// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include <stddef.h>
#include <stdint.h>

#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "hwreg.h"
#include "memtest.h"
#include "shared.h"

extern caddr_t _end; /* _end is set in the linker command file */
extern caddr_t _sp;  /* _end is set in the linker command file */
/* just in case, most boards have at least some memory */
#ifndef RAMSIZE
#define RAMSIZE (caddr_t)(1024 * 1024 * 4)
#endif

void print_chr(char ch);
void print_str(const char *p);
void stop_verilator();

// #define SOFT_CONVOLVE

#define PL_MPEG_IMPLEMENTATION
#define PLM_NO_STDIO
#include "pl_mpeg.h"

void stop_verilator() { *((volatile uint8_t *)OUTPORT_END) = 4; }

void main(void) {
    // It might be possible that the shared memory contains residual data
    // from previous runs. Invalidate the commands to start new
    clear_shared_memory();

    for (;;) {
        INVALIDATE_CACHE = 1;

        struct image_synthesis_descriptor *desc =
            get_next_ready_synthesis_desc();

        if (desc->ready == 1) {
            uint8_t *d = (uint8_t *)(((uint32_t)desc->cwp.d) + 0x50000000);
            DEBUG_STATE = 33;

            write_pixels(desc->cwp.macroblock_intra, desc->cwp.n,
                         desc->cwp.block_data, desc->cwp.di, d, desc->cwp.dw,
                         desc->cwp.si);
        } else if (desc->ready == 2) {
            uint8_t *s = (uint8_t *)(((uint32_t)desc->cpm.s) + 0x50000000);
            uint8_t *d = (uint8_t *)(((uint32_t)desc->cpm.d) + 0x50000000);
            DEBUG_STATE = 34;

            macroblock_worker(s, d, desc->cpm.odd_h, desc->cpm.odd_v,
                              desc->cpm.interpolate, desc->cpm.dw, desc->cpm.di,
                              desc->cpm.si, desc->cpm.block_size);
        } else if (desc->ready == 3) {
            // Do nothing. Just for syncing CPUs
        }

        __asm volatile("" : : : "memory");
        desc->ready = 0; // give the buffer back
        __asm volatile("" : : : "memory");
    }
}

/*
 * sbrk -- changes heap size size. Get nbytes more
 *         RAM. We just increment a pointer in what's
 *         left of memory on the board.
 */
caddr_t _sbrk(int nbytes) {
    static caddr_t heap_ptr = NULL;
    caddr_t base;

    if (heap_ptr == NULL) {
        heap_ptr = (caddr_t)&_sp;
    }

    if ((RAMSIZE - heap_ptr) >= 0) {
        base = heap_ptr;
        heap_ptr += nbytes;
        return (base);
    } else {
        errno = ENOMEM;
        return ((caddr_t)-1);
    }
}
