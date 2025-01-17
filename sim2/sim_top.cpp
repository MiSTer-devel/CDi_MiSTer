// Include common routines
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

#include "hle.h"
#include <arpa/inet.h>
#include <byteswap.h>

#define SCC68070
#define SLAVE

#define BCD(v) ((uint8_t)((((v) / 10) << 4) | ((v) % 10)))

struct subcode {
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
};
static_assert(sizeof(struct subcode) == 24);

struct toc_entry {
    uint8_t control;
    uint8_t track;
    uint8_t m;
    uint8_t s;
    uint8_t f;
};

static struct toc_entry toc_buffer[100];
int toc_entry_count = 0;

typedef VerilatedFstC tracetype_t;

static bool do_trace{false};
volatile sig_atomic_t status = 0;

const int width = 120 * 16;
const int height = 312;
const int size = width * height * 3;

FILE *f_cd_bin{nullptr};

template <typename T, typename U> constexpr T BIT(T x, U n) noexcept {
    return (x >> n) & T(1);
}

static void catch_function(int signo) {
    status = signo;
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

// CRC routine from https://github.com/mamedev/mame/blob/master/src/mame/philips/cdicdic.cpp
const uint16_t s_crc_ccitt_table[256] = {
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7, 0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad,
    0xe1ce, 0xf1ef, 0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6, 0x9339, 0x8318, 0xb37b, 0xa35a,
    0xd3bd, 0xc39c, 0xf3ff, 0xe3de, 0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4, 0x5485, 0xa56a, 0xb54b,
    0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d, 0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4,
    0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc, 0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861,
    0x2802, 0x3823, 0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b, 0x5af5, 0x4ad4, 0x7ab7, 0x6a96,
    0x1a71, 0x0a50, 0x3a33, 0x2a12, 0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a, 0x6ca6, 0x7c87,
    0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41, 0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49,
    0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70, 0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a,
    0x9f59, 0x8f78, 0x9188, 0x81a9, 0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f, 0x1080, 0x00a1, 0x30c2, 0x20e3,
    0x5004, 0x4025, 0x7046, 0x6067, 0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e, 0x02b1, 0x1290,
    0x22f3, 0x32d2, 0x4235, 0x5214, 0x6277, 0x7256, 0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d,
    0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405, 0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e,
    0xc71d, 0xd73c, 0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634, 0xd94c, 0xc96d, 0xf90e, 0xe92f,
    0x99c8, 0x89e9, 0xb98a, 0xa9ab, 0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3, 0xcb7d, 0xdb5c,
    0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a, 0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92,
    0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9, 0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83,
    0x1ce0, 0x0cc1, 0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8, 0x6e17, 0x7e36, 0x4e55, 0x5e74,
    0x2e93, 0x3eb2, 0x0ed1, 0x1ef0};

#define CRC_CCITT_ROUND(accum, data) (((accum << 8) | data) ^ s_crc_ccitt_table[accum >> 8])

void subcode_data(int lba, struct subcode &out) {
    int fake_lba = lba;
    if (fake_lba < 150)
        fake_lba += 150;
    uint8_t m, s, f;
    m = fake_lba / (60 * 75);
    fake_lba -= m * (60 * 75);
    s = fake_lba / 75;
    f = fake_lba % 75;

    if (lba < toc_entry_count) {
        auto &toc_entry = toc_buffer[lba];

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

        // printf("toc  lba=%d   %02x %02x %02x %02x %02x\n", lba, out.control, out.index, out.mode1_amins,
        // out.mode1_asecs, out.mode1_afrac);
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
    Vemu dut;
    uint64_t step = 0;
    uint64_t sim_time = 0;
    int frame_index = 0;

  private:
    FILE *f_audio_left{nullptr};
    FILE *f_audio_right{nullptr};

    uint8_t output_image[size] = {0};
    uint32_t regfile[16];

    tracetype_t m_trace;

    uint32_t print_instructions = 0;
    uint32_t prevpc = 0;
    uint32_t leave_sys_callpc = 0;

    int pixel_index = 0;

    uint16_t hps_buffer[4096];
    uint16_t hps_buffer_index = 0;
    bool hps_nvram_backup_active{false};
    bool ignore_first_hps_din{false};

    int instanceid;

    std::chrono::_V2::system_clock::time_point start;
    int sd_rd_q;
    static constexpr uint32_t kSectorHeaderSize{12};
    static constexpr uint32_t kSectorSize{2352};
    static constexpr uint32_t kWordsPerSubcodeFrame{12};
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

    void clock() {

        for (int i = 0; i < 2; i++) {
            dut.rootp->emu__DOT__clk_sys = (sim_time & 1);
            dut.rootp->emu__DOT__clk_audio = (sim_time & 1);
            dut.eval();
            if (do_trace) {
                m_trace.dump(sim_time);
            }
            sim_time++;
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
            clock();
        }

        while (fread(&transferword, 2, 1, f) == 1) {
            dut.rootp->emu__DOT__ioctl_wr = 1;
            dut.rootp->emu__DOT__ioctl_dout = transferword;

            clock();
            dut.rootp->emu__DOT__ioctl_wr = 0;

            // make some clocks to avoid asking for busy
            // the real MiSTer has 31 clocks between writes
            // we are going for ~20 to put more stress on it.
            for (int i = 0; i < 20; i++) {
                clock();
            }
            dut.rootp->emu__DOT__ioctl_addr += 2;
            clock();
        }
        fclose(f);
    }

    void printstate() {
#ifdef SCC68070
        uint32_t pc = dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__exe_pc;
        // d0 = dut.rootp->fx68k_tb__DOT__d0;
        memcpy(regfile, &dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__regfile[0],
               sizeof(regfile));

        printf("%x", pc);
        for (int i = 0; i < 16; i++)
            printf(" %x", regfile[i]);
        printf("\n");
#endif
    }

    void modelstep() {
        step++;
        clock();

        if ((step % 100000) == 0) {
            printf("%d\n", step);
        }

#ifdef SCC68070
        // Abort on illegal Instructions
        if (dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__trap_illegal) {
            fprintf(stderr, "Illegal Instruction!\n");
            exit(1);
        }
#endif

        dut.rootp->emu__DOT__nvram_media_change = (step == 2000);
        // Simulate CD data delivery from HPS
        if (dut.rootp->emu__DOT__cd_hps_req && sd_rd_q == 0 && dut.rootp->emu__DOT__nvram_hps_ack == 0) {
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

            fread(hps_buffer, 1, kSectorSize, f_cd_bin);

            struct subcode &out = *reinterpret_cast<struct subcode *>(&hps_buffer[kSectorSize / 2]);
            subcode_data(dut.rootp->emu__DOT__cd_hps_lba, out);
            hps_buffer_index = 0;
        }

        if (dut.rootp->emu__DOT__nvram_hps_rd && sd_rd_q == 0 && dut.rootp->emu__DOT__cd_hps_ack == 0) {
            assert(dut.rootp->emu__DOT__nvram_hps_ack == 0);
            dut.rootp->emu__DOT__nvram_hps_ack = 1;

            printf("Request NvRAM restore!\n");

            FILE *f_nvram_bin = fopen("save_in.bin", "rb");
            assert(f_nvram_bin);
            fread(hps_buffer, 1, 8192, f_nvram_bin);
            hps_buffer_index = 0;
            dut.rootp->emu__DOT__sd_buff_addr = hps_buffer_index;
            fclose(f_nvram_bin);
        }

        if (dut.rootp->emu__DOT__nvram_hps_wr && sd_rd_q == 0 && dut.rootp->emu__DOT__cd_hps_ack == 0) {
            assert(dut.rootp->emu__DOT__nvram_hps_ack == 0);
            dut.rootp->emu__DOT__nvram_hps_ack = 1;

            printf("Request NvRAM backup!\n");
            hps_buffer_index = 0;
            hps_nvram_backup_active = true;
            dut.rootp->emu__DOT__sd_buff_addr = hps_buffer_index;
            ignore_first_hps_din = true;
        }

        dut.rootp->emu__DOT__sd_buff_wr = 0;
        if (dut.rootp->emu__DOT__cd_hps_ack && (step % 200) == 15) {
            if (hps_buffer_index == kWordsPerSector) {
                dut.rootp->emu__DOT__cd_hps_ack = 0;
                printf("Sector transferred!\n");
            } else {
                dut.rootp->emu__DOT__sd_buff_dout = hps_buffer[hps_buffer_index];
                dut.rootp->emu__DOT__sd_buff_wr = 1;
                hps_buffer_index++;
            }
        }

        if (dut.rootp->emu__DOT__nvram_hps_ack && (step % 20) == 15) {
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

        sd_rd_q =
            dut.rootp->emu__DOT__cd_hps_req || dut.rootp->emu__DOT__nvram_hps_rd || dut.rootp->emu__DOT__nvram_hps_wr;

        /*
        if (dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__uart_transmit_holding_valid) {
            fputc(dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__uart_transmit_holding_register, stderr);
            dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__uart_transmit_holding_valid = 0;
        }
        */

        // Trace System Calls
#ifdef SCC68070
        if (dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__decodeopc &&
            dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__clkena_in) {

            uint32_t m_pc = dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__exe_pc;

            if (m_pc == 0x62c) {
                assert((prevpc & 1) == 0);
                uint32_t callpos = ((prevpc & 0x3fffff) >> 1) + 1;
                uint32_t call = dut.rootp->emu__DOT__rom[callpos];
                printf("Syscall %x %x %s\n", prevpc, call, systemCallNameToString(static_cast<SystemCallType>(call)));
                leave_sys_callpc = prevpc + 4;

                // SysDbg ? Just give up!
                if (static_cast<SystemCallType>(call) == F_SysDbg) {
                    fprintf(stderr, "System halted and debugger calted!\n");
                    exit(1);
                }
            }

            if (m_pc == leave_sys_callpc) {
                printf("Return from Syscall %x %x\n",
                       dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__flags,
                       dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__flagssr);
                printstate();
            }

            prevpc = m_pc;
        }

        // Trace CPU state
        if (dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__tg68__DOT__tg68kdotcinst__DOT__decodeopc &&
            print_instructions && dut.rootp->emu__DOT__cditop__DOT__scc68070_0__DOT__clkena_in) {

            printstate();
        }
#endif

        // Simulate television
        if (dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__new_frame) {
            char filename[100];

            // Start game
            if (frame_index == 247) {
                printf("Press a button!\n");
                dut.rootp->emu__DOT__JOY0 = 0b100000;
            }
            if (frame_index == 250) {
                printf("Release a button!\n");
                dut.rootp->emu__DOT__JOY0 = 0b000000;
            }

            if (instanceid == 2) // Tetris
            {
                // Skip Philips Logo
                if (frame_index == 347) {
                    printf("Press a button!\n");
                    dut.rootp->emu__DOT__JOY0 = 0b100000;
                }
                if (frame_index == 350) {
                    printf("Release a button!\n");
                    dut.rootp->emu__DOT__JOY0 = 0b000000;
                }
                // Skip Intro
                if (frame_index == 505) {
                    printf("Press a button!\n");
                    dut.rootp->emu__DOT__JOY0 = 0b100000;
                }
                if (frame_index == 510) {
                    printf("Release a button!\n");
                    dut.rootp->emu__DOT__JOY0 = 0b000000;
                }

                // And just stay like this
            } else if (instanceid == 1 && frame_index > 300) { // Hotel Mario
                if (frame_index < 910) {
                    // Before ingame
                    if ((frame_index % 25) == 20) {
                        printf("Press a button!\n");
                        dut.rootp->emu__DOT__JOY0 = 0b100000;
                    }

                    if ((frame_index % 25) == 23) {
                        printf("Release a button!\n");
                        dut.rootp->emu__DOT__JOY0 = 0b000000;
                    }
                } else if (get_pixel_value(498, 130) == 0x10bc10 && get_pixel_value(1193, 233) == 0x101010) {
                    printf("Level Title Card");
                    // Level Title Card
                    if ((frame_index % 20) == 10) {
                        printf("Press a button!\n");
                        dut.rootp->emu__DOT__JOY0 = 0b100000;
                    }

                    if ((frame_index % 20) == 15) {
                        printf("Release a button!\n");
                        dut.rootp->emu__DOT__JOY0 = 0b000000;
                    }
                } else {
                    // Press down left during ingame to kill mario to cause audiomap restart
                    dut.rootp->emu__DOT__JOY0 = 0b000110;
                }
            } else if (frame_index > 290) {
                if ((frame_index % 25) == 20) {
                    printf("Press a button!\n");
                    dut.rootp->emu__DOT__JOY0 = 0b100000;
                }

                if ((frame_index % 25) == 23) {
                    printf("Release a button!\n");
                    dut.rootp->emu__DOT__JOY0 = 0b000000;
                }
            }

            if (pixel_index > 100) {
                auto current = std::chrono::system_clock::now();
                std::chrono::duration<double> elapsed_seconds = current - start;
                sprintf(filename, "%d/video_%03d.png", instanceid, frame_index);
                write_png_file(filename);
                printf("Written %s %d\n", filename, pixel_index);
                printf("We are at step=%ld\n", step);
                fprintf(stderr, "Written %s after %.2fs\n", filename, elapsed_seconds.count());
                frame_index++;
            }
            pixel_index = 0;
        }

        // Simulate Audio
        if (dut.rootp->emu__DOT__cditop__DOT__cdic_inst__DOT__sample_tick44) {
            int16_t sample_l = dut.rootp->emu__DOT__cditop__DOT__cdic_inst__DOT__adpcm__DOT__fifo_out_left;
            int16_t sample_r = dut.rootp->emu__DOT__cditop__DOT__cdic_inst__DOT__adpcm__DOT__fifo_out_right;
            fwrite(&sample_l, 2, 1, f_audio_left);
            fwrite(&sample_r, 2, 1, f_audio_right);
        }

        if (pixel_index < size - 6) {
            if (dut.VGA_DE) {
                output_image[pixel_index++] = dut.VGA_R;
                output_image[pixel_index++] = dut.VGA_G;
                output_image[pixel_index++] = dut.VGA_B;
            } else {
                output_image[pixel_index++] = do_trace ? 80 : 10;
                output_image[pixel_index++] = 10;
                output_image[pixel_index++] = 10;
            }
        }
    }

    virtual ~CDi() {
        fclose(f_audio_right);
        fclose(f_audio_left);
    }
    CDi(int i) {
        instanceid = i;

        char filename[100];
        sprintf(filename, "%d/audio_left.bin", instanceid);
        fprintf(stderr, "Writing to %s\n", filename);
        f_audio_left = fopen(filename, "wb");

        sprintf(filename, "%d/audio_right.bin", instanceid);
        fprintf(stderr, "Writing to %s\n", filename);
        f_audio_right = fopen(filename, "wb");

        dut.trace(&m_trace, 5);

        if (do_trace) {
            sprintf(filename, "/tmp/waveform%d.vcd", instanceid);
            fprintf(stderr, "Writing to %s\n", filename);
            m_trace.open(filename);
        }

        dut.eval();
        // do_trace = false;
        dut.rootp->emu__DOT__debug_uart_fake_space = false;
        dut.rootp->emu__DOT__img_size = 4096;

        // dut.rootp->emu__DOT__tvmode_ntsc = true;

        dut.RESET = 1;
        dut.UART_RXD = 1;

        // wait for SDRAM to initialize
        for (int y = 0; y < 300; y++) {
            clock();
        }

        dut.RESET = 0;
        dut.OSD_STATUS = 1;

        start = std::chrono::system_clock::now();
    }

    void reset() {
        dut.RESET = 1;
        clock();
        dut.RESET = 0;
    }

    void dump_system_memory() {
        char filename[100];
        sprintf(filename, "%d/ramdump.bin", instanceid);
        printf("Writing %s!\n", filename);
        FILE *f = fopen(filename, "wb");
        assert(f);
        fwrite(&dut.rootp->emu__DOT__ram[0], 1, 1024 * 256 * 4, f);
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

    if (do_trace)
        Verilated::traceEverOn(true);

    if (signal(SIGINT, catch_function) == SIG_ERR) {
        fputs("An error occurred while setting a signal handler.\n", stderr);
        return EXIT_FAILURE;
    }

    int machineindex = 0;

    if (argc == 2) {
        machineindex = atoi(argv[1]);
        fprintf(stderr, "Machine is %d\n", machineindex);
    }

    switch (machineindex) {
    case 0:
        f_cd_bin = fopen("images/Zelda Wand of Gamelon.bin", "rb");
        break;
    case 1:
        f_cd_bin = fopen("images/Hotel Mario.bin", "rb");
        break;
    case 2:
        f_cd_bin = fopen("images/tetris.bin", "rb");
        break;
    case 3:
        f_cd_bin = fopen("images/Nobelia (USA).bin", "rb");
        break;
    case 4:
        f_cd_bin = fopen("images/Hotel Mario.bin", "rb");
        break;
    case 5:
        f_cd_bin = fopen("images/Zelda's Adventure (Europe).bin", "rb");
        break;
    case 6:
        f_cd_bin = fopen("images/tetris.bin", "rb");
        break;
    case 7:
        f_cd_bin = fopen("images/Flashback (Europe).bin", "rb");
        break;
    }

    assert(f_cd_bin);

    toc_buffer[0] = {1, 1, 0, 0, 0};
    toc_buffer[1] = {1, 1, 0, 0, 0};
    toc_buffer[2] = {1, 1, 0, 0, 0};
    toc_buffer[3] = {1, 2, 3, 38, 69};
    toc_buffer[4] = {1, 2, 3, 38, 69};
    toc_buffer[5] = {1, 2, 3, 38, 69};
    toc_buffer[6] = {1, 3, 7, 1, 96};
    toc_buffer[7] = {1, 3, 7, 1, 96};
    toc_buffer[8] = {1, 3, 7, 1, 96};
    toc_buffer[9] = {1, 4, 18, 16, 71};
    toc_buffer[10] = {1, 4, 18, 16, 71};
    toc_buffer[11] = {1, 4, 18, 16, 71};
    toc_buffer[12] = {1, 160, 1, 0, 0};
    toc_buffer[13] = {1, 160, 1, 0, 0};
    toc_buffer[14] = {1, 160, 1, 0, 0};
    toc_buffer[15] = {1, 161, 4, 0, 0};
    toc_buffer[16] = {1, 161, 4, 0, 0};
    toc_buffer[17] = {1, 161, 4, 0, 0};
    toc_buffer[18] = {1, 162, 0, 0, 0};
    toc_entry_count=19;

    CDi machine(machineindex);

    while (status == 0) {
        machine.modelstep();
    }

    machine.modelstep();
    machine.modelstep();
    machine.modelstep();
    machine.dump_system_memory();
    machine.dump_slave_memory();

    fclose(f_cd_bin);

    fprintf(stderr, "Closing...\n");
    fflush(stdout);

    return 0;
}
