// Include common routines
#include <sys/types.h>
#include <verilated.h>
#include <verilated_fst_c.h>
#include <verilated_vcd_c.h>

// Include model header, generated from Verilating "top.v"
#include "Vemu.h"
#include "Vemu___024root.h"

#include <chrono>
#include <csignal>
#include <cstdint>
#include <png.h>

#include "crc.h"
#include "hle.h"
#include "scramble.h"
#include "table_of_contents.h"
#include <arpa/inet.h>
#include <byteswap.h>

#define SCC68070
#define SLAVE
#define TRACE
// #define SIMULATE_RC5

#define PL_MPEG_IMPLEMENTATION
#include "pl_mpeg_pc.h"

char GetPictureType(int val) {
    switch (val) {
    case PLM_VIDEO_PICTURE_TYPE_INTRA:
        return 'I';
    case PLM_VIDEO_PICTURE_TYPE_PREDICTIVE:
        return 'P';
    case PLM_VIDEO_PICTURE_TYPE_B:
        return 'B';
    default:
        return '?';
    }
}

int write_bmp(const char *path, int width, int height, uint8_t *pixels) {
    FILE *fh = fopen(path, "wb");
    if (!fh) {
        return 0;
    }

    int padded_width = (width * 3 + 3) & (~3);
    int padding = padded_width - (width * 3);
    int data_size = padded_width * height;
    int file_size = 54 + data_size;

    fwrite("BM", 1, 2, fh);
    fwrite(&file_size, 1, 4, fh);
    fwrite("\x00\x00\x00\x00\x36\x00\x00\x00\x28\x00\x00\x00", 1, 12, fh);
    fwrite(&width, 1, 4, fh);
    fwrite(&height, 1, 4, fh);
    fwrite("\x01\x00\x18\x00\x00\x00\x00\x00", 1, 8, fh); // planes, bpp, compression
    fwrite(&data_size, 1, 4, fh);
    fwrite("\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", 1, 16, fh);

    for (int y = height - 1; y >= 0; y--) {
        fwrite(pixels + y * width * 3, 3, width, fh);
        fwrite("\x00\x00\x00\x00", 1, padding, fh);
    }
    fclose(fh);
    return file_size;
}

typedef struct {
    unsigned int width;
    unsigned int height;
    uint32_t adr;
} plm_plane2_t;

typedef struct {
    int32_t time;
    unsigned int width;
    unsigned int height;
    plm_plane2_t y;
    plm_plane2_t cr;
    plm_plane2_t cb;
} plm_frame2_t;

#define BCD(v) ((uint8_t)((((v) / 10) << 4) | ((v) % 10)))

struct subcode {
    // Subcode Q
    uint16_t control;
    uint16_t track;
    uint16_t index;
    uint16_t mode1_mins;
    uint16_t mode1_secs;
    uint16_t mode1_frac;
    uint16_t mode1_zero;
    uint16_t mode1_amins;
    uint16_t mode1_asecs;
    uint16_t mode1_afrac;
    uint16_t mode1_crc0;
    uint16_t mode1_crc1;

    // Subcode RW in interleaved form
    uint16_t rw[96];
};
static_assert(sizeof(struct subcode) == (12 + 96) * 2);

struct toc_entry toc_buffer[100];
int toc_entry_count = 0;

#ifdef TRACE
typedef VerilatedFstC tracetype_t;

static bool do_trace{true};
#endif
volatile sig_atomic_t status = 0;

const int width = 120 * 16;
const int height = 312;
const int size = width * height * 3;

FILE *f_cd_bin{nullptr};
FILE *f_sub_bin{nullptr};

template <typename T, typename U> constexpr T BIT(T x, U n) noexcept {
    return (x >> n) & T(1);
}

bool press_button_signal{false};
bool print_instructions{false};

void signal_handler(int signum, siginfo_t *info, void *context) {
    fprintf(stderr, "Received signal %d\n", signum);

    switch (signum) {
    case SIGINT:
        // End simulation
        status = signum;
        break;
    case SIGUSR1:
        // Press a button
        // example: killall -s USR1 Vemu
        press_button_signal = true;
        break;
    case SIGUSR2:
        // example: killall -s USR2 Vemu
#ifdef TRACE
        do_trace = !do_trace;
        fprintf(stderr, "Trace %s\n", do_trace ? "on" : "off");
#else
        print_instructions = !print_instructions;
        fprintf(stderr, "Instruction Trace %s\n", print_instructions ? "on" : "off");
#endif
        break;
    }
}

// got from mame
uint32_t lba_from_time(uint32_t m_time) {
    const uint8_t bcd_mins = (m_time >> 24) & 0xff;
    const uint8_t mins_upper_digit = bcd_mins >> 4;
    const uint8_t mins_lower_digit = bcd_mins & 0xf;
    const uint8_t raw_mins = (mins_upper_digit * 10) + mins_lower_digit;

    const uint8_t bcd_secs = (m_time >> 16) & 0xff;
    const uint8_t secs_upper_digit = bcd_secs >> 4;
    const uint8_t secs_lower_digit = bcd_secs & 0xf;
    const uint8_t raw_secs = (secs_upper_digit * 10) + secs_lower_digit;

    uint32_t lba = ((raw_mins * 60) + raw_secs) * 75;

    const uint8_t bcd_frac = (m_time >> 8) & 0xff;
    const bool even_second = BIT(bcd_frac, 7);
    if (!even_second) {
        const uint8_t frac_upper_digit = bcd_frac >> 4;
        const uint8_t frac_lower_digit = bcd_frac & 0xf;
        const uint8_t raw_frac = (frac_upper_digit * 10) + frac_lower_digit;
        lba += raw_frac;
    }

    if (lba >= 150)
        lba -= 150;

    return lba;
}

static inline uint32_t unBCD(uint32_t val) {
    return ((val & 0xf0) >> 4) * 10 + (val & 0x0f);
}

void check_scramble(int lba, uint8_t *buffer) {
    // Check for sync pattern to confirm mode 2
    // Starts and ends with 0x00 and ...
    if ((buffer[0] != 0) || (buffer[11] != 0))
        return;

    // ... inbetween there are 0xff bytes
    for (uint32_t i = 01; i < 11; i++)
        if (buffer[i] != 0xff)
            return;

    // Sync pattern confirmed. check validity of mode2 header
    uint32_t mm, ss, ff;
    uint8_t mode;

    mm = unBCD(buffer[12]);
    ss = unBCD(buffer[13]);
    ff = unBCD(buffer[14]);
    mode = buffer[15];
    int mode2_lba = mm * 75 * 60 + ss * 75 + ff;

    if (mode2_lba == lba && mode == 2) {
        // Is a valid header. Do nothing
    } else {
        // Can we fix it? Let's test on 4 bytes
        mm = unBCD(buffer[12] ^ s_sector_scramble[0]);
        ss = unBCD(buffer[13] ^ s_sector_scramble[1]);
        ff = unBCD(buffer[14] ^ s_sector_scramble[2]);
        mode = buffer[15] ^ s_sector_scramble[3];
        mode2_lba = mm * 75 * 60 + ss * 75 + ff;
        if (mode2_lba == lba && mode == 2) {
            descramble_sector(buffer);
        }
    }
}

void reinterleave_rw_subchannels(const uint8_t rw[6][12], uint16_t raw[96]) {
    memset(raw, 0, sizeof(uint16_t) * 96);

    for (int symbol = 0; symbol < 96; symbol++) {
        uint8_t out = 0;

        for (int ch = 0; ch < 6; ch++) {
            uint8_t bit = (rw[ch][symbol >> 3] >> (7 - (symbol & 7))) & 1;

            out |= bit << (5 - ch);
        }

        raw[symbol] = htons(out);
    }
}

void subcode_data(int lba, struct subcode &out) {
    int fake_lba = lba;
    if (fake_lba < 150)
        fake_lba += 150;
    uint8_t m, s, f;
    m = fake_lba / (60 * 75);
    fake_lba -= m * (60 * 75);
    s = fake_lba / 75;
    f = fake_lba % 75;

    int toc_entry_index = lba + 0x10000;
    if (lba < 0 && toc_entry_index < toc_entry_count) {

        auto &toc_entry = toc_buffer[toc_entry_index];

        out.control = htons(toc_entry.control);
        out.track = 0; // Track 0 for TOC
        out.index = htons(toc_entry.track);
        out.mode1_mins = htons(BCD(m));
        out.mode1_secs = htons(BCD(s));
        out.mode1_frac = htons(BCD(f));
        out.mode1_zero = 0;
        out.mode1_amins = htons(toc_entry.m);
        out.mode1_asecs = htons(toc_entry.s);
        out.mode1_afrac = htons(toc_entry.f);
        out.mode1_crc0 = htons(0xff);
        out.mode1_crc1 = htons(0xff);

        // printf("toc  lba=%d   %02x %02x %02x %02x %02x\n", toc_entry_index, out.control, out.index, out.mode1_amins,
        //        out.mode1_asecs, out.mode1_afrac);
    } else {
        int track = 1;
        out.control = htons(0x01);
        out.track = htons(1); // Track 1 for TOC
        out.index = htons(1);
        out.mode1_mins = htons(BCD(m));
        out.mode1_secs = htons(BCD(s));
        out.mode1_frac = htons(BCD(f));
        out.mode1_zero = 0;
        out.mode1_amins = htons(BCD(m));
        out.mode1_asecs = htons(BCD(s));
        out.mode1_afrac = htons(BCD(f));
        out.mode1_crc0 = htons(0xff);
        out.mode1_crc1 = htons(0xff);

        // printf("data lba=%d   %02x %02x %02x %02x %02x\n", lba, out.control, out.track, BCD(m), BCD(s), BCD(f));
    }

    uint16_t crc_accum = 0;
    uint8_t *crc = reinterpret_cast<uint8_t *>(&out);
    for (int i = 0; i < 12; i++)
        crc_accum = CRC_CCITT_ROUND(crc_accum, crc[1 + i * 2]);

    out.mode1_crc0 = htons((crc_accum >> 8) & 0xff);
    out.mode1_crc1 = htons(crc_accum & 0xff);

    printf("subcode %d   %02x %02x %02x %02x %02x %02x     %02x %02x %02x %02x %02x %02x\n", lba, ntohs(out.control),
           ntohs(out.track), ntohs(out.index), ntohs(out.mode1_mins), ntohs(out.mode1_secs), ntohs(out.mode1_frac),
           ntohs(out.mode1_zero), ntohs(out.mode1_amins), ntohs(out.mode1_asecs), ntohs(out.mode1_afrac),
           ntohs(out.mode1_crc0), ntohs(out.mode1_crc1));
}

class CDi {
  public:
#ifdef SIMULATE_RC5
    FILE *rc5_file;
    uint64_t rc5_fliptime{0};
    uint32_t rc5_nextstate{1};
#endif

    Vemu dut;
    uint64_t time30mhz = 0;
    uint64_t tracetime = 0;
    int frame_index = 0;
    int release_button_frame{-1};
    int fmv_frame_cnt{0};

  private:
    FILE *f_audio_left{nullptr};
    FILE *f_audio_right{nullptr};
    FILE *f_fma{nullptr};
    FILE *f_fma_mp2{nullptr};

    FILE *f_fmv{nullptr};
    FILE *f_fmv_m1v{nullptr};

    int fmv_index{0};
    /// @brief Used to decide whether a new index must be created
    /// Only create a new index when enough data was collected for the last
    int fmv_collected_data_cnt{0};

    FILE *f_uart{nullptr};

    uint8_t output_image[size] = {0};
    uint32_t regfile[16];
#ifdef TRACE
    tracetype_t m_trace;
#endif

    uint32_t prevpc = 0;
    uint32_t leave_sys_callpc = 0;
    SttFunction call_func;

    int pixel_index = 0;

    uint16_t hps_buffer[4096];
    uint16_t hps_buffer_index = 0;
    bool hps_nvram_backup_active{false};
    bool ignore_first_hps_din{false};
    bool executing_dvc_rom_instructions{false};

    int instanceid;

    std::chrono::_V2::system_clock::time_point start;
    static constexpr uint32_t kSectorHeaderSize{12};
    static constexpr uint32_t kSectorSize{2352};
    static constexpr uint32_t kSubcodeRWSize{96};
    static constexpr uint32_t kSubcodeQSize{12};
    static constexpr uint32_t kWordsPerSubcodeFrame{kSubcodeQSize + kSubcodeRWSize};
    static constexpr uint32_t kWordsPerSector{kWordsPerSubcodeFrame + kSectorSize / 2};

    uint32_t get_pixel_value(uint32_t x, uint32_t y) {
        uint8_t *pixel = &output_image[(width * y + x) * 3];
        uint32_t r = static_cast<uint32_t>(*pixel++) << 16;
        uint32_t g = static_cast<uint32_t>(*pixel++) << 8;
        uint32_t b = static_cast<uint32_t>(*pixel++);
        return r | g | b;
    }

    void write_png_file(const char *filename) {
        FILE *fp = fopen(filename, "wb");
        if (!fp)
            abort();

        png_structp png = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
        if (!png)
            abort();

        png_infop info = png_create_info_struct(png);
        if (!info)
            abort();

        if (setjmp(png_jmpbuf(png)))
            abort();

        png_init_io(png, fp);

        int png_height_scale = 4;
        int png_height = height * png_height_scale;
        // Output is 8bit depth, RGBA format.
        png_set_IHDR(png, info, width, png_height, 8, PNG_COLOR_TYPE_RGB, PNG_INTERLACE_NONE,
                     PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
        png_write_info(png, info);

        png_bytepp row_pointers = (png_bytepp)png_malloc(png, sizeof(png_bytepp) * png_height);

        for (int i = 0; i < png_height; i++) {
            row_pointers[i] = &output_image[width * 3 * (i / png_height_scale)];
        }

        png_write_image(png, row_pointers);
        png_write_end(png, NULL);

        free(row_pointers);

        fclose(fp);

        png_destroy_write_struct(&png, &info);
    }

    uint16_t phase_accumulator;

    void clockmpeg() {
        mpeg_clk_calc_ticks++;

        for (int i = 0; i < 2; i++) {
            dut.rootp->emu__DOT__clk_mpeg = i & 1;
            dut.eval();
#ifdef TRACE
            if (do_trace) {
                m_trace.dump(tracetime);
            }
#endif
            tracetime++;
        }
    }

    // These two are used to calculate the actual MPEG frequency
    // required to do the job on a frame basis
    uint32_t mpeg_clk_calc_ticks30{0}; ///< counts 30 MHz clock ticks
    uint32_t mpeg_clk_calc_ticks{0};   ///< counts MPEG clock ticks

    /*
    Primarily creates a 30 MHz clock and
    derives 22.2264 MHz audio clock from that.
    Dynamically creates a frequency for clk_mpeg
    from 30 to 90 MHz depending on MPEG load to
    speed up the simulation when the performance is not required.
    */
    void clock30() {
        mpeg_clk_calc_ticks30++;
        mpeg_clk_calc_ticks++;

        uint32_t fmv_fifo_level = dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__video__DOT__fifo_level;

        for (int i = 0; i < 2; i++) {
            // clk_sys is 30 MHz
            dut.rootp->emu__DOT__clk_sys = (i & 1);

            // clk_mpeg is 30 MHz when no work is to be done
            dut.rootp->emu__DOT__clk_mpeg = (i & 1);

            // clk_audio is 6.615 MHz
            // 6.615 MHz * 2^15 / 30 MHz = 7225.344
            phase_accumulator += 7225;
            dut.rootp->emu__DOT__clk_audio = (phase_accumulator & 0x8000) ? 1 : 0;

            dut.eval();
#ifdef TRACE
            if (do_trace) {
                m_trace.dump(tracetime);
            }
#endif
            tracetime++;
        }

        // The FPGA PLL is configured for 80 MHz, but
        // the power is not always required. Scale it up to 60 MHZ
        if (fmv_fifo_level > 2000) {
            clockmpeg();
        }

        // Ok, scale it up to 90 MHz
        if (fmv_fifo_level > 8000) {
            clockmpeg();
        }
    }

    /// @brief Reads from RAM based on CPU memory view
    uint16_t cpu_memory_read_u16(uint32_t addr) {
        // ensure alignment
        assert((addr & 1) == 0);

        if (addr < 0x080000) {
            return dut.rootp->emu__DOT__ram[(addr) >> 1]; // Video A bank
        } else if (addr >= 0x200000 && addr < 0x280000) {
            return dut.rootp->emu__DOT__ram[(addr - 0x200000 + 0x80000) >> 1]; // Video B bank
        } else if (addr >= 0x400000 && addr <= 0x4ffbff) {
            return dut.rootp->emu__DOT__rom[(addr - 0x400000) >> 1]; // System ROM
        } else if (addr >= 0xd00000 && addr <= 0xdfffff) {
            return dut.rootp->emu__DOT__ram[(addr - 0xd00000 + 0x100000) >> 1]; // DVC RAM
        } else if (addr >= 0xe40000 && addr < 0xe60000) {
            return dut.rootp->emu__DOT__vmpega_rom[(addr - 0xe40000) >> 1]; // VMPEG ROM
        } else {
            printf("Not mapped? %x\n", addr);
            return 0;
            // exit(1);
        }
    }

    uint8_t cpu_memory_read_u8(uint32_t addr) {
        if (addr & 1)
            return cpu_memory_read_u16(addr);
        else
            return cpu_memory_read_u16(addr) >> 8;
    }

    uint32_t cpu_memory_read_u32(uint32_t addr) {
        uint32_t high = cpu_memory_read_u16(addr);
        uint32_t low = cpu_memory_read_u16(addr + 2);

        return (high << 16) | low;
    }

    typedef struct _motionstatus {
        unsigned short MVS_LCntr;  /* loops remaining */
        unsigned long MVS_CurAdr;  /* address to retrieve data */
        unsigned long MVS_Speed;   /* display speed */
        unsigned long MVS_ImgSz;   /* image size of current stream */
        unsigned long MVS_TimeCd;  /* timecode of current picture */
        unsigned short MVS_TmpRef; /* temporal reference */
        unsigned short MVS_Stream; /* current stream number */
        unsigned char MVS_PicRt,   /* picture rate */
            MVS_Res1;              /* reserved */
        unsigned long MVS_DSC,     /* Video decoder system clock */
            MVS_Res2;              /* reserved */
    } MotionStatus;

    void PrintMvStatus(uint32_t addr) {
        MotionStatus status;
        status.MVS_LCntr = cpu_memory_read_u16(addr + 0);
        status.MVS_CurAdr = cpu_memory_read_u32(addr + 2);
        status.MVS_Speed = cpu_memory_read_u32(addr + 6);
        status.MVS_ImgSz = cpu_memory_read_u32(addr + 10);
        status.MVS_TimeCd = cpu_memory_read_u32(addr + 14);
        status.MVS_TmpRef = cpu_memory_read_u16(addr + 18);
        status.MVS_Stream = cpu_memory_read_u16(addr + 20);
        status.MVS_PicRt = cpu_memory_read_u8(addr + 22);
        status.MVS_DSC = cpu_memory_read_u32(addr + 24);

        printf("MVS_LCntr %x\n", status.MVS_LCntr);
        printf("MVS_CurAdr %x\n", status.MVS_CurAdr);
        printf("MVS_Speed %x\n", status.MVS_Speed);
        printf("MVS_ImgSz %x\n", status.MVS_ImgSz);
        printf("MVS_TimeCd %x\n", status.MVS_TimeCd);
        printf("MVS_TmpRef %x\n", status.MVS_TmpRef);
        printf("MVS_Stream %x\n", status.MVS_Stream);
        printf("MVS_PicRt %x\n", status.MVS_PicRt);
        printf("MVS_DSC %x\n", status.MVS_DSC);
    }

    void AnalyzeSyscall() {
        // A syscall is a "Trap #0" followed by a 16 bit argument
        assert((prevpc & 1) == 0);
        uint32_t calladdr = prevpc + 2;
        uint16_t call = cpu_memory_read_u16(calladdr);
        printf("Syscall @ %x %x %s", prevpc, call, systemCallNameToString(static_cast<SystemCallType>(call)));
        uint32_t *cpu_d = &dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__regfile[0];
        uint32_t *cpu_a = &dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__regfile[8];

        for (int i = 0; i < 8; i++) {
            printf(" %08x", cpu_d[i]);
        }
        printf(" ");
        for (int i = 0; i < 8; i++) {
            printf(" %08x", cpu_a[i]);
        }

        if (static_cast<SystemCallType>(call) == SystemCallType::I_SetStt) {
            SttFunction func = static_cast<SttFunction>(cpu_d[1] & 0xffff);

            printf(" SetStt %s", sttFunctionToString(func));

            if (func == SttFunction::MV_Window) {
                uint32_t height = cpu_d[4] & 0xffff;
                uint32_t width = (cpu_d[4] >> 16) & 0xffff;
                printf(" %d %d ", width, height);
                // Check plausibility
                if ((width > 1000) || (height > 1000))
                    printf("UNPLAUSIBLE!\n");
            }

            if (func == SttFunction::SS_DC) {
                printf(" %s at video pos %d %d", ss_dc_FunctionToString(cpu_d[2]),
                       dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_x,
                       dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_y);
                if (cpu_d[2] == 0x0a && (cpu_d[6] & 0xF0000000) == 0x40000000) {
                    printf(" VSR %x", cpu_d[6] & 0xFFFFFFF);
                }
            }

            call_func = func;
        }
        if (static_cast<SystemCallType>(call) == SystemCallType::I_GetStt) {
            SttFunction func = static_cast<SttFunction>(cpu_d[1] & 0xffff);
            printf(" GetStt %s", sttFunctionToString(func));
            call_func = func;
        }
        printf("\n");

        leave_sys_callpc = prevpc + 4;

        // SysDbg ? Just give up!
        if (static_cast<SystemCallType>(call) == SystemCallType::F_SysDbg) {
            fprintf(stderr, "System halted and debugger calted!\n");
            exit(1);
        }
    }

    void AnalyzeSyscallReturn() {
        uint32_t *cpu_d = &dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__regfile[0];
        uint32_t *cpu_a = &dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__regfile[8];

        if (call_func == MV_Status) {
            PrintMvStatus(cpu_a[0]);
        }

        call_func = SS_Opt; // Invalidate
    }

    // Keep pressing B1 until the broken game is reached
    void lost_ride_pal() {
        if (frame_index > 150) {
            if ((frame_index % 40) == 10) {
                press_button_signal = true;
            }
        }
    }

    /// Presses buttons until game is reached
    void space_ace_pal() {
        switch (frame_index) {
        case 154:
            // Skip Philips Intro
            press_button_signal = true;
            break;
        case 414:
            // Skip SUPERCLUB company logo
            press_button_signal = true;
            break;
        case 460:
            // Skip game intro
            press_button_signal = true;
            break;
        }
    }

    /// Presses buttons until game is reached
    void braindead13_pal() {
        switch (frame_index) {
        case 250:
            // Skip Philips Intro
            press_button_signal = true;
            break;
        case 300:
            // Skip ICDI company logo
            press_button_signal = true;
            break;
        case 313:
#ifdef TRACE
            do_trace = true;
            fprintf(stderr, "Trace on!\n");
#endif
            break;
        case 365:
            // status = 1;
            // fprintf(stderr, "Stop!\n");
            break;
        case 460: // TODO index might be wrong
            // Skip game intro
            press_button_signal = true;
            break;
        }
    }

  public:
    void loadfile(uint16_t index, const char *path) {

        FILE *f = fopen(path, "rb");
        assert(f);

        uint16_t transferword;

        dut.rootp->emu__DOT__ioctl_addr = 0;
        dut.rootp->emu__DOT__ioctl_index = index;

        // make some clocks before starting
        for (int step = 0; step < 300; step++) {
            clock30();
        }

        while (fread(&transferword, 2, 1, f) == 1) {
            dut.rootp->emu__DOT__ioctl_wr = 1;
            dut.rootp->emu__DOT__ioctl_dout = transferword;

            clock30();
            dut.rootp->emu__DOT__ioctl_wr = 0;

            // make some clocks to avoid asking for busy
            // the real MiSTer has 31 clocks between writes
            // we are going for ~20 to put more stress on it.
            for (int i = 0; i < 20; i++) {
                clock30();
            }
            dut.rootp->emu__DOT__ioctl_addr += 2;
            clock30();
        }
        fclose(f);
    }

    void printstate() {
#ifdef SCC68070
        uint32_t pc = dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__exe_pc;
        // d0 = dut.rootp->fx68k_tb__DOT__d0;
        memcpy(regfile, &dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__regfile[0],
               sizeof(regfile));

        printf("%08x ", pc);
        for (int i = 0; i < 16; i++) {
            if (i == 8)
                printf(" ");
            printf(" %08x", regfile[i]);
        }
        printf("\n");
#endif
    }

    void modelstep() {
        time30mhz++;
        clock30();

#ifdef SIMULATE_RC5
        if (time30mhz >= rc5_fliptime) {
            dut.rootp->emu__DOT__rc_eye = rc5_nextstate;

            fprintf(stderr, "Set RC5!\n");
            char buffer[100];
            if (!fgets(buffer, sizeof(buffer), rc5_file))
                exit(1);
            char *endptr;
            // primitive csv parsing
            float next_flip = std::max(strtof(buffer, &endptr) - 2.58810f + 3.0f, 0.0f) * 30e6 * 2;
            rc5_nextstate = strtol(endptr + 1, &endptr, 10);
            assert(rc5_nextstate <= 1);
            printf("%f %d\n", next_flip, rc5_nextstate);
            rc5_fliptime = next_flip;
        }
#endif

        if ((time30mhz % 100000) == 0) {
            printf("%d\n", time30mhz);
        }

        dut.rootp->emu__DOT__cd_media_change = (time30mhz == 1300000);
        if (time30mhz == 1300000)
            printf("Media change!\n");

#ifdef SCC68070

        if (dut.rootp->emu__DOT__cditop__DOT__as && !dut.rootp->emu__DOT__cditop__DOT__write_strobe &&
            dut.rootp->emu__DOT__cditop__DOT__bus_ack && dut.rootp->emu__DOT__cditop__DOT__addr_byte < 0x60) {
            switch (dut.rootp->emu__DOT__cditop__DOT__addr_byte >> 2) {
            case 0: // Ignore Reset SP
            case 1: // Ignore Reset PC
                break;
            case 2:
                printf("Exception - Bus error\n");
                break;
            case 3:
                printf("Exception - Address error\n");
                break;
            case 4:
                printf("Exception - Illegal instruction\n");
                status = 1;
                break;
            case 5:
                printf("Exception - Division by zero\n");
                status = 1;
                break;
            case 8:
                printf("Exception - Privilege violation \n");
                break;
            default:
                printf("Exception - %d ??? \n", dut.rootp->emu__DOT__cditop__DOT__addr_byte >> 2);
                break;
            }
        }

#endif

        dut.rootp->emu__DOT__nvram_media_change = (time30mhz == 2000);
        // Simulate CD data delivery from HPS
        if (dut.rootp->emu__DOT__cd_hps_req && dut.rootp->emu__DOT__cd_hps_ack == 0 &&
            dut.rootp->emu__DOT__nvram_hps_ack == 0) {
            assert(dut.rootp->emu__DOT__cd_hps_ack == 0);
            dut.rootp->emu__DOT__cd_hps_ack = 1;

            uint32_t lba = dut.rootp->emu__DOT__cd_hps_lba;
            uint32_t m_time = dut.rootp->emu__DOT__cditop__DOT__cdic_inst__DOT__time_register;

            uint32_t reference_lba = lba_from_time(m_time);
            // assert(lba == reference_lba);
            // assert(lba >= 150);

            if (lba < 150)
                lba += 150;
            uint32_t file_offset = (lba - 150) * kSectorSize;

            printf("Request CD Sector %x %x %x\n", m_time, lba, file_offset);

            int res = fseek(f_cd_bin, file_offset, SEEK_SET);
            assert(res == 0);

            res = fread(hps_buffer, 1, kSectorSize, f_cd_bin);
            assert(res == kSectorSize);

            check_scramble(lba, reinterpret_cast<uint8_t *>(hps_buffer));

            // Subcode Q
            struct subcode &out = *reinterpret_cast<struct subcode *>(&hps_buffer[kSectorSize / 2]);
            subcode_data(dut.rootp->emu__DOT__cd_hps_lba, out);

            // Subcode RW from .sub file
            uint8_t rw[kSubcodeRWSize];
            // First we read the raw bytes
            file_offset = (lba - 150) * kSubcodeRWSize;
            if (f_sub_bin) {
                res = fseek(f_sub_bin, file_offset, SEEK_SET);
                assert(res == 0);
                res = fread(rw, 1, kSubcodeRWSize, f_sub_bin);
                assert(res == kSubcodeRWSize);
            } else {
                memset(rw, 0, sizeof(rw));
            }
            /*
            // Then we need to convert them to words
            for (int i = 0; i < kSubcodeRWSize; i++) {
                out.rw[i] = htons(rw[i]);
            }*/
            reinterleave_rw_subchannels(reinterpret_cast<uint8_t (*)[12]>(&rw[24]), out.rw);

            hps_buffer_index = 0;
        }

        if (dut.rootp->emu__DOT__nvram_hps_rd && dut.rootp->emu__DOT__nvram_hps_ack == 0 &&
            dut.rootp->emu__DOT__cd_hps_ack == 0) {
            assert(dut.rootp->emu__DOT__nvram_hps_ack == 0);
            dut.rootp->emu__DOT__nvram_hps_ack = 1;

            printf("Request NvRAM restore!\n");

            FILE *f_nvram_bin = fopen("save_in.bin", "rb");
            if (f_nvram_bin) {
                fread(hps_buffer, 1, 8192, f_nvram_bin);
                hps_buffer_index = 0;
                dut.rootp->emu__DOT__sd_buff_addr = hps_buffer_index;
                fclose(f_nvram_bin);
            }
        }

        if (dut.rootp->emu__DOT__nvram_hps_wr && dut.rootp->emu__DOT__nvram_hps_ack == 0 &&
            dut.rootp->emu__DOT__cd_hps_ack == 0) {
            assert(dut.rootp->emu__DOT__nvram_hps_ack == 0);
            dut.rootp->emu__DOT__nvram_hps_ack = 1;

            printf("Request NvRAM backup!\n");
            hps_buffer_index = 0;
            hps_nvram_backup_active = true;
            dut.rootp->emu__DOT__sd_buff_addr = hps_buffer_index;
            ignore_first_hps_din = true;
        }

        dut.rootp->emu__DOT__sd_buff_wr = 0;
        if (dut.rootp->emu__DOT__cd_hps_ack && (time30mhz % 180) == 15) {
            if (hps_buffer_index == kWordsPerSector) {
                dut.rootp->emu__DOT__cd_hps_ack = 0;
                printf("Sector transferred!\n");
            } else {
                dut.rootp->emu__DOT__sd_buff_dout = hps_buffer[hps_buffer_index];
                dut.rootp->emu__DOT__sd_buff_wr = 1;
                hps_buffer_index++;
            }
        }

        if (dut.rootp->emu__DOT__nvram_hps_ack && (time30mhz % 20) == 15) {
            if (hps_nvram_backup_active) {
                if (hps_buffer_index == 4096) {
                    dut.rootp->emu__DOT__nvram_hps_ack = 0;
                    printf("NvRAM backed up!\n");

                    FILE *f_nvram_bin = fopen("save_out.bin", "wb");
                    assert(f_nvram_bin);
                    fwrite(hps_buffer, 1, 8192, f_nvram_bin);
                    hps_nvram_backup_active = false;
                    fclose(f_nvram_bin);
                } else {
                    hps_buffer[hps_buffer_index] = dut.rootp->emu__DOT__nvram_hps_din;

                    if (ignore_first_hps_din)
                        ignore_first_hps_din = false;
                    else
                        hps_buffer_index++;

                    dut.rootp->emu__DOT__sd_buff_addr = hps_buffer_index;
                }

            } else {
                if (hps_buffer_index == 4096) {
                    dut.rootp->emu__DOT__nvram_hps_ack = 0;
                    printf("NvRAM restored!\n");
                } else {
                    dut.rootp->emu__DOT__sd_buff_dout = hps_buffer[hps_buffer_index];
                    dut.rootp->emu__DOT__sd_buff_wr = 1;
                    dut.rootp->emu__DOT__sd_buff_addr = hps_buffer_index;

                    hps_buffer_index++;
                }
            }
        }

        if (dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__uart_tx_data_valid) {
            fputc(dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__uart_transmit_holding_register, f_uart);
            fflush(f_uart);
        }

        // Trace System Calls
#ifdef SCC68070
        if (dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__decodeopc &&
            dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__clkena_in) {

            uint32_t m_pc = dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__exe_pc;

            if (m_pc == 0x62c) {
                AnalyzeSyscall();
            }

            if (m_pc == 0x0e52e50) {
                // We are at the beginning of IrqSrvc in fdrvs1. This means that A2 contains fdrvs1_static
                uint32_t *cpu_a =
                    &dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__regfile[8];
                dut.rootp->emu__DOT__cditop__DOT__fdrvs1_static = cpu_a[2];
            }

#if 0
            executing_dvc_rom_instructions = m_pc >= 0xe40000 && m_pc < 0xe7ffff;
#endif
            if (print_instructions || executing_dvc_rom_instructions) {
                printstate();
            }

            if (m_pc == leave_sys_callpc) {
                printf("Return from Syscall %x %x  ",
                       dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__flags,
                       dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__flagssr);
                printstate();
                AnalyzeSyscallReturn();
            }

            prevpc = m_pc;
        }

#if 0
        if (executing_dvc_rom_instructions && dut.rootp->emu__DOT__cditop__DOT__bus_ack &&
            (dut.rootp->emu__DOT__cditop__DOT__addr_byte & 0xf00000) != 0xe00000) {

            printf("CPU %s %x %x %d%d\n", dut.rootp->emu__DOT__cditop__DOT__write_strobe ? "Write" : "Read",
                   dut.rootp->emu__DOT__cditop__DOT__addr_byte, dut.rootp->emu__DOT__cditop__DOT__cpu_data,
                   dut.rootp->emu__DOT__cditop__DOT__uds, dut.rootp->emu__DOT__cditop__DOT__lds);
        }
#endif
#endif

        // Simulate television
        if (dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_y == 0 &&
            dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_x == 0) {
            char filename[100];

#ifndef SIMULATE_RC5
            if (dut.rootp->emu__DOT__tvmode_ntsc) {
                // NTSC
            } else {
                // PAL
                // space_ace_pal();
                // braindead13_pal();
                // lost_ride_pal();
            }
#endif

            if (press_button_signal) {
                press_button_signal = false;
                release_button_frame = frame_index + 10;
                printf("Press a button!\n");
                fprintf(stderr, "Press a button!\n");
                dut.rootp->emu__DOT__JOY0 = 0b10000;
            }

            if (release_button_frame == frame_index) {
                printf("Release a button!\n");
                fprintf(stderr, "Release a button!\n");
                dut.rootp->emu__DOT__JOY0 = 0b00000;
            }

            if (pixel_index > 400) {
                auto current = std::chrono::system_clock::now();
                std::chrono::duration<double> elapsed_seconds = current - start;
                sprintf(filename, "%d/video_%03d.png", instanceid, frame_index);
                write_png_file(filename);
                printf("Written video_%03d.png\n", frame_index);
                // printf("We are at time30mhz=%ld\n", time30mhz);

                uint32_t mpeg_frequency = mpeg_clk_calc_ticks * 30 / mpeg_clk_calc_ticks30;

                // printf("Written %s after %.2fs. FMV at %d MHz\n", filename, elapsed_seconds.count(), mpeg_frequency);
                fprintf(stderr, "Written %s after %.2fs. FMV at %d MHz\n", filename, elapsed_seconds.count(),
                        mpeg_frequency);

                mpeg_clk_calc_ticks30 = 0;
                mpeg_clk_calc_ticks = 0;

                frame_index++;
                dut.rootp->emu__DOT__cditop__DOT__frame_index = frame_index;
            }
            pixel_index = 0;
            memset(output_image, 0, sizeof(output_image));
        }

        // Simulate Audio
        if (dut.rootp->emu__DOT__cditop__DOT__cdic_inst__DOT__sample_tick) {
            int16_t sample_l = dut.rootp->emu__DOT__cditop__DOT__cdic_inst__DOT__adpcm__DOT__fifo_out_left;
            int16_t sample_r = dut.rootp->emu__DOT__cditop__DOT__cdic_inst__DOT__adpcm__DOT__fifo_out_right;
            fwrite(&sample_l, 2, 1, f_audio_left);
            fwrite(&sample_r, 2, 1, f_audio_right);
        }

        if (dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__video__DOT__expose_frame_struct_adr) {
            uint32_t addr = dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__video__DOT__frame_struct_adr;
            uint8_t *mem1 =
                (uint8_t *)&dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__video__DOT__core1mem__DOT__ram;
            uint8_t *mem_video = (uint8_t *)&dut.rootp->emu__DOT__ddram;

            plm_frame2_t frame = *(plm_frame2_t *)(mem1 + addr);

            printf("%d %d %x %x %x\n", frame.width, frame.height, frame.y.adr, frame.cr.adr, frame.cb.adr);

            // printf("%x %x %x\n",mem[frame.y.adr], mem[frame.cr.adr],mem[frame.cb.adr]);
            plm_frame_t frame_convert;
            frame_convert.y.data = &mem_video[frame.y.adr];
            frame_convert.y.height = frame.y.height;
            frame_convert.y.width = frame.y.width;
            frame_convert.cr.data = &mem_video[frame.cr.adr];
            frame_convert.cr.height = frame.cr.height;
            frame_convert.cr.width = frame.cr.width;
            frame_convert.cb.data = &mem_video[frame.cb.adr];
            frame_convert.cb.height = frame.cb.height;
            frame_convert.cb.width = frame.cb.width;
            frame_convert.width = frame.width;
            frame_convert.height = frame.height;

            char bmp_name[20];
            int w = frame.width;
            int h = frame.height;
            uint8_t *pixels = (uint8_t *)malloc(w * h * 3);
            assert(pixels);
            plm_frame_to_bgr(&frame_convert, pixels, w * 3); // BMP expects BGR ordering

#ifdef TRACE
            // do_trace = true;
#endif
            sprintf(bmp_name, "%d/%03d.bmp", instanceid, fmv_frame_cnt);
            printf("FMV Writing %s at Fifo Level %d at Frame Level %d\n", bmp_name,
                   dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__video__DOT__fifo_level,
                   dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__video__DOT__pictures_in_fifo_clk_mpeg);
            ;
            fprintf(stderr, "FMV Writing %s at Fifo Level %d at Frame Level %d\n", bmp_name,
                    dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__video__DOT__fifo_level,
                    dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__video__DOT__pictures_in_fifo_clk_mpeg);

            write_bmp(bmp_name, w, h, pixels);

            free(pixels);
            fmv_frame_cnt++;

#if 0
            FILE *f = fopen("ddramdump.bin", "wb");
            assert(f);
            fwrite(&dut.rootp->emu__DOT__ddram[0], 1, 5000000, f);
            fclose(f);
#endif
        }

        if (dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__restart_fmv_dsp_enable) {
            open_fmv_trace();
        }

        if (dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__fmv_data_valid) {
            fmv_collected_data_cnt++;

            fwrite(&dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__mpeg_data, 1, 1, f_fmv);

            if (dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__fmv_packet_body) {
                fwrite(&dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__mpeg_data, 1, 1, f_fmv_m1v);
            }
#ifdef TRACE
            if (!do_trace)
                fprintf(stderr, "Trace on!\n");
            do_trace = true;
#endif
        }
        if (dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__fma_data_valid) {
            fwrite(&dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__mpeg_data, 1, 1, f_fma);

            if (dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__fma_packet_body) {
                fwrite(&dut.rootp->emu__DOT__cditop__DOT__vmpeg_inst__DOT__mpeg_data, 1, 1, f_fma_mp2);
            }
#ifdef TRACE
            if (!do_trace)
                fprintf(stderr, "Trace on!\n");
            do_trace = true;
#endif
        }

        if (pixel_index < size - 6) {
            uint8_t r, g, b;

            r = g = b = 30;

            if (dut.VGA_DE) {
                r = dut.VGA_R;
                g = dut.VGA_G;
                b = dut.VGA_B;
            }

            if (dut.VGA_HS) {
                r += 100;
            }

            if (dut.VGA_VS) {
                g += 100;
            }

            output_image[pixel_index++] = r;
            output_image[pixel_index++] = g;
            output_image[pixel_index++] = b;
        }
    }

    virtual ~CDi() {
        assert(f_audio_right);
        assert(f_audio_left);
        assert(f_fma);
        assert(f_fma_mp2);
        assert(f_fmv);
        assert(f_fmv_m1v);
        assert(f_uart);

        fclose(f_audio_right);
        fclose(f_audio_left);
        fclose(f_fma);
        fclose(f_fma_mp2);
        fclose(f_fmv);
        fclose(f_fmv_m1v);
        fclose(f_uart);

        f_audio_right = nullptr;
        f_audio_left = nullptr;
        f_fma = nullptr;
        f_fma_mp2 = nullptr;
        f_fmv = nullptr;
        f_fmv_m1v = nullptr;
        f_uart = nullptr;
    }

    /// @brief Opens/Reopen the FMV trace for writing FMV MPEG data
    /// Allows storing multiple MPEG streams per simulation
    void open_fmv_trace() {
        // Only restart trace when a considerable amount of data was stored in the last
        if (fmv_collected_data_cnt < 100 && f_fmv) {
            printf("Continue with current FMV trace...\n");
            return;
        }

        char filename[100];

        if (f_fmv)
            fclose(f_fmv);
        if (f_fmv_m1v)
            fclose(f_fmv_m1v);

        sprintf(filename, "%d/fmv_%d.bin", instanceid, fmv_index);
        fprintf(stderr, "Writing to %s\n", filename);
        printf("Writing to %s\n", filename);
        f_fmv = fopen(filename, "wb");
        assert(f_fmv);

        sprintf(filename, "%d/fmv_m1v_%d.bin", instanceid, fmv_index);
        fprintf(stderr, "Writing to %s\n", filename);
        printf("Writing to %s\n", filename);
        f_fmv_m1v = fopen(filename, "wb");
        assert(f_fmv_m1v);

        fmv_index++;
    }

    CDi(int i) {
        instanceid = i;

        char filename[100];
        sprintf(filename, "%d/audio_left.bin", instanceid);
        fprintf(stderr, "Writing to %s\n", filename);
        f_audio_left = fopen(filename, "wb");
        assert(f_audio_left);

        sprintf(filename, "%d/audio_right.bin", instanceid);
        fprintf(stderr, "Writing to %s\n", filename);
        f_audio_right = fopen(filename, "wb");
        assert(f_audio_right);

        sprintf(filename, "%d/fma.bin", instanceid);
        fprintf(stderr, "Writing to %s\n", filename);
        f_fma = fopen(filename, "wb");
        assert(f_fma);

        sprintf(filename, "%d/fma_mp2.bin", instanceid);
        fprintf(stderr, "Writing to %s\n", filename);
        f_fma_mp2 = fopen(filename, "wb");
        assert(f_fma_mp2);

        open_fmv_trace();

        sprintf(filename, "%d/uartlog", instanceid);
        fprintf(stderr, "Writing to %s\n", filename);
        f_uart = fopen(filename, "wb");
        assert(f_uart);

#ifdef TRACE
        dut.trace(&m_trace, 5);

        if (do_trace) {
            sprintf(filename, "/tmp/waveform.vcd", instanceid);
            fprintf(stderr, "Writing to %s\n", filename);
            m_trace.open(filename);
        }
#endif

        dut.eval();
        dut.rootp->emu__DOT__debug_uart_fake_space = false;
        dut.rootp->emu__DOT__img_size = 4096;
        dut.rootp->emu__DOT__rc_eye = 1; // RC Eye signal is idle high

        dut.rootp->emu__DOT__tvmode_ntsc = false;

        dut.RESET = 1;
        dut.UART_RXD = 1;

        // wait for SDRAM to initialize
        for (int y = 0; y < 300; y++) {
            clock30();
        }

        memset(&dut.rootp->emu__DOT__ddram[0], 0x00, 5000000);
        memset(&dut.rootp->emu__DOT__ram[0], 0x00, 2097152 * 2);

#if 0
        FILE *f = fopen("ddramdump.bin", "rb");
        assert(f);
        fread(&dut.rootp->emu__DOT__ddram[0], 1, 5000000, f);
        fclose(f);
#endif

        dut.RESET = 0;
        dut.OSD_STATUS = 1;

        start = std::chrono::system_clock::now();
#ifdef TRACE
        do_trace = false;
        fprintf(stderr, "Trace off!\n");
#endif

#ifdef SIMULATE_RC5
        rc5_file = fopen("rc5_joy_upwards.csv", "r");
#endif
    }

    void reset() {
        dut.RESET = 1;
        clock30();
        dut.RESET = 0;
    }
    /// @brief 1MB of Video RAM dumped
    /// Located in SDRAM at 0x000000
    void dump_base_case_memory() {
        char filename[100];
        sprintf(filename, "%d/video_ramdump.bin", instanceid);
        printf("Writing %s!\n", filename);
        FILE *f = fopen(filename, "wb");
        assert(f);
        fwrite(&dut.rootp->emu__DOT__ram[0], 1, 1024 * 256 * 4, f);
        fclose(f);
    }

    /// @brief 1MB of DVC RAM dumped
    /// Located in SDRAM at 0x100000
    void dump_dvc_sys_memory() {
        char filename[100];
        sprintf(filename, "%d/dvc_ramdump.bin", instanceid);
        printf("Writing %s!\n", filename);
        FILE *f = fopen(filename, "wb");
        assert(f);
        fwrite(&dut.rootp->emu__DOT__ram[0x100000 / 2], 1, 1024 * 256 * 4, f);
        fclose(f);
    }

    void dump_slave_memory() {
#ifdef SLAVE
        char filename[100];
        sprintf(filename, "%d/ramdump_slave.bin", instanceid);
        printf("Writing %s!\n", filename);
        FILE *f = fopen(filename, "wb");
        assert(f);
        fwrite(&dut.rootp->emu__DOT__cditop__DOT__uc68hc05_0__DOT__memory[0], 1, 8192, f);
        fclose(f);
#endif
    }

    void dump_cdic_memory() {
        char filename[100];
        sprintf(filename, "%d/ramdump_cdic.bin", instanceid);
        printf("Writing %s!\n", filename);
        FILE *f = fopen(filename, "wb");
        assert(f);
        fwrite(&dut.rootp->emu__DOT__cditop__DOT__cdic_inst__DOT__mem__DOT__ram[0], 2, 8192, f);
        fclose(f);
    }
};

int main(int argc, char **argv) {
    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

#ifdef TRACE
    if (do_trace)
        Verilated::traceEverOn(true);
#endif

    struct sigaction sa;
    sa.sa_sigaction = signal_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_SIGINFO;

    sigaction(SIGINT, &sa, NULL);
    sigaction(SIGUSR1, &sa, NULL);
    sigaction(SIGUSR2, &sa, NULL);

    int machineindex = 0;

    if (argc >= 2) {
        machineindex = atoi(argv[1]);
        fprintf(stderr, "Machine is %d\n", machineindex);
    }

    switch (machineindex) {
    case 0:
        f_cd_bin = fopen("images/karaoke.bin", "rb");
        f_sub_bin = fopen("images/karaoke.sub", "rb");
        break;
    case 1:
        f_cd_bin = fopen("images/braindead13.bin", "rb");
        break;
    case 2:
        f_cd_bin = fopen("images/LuckyLuke.bin", "rb");
        prepare_lucky_luke_europe_toc();
        break;
    case 3:
        f_cd_bin = fopen("images/Zelda Wand of Gamelon.bin", "rb");
        break;
    case 4:
        f_cd_bin = fopen("images/christ_country.bin", "rb");
        break;
    case 5:
        f_cd_bin = fopen("images/startrek.bin", "rb");
        break;
    case 6:
        f_cd_bin = fopen("images/FMVTEST.BIN", "rb");
        break;
    case 7:
        f_cd_bin = fopen("images/7thguest_german.bin", "rb");
        break;
    case 8:
        f_cd_bin = fopen("images/Dragon_s_Lair_US.bin", "rb");
        break;
    case 9:
        f_cd_bin = fopen("images/space_ace_eu.bin", "rb");
        break;
    }

    assert(f_cd_bin);

    CDi machine(machineindex);

    machine.dut.rootp->emu__DOT__config_auto_play = argc >= 3 ? 1 : 0;
    if (machine.dut.rootp->emu__DOT__config_auto_play) {
        fprintf(stderr, "Autoplay enabled!\n");
    }

    while (status == 0 && !Verilated::gotFinish()) {
        machine.modelstep();
    }

    machine.modelstep();
    machine.modelstep();
    machine.modelstep();
    machine.dump_base_case_memory();
    machine.dump_dvc_sys_memory();
    machine.dump_slave_memory();

    fclose(f_cd_bin);

    fprintf(stderr, "Closing...\n");
    fflush(stdout);

    return 0;
}
