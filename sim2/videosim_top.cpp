#include <verilated.h>
#include <verilated_fst_c.h>

#include "Vemu.h"
#include "Vemu___024root.h"

#include <algorithm>
#include <byteswap.h>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <glob.h>
#include <map>
#include <png.h>
#include <regex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <sys/wait.h>
#include <vector>

#ifdef TRACE
using TraceType = VerilatedFstC;
static bool do_trace = true;
#endif

#ifndef CROP
#define CROP 1
#endif

constexpr int kMaxWidth = 120 * 16;
constexpr int kMaxHeight = 312;
constexpr int kImageSize = kMaxWidth * kMaxHeight * 3;
constexpr int kPngHeightScale = 4;

#if CROP
int width = 384 * 4; // Default PAL
int height = 280;
#else
constexpr int width = kMaxWidth;
constexpr int height = kMaxHeight;
#endif

class VideoSim {
  public:
    Vemu dut;

    VideoSim() {
#ifdef TRACE
        dut.trace(&trace, 5);
        if (do_trace) {
            constexpr const char *kTraceFile = "/tmp/waveform.fst";
            fprintf(stderr, "Writing to %s\n", kTraceFile);
            trace.open(kTraceFile);
        }
#endif
        dut.RESET = 1;

        for (int i = 0; i < 300; ++i)
            clock();

        dut.rootp->emu__DOT__cditop__DOT__debug_disable_cpu = true;
        dut.rootp->emu__DOT__img_size = 4096;
        dut.UART_RXD = 1;

        dut.RESET = 0;
        dut.OSD_STATUS = 1;
    }

    ~VideoSim() {
#ifdef TRACE
        if (do_trace)
            trace.close();
#endif
    }

    void step() {
        clock();

        if (dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_y == 0 &&
            dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_x == 4)
            pixel_index = 0;

        if (pixel_index >= kImageSize)
            return;

        uint8_t red = 30;
        uint8_t green = 30;
        uint8_t blue = 30;
        if (dut.VGA_DE) {
            red = dut.VGA_R;
            green = dut.VGA_G;
            blue = dut.VGA_B;
        }

#if CROP
        if (dut.VGA_DE) {
#endif
            output_image[pixel_index++] = red;
            output_image[pixel_index++] = green;
            output_image[pixel_index++] = blue;
#if CROP
        }
#endif
    }

    void write_png(const char *filename) const {
        FILE *file = fopen(filename, "wb");
        if (!file)
            throw std::runtime_error(std::string("Unable to create ") + filename);

        png_structp png = png_create_write_struct(PNG_LIBPNG_VER_STRING, nullptr, nullptr, nullptr);
        png_infop info = png ? png_create_info_struct(png) : nullptr;
        if (!png || !info || setjmp(png_jmpbuf(png))) {
            if (png)
                png_destroy_write_struct(&png, info ? &info : nullptr);
            fclose(file);
            throw std::runtime_error(std::string("Unable to write ") + filename);
        }

        png_init_io(png, file);
        png_set_IHDR(png, info, width, height * kPngHeightScale, 8, PNG_COLOR_TYPE_RGB, PNG_INTERLACE_NONE,
                     PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
        png_write_info(png, info);

        std::vector<png_bytep> rows(height * kPngHeightScale);
        for (int row = 0; row < height * kPngHeightScale; ++row)
            rows[row] = const_cast<png_bytep>(&output_image[width * 3 * (row / kPngHeightScale)]);

        png_write_image(png, rows.data());
        png_write_end(png, nullptr);
        png_destroy_write_struct(&png, &info);
        fclose(file);
    }

  private:
    uint64_t sim_time = 0;
    int pixel_index = 0;
    uint8_t output_image[kImageSize] = {};
#ifdef TRACE
    TraceType trace;
#endif

    void clock() {
        for (int i = 0; i < 2; ++i) {
            dut.rootp->emu__DOT__clk_sys = sim_time & 1;
            dut.rootp->emu__DOT__clk_audio = sim_time & 1;
            dut.eval();
#ifdef TRACE
            if (do_trace)
                trace.dump(sim_time);
#endif
            ++sim_time;
        }
    }
};

std::vector<std::string> find_files(const std::string &pattern) {
    glob_t result{};
    if (::glob(pattern.c_str(), GLOB_TILDE, nullptr, &result) != 0) {
        globfree(&result);
        throw std::runtime_error("No RAM dumps match " + pattern);
    }
    std::vector<std::string> files(result.gl_pathv, result.gl_pathv + result.gl_pathc);
    globfree(&result);
    return files;
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

void get_video_frame(const std::string &binpath, const std::string &pngpath, const std::string &hacks) {
    VideoSim machine;

    FILE *file = fopen(binpath.c_str(), "rb");
    if (!file)
        throw std::runtime_error("Unable to open " + binpath);
    fread(&machine.dut.rootp->emu__DOT__ram[0], 1, 1024 * 256 * 4, file);
    fclose(file);

    // Swap endianess if required
    if (machine.dut.rootp->emu__DOT__ram[1] == 0x0015) {
        for (int i = 0; i < 1024 * 256 * 2; ++i)
            machine.dut.rootp->emu__DOT__ram[i] = bswap_16(machine.dut.rootp->emu__DOT__ram[i]);
    }

    constexpr uint32_t kIc1 = 1 << 9;
    constexpr uint32_t kDc1 = 1 << 8;
    constexpr uint32_t kCf = 1 << 14; // 30 MHz
    machine.step();
    machine.step();
    machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__command_register_dcr1 = kIc1 | kDc1 | kCf;
    machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__command_register_dcr2 = kIc1 | kDc1;

    if (has_hack(hacks, "st")) {
        machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__control_register_crsr1w = 1;
#if CROP
        width = 360 * 4;
        height = 240;
#endif
    }

    machine.step();
    machine.step();
    while (machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_y == 0)
        machine.step();
    while (machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_y != 0)
        machine.step();
    machine.step();

    if (has_hack(hacks, "2rounds")) {
        while (machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_y == 0)
            machine.step();
        while (machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_y != 0)
            machine.step();
    }

    // Add some clock cycles due to video latency. The bottom right might still have a non-written spot
    while (machine.dut.rootp->emu__DOT__cditop__DOT__mcd212_inst__DOT__video_x < 5)
        machine.step();

    machine.write_png(pngpath.c_str());
    fprintf(stderr, "Written %s\n", pngpath.c_str());

#if CROP
    width = 384 * 4;
    height = 280;
#endif
}

void forked_run() {
    constexpr size_t kNumberForks = 14;
    const char *ramdump_glob = std::getenv("CDI_RAMDUMP_GLOB");
    const char *ramdumps_dir = std::getenv("CDI_RAMDUMPS");
    const char *hacks_file = std::getenv("CDI_VIDEO_HACKS_FILE");
    const auto hacks_by_dump = load_hacks(hacks_file ? hacks_file : "videosim_hacks.txt");
    const std::string path =
        std::string(ramdumps_dir ? ramdumps_dir : "ramdumps/") + "/" + (ramdump_glob ? ramdump_glob : "*") + ".bin";
    const auto ramdumps = find_files(path);
    const size_t chunk_size = std::max(ramdumps.size() / kNumberForks, size_t{1});
    std::vector<pid_t> children;

    for (size_t first = 0; first < ramdumps.size(); first += chunk_size) {
        const pid_t pid = fork();
        if (pid < 0)
            throw std::runtime_error("fork failed");
        if (pid == 0) {
            for (size_t i = first; i < std::min(first + chunk_size, ramdumps.size()); ++i) {
                const auto hacks = hacks_by_dump.find(dump_name(ramdumps[i]));
                const auto pngpath = std::regex_replace(ramdumps[i], std::regex(".*/(.*).bin"), "videosim/$1.png");
                get_video_frame(ramdumps[i], pngpath, hacks == hacks_by_dump.end() ? "" : hacks->second);
            }
            std::exit(0);
        }
        children.push_back(pid);
    }

    for (const pid_t child : children) {
        if (waitpid(child, nullptr, 0) < 0)
            throw std::runtime_error("waitpid failed");
    }
}

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
#ifdef TRACE
    if (do_trace)
        Verilated::traceEverOn(true);
#endif
    forked_run();
    return 0;
}
