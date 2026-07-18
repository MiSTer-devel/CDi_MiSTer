`timescale 1 ns / 1 ns
`include "bus.svh"
`include "audiotypes.svh"

module audioplayer (
    input clk,
    input sample_tick37,
    input sample_tick44,
    input reset,

    output bit [12:0] mem_addr,
    output bit mem_rd,
    input [15:0] mem_data,
    input mem_ack,

    input start_playback,
    input stop_playback,
    input cdda_mode,
    input last_refreshed_buffer,
    output bit playback_active,
    output bit finished_buffer_playback,
    output decoder_disable_audiomap,

    output bit signed [15:0] audio_left,
    output bit signed [15:0] audio_right
);

    audiostream xa_out ();
    audiostream xa_fifo_out[2] ();
    audiostream xa_fifo_in[2] ();
    wire xa_channel  /*verilator public_flat_rd*/;

`ifdef VERILATOR
    wire signed [15:0] xa_sample  /*verilator public_flat_rd*/ = xa_out.sample;
    wire sample_strobe  /*verilator public_flat_rd*/ = xa_out.write && xa_out.strobe;
`endif

    header_coding_s current_active_coding;

    wire decoder_idle;
    bit [12:0] playback_request_addr  /*verilator public_flat_rd*/;
    bit decoder_start  /*verilator public_flat_rd*/ = 0;

    wire reset_filter_on_start;

    audiodecoder decoder (
        .clk(clk),
        .reset(reset),
        .reset_filter_on_start(reset_filter_on_start),
        .mem_addr(mem_addr),
        .mem_data(mem_data),
        .mem_rd(mem_rd),
        .mem_ack(mem_ack),

        .out(xa_out),
        .sample_channel(xa_channel),

        .start_playback(decoder_start),
        .cdda_mode,
        .playback_coding_out(current_active_coding),
        .playback_addr(playback_request_addr),
        .idle(decoder_idle),
        .disable_audiomap(decoder_disable_audiomap)
    );

    wire [1:0] fifo_nearly_full;
    wire [1:0] fifo_nearly_empty;

    always_ff @(posedge clk) begin
        decoder_start <= 0;
        finished_buffer_playback <= 0;

        if (reset) begin
            playback_active <= 0;
            playback_request_addr <= 0;
        end else begin
            // Only start playback when decoder is idle
            if (decoder_idle && !decoder_start && fifo_nearly_empty[0]) begin
                decoder_start <= playback_active && !decoder_disable_audiomap;
                finished_buffer_playback <= finished_buffer_playback_latched;
            end

            // To react on audiomap activation change
            if (stop_playback || decoder_disable_audiomap) begin
                playback_active <= 0;
            end

            // Buffer playback
            if (start_playback && !playback_active) begin
                playback_active <= 1;
                // ADPCM playback always starts at 0x2800
                // For CDDA this might not be accurate
                playback_request_addr <= cdda_mode ? (last_refreshed_buffer ? 13'h0f00 : 13'h0a00) : 13'h1400;
            end

            // after the decoder was started, change address to the next buffer
            if (decoder_start && playback_active) begin
                if (cdda_mode)
                    playback_request_addr <= playback_request_addr == 13'h0a00 ? 13'h0f00 : 13'h0a00;
                else
                    playback_request_addr <= playback_request_addr == 13'h1400 ? 13'h1900 : 13'h1400;
            end
        end
    end


    always_comb begin
        // Mono is default. Write to both FIFOs and ignore the channel
        xa_fifo_in[0].sample = xa_out.sample;
        xa_fifo_in[1].sample = xa_out.sample;
        xa_fifo_in[0].write = xa_out.write;
        xa_fifo_in[1].write = xa_out.write;
        xa_out.strobe = xa_channel ? xa_fifo_in[1].strobe : xa_fifo_in[0].strobe;

        // In case of Stereo, write only to selected channel
        if (current_active_coding.chan == kStereo) begin
            xa_fifo_in[0].write = xa_channel == 0 && xa_out.write;
            xa_fifo_in[1].write = xa_channel == 1 && xa_out.write;
        end
    end

`ifdef VERILATOR
    wire signed [15:0] fifo_out_left  /*verilator public_flat_rd*/ = xa_fifo_out[0].sample;
    wire signed [15:0] fifo_out_right  /*verilator public_flat_rd*/ = xa_fifo_out[1].sample;
    wire fifo_out_valid  /*verilator public_flat_rd*/ = xa_fifo_out[0].strobe;
`endif

    audiofifo fifo_left (
        .clk,
        .reset,
        .in(xa_fifo_in[0]),
        .out(xa_fifo_out[0]),
        .nearly_full(fifo_nearly_full[0]),
        .nearly_empty(fifo_nearly_empty[0])
    );
    audiofifo fifo_right (
        .clk,
        .reset,
        .in(xa_fifo_in[1]),
        .out(xa_fifo_out[1]),
        .nearly_full(fifo_nearly_full[1]),
        .nearly_empty(fifo_nearly_empty[1])
    );

    bit audio_fifo_output_enabled = 0;
    bit sample_toggle18 = 0;
    bit decoder_idle_q;

    assign reset_filter_on_start = !audio_fifo_output_enabled;

    bit strobe_fifo;
    always_comb begin
        strobe_fifo = 0;
        if (audio_fifo_output_enabled) begin
            if (current_active_coding.rate == k44Khz && sample_tick44) strobe_fifo = 1;
            if (current_active_coding.rate == k37Khz && sample_tick37) strobe_fifo = 1;
            if (current_active_coding.rate == k18Khz && sample_tick37 && sample_toggle18)
                strobe_fifo = 1;
        end
    end

    // Used to reduce the speed of zeroing after playback has ended
    bit [4:0] dc_bias_cnt;

    // To avoid buffer underflows between audio sectors,
    // we are waiting exactly two 37.8 kHz samples until playback starts.
    // One would have been enough, but let's be sure.
    // Not having this results into pops especially percievible
    // with Tetris
    bit audio_fifo_output_enabled_next_sample_tick;

    bit finished_buffer_playback_latched;

    always_ff @(posedge clk) begin
        dc_bias_cnt <= dc_bias_cnt + 1;

        decoder_idle_q <= decoder_idle;

        xa_fifo_out[0].strobe <= 0;
        xa_fifo_out[1].strobe <= 0;

        if (reset) begin
            audio_fifo_output_enabled <= 0;
            audio_fifo_output_enabled_next_sample_tick <= 0;
            xa_fifo_out[0].strobe <= 0;
            xa_fifo_out[1].strobe <= 0;
        end else begin

            if (fifo_nearly_full == 2'b11 &&
                ((current_active_coding.rate != k44Khz && sample_tick37) ||
                 (current_active_coding.rate == k44Khz && sample_tick44))) begin
                audio_fifo_output_enabled_next_sample_tick <= 1;
                audio_fifo_output_enabled <= audio_fifo_output_enabled_next_sample_tick;
            end

            if (audio_fifo_output_enabled && decoder_idle && !decoder_idle_q) begin
                finished_buffer_playback_latched <= 1;
            end

            if (finished_buffer_playback) begin
                finished_buffer_playback_latched <= 0;
            end

            if (xa_fifo_out[0].write == 0 && xa_fifo_out[0].write == 0) begin
                audio_fifo_output_enabled <= 0;
                audio_fifo_output_enabled_next_sample_tick <= 0;
            end

            if (audio_fifo_output_enabled) begin
                if (strobe_fifo) begin
                    xa_fifo_out[0].strobe <= 1;
                    xa_fifo_out[1].strobe <= 1;

                    audio_left <= xa_fifo_out[0].sample;
                    audio_right <= xa_fifo_out[1].sample;
                end
            end else if (dc_bias_cnt == 0) begin
                // Slowly move the current sample to zero
                // to remove pops when playing the next samples

                if (audio_left > 0) audio_left <= audio_left - 1;
                else if (audio_left < 0) audio_left <= audio_left + 1;

                if (audio_right > 0) audio_right <= audio_right - 1;
                else if (audio_right < 0) audio_right <= audio_right + 1;
            end

            if (sample_tick37) sample_toggle18 <= !sample_toggle18;
        end
    end

endmodule
