#pragma once

#include <stdint.h>

struct io_fifo_control {
    uint32_t write_byte_index;          // @0x10002000 read only
    uint32_t read_bit_index;            // @0x10002004 read + write
    uint32_t hw_read_count;             // @0x10002008 read + write
    uint32_t hw_huffman_read_dct_coeff; // @0x1000200C read + write
    uint32_t has_sequence_header;       // @0x10002010 read only
};

struct frame_display_fifo {
    uint32_t y_adr;                    // @0x10003000
    uint32_t u_adr;                    // @0x10003004
    uint32_t v_adr;                    // @0x10003008
    uint32_t width;                    // @0x1000300C
    uint32_t height;                   // @0x10003010
    uint32_t frameperiod_30mhz;        // @0x10003014, ticks of 30 MHz
    int32_t dts_desync;                // @0x10003018 Read only
    uint32_t event_sequence_end;       // @0x1000301C Write only
    uint32_t first_intra_frame_of_gop; // @0x10003020 Write only
    uint32_t event_buffer_underflow;   // @0x10003024 Write only
    uint32_t pictures_in_output_fifo;  // @0x10003028 Read only
    uint32_t playback_active;          // @0x1000302c Read only
    uint32_t frameperiod_rawhdr;       // @0x10003030 Write only
    uint32_t frameperiod_90khz;        // @0x10003034 Write only
    uint32_t video_status;             // @0x10003038 Write only
    uint32_t slow_motion;              // @0x1000303c Read only
    uint32_t commit_frame;             // @0x10003040 Write only
    uint32_t timecode;                 // @0x10003044 Write only
    uint32_t first_intra_frame_of_seq; // @0x10003048 Write only
    uint32_t reserved2_;               // @0x1000304C
    uint32_t event_frame_decoded;      // @0x10003050 Write only
    uint32_t luma_width;               // @0x10003054 Write only
    uint32_t chroma_width;             // @0x10003058 Write only
};

struct io_fifo_control *const fifo_ctrl = (struct io_fifo_control *)0x10002000;
struct frame_display_fifo *const frame_display_fifo =
    (struct frame_display_fifo *)0x10003000;

#define OUTPORT *(volatile uint32_t *)0x10000000

#define OUTPORT_END 0x1000000c
#define OUTPORT_FRAME 0x10000010

#define DEBUG_STATE *(volatile uint32_t *)0x10000030

// Only for worker cores
#define INVALIDATE_CACHE *(volatile uint32_t *)0x10001110
