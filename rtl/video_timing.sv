// Info from Chapter 5 - Image Display Control (MCD212)

module video_timing (
    input clk,
    input reset,
    output bit fake_parity,  // Always switches between odd (1) and even (0) field (even non interlaced)
    output bit parity,  // Non interlaced always 1, interlaced 1 odd, 0 even field
    input sm,  // scan mode, 1 = interlaced, 0 = non-interlaced
    input cf,  // crystal, 0 = 28 MHz for NTSC monitors, 1 = 30 MHz for PAL and NTSC TV
    input st,  // standard, 1=360/720 pixels per line, 0=384/768
    input cm,  // color mode, 0 = 4 clocks per pixel, 1 = 2 clocks per pixel
    input fd,  // frame duration, 0=50 Hz, 1=60 Hz
    output bit [8:0] video_y,
    output bit [12:0] video_x,
    output bit hsync,
    output bit vsync,
    output bit hblank,
    output bit vblank,
    output bit hblank_no_st,
    output bit vblank_no_st,
    output bit new_line
);

    localparam bit [12:0] ClksPerCycle = 16;

    // horizontal timing according to Table 5-4
    bit [12:0] h_total;  // A in datasheet
    bit [12:0] h_active;  // B in datashheet
    bit [12:0] h_start;  // C in datasheet
    bit [12:0] h_sync;  // E in datasheet

    // Allows moving videotiming to the left to counter pipeline latencies.
    // C is defined as 10.7µs at 30 MHz or 20 cycles of 16 CLK periods.
    // This means HBlank must be 320 clock cycles wide
    localparam kHBlankOffset = 7;

    always_comb begin
        if (st && cf) begin
            // 30 MHz pixel frequency but 360 pixels instead of 384
            // Used in the game "Flashback"
            h_total  = 120;
            h_active = 90;
            h_start  = 23;
            h_sync   = 9;
        end else if (cf) begin
            // 30 MHz pixel frequency. This is the usual case
            h_total  = 120;
            h_active = 96;
            h_start  = 20;
            h_sync   = 9;
        end else begin
            // 28 MHz? NTSC Monitor? This should never occur
            h_total  = 112;
            h_active = 90;
            h_start  = 19;
            h_sync   = 8;
        end

        h_total  = h_total * ClksPerCycle;
        h_active = h_active * ClksPerCycle;
        h_start  = h_start * ClksPerCycle - kHBlankOffset;
        h_sync   = h_sync * ClksPerCycle;
    end

    bit [12:0] h_active_no_st;
    bit [12:0] h_start_no_st;

    always_comb begin
        if (cf) begin
            h_active_no_st = 96;
            h_start_no_st  = 20;
        end else begin
            h_active_no_st = 8;
            h_start_no_st  = 19;
        end

        // hblank <= hblank_vt_q2 <= hblank_vt_q <= hblank_vt causes 3 ticks delay
        // in parent module
        h_active_no_st = h_active_no_st * ClksPerCycle;
        h_start_no_st  = h_start_no_st * ClksPerCycle - kHBlankOffset + 3;
    end


    // vertical timing according to Table 5-6
    bit [8:0] v_total;  // J in datasheet
    bit [8:0] v_active;  // K in datasheet
    bit [8:0] v_sync;  // P in datasheet
    bit [8:0] v_start;  // L in datasheet
    bit [8:0] v_front_porch;  // M in datasheet

    always_comb begin
        v_sync = 3;
        if (fd) begin
            // NTSC
            v_total = 262;
            v_active = 240;
            v_start = 18;
            v_front_porch = 4;
        end else if (st) begin
            // PAL with NTSC height
            v_total = 312;
            v_active = 240;
            v_start = 46;
            v_front_porch = 26;
        end else begin
            // PAL full height
            v_total = 312;
            v_active = 280;
            v_start = 26;
            v_front_porch = 6;
        end

        // Add the half line
        v_total = v_total + 1;

        // This hack is required to fix the flickering OSD
        // It moves even fields one line down
        // but also breaks the line order for everything else
        if (!parity) v_start = v_start + 1;
    end

    bit [8:0] v_active_no_st;
    bit [8:0] v_start_no_st;

    always_comb begin
        if (fd) begin
            // NTSC
            v_active_no_st = 240;
            v_start_no_st  = 18;
        end else begin
            // PAL full height
            v_active_no_st = 280;
            v_start_no_st  = 26;
        end

        // This hack is required to fix the flickering OSD
        // It moves even fields one line down
        // but also breaks the line order for everything else
        if (!parity) v_start_no_st = v_start_no_st + 1;
    end


    always_ff @(posedge clk) begin
        new_line <= 0;

        if (video_x == (h_total - 1)) begin  // end of line reached?
            video_x <= 0;
            hsync <= 1;
            new_line <= 1;

            if (video_y == (v_total - 1) && !parity) begin
                // Start odd field now
                // Can only be reached in interlacing mode
                video_y <= 0;
                parity <= 1;
                fake_parity <= 1;
                vsync <= 1;
            end else if (video_y == (v_total - 2) && parity) begin
                // Start even field when in interlacing
                // Stay on odd field when interlacing is disabled
                video_y <= 0;

                if (sm) parity <= 0;
                else vsync <= 1;

                fake_parity <= !fake_parity;
            end else begin
                video_y <= video_y + 1;
            end
        end else begin
            video_x <= video_x + 1;
        end

        if (video_x == h_sync) hsync <= 0;
        if (parity && video_y == v_sync) vsync <= 0;

        // Create the centered vsync edges for interlacing
        if (!parity && video_x == h_total / 2 && video_y == 0) vsync <= 1;
        if (!parity && video_x == h_total / 2 && video_y == v_sync) vsync <= 0;

        // Never reset on FPGA build to keep the video stable.
        // This avoids resyncs of HDMI sinks during reset
`ifdef VERILATOR
        if (reset) begin
            video_x <= 0;
            video_y <= 0;
            parity <= 1;
            fake_parity <= 1;
        end
`endif
    end

    always_ff @(posedge clk) begin
        hblank <= !(video_x >= h_start && video_x < (h_start + h_active));
        vblank <= !(video_y >= v_start && video_y < (v_start + v_active));

        hblank_no_st <= !(video_x >= h_start_no_st && video_x < (h_start_no_st + h_active_no_st));
        vblank_no_st <= !(video_y >= v_start_no_st && video_y < (v_start_no_st + v_active_no_st));

    end


`ifdef VERILATOR
    wire [4:0] timing_param = {sm, cf, st, cm, fd};
    bit  [4:0] timing_param_q = 0;

    always_ff @(posedge clk) begin
        timing_param_q <= timing_param;

        if (timing_param_q != timing_param) begin
            $display("Video Timing Parameters: %b", timing_param);
        end
    end
`endif

endmodule
