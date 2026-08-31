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
plm_audio_* ... the MPEG1 Audio Layer I/II ("mp1"/"mp2") decoder


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
However, if you get raw mpeg1video data or raw mp1/mp2 audio data from a
different source, these functions can be used to decode the raw data directly.
Similarly, if you only want to analyze an MPEG-PS file or extract raw video or
audio packets from it, you can use the plm_demux_* functions.


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

#include <math.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// -----------------------------------------------------------------------------
// Public Data Types

// Object types for the various interfaces

typedef struct plm_t plm_t;
typedef struct plm_buffer_t plm_buffer_t;
typedef struct plm_dma_buffer_t plm_dma_buffer_t;
typedef struct plm_demux_t plm_demux_t;
typedef struct plm_video_t plm_video_t;
typedef struct plm_audio_t plm_audio_t;

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
    int32_t time;
    unsigned int width;
    unsigned int height;
    plm_plane_t y;
    plm_plane_t cr;
    plm_plane_t cb;
} plm_frame_t;

// Callback function type for decoded video frames used by the high-level
// plm_* interface

typedef void (*plm_video_decode_callback)(plm_t *self, plm_frame_t *frame, void *user);

// Decoded Audio Samples
// Samples are stored as normalized (-1, 1) float either interleaved, or if
// PLM_AUDIO_SEPARATE_CHANNELS is defined, in two separate arrays.
// The `count` is the number of decoded samples per channel in this frame.
// MPEG Layer II frames have PLM_AUDIO_SAMPLES_PER_FRAME samples; Layer I
// frames have 384 samples. The buffers are sized for the larger Layer II frame.

#define PLM_AUDIO_SAMPLES_PER_FRAME 1152

typedef struct {
    int32_t time;
    unsigned int count;
} plm_samples_t;

// Callback function type for decoded audio samples used by the high-level
// plm_* interface

typedef void (*plm_audio_decode_callback)(plm_t *self, plm_samples_t *samples, void *user);

// Callback function for plm_buffer when it needs more data

typedef void (*plm_buffer_load_callback)(plm_buffer_t *self, void *user);

// Callback function for plm_buffer when it needs to seek

typedef void (*plm_buffer_seek_callback)(plm_buffer_t *self, size_t offset, void *user);

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

plm_t *plm_create_with_memory(uint8_t *bytes, size_t length, int free_when_done);

// Create a plmpeg instance with a plm_buffer as source. Pass TRUE to
// destroy_when_done to let plmpeg call plm_buffer_destroy() on the buffer when
// plm_destroy() is called.

plm_t *plm_create_with_buffer(plm_dma_buffer_t *buffer, int destroy_when_done);

// Destroy a plmpeg instance and free all data.

void plm_destroy(plm_t *self);

// Get whether we have headers on all available streams and we can report the
// number of video/audio streams, video dimensions, framerate and audio
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
int32_t plm_get_pixel_aspect_ratio(plm_t *self);

// Get the framerate of the video stream in frames per second.

int32_t plm_get_framerate(plm_t *self);

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

void plm_set_video_decode_callback(plm_t *self, plm_video_decode_callback fp, void *user);

// Set the callback for decoded audio samples used with plm_decode(). If no
// callback is set, audio data will be ignored and not be decoded. The *user
// Parameter will be passed to your callback.

void plm_set_audio_decode_callback(plm_t *self, plm_audio_decode_callback fp, void *user);

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

plm_buffer_t *plm_buffer_create_with_callbacks(plm_buffer_load_callback load_callback,
                                               plm_buffer_seek_callback seek_callback,
                                               plm_buffer_tell_callback tell_callback, size_t length,
                                               void *user);

// Create a buffer instance with a pointer to memory as source. This assumes
// the whole file is in memory. The bytes are not copied. Pass 1 to
// free_when_done to let plmpeg call free() on the pointer when plm_destroy()
// is called.

plm_dma_buffer_t *plm_buffer_create_with_memory(uint8_t *bytes, size_t length, int free_when_done);

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

void plm_buffer_set_load_callback(plm_buffer_t *self, plm_buffer_load_callback fp, void *user);

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

plm_packet_t *plm_demux_seek(plm_demux_t *self, int64_t time, int type, int force_intra);

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

plm_video_t *plm_video_create_with_buffer(plm_buffer_t *buffer, int destroy_when_done);

// Destroy a video decoder and free all data.

void plm_video_destroy(plm_video_t *self);

// Get whether a sequence header was found and we can accurately report on
// dimensions and framerate.

int plm_video_has_header(plm_video_t *self);

// Get the framerate in frames per second.

int32_t plm_video_get_framerate(plm_video_t *self);
int32_t plm_video_get_pixel_aspect_ratio(plm_video_t *self);

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
// 1/framerate seconds. The returned frame_t is valid until the next call of
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

// -----------------------------------------------------------------------------
// plm_audio public API
// Decode MPEG-1 Audio Layer I/II ("mp1"/"mp2") data into raw samples

// Create an audio decoder with a plm_buffer as source.

plm_audio_t *plm_audio_create_with_buffer(plm_dma_buffer_t *buffer);

// Destroy an audio decoder and free all data.

void plm_audio_destroy(plm_audio_t *self);

// Get whether a frame header was found and we can accurately report on
// samplerate.

int plm_audio_has_header(plm_audio_t *self);

// Get the samplerate in samples per second.

int plm_audio_get_samplerate(plm_audio_t *self);

// Get the current internal time in seconds.

int64_t plm_audio_get_time(plm_audio_t *self);

// Set the current internal time in seconds. This is only useful when you
// manipulate the underlying video buffer and want to enforce a correct
// timestamps.

void plm_audio_set_time(plm_audio_t *self, int64_t time);

// Rewind the internal buffer. See plm_buffer_rewind().

void plm_audio_rewind(plm_audio_t *self);

// Get whether the file has ended. This will be cleared on rewind.

int plm_audio_has_ended(plm_audio_t *self);

// Decode and return one "frame" of audio and advance the internal time by
// (samples->count/samplerate) seconds. The returned samples_t
// is valid until the next call of plm_audio_decode() or until the audio
// decoder is destroyed.

plm_samples_t *plm_audio_decode(plm_audio_t *self);

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

#ifndef PLM_MALLOC
#define PLM_MALLOC(sz) malloc(sz)

// To catch heap management, invalidate these calls
#define PLM_FREE(p) stop_verilator();
#define PLM_REALLOC(p, sz)                                                                                   \
    0;                                                                                                       \
    stop_verilator();
#endif

#define PLM_UNUSED(expr) (void)(expr)
#ifdef _MSC_VER
#pragma warning(disable : 4996)
#endif

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
    int discard_read_bytes;
    int has_ended;
    int free_when_done;
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
void plm_buffer_seek_file_callback(plm_buffer_t *self, size_t offset, void *user);
size_t plm_buffer_tell_file_callback(plm_buffer_t *self, void *user);
#endif

int plm_dma_buffer_has(plm_dma_buffer_t *self, size_t count);
int plm_dma_buffer_read(plm_dma_buffer_t *self, int count);
void plm_dma_buffer_align(plm_dma_buffer_t *self);
void plm_dma_buffer_skip(plm_dma_buffer_t *self, size_t count);
int plm_dma_buffer_skip_bytes(plm_dma_buffer_t *self, uint8_t v);
int plm_dma_buffer_next_start_code(plm_dma_buffer_t *self);
int plm_dma_buffer_find_start_code(plm_dma_buffer_t *self, int code);
int plm_dma_buffer_no_start_code(plm_dma_buffer_t *self);

int plm_buffer_has(plm_buffer_t *self, size_t count);
int plm_buffer_read(plm_buffer_t *self, int count);
void plm_buffer_align(plm_buffer_t *self);
void plm_buffer_skip(plm_buffer_t *self, size_t count);
int plm_buffer_skip_bytes(plm_buffer_t *self, uint8_t v);
int plm_buffer_next_start_code(plm_buffer_t *self);
int plm_buffer_find_start_code(plm_buffer_t *self, int code);
int plm_buffer_no_start_code(plm_buffer_t *self);

int16_t plm_buffer_read_vlc(plm_buffer_t *self, const plm_vlc_t *table);
uint16_t plm_buffer_read_vlc_uint(plm_buffer_t *self, const plm_vlc_uint_t *table);

plm_dma_buffer_t *plm_buffer_create_with_memory(uint8_t *bytes, size_t length, int free_when_done) {
    static int already_taken = 0;
    if (already_taken)
        stop_verilator();
    already_taken = 1;

    static plm_dma_buffer_t singleton1;
    plm_dma_buffer_t *self = &singleton1;
    memset(self, 0, sizeof(plm_dma_buffer_t));
    self->capacity = length;
    self->total_size = length;
    self->free_when_done = free_when_done;
    self->bytes = bytes;
    self->mode = PLM_BUFFER_MODE_FIXED_MEM;
    self->discard_read_bytes = FALSE;
    return self;
}
int plm_dma_buffer_has(plm_dma_buffer_t *self, size_t count) {
    if (((fifo_ctrl->write_byte_index << 3) - fifo_ctrl->read_bit_index) >= count) {
        return TRUE;
    }

    if (self->total_size != 0 && fifo_ctrl->write_byte_index == self->total_size) {
        self->has_ended = TRUE;
    }
    return FALSE;
}
int plm_dma_buffer_read(plm_dma_buffer_t *self, int count) {
    if (!plm_dma_buffer_has(self, count)) {
        return 0;
    }

    int value = 0;
    while (count) {
        int current_byte = self->bytes[fifo_ctrl->read_bit_index >> 3];

        int remaining = 8 - (fifo_ctrl->read_bit_index & 7); // Remaining bits in byte
        int read = remaining < count ? remaining : count;    // Bits in self run
        int shift = remaining - read;
        int mask = (0xff >> (8 - read));

        value = (value << read) | ((current_byte & (mask << shift)) >> shift);

        fifo_ctrl->read_bit_index += read;
        count -= read;
    }

    return value;
}

int plm_dma_buffer_peek(plm_dma_buffer_t *self, int count) {
    if (!plm_dma_buffer_has(self, count)) {
        return 0;
    }

    uint32_t read_bit_index = fifo_ctrl->read_bit_index;
    int value = 0;

    while (count) {
        int current_byte = self->bytes[read_bit_index >> 3];

        int remaining = 8 - (read_bit_index & 7);         // Remaining bits in byte
        int read = remaining < count ? remaining : count; // Bits in self run
        int shift = remaining - read;
        int mask = (0xff >> (8 - read));

        value = (value << read) | ((current_byte & (mask << shift)) >> shift);

        read_bit_index += read;
        count -= read;
    }

    return value;
}
void plm_dma_buffer_align(plm_dma_buffer_t *self) {
    fifo_ctrl->read_bit_index = ((fifo_ctrl->read_bit_index + 7) >> 3) << 3; // Align to next byte
}
void plm_dma_buffer_skip(plm_dma_buffer_t *self, size_t count) {
    if (plm_dma_buffer_has(self, count)) {
        fifo_ctrl->read_bit_index += count;
    }
}

int plm_dma_buffer_skip_bytes(plm_dma_buffer_t *self, uint8_t v) {
    plm_dma_buffer_align(self);
    int skipped = 0;
    while (plm_dma_buffer_has(self, 8) && self->bytes[fifo_ctrl->read_bit_index >> 3] == v) {
        fifo_ctrl->read_bit_index += 8;
        skipped++;
    }
    return skipped;
}
// -----------------------------------------------------------------------------
// plm_audio implementation

// Based on kjmp2 by Martin J. Fiedler
// http://keyj.emphy.de/kjmp2/

static const int PLM_AUDIO_FRAME_SYNC = 0x7ff;

static const int PLM_AUDIO_MPEG_2_5 = 0x0;
static const int PLM_AUDIO_MPEG_2 = 0x2;
static const int PLM_AUDIO_MPEG_1 = 0x3;

static const int PLM_AUDIO_LAYER_III = 0x1;
static const int PLM_AUDIO_LAYER_II = 0x2;
static const int PLM_AUDIO_LAYER_I = 0x3;

static const int PLM_AUDIO_MODE_STEREO = 0x0;
static const int PLM_AUDIO_MODE_JOINT_STEREO = 0x1;
static const int PLM_AUDIO_MODE_DUAL_CHANNEL = 0x2;
static const int PLM_AUDIO_MODE_MONO = 0x3;

static const unsigned short PLM_AUDIO_SAMPLE_RATE[] = {
    44100, 48000, 32000, 0, // MPEG-1
    22050, 24000, 16000, 0  // MPEG-2
};

static const short PLM_AUDIO_BIT_RATE[] = {
    32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, // MPEG-1
    8,  16, 24, 32, 40, 48, 56,  64,  80,  96,  112, 128, 144, 160  // MPEG-2
};

static const short PLM_AUDIO_BIT_RATE_LAYER_I[] = {
    32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, // MPEG-1
    32, 48, 56, 64,  80,  96,  112, 128, 144, 160, 176, 192, 224, 256  // MPEG-2
};

static const int PLM_AUDIO_SCALEFACTOR_BASE[] = {0x02000000, 0x01965FEA, 0x01428A30};

typedef int32_t intsample_t;
#define MULTDIV 256
#define FLOAT_TO_FIX_2(x) (x * 2)
#define FLOAT_TO_FIX_256(x) ((intsample_t)(x * MULTDIV))

static const intsample_t PLM_AUDIO_SYNTHESIS_WINDOW[] = {
    FLOAT_TO_FIX_2(0.0),      FLOAT_TO_FIX_2(-0.5),     FLOAT_TO_FIX_2(-0.5),     FLOAT_TO_FIX_2(-0.5),
    FLOAT_TO_FIX_2(-0.5),     FLOAT_TO_FIX_2(-0.5),     FLOAT_TO_FIX_2(-0.5),     FLOAT_TO_FIX_2(-1.0),
    FLOAT_TO_FIX_2(-1.0),     FLOAT_TO_FIX_2(-1.0),     FLOAT_TO_FIX_2(-1.0),     FLOAT_TO_FIX_2(-1.5),
    FLOAT_TO_FIX_2(-1.5),     FLOAT_TO_FIX_2(-2.0),     FLOAT_TO_FIX_2(-2.0),     FLOAT_TO_FIX_2(-2.5),
    FLOAT_TO_FIX_2(-2.5),     FLOAT_TO_FIX_2(-3.0),     FLOAT_TO_FIX_2(-3.5),     FLOAT_TO_FIX_2(-3.5),
    FLOAT_TO_FIX_2(-4.0),     FLOAT_TO_FIX_2(-4.5),     FLOAT_TO_FIX_2(-5.0),     FLOAT_TO_FIX_2(-5.5),
    FLOAT_TO_FIX_2(-6.5),     FLOAT_TO_FIX_2(-7.0),     FLOAT_TO_FIX_2(-8.0),     FLOAT_TO_FIX_2(-8.5),
    FLOAT_TO_FIX_2(-9.5),     FLOAT_TO_FIX_2(-10.5),    FLOAT_TO_FIX_2(-12.0),    FLOAT_TO_FIX_2(-13.0),
    FLOAT_TO_FIX_2(-14.5),    FLOAT_TO_FIX_2(-15.5),    FLOAT_TO_FIX_2(-17.5),    FLOAT_TO_FIX_2(-19.0),
    FLOAT_TO_FIX_2(-20.5),    FLOAT_TO_FIX_2(-22.5),    FLOAT_TO_FIX_2(-24.5),    FLOAT_TO_FIX_2(-26.5),
    FLOAT_TO_FIX_2(-29.0),    FLOAT_TO_FIX_2(-31.5),    FLOAT_TO_FIX_2(-34.0),    FLOAT_TO_FIX_2(-36.5),
    FLOAT_TO_FIX_2(-39.5),    FLOAT_TO_FIX_2(-42.5),    FLOAT_TO_FIX_2(-45.5),    FLOAT_TO_FIX_2(-48.5),
    FLOAT_TO_FIX_2(-52.0),    FLOAT_TO_FIX_2(-55.5),    FLOAT_TO_FIX_2(-58.5),    FLOAT_TO_FIX_2(-62.5),
    FLOAT_TO_FIX_2(-66.0),    FLOAT_TO_FIX_2(-69.5),    FLOAT_TO_FIX_2(-73.5),    FLOAT_TO_FIX_2(-77.0),
    FLOAT_TO_FIX_2(-80.5),    FLOAT_TO_FIX_2(-84.5),    FLOAT_TO_FIX_2(-88.0),    FLOAT_TO_FIX_2(-91.5),
    FLOAT_TO_FIX_2(-95.0),    FLOAT_TO_FIX_2(-98.0),    FLOAT_TO_FIX_2(-101.0),   FLOAT_TO_FIX_2(-104.0),
    FLOAT_TO_FIX_2(106.5),    FLOAT_TO_FIX_2(109.0),    FLOAT_TO_FIX_2(111.0),    FLOAT_TO_FIX_2(112.5),
    FLOAT_TO_FIX_2(113.5),    FLOAT_TO_FIX_2(114.0),    FLOAT_TO_FIX_2(114.0),    FLOAT_TO_FIX_2(113.5),
    FLOAT_TO_FIX_2(112.0),    FLOAT_TO_FIX_2(110.5),    FLOAT_TO_FIX_2(107.5),    FLOAT_TO_FIX_2(104.0),
    FLOAT_TO_FIX_2(100.0),    FLOAT_TO_FIX_2(94.5),     FLOAT_TO_FIX_2(88.5),     FLOAT_TO_FIX_2(81.5),
    FLOAT_TO_FIX_2(73.0),     FLOAT_TO_FIX_2(63.5),     FLOAT_TO_FIX_2(53.0),     FLOAT_TO_FIX_2(41.5),
    FLOAT_TO_FIX_2(28.5),     FLOAT_TO_FIX_2(14.5),     FLOAT_TO_FIX_2(-1.0),     FLOAT_TO_FIX_2(-18.0),
    FLOAT_TO_FIX_2(-36.0),    FLOAT_TO_FIX_2(-55.5),    FLOAT_TO_FIX_2(-76.5),    FLOAT_TO_FIX_2(-98.5),
    FLOAT_TO_FIX_2(-122.0),   FLOAT_TO_FIX_2(-147.0),   FLOAT_TO_FIX_2(-173.5),   FLOAT_TO_FIX_2(-200.5),
    FLOAT_TO_FIX_2(-229.5),   FLOAT_TO_FIX_2(-259.5),   FLOAT_TO_FIX_2(-290.5),   FLOAT_TO_FIX_2(-322.5),
    FLOAT_TO_FIX_2(-355.5),   FLOAT_TO_FIX_2(-389.5),   FLOAT_TO_FIX_2(-424.0),   FLOAT_TO_FIX_2(-459.5),
    FLOAT_TO_FIX_2(-495.5),   FLOAT_TO_FIX_2(-532.0),   FLOAT_TO_FIX_2(-568.5),   FLOAT_TO_FIX_2(-605.0),
    FLOAT_TO_FIX_2(-641.5),   FLOAT_TO_FIX_2(-678.0),   FLOAT_TO_FIX_2(-714.0),   FLOAT_TO_FIX_2(-749.0),
    FLOAT_TO_FIX_2(-783.5),   FLOAT_TO_FIX_2(-817.0),   FLOAT_TO_FIX_2(-849.0),   FLOAT_TO_FIX_2(-879.5),
    FLOAT_TO_FIX_2(-908.5),   FLOAT_TO_FIX_2(-935.0),   FLOAT_TO_FIX_2(-959.5),   FLOAT_TO_FIX_2(-981.0),
    FLOAT_TO_FIX_2(-1000.5),  FLOAT_TO_FIX_2(-1016.0),  FLOAT_TO_FIX_2(-1028.5),  FLOAT_TO_FIX_2(-1037.5),
    FLOAT_TO_FIX_2(-1042.5),  FLOAT_TO_FIX_2(-1043.5),  FLOAT_TO_FIX_2(-1040.0),  FLOAT_TO_FIX_2(-1031.5),
    FLOAT_TO_FIX_2(1018.5),   FLOAT_TO_FIX_2(1000.0),   FLOAT_TO_FIX_2(976.0),    FLOAT_TO_FIX_2(946.5),
    FLOAT_TO_FIX_2(911.0),    FLOAT_TO_FIX_2(869.5),    FLOAT_TO_FIX_2(822.0),    FLOAT_TO_FIX_2(767.5),
    FLOAT_TO_FIX_2(707.0),    FLOAT_TO_FIX_2(640.0),    FLOAT_TO_FIX_2(565.5),    FLOAT_TO_FIX_2(485.0),
    FLOAT_TO_FIX_2(397.0),    FLOAT_TO_FIX_2(302.5),    FLOAT_TO_FIX_2(201.0),    FLOAT_TO_FIX_2(92.5),
    FLOAT_TO_FIX_2(-22.5),    FLOAT_TO_FIX_2(-144.0),   FLOAT_TO_FIX_2(-272.5),   FLOAT_TO_FIX_2(-407.0),
    FLOAT_TO_FIX_2(-547.5),   FLOAT_TO_FIX_2(-694.0),   FLOAT_TO_FIX_2(-846.0),   FLOAT_TO_FIX_2(-1003.0),
    FLOAT_TO_FIX_2(-1165.0),  FLOAT_TO_FIX_2(-1331.5),  FLOAT_TO_FIX_2(-1502.0),  FLOAT_TO_FIX_2(-1675.5),
    FLOAT_TO_FIX_2(-1852.5),  FLOAT_TO_FIX_2(-2031.5),  FLOAT_TO_FIX_2(-2212.5),  FLOAT_TO_FIX_2(-2394.0),
    FLOAT_TO_FIX_2(-2576.5),  FLOAT_TO_FIX_2(-2758.5),  FLOAT_TO_FIX_2(-2939.5),  FLOAT_TO_FIX_2(-3118.5),
    FLOAT_TO_FIX_2(-3294.5),  FLOAT_TO_FIX_2(-3467.5),  FLOAT_TO_FIX_2(-3635.5),  FLOAT_TO_FIX_2(-3798.5),
    FLOAT_TO_FIX_2(-3955.0),  FLOAT_TO_FIX_2(-4104.5),  FLOAT_TO_FIX_2(-4245.5),  FLOAT_TO_FIX_2(-4377.5),
    FLOAT_TO_FIX_2(-4499.0),  FLOAT_TO_FIX_2(-4609.5),  FLOAT_TO_FIX_2(-4708.0),  FLOAT_TO_FIX_2(-4792.5),
    FLOAT_TO_FIX_2(-4863.5),  FLOAT_TO_FIX_2(-4919.0),  FLOAT_TO_FIX_2(-4958.0),  FLOAT_TO_FIX_2(-4979.5),
    FLOAT_TO_FIX_2(-4983.0),  FLOAT_TO_FIX_2(-4967.5),  FLOAT_TO_FIX_2(-4931.5),  FLOAT_TO_FIX_2(-4875.0),
    FLOAT_TO_FIX_2(-4796.0),  FLOAT_TO_FIX_2(-4694.5),  FLOAT_TO_FIX_2(-4569.5),  FLOAT_TO_FIX_2(-4420.0),
    FLOAT_TO_FIX_2(-4246.0),  FLOAT_TO_FIX_2(-4046.0),  FLOAT_TO_FIX_2(-3820.0),  FLOAT_TO_FIX_2(-3567.0),
    FLOAT_TO_FIX_2(3287.0),   FLOAT_TO_FIX_2(2979.5),   FLOAT_TO_FIX_2(2644.0),   FLOAT_TO_FIX_2(2280.5),
    FLOAT_TO_FIX_2(1888.0),   FLOAT_TO_FIX_2(1467.5),   FLOAT_TO_FIX_2(1018.5),   FLOAT_TO_FIX_2(541.0),
    FLOAT_TO_FIX_2(35.0),     FLOAT_TO_FIX_2(-499.0),   FLOAT_TO_FIX_2(-1061.0),  FLOAT_TO_FIX_2(-1650.0),
    FLOAT_TO_FIX_2(-2266.5),  FLOAT_TO_FIX_2(-2909.0),  FLOAT_TO_FIX_2(-3577.0),  FLOAT_TO_FIX_2(-4270.0),
    FLOAT_TO_FIX_2(-4987.5),  FLOAT_TO_FIX_2(-5727.5),  FLOAT_TO_FIX_2(-6490.0),  FLOAT_TO_FIX_2(-7274.0),
    FLOAT_TO_FIX_2(-8077.5),  FLOAT_TO_FIX_2(-8899.5),  FLOAT_TO_FIX_2(-9739.0),  FLOAT_TO_FIX_2(-10594.5),
    FLOAT_TO_FIX_2(-11464.5), FLOAT_TO_FIX_2(-12347.0), FLOAT_TO_FIX_2(-13241.0), FLOAT_TO_FIX_2(-14144.5),
    FLOAT_TO_FIX_2(-15056.0), FLOAT_TO_FIX_2(-15973.5), FLOAT_TO_FIX_2(-16895.5), FLOAT_TO_FIX_2(-17820.0),
    FLOAT_TO_FIX_2(-18744.5), FLOAT_TO_FIX_2(-19668.0), FLOAT_TO_FIX_2(-20588.0), FLOAT_TO_FIX_2(-21503.0),
    FLOAT_TO_FIX_2(-22410.5), FLOAT_TO_FIX_2(-23308.5), FLOAT_TO_FIX_2(-24195.0), FLOAT_TO_FIX_2(-25068.5),
    FLOAT_TO_FIX_2(-25926.5), FLOAT_TO_FIX_2(-26767.0), FLOAT_TO_FIX_2(-27589.0), FLOAT_TO_FIX_2(-28389.0),
    FLOAT_TO_FIX_2(-29166.5), FLOAT_TO_FIX_2(-29919.0), FLOAT_TO_FIX_2(-30644.5), FLOAT_TO_FIX_2(-31342.0),
    FLOAT_TO_FIX_2(-32009.5), FLOAT_TO_FIX_2(-32645.0), FLOAT_TO_FIX_2(-33247.0), FLOAT_TO_FIX_2(-33814.5),
    FLOAT_TO_FIX_2(-34346.0), FLOAT_TO_FIX_2(-34839.5), FLOAT_TO_FIX_2(-35295.0), FLOAT_TO_FIX_2(-35710.0),
    FLOAT_TO_FIX_2(-36084.5), FLOAT_TO_FIX_2(-36417.5), FLOAT_TO_FIX_2(-36707.5), FLOAT_TO_FIX_2(-36954.0),
    FLOAT_TO_FIX_2(-37156.5), FLOAT_TO_FIX_2(-37315.0), FLOAT_TO_FIX_2(-37428.0), FLOAT_TO_FIX_2(-37496.0),
    FLOAT_TO_FIX_2(37519.0),  FLOAT_TO_FIX_2(37496.0),  FLOAT_TO_FIX_2(37428.0),  FLOAT_TO_FIX_2(37315.0),
    FLOAT_TO_FIX_2(37156.5),  FLOAT_TO_FIX_2(36954.0),  FLOAT_TO_FIX_2(36707.5),  FLOAT_TO_FIX_2(36417.5),
    FLOAT_TO_FIX_2(36084.5),  FLOAT_TO_FIX_2(35710.0),  FLOAT_TO_FIX_2(35295.0),  FLOAT_TO_FIX_2(34839.5),
    FLOAT_TO_FIX_2(34346.0),  FLOAT_TO_FIX_2(33814.5),  FLOAT_TO_FIX_2(33247.0),  FLOAT_TO_FIX_2(32645.0),
    FLOAT_TO_FIX_2(32009.5),  FLOAT_TO_FIX_2(31342.0),  FLOAT_TO_FIX_2(30644.5),  FLOAT_TO_FIX_2(29919.0),
    FLOAT_TO_FIX_2(29166.5),  FLOAT_TO_FIX_2(28389.0),  FLOAT_TO_FIX_2(27589.0),  FLOAT_TO_FIX_2(26767.0),
    FLOAT_TO_FIX_2(25926.5),  FLOAT_TO_FIX_2(25068.5),  FLOAT_TO_FIX_2(24195.0),  FLOAT_TO_FIX_2(23308.5),
    FLOAT_TO_FIX_2(22410.5),  FLOAT_TO_FIX_2(21503.0),  FLOAT_TO_FIX_2(20588.0),  FLOAT_TO_FIX_2(19668.0),
    FLOAT_TO_FIX_2(18744.5),  FLOAT_TO_FIX_2(17820.0),  FLOAT_TO_FIX_2(16895.5),  FLOAT_TO_FIX_2(15973.5),
    FLOAT_TO_FIX_2(15056.0),  FLOAT_TO_FIX_2(14144.5),  FLOAT_TO_FIX_2(13241.0),  FLOAT_TO_FIX_2(12347.0),
    FLOAT_TO_FIX_2(11464.5),  FLOAT_TO_FIX_2(10594.5),  FLOAT_TO_FIX_2(9739.0),   FLOAT_TO_FIX_2(8899.5),
    FLOAT_TO_FIX_2(8077.5),   FLOAT_TO_FIX_2(7274.0),   FLOAT_TO_FIX_2(6490.0),   FLOAT_TO_FIX_2(5727.5),
    FLOAT_TO_FIX_2(4987.5),   FLOAT_TO_FIX_2(4270.0),   FLOAT_TO_FIX_2(3577.0),   FLOAT_TO_FIX_2(2909.0),
    FLOAT_TO_FIX_2(2266.5),   FLOAT_TO_FIX_2(1650.0),   FLOAT_TO_FIX_2(1061.0),   FLOAT_TO_FIX_2(499.0),
    FLOAT_TO_FIX_2(-35.0),    FLOAT_TO_FIX_2(-541.0),   FLOAT_TO_FIX_2(-1018.5),  FLOAT_TO_FIX_2(-1467.5),
    FLOAT_TO_FIX_2(-1888.0),  FLOAT_TO_FIX_2(-2280.5),  FLOAT_TO_FIX_2(-2644.0),  FLOAT_TO_FIX_2(-2979.5),
    FLOAT_TO_FIX_2(3287.0),   FLOAT_TO_FIX_2(3567.0),   FLOAT_TO_FIX_2(3820.0),   FLOAT_TO_FIX_2(4046.0),
    FLOAT_TO_FIX_2(4246.0),   FLOAT_TO_FIX_2(4420.0),   FLOAT_TO_FIX_2(4569.5),   FLOAT_TO_FIX_2(4694.5),
    FLOAT_TO_FIX_2(4796.0),   FLOAT_TO_FIX_2(4875.0),   FLOAT_TO_FIX_2(4931.5),   FLOAT_TO_FIX_2(4967.5),
    FLOAT_TO_FIX_2(4983.0),   FLOAT_TO_FIX_2(4979.5),   FLOAT_TO_FIX_2(4958.0),   FLOAT_TO_FIX_2(4919.0),
    FLOAT_TO_FIX_2(4863.5),   FLOAT_TO_FIX_2(4792.5),   FLOAT_TO_FIX_2(4708.0),   FLOAT_TO_FIX_2(4609.5),
    FLOAT_TO_FIX_2(4499.0),   FLOAT_TO_FIX_2(4377.5),   FLOAT_TO_FIX_2(4245.5),   FLOAT_TO_FIX_2(4104.5),
    FLOAT_TO_FIX_2(3955.0),   FLOAT_TO_FIX_2(3798.5),   FLOAT_TO_FIX_2(3635.5),   FLOAT_TO_FIX_2(3467.5),
    FLOAT_TO_FIX_2(3294.5),   FLOAT_TO_FIX_2(3118.5),   FLOAT_TO_FIX_2(2939.5),   FLOAT_TO_FIX_2(2758.5),
    FLOAT_TO_FIX_2(2576.5),   FLOAT_TO_FIX_2(2394.0),   FLOAT_TO_FIX_2(2212.5),   FLOAT_TO_FIX_2(2031.5),
    FLOAT_TO_FIX_2(1852.5),   FLOAT_TO_FIX_2(1675.5),   FLOAT_TO_FIX_2(1502.0),   FLOAT_TO_FIX_2(1331.5),
    FLOAT_TO_FIX_2(1165.0),   FLOAT_TO_FIX_2(1003.0),   FLOAT_TO_FIX_2(846.0),    FLOAT_TO_FIX_2(694.0),
    FLOAT_TO_FIX_2(547.5),    FLOAT_TO_FIX_2(407.0),    FLOAT_TO_FIX_2(272.5),    FLOAT_TO_FIX_2(144.0),
    FLOAT_TO_FIX_2(22.5),     FLOAT_TO_FIX_2(-92.5),    FLOAT_TO_FIX_2(-201.0),   FLOAT_TO_FIX_2(-302.5),
    FLOAT_TO_FIX_2(-397.0),   FLOAT_TO_FIX_2(-485.0),   FLOAT_TO_FIX_2(-565.5),   FLOAT_TO_FIX_2(-640.0),
    FLOAT_TO_FIX_2(-707.0),   FLOAT_TO_FIX_2(-767.5),   FLOAT_TO_FIX_2(-822.0),   FLOAT_TO_FIX_2(-869.5),
    FLOAT_TO_FIX_2(-911.0),   FLOAT_TO_FIX_2(-946.5),   FLOAT_TO_FIX_2(-976.0),   FLOAT_TO_FIX_2(-1000.0),
    FLOAT_TO_FIX_2(1018.5),   FLOAT_TO_FIX_2(1031.5),   FLOAT_TO_FIX_2(1040.0),   FLOAT_TO_FIX_2(1043.5),
    FLOAT_TO_FIX_2(1042.5),   FLOAT_TO_FIX_2(1037.5),   FLOAT_TO_FIX_2(1028.5),   FLOAT_TO_FIX_2(1016.0),
    FLOAT_TO_FIX_2(1000.5),   FLOAT_TO_FIX_2(981.0),    FLOAT_TO_FIX_2(959.5),    FLOAT_TO_FIX_2(935.0),
    FLOAT_TO_FIX_2(908.5),    FLOAT_TO_FIX_2(879.5),    FLOAT_TO_FIX_2(849.0),    FLOAT_TO_FIX_2(817.0),
    FLOAT_TO_FIX_2(783.5),    FLOAT_TO_FIX_2(749.0),    FLOAT_TO_FIX_2(714.0),    FLOAT_TO_FIX_2(678.0),
    FLOAT_TO_FIX_2(641.5),    FLOAT_TO_FIX_2(605.0),    FLOAT_TO_FIX_2(568.5),    FLOAT_TO_FIX_2(532.0),
    FLOAT_TO_FIX_2(495.5),    FLOAT_TO_FIX_2(459.5),    FLOAT_TO_FIX_2(424.0),    FLOAT_TO_FIX_2(389.5),
    FLOAT_TO_FIX_2(355.5),    FLOAT_TO_FIX_2(322.5),    FLOAT_TO_FIX_2(290.5),    FLOAT_TO_FIX_2(259.5),
    FLOAT_TO_FIX_2(229.5),    FLOAT_TO_FIX_2(200.5),    FLOAT_TO_FIX_2(173.5),    FLOAT_TO_FIX_2(147.0),
    FLOAT_TO_FIX_2(122.0),    FLOAT_TO_FIX_2(98.5),     FLOAT_TO_FIX_2(76.5),     FLOAT_TO_FIX_2(55.5),
    FLOAT_TO_FIX_2(36.0),     FLOAT_TO_FIX_2(18.0),     FLOAT_TO_FIX_2(1.0),      FLOAT_TO_FIX_2(-14.5),
    FLOAT_TO_FIX_2(-28.5),    FLOAT_TO_FIX_2(-41.5),    FLOAT_TO_FIX_2(-53.0),    FLOAT_TO_FIX_2(-63.5),
    FLOAT_TO_FIX_2(-73.0),    FLOAT_TO_FIX_2(-81.5),    FLOAT_TO_FIX_2(-88.5),    FLOAT_TO_FIX_2(-94.5),
    FLOAT_TO_FIX_2(-100.0),   FLOAT_TO_FIX_2(-104.0),   FLOAT_TO_FIX_2(-107.5),   FLOAT_TO_FIX_2(-110.5),
    FLOAT_TO_FIX_2(-112.0),   FLOAT_TO_FIX_2(-113.5),   FLOAT_TO_FIX_2(-114.0),   FLOAT_TO_FIX_2(-114.0),
    FLOAT_TO_FIX_2(-113.5),   FLOAT_TO_FIX_2(-112.5),   FLOAT_TO_FIX_2(-111.0),   FLOAT_TO_FIX_2(-109.0),
    FLOAT_TO_FIX_2(106.5),    FLOAT_TO_FIX_2(104.0),    FLOAT_TO_FIX_2(101.0),    FLOAT_TO_FIX_2(98.0),
    FLOAT_TO_FIX_2(95.0),     FLOAT_TO_FIX_2(91.5),     FLOAT_TO_FIX_2(88.0),     FLOAT_TO_FIX_2(84.5),
    FLOAT_TO_FIX_2(80.5),     FLOAT_TO_FIX_2(77.0),     FLOAT_TO_FIX_2(73.5),     FLOAT_TO_FIX_2(69.5),
    FLOAT_TO_FIX_2(66.0),     FLOAT_TO_FIX_2(62.5),     FLOAT_TO_FIX_2(58.5),     FLOAT_TO_FIX_2(55.5),
    FLOAT_TO_FIX_2(52.0),     FLOAT_TO_FIX_2(48.5),     FLOAT_TO_FIX_2(45.5),     FLOAT_TO_FIX_2(42.5),
    FLOAT_TO_FIX_2(39.5),     FLOAT_TO_FIX_2(36.5),     FLOAT_TO_FIX_2(34.0),     FLOAT_TO_FIX_2(31.5),
    FLOAT_TO_FIX_2(29.0),     FLOAT_TO_FIX_2(26.5),     FLOAT_TO_FIX_2(24.5),     FLOAT_TO_FIX_2(22.5),
    FLOAT_TO_FIX_2(20.5),     FLOAT_TO_FIX_2(19.0),     FLOAT_TO_FIX_2(17.5),     FLOAT_TO_FIX_2(15.5),
    FLOAT_TO_FIX_2(14.5),     FLOAT_TO_FIX_2(13.0),     FLOAT_TO_FIX_2(12.0),     FLOAT_TO_FIX_2(10.5),
    FLOAT_TO_FIX_2(9.5),      FLOAT_TO_FIX_2(8.5),      FLOAT_TO_FIX_2(8.0),      FLOAT_TO_FIX_2(7.0),
    FLOAT_TO_FIX_2(6.5),      FLOAT_TO_FIX_2(5.5),      FLOAT_TO_FIX_2(5.0),      FLOAT_TO_FIX_2(4.5),
    FLOAT_TO_FIX_2(4.0),      FLOAT_TO_FIX_2(3.5),      FLOAT_TO_FIX_2(3.5),      FLOAT_TO_FIX_2(3.0),
    FLOAT_TO_FIX_2(2.5),      FLOAT_TO_FIX_2(2.5),      FLOAT_TO_FIX_2(2.0),      FLOAT_TO_FIX_2(2.0),
    FLOAT_TO_FIX_2(1.5),      FLOAT_TO_FIX_2(1.5),      FLOAT_TO_FIX_2(1.0),      FLOAT_TO_FIX_2(1.0),
    FLOAT_TO_FIX_2(1.0),      FLOAT_TO_FIX_2(1.0),      FLOAT_TO_FIX_2(0.5),      FLOAT_TO_FIX_2(0.5),
    FLOAT_TO_FIX_2(0.5),      FLOAT_TO_FIX_2(0.5),      FLOAT_TO_FIX_2(0.5),      FLOAT_TO_FIX_2(0.5)};

// Quantizer lookup, step 1: bitrate classes
static const uint8_t PLM_AUDIO_QUANT_LUT_STEP_1[2][16] = {
    // 32, 48, 56, 64, 80, 96,112,128,160,192,224,256,320,384 <- bitrate
    {0, 0, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2}, // mono
    // 16, 24, 28, 32, 40, 48, 56, 64, 80, 96,112,128,160,192 <- bitrate / chan
    {0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 2} // stereo
};

// Quantizer lookup, step 2: bitrate class, sample rate -> B2 table idx, sblimit
#define PLM_AUDIO_QUANT_TAB_A (27 | 64) // Table 3-B.2a: high-rate, sblimit = 27
#define PLM_AUDIO_QUANT_TAB_B (30 | 64) // Table 3-B.2b: high-rate, sblimit = 30
#define PLM_AUDIO_QUANT_TAB_C 8         // Table 3-B.2c:  low-rate, sblimit =  8
#define PLM_AUDIO_QUANT_TAB_D 12        // Table 3-B.2d:  low-rate, sblimit = 12

// clang-format off
static const uint8_t QUANT_LUT_STEP_2[3][3] = {
	//44.1 kHz,              48 kHz,                32 kHz
	{ PLM_AUDIO_QUANT_TAB_C, PLM_AUDIO_QUANT_TAB_C, PLM_AUDIO_QUANT_TAB_D }, // 32 - 48 kbit/sec/ch
	{ PLM_AUDIO_QUANT_TAB_A, PLM_AUDIO_QUANT_TAB_A, PLM_AUDIO_QUANT_TAB_A }, // 56 - 80 kbit/sec/ch
	{ PLM_AUDIO_QUANT_TAB_B, PLM_AUDIO_QUANT_TAB_A, PLM_AUDIO_QUANT_TAB_B }  // 96+	 kbit/sec/ch
};

// Quantizer lookup, step 3: B2 table, subband -> nbal, row index
// (upper 4 bits: nbal, lower 4 bits: row index)
static const uint8_t PLM_AUDIO_QUANT_LUT_STEP_3[3][32] = {
	// Low-rate table (3-B.2c and 3-B.2d)
	{
		0x44,0x44,
		0x34,0x34,0x34,0x34,0x34,0x34,0x34,0x34,0x34,0x34
	},
	// High-rate table (3-B.2a and 3-B.2b)
	{
		0x43,0x43,0x43,
		0x42,0x42,0x42,0x42,0x42,0x42,0x42,0x42,
		0x31,0x31,0x31,0x31,0x31,0x31,0x31,0x31,0x31,0x31,0x31,0x31,
		0x20,0x20,0x20,0x20,0x20,0x20,0x20
	},
	// MPEG-2 LSR table (B.2 in ISO 13818-3)
	{
		0x45,0x45,0x45,0x45,
		0x34,0x34,0x34,0x34,0x34,0x34,0x34,
		0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,
		0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24
	}
};

// Quantizer lookup, step 4: table row, allocation[] value -> quant table index
static const uint8_t PLM_AUDIO_QUANT_LUT_STEP_4[6][16] = {
	{ 0, 1, 2, 17 },
	{ 0, 1, 2,  3, 4, 5, 6, 17 },
	{ 0, 1, 2,  3, 4, 5, 6,  7,  8,  9, 10, 11, 12, 13, 14, 17 },
	{ 0, 1, 3,  5, 6, 7, 8,  9, 10, 11, 12, 13, 14, 15, 16, 17 },
	{ 0, 1, 2,  4, 5, 6, 7,  8,  9, 10, 11, 12, 13, 14, 15, 17 },
	{ 0, 1, 2,  3, 4, 5, 6,  7,  8,  9, 10, 11, 12, 13, 14, 15 }
};

typedef struct plm_quantizer_spec_t {
	unsigned short levels;
	unsigned char group;
	unsigned char bits;
} plm_quantizer_spec_t;

static const plm_quantizer_spec_t PLM_AUDIO_QUANT_TAB[] = {
	{     3, 1,  5 },  //  1
	{     5, 1,  7 },  //  2
	{     7, 0,  3 },  //  3
	{     9, 1, 10 },  //  4
	{    15, 0,  4 },  //  5
	{    31, 0,  5 },  //  6
	{    63, 0,  6 },  //  7
	{   127, 0,  7 },  //  8
	{   255, 0,  8 },  //  9
	{   511, 0,  9 },  // 10
	{  1023, 0, 10 },  // 11
	{  2047, 0, 11 },  // 12
	{  4095, 0, 12 },  // 13
	{  8191, 0, 13 },  // 14
	{ 16383, 0, 14 },  // 15
	{ 32767, 0, 15 },  // 16
	{ 65535, 0, 16 }   // 17
};

static const plm_quantizer_spec_t PLM_AUDIO_LAYER_I_QUANT_TAB[] = {
	{     3, 0,  2 },  //  1
	{     7, 0,  3 },  //  2
	{    15, 0,  4 },  //  3
	{    31, 0,  5 },  //  4
	{    63, 0,  6 },  //  5
	{   127, 0,  7 },  //  6
	{   255, 0,  8 },  //  7
	{   511, 0,  9 },  //  8
	{  1023, 0, 10 },  //  9
	{  2047, 0, 11 },  // 10
	{  4095, 0, 12 },  // 11
	{  8191, 0, 13 },  // 12
	{ 16383, 0, 14 },  // 13
	{ 32767, 0, 15 }   // 14
};
// clang-format on

// #define SOFT_CONVOLVE

struct plm_audio_t {
    int32_t time;
    int samples_decoded;
    int samplerate_index;
    int bitrate_index;
    int version;
    int layer;
    int mode;
    int bound;
    int v_pos;
    int next_frame_data_size;
    int samples_per_frame;
    int has_header;

    plm_dma_buffer_t *buffer;

    const plm_quantizer_spec_t *allocation[2][32];
    uint8_t scale_factor_info[2][32];
    int scale_factor[2][32][3];
    int sample[2][32][3];

    plm_samples_t samples;
    intsample_t V[2][1024];
#ifdef SOFT_CONVOLVE
    intsample_t D[1024];
    intsample_t U[32];
#endif
};

int plm_audio_find_frame_sync(plm_audio_t *self);
int plm_audio_decode_header(plm_audio_t *self);
void plm_audio_decode_frame(plm_audio_t *self);
void plm_audio_decode_layer_i_frame(plm_audio_t *self);
void plm_audio_decode_layer_ii_frame(plm_audio_t *self);
const plm_quantizer_spec_t *plm_audio_read_allocation(plm_audio_t *self, int sb, int tab3);
void plm_audio_read_samples(plm_audio_t *self, int ch, int sb, int part);
void plm_audio_read_layer_i_sample(plm_audio_t *self, int ch, int sb);
void plm_audio_synthesize_sample(plm_audio_t *self, int ss, int *out_pos);
void plm_audio_idct36(int s[32][3], int ss, intsample_t *d, int dp);

plm_audio_t *plm_audio_create_with_buffer(plm_dma_buffer_t *buffer) {
    static plm_audio_t instance_audio;
    plm_audio_t *self = &instance_audio;
    memset(self, 0, sizeof(plm_audio_t));

    self->samples.count = PLM_AUDIO_SAMPLES_PER_FRAME;
    self->samples_per_frame = PLM_AUDIO_SAMPLES_PER_FRAME;
    self->buffer = buffer;
    self->samplerate_index = 3; // Indicates 0

#ifdef SOFT_CONVOLVE
    memcpy(self->D, PLM_AUDIO_SYNTHESIS_WINDOW, 512 * sizeof(intsample_t));
    memcpy(self->D + 512, PLM_AUDIO_SYNTHESIS_WINDOW, 512 * sizeof(intsample_t));
#endif
    // Attempt to decode first header
    self->next_frame_data_size = plm_audio_decode_header(self);

    return self;
}

plm_samples_t *plm_audio_decode(plm_audio_t *self) {
    // Do we have at least enough information to decode the frame header?
    if (!self->next_frame_data_size) {
        if (!plm_dma_buffer_has(self->buffer, 48)) {
            return NULL;
        }
        self->next_frame_data_size = plm_audio_decode_header(self);
    }

    if (self->next_frame_data_size == 0 ||
        !plm_dma_buffer_has(self->buffer, self->next_frame_data_size << 3)) {
        return NULL;
    }

    // To avoid accidental detection of frame headers inside of superfluous
    // data, we keep note here on the amount of data we should skip
    int bit_index_next_frame_header = fifo_ctrl->read_bit_index + (self->next_frame_data_size << 3);

    plm_audio_decode_frame(self);

    if (fifo_ctrl->read_bit_index < bit_index_next_frame_header) {
        plm_dma_buffer_skip(self->buffer, bit_index_next_frame_header - fifo_ctrl->read_bit_index);
    }

    self->next_frame_data_size = 0;

    self->samples.time = self->time;

    self->samples.count = self->samples_per_frame;
    self->samples_decoded += self->samples_per_frame;
    self->time = self->samples_decoded / PLM_AUDIO_SAMPLE_RATE[self->samplerate_index];

    return &self->samples;
}

int plm_audio_find_frame_sync(plm_audio_t *self) {
    size_t i;
    for (i = fifo_ctrl->read_bit_index >> 3; i < fifo_ctrl->write_byte_index - 1; i++) {
        if (
            // Ensure first 8 bytes of sync word are set
            self->buffer->bytes[i] == 0xFF &&
            // Ensure next 4 bytes of sync words are set,
            // MPEG ID == 1 and Layer either 1 or 2
            (self->buffer->bytes[i + 1] & 0xFC) == 0xFC &&
            // Ensure layer != 0
            (self->buffer->bytes[i + 1] & 0x06) != 0x00 &&
            // Ensure bitrate index != 0xf
            (self->buffer->bytes[i + 2] & 0xF0) != 0xF0 &&
            // Ensure sampling frequency != 3
            (self->buffer->bytes[i + 2] & 0x0C) != 0x0C) {
            fifo_ctrl->read_bit_index = ((i + 1) << 3) + 3;
            return TRUE;
        }
    }
    fifo_ctrl->read_bit_index = (i + 1) << 3;
    return FALSE;
}

int plm_audio_decode_header(plm_audio_t *self) {
    if (!plm_dma_buffer_has(self->buffer, 48)) {
        return 0;
    }

    plm_dma_buffer_skip_bytes(self->buffer, 0x00);
    int sync = plm_dma_buffer_read(self->buffer, 11);

    // Attempt to resync if no syncword was found. This sucks balls. The MPEG
    // audio stream contains a syncword just before every frame (11 bits set to
    // 1). However, this syncword is not guaranteed to not occur elsewhere in
    // the stream. So, if we have to resync, we also have to check if the header
    // (samplerate, bitrate) differs from the one we had before. This all
    // may still lead to garbage data being decoded :/

    if (sync != PLM_AUDIO_FRAME_SYNC && !plm_audio_find_frame_sync(self)) {
        return 0;
    }

    // prefix with 0xE0 for first F nibble in MPEG1 audio header and MPEG ID
    fifo_ctrl->mpeg_audio_header = 0xE00000 | plm_dma_buffer_peek(self->buffer, 8 + 8 + 5);
    self->version = plm_dma_buffer_read(self->buffer, 2);
    self->layer = plm_dma_buffer_read(self->buffer, 2);
    int hasCRC = !plm_dma_buffer_read(self->buffer, 1);

    if (self->version != PLM_AUDIO_MPEG_1 ||
        (self->layer != PLM_AUDIO_LAYER_I && self->layer != PLM_AUDIO_LAYER_II)) {
        return 0;
    }

    int bitrate_index = plm_dma_buffer_read(self->buffer, 4) - 1;
    if (bitrate_index < 0 || bitrate_index > 13) {
        return 0;
    }

    int samplerate_index = plm_dma_buffer_read(self->buffer, 2);
    if (samplerate_index == 3) {
        return 0;
    }

    int padding = plm_dma_buffer_read(self->buffer, 1);
    plm_dma_buffer_skip(self->buffer, 1); // f_private
    int mode = plm_dma_buffer_read(self->buffer, 2);

    // If we already have a header, make sure the samplerate, bitrate and mode
    // are still the same, otherwise we might have missed sync.
    if (self->has_header &&
        (self->bitrate_index != bitrate_index || self->samplerate_index != samplerate_index)) {
        return 0;
    }

    self->bitrate_index = bitrate_index;
    self->samplerate_index = samplerate_index;
    self->mode = mode;
    self->has_header = TRUE;

    // Parse the mode_extension, set up the stereo bound
    if (mode == PLM_AUDIO_MODE_JOINT_STEREO) {
        self->bound = (plm_dma_buffer_read(self->buffer, 2) + 1) << 2;
    } else {
        plm_dma_buffer_skip(self->buffer, 2);
        self->bound = (mode == PLM_AUDIO_MODE_MONO) ? 0 : 32;
    }

    // Discard the last 4 bits of the header and the CRC value, if present
    plm_dma_buffer_skip(self->buffer,
                        4); // copyright(1), original(1), emphasis(2)
    if (hasCRC) {
        plm_dma_buffer_skip(self->buffer, 16);
    }

    // Compute frame size, check if we have enough data to decode the whole
    // frame.
    self->samples_per_frame = (self->layer == PLM_AUDIO_LAYER_I) ? 384 : 1152;
    self->samples.count = self->samples_per_frame;
    int bitrate = self->layer == PLM_AUDIO_LAYER_I ? PLM_AUDIO_BIT_RATE_LAYER_I[self->bitrate_index]
                                                   : PLM_AUDIO_BIT_RATE[self->bitrate_index];
    int samplerate = PLM_AUDIO_SAMPLE_RATE[self->samplerate_index];
    int frame_size = self->layer == PLM_AUDIO_LAYER_I ? (((12000 * bitrate / samplerate) + padding) << 2)
                                                      : ((144000 * bitrate / samplerate) + padding);
    return frame_size - (hasCRC ? 6 : 4);
}

void plm_audio_decode_frame(plm_audio_t *self) {
    if (self->layer == PLM_AUDIO_LAYER_I) {
        plm_audio_decode_layer_i_frame(self);
    } else {
        plm_audio_decode_layer_ii_frame(self);
    }
}

void plm_audio_decode_layer_ii_frame(plm_audio_t *self) {
    // Prepare the quantizer table lookups
    int tab3 = 0;
    int sblimit = 0;

    int tab1 = (self->mode == PLM_AUDIO_MODE_MONO) ? 0 : 1;
    int tab2 = PLM_AUDIO_QUANT_LUT_STEP_1[tab1][self->bitrate_index];
    tab3 = QUANT_LUT_STEP_2[tab2][self->samplerate_index];
    sblimit = tab3 & 63;
    tab3 >>= 6;

    if (self->bound > sblimit) {
        self->bound = sblimit;
    }

    // Read the allocation information
    for (int sb = 0; sb < self->bound; sb++) {
        self->allocation[0][sb] = plm_audio_read_allocation(self, sb, tab3);
        self->allocation[1][sb] = plm_audio_read_allocation(self, sb, tab3);
    }

    for (int sb = self->bound; sb < sblimit; sb++) {
        self->allocation[0][sb] = self->allocation[1][sb] = plm_audio_read_allocation(self, sb, tab3);
    }

    // Read scale factor selector information
    int channels = (self->mode == PLM_AUDIO_MODE_MONO) ? 1 : 2;
    for (int sb = 0; sb < sblimit; sb++) {
        for (int ch = 0; ch < channels; ch++) {
            if (self->allocation[ch][sb]) {
                self->scale_factor_info[ch][sb] = plm_dma_buffer_read(self->buffer, 2);
            }
        }
        if (self->mode == PLM_AUDIO_MODE_MONO) {
            self->scale_factor_info[1][sb] = self->scale_factor_info[0][sb];
        }
    }

    // Read scale factors
    for (int sb = 0; sb < sblimit; sb++) {
        for (int ch = 0; ch < channels; ch++) {
            if (self->allocation[ch][sb]) {
                int *sf = self->scale_factor[ch][sb];
                switch (self->scale_factor_info[ch][sb]) {
                case 0:
                    sf[0] = plm_dma_buffer_read(self->buffer, 6);
                    sf[1] = plm_dma_buffer_read(self->buffer, 6);
                    sf[2] = plm_dma_buffer_read(self->buffer, 6);
                    break;
                case 1:
                    sf[0] = sf[1] = plm_dma_buffer_read(self->buffer, 6);
                    sf[2] = plm_dma_buffer_read(self->buffer, 6);
                    break;
                case 2:
                    sf[0] = sf[1] = sf[2] = plm_dma_buffer_read(self->buffer, 6);
                    break;
                case 3:
                    sf[0] = plm_dma_buffer_read(self->buffer, 6);
                    sf[1] = sf[2] = plm_dma_buffer_read(self->buffer, 6);
                    break;
                }
            }
        }
        if (self->mode == PLM_AUDIO_MODE_MONO) {
            self->scale_factor[1][sb][0] = self->scale_factor[0][sb][0];
            self->scale_factor[1][sb][1] = self->scale_factor[0][sb][1];
            self->scale_factor[1][sb][2] = self->scale_factor[0][sb][2];
        }
    }

    // Coefficient input and reconstruction
    int out_pos = 0;
    for (int part = 0; part < 3; part++) {
        for (int granule = 0; granule < 4; granule++) {

            // Read the samples
            for (int sb = 0; sb < self->bound; sb++) {
                plm_audio_read_samples(self, 0, sb, part);
                plm_audio_read_samples(self, 1, sb, part);
            }
            for (int sb = self->bound; sb < sblimit; sb++) {
                plm_audio_read_samples(self, 0, sb, part);
                self->sample[1][sb][0] = self->sample[0][sb][0];
                self->sample[1][sb][1] = self->sample[0][sb][1];
                self->sample[1][sb][2] = self->sample[0][sb][2];
            }
            for (int sb = sblimit; sb < 32; sb++) {
                self->sample[0][sb][0] = 0;
                self->sample[0][sb][1] = 0;
                self->sample[0][sb][2] = 0;
                self->sample[1][sb][0] = 0;
                self->sample[1][sb][1] = 0;
                self->sample[1][sb][2] = 0;
            }

            // Synthesis loop
            for (int p = 0; p < 3; p++) {
                plm_audio_synthesize_sample(self, p, &out_pos);
            } // End of synthesis sub-block loop

        } // Decoding of the granule finished
    }

    plm_dma_buffer_align(self->buffer);
}

void plm_audio_decode_layer_i_frame(plm_audio_t *self) {
    int sblimit = 32;
    if (self->bound > sblimit) {
        self->bound = sblimit;
    }

    for (int sb = 0; sb < self->bound; sb++) {
        self->allocation[0][sb] = plm_audio_read_allocation(self, sb, -1);
        self->allocation[1][sb] = plm_audio_read_allocation(self, sb, -1);
    }

    for (int sb = self->bound; sb < sblimit; sb++) {
        self->allocation[0][sb] = self->allocation[1][sb] = plm_audio_read_allocation(self, sb, -1);
    }

    int channels = (self->mode == PLM_AUDIO_MODE_MONO) ? 1 : 2;
    for (int sb = 0; sb < sblimit; sb++) {
        for (int ch = 0; ch < channels; ch++) {
            if (self->allocation[ch][sb]) {
                self->scale_factor[ch][sb][0] = plm_dma_buffer_read(self->buffer, 6);
            }
        }
        if (self->mode == PLM_AUDIO_MODE_MONO) {
            self->scale_factor[1][sb][0] = self->scale_factor[0][sb][0];
        }
    }

    int out_pos = 0;
    for (int sample = 0; sample < 12; sample++) {
        for (int sb = 0; sb < self->bound; sb++) {
            plm_audio_read_layer_i_sample(self, 0, sb);
            plm_audio_read_layer_i_sample(self, 1, sb);
        }
        for (int sb = self->bound; sb < sblimit; sb++) {
            plm_audio_read_layer_i_sample(self, 0, sb);
            self->sample[1][sb][0] = self->sample[0][sb][0];
        }

        plm_audio_synthesize_sample(self, 0, &out_pos);
    }

    plm_dma_buffer_align(self->buffer);
}

const plm_quantizer_spec_t *plm_audio_read_allocation(plm_audio_t *self, int sb, int tab3) {
    if (tab3 < 0) {
        int allocation = plm_dma_buffer_read(self->buffer, 4);
        return (allocation && allocation < 15) ? (&PLM_AUDIO_LAYER_I_QUANT_TAB[allocation - 1]) : 0;
    }

    int tab4 = PLM_AUDIO_QUANT_LUT_STEP_3[tab3][sb];
    int qtab = PLM_AUDIO_QUANT_LUT_STEP_4[tab4 & 15][plm_dma_buffer_read(self->buffer, tab4 >> 4)];
    return qtab ? (&PLM_AUDIO_QUANT_TAB[qtab - 1]) : 0;
}

void plm_audio_read_samples(plm_audio_t *self, int ch, int sb, int part) {
    const plm_quantizer_spec_t *q = self->allocation[ch][sb];
    int sf = self->scale_factor[ch][sb][part];
    int *sample = self->sample[ch][sb];
    int val = 0;

    if (!q) {
        // No bits allocated for this subband
        sample[0] = sample[1] = sample[2] = 0;
        return;
    }

    // Resolve scalefactor
    if (sf == 63) {
        sf = 0;
    } else {
        int shift = (sf / 3) | 0;
        sf = (PLM_AUDIO_SCALEFACTOR_BASE[sf % 3] + ((1 << shift) >> 1)) >> shift;
    }

    // Decode samples
    int adj = q->levels;
    if (q->group) {
        // Decode grouped samples
        val = plm_dma_buffer_read(self->buffer, q->bits);
        sample[0] = val % adj;
        val /= adj;
        sample[1] = val % adj;
        sample[2] = val / adj;
    } else {
        // Decode direct samples
        sample[0] = plm_dma_buffer_read(self->buffer, q->bits);
        sample[1] = plm_dma_buffer_read(self->buffer, q->bits);
        sample[2] = plm_dma_buffer_read(self->buffer, q->bits);
    }

    // Postmultiply samples
    int scale = 65536 / (adj + 1);
    adj = ((adj + 1) >> 1) - 1;

    val = (adj - sample[0]) * scale;
    sample[0] = (val * (sf >> 12) + ((val * (sf & 4095) + 2048) >> 12)) >> 12;

    val = (adj - sample[1]) * scale;
    sample[1] = (val * (sf >> 12) + ((val * (sf & 4095) + 2048) >> 12)) >> 12;

    val = (adj - sample[2]) * scale;
    sample[2] = (val * (sf >> 12) + ((val * (sf & 4095) + 2048) >> 12)) >> 12;
}

void plm_audio_read_layer_i_sample(plm_audio_t *self, int ch, int sb) {
    const plm_quantizer_spec_t *q = self->allocation[ch][sb];
    int sf = self->scale_factor[ch][sb][0];
    int val = 0;

    if (!q) {
        self->sample[ch][sb][0] = 0;
        return;
    }

    if (sf == 63) {
        sf = 0;
    } else {
        int shift = (sf / 3) | 0;
        sf = (PLM_AUDIO_SCALEFACTOR_BASE[sf % 3] + ((1 << shift) >> 1)) >> shift;
    }

    int sample = plm_dma_buffer_read(self->buffer, q->bits);
    int adj = q->levels;
    int scale = 65536 / (adj + 1);
    adj = ((adj + 1) >> 1) - 1;

    val = (adj - sample) * scale;
    self->sample[ch][sb][0] = (val * (sf >> 12) + ((val * (sf & 4095) + 2048) >> 12)) >> 12;
}

void plm_audio_synthesize_sample(plm_audio_t *self, int ss, int *out_pos) {
    // Shifting step
    self->v_pos = (self->v_pos - 64) & 1023;

    for (int ch = 0; ch < 2; ch++) {
        plm_audio_idct36(self->sample[ch], ss, self->V[ch], self->v_pos);

        // Using hardware
        intsample_t hw_U[32];

        {
            for (int i = 0; i < 32; ++i) {

                int d_index = 512 - (self->v_pos >> 1);
                int v_index = (self->v_pos % 128) >> 1;

                // calculate the first 8
                synth_window_mac->result = 0;
                synth_window_mac->addr = &self->V[ch][v_index + i];
                synth_window_mac->index = d_index + i;

                // step forward
                v_index += 128 * 8;
                d_index += 64 * 8;

                // second 8 samples
                d_index -= (512 - 32);
                v_index = (128 - 32 + 1024) - v_index;
                // CPU will stall here probably
                synth_window_mac->addr = &self->V[ch][v_index + i];
                synth_window_mac->index = d_index + i;
                // CPU will stall here probably
                hw_U[i] = synth_window_mac->result;
                //*((volatile intsample_t *)OUTPORT)=hw_U[i];
            }
        }

#ifdef SOFT_CONVOLVE

        // With software for reference
        // Build U, windowing, calculate output
        memset(self->U, 0, sizeof(self->U));

        int d_index = 512 - (self->v_pos >> 1);
        int v_index = (self->v_pos % 128) >> 1;
        while (v_index < 1024) {
            for (int i = 0; i < 32; ++i) {
                self->U[i] += self->D[d_index++] * self->V[ch][v_index++];
            }
            v_index += 128 - 32;
            d_index += 64 - 32;
        }

        d_index -= (512 - 32);
        v_index = (128 - 32 + 1024) - v_index;
        while (v_index < 1024) {
            for (int i = 0; i < 32; ++i) {
                self->U[i] += self->D[d_index++] * self->V[ch][v_index++];
            }

            v_index += 128 - 32;
            d_index += 64 - 32;
        }

        // Verify hardware results against software results
        if (memcmp(hw_U, self->U, sizeof(hw_U))) {
            *((volatile uint8_t *)OUTPORT) = 0x42;
            //*((volatile uint8_t *)OUTPORT)=0x42;
            for (int i = 0; i < 32; ++i) {
                *((volatile uint32_t *)OUTPORT_L) = hw_U[i];
                *((volatile uint32_t *)OUTPORT_R) = self->U[i];
            }

            for (;;)
                ;
        }
#endif
        {
            volatile struct io_audio_out *out_channel = (ch == 0) ? io_audio_out_left : io_audio_out_right;
            for (int j = 0; j < 32; j++) {
                out_channel->sample = hw_U[j] / (0x10000);
            }
        }
    } // End of synthesis channel loop
    out_pos += 32;
}

void plm_audio_idct36(int s[32][3], int ss, intsample_t *d, int dp) {
    int32_t t01, t02, t03, t04, t05, t06, t07, t08, t09, t10, t11, t12, t13, t14, t15, t16, t17, t18, t19,
        t20, t21, t22, t23, t24, t25, t26, t27, t28, t29, t30, t31, t32, t33;

    t01 = (s[0][ss] + s[31][ss]);
    t02 = (s[0][ss] - s[31][ss]) * FLOAT_TO_FIX_256(0.500602998235f) / MULTDIV;
    t03 = (s[1][ss] + s[30][ss]);
    t04 = (s[1][ss] - s[30][ss]) * FLOAT_TO_FIX_256(0.505470959898f) / MULTDIV;
    t05 = (s[2][ss] + s[29][ss]);
    t06 = (s[2][ss] - s[29][ss]) * FLOAT_TO_FIX_256(0.515447309923f) / MULTDIV;
    t07 = (s[3][ss] + s[28][ss]);
    t08 = (s[3][ss] - s[28][ss]) * FLOAT_TO_FIX_256(0.53104259109f) / MULTDIV;
    t09 = (s[4][ss] + s[27][ss]);
    t10 = (s[4][ss] - s[27][ss]) * FLOAT_TO_FIX_256(0.553103896034f) / MULTDIV;
    t11 = (s[5][ss] + s[26][ss]);
    t12 = (s[5][ss] - s[26][ss]) * FLOAT_TO_FIX_256(0.582934968206f) / MULTDIV;
    t13 = (s[6][ss] + s[25][ss]);
    t14 = (s[6][ss] - s[25][ss]) * FLOAT_TO_FIX_256(0.622504123036f) / MULTDIV;
    t15 = (s[7][ss] + s[24][ss]);
    t16 = (s[7][ss] - s[24][ss]) * FLOAT_TO_FIX_256(0.674808341455f) / MULTDIV;
    t17 = (s[8][ss] + s[23][ss]);
    t18 = (s[8][ss] - s[23][ss]) * FLOAT_TO_FIX_256(0.744536271002f) / MULTDIV;
    t19 = (s[9][ss] + s[22][ss]);
    t20 = (s[9][ss] - s[22][ss]) * FLOAT_TO_FIX_256(0.839349645416f) / MULTDIV;
    t21 = (s[10][ss] + s[21][ss]);
    t22 = (s[10][ss] - s[21][ss]) * FLOAT_TO_FIX_256(0.972568237862f) / MULTDIV;
    t23 = (s[11][ss] + s[20][ss]);
    t24 = (s[11][ss] - s[20][ss]) * FLOAT_TO_FIX_256(1.16943993343f) / MULTDIV;
    t25 = (s[12][ss] + s[19][ss]);
    t26 = (s[12][ss] - s[19][ss]) * FLOAT_TO_FIX_256(1.48416461631f) / MULTDIV;
    t27 = (s[13][ss] + s[18][ss]);
    t28 = (s[13][ss] - s[18][ss]) * FLOAT_TO_FIX_256(2.05778100995f) / MULTDIV;
    t29 = (s[14][ss] + s[17][ss]);
    t30 = (s[14][ss] - s[17][ss]) * FLOAT_TO_FIX_256(3.40760841847f) / MULTDIV;
    t31 = (s[15][ss] + s[16][ss]);
    t32 = (s[15][ss] - s[16][ss]) * FLOAT_TO_FIX_256(10.1900081235f) / MULTDIV;

    t33 = t01 + t31;
    t31 = (t01 - t31) * FLOAT_TO_FIX_256(0.502419286188f) / MULTDIV;
    t01 = t03 + t29;
    t29 = (t03 - t29) * FLOAT_TO_FIX_256(0.52249861494f) / MULTDIV;
    t03 = t05 + t27;
    t27 = (t05 - t27) * FLOAT_TO_FIX_256(0.566944034816f) / MULTDIV;
    t05 = t07 + t25;
    t25 = (t07 - t25) * FLOAT_TO_FIX_256(0.64682178336f) / MULTDIV;
    t07 = t09 + t23;
    t23 = (t09 - t23) * FLOAT_TO_FIX_256(0.788154623451f) / MULTDIV;
    t09 = t11 + t21;
    t21 = (t11 - t21) * FLOAT_TO_FIX_256(1.06067768599f) / MULTDIV;
    t11 = t13 + t19;
    t19 = (t13 - t19) * FLOAT_TO_FIX_256(1.72244709824f) / MULTDIV;
    t13 = t15 + t17;
    t17 = (t15 - t17) * FLOAT_TO_FIX_256(5.10114861869f) / MULTDIV;
    t15 = t33 + t13;
    t13 = (t33 - t13) * FLOAT_TO_FIX_256(0.509795579104f) / MULTDIV;
    t33 = t01 + t11;
    t01 = (t01 - t11) * FLOAT_TO_FIX_256(0.601344886935f) / MULTDIV;
    t11 = t03 + t09;
    t09 = (t03 - t09) * FLOAT_TO_FIX_256(0.899976223136f) / MULTDIV;
    t03 = t05 + t07;
    t07 = (t05 - t07) * FLOAT_TO_FIX_256(2.56291544774f) / MULTDIV;
    t05 = t15 + t03;
    t15 = (t15 - t03) * FLOAT_TO_FIX_256(0.541196100146f) / MULTDIV;
    t03 = t33 + t11;
    t11 = (t33 - t11) * FLOAT_TO_FIX_256(1.30656296488f) / MULTDIV;
    t33 = t05 + t03;
    t05 = (t05 - t03) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t03 = t15 + t11;
    t15 = (t15 - t11) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t03 += t15;
    t11 = t13 + t07;
    t13 = (t13 - t07) * FLOAT_TO_FIX_256(0.541196100146f) / MULTDIV;
    t07 = t01 + t09;
    t09 = (t01 - t09) * FLOAT_TO_FIX_256(1.30656296488f) / MULTDIV;
    t01 = t11 + t07;
    t07 = (t11 - t07) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t11 = t13 + t09;
    t13 = (t13 - t09) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t11 += t13;
    t01 += t11;
    t11 += t07;
    t07 += t13;
    t09 = t31 + t17;
    t31 = (t31 - t17) * FLOAT_TO_FIX_256(0.509795579104f) / MULTDIV;
    t17 = t29 + t19;
    t29 = (t29 - t19) * FLOAT_TO_FIX_256(0.601344886935f) / MULTDIV;
    t19 = t27 + t21;
    t21 = (t27 - t21) * FLOAT_TO_FIX_256(0.899976223136f) / MULTDIV;
    t27 = t25 + t23;
    t23 = (t25 - t23) * FLOAT_TO_FIX_256(2.56291544774f) / MULTDIV;
    t25 = t09 + t27;
    t09 = (t09 - t27) * FLOAT_TO_FIX_256(0.541196100146f) / MULTDIV;
    t27 = t17 + t19;
    t19 = (t17 - t19) * FLOAT_TO_FIX_256(1.30656296488f) / MULTDIV;
    t17 = t25 + t27;
    t27 = (t25 - t27) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t25 = t09 + t19;
    t19 = (t09 - t19) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t25 += t19;
    t09 = t31 + t23;
    t31 = (t31 - t23) * FLOAT_TO_FIX_256(0.541196100146f) / MULTDIV;
    t23 = t29 + t21;
    t21 = (t29 - t21) * FLOAT_TO_FIX_256(1.30656296488f) / MULTDIV;
    t29 = t09 + t23;
    t23 = (t09 - t23) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t09 = t31 + t21;
    t31 = (t31 - t21) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t09 += t31;
    t29 += t09;
    t09 += t23;
    t23 += t31;
    t17 += t29;
    t29 += t25;
    t25 += t09;
    t09 += t27;
    t27 += t23;
    t23 += t19;
    t19 += t31;
    t21 = t02 + t32;
    t02 = (t02 - t32) * FLOAT_TO_FIX_256(0.502419286188f) / MULTDIV;
    t32 = t04 + t30;
    t04 = (t04 - t30) * FLOAT_TO_FIX_256(0.52249861494f) / MULTDIV;
    t30 = t06 + t28;
    t28 = (t06 - t28) * FLOAT_TO_FIX_256(0.566944034816f) / MULTDIV;
    t06 = t08 + t26;
    t08 = (t08 - t26) * FLOAT_TO_FIX_256(0.64682178336f) / MULTDIV;
    t26 = t10 + t24;
    t10 = (t10 - t24) * FLOAT_TO_FIX_256(0.788154623451f) / MULTDIV;
    t24 = t12 + t22;
    t22 = (t12 - t22) * FLOAT_TO_FIX_256(1.06067768599f) / MULTDIV;
    t12 = t14 + t20;
    t20 = (t14 - t20) * FLOAT_TO_FIX_256(1.72244709824f) / MULTDIV;
    t14 = t16 + t18;
    t16 = (t16 - t18) * FLOAT_TO_FIX_256(5.10114861869f) / MULTDIV;
    t18 = t21 + t14;
    t14 = (t21 - t14) * FLOAT_TO_FIX_256(0.509795579104f) / MULTDIV;
    t21 = t32 + t12;
    t32 = (t32 - t12) * FLOAT_TO_FIX_256(0.601344886935f) / MULTDIV;
    t12 = t30 + t24;
    t24 = (t30 - t24) * FLOAT_TO_FIX_256(0.899976223136f) / MULTDIV;
    t30 = t06 + t26;
    t26 = (t06 - t26) * FLOAT_TO_FIX_256(2.56291544774f) / MULTDIV;
    t06 = t18 + t30;
    t18 = (t18 - t30) * FLOAT_TO_FIX_256(0.541196100146f) / MULTDIV;
    t30 = t21 + t12;
    t12 = (t21 - t12) * FLOAT_TO_FIX_256(1.30656296488f) / MULTDIV;
    t21 = t06 + t30;
    t30 = (t06 - t30) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t06 = t18 + t12;
    t12 = (t18 - t12) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t06 += t12;
    t18 = t14 + t26;
    t26 = (t14 - t26) * FLOAT_TO_FIX_256(0.541196100146f) / MULTDIV;
    t14 = t32 + t24;
    t24 = (t32 - t24) * FLOAT_TO_FIX_256(1.30656296488f) / MULTDIV;
    t32 = t18 + t14;
    t14 = (t18 - t14) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t18 = t26 + t24;
    t24 = (t26 - t24) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t18 += t24;
    t32 += t18;
    t18 += t14;
    t26 = t14 + t24;
    t14 = t02 + t16;
    t02 = (t02 - t16) * FLOAT_TO_FIX_256(0.509795579104f) / MULTDIV;
    t16 = t04 + t20;
    t04 = (t04 - t20) * FLOAT_TO_FIX_256(0.601344886935f) / MULTDIV;
    t20 = t28 + t22;
    t22 = (t28 - t22) * FLOAT_TO_FIX_256(0.899976223136f) / MULTDIV;
    t28 = t08 + t10;
    t10 = (t08 - t10) * FLOAT_TO_FIX_256(2.56291544774f) / MULTDIV;
    t08 = t14 + t28;
    t14 = (t14 - t28) * FLOAT_TO_FIX_256(0.541196100146f) / MULTDIV;
    t28 = t16 + t20;
    t20 = (t16 - t20) * FLOAT_TO_FIX_256(1.30656296488f) / MULTDIV;
    t16 = t08 + t28;
    t28 = (t08 - t28) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t08 = t14 + t20;
    t20 = (t14 - t20) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t08 += t20;
    t14 = t02 + t10;
    t02 = (t02 - t10) * FLOAT_TO_FIX_256(0.541196100146f) / MULTDIV;
    t10 = t04 + t22;
    t22 = (t04 - t22) * FLOAT_TO_FIX_256(1.30656296488f) / MULTDIV;
    t04 = t14 + t10;
    t10 = (t14 - t10) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t14 = t02 + t22;
    t02 = (t02 - t22) * FLOAT_TO_FIX_256(0.707106781187f) / MULTDIV;
    t14 += t02;
    t04 += t14;
    t14 += t10;
    t10 += t02;
    t16 += t04;
    t04 += t08;
    t08 += t14;
    t14 += t28;
    t28 += t10;
    t10 += t20;
    t20 += t02;
    t21 += t16;
    t16 += t32;
    t32 += t04;
    t04 += t06;
    t06 += t08;
    t08 += t18;
    t18 += t14;
    t14 += t30;
    t30 += t28;
    t28 += t26;
    t26 += t10;
    t10 += t12;
    t12 += t20;
    t20 += t24;
    t24 += t02;

    d[dp + 48] = -t33;
    d[dp + 49] = d[dp + 47] = -t21;
    d[dp + 50] = d[dp + 46] = -t17;
    d[dp + 51] = d[dp + 45] = -t16;
    d[dp + 52] = d[dp + 44] = -t01;
    d[dp + 53] = d[dp + 43] = -t32;
    d[dp + 54] = d[dp + 42] = -t29;
    d[dp + 55] = d[dp + 41] = -t04;
    d[dp + 56] = d[dp + 40] = -t03;
    d[dp + 57] = d[dp + 39] = -t06;
    d[dp + 58] = d[dp + 38] = -t25;
    d[dp + 59] = d[dp + 37] = -t08;
    d[dp + 60] = d[dp + 36] = -t11;
    d[dp + 61] = d[dp + 35] = -t18;
    d[dp + 62] = d[dp + 34] = -t09;
    d[dp + 63] = d[dp + 33] = -t14;
    d[dp + 32] = -t05;
    d[dp + 0] = t05;
    d[dp + 31] = -t30;
    d[dp + 1] = t30;
    d[dp + 30] = -t27;
    d[dp + 2] = t27;
    d[dp + 29] = -t28;
    d[dp + 3] = t28;
    d[dp + 28] = -t07;
    d[dp + 4] = t07;
    d[dp + 27] = -t26;
    d[dp + 5] = t26;
    d[dp + 26] = -t23;
    d[dp + 6] = t23;
    d[dp + 25] = -t10;
    d[dp + 7] = t10;
    d[dp + 24] = -t15;
    d[dp + 8] = t15;
    d[dp + 23] = -t12;
    d[dp + 9] = t12;
    d[dp + 22] = -t19;
    d[dp + 10] = t19;
    d[dp + 21] = -t20;
    d[dp + 11] = t20;
    d[dp + 20] = -t13;
    d[dp + 12] = t13;
    d[dp + 19] = -t24;
    d[dp + 13] = t24;
    d[dp + 18] = -t31;
    d[dp + 14] = t31;
    d[dp + 17] = -t02;
    d[dp + 15] = t02;
    d[dp + 16] = 0.0;
}

#endif // PL_MPEG_IMPLEMENTATION
