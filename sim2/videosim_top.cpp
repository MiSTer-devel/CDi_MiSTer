// Include common routines
#include <verilated.h>
#include <verilated_fst_c.h>

// Include model header, generated from Verilating "top.v"
#include "Vemu.h"
#include "Vemu___024root.h"

#include "hle.h"
#include <arpa/inet.h>
#include <byteswap.h>
#include <chrono>
#include <csignal>
#include <cstdint>
#include <fstream>
#include <glob.h>
#include <iostream>
#include <map>
#include <png.h>
#include <regex>
#include <sstream>
#include <stdexcept>
#include <string.h> // memset()
#include <string>
#include <sys/wait.h>
#include <vector>

// #define SCC68070
// #define SLAVE
// #define TRACE

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

#ifdef TRACE
typedef VerilatedFstC tracetype_t;

static bool do_trace{true};
#endif
volatile sig_atomic_t status = 0;

#ifndef CROP
#define CROP 1
#endif

constexpr int kMaxWidth = 120 * 16;
constexpr int kMaxHeight = 312;

#if CROP
int width = 384 * 4; // default PAL
int height = 280;    // default PAL
#else
constexpr int width = 120 * 16;
constexpr int height = 312;
#endif

const int size = kMaxWidth * kMaxHeight * 3;
const int png_height_scale = 4;

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
    Vemu dut;
    uint64_t step = 0;
    uint64_t sim_time = 0;
    int frame_index = 0;

  private:
    uint8_t output_image[size] = {0};
    uint32_t regfile[16];
#ifdef TRACE
    tracetype_t m_trace;
#endif

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

  public:
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
#ifdef TRACE
            if (do_trace) {
                m_trace.dump(sim_time);
            }
#endif
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

        // Ignore CD data delivery from HPS
        if (dut.rootp->emu__DOT__cd_hps_req && sd_rd_q == 0 && dut.rootp->emu__DOT__nvram_hps_ack == 0) {
        }

        if (dut.rootp->emu__DOT__nvram_hps_rd && sd_rd_q == 0 && dut.rootp->emu__DOT__cd_hps_ack == 0) {
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
        if (dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_y == 0 &&
            dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_x == 0) {
            char filename[100];

            // Start game
            if (frame_index == 190) {
                printf("Press a button!\n");
                dut.rootp->emu__DOT__JOY0 = 0b100000;
            }
            if (frame_index == 194) {
                printf("Release a button!\n");
                dut.rootp->emu__DOT__JOY0 = 0b000000;
            }

            if (pixel_index > 100) {
                frame_index++;
            }
            pixel_index = 0;
        }

        if (pixel_index < size) {
            uint8_t r, g, b;

            r = g = b = 30;

            if (dut.VGA_DE) {
                r = dut.VGA_R;
                g = dut.VGA_G;
                b = dut.VGA_B;
#if CROP
                output_image[pixel_index++] = r;
                output_image[pixel_index++] = g;
                output_image[pixel_index++] = b;
#endif
            }

#if !CROP
            output_image[pixel_index++] = r;
            output_image[pixel_index++] = g;
            output_image[pixel_index++] = b;
#endif
        }
    }

    virtual ~CDi() {
    }
    CDi(int i) {
        instanceid = i;

#ifdef TRACE
        dut.trace(&m_trace, 5);

        if (do_trace) {
            char filename[100];
            sprintf(filename, "/tmp/waveform.vcd", instanceid);
            fprintf(stderr, "Writing to %s\n", filename);
            m_trace.open(filename);
        }
#endif

        dut.eval();
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

std::vector<std::string> glob(const std::string &pattern) {
    using namespace std;

    // glob struct resides on the stack
    glob_t glob_result;
    memset(&glob_result, 0, sizeof(glob_result));

    // do the glob operation
    int return_value = glob(pattern.c_str(), GLOB_TILDE, NULL, &glob_result);
    if (return_value != 0) {
        globfree(&glob_result);
        std::cerr << "glob() failed with return_value " << return_value << endl;
        exit(1);
    }

    // collect all the filenames into a std::list<std::string>
    vector<string> filenames;
    for (size_t i = 0; i < glob_result.gl_pathc; ++i) {
        filenames.push_back(string(glob_result.gl_pathv[i]));
    }

    // cleanup
    globfree(&glob_result);

    // done
    return filenames;
}

bool has_hack(const std::string &hacks, const std::string &hack) {
    size_t start = 0;
    while (start < hacks.size()) {
        const size_t end = hacks.find(',', start);
        if (hacks.substr(start, end - start) == hack)
            return true;
        if (end == std::string::npos)
            break;
        start = end + 1;
    }
    return false;
}

std::map<std::string, std::string> load_hacks(const char *filename) {
    std::map<std::string, std::string> hacks_by_dump;
    std::ifstream file(filename);

    if (!file)
        throw std::runtime_error(std::string("Unable to open video hack configuration ") + filename);

    std::string line;
    while (std::getline(file, line)) {
        std::istringstream entry(line);
        std::string dump_name;
        std::string hacks;

        if (!(entry >> dump_name) || dump_name[0] == '#')
            continue;
        if (!(entry >> hacks))
            throw std::runtime_error("Missing hacks for dump " + dump_name);

        hacks_by_dump[dump_name] = hacks;
    }

    return hacks_by_dump;
}

std::string dump_name(const std::string &binpath) {
    const size_t basename_start = binpath.find_last_of('/') + 1;
    const size_t extension_start = binpath.rfind(".bin");
    return binpath.substr(basename_start, extension_start - basename_start);
}

void get_video_frame(std::string binpath, std::string pngpath, const std::string &hacks) {
    CDi machine(0);

    FILE *f = fopen(binpath.c_str(), "rb");
    assert(f);
    fread(&machine.dut.rootp->emu__DOT__ram[0], 1, 1024 * 256 * 4, f);
    fclose(f);

    // To support multiple endianesses, we use the second word to detect it
    if (machine.dut.rootp->emu__DOT__ram[1] == 0x0015) {
        for (int i = 0; i < 1024 * 256 * 2; i++) {
            machine.dut.rootp->emu__DOT__ram[i] = bswap_16(machine.dut.rootp->emu__DOT__ram[i]);
        }
    }

    // Force ICA0 and ICA1
    static constexpr uint32_t ic1 = (1 << 9);
    static constexpr uint32_t dc1 = (1 << 8);
    static constexpr uint32_t cf = (1 << 14); // 30 MHz
    static constexpr uint32_t fd = (1 << 13); // 60 Hz

    machine.modelstep(); // To let the reset signal sink in
    machine.modelstep(); // To let the reset signal sink in

    machine.dut.rootp->emu__DOT__debug_limited_to_full = 0; // Force RGB scaling 0-255
    // machine.dut.rootp->emu__DOT__debug_limited_to_full = 1; // Force RGB scaling 16-235

    machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__command_register_dcr1 = ic1 | dc1 | cf;
    machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__command_register_dcr2 = ic1 | dc1;

    if (has_hack(hacks, "st")) {
        machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__control_register_crsr1w = 1;
#if CROP
        width = 360 * 4;
        height = 240;
#endif
    }

    machine.modelstep(); // Step to get new frame out of the way

    // Drive until frame is generated
    machine.modelstep();
    while (machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_y == 0) {
        machine.modelstep();
    }
    while (machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_y != 0) {
        machine.modelstep();
    }
    machine.modelstep();

    if (has_hack(hacks, "2rounds")) {
        // And again!
        while (machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_y == 0) {
            machine.modelstep();
        }
        while (machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_y != 0) {
            machine.modelstep();
        }
    }

    machine.write_png_file(pngpath.c_str());
    // machine.write_png_file("1.png");
    fprintf(stderr, "Written %s\n", pngpath.c_str());

    // restore PAL default
#if CROP
    width = 384 * 4;
    height = 280;
#endif
}

void forked_run() {
    static constexpr size_t kNumberForks{14};
    std::vector<pid_t> child_pids;

    const char *env_ramdump_glob = std::getenv("CDI_RAMDUMP_GLOB");
    const char *env_ramdumps = std::getenv("CDI_RAMDUMPS");
    const char *env_video_hacks_file = std::getenv("CDI_VIDEO_HACKS_FILE");
    const auto hacks_by_dump = load_hacks(env_video_hacks_file ? env_video_hacks_file : "videosim_hacks.txt");

    std::string path = std::string(env_ramdumps ? env_ramdumps : "ramdumps/") + "/" +
                       (env_ramdump_glob ? env_ramdump_glob : "*") + ".bin";
    printf("Reading ram dumps from %s\n", path.c_str());
    auto ramdumps = glob(path);
    size_t chunksize = std::max((size_t)ramdumps.size() / kNumberForks, (size_t)1);
    printf("Splitting %d ram dumps into %d sizes of %d\n", ramdumps.size(), kNumberForks, chunksize);

    auto iterator = ramdumps.begin();

    int runner = 0;

    while (iterator < ramdumps.end()) {

        pid_t pid = fork();
        switch (pid) {
        case -1:
            perror("fork");
            exit(EXIT_FAILURE);
        case 0:
            printf("Runner %d is PID %jd\n", runner, (intmax_t)pid);

            while (chunksize && iterator != ramdumps.end()) {
                chunksize--;
                printf("Runner %d %s\n", runner, iterator->c_str());

                auto binpath = *iterator;
                auto pngpath = std::regex_replace(binpath, std::regex(".*/(.*).bin"), "videosim/$1.png");
                const auto hacks = hacks_by_dump.find(dump_name(binpath));

                get_video_frame(binpath, pngpath, hacks == hacks_by_dump.end() ? "" : hacks->second);

                iterator++;
            }
            exit(0);
        default:
            printf("Child is PID %jd\n", (intmax_t)pid);
            child_pids.push_back(pid);
        }

        iterator += chunksize;
        runner++;
    }

    printf("Waiting for the runners to finish...\n");

    for (auto child : child_pids) {
        pid_t result = waitpid(child, nullptr, 0);
        printf("PID %d has finished!\n", result);
    }
}

int main(int argc, char **argv) {

    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

#ifdef TRACE
    if (do_trace)
        Verilated::traceEverOn(true);
#endif

    forked_run();

    fprintf(stderr, "Closing...\n");
    fflush(stdout);

    return 0;
}
