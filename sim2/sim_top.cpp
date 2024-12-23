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
#include <byteswap.h>

#define SCC68070
#define SLAVE

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

            uint32_t file_offset = (lba - 150) * kSectorSize;

            printf("Request CD Sector %x %x %x\n", m_time, lba, file_offset);

            int res = fseek(f_cd_bin, file_offset, SEEK_SET);
            assert(res == 0);

            fread(hps_buffer, 1, kSectorSize, f_cd_bin);

            for (int i = 0; i < 12; i++)
                hps_buffer[kSectorSize / 2 + i] = 0x12 + i;
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
        if (dut.rootp->emu__DOT__cditop__DOT__cdic_inst__DOT__sample_tick37) {
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
    case 8:
        f_cd_bin = fopen("images/Myst (Europe).bin", "rb");
        break;
    }

    assert(f_cd_bin);

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
