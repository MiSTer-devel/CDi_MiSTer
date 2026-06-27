// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include <stdbool.h>
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
void advertise_at_least_one_frame();

// #define SOFT_CONVOLVE
int seq_hdr_latched;

#define PL_MPEG_IMPLEMENTATION
#define PLM_NO_STDIO
#include "pl_mpeg.h"

// Settings from sequence header
// To be able to continue playback, those must be kept between resets
__attribute__((section(".noinit"))) struct seq_hdr_conf seq_hdr_conf;

void stop_verilator() { *((volatile uint8_t *)OUTPORT_END) = 1; }

void sync_to_worker() {
    struct image_synthesis_descriptor *desc = get_next_free_synthesis_desc();
    commit_synthesis_desc(desc, 3);
    while (desc->ready == 3)
        __asm volatile("" : : : "memory");
}

void dct_coeff_read(plm_dma_buffer_t *buffer) {
#if 0
	fifo_ctrl->hw_huffman_read_dct_coeff = 1;
	__asm volatile("" : : : "memory");
	OUTPORT = fifo_ctrl->hw_huffman_read_dct_coeff;
	OUTPORT = fifo_ctrl->read_bit_index;
#else
    OUTPORT = plm_dma_buffer_read_vlc_uint(buffer, PLM_VIDEO_DCT_COEFF);
    OUTPORT = fifo_ctrl->read_bit_index;
#endif
}

static int32_t dts_desync_last = 0;

static void push_frame(plm_frame_t *frame) {
    static int first_intra_frame_of_gop_occured = false;
    static int intra_frame_occured_during_stream = false;

    if (frame->picture_type == PLM_VIDEO_PICTURE_TYPE_INTRA)
        intra_frame_occured_during_stream = true;

    // To avoid scrambled graphics, the first frame to provide
    // for display, shall be an I frame
    if (!intra_frame_occured_during_stream)
        return;

    __asm volatile("" : : : "memory");

    while (frame_display_fifo->pictures_in_output_fifo > 25)
        __asm volatile("" : : : "memory");

    *((volatile plm_frame_t **)OUTPORT_FRAME) = frame;
    frame_display_fifo->y_adr = (uint32_t)frame->y.data;
    frame_display_fifo->u_adr = (uint32_t)frame->cb.data;
    frame_display_fifo->v_adr = (uint32_t)frame->cr.data;

    // The VMPEG driver needs to know when the first I frame occurred during a
    // GOP We use the temporal ref for this, which starts at 0 with every GOP
    if (frame->temporal_ref == 0)
        first_intra_frame_of_gop_occured = false;

    if (!first_intra_frame_of_gop_occured &&
        frame->picture_type == PLM_VIDEO_PICTURE_TYPE_INTRA) {
        first_intra_frame_of_gop_occured = true;
        frame_display_fifo->first_intra_frame_of_gop = 1;

        frame_display_fifo->first_intra_frame_of_seq = seq_hdr_latched;
        seq_hdr_latched = false;
    } else {
        frame_display_fifo->first_intra_frame_of_gop = 0;
        frame_display_fifo->first_intra_frame_of_seq = 0;
    }

    frame_display_fifo->width = frame->width;
    frame_display_fifo->height = frame->height;

    int32_t dts_desync_avg =
        (dts_desync_last + frame_display_fifo->dts_desync) / 2;
    dts_desync_last = frame_display_fifo->dts_desync;

    int period30mhz = PLM_VIDEO_PICTURE_RATE_30MHZ[seq_hdr_conf.frameperiod] *
                          (frame_display_fifo->slow_motion + 1) -
                      dts_desync_avg * 1000; // steps of 33 us
    int period90khz = PLM_VIDEO_PICTURE_RATE_90KHZ[seq_hdr_conf.frameperiod];

    if (period30mhz < 400000) // much faster than 60 Hz? Better not
        period30mhz = 400000;

    frame_display_fifo->frameperiod_90khz = period90khz;
    frame_display_fifo->frameperiod_rawhdr = seq_hdr_conf.frameperiod;
    frame_display_fifo->temporal_ref = frame->temporal_ref;
    frame_display_fifo->timecode = frame->timecode;

    frame_display_fifo->frameperiod_30mhz = period30mhz;

    frame_display_fifo->video_status =
        (frame->temporal_ref << 2) | frame->picture_type;

    // The order is crucial. Everything written above must be in I/O by now
    __asm volatile("" : : : "memory");
    frame_display_fifo->commit_frame = 1;
    __asm volatile("" : : : "memory");
}

void main(void) {
    DEBUG_STATE = 1;

    plm_dma_buffer_t *buffer =
        plm_buffer_create_with_memory((uint8_t *)0x20000000, 700 * 1024 * 1024);
    if (!buffer)
        *((volatile uint8_t *)OUTPORT_END) = 2;

    DEBUG_STATE = 29;

    while (!plm_dma_buffer_has(buffer, 1000))
        ;

    DEBUG_STATE = 30;

    plm_video_t *mpeg = plm_video_create_with_buffer(buffer, 0);
    if (!mpeg)
        *((volatile uint8_t *)OUTPORT_END) = 3;

    int underflow_occured = 0;

    for (;;) {
        plm_frame_t *frame = plm_video_decode(mpeg);

        if (frame) {
            if (!frame->ready_for_display)
                *((volatile uint8_t *)OUTPORT_END) = 11;

            DEBUG_STATE = 27;

            worker_cnt = 0;
            sync_to_worker();
            worker_cnt = 1;
            sync_to_worker();
            worker_cnt = 2;
            sync_to_worker();

            DEBUG_STATE = 28;

            push_frame(frame);
            frame->ready_for_display = false;
            underflow_occured = 0;
        } else {
            // Only indicate underflow when there is no frame left
            if (!underflow_occured) {
                frame_display_fifo->event_buffer_underflow = 1;
                underflow_occured = 1;
            }
        }
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
