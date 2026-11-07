#include <cassert>
#include <cstdint>
#include <cstdio>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <sys/types.h>

class RiscVStackAnalyzer {
  private:
    uint32_t stack_size{0};
    uint32_t stack_bottom{0};
    uint32_t stack_top{0}; // first byte after stack!

    static constexpr uint8_t kWaterMark{0xAA};
    static constexpr uint8_t kMinimumFreeSpace{30};

  public:
    void ReadMapFile(const char *map_file) {
        std::ifstream map(map_file);
        std::string line, section;
        while (std::getline(map, line)) {
            std::istringstream fields(line);
            if (fields >> section >> std::hex >> stack_bottom >> stack_size && section == ".stack")
                break;
        }
        assert(stack_size);
        stack_top = stack_bottom + stack_size;
        printf("RISC-V Stack from %x to %x\n", stack_bottom, stack_top);
    }

    void InsertWatermarks(void *ram_void) {
        uint8_t *ram = reinterpret_cast<uint8_t *>(ram_void);
        for (int adr = stack_bottom; adr < stack_top; adr++)
            ram[adr] = kWaterMark;
    }

    int MeasureMaximumStackUsage(void *ram_void) {
        uint8_t *ram = reinterpret_cast<uint8_t *>(ram_void);
        for (int adr = stack_bottom; adr < stack_top; adr++) {
            if (ram[adr] != kWaterMark) {

                // This must be caught at all costs!
                // This project must never fail with something as stupid as a stack overflow
                // in the MPEG hardware >.<
                if (kMinimumFreeSpace > (adr - stack_bottom)) {
                    printf("WARNING: Stack might overflow %d\n", adr - stack_bottom);
                }

                return stack_top - adr;
            }
        }

        // No stack usage
        return 0;
    }
};
