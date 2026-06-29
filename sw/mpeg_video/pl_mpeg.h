/*
PL_MPEG - MPEG1 Video decoder, MP2 Audio decoder, MPEG-PS demuxer
SPDX-License-Identifier: MIT

Dominic Szablewski - https://phoboslab.org


-- Synopsis

// Define `PL_MPEG_IMPLEMENTATION` in *one* C/C++ file before including this
// library to create the implementation.

#define PL_MPEG_IMPLEMENTATION
#include "plmpeg.h"

// This function gets called for each decoded video frame
void my_video_callback(plm_t *plm, plm_frame_t *frame, void *user) {
        // Do something with frame->y.data, frame->cr.data, frame->cb.data
}

// This function gets called for each decoded audio frame
void my_audio_callback(plm_t *plm, plm_samples_t *frame, void *user) {
        // Do something with samples->interleaved
}

// Load a .mpg (MPEG Program Stream) file
plm_t *plm = plm_create_with_filename("some-file.mpg");

// Install the video & audio decode callbacks
plm_set_video_decode_callback(plm, my_video_callback, my_data);
plm_set_audio_decode_callback(plm, my_audio_callback, my_data);


// Decode
do {
        plm_decode(plm, time_since_last_call);
} while (!plm_has_ended(plm));

// All done
plm_destroy(plm);



-- Documentation

This library provides several interfaces to load, demux and decode MPEG video
and audio data. A high-level API combines the demuxer, video & audio decoders
in an easy to use wrapper.

Lower-level APIs for accessing the demuxer, video decoder and audio decoder,
as well as providing different data sources are also available.

Interfaces are written in an object oriented style, meaning you create object
instances via various different constructor functions (plm_*create()),
do some work on them and later dispose them via plm_*destroy().

plm_* ......... the high-level interface, combining demuxer and decoders
plm_buffer_* .. the data source used by all interfaces
plm_demux_* ... the MPEG-PS demuxer
plm_video_* ... the MPEG1 Video ("mpeg1") decoder
plm_audio_* ... the MPEG1 Audio Layer II ("mp2") decoder


With the high-level interface you have two options to decode video & audio:

 1. Use plm_decode() and just hand over the delta time since the last call.
    It will decode everything needed and call your callbacks (specified through
    plm_set_{video|audio}_decode_callback()) any number of times.

 2. Use plm_decode_video() and plm_decode_audio() to decode exactly one
    frame of video or audio data at a time. How you handle the synchronization
    of both streams is up to you.

If you only want to decode video *or* audio through these functions, you should
disable the other stream (plm_set_{video|audio}_enabled(FALSE))

Video data is decoded into a struct with all 3 planes (Y, Cr, Cb) stored in
separate buffers. You can either convert this to RGB on the CPU (slow) via the
plm_frame_to_rgb() function or do it on the GPU with the following matrix:

mat4 bt601 = mat4(
        1.16438,  0.00000,  1.59603, -0.87079,
        1.16438, -0.39176, -0.81297,  0.52959,
        1.16438,  2.01723,  0.00000, -1.08139,
        0, 0, 0, 1
);
gl_FragColor = vec4(y, cb, cr, 1.0) * bt601;

Audio data is decoded into a struct with either one single float array with the
samples for the left and right channel interleaved, or if the
PLM_AUDIO_SEPARATE_CHANNELS is defined *before* including this library, into
two separate float arrays - one for each channel.


Data can be supplied to the high level interface, the demuxer and the decoders
in three different ways:

 1. Using plm_create_from_filename() or with a file handle with
    plm_create_from_file().

 2. Using plm_create_with_memory() and supplying a pointer to memory that
    contains the whole file.

 3. Using plm_create_with_buffer(), supplying your own plm_buffer_t instance and
    periodically writing to this buffer.

When using your own plm_buffer_t instance, you can fill this buffer using
plm_buffer_write(). You can either monitor plm_buffer_get_remaining() and push
data when appropriate, or install a callback on the buffer with
plm_buffer_set_load_callback() that gets called whenever the buffer needs more
data.

A buffer created with plm_buffer_create_with_capacity() is treated as a ring
buffer, meaning that data that has already been read, will be discarded. In
contrast, a buffer created with plm_buffer_create_for_appending() will keep all
data written to it in memory. This enables seeking in the already loaded data.


There should be no need to use the lower level plm_demux_*, plm_video_* and
plm_audio_* functions, if all you want to do is read/decode an MPEG-PS file.
However, if you get raw mpeg1video data or raw mp2 audio data from a different
source, these functions can be used to decode the raw data directly. Similarly,
if you only want to analyze an MPEG-PS file or extract raw video or audio
packets from it, you can use the plm_demux_* functions.


This library uses malloc(), realloc() and free() to manage memory. Typically
all allocation happens up-front when creating the interface. However, the
default buffer size may be too small for certain inputs. In these cases plmpeg
will realloc() the buffer with a larger size whenever needed. You can configure
the default buffer size by defining PLM_BUFFER_DEFAULT_SIZE *before*
including this library.

You can also define PLM_MALLOC, PLM_REALLOC and PLM_FREE to provide your own
memory management functions.


See below for detailed the API documentation.

*/

#ifndef PL_MPEG_H
#define PL_MPEG_H

#include "fast_block_zero.h"
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// -----------------------------------------------------------------------------
// Public Data Types

extern struct seq_hdr_conf {
    int frameperiod; // raw value from header
    int pixel_aspect_ratio;

    int width;
    int height;
    int mb_width;
    int mb_height;
    int mb_size;

    int luma_width;
    int luma_height;

    int chroma_width;
    int chroma_height;

    uint8_t intra_quant_matrix[64];
    uint8_t non_intra_quant_matrix[64];

    uint8_t *next_framebuffer;

} seq_hdr_conf;

// Object types for the various interfaces

typedef struct plm_t plm_t;
typedef struct plm_buffer_t plm_buffer_t;
typedef struct plm_dma_buffer_t plm_dma_buffer_t;
typedef struct plm_demux_t plm_demux_t;
typedef struct plm_video_t plm_video_t;
typedef struct plm_audio_t plm_audio_t;

int seq_hdr_latched;

// Demuxed MPEG PS packet
// The type maps directly to the various MPEG-PES start codes. PTS is the
// presentation time stamp of the packet in seconds. Note that not all packets
// have a PTS value, indicated by PLM_PACKET_INVALID_TS.

#define PLM_PACKET_INVALID_TS -1

typedef struct {
    int type;
    int64_t pts;
    size_t length;
    uint8_t *data;
} plm_packet_t;

// Decoded Video Plane
// The byte length of the data is width * height. Note that different planes
// have different sizes: the Luma plane (Y) is double the size of each of
// the two Chroma planes (Cr, Cb) - i.e. 4 times the byte length.
// Also note that the size of the plane does *not* denote the size of the
// displayed frame. The sizes of planes are always rounded up to the nearest
// macroblock (16px).

typedef struct {
    unsigned int width;
    unsigned int height;
    uint8_t *data;
} plm_plane_t;

// Decoded Video Frame
// width and height denote the desired display size of the frame. This may be
// different from the internal size of the 3 planes.

typedef struct {
    unsigned int width;
    unsigned int height;
    plm_plane_t y;
    plm_plane_t cr;
    plm_plane_t cb;
    int picture_type;
    int temporal_ref;
    int timecode;
    int ready_for_display;
} plm_frame_t;

// Callback function type for decoded video frames used by the high-level
// plm_* interface

typedef void (*plm_video_decode_callback)(plm_t *self, plm_frame_t *frame,
                                          void *user);

// Decoded Audio Samples
// Samples are stored as normalized (-1, 1) float either interleaved, or if
// PLM_AUDIO_SEPARATE_CHANNELS is defined, in two separate arrays.
// The `count` is always PLM_AUDIO_SAMPLES_PER_FRAME and just there for
// convenience.

#define PLM_AUDIO_SAMPLES_PER_FRAME 1152

typedef struct {
    int32_t time;
    unsigned int count;
} plm_samples_t;

// Callback function type for decoded audio samples used by the high-level
// plm_* interface

typedef void (*plm_audio_decode_callback)(plm_t *self, plm_samples_t *samples,
                                          void *user);

// Callback function for plm_buffer when it needs more data

typedef void (*plm_buffer_load_callback)(plm_buffer_t *self, void *user);

// Callback function for plm_buffer when it needs to seek

typedef void (*plm_buffer_seek_callback)(plm_buffer_t *self, size_t offset,
                                         void *user);

// Callback function for plm_buffer when it needs to tell the position

typedef size_t (*plm_buffer_tell_callback)(plm_buffer_t *self, void *user);

// -----------------------------------------------------------------------------
// plm_* public API
// High-Level API for loading/demuxing/decoding MPEG-PS data

#ifndef PLM_NO_STDIO

// Create a plmpeg instance with a filename. Returns NULL if the file could not
// be opened.

plm_t *plm_create_with_filename(const char *filename);

// Create a plmpeg instance with a file handle. Pass TRUE to close_when_done to
// let plmpeg call fclose() on the handle when plm_destroy() is called.

plm_t *plm_create_with_file(FILE *fh, int close_when_done);

#endif // PLM_NO_STDIO

// Create a plmpeg instance with a pointer to memory as source. This assumes the
// whole file is in memory. The memory is not copied. Pass TRUE to
// free_when_done to let plmpeg call free() on the pointer when plm_destroy()
// is called.

plm_t *plm_create_with_memory(uint8_t *bytes, size_t length);

// Create a plmpeg instance with a plm_buffer as source. Pass TRUE to
// destroy_when_done to let plmpeg call plm_buffer_destroy() on the buffer when
// plm_destroy() is called.

plm_t *plm_create_with_buffer(plm_dma_buffer_t *buffer, int destroy_when_done);

// Destroy a plmpeg instance and free all data.

void plm_destroy(plm_t *self);

// Get whether we have headers on all available streams and we can report the
// number of video/audio streams, video dimensions, frameperiod and audio
// samplerate.
// This returns FALSE if the file is not an MPEG-PS file or - when not using a
// file as source - when not enough data is available yet.

int plm_has_headers(plm_t *self);

// Probe the MPEG-PS data to find the actual number of video and audio streams
// within the buffer. For certain files (e.g. VideoCD) this can be more accurate
// than just reading the number of streams from the headers.
// This should only be used when the underlying plm_buffer is seekable, i.e. for
// files, fixed memory buffers or _for_appending buffers. If used with dynamic
// memory buffers it will skip decoding the probesize!
// The necessary probesize is dependent on the files you expect to read. Usually
// a few hundred KB should be enough to find all streams.
// Use plm_get_num_{audio|video}_streams() afterwards to get the number of
// streams in the file.
// Returns TRUE if any streams were found within the probesize.

int plm_probe(plm_t *self, size_t probesize);

// Get or set whether video decoding is enabled. Default TRUE.

int plm_get_video_enabled(plm_t *self);
void plm_set_video_enabled(plm_t *self, int enabled);

// Get the number of video streams (0--1) reported in the system header.

int plm_get_num_video_streams(plm_t *self);

// Get the display width/height of the video stream.

int plm_get_width(plm_t *self);
int plm_get_height(plm_t *self);

// Get or set whether audio decoding is enabled. Default TRUE.

int plm_get_audio_enabled(plm_t *self);
void plm_set_audio_enabled(plm_t *self, int enabled);

// Get the number of audio streams (0--4) reported in the system header.

int plm_get_num_audio_streams(plm_t *self);

// Set the desired audio stream (0--3). Default 0.

void plm_set_audio_stream(plm_t *self, int stream_index);

// Get the samplerate of the audio stream in samples per second.

int plm_get_samplerate(plm_t *self);

// Get or set the audio lead time in seconds - the time in which audio samples
// are decoded in advance (or behind) the video decode time. Typically this
// should be set to the duration of the buffer of the audio API that you use
// for output. E.g. for SDL2: (SDL_AudioSpec.samples / samplerate)

int64_t plm_get_audio_lead_time(plm_t *self);
void plm_set_audio_lead_time(plm_t *self, int64_t lead_time);

// Get the current internal time in seconds.

int64_t plm_get_time(plm_t *self);

// Get the video duration of the underlying source in seconds.

int64_t plm_get_duration(plm_t *self);

// Rewind all buffers back to the beginning.

void plm_rewind(plm_t *self);

// Get or set looping. Default FALSE.

int plm_get_loop(plm_t *self);
void plm_set_loop(plm_t *self, int loop);

// Get whether the file has ended. If looping is enabled, this will always
// return FALSE.

int plm_has_ended(plm_t *self);

// Set the callback for decoded video frames used with plm_decode(). If no
// callback is set, video data will be ignored and not be decoded. The *user
// Parameter will be passed to your callback.

void plm_set_video_decode_callback(plm_t *self, plm_video_decode_callback fp,
                                   void *user);

// Set the callback for decoded audio samples used with plm_decode(). If no
// callback is set, audio data will be ignored and not be decoded. The *user
// Parameter will be passed to your callback.

void plm_set_audio_decode_callback(plm_t *self, plm_audio_decode_callback fp,
                                   void *user);

// Advance the internal timer by seconds and decode video/audio up to this time.
// This will call the video_decode_callback and audio_decode_callback any number
// of times. A frame-skip is not implemented, i.e. everything up to current time
// will be decoded.

void plm_decode(plm_t *self, int64_t seconds);

// Decode and return one video frame. Returns NULL if no frame could be decoded
// (either because the source ended or data is corrupt). If you only want to
// decode video, you should disable audio via plm_set_audio_enabled().
// The returned plm_frame_t is valid until the next call to plm_decode_video()
// or until plm_destroy() is called.

plm_frame_t *plm_decode_video(plm_t *self);

// Decode and return one audio frame. Returns NULL if no frame could be decoded
// (either because the source ended or data is corrupt). If you only want to
// decode audio, you should disable video via plm_set_video_enabled().
// The returned plm_samples_t is valid until the next call to plm_decode_audio()
// or until plm_destroy() is called.

plm_samples_t *plm_decode_audio(plm_t *self);

// Seek to the specified time, clamped between 0 -- duration. This can only be
// used when the underlying plm_buffer is seekable, i.e. for files, fixed
// memory buffers or _for_appending buffers.
// If seek_exact is TRUE this will seek to the exact time, otherwise it will
// seek to the last intra frame just before the desired time. Exact seeking can
// be slow, because all frames up to the seeked one have to be decoded on top of
// the previous intra frame.
// If seeking succeeds, this function will call the video_decode_callback
// exactly once with the target frame. If audio is enabled, it will also call
// the audio_decode_callback any number of times, until the audio_lead_time is
// satisfied.
// Returns TRUE if seeking succeeded or FALSE if no frame could be found.

int plm_seek(plm_t *self, int64_t time, int seek_exact);

// Similar to plm_seek(), but will not call the video_decode_callback,
// audio_decode_callback or make any attempts to sync audio.
// Returns the found frame or NULL if no frame could be found.

plm_frame_t *plm_seek_frame(plm_t *self, int64_t time, int seek_exact);

// -----------------------------------------------------------------------------
// plm_buffer public API
// Provides the data source for all other plm_* interfaces

// The default size for buffers created from files or by the high-level API

#ifndef PLM_BUFFER_DEFAULT_SIZE
#define PLM_BUFFER_DEFAULT_SIZE (4 * 1024)
#endif

#ifndef PLM_NO_STDIO

// Create a buffer instance with a filename. Returns NULL if the file could not
// be opened.

plm_buffer_t *plm_buffer_create_with_filename(const char *filename);

// Create a buffer instance with a file handle. Pass TRUE to close_when_done
// to let plmpeg call fclose() on the handle when plm_destroy() is called.

plm_buffer_t *plm_buffer_create_with_file(FILE *fh, int close_when_done);

#endif // PLM_NO_STDIO

// Create a buffer instance with custom callbacks for loading, seeking and
// telling the position. This behaves like a file handle, but with user-defined
// callbacks, useful for file handles that don't use the standard FILE API.
// Setting the length and closing/freeing has to be done manually.

plm_buffer_t *
plm_buffer_create_with_callbacks(plm_buffer_load_callback load_callback,
                                 plm_buffer_seek_callback seek_callback,
                                 plm_buffer_tell_callback tell_callback,
                                 size_t length, void *user);

// Create a buffer instance with a pointer to memory as source. This assumes
// the whole file is in memory. The bytes are not copied. Pass 1 to
// free_when_done to let plmpeg call free() on the pointer when plm_destroy()
// is called.

plm_dma_buffer_t *plm_buffer_create_with_memory(uint8_t *bytes, size_t length);

// Create an empty buffer with an initial capacity. The buffer will grow
// as needed. Data that has already been read, will be discarded.

plm_buffer_t *plm_buffer_create_with_capacity(size_t capacity);

// Create an empty buffer with an initial capacity. The buffer will grow
// as needed. Decoded data will *not* be discarded. This can be used when
// loading a file over the network, without needing to throttle the download.
// It also allows for seeking in the already loaded data.

plm_buffer_t *plm_buffer_create_for_appending(size_t initial_capacity);

// Destroy a buffer instance and free all data

void plm_buffer_destroy(plm_buffer_t *self);

// Copy data into the buffer. If the data to be written is larger than the
// available space, the buffer will realloc() with a larger capacity.
// Returns the number of bytes written. This will always be the same as the
// passed in length, except when the buffer was created _with_memory() for
// which _write() is forbidden.

size_t plm_buffer_write(plm_buffer_t *self, uint8_t *bytes, size_t length);

// Mark the current byte length as the end of this buffer and signal that no
// more data is expected to be written to it. This function should be called
// just after the last plm_buffer_write().
// For _with_capacity buffers, this is cleared on a plm_buffer_rewind().

void plm_buffer_signal_end(plm_buffer_t *self);

// Set a callback that is called whenever the buffer needs more data

void plm_buffer_set_load_callback(plm_buffer_t *self,
                                  plm_buffer_load_callback fp, void *user);

// Rewind the buffer back to the beginning. When loading from a file handle,
// this also seeks to the beginning of the file.

void plm_buffer_rewind(plm_buffer_t *self);

// Get the total size. For files, this returns the file size. For all other
// types it returns the number of bytes currently in the buffer.

size_t plm_buffer_get_size(plm_buffer_t *self);

// Get the number of remaining (yet unread) bytes in the buffer. This can be
// useful to throttle writing.

size_t plm_buffer_get_remaining(plm_buffer_t *self);

// Get whether the read position of the buffer is at the end and no more data
// is expected.

int plm_buffer_has_ended(plm_buffer_t *self);
int plm_dma_buffer_has_ended(plm_dma_buffer_t *self);

// -----------------------------------------------------------------------------
// plm_demux public API
// Demux an MPEG Program Stream (PS) data into separate packages

// Various Packet Types

static const int PLM_DEMUX_PACKET_PRIVATE = 0xBD;
static const int PLM_DEMUX_PACKET_AUDIO_1 = 0xC0;
static const int PLM_DEMUX_PACKET_AUDIO_2 = 0xC1;
static const int PLM_DEMUX_PACKET_AUDIO_3 = 0xC2;
static const int PLM_DEMUX_PACKET_AUDIO_4 = 0xC3;
static const int PLM_DEMUX_PACKET_VIDEO_1 = 0xE0;

// Create a demuxer with a plm_buffer as source. This will also attempt to read
// the pack and system headers from the buffer.

plm_demux_t *plm_demux_create(plm_dma_buffer_t *buffer, int destroy_when_done);

// Destroy a demuxer and free all data.

void plm_demux_destroy(plm_demux_t *self);

// Returns TRUE/FALSE whether pack and system headers have been found. This will
// attempt to read the headers if non are present yet.

int plm_demux_has_headers(plm_demux_t *self);

// Probe the file for the actual number of video/audio streams. See
// plm_probe() for the details.

int plm_demux_probe(plm_demux_t *self, size_t probesize);

// Returns the number of video streams found in the system header. This will
// attempt to read the system header if non is present yet.

int plm_demux_get_num_video_streams(plm_demux_t *self);

// Returns the number of audio streams found in the system header. This will
// attempt to read the system header if non is present yet.

int plm_demux_get_num_audio_streams(plm_demux_t *self);

// Rewind the internal buffer. See plm_buffer_rewind().

void plm_demux_rewind(plm_demux_t *self);

// Get whether the file has ended. This will be cleared on seeking or rewind.

int plm_demux_has_ended(plm_demux_t *self);

// Seek to a packet of the specified type with a PTS just before specified time.
// If force_intra is TRUE, only packets containing an intra frame will be
// considered - this only makes sense when the type is PLM_DEMUX_PACKET_VIDEO_1.
// Note that the specified time is considered 0-based, regardless of the first
// PTS in the data source.

plm_packet_t *plm_demux_seek(plm_demux_t *self, int64_t time, int type,
                             int force_intra);

// Get the PTS of the first packet of this type. Returns PLM_PACKET_INVALID_TS
// if not packet of this packet type can be found.

int64_t plm_demux_get_start_time(plm_demux_t *self, int type);

// Get the duration for the specified packet type - i.e. the span between the
// the first PTS and the last PTS in the data source. This only makes sense when
// the underlying data source is a file or fixed memory.

int64_t plm_demux_get_duration(plm_demux_t *self, int type);

// Decode and return the next packet. The returned packet_t is valid until
// the next call to plm_demux_decode() or until the demuxer is destroyed.

plm_packet_t *plm_demux_decode(plm_demux_t *self);

// -----------------------------------------------------------------------------
// plm_video public API
// Decode MPEG1 Video ("mpeg1") data into raw YCrCb frames

// Create a video decoder with a plm_buffer as source.

plm_video_t *plm_video_create_with_buffer(plm_dma_buffer_t *buffer,
                                          int destroy_when_done);

// Destroy a video decoder and free all data.

void plm_video_destroy(plm_video_t *self);

// Get whether a sequence header was found and we can accurately report on
// dimensions and frameperiod.

int plm_video_has_header(plm_video_t *self);

// Get the display width/height.

int plm_video_get_width(plm_video_t *self);
int plm_video_get_height(plm_video_t *self);

// Set "no delay" mode. When enabled, the decoder assumes that the video does
// *not* contain any B-Frames. This is useful for reducing lag when streaming.
// The default is FALSE.

void plm_video_set_no_delay(plm_video_t *self, int no_delay);

// Get the current internal time in seconds.

int64_t plm_video_get_time(plm_video_t *self);

// Set the current internal time in seconds. This is only useful when you
// manipulate the underlying video buffer and want to enforce a correct
// timestamps.

void plm_video_set_time(plm_video_t *self, int64_t time);

// Rewind the internal buffer. See plm_buffer_rewind().

void plm_video_rewind(plm_video_t *self);

// Get whether the file has ended. This will be cleared on rewind.

int plm_video_has_ended(plm_video_t *self);

// Decode and return one frame of video and advance the internal time by
// 1/frameperiod seconds. The returned frame_t is valid until the next call of
// plm_video_decode() or until the video decoder is destroyed.

plm_frame_t *plm_video_decode(plm_video_t *self);

// Convert the YCrCb data of a frame into interleaved R G B data. The stride
// specifies the width in bytes of the destination buffer. I.e. the number of
// bytes from one line to the next. The stride must be at least
// (frame->width * bytes_per_pixel). The buffer pointed to by *dest must have a
// size of at least (stride * frame->height).
// Note that the alpha component of the dest buffer is always left untouched.

void plm_frame_to_rgb(plm_frame_t *frame, uint8_t *dest, int stride);
void plm_frame_to_bgr(plm_frame_t *frame, uint8_t *dest, int stride);
void plm_frame_to_rgba(plm_frame_t *frame, uint8_t *dest, int stride);
void plm_frame_to_bgra(plm_frame_t *frame, uint8_t *dest, int stride);
void plm_frame_to_argb(plm_frame_t *frame, uint8_t *dest, int stride);
void plm_frame_to_abgr(plm_frame_t *frame, uint8_t *dest, int stride);

#ifdef __cplusplus
}
#endif

#endif // PL_MPEG_H

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// IMPLEMENTATION

#ifdef PL_MPEG_IMPLEMENTATION

#include <stdlib.h>
#include <string.h>
#ifndef PLM_NO_STDIO
#include <stdio.h>
#endif

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

void *checked_malloc(int sz) {
    stop_verilator();
    void *retval = malloc(sz);
    if (!retval)
        for (;;)
            ;
    return retval;
};
#ifndef PLM_MALLOC
// To catch heap management, invalidate these calls
#define PLM_MALLOC(sz) checked_malloc(sz)
#define PLM_FREE(p) stop_verilator()
#define PLM_REALLOC(p, sz)                                                     \
    0;                                                                         \
    stop_verilator()
#endif

#define PLM_UNUSED(expr) (void)(expr)
#ifdef _MSC_VER
#pragma warning(disable : 4996)
#endif

// -----------------------------------------------------------------------------
// plm (high-level interface) implementation

struct plm_t {
    plm_demux_t *demux;
    int64_t time;
    int has_ended;
    int loop;
    int has_decoders;

    int video_enabled;
    int video_packet_type;
    plm_buffer_t *video_buffer;
    plm_video_t *video_decoder;

    int audio_enabled;
    int audio_stream_index;
    int audio_packet_type;
    int64_t audio_lead_time;
    plm_buffer_t *audio_buffer;
    plm_audio_t *audio_decoder;

    plm_video_decode_callback video_decode_callback;
    void *video_decode_callback_user_data;

    plm_audio_decode_callback audio_decode_callback;
    void *audio_decode_callback_user_data;
};

int plm_init_decoders(plm_t *self);
void plm_handle_end(plm_t *self);
void plm_read_video_packet(plm_buffer_t *buffer, void *user);
void plm_read_audio_packet(plm_buffer_t *buffer, void *user);
void plm_read_packets(plm_t *self, int requested_type);

#ifndef PLM_NO_STDIO

plm_t *plm_create_with_filename(const char *filename) {
    plm_buffer_t *buffer = plm_buffer_create_with_filename(filename);
    if (!buffer) {
        return NULL;
    }
    return plm_create_with_buffer(buffer, TRUE);
}

plm_t *plm_create_with_file(FILE *fh, int close_when_done) {
    plm_buffer_t *buffer = plm_buffer_create_with_file(fh, close_when_done);
    return plm_create_with_buffer(buffer, TRUE);
}

#endif // PLM_NO_STDIO

plm_t *plm_create_with_memory(uint8_t *bytes, size_t length) {
    plm_dma_buffer_t *buffer = plm_buffer_create_with_memory(bytes, length);
    return plm_create_with_buffer(buffer, TRUE);
}

plm_t *plm_create_with_buffer(plm_dma_buffer_t *buffer, int destroy_when_done) {
    plm_t *self = (plm_t *)PLM_MALLOC(sizeof(plm_t));
    memset(self, 0, sizeof(plm_t));

    self->demux = plm_demux_create(buffer, destroy_when_done);
    self->video_enabled = TRUE;
    self->audio_enabled = TRUE;
    plm_init_decoders(self);

    return self;
}

int plm_get_video_enabled(plm_t *self) { return self->video_enabled; }

void plm_set_video_enabled(plm_t *self, int enabled) {
    self->video_enabled = enabled;

    if (!enabled) {
        self->video_packet_type = 0;
        return;
    }

    self->video_packet_type = (plm_init_decoders(self) && self->video_decoder)
                                  ? PLM_DEMUX_PACKET_VIDEO_1
                                  : 0;
}

int plm_get_num_video_streams(plm_t *self) {
    return plm_demux_get_num_video_streams(self->demux);
}

int plm_get_width(plm_t *self) {
    return (plm_init_decoders(self) && self->video_decoder)
               ? plm_video_get_width(self->video_decoder)
               : 0;
}

int plm_get_height(plm_t *self) {
    return (plm_init_decoders(self) && self->video_decoder)
               ? plm_video_get_height(self->video_decoder)
               : 0;
}

int64_t plm_get_duration(plm_t *self) {
    return plm_demux_get_duration(self->demux, PLM_DEMUX_PACKET_VIDEO_1);
}

int plm_get_loop(plm_t *self) { return self->loop; }

void plm_set_loop(plm_t *self, int loop) { self->loop = loop; }

int plm_has_ended(plm_t *self) { return self->has_ended; }

void plm_read_video_packet(plm_buffer_t *buffer, void *user) {
    PLM_UNUSED(buffer);
    plm_t *self = (plm_t *)user;
    plm_read_packets(self, self->video_packet_type);
}

void plm_read_packets(plm_t *self, int requested_type) {
    plm_packet_t *packet;
    while ((packet = plm_demux_decode(self->demux))) {
        if (packet->type == self->video_packet_type) {
            plm_buffer_write(self->video_buffer, packet->data, packet->length);
        } else if (packet->type == self->audio_packet_type) {
            plm_buffer_write(self->audio_buffer, packet->data, packet->length);
        }

        if (packet->type == requested_type) {
            return;
        }
    }

    if (plm_demux_has_ended(self->demux)) {
        if (self->video_buffer) {
            plm_buffer_signal_end(self->video_buffer);
        }
        if (self->audio_buffer) {
            plm_buffer_signal_end(self->audio_buffer);
        }
    }
}

// -----------------------------------------------------------------------------
// plm_buffer implementation

enum plm_buffer_mode {
    PLM_BUFFER_MODE_FILE,
    PLM_BUFFER_MODE_FIXED_MEM,
    PLM_BUFFER_MODE_RING,
    PLM_BUFFER_MODE_APPEND
};

struct plm_dma_buffer_t {
    size_t capacity;
    size_t total_size;
    int has_ended;
#ifndef PLM_NO_STDIO
    int close_when_done;
    FILE *fh;
#endif
    uint8_t *bytes;
    enum plm_buffer_mode mode;
};

struct plm_buffer_t {
    size_t bit_index;
    size_t capacity;
    size_t length;
    size_t total_size;
    int discard_read_bytes;
    int has_ended;
    int free_when_done;
#ifndef PLM_NO_STDIO
    int close_when_done;
    FILE *fh;
#endif
    plm_buffer_load_callback load_callback;
    plm_buffer_seek_callback seek_callback;
    plm_buffer_tell_callback tell_callback;
    void *load_callback_user_data;
    uint8_t *bytes;
    enum plm_buffer_mode mode;
};

typedef struct {
    int16_t index;
    int16_t value;
} plm_vlc_t;

typedef struct {
    int16_t index;
    uint16_t value;
} plm_vlc_uint_t;

void plm_buffer_seek(plm_buffer_t *self, size_t pos);
size_t plm_buffer_tell(plm_buffer_t *self);
void plm_buffer_discard_read_bytes(plm_buffer_t *self);

#ifndef PLM_NO_STDIO
void plm_buffer_load_file_callback(plm_buffer_t *self, void *user);
void plm_buffer_seek_file_callback(plm_buffer_t *self, size_t offset,
                                   void *user);
size_t plm_buffer_tell_file_callback(plm_buffer_t *self, void *user);
#endif

int plm_buffer_has(plm_buffer_t *self, size_t count);
int plm_buffer_read(plm_buffer_t *self, int count);
void plm_buffer_align(plm_buffer_t *self);
void plm_buffer_skip(plm_buffer_t *self, size_t count);
int plm_buffer_skip_bytes(plm_buffer_t *self, uint8_t v);
int plm_dma_buffer_next_start_code(plm_dma_buffer_t *self);
int plm_dma_buffer_find_start_code(plm_dma_buffer_t *self, int code);
int plm_buffer_no_start_code(plm_buffer_t *self);
int16_t plm_buffer_read_vlc(plm_buffer_t *self, const plm_vlc_t *table);
uint16_t plm_buffer_read_vlc_uint(plm_buffer_t *self,
                                  const plm_vlc_uint_t *table);

#ifndef PLM_NO_STDIO

plm_buffer_t *plm_buffer_create_with_filename(const char *filename) {
    FILE *fh = fopen(filename, "rb");
    if (!fh) {
        return NULL;
    }
    return plm_buffer_create_with_file(fh, TRUE);
}

plm_buffer_t *plm_buffer_create_with_file(FILE *fh, int close_when_done) {
    plm_buffer_t *self =
        plm_buffer_create_with_capacity(PLM_BUFFER_DEFAULT_SIZE);
    self->fh = fh;
    self->close_when_done = close_when_done;
    self->mode = PLM_BUFFER_MODE_FILE;
    self->discard_read_bytes = TRUE;

    fseek(self->fh, 0, SEEK_END);
    self->total_size = ftell(self->fh);
    fseek(self->fh, 0, SEEK_SET);

    self->load_callback = plm_buffer_load_file_callback;
    self->seek_callback = plm_buffer_seek_file_callback;
    self->tell_callback = plm_buffer_tell_file_callback;
    return self;
}

#endif // PLM_NO_STDIO

plm_buffer_t *
plm_buffer_create_with_callbacks(plm_buffer_load_callback load_callback,
                                 plm_buffer_seek_callback seek_callback,
                                 plm_buffer_tell_callback tell_callback,
                                 size_t length, void *user) {
    plm_buffer_t *self =
        plm_buffer_create_with_capacity(PLM_BUFFER_DEFAULT_SIZE);
    self->mode = PLM_BUFFER_MODE_FILE;
    self->total_size = length;
    self->load_callback = load_callback;
    self->seek_callback = seek_callback;
    self->tell_callback = tell_callback;
    self->load_callback_user_data = user;
    return self;
}

plm_dma_buffer_t *plm_buffer_create_with_memory(uint8_t *bytes, size_t length) {
    static int already_taken = 0;
    if (already_taken)
        stop_verilator();
    already_taken = 1;

    static plm_dma_buffer_t singleton1;
    plm_dma_buffer_t *self = &singleton1;
    memset(self, 0, sizeof(plm_dma_buffer_t));
    self->capacity = length;
    self->total_size = length;
    self->bytes = bytes;
    self->mode = PLM_BUFFER_MODE_FIXED_MEM;
    return self;
}

plm_buffer_t *plm_buffer_create_with_capacity(size_t capacity) {
    plm_buffer_t *self = (plm_buffer_t *)PLM_MALLOC(sizeof(plm_buffer_t));
    memset(self, 0, sizeof(plm_buffer_t));
    self->capacity = capacity;
    self->free_when_done = TRUE;
    self->bytes = (uint8_t *)PLM_MALLOC(capacity);
    self->mode = PLM_BUFFER_MODE_RING;
    self->discard_read_bytes = TRUE;
    return self;
}

plm_buffer_t *plm_buffer_create_for_appending(size_t initial_capacity) {
    plm_buffer_t *self = plm_buffer_create_with_capacity(initial_capacity);
    self->mode = PLM_BUFFER_MODE_APPEND;
    self->discard_read_bytes = FALSE;
    return self;
}

void plm_buffer_destroy(plm_buffer_t *self) {
#ifndef PLM_NO_STDIO
    if (self->fh && self->close_when_done) {
        fclose(self->fh);
    }
#endif
    if (self->free_when_done) {
        PLM_FREE(self->bytes);
    }
    PLM_FREE(self);
}

size_t plm_buffer_get_size(plm_buffer_t *self) {
    return (self->mode == PLM_BUFFER_MODE_FILE) ? self->total_size
                                                : self->length;
}

size_t plm_buffer_get_remaining(plm_buffer_t *self) {
    return self->length - (self->bit_index >> 3);
}

size_t plm_buffer_write(plm_buffer_t *self, uint8_t *bytes, size_t length) {
    if (self->mode == PLM_BUFFER_MODE_FIXED_MEM) {
        return 0;
    }

    if (self->discard_read_bytes) {
        // This should be a ring buffer, but instead it just shifts all unread
        // data to the beginning of the buffer and appends new data at the end.
        // Seems to be good enough.

        plm_buffer_discard_read_bytes(self);
        if (self->mode == PLM_BUFFER_MODE_RING) {
            self->total_size = 0;
        }
    }

    // Do we have to resize to fit the new data?
    size_t bytes_available = self->capacity - self->length;
    if (bytes_available < length) {
        size_t new_size = self->capacity;
        do {
            new_size *= 2;
        } while (new_size - self->length < length);
        self->bytes = (uint8_t *)PLM_REALLOC(self->bytes, new_size);
        self->capacity = new_size;
    }

    memcpy(self->bytes + self->length, bytes, length);
    self->length += length;
    self->has_ended = FALSE;
    return length;
}

void plm_buffer_signal_end(plm_buffer_t *self) {
    self->total_size = self->length;
}

void plm_buffer_set_load_callback(plm_buffer_t *self,
                                  plm_buffer_load_callback fp, void *user) {
    self->load_callback = fp;
    self->load_callback_user_data = user;
}

void plm_buffer_seek(plm_buffer_t *self, size_t pos) {
    self->has_ended = FALSE;

    if (self->seek_callback) {
        self->seek_callback(self, pos, self->load_callback_user_data);
        self->bit_index = 0;
        self->length = 0;
    } else if (self->mode == PLM_BUFFER_MODE_RING) {
        if (pos != 0) {
            // Seeking to non-0 is forbidden for dynamic-mem buffers
            return;
        }
        self->bit_index = 0;
        self->length = 0;
        self->total_size = 0;
    } else if (pos < self->length) {
        self->bit_index = pos << 3;
    }
}

void plm_buffer_discard_read_bytes(plm_buffer_t *self) {
    size_t byte_pos = self->bit_index >> 3;
    if (byte_pos == self->length) {
        self->bit_index = 0;
        self->length = 0;
    } else if (byte_pos > 0) {
        // This operation is not allowed. The MPEG data is read only!
        for (;;)
            ;
        memmove(self->bytes, self->bytes + byte_pos, self->length - byte_pos);
        self->bit_index -= byte_pos << 3;
        self->length -= byte_pos;
    }
}

#ifndef PLM_NO_STDIO

void plm_buffer_load_file_callback(plm_buffer_t *self, void *user) {
    PLM_UNUSED(user);

    if (self->discard_read_bytes) {
        plm_buffer_discard_read_bytes(self);
    }

    size_t bytes_available = self->capacity - self->length;
    size_t bytes_read =
        fread(self->bytes + self->length, 1, bytes_available, self->fh);
    self->length += bytes_read;

    if (bytes_read == 0) {
        self->has_ended = TRUE;
    }
}

void plm_buffer_seek_file_callback(plm_buffer_t *self, size_t offset,
                                   void *user) {
    PLM_UNUSED(user);
    fseek(self->fh, offset, SEEK_SET);
}

size_t plm_buffer_tell_file_callback(plm_buffer_t *self, void *user) {
    PLM_UNUSED(user);
    return ftell(self->fh);
}

#endif // PLM_NO_STDIO

static inline int plm_dma_buffer_has(plm_dma_buffer_t *self, size_t count) {
    __asm volatile("" : : : "memory");
    while (((fifo_ctrl->write_byte_index << 3) - fifo_ctrl->read_bit_index) <
           count) {
        __asm volatile("" : : : "memory");
        // We need patience now. If we have reached this point, there has to be
        // picture data if it doesn't exist, a real VMPEG stalls. We need to
        // stall as well
    }
    return TRUE;
}

static inline int plm_dma_buffer_has_noblock(plm_dma_buffer_t *self,
                                             size_t count) {
    __asm volatile("" : : : "memory");
    if (((fifo_ctrl->write_byte_index << 3) - fifo_ctrl->read_bit_index) >=
        count) {
        return TRUE;
    }
    return FALSE;
}

int plm_buffer_has(plm_buffer_t *self, size_t count) {
    if (((self->length << 3) - self->bit_index) >= count) {
        return TRUE;
    }

    if (self->load_callback) {
        self->load_callback(self, self->load_callback_user_data);

        if (((self->length << 3) - self->bit_index) >= count) {
            return TRUE;
        }
    }

    if (self->total_size != 0 && self->length == self->total_size) {
        self->has_ended = TRUE;
    }
    return FALSE;
}

int plm_dma_buffer_read(plm_dma_buffer_t *self, int count) {
    if (!plm_dma_buffer_has(self, count)) {
        return 0;
    }

#if 0
	__asm volatile("" : : : "memory");

	int value = 0;
	while (count) {
		int current_byte = self->bytes[fifo_ctrl->read_bit_index >> 3];

		int remaining = 8 - (fifo_ctrl->read_bit_index & 7); // Remaining bits in byte
		int read = remaining < count ? remaining : count; // Bits in self run
		int shift = remaining - read;
		int mask = (0xff >> (8 - read));

		value = (value << read) | ((current_byte & (mask << shift)) >> shift);

		fifo_ctrl->read_bit_index += read;
		count -= read;
	}
#else
    fifo_ctrl->hw_read_count = count;
    __asm volatile("" : : : "memory");
    int value = fifo_ctrl->hw_read_count;
#endif
    //*((volatile uint32_t *)OUTPORT) = value;

    return value;
}

int plm_buffer_read(plm_buffer_t *self, int count) {
    int value = 0;

    while (count) {
        int current_byte = self->bytes[self->bit_index >> 3];

        int remaining = 8 - (self->bit_index & 7); // Remaining bits in byte
        int read = remaining < count ? remaining : count; // Bits in self run
        int shift = remaining - read;
        int mask = (0xff >> (8 - read));

        value = (value << read) | ((current_byte & (mask << shift)) >> shift);

        self->bit_index += read;
        count -= read;
    }

    return value;
}

void plm_dma_buffer_align(plm_dma_buffer_t *self) {
    fifo_ctrl->read_bit_index = ((fifo_ctrl->read_bit_index + 7) >> 3)
                                << 3; // Align to next byte
}

void plm_buffer_align(plm_buffer_t *self) {
    self->bit_index = ((self->bit_index + 7) >> 3) << 3; // Align to next byte
}

void plm_dma_buffer_skip(plm_dma_buffer_t *self, size_t count) {
    if (plm_dma_buffer_has(self, count)) {
        fifo_ctrl->read_bit_index += count;
    }
}

int plm_dma_buffer_next_start_code(plm_dma_buffer_t *self) {
    plm_dma_buffer_align(self);

    while (plm_dma_buffer_has(self, (4 << 3))) {
        size_t byte_index = (fifo_ctrl->read_bit_index) >> 3;
        if (self->bytes[byte_index] == 0x00 &&
            self->bytes[byte_index + 1] == 0x00 &&
            self->bytes[byte_index + 2] == 0x01) {
            fifo_ctrl->read_bit_index = (byte_index + 4) << 3;

            int startcode = self->bytes[byte_index + 3];
            return startcode;
        }
        fifo_ctrl->read_bit_index += 8;
    }
    return -1;
}

int plm_dma_buffer_find_start_code(plm_dma_buffer_t *self, int code) {
    int current = 0;
    while (TRUE) {
        current = plm_dma_buffer_next_start_code(self);
        if (current == code || current == -1) {
            return current;
        }
    }
    return -1;
}

int plm_dma_buffer_peek_non_zero(plm_dma_buffer_t *self, int bit_count) {
    if (!plm_dma_buffer_has(self, bit_count)) {
        return FALSE;
    }

    int val = plm_dma_buffer_read(self, bit_count);
    fifo_ctrl->read_bit_index -= bit_count;
    return val != 0;
}

int16_t plm_dma_buffer_read_vlc(plm_dma_buffer_t *self,
                                const plm_vlc_t *table) {
    plm_vlc_t state = {0, 0};
    do {
        state = table[state.index + plm_dma_buffer_read(self, 1)];
    } while (state.index > 0);
    return state.value;
}

uint16_t plm_dma_buffer_read_vlc_uint(plm_dma_buffer_t *self,
                                      const plm_vlc_uint_t *table) {
    return (uint16_t)plm_dma_buffer_read_vlc(self, (const plm_vlc_t *)table);
}

// ----------------------------------------------------------------------------
// plm_demux implementation

static const int PLM_START_PACK = 0xBA;
static const int PLM_START_END = 0xB9;
static const int PLM_START_SYSTEM = 0xBB;

struct plm_demux_t {
    plm_dma_buffer_t *buffer;
    int destroy_buffer_when_done;
    int64_t system_clock_ref;

    size_t last_file_size;
    int64_t last_decoded_pts;
    int64_t duration;

    int start_code;
    int has_pack_header;
    int has_system_header;
    int has_headers;

    int num_audio_streams;
    int num_video_streams;
    plm_packet_t current_packet;
    plm_packet_t next_packet;
};

void plm_demux_buffer_seek(plm_demux_t *self, size_t pos);
int64_t plm_demux_decode_time(plm_demux_t *self);
plm_packet_t *plm_demux_decode_packet(plm_demux_t *self, int type);
plm_packet_t *plm_demux_get_packet(plm_demux_t *self);

// -----------------------------------------------------------------------------
// plm_video implementation

// Inspired by Java MPEG-1 Video Decoder and Player by Zoltan Korandi
// https://sourceforge.net/projects/javampeg1video/

static const int PLM_VIDEO_PICTURE_TYPE_INTRA = 1;
static const int PLM_VIDEO_PICTURE_TYPE_PREDICTIVE = 2;
static const int PLM_VIDEO_PICTURE_TYPE_B = 3;

static const int PLM_START_SEQUENCE = 0xB3;
static const int PLM_START_SEQ_END = 0xB7;
static const int PLM_START_SLICE_FIRST = 0x01;
static const int PLM_START_SLICE_LAST = 0xAF;
static const int PLM_START_PICTURE = 0x00;
static const int PLM_START_EXTENSION = 0xB5;
static const int PLM_START_USER_DATA = 0xB2;
static const int PLM_START_GROUP_OF_PICTURES = 0xB8;

#define PLM_START_IS_SLICE(c)                                                  \
    (c >= PLM_START_SLICE_FIRST && c <= PLM_START_SLICE_LAST)

#define TICKS_30MHZ(x) (x ? 30000000.0 / x : 10000)

// clang-format off


// Longest frame period: 1251251.25125125 = 30000000 / 23.976
// Requires 21 bits for storage
static const uint32_t PLM_VIDEO_PICTURE_RATE_30MHZ[] = {
	TICKS_30MHZ(0.000),
	TICKS_30MHZ(23.976),
	TICKS_30MHZ(24.000),
	TICKS_30MHZ(25.000),
	TICKS_30MHZ(29.970),
	TICKS_30MHZ(30.000),
	TICKS_30MHZ(50.000),
	TICKS_30MHZ(59.94),
	TICKS_30MHZ(60.000),
	TICKS_30MHZ(0.000),
	TICKS_30MHZ(0.000),
	TICKS_30MHZ(0.000),
	TICKS_30MHZ(0.000),
	TICKS_30MHZ(0.000),
	TICKS_30MHZ(0.000),
	TICKS_30MHZ(0.0),
};

#define TICKS_90KHZ(x) (x ? 90000.0 / x : 100)
static const uint32_t PLM_VIDEO_PICTURE_RATE_90KHZ[] = {
	TICKS_90KHZ(0.000),
	TICKS_90KHZ(23.976),
	TICKS_90KHZ(24.000),
	TICKS_90KHZ(25.000),
	TICKS_90KHZ(29.970),
	TICKS_90KHZ(30.000),
	TICKS_90KHZ(50.000),
	TICKS_90KHZ(59.94),
	TICKS_90KHZ(60.000),
	TICKS_90KHZ(0.000),
	TICKS_90KHZ(0.000),
	TICKS_90KHZ(0.000),
	TICKS_90KHZ(0.000),
	TICKS_90KHZ(0.000),
	TICKS_90KHZ(0.000),
	TICKS_90KHZ(0.0),
};

static const uint8_t PLM_VIDEO_ZIG_ZAG[] = {
	 0,  1,  8, 16,  9,  2,  3, 10,
	17, 24, 32, 25, 18, 11,  4,  5,
	12, 19, 26, 33, 40, 48, 41, 34,
	27, 20, 13,  6,  7, 14, 21, 28,
	35, 42, 49, 56, 57, 50, 43, 36,
	29, 22, 15, 23, 30, 37, 44, 51,
	58, 59, 52, 45, 38, 31, 39, 46,
	53, 60, 61, 54, 47, 55, 62, 63
};

static const uint8_t PLM_VIDEO_INTRA_QUANT_MATRIX[] = {
	 8, 16, 19, 22, 26, 27, 29, 34,
	16, 16, 22, 24, 27, 29, 34, 37,
	19, 22, 26, 27, 29, 34, 34, 38,
	22, 22, 26, 27, 29, 34, 37, 40,
	22, 26, 27, 29, 32, 35, 40, 48,
	26, 27, 29, 32, 35, 40, 48, 58,
	26, 27, 29, 34, 38, 46, 56, 69,
	27, 29, 35, 38, 46, 56, 69, 83
};

static const uint8_t PLM_VIDEO_NON_INTRA_QUANT_MATRIX[] = {
	16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16
};

static const uint8_t PLM_VIDEO_PREMULTIPLIER_MATRIX[] = {
	32, 44, 42, 38, 32, 25, 17,  9,
	44, 62, 58, 52, 44, 35, 24, 12,
	42, 58, 55, 49, 42, 33, 23, 12,
	38, 52, 49, 44, 38, 30, 20, 10,
	32, 44, 42, 38, 32, 25, 17,  9,
	25, 35, 33, 30, 25, 20, 14,  7,
	17, 24, 23, 20, 17, 14,  9,  5,
	 9, 12, 12, 10,  9,  7,  5,  2
};

static const plm_vlc_t PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT[] = {
	{  1 << 1,    0}, {       0,    1},  //   0: x
	{  2 << 1,    0}, {  3 << 1,    0},  //   1: 0x
	{  4 << 1,    0}, {  5 << 1,    0},  //   2: 00x
	{       0,    3}, {       0,    2},  //   3: 01x
	{  6 << 1,    0}, {  7 << 1,    0},  //   4: 000x
	{       0,    5}, {       0,    4},  //   5: 001x
	{  8 << 1,    0}, {  9 << 1,    0},  //   6: 0000x
	{       0,    7}, {       0,    6},  //   7: 0001x
	{ 10 << 1,    0}, { 11 << 1,    0},  //   8: 0000 0x
	{ 12 << 1,    0}, { 13 << 1,    0},  //   9: 0000 1x
	{ 14 << 1,    0}, { 15 << 1,    0},  //  10: 0000 00x
	{ 16 << 1,    0}, { 17 << 1,    0},  //  11: 0000 01x
	{ 18 << 1,    0}, { 19 << 1,    0},  //  12: 0000 10x
	{       0,    9}, {       0,    8},  //  13: 0000 11x
	{      -1,    0}, { 20 << 1,    0},  //  14: 0000 000x
	{      -1,    0}, { 21 << 1,    0},  //  15: 0000 001x
	{ 22 << 1,    0}, { 23 << 1,    0},  //  16: 0000 010x
	{       0,   15}, {       0,   14},  //  17: 0000 011x
	{       0,   13}, {       0,   12},  //  18: 0000 100x
	{       0,   11}, {       0,   10},  //  19: 0000 101x
	{ 24 << 1,    0}, { 25 << 1,    0},  //  20: 0000 0001x
	{ 26 << 1,    0}, { 27 << 1,    0},  //  21: 0000 0011x
	{ 28 << 1,    0}, { 29 << 1,    0},  //  22: 0000 0100x
	{ 30 << 1,    0}, { 31 << 1,    0},  //  23: 0000 0101x
	{ 32 << 1,    0}, {      -1,    0},  //  24: 0000 0001 0x
	{      -1,    0}, { 33 << 1,    0},  //  25: 0000 0001 1x
	{ 34 << 1,    0}, { 35 << 1,    0},  //  26: 0000 0011 0x
	{ 36 << 1,    0}, { 37 << 1,    0},  //  27: 0000 0011 1x
	{ 38 << 1,    0}, { 39 << 1,    0},  //  28: 0000 0100 0x
	{       0,   21}, {       0,   20},  //  29: 0000 0100 1x
	{       0,   19}, {       0,   18},  //  30: 0000 0101 0x
	{       0,   17}, {       0,   16},  //  31: 0000 0101 1x
	{       0,   35}, {      -1,    0},  //  32: 0000 0001 00x
	{      -1,    0}, {       0,   34},  //  33: 0000 0001 11x
	{       0,   33}, {       0,   32},  //  34: 0000 0011 00x
	{       0,   31}, {       0,   30},  //  35: 0000 0011 01x
	{       0,   29}, {       0,   28},  //  36: 0000 0011 10x
	{       0,   27}, {       0,   26},  //  37: 0000 0011 11x
	{       0,   25}, {       0,   24},  //  38: 0000 0100 00x
	{       0,   23}, {       0,   22},  //  39: 0000 0100 01x
};
// clang-format on

static inline int
plm_dma_read_macroblock_address_increment(plm_dma_buffer_t *buffer) {
    int result;
    // Use soft huffman decoding in case we have less than 13 bits
    if (!plm_dma_buffer_has_noblock(buffer, 13)) {
        result = plm_dma_buffer_read_vlc(
            buffer, PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT);
    } else {
        fifo_ctrl->hw_huffman_read_dct_coeff = 1;
        __asm volatile("" : : : "memory");
        result = fifo_ctrl->hw_huffman_read_dct_coeff;
    }
    return result;
}
// clang-format off

static const plm_vlc_t PLM_VIDEO_MACROBLOCK_TYPE_INTRA[] = {
	{  1 << 1,    0}, {       0,  0x01},  //   0: x
	{      -1,    0}, {       0,  0x11},  //   1: 0x
};

static const plm_vlc_t PLM_VIDEO_MACROBLOCK_TYPE_PREDICTIVE[] = {
	{  1 << 1,    0}, {       0, 0x0a},  //   0: x
	{  2 << 1,    0}, {       0, 0x02},  //   1: 0x
	{  3 << 1,    0}, {       0, 0x08},  //   2: 00x
	{  4 << 1,    0}, {  5 << 1,    0},  //   3: 000x
	{  6 << 1,    0}, {       0, 0x12},  //   4: 0000x
	{       0, 0x1a}, {       0, 0x01},  //   5: 0001x
	{      -1,    0}, {       0, 0x11},  //   6: 0000 0x
};

static const plm_vlc_t PLM_VIDEO_MACROBLOCK_TYPE_B[] = {
	{  1 << 1,    0}, {  2 << 1,    0},  //   0: x
	{  3 << 1,    0}, {  4 << 1,    0},  //   1: 0x
	{       0, 0x0c}, {       0, 0x0e},  //   2: 1x
	{  5 << 1,    0}, {  6 << 1,    0},  //   3: 00x
	{       0, 0x04}, {       0, 0x06},  //   4: 01x
	{  7 << 1,    0}, {  8 << 1,    0},  //   5: 000x
	{       0, 0x08}, {       0, 0x0a},  //   6: 001x
	{  9 << 1,    0}, { 10 << 1,    0},  //   7: 0000x
	{       0, 0x1e}, {       0, 0x01},  //   8: 0001x
	{      -1,    0}, {       0, 0x11},  //   9: 0000 0x
	{       0, 0x16}, {       0, 0x1a},  //  10: 0000 1x
};

static const plm_vlc_t *PLM_VIDEO_MACROBLOCK_TYPE[] = {
	NULL,
	PLM_VIDEO_MACROBLOCK_TYPE_INTRA,
	PLM_VIDEO_MACROBLOCK_TYPE_PREDICTIVE,
	PLM_VIDEO_MACROBLOCK_TYPE_B
};

static const plm_vlc_t PLM_VIDEO_CODE_BLOCK_PATTERN[] = {
	{  1 << 1,    0}, {  2 << 1,    0},  //   0: x
	{  3 << 1,    0}, {  4 << 1,    0},  //   1: 0x
	{  5 << 1,    0}, {  6 << 1,    0},  //   2: 1x
	{  7 << 1,    0}, {  8 << 1,    0},  //   3: 00x
	{  9 << 1,    0}, { 10 << 1,    0},  //   4: 01x
	{ 11 << 1,    0}, { 12 << 1,    0},  //   5: 10x
	{ 13 << 1,    0}, {       0,   60},  //   6: 11x
	{ 14 << 1,    0}, { 15 << 1,    0},  //   7: 000x
	{ 16 << 1,    0}, { 17 << 1,    0},  //   8: 001x
	{ 18 << 1,    0}, { 19 << 1,    0},  //   9: 010x
	{ 20 << 1,    0}, { 21 << 1,    0},  //  10: 011x
	{ 22 << 1,    0}, { 23 << 1,    0},  //  11: 100x
	{       0,   32}, {       0,   16},  //  12: 101x
	{       0,    8}, {       0,    4},  //  13: 110x
	{ 24 << 1,    0}, { 25 << 1,    0},  //  14: 0000x
	{ 26 << 1,    0}, { 27 << 1,    0},  //  15: 0001x
	{ 28 << 1,    0}, { 29 << 1,    0},  //  16: 0010x
	{ 30 << 1,    0}, { 31 << 1,    0},  //  17: 0011x
	{       0,   62}, {       0,    2},  //  18: 0100x
	{       0,   61}, {       0,    1},  //  19: 0101x
	{       0,   56}, {       0,   52},  //  20: 0110x
	{       0,   44}, {       0,   28},  //  21: 0111x
	{       0,   40}, {       0,   20},  //  22: 1000x
	{       0,   48}, {       0,   12},  //  23: 1001x
	{ 32 << 1,    0}, { 33 << 1,    0},  //  24: 0000 0x
	{ 34 << 1,    0}, { 35 << 1,    0},  //  25: 0000 1x
	{ 36 << 1,    0}, { 37 << 1,    0},  //  26: 0001 0x
	{ 38 << 1,    0}, { 39 << 1,    0},  //  27: 0001 1x
	{ 40 << 1,    0}, { 41 << 1,    0},  //  28: 0010 0x
	{ 42 << 1,    0}, { 43 << 1,    0},  //  29: 0010 1x
	{       0,   63}, {       0,    3},  //  30: 0011 0x
	{       0,   36}, {       0,   24},  //  31: 0011 1x
	{ 44 << 1,    0}, { 45 << 1,    0},  //  32: 0000 00x
	{ 46 << 1,    0}, { 47 << 1,    0},  //  33: 0000 01x
	{ 48 << 1,    0}, { 49 << 1,    0},  //  34: 0000 10x
	{ 50 << 1,    0}, { 51 << 1,    0},  //  35: 0000 11x
	{ 52 << 1,    0}, { 53 << 1,    0},  //  36: 0001 00x
	{ 54 << 1,    0}, { 55 << 1,    0},  //  37: 0001 01x
	{ 56 << 1,    0}, { 57 << 1,    0},  //  38: 0001 10x
	{ 58 << 1,    0}, { 59 << 1,    0},  //  39: 0001 11x
	{       0,   34}, {       0,   18},  //  40: 0010 00x
	{       0,   10}, {       0,    6},  //  41: 0010 01x
	{       0,   33}, {       0,   17},  //  42: 0010 10x
	{       0,    9}, {       0,    5},  //  43: 0010 11x
	{      -1,    0}, { 60 << 1,    0},  //  44: 0000 000x
	{ 61 << 1,    0}, { 62 << 1,    0},  //  45: 0000 001x
	{       0,   58}, {       0,   54},  //  46: 0000 010x
	{       0,   46}, {       0,   30},  //  47: 0000 011x
	{       0,   57}, {       0,   53},  //  48: 0000 100x
	{       0,   45}, {       0,   29},  //  49: 0000 101x
	{       0,   38}, {       0,   26},  //  50: 0000 110x
	{       0,   37}, {       0,   25},  //  51: 0000 111x
	{       0,   43}, {       0,   23},  //  52: 0001 000x
	{       0,   51}, {       0,   15},  //  53: 0001 001x
	{       0,   42}, {       0,   22},  //  54: 0001 010x
	{       0,   50}, {       0,   14},  //  55: 0001 011x
	{       0,   41}, {       0,   21},  //  56: 0001 100x
	{       0,   49}, {       0,   13},  //  57: 0001 101x
	{       0,   35}, {       0,   19},  //  58: 0001 110x
	{       0,   11}, {       0,    7},  //  59: 0001 111x
	{       0,   39}, {       0,   27},  //  60: 0000 0001x
	{       0,   59}, {       0,   55},  //  61: 0000 0010x
	{       0,   47}, {       0,   31},  //  62: 0000 0011x
};

static const plm_vlc_t PLM_VIDEO_MOTION[] = {
	{  1 << 1,    0}, {       0,    0},  //   0: x
	{  2 << 1,    0}, {  3 << 1,    0},  //   1: 0x
	{  4 << 1,    0}, {  5 << 1,    0},  //   2: 00x
	{       0,    1}, {       0,   -1},  //   3: 01x
	{  6 << 1,    0}, {  7 << 1,    0},  //   4: 000x
	{       0,    2}, {       0,   -2},  //   5: 001x
	{  8 << 1,    0}, {  9 << 1,    0},  //   6: 0000x
	{       0,    3}, {       0,   -3},  //   7: 0001x
	{ 10 << 1,    0}, { 11 << 1,    0},  //   8: 0000 0x
	{ 12 << 1,    0}, { 13 << 1,    0},  //   9: 0000 1x
	{      -1,    0}, { 14 << 1,    0},  //  10: 0000 00x
	{ 15 << 1,    0}, { 16 << 1,    0},  //  11: 0000 01x
	{ 17 << 1,    0}, { 18 << 1,    0},  //  12: 0000 10x
	{       0,    4}, {       0,   -4},  //  13: 0000 11x
	{      -1,    0}, { 19 << 1,    0},  //  14: 0000 001x
	{ 20 << 1,    0}, { 21 << 1,    0},  //  15: 0000 010x
	{       0,    7}, {       0,   -7},  //  16: 0000 011x
	{       0,    6}, {       0,   -6},  //  17: 0000 100x
	{       0,    5}, {       0,   -5},  //  18: 0000 101x
	{ 22 << 1,    0}, { 23 << 1,    0},  //  19: 0000 0011x
	{ 24 << 1,    0}, { 25 << 1,    0},  //  20: 0000 0100x
	{ 26 << 1,    0}, { 27 << 1,    0},  //  21: 0000 0101x
	{ 28 << 1,    0}, { 29 << 1,    0},  //  22: 0000 0011 0x
	{ 30 << 1,    0}, { 31 << 1,    0},  //  23: 0000 0011 1x
	{ 32 << 1,    0}, { 33 << 1,    0},  //  24: 0000 0100 0x
	{       0,   10}, {       0,  -10},  //  25: 0000 0100 1x
	{       0,    9}, {       0,   -9},  //  26: 0000 0101 0x
	{       0,    8}, {       0,   -8},  //  27: 0000 0101 1x
	{       0,   16}, {       0,  -16},  //  28: 0000 0011 00x
	{       0,   15}, {       0,  -15},  //  29: 0000 0011 01x
	{       0,   14}, {       0,  -14},  //  30: 0000 0011 10x
	{       0,   13}, {       0,  -13},  //  31: 0000 0011 11x
	{       0,   12}, {       0,  -12},  //  32: 0000 0100 00x
	{       0,   11}, {       0,  -11},  //  33: 0000 0100 01x
};

static const plm_vlc_t PLM_VIDEO_DCT_SIZE_LUMINANCE[] = {
	{  1 << 1,    0}, {  2 << 1,    0},  //   0: x
	{       0,    1}, {       0,    2},  //   1: 0x
	{  3 << 1,    0}, {  4 << 1,    0},  //   2: 1x
	{       0,    0}, {       0,    3},  //   3: 10x
	{       0,    4}, {  5 << 1,    0},  //   4: 11x
	{       0,    5}, {  6 << 1,    0},  //   5: 111x
	{       0,    6}, {  7 << 1,    0},  //   6: 1111x
	{       0,    7}, {  8 << 1,    0},  //   7: 1111 1x
	{       0,    8}, {      -1,    0},  //   8: 1111 11x
};

static const plm_vlc_t PLM_VIDEO_DCT_SIZE_CHROMINANCE[] = {
	{  1 << 1,    0}, {  2 << 1,    0},  //   0: x
	{       0,    0}, {       0,    1},  //   1: 0x
	{       0,    2}, {  3 << 1,    0},  //   2: 1x
	{       0,    3}, {  4 << 1,    0},  //   3: 11x
	{       0,    4}, {  5 << 1,    0},  //   4: 111x
	{       0,    5}, {  6 << 1,    0},  //   5: 1111x
	{       0,    6}, {  7 << 1,    0},  //   6: 1111 1x
	{       0,    7}, {  8 << 1,    0},  //   7: 1111 11x
	{       0,    8}, {      -1,    0},  //   8: 1111 111x
};

static const plm_vlc_t *PLM_VIDEO_DCT_SIZE[] = {
	PLM_VIDEO_DCT_SIZE_LUMINANCE,
	PLM_VIDEO_DCT_SIZE_CHROMINANCE,
	PLM_VIDEO_DCT_SIZE_CHROMINANCE
};


//  dct_coeff bitmap:
//    0xff00  run
//    0x00ff  level

//  Decoded values are unsigned. Sign bit follows in the stream.

static const plm_vlc_uint_t PLM_VIDEO_DCT_COEFF[] = {
	{  1 << 1,        0}, {       0,   0x0001},  //   0: x
	{  2 << 1,        0}, {  3 << 1,        0},  //   1: 0x
	{  4 << 1,        0}, {  5 << 1,        0},  //   2: 00x
	{  6 << 1,        0}, {       0,   0x0101},  //   3: 01x
	{  7 << 1,        0}, {  8 << 1,        0},  //   4: 000x
	{  9 << 1,        0}, { 10 << 1,        0},  //   5: 001x
	{       0,   0x0002}, {       0,   0x0201},  //   6: 010x
	{ 11 << 1,        0}, { 12 << 1,        0},  //   7: 0000x
	{ 13 << 1,        0}, { 14 << 1,        0},  //   8: 0001x
	{ 15 << 1,        0}, {       0,   0x0003},  //   9: 0010x
	{       0,   0x0401}, {       0,   0x0301},  //  10: 0011x
	{ 16 << 1,        0}, {       0,   0xffff},  //  11: 0000 0x
	{ 17 << 1,        0}, { 18 << 1,        0},  //  12: 0000 1x
	{       0,   0x0701}, {       0,   0x0601},  //  13: 0001 0x
	{       0,   0x0102}, {       0,   0x0501},  //  14: 0001 1x
	{ 19 << 1,        0}, { 20 << 1,        0},  //  15: 0010 0x
	{ 21 << 1,        0}, { 22 << 1,        0},  //  16: 0000 00x
	{       0,   0x0202}, {       0,   0x0901},  //  17: 0000 10x
	{       0,   0x0004}, {       0,   0x0801},  //  18: 0000 11x
	{ 23 << 1,        0}, { 24 << 1,        0},  //  19: 0010 00x
	{ 25 << 1,        0}, { 26 << 1,        0},  //  20: 0010 01x
	{ 27 << 1,        0}, { 28 << 1,        0},  //  21: 0000 000x
	{ 29 << 1,        0}, { 30 << 1,        0},  //  22: 0000 001x
	{       0,   0x0d01}, {       0,   0x0006},  //  23: 0010 000x
	{       0,   0x0c01}, {       0,   0x0b01},  //  24: 0010 001x
	{       0,   0x0302}, {       0,   0x0103},  //  25: 0010 010x
	{       0,   0x0005}, {       0,   0x0a01},  //  26: 0010 011x
	{ 31 << 1,        0}, { 32 << 1,        0},  //  27: 0000 0000x
	{ 33 << 1,        0}, { 34 << 1,        0},  //  28: 0000 0001x
	{ 35 << 1,        0}, { 36 << 1,        0},  //  29: 0000 0010x
	{ 37 << 1,        0}, { 38 << 1,        0},  //  30: 0000 0011x
	{ 39 << 1,        0}, { 40 << 1,        0},  //  31: 0000 0000 0x
	{ 41 << 1,        0}, { 42 << 1,        0},  //  32: 0000 0000 1x
	{ 43 << 1,        0}, { 44 << 1,        0},  //  33: 0000 0001 0x
	{ 45 << 1,        0}, { 46 << 1,        0},  //  34: 0000 0001 1x
	{       0,   0x1001}, {       0,   0x0502},  //  35: 0000 0010 0x
	{       0,   0x0007}, {       0,   0x0203},  //  36: 0000 0010 1x
	{       0,   0x0104}, {       0,   0x0f01},  //  37: 0000 0011 0x
	{       0,   0x0e01}, {       0,   0x0402},  //  38: 0000 0011 1x
	{ 47 << 1,        0}, { 48 << 1,        0},  //  39: 0000 0000 00x
	{ 49 << 1,        0}, { 50 << 1,        0},  //  40: 0000 0000 01x
	{ 51 << 1,        0}, { 52 << 1,        0},  //  41: 0000 0000 10x
	{ 53 << 1,        0}, { 54 << 1,        0},  //  42: 0000 0000 11x
	{ 55 << 1,        0}, { 56 << 1,        0},  //  43: 0000 0001 00x
	{ 57 << 1,        0}, { 58 << 1,        0},  //  44: 0000 0001 01x
	{ 59 << 1,        0}, { 60 << 1,        0},  //  45: 0000 0001 10x
	{ 61 << 1,        0}, { 62 << 1,        0},  //  46: 0000 0001 11x
	{       0,        0}, { 63 << 1,        0},  //  47: 0000 0000 000x
	{ 64 << 1,        0}, { 65 << 1,        0},  //  48: 0000 0000 001x
	{ 66 << 1,        0}, { 67 << 1,        0},  //  49: 0000 0000 010x
	{ 68 << 1,        0}, { 69 << 1,        0},  //  50: 0000 0000 011x
	{ 70 << 1,        0}, { 71 << 1,        0},  //  51: 0000 0000 100x
	{ 72 << 1,        0}, { 73 << 1,        0},  //  52: 0000 0000 101x
	{ 74 << 1,        0}, { 75 << 1,        0},  //  53: 0000 0000 110x
	{ 76 << 1,        0}, { 77 << 1,        0},  //  54: 0000 0000 111x
	{       0,   0x000b}, {       0,   0x0802},  //  55: 0000 0001 000x
	{       0,   0x0403}, {       0,   0x000a},  //  56: 0000 0001 001x
	{       0,   0x0204}, {       0,   0x0702},  //  57: 0000 0001 010x
	{       0,   0x1501}, {       0,   0x1401},  //  58: 0000 0001 011x
	{       0,   0x0009}, {       0,   0x1301},  //  59: 0000 0001 100x
	{       0,   0x1201}, {       0,   0x0105},  //  60: 0000 0001 101x
	{       0,   0x0303}, {       0,   0x0008},  //  61: 0000 0001 110x
	{       0,   0x0602}, {       0,   0x1101},  //  62: 0000 0001 111x
	{ 78 << 1,        0}, { 79 << 1,        0},  //  63: 0000 0000 0001x
	{ 80 << 1,        0}, { 81 << 1,        0},  //  64: 0000 0000 0010x
	{ 82 << 1,        0}, { 83 << 1,        0},  //  65: 0000 0000 0011x
	{ 84 << 1,        0}, { 85 << 1,        0},  //  66: 0000 0000 0100x
	{ 86 << 1,        0}, { 87 << 1,        0},  //  67: 0000 0000 0101x
	{ 88 << 1,        0}, { 89 << 1,        0},  //  68: 0000 0000 0110x
	{ 90 << 1,        0}, { 91 << 1,        0},  //  69: 0000 0000 0111x
	{       0,   0x0a02}, {       0,   0x0902},  //  70: 0000 0000 1000x
	{       0,   0x0503}, {       0,   0x0304},  //  71: 0000 0000 1001x
	{       0,   0x0205}, {       0,   0x0107},  //  72: 0000 0000 1010x
	{       0,   0x0106}, {       0,   0x000f},  //  73: 0000 0000 1011x
	{       0,   0x000e}, {       0,   0x000d},  //  74: 0000 0000 1100x
	{       0,   0x000c}, {       0,   0x1a01},  //  75: 0000 0000 1101x
	{       0,   0x1901}, {       0,   0x1801},  //  76: 0000 0000 1110x
	{       0,   0x1701}, {       0,   0x1601},  //  77: 0000 0000 1111x
	{ 92 << 1,        0}, { 93 << 1,        0},  //  78: 0000 0000 0001 0x
	{ 94 << 1,        0}, { 95 << 1,        0},  //  79: 0000 0000 0001 1x
	{ 96 << 1,        0}, { 97 << 1,        0},  //  80: 0000 0000 0010 0x
	{ 98 << 1,        0}, { 99 << 1,        0},  //  81: 0000 0000 0010 1x
	{100 << 1,        0}, {101 << 1,        0},  //  82: 0000 0000 0011 0x
	{102 << 1,        0}, {103 << 1,        0},  //  83: 0000 0000 0011 1x
	{       0,   0x001f}, {       0,   0x001e},  //  84: 0000 0000 0100 0x
	{       0,   0x001d}, {       0,   0x001c},  //  85: 0000 0000 0100 1x
	{       0,   0x001b}, {       0,   0x001a},  //  86: 0000 0000 0101 0x
	{       0,   0x0019}, {       0,   0x0018},  //  87: 0000 0000 0101 1x
	{       0,   0x0017}, {       0,   0x0016},  //  88: 0000 0000 0110 0x
	{       0,   0x0015}, {       0,   0x0014},  //  89: 0000 0000 0110 1x
	{       0,   0x0013}, {       0,   0x0012},  //  90: 0000 0000 0111 0x
	{       0,   0x0011}, {       0,   0x0010},  //  91: 0000 0000 0111 1x
	{104 << 1,        0}, {105 << 1,        0},  //  92: 0000 0000 0001 00x
	{106 << 1,        0}, {107 << 1,        0},  //  93: 0000 0000 0001 01x
	{108 << 1,        0}, {109 << 1,        0},  //  94: 0000 0000 0001 10x
	{110 << 1,        0}, {111 << 1,        0},  //  95: 0000 0000 0001 11x
	{       0,   0x0028}, {       0,   0x0027},  //  96: 0000 0000 0010 00x
	{       0,   0x0026}, {       0,   0x0025},  //  97: 0000 0000 0010 01x
	{       0,   0x0024}, {       0,   0x0023},  //  98: 0000 0000 0010 10x
	{       0,   0x0022}, {       0,   0x0021},  //  99: 0000 0000 0010 11x
	{       0,   0x0020}, {       0,   0x010e},  // 100: 0000 0000 0011 00x
	{       0,   0x010d}, {       0,   0x010c},  // 101: 0000 0000 0011 01x
	{       0,   0x010b}, {       0,   0x010a},  // 102: 0000 0000 0011 10x
	{       0,   0x0109}, {       0,   0x0108},  // 103: 0000 0000 0011 11x
	{       0,   0x0112}, {       0,   0x0111},  // 104: 0000 0000 0001 000x
	{       0,   0x0110}, {       0,   0x010f},  // 105: 0000 0000 0001 001x
	{       0,   0x0603}, {       0,   0x1002},  // 106: 0000 0000 0001 010x
	{       0,   0x0f02}, {       0,   0x0e02},  // 107: 0000 0000 0001 011x
	{       0,   0x0d02}, {       0,   0x0c02},  // 108: 0000 0000 0001 100x
	{       0,   0x0b02}, {       0,   0x1f01},  // 109: 0000 0000 0001 101x
	{       0,   0x1e01}, {       0,   0x1d01},  // 110: 0000 0000 0001 110x
	{       0,   0x1c01}, {       0,   0x1b01},  // 111: 0000 0000 0001 111x
};
// clang-format on
static inline uint16_t plm_dma_read_dct_coeff(plm_dma_buffer_t *buffer) {
    uint16_t result;

    // Use soft huffman decoding in case we have less than 16 bits

    if (!plm_dma_buffer_has_noblock(buffer, 16)) {
        result = plm_dma_buffer_read_vlc_uint(buffer, PLM_VIDEO_DCT_COEFF);
    } else {
        fifo_ctrl->hw_huffman_read_dct_coeff = 0;
        __asm volatile("" : : : "memory");
        return fifo_ctrl->hw_huffman_read_dct_coeff;
    }

    return result;
}

typedef struct {
    int full_px;
    int is_set;
    int r_size;
    int h;
    int v;
} plm_video_motion_t;

// We use 16 MB of memory to store the framebuffers
#define DDR_MEMORY_AREA 16777216

struct plm_video_t {
    int start_code;
    int picture_type;
    int temporal_ref;
    int timecode; // from GOP

    plm_video_motion_t motion_forward;
    plm_video_motion_t motion_backward;

    int quantizer_scale;
    int slice_begin;
    int macroblock_address;

    int mb_row;
    int mb_col;

    int macroblock_type;
    int macroblock_intra;

    int dc_predictor[3];

    plm_dma_buffer_t *buffer;

    plm_frame_t frame_current;
    plm_frame_t frame_forward;
    plm_frame_t frame_backward;

    int has_reference_frame;
};

static inline uint8_t plm_clamp(int n) {
    if (n > 255) {
        n = 255;
    } else if (n < 0) {
        n = 0;
    }
    return n;
}

int plm_video_decode_group_of_pictures(plm_video_t *self);
int plm_video_decode_sequence_header(plm_video_t *self);
void plm_video_init_frame(plm_video_t *self, plm_frame_t *frame);
void plm_video_decode_picture(plm_video_t *self);
void plm_video_decode_slice(plm_video_t *self, int slice);
void plm_video_decode_macroblock(plm_video_t *self);
void plm_video_decode_motion_vectors(plm_video_t *self);
int plm_video_decode_motion_vector(plm_video_t *self, int r_size, int motion);
void plm_video_predict_macroblock(plm_video_t *self);
void plm_video_copy_macroblock(plm_video_t *self, plm_frame_t *s, int motion_h,
                               int motion_v);
void plm_video_interpolate_macroblock(plm_video_t *self, plm_frame_t *s,
                                      int motion_h, int motion_v);
void plm_video_process_macroblock(plm_video_t *self, uint8_t *s, uint8_t *d,
                                  int mh, int mb, int bs, int interp);
void plm_video_decode_block(plm_video_t *self, int block);
void plm_video_idct(int *block);

plm_video_t *plm_video_create_with_buffer(plm_dma_buffer_t *buffer,
                                          int destroy_when_done) {

    static plm_video_t plm_instance;
    plm_video_t *self = &plm_instance;
    memset(self, 0, sizeof(plm_video_t));

    self->buffer = buffer;

    __asm volatile("" : : : "memory");

    if (fifo_ctrl->has_sequence_header) {
        /*
         * We already have decoded something, there are two possibilities now
         * 1) We are resuming the same stream
         * 2) We are starting a new stream
         * Since this function is only called with a certain minimum of buffered
         * data, we can try to find a sequence header. If one exists, we need to
         * forget the already cached one!
         */
        size_t byte_index = (fifo_ctrl->read_bit_index) >> 3;
        size_t byte_index_end = fifo_ctrl->write_byte_index - 4;
        self->start_code = -1;
        while (byte_index < byte_index_end) {
            if (buffer->bytes[byte_index] == 0x00 &&
                buffer->bytes[byte_index + 1] == 0x00 &&
                buffer->bytes[byte_index + 2] == 0x01 &&
                buffer->bytes[byte_index + 3] == PLM_START_SEQUENCE) {
                // Position read pointer for plm_video_decode_sequence_header()
                fifo_ctrl->read_bit_index = (byte_index + 4) << 3;
                self->start_code = PLM_START_SEQUENCE;
                break;
            }
            byte_index++;
        }
    } else {
        // We don't have any sequence header cached, search for one!
        self->start_code =
            plm_dma_buffer_find_start_code(self->buffer, PLM_START_SEQUENCE);
    }

    if (self->start_code != -1) {
        plm_video_decode_sequence_header(self);
    }

    return self;
}

int plm_video_get_width(plm_video_t *self) {
    return plm_video_has_header(self) ? seq_hdr_conf.width : 0;
}

int plm_video_get_height(plm_video_t *self) {
    return plm_video_has_header(self) ? seq_hdr_conf.height : 0;
}

plm_frame_t *plm_video_decode(plm_video_t *self) {
    // used to avoid finding a sequence header again
    static int dont_find_next_header = FALSE;

    plm_frame_t *frame = NULL;

    // In case the sequence header was parsed before reset
    self->start_code = PLM_START_SEQUENCE;

    do {
        DEBUG_STATE = 2;
        if (!dont_find_next_header)
            self->start_code = plm_dma_buffer_next_start_code(self->buffer);
        dont_find_next_header = FALSE;

        if (self->start_code == PLM_START_PICTURE &&
            fifo_ctrl->has_sequence_header) {
            plm_video_decode_picture(self);

            if (self->picture_type == PLM_VIDEO_PICTURE_TYPE_B) {
                frame = &self->frame_current;
            } else if (self->has_reference_frame) {
                frame = &self->frame_forward;
            } else {
                self->has_reference_frame = TRUE;
            }
        } else if (self->start_code == PLM_START_SEQ_END) {
            frame_display_fifo->event_sequence_end = 1;
            __asm volatile("" : : : "memory");

            if (self->has_reference_frame) {
                self->has_reference_frame = FALSE;
                frame = &self->frame_backward;
                fifo_ctrl->has_sequence_header = FALSE;
            }
        } else if (self->start_code == PLM_START_SEQUENCE) {
            if (self->has_reference_frame) {
                // Is this state even possible?

                // Anyway, we start as sequence end
                self->has_reference_frame = FALSE;
                frame = &self->frame_backward;
                fifo_ctrl->has_sequence_header = FALSE;

                dont_find_next_header = TRUE;
                break;
            }
            plm_video_decode_sequence_header(self);
        } else if (self->start_code == PLM_START_GROUP_OF_PICTURES) {
            plm_video_decode_group_of_pictures(self);
        } else if (self->start_code == -1) {
            // This should be impossible!
            *((volatile uint8_t *)OUTPORT_END) = 9;
            return NULL;
        }

    } while (!frame);
    DEBUG_STATE = 15;

    return frame;
}

int plm_video_has_header(plm_video_t *self) {
    __asm volatile("" : : : "memory");
    if (fifo_ctrl->has_sequence_header) {
        return TRUE;
    }

    if (self->start_code != PLM_START_SEQUENCE) {
        self->start_code =
            plm_dma_buffer_find_start_code(self->buffer, PLM_START_SEQUENCE);
    }
    if (self->start_code == -1) {
        return FALSE;
    }

    if (!plm_video_decode_sequence_header(self)) {
        return FALSE;
    }

    return TRUE;
}

int plm_video_decode_group_of_pictures(plm_video_t *self) {
    if (!plm_dma_buffer_has(self->buffer, 11 + 2 + 12)) {
        return FALSE;
    }

    // skip drop frame flag
    plm_dma_buffer_skip(self->buffer, 1);

    // 5 bits hour
    // 6 bits minute
    uint32_t hours_minutes = plm_dma_buffer_read(self->buffer, 11);

    // skip marker
    plm_dma_buffer_skip(self->buffer, 1);

    // 6 bits seconds
    // 6 bits picture
    uint32_t seconds_frame = plm_dma_buffer_read(self->buffer, 12);

    // according to FMV driver
    // High  SSSS SSSS SSPP PPPP
    // Low   HHHH HHHH HHMM MMMM
    self->timecode = (seconds_frame << 16) | (hours_minutes);
}

int plm_video_decode_sequence_header(plm_video_t *self) {
    int max_header_size = 64 + 2 * 64 * 8; // 64 bit header + 2x 64 byte matrix
    if (!plm_dma_buffer_has(self->buffer, max_header_size)) {
        return FALSE;
    }

    int width = plm_dma_buffer_read(self->buffer, 12);
    int height = plm_dma_buffer_read(self->buffer, 12);

    if (width <= 0 || height <= 0) {
        return FALSE;
    }

    int frame_size_changed =
        ((width != seq_hdr_conf.width) || (height != seq_hdr_conf.height));

    seq_hdr_conf.width = width;
    seq_hdr_conf.height = height;

    // Get pixel aspect ratio
    seq_hdr_conf.pixel_aspect_ratio = plm_dma_buffer_read(self->buffer, 4);

    // Get frame rate
    seq_hdr_conf.frameperiod = plm_dma_buffer_read(self->buffer, 4);

    // Skip bit_rate, marker, buffer_size and constrained bit
    plm_dma_buffer_skip(self->buffer, 18 + 1 + 10 + 1);

    // Load custom intra quant matrix?
    if (plm_dma_buffer_read(self->buffer, 1)) {
        for (int i = 0; i < 64; i++) {
            int idx = PLM_VIDEO_ZIG_ZAG[i];
            seq_hdr_conf.intra_quant_matrix[idx] =
                plm_dma_buffer_read(self->buffer, 8);
        }
    } else {
        memcpy(seq_hdr_conf.intra_quant_matrix, PLM_VIDEO_INTRA_QUANT_MATRIX,
               64);
    }

    // Load custom non intra quant matrix?
    if (plm_dma_buffer_read(self->buffer, 1)) {
        for (int i = 0; i < 64; i++) {
            int idx = PLM_VIDEO_ZIG_ZAG[i];
            seq_hdr_conf.non_intra_quant_matrix[idx] =
                plm_dma_buffer_read(self->buffer, 8);
        }
    } else {
        memcpy(seq_hdr_conf.non_intra_quant_matrix,
               PLM_VIDEO_NON_INTRA_QUANT_MATRIX, 64);
    }

    seq_hdr_conf.mb_width = (seq_hdr_conf.width + 15) >> 4;
    seq_hdr_conf.mb_height = (seq_hdr_conf.height + 15) >> 4;
    seq_hdr_conf.mb_size = seq_hdr_conf.mb_width * seq_hdr_conf.mb_height;

    seq_hdr_conf.luma_width = seq_hdr_conf.mb_width << 4;
    seq_hdr_conf.luma_height = seq_hdr_conf.mb_height << 4;

    seq_hdr_conf.chroma_width = seq_hdr_conf.mb_width << 3;
    seq_hdr_conf.chroma_height = seq_hdr_conf.mb_height << 3;

    fifo_ctrl->has_sequence_header = TRUE;

    if (frame_size_changed) {
        // Allocate one big chunk of data for all 3 frames = 9 planes
        plm_video_init_frame(self, &self->frame_current);
        plm_video_init_frame(self, &self->frame_forward);
        plm_video_init_frame(self, &self->frame_backward);
    }
    __asm volatile("" : : : "memory");
    seq_hdr_latched = 1;

    return TRUE;
}

void plm_video_init_frame(plm_video_t *self, plm_frame_t *frame) {
    size_t luma_plane_size = seq_hdr_conf.luma_width * seq_hdr_conf.luma_height;
    size_t chroma_plane_size =
        seq_hdr_conf.chroma_width * seq_hdr_conf.chroma_height;
    size_t frame_data_size = (luma_plane_size + 2 * chroma_plane_size);

    frame->width = seq_hdr_conf.width;
    frame->height = seq_hdr_conf.height;
    frame->y.width = seq_hdr_conf.luma_width;
    frame->y.height = seq_hdr_conf.luma_height;
    frame->y.data = seq_hdr_conf.next_framebuffer;

    frame->cr.width = seq_hdr_conf.chroma_width;
    frame->cr.height = seq_hdr_conf.chroma_height;
    frame->cr.data = seq_hdr_conf.next_framebuffer + luma_plane_size;

    frame->cb.width = seq_hdr_conf.chroma_width;
    frame->cb.height = seq_hdr_conf.chroma_height;
    frame->cb.data =
        seq_hdr_conf.next_framebuffer + luma_plane_size + chroma_plane_size;

    frame->ready_for_display = FALSE;

    seq_hdr_conf.next_framebuffer += frame_data_size;
    if (((uint32_t)(seq_hdr_conf.next_framebuffer + frame_data_size)) >=
        DDR_MEMORY_AREA)
        seq_hdr_conf.next_framebuffer = 0;
}

void plm_video_decode_picture(plm_video_t *self) {
    DEBUG_STATE = 3;

    self->temporal_ref = plm_dma_buffer_read(self->buffer, 10);
    self->picture_type = plm_dma_buffer_read(self->buffer, 3);
    plm_dma_buffer_skip(self->buffer, 16); // skip vbv_delay

    // D frames or unknown coding type
    if (self->picture_type <= 0 ||
        self->picture_type > PLM_VIDEO_PICTURE_TYPE_B) {
        return;
    }

    DEBUG_STATE = 4;

    // Forward full_px, f_code
    if (self->picture_type == PLM_VIDEO_PICTURE_TYPE_PREDICTIVE ||
        self->picture_type == PLM_VIDEO_PICTURE_TYPE_B) {
        self->motion_forward.full_px = plm_dma_buffer_read(self->buffer, 1);
        int f_code = plm_dma_buffer_read(self->buffer, 3);
        if (f_code == 0) {
            // Ignore picture with zero f_code
            return;
        }
        self->motion_forward.r_size = f_code - 1;
    }

    DEBUG_STATE = 5;

    // Backward full_px, f_code
    if (self->picture_type == PLM_VIDEO_PICTURE_TYPE_B) {
        self->motion_backward.full_px = plm_dma_buffer_read(self->buffer, 1);
        int f_code = plm_dma_buffer_read(self->buffer, 3);
        if (f_code == 0) {
            // Ignore picture with zero f_code
            return;
        }
        self->motion_backward.r_size = f_code - 1;
    }

    plm_frame_t frame_temp = self->frame_forward;
    if (self->picture_type == PLM_VIDEO_PICTURE_TYPE_INTRA ||
        self->picture_type == PLM_VIDEO_PICTURE_TYPE_PREDICTIVE) {
        self->frame_forward = self->frame_backward;
    }

    // Find first slice start code; skip extension and user data
    do {
        self->start_code = plm_dma_buffer_next_start_code(self->buffer);
    } while (self->start_code == PLM_START_EXTENSION ||
             self->start_code == PLM_START_USER_DATA);

    // Decode all slices
    plm_video_init_frame(self, &self->frame_current);
    self->frame_current.picture_type = self->picture_type;
    self->frame_current.temporal_ref = self->temporal_ref;
    self->frame_current.timecode = self->timecode;

    while (PLM_START_IS_SLICE(self->start_code)) {
        DEBUG_STATE = 7;

        plm_video_decode_slice(self, self->start_code & 0x000000FF);
        if (self->macroblock_address >= seq_hdr_conf.mb_size - 1) {
            break;
        }
        self->start_code = plm_dma_buffer_next_start_code(self->buffer);
    }

    // Predict skipped macroblocks after the last slice
    while (self->macroblock_address < seq_hdr_conf.mb_size - 1) {
        self->macroblock_address++;
        self->mb_row = self->macroblock_address / seq_hdr_conf.mb_width;
        self->mb_col = self->macroblock_address % seq_hdr_conf.mb_width;
        plm_video_predict_macroblock(self);
    }

    // Present settings even before a frame is available for display
    frame_display_fifo->width = seq_hdr_conf.width;
    frame_display_fifo->height = seq_hdr_conf.height;
    int period30mhz = PLM_VIDEO_PICTURE_RATE_30MHZ[seq_hdr_conf.frameperiod] *
                      (frame_display_fifo->slow_motion + 1);
    int period90khz = PLM_VIDEO_PICTURE_RATE_90KHZ[seq_hdr_conf.frameperiod];

    if (period30mhz < 400000) // much faster than 60 Hz? Better not
        period30mhz = 400000;
    frame_display_fifo->frameperiod_90khz = period90khz;
    frame_display_fifo->frameperiod_rawhdr = seq_hdr_conf.frameperiod;
    frame_display_fifo->timecode = self->timecode;

    self->frame_current.ready_for_display = TRUE;
    frame_display_fifo->event_frame_decoded = 1;

    // If this is a reference picture rotate the prediction pointers
    if (self->picture_type == PLM_VIDEO_PICTURE_TYPE_INTRA ||
        self->picture_type == PLM_VIDEO_PICTURE_TYPE_PREDICTIVE) {
        self->frame_backward = self->frame_current;
        self->frame_current = frame_temp;
    }
}

void plm_video_decode_slice(plm_video_t *self, int slice) {
    self->slice_begin = TRUE;
    self->macroblock_address = (slice - 1) * seq_hdr_conf.mb_width - 1;

    // Reset motion vectors and DC predictors
    self->motion_backward.h = self->motion_forward.h = 0;
    self->motion_backward.v = self->motion_forward.v = 0;
    self->dc_predictor[0] = 128;
    self->dc_predictor[1] = 128;
    self->dc_predictor[2] = 128;

    self->quantizer_scale = plm_dma_buffer_read(self->buffer, 5);

    // Skip extra
    while (plm_dma_buffer_read(self->buffer, 1)) {
        plm_dma_buffer_skip(self->buffer, 8);
    }

    do {
        plm_video_decode_macroblock(self);
    } while (self->macroblock_address < seq_hdr_conf.mb_size - 1 &&
             plm_dma_buffer_peek_non_zero(self->buffer, 23));
}

void plm_video_decode_macroblock(plm_video_t *self) {
    DEBUG_STATE = 14;

    worker_cnt++;
    if (worker_cnt >= 3)
        worker_cnt = 0;

    // Decode increment
    int increment = 0;
    int t = plm_dma_read_macroblock_address_increment(self->buffer);

    while (t == 34) {
        // macroblock_stuffing
        t = plm_dma_read_macroblock_address_increment(self->buffer);
    }
    while (t == 35) {
        // macroblock_escape
        increment += 33;
        t = plm_dma_read_macroblock_address_increment(self->buffer);
    }
    increment += t;

    DEBUG_STATE = 16;

    // Process any skipped macroblocks
    if (self->slice_begin) {
        // The first increment of each slice is relative to beginning of the
        // previous row, not the previous macroblock
        self->slice_begin = FALSE;
        self->macroblock_address += increment;
    } else {
        if (self->macroblock_address + increment >= seq_hdr_conf.mb_size) {
            return; // invalid
        }
        if (increment > 1) {
            // Skipped macroblocks reset DC predictors
            self->dc_predictor[0] = 128;
            self->dc_predictor[1] = 128;
            self->dc_predictor[2] = 128;

            // Skipped macroblocks in P-pictures reset motion vectors
            if (self->picture_type == PLM_VIDEO_PICTURE_TYPE_PREDICTIVE) {
                self->motion_forward.h = 0;
                self->motion_forward.v = 0;
            }
        }

        // Predict skipped macroblocks
        while (increment > 1) {
            self->macroblock_address++;
            self->mb_row = self->macroblock_address / seq_hdr_conf.mb_width;
            self->mb_col = self->macroblock_address % seq_hdr_conf.mb_width;

            plm_video_predict_macroblock(self);
            increment--;
        }
        self->macroblock_address++;
    }

    self->mb_row = self->macroblock_address / seq_hdr_conf.mb_width;
    self->mb_col = self->macroblock_address % seq_hdr_conf.mb_width;

    if (self->mb_col >= seq_hdr_conf.mb_width ||
        self->mb_row >= seq_hdr_conf.mb_height) {
        return; // corrupt stream;
    }

    // Process the current macroblock
    const plm_vlc_t *table = PLM_VIDEO_MACROBLOCK_TYPE[self->picture_type];
    self->macroblock_type = plm_dma_buffer_read_vlc(self->buffer, table);

    self->macroblock_intra = (self->macroblock_type & 0x01);
    self->motion_forward.is_set = (self->macroblock_type & 0x08);
    self->motion_backward.is_set = (self->macroblock_type & 0x04);

    // Quantizer scale
    if ((self->macroblock_type & 0x10) != 0) {
        self->quantizer_scale = plm_dma_buffer_read(self->buffer, 5);
    }

    if (self->macroblock_intra) {
        // Intra-coded macroblocks reset motion vectors
        self->motion_backward.h = self->motion_forward.h = 0;
        self->motion_backward.v = self->motion_forward.v = 0;
    } else {
        // Non-intra macroblocks reset DC predictors
        self->dc_predictor[0] = 128;
        self->dc_predictor[1] = 128;
        self->dc_predictor[2] = 128;

        plm_video_decode_motion_vectors(self);
        plm_video_predict_macroblock(self);
    }

    // Decode blocks
    int cbp = ((self->macroblock_type & 0x02) != 0)
                  ? plm_dma_buffer_read_vlc(self->buffer,
                                            PLM_VIDEO_CODE_BLOCK_PATTERN)
                  : (self->macroblock_intra ? 0x3f : 0);

    for (int block = 0, mask = 0x20; block < 6; block++) {
        if ((cbp & mask) != 0) {
            plm_video_decode_block(self, block);
        }
        mask >>= 1;
    }
}

void plm_video_decode_motion_vectors(plm_video_t *self) {

    // Forward
    if (self->motion_forward.is_set) {
        int r_size = self->motion_forward.r_size;
        self->motion_forward.h = plm_video_decode_motion_vector(
            self, r_size, self->motion_forward.h);
        self->motion_forward.v = plm_video_decode_motion_vector(
            self, r_size, self->motion_forward.v);
    } else if (self->picture_type == PLM_VIDEO_PICTURE_TYPE_PREDICTIVE) {
        // No motion information in P-picture, reset vectors
        self->motion_forward.h = 0;
        self->motion_forward.v = 0;
    }

    if (self->motion_backward.is_set) {
        int r_size = self->motion_backward.r_size;
        self->motion_backward.h = plm_video_decode_motion_vector(
            self, r_size, self->motion_backward.h);
        self->motion_backward.v = plm_video_decode_motion_vector(
            self, r_size, self->motion_backward.v);
    }
}

int plm_video_decode_motion_vector(plm_video_t *self, int r_size, int motion) {
    int fscale = 1 << r_size;
    int m_code = plm_dma_buffer_read_vlc(self->buffer, PLM_VIDEO_MOTION);
    int r = 0;
    int d;

    if ((m_code != 0) && (fscale != 1)) {
        r = plm_dma_buffer_read(self->buffer, r_size);
        d = ((abs(m_code) - 1) << r_size) + r + 1;
        if (m_code < 0) {
            d = -d;
        }
    } else {
        d = m_code;
    }

    motion += d;
    if (motion > (fscale << 4) - 1) {
        motion -= fscale << 5;
    } else if (motion < (int)((unsigned)(-fscale) << 4)) {
        motion += fscale << 5;
    }

    return motion;
}

void plm_video_predict_macroblock(plm_video_t *self) {
    int fw_h = self->motion_forward.h;
    int fw_v = self->motion_forward.v;

    if (self->motion_forward.full_px) {
        fw_h <<= 1;
        fw_v <<= 1;
    }

    if (self->picture_type == PLM_VIDEO_PICTURE_TYPE_B) {
        int bw_h = self->motion_backward.h;
        int bw_v = self->motion_backward.v;

        if (self->motion_backward.full_px) {
            bw_h <<= 1;
            bw_v <<= 1;
        }

        if (self->motion_forward.is_set) {
            DEBUG_STATE = 23;
            plm_video_copy_macroblock(self, &self->frame_forward, fw_h, fw_v);
            if (self->motion_backward.is_set) {
                DEBUG_STATE = 24;
                plm_video_interpolate_macroblock(self, &self->frame_backward,
                                                 bw_h, bw_v);
            }
        } else {
            DEBUG_STATE = 25;
            plm_video_copy_macroblock(self, &self->frame_backward, bw_h, bw_v);
        }
    } else {
        DEBUG_STATE = 26;
        plm_video_copy_macroblock(self, &self->frame_forward, fw_h, fw_v);
    }
}

void plm_video_copy_macroblock(plm_video_t *self, plm_frame_t *s, int motion_h,
                               int motion_v) {
    plm_frame_t *d = &self->frame_current;
    plm_video_process_macroblock(self, s->y.data, d->y.data, motion_h, motion_v,
                                 16, FALSE);
    plm_video_process_macroblock(self, s->cr.data, d->cr.data, motion_h / 2,
                                 motion_v / 2, 8, FALSE);
    plm_video_process_macroblock(self, s->cb.data, d->cb.data, motion_h / 2,
                                 motion_v / 2, 8, FALSE);
}

void plm_video_interpolate_macroblock(plm_video_t *self, plm_frame_t *s,
                                      int motion_h, int motion_v) {
    plm_frame_t *d = &self->frame_current;
    plm_video_process_macroblock(self, s->y.data, d->y.data, motion_h, motion_v,
                                 16, TRUE);
    plm_video_process_macroblock(self, s->cr.data, d->cr.data, motion_h / 2,
                                 motion_v / 2, 8, TRUE);
    plm_video_process_macroblock(self, s->cb.data, d->cb.data, motion_h / 2,
                                 motion_v / 2, 8, TRUE);
}

#define PLM_BLOCK_SET(DEST, DEST_INDEX, DEST_WIDTH, SOURCE_INDEX,              \
                      SOURCE_WIDTH, BLOCK_SIZE, OP)                            \
    do {                                                                       \
        int dest_scan = DEST_WIDTH - BLOCK_SIZE;                               \
        int source_scan = SOURCE_WIDTH - BLOCK_SIZE;                           \
        for (int y = 0; y < BLOCK_SIZE; y++) {                                 \
            for (int x = 0; x < BLOCK_SIZE; x++) {                             \
                DEST[DEST_INDEX] = OP;                                         \
                SOURCE_INDEX++;                                                \
                DEST_INDEX++;                                                  \
            }                                                                  \
            SOURCE_INDEX += source_scan;                                       \
            DEST_INDEX += dest_scan;                                           \
        }                                                                      \
    } while (FALSE)

void macroblock_worker(uint8_t *s, uint8_t *d, int odd_h, int odd_v,
                       int interpolate, int dw, int di, int si,
                       int block_size) {
#define PLM_MB_CASE(INTERPOLATE, ODD_H, ODD_V, OP)                             \
    case ((INTERPOLATE << 2) | (ODD_H << 1) | (ODD_V)):                        \
        PLM_BLOCK_SET(d, di, dw, si, dw, block_size, OP);                      \
        break

    switch ((interpolate << 2) | (odd_h << 1) | (odd_v)) {
        PLM_MB_CASE(0, 0, 0, (s[si]));
        PLM_MB_CASE(0, 0, 1, (s[si] + s[si + dw] + 1) >> 1);
        PLM_MB_CASE(0, 1, 0, (s[si] + s[si + 1] + 1) >> 1);
        PLM_MB_CASE(0, 1, 1,
                    (s[si] + s[si + 1] + s[si + dw] + s[si + dw + 1] + 2) >> 2);

        PLM_MB_CASE(1, 0, 0, (d[di] + (s[si]) + 1) >> 1);
        PLM_MB_CASE(1, 0, 1,
                    (d[di] + ((s[si] + s[si + dw] + 1) >> 1) + 1) >> 1);
        PLM_MB_CASE(1, 1, 0, (d[di] + ((s[si] + s[si + 1] + 1) >> 1) + 1) >> 1);
        PLM_MB_CASE(
            1, 1, 1,
            (d[di] +
             ((s[si] + s[si + 1] + s[si + dw] + s[si + dw + 1] + 2) >> 2) +
             1) >>
                1);
    }

#undef PLM_MB_CASE
}

void plm_video_process_macroblock(plm_video_t *self, uint8_t *s, uint8_t *d,
                                  int motion_h, int motion_v, int block_size,
                                  int interpolate) {
    int dw = seq_hdr_conf.mb_width * block_size;

    int hp = motion_h >> 1;
    int vp = motion_v >> 1;
    int odd_h = (motion_h & 1) == 1;
    int odd_v = (motion_v & 1) == 1;

    unsigned int si = ((self->mb_row * block_size) + vp) * dw +
                      (self->mb_col * block_size) + hp;
    unsigned int di = (self->mb_row * dw + self->mb_col) * block_size;

    unsigned int max_address =
        (dw * (seq_hdr_conf.mb_height * block_size - block_size + 1) -
         block_size);
    if (si > max_address || di > max_address) {
        return; // corrupt video
    }

    struct image_synthesis_descriptor *desc = get_next_free_synthesis_desc();
    desc->cpm.interpolate = interpolate;
    desc->cpm.block_size = block_size;
    desc->cpm.odd_h = odd_h;
    desc->cpm.odd_v = odd_v;
    desc->cpm.s = s;
    desc->cpm.si = si;
    desc->cpm.di = di;
    desc->cpm.d = d;
    desc->cpm.dw = dw;
    commit_synthesis_desc(desc, 2);
}

#if 1
static void write_pixels(int macroblock_intra, int n, int *s, int di,
                         uint8_t *d, int dw, int si) {
    if (macroblock_intra) {
        // Overwrite (no prediction)
        if (n == 1) {
            int clamped = plm_clamp((s[0] + 128) >> 8);
            PLM_BLOCK_SET(d, di, dw, si, 8, 8, clamped);
        } else {
            plm_video_idct(s);
            PLM_BLOCK_SET(d, di, dw, si, 8, 8, plm_clamp(s[si]));
        }
    } else {
        // Add data to the predicted macroblock
        if (n == 1) {
            int value = (s[0] + 128) >> 8;
            PLM_BLOCK_SET(d, di, dw, si, 8, 8, plm_clamp(d[di] + value));
        } else {
            plm_video_idct(s);
            PLM_BLOCK_SET(d, di, dw, si, 8, 8, plm_clamp(d[di] + s[si]));
        }
    }
}

#endif

void plm_video_decode_block(plm_video_t *self, int block) {
    int n = 0;
    uint8_t *quant_matrix;
    DEBUG_STATE = 8;

    struct image_synthesis_descriptor *desc = get_next_free_synthesis_desc();
    int *block_data = desc->cwp.block_data;
    fast_block_zero(block_data);

    DEBUG_STATE = 17;

    // Decode DC coefficient of intra-coded blocks
    if (self->macroblock_intra) {
        int predictor;
        int dct_size;

        // DC prediction
        int plane_index = block > 3 ? block - 3 : 0;
        predictor = self->dc_predictor[plane_index];
        dct_size = plm_dma_buffer_read_vlc(self->buffer,
                                           PLM_VIDEO_DCT_SIZE[plane_index]);

        // Read DC coeff
        if (dct_size > 0) {
            int differential = plm_dma_buffer_read(self->buffer, dct_size);
            if ((differential & (1 << (dct_size - 1))) != 0) {
                block_data[0] = predictor + differential;
            } else {
                block_data[0] =
                    predictor + (-(1 << dct_size) | (differential + 1));
            }
        } else {
            block_data[0] = predictor;
        }

        // Save predictor value
        self->dc_predictor[plane_index] = block_data[0];

        // Dequantize + premultiply
        block_data[0] <<= (3 + 5);

        quant_matrix = seq_hdr_conf.intra_quant_matrix;
        n = 1;
    } else {
        quant_matrix = seq_hdr_conf.non_intra_quant_matrix;
    }

    // Decode AC coefficients (+DC for non-intra)
    int level = 0;
    while (TRUE) {
        int run = 0;
        DEBUG_STATE = 20;
        uint16_t coeff = plm_dma_read_dct_coeff(self->buffer);
        DEBUG_STATE = 32;

        if ((coeff == 0x0001) && (n > 0) &&
            (plm_dma_buffer_read(self->buffer, 1) == 0)) {
            // end_of_block
            break;
        }
        if (coeff == 0xffff) {
            // escape
            run = plm_dma_buffer_read(self->buffer, 6);
            level = plm_dma_buffer_read(self->buffer, 8);
            if (level == 0) {
                level = plm_dma_buffer_read(self->buffer, 8);
            } else if (level == 128) {
                level = plm_dma_buffer_read(self->buffer, 8) - 256;
            } else if (level > 128) {
                level = level - 256;
            }
        } else {
            run = coeff >> 8;
            level = coeff & 0xff;
            if (plm_dma_buffer_read(self->buffer, 1)) {
                level = -level;
            }
        }

        n += run;
        if (n < 0 || n >= 64) {
            return; // invalid
        }

        DEBUG_STATE = 31;
        int de_zig_zagged = PLM_VIDEO_ZIG_ZAG[n];
        n++;

        // Dequantize, oddify, clip
        level = (unsigned)level << 1;
        if (!self->macroblock_intra) {
            level += (level < 0 ? -1 : 1);
        }
        level =
            (level * self->quantizer_scale * quant_matrix[de_zig_zagged]) >> 4;
        if ((level & 1) == 0) {
            level -= level > 0 ? 1 : -1;
        }
        if (level > 2047) {
            level = 2047;
        } else if (level < -2048) {
            level = -2048;
        }

        // Save premultiplied coefficient
        block_data[de_zig_zagged] =
            level * PLM_VIDEO_PREMULTIPLIER_MATRIX[de_zig_zagged];
    }
    DEBUG_STATE = 6;

    // Move block to its place
    uint8_t *d;
    int dw;
    int di;

    if (block < 4) {
        d = self->frame_current.y.data;
        dw = seq_hdr_conf.luma_width;
        di = (self->mb_row * seq_hdr_conf.luma_width + self->mb_col) << 4;
        if ((block & 1) != 0) {
            di += 8;
        }
        if ((block & 2) != 0) {
            di += seq_hdr_conf.luma_width << 3;
        }
    } else {
        d = (block == 4) ? self->frame_current.cb.data
                         : self->frame_current.cr.data;
        dw = seq_hdr_conf.chroma_width;
        di = ((self->mb_row * seq_hdr_conf.luma_width) << 2) +
             (self->mb_col << 3);
    }

    int *s = block_data;
    int si = 0;

    desc->cwp.macroblock_intra = self->macroblock_intra;
    desc->cwp.n = n;
    desc->cwp.s = s;
    desc->cwp.si = si;
    desc->cwp.di = di;
    desc->cwp.d = d;
    desc->cwp.dw = dw;
    commit_synthesis_desc(desc, 1);
    DEBUG_STATE = 12;
}

void plm_video_idct(int *block) {
    int b1, b3, b4, b6, b7, tmp1, tmp2, m0, x0, x1, x2, x3, x4, y3, y4, y5, y6,
        y7;

    DEBUG_STATE = 10;

    // Transform columns
    for (int i = 0; i < 8; ++i) {
        b1 = block[4 * 8 + i];
        b3 = block[2 * 8 + i] + block[6 * 8 + i];
        b4 = block[5 * 8 + i] - block[3 * 8 + i];
        tmp1 = block[1 * 8 + i] + block[7 * 8 + i];
        tmp2 = block[3 * 8 + i] + block[5 * 8 + i];
        b6 = block[1 * 8 + i] - block[7 * 8 + i];
        b7 = tmp1 + tmp2;
        m0 = block[0 * 8 + i];
        x4 = ((b6 * 473 - b4 * 196 + 128) >> 8) - b7;
        x0 = x4 - (((tmp1 - tmp2) * 362 + 128) >> 8);
        x1 = m0 - b1;
        x2 = (((block[2 * 8 + i] - block[6 * 8 + i]) * 362 + 128) >> 8) - b3;
        x3 = m0 + b1;
        y3 = x1 + x2;
        y4 = x3 + b3;
        y5 = x1 - x2;
        y6 = x3 - b3;
        y7 = -x0 - ((b4 * 473 + b6 * 196 + 128) >> 8);
        block[0 * 8 + i] = b7 + y4;
        block[1 * 8 + i] = x4 + y3;
        block[2 * 8 + i] = y5 - x0;
        block[3 * 8 + i] = y6 - y7;
        block[4 * 8 + i] = y6 + y7;
        block[5 * 8 + i] = x0 + y5;
        block[6 * 8 + i] = y3 - x4;
        block[7 * 8 + i] = y4 - b7;
    }

    // Transform rows
    for (int i = 0; i < 64; i += 8) {
        b1 = block[4 + i];
        b3 = block[2 + i] + block[6 + i];
        b4 = block[5 + i] - block[3 + i];
        tmp1 = block[1 + i] + block[7 + i];
        tmp2 = block[3 + i] + block[5 + i];
        b6 = block[1 + i] - block[7 + i];
        b7 = tmp1 + tmp2;
        m0 = block[0 + i];
        x4 = ((b6 * 473 - b4 * 196 + 128) >> 8) - b7;
        x0 = x4 - (((tmp1 - tmp2) * 362 + 128) >> 8);
        x1 = m0 - b1;
        x2 = (((block[2 + i] - block[6 + i]) * 362 + 128) >> 8) - b3;
        x3 = m0 + b1;
        y3 = x1 + x2;
        y4 = x3 + b3;
        y5 = x1 - x2;
        y6 = x3 - b3;
        y7 = -x0 - ((b4 * 473 + b6 * 196 + 128) >> 8);
        block[0 + i] = (b7 + y4 + 128) >> 8;
        block[1 + i] = (x4 + y3 + 128) >> 8;
        block[2 + i] = (y5 - x0 + 128) >> 8;
        block[3 + i] = (y6 - y7 + 128) >> 8;
        block[4 + i] = (y6 + y7 + 128) >> 8;
        block[5 + i] = (x0 + y5 + 128) >> 8;
        block[6 + i] = (y3 - x4 + 128) >> 8;
        block[7 + i] = (y4 - b7 + 128) >> 8;
    }

    DEBUG_STATE = 11;
}

// YCbCr conversion following the BT.601 standard:
// https://infogalactic.com/info/YCbCr#ITU-R_BT.601_conversion

#define PLM_PUT_PIXEL(RI, GI, BI, Y_OFFSET, DEST_OFFSET)                       \
    y = ((frame->y.data[y_index + Y_OFFSET] - 16) * 76309) >> 16;              \
    dest[d_index + DEST_OFFSET + RI] = plm_clamp(y + r);                       \
    dest[d_index + DEST_OFFSET + GI] = plm_clamp(y - g);                       \
    dest[d_index + DEST_OFFSET + BI] = plm_clamp(y + b);

#define PLM_DEFINE_FRAME_CONVERT_FUNCTION(NAME, BYTES_PER_PIXEL, RI, GI, BI)   \
    void NAME(plm_frame_t *frame, uint8_t *dest, int stride) {                 \
        int cols = frame->width >> 1;                                          \
        int rows = frame->height >> 1;                                         \
        int yw = frame->y.width;                                               \
        int cw = frame->cb.width;                                              \
        for (int row = 0; row < rows; row++) {                                 \
            int c_index = row * cw;                                            \
            int y_index = row * 2 * yw;                                        \
            int d_index = row * 2 * stride;                                    \
            for (int col = 0; col < cols; col++) {                             \
                int y;                                                         \
                int cr = frame->cr.data[c_index] - 128;                        \
                int cb = frame->cb.data[c_index] - 128;                        \
                int r = (cr * 104597) >> 16;                                   \
                int g = (cb * 25674 + cr * 53278) >> 16;                       \
                int b = (cb * 132201) >> 16;                                   \
                PLM_PUT_PIXEL(RI, GI, BI, 0, 0);                               \
                PLM_PUT_PIXEL(RI, GI, BI, 1, BYTES_PER_PIXEL);                 \
                PLM_PUT_PIXEL(RI, GI, BI, yw, stride);                         \
                PLM_PUT_PIXEL(RI, GI, BI, yw + 1, stride + BYTES_PER_PIXEL);   \
                c_index += 1;                                                  \
                y_index += 2;                                                  \
                d_index += 2 * BYTES_PER_PIXEL;                                \
            }                                                                  \
        }                                                                      \
    }

PLM_DEFINE_FRAME_CONVERT_FUNCTION(plm_frame_to_rgb, 3, 0, 1, 2)
PLM_DEFINE_FRAME_CONVERT_FUNCTION(plm_frame_to_bgr, 3, 2, 1, 0)
PLM_DEFINE_FRAME_CONVERT_FUNCTION(plm_frame_to_rgba, 4, 0, 1, 2)
PLM_DEFINE_FRAME_CONVERT_FUNCTION(plm_frame_to_bgra, 4, 2, 1, 0)
PLM_DEFINE_FRAME_CONVERT_FUNCTION(plm_frame_to_argb, 4, 1, 2, 3)
PLM_DEFINE_FRAME_CONVERT_FUNCTION(plm_frame_to_abgr, 4, 3, 2, 1)

#undef PLM_PUT_PIXEL
#undef PLM_DEFINE_FRAME_CONVERT_FUNCTION

#endif // PL_MPEG_IMPLEMENTATION
