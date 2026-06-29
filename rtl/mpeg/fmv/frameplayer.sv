
`include "../../bus.svh"
`include "../../videotypes.svh"
`include "../util.svh"

module frameplayer (
    input clkvideo,
    input clkddr,
    input reset,

    ddr_if.to_host ddrif,

    output rgb888_s vidout,

    input vcd_pixel_clock,
    input debug_activate_vcd_filter,
    input hsync,
    input vsync,
    input hblank,
    input vblank,

    input planar_yuv_s frame,
    input [8:0] frame_width,  // expected to be clocked at clkvideo
    input [8:0] frame_height,  // expected to be clocked at clkvideo
    input [8:0] offset_y,  // expected to be clocked at clkvideo
    input [8:0] offset_x,  // expected to be clocked at clkvideo
    input [8:0] window_y,  // expected to be clocked at clkvideo
    input [8:0] window_x,  // expected to be clocked at clkvideo

    input latch_frame_clkvideo,
    input latch_frame_clkddr,
    input invalidate_latched_frame,
    input show_on_next_video_frame   // expected to be clocked at clkddr
);

    assign ddrif.byteenable = 8'hff;
    assign ddrif.write = 0;

    planar_yuv_s latched_frame;
    bit latched_frame_valid;
    bit fetch_and_show_frame;

    always_ff @(posedge clkddr) begin
        if (reset_clkddr || invalidate_latched_frame) begin
            latched_frame_valid <= 0;
        end else if (latch_frame_clkddr) begin
            latched_frame <= frame;
            latched_frame_valid <= 1;
            //$display("Latched frame %x", latched_frame);
        end
    end

    bit [8:0] frame_width_clkvideo = 100;
    bit [8:0] frame_height_clkvideo = 100;

    bit [8:0] frame_width_clkddr = 100;
    bit [8:0] frame_height_clkddr = 100;
    bit [8:0] window_x_clkddr;
    bit [8:0] window_y_clkddr;

    bit [28:0] address_y;
    bit [28:0] address_u;
    bit [28:0] address_v;

    bit [28:0] address_y_offset;
    bit [28:0] address_uv_offset;
    bit [10:0] luma_stride;
    bit [9:0] chroma_stride;

    enum bit [1:0] {
        IDLE,
        WAITING,
        SETTLE
    } fetchstate;

    bit luma_fifo_strobe;
    yuv_s current_color;

    bit target_y;
    bit target_u;
    bit target_v;

    wire new_line_started = hsync && !hsync_q && (vertical_offset_wait == 0);
    wire new_line_started_clkddr;

    wire reset_clkddr;
    wire vblank_clkddr;

    flag_cross_domain cross_new_line_started (
        .clk_a(clkvideo),
        .clk_b(clkddr),
        .flag_in_clk_a(new_line_started),
        .flag_out_clk_b(new_line_started_clkddr)
    );

    flag_cross_domain cross_reset (
        .clk_a(clkvideo),
        .clk_b(clkddr),
        .flag_in_clk_a(reset),
        .flag_out_clk_b(reset_clkddr)
    );

    signal_cross_domain cross_vblank (
        .clk_a(clkvideo),
        .clk_b(clkddr),
        .signal_in_clk_a(vblank),
        .signal_out_clk_b(vblank_clkddr)
    );

    wire fetch_and_show_frame_clkvideo;
    signal_cross_domain cross_fetch_and_show_frame (
        .clk_a(clkddr),
        .clk_b(clkvideo),
        .signal_in_clk_a(fetch_and_show_frame),
        .signal_out_clk_b(fetch_and_show_frame_clkvideo)
    );

    bit [9:0] luma_read_addr;
    bit [9:0] chroma_read_addr;

    /// Since DD4 access is aligned to 8 byte,
    /// we need a way of throwing up to 7 byte away
    bit [2:0] initial_luma_read_addr;
    bit [3:0] initial_chroma_read_addr;

    ddr_chroma_line_buffer line_buffer_u (
        .clk_in(clkddr),
        .reset(new_line_started_clkddr),
        .wdata(ddrif.rdata),
        .we(ddrif.rdata_ready && target_u),
        .clk_out(clkvideo),
        .q(current_color.u),
        .raddr(chroma_read_addr[9:1])
    );

    ddr_chroma_line_buffer line_buffer_v (
        .clk_in(clkddr),
        .reset(new_line_started_clkddr),
        .wdata(ddrif.rdata),
        .we(ddrif.rdata_ready && target_v),
        .clk_out(clkvideo),
        .q(current_color.v),
        .raddr(chroma_read_addr[9:1])
    );

    ddr_luma_line_buffer line_buffer_y (
        .clk_in(clkddr),
        .reset(new_line_started_clkddr),
        .wdata(ddrif.rdata),
        .we(ddrif.rdata_ready && target_y),
        .clk_out(clkvideo),
        .q(current_color.y),
        .raddr(luma_read_addr)
    );


    bit [8:0] pixelcnt;
    bit [8:0] linecnt;
    bit [8:0] linecnt_clkddr;
    bit hsync_q;
    bit line_alternate;
    bit u_requested;
    bit v_requested;
    bit y_requested;

    bit [8:0] vertical_offset_wait;
    bit [10:0] horizontal_offset_wait;
    bit [8:0] latched_offset_x;

    always_ff @(posedge clkddr) begin
        if (vblank_clkddr) begin
            window_x_clkddr <= window_x;
            window_y_clkddr <= window_y;

            frame_width_clkddr <= frame_width;
            frame_height_clkddr <= frame_height;
        end
    end

    sample_rate_converter pixel_src (
        .clk30(clkvideo),
        .reset(horizontal_offset_wait != 0 || hblank),
        .vcd_mode(vcd_pixel_clock),
        .newpixel(luma_fifo_strobe)
    );

    bit luma_fifo_strobe_q;

    always_ff @(posedge clkvideo) begin
        hsync_q <= hsync;
        luma_fifo_strobe_q <= luma_fifo_strobe;

        if (reset || vblank) begin
            linecnt <= 0;
            vertical_offset_wait <= offset_y;
            latched_offset_x <= offset_x;

            frame_width_clkvideo <= frame_width;
            frame_height_clkvideo <= frame_height;
        end else if (!vblank && hsync && !hsync_q) begin
            if (vertical_offset_wait != 0) vertical_offset_wait <= vertical_offset_wait - 1;
            else linecnt <= linecnt + 1;
        end

        if (luma_fifo_strobe) begin
            luma_read_addr   <= luma_read_addr + 1;
            chroma_read_addr <= chroma_read_addr + 1;
        end

        if (vblank) begin
            initial_luma_read_addr   <= window_x[2:0];
            initial_chroma_read_addr <= window_x[3:0];
        end

        if (hblank || reset) begin
            pixelcnt <= 0;

            luma_read_addr <= {7'b0, initial_luma_read_addr};
            chroma_read_addr <= {6'b000000, initial_chroma_read_addr};
            horizontal_offset_wait <= {latched_offset_x, 2'b00};
        end else if (!vblank && !hblank && pixelcnt < frame_width_clkvideo && linecnt < frame_height_clkvideo && vertical_offset_wait==0 && fetch_and_show_frame_clkvideo) begin

            if (horizontal_offset_wait != 0) horizontal_offset_wait <= horizontal_offset_wait - 1;
            else if (luma_fifo_strobe_q) begin
                pixelcnt <= pixelcnt + 1;
            end
        end
    end

    bit [6:0] data_burst_cnt;

    // 0011 like the N64 core to force a base of 0x30000000
    localparam bit [3:0] DDR_CORE_BASE = 4'b0011;

    always_ff @(posedge clkddr) begin
        linecnt_clkddr <= linecnt;

        if (!ddrif.busy) begin
            ddrif.read <= 0;
        end
        if (ddrif.rdata_ready) begin
            data_burst_cnt <= data_burst_cnt - 1;
        end
        if (data_burst_cnt == 0) begin
            ddrif.acquire <= 0;
        end

        address_y_offset  <= latched_frame.width * window_y_clkddr;
        address_uv_offset <= 29'(latched_frame.width / 2) * 29'(window_y_clkddr / 2);

        if (reset_clkddr || vblank_clkddr) begin
            fetchstate <= IDLE;
            address_y <= latched_frame.y_adr + address_y_offset + 29'(window_x_clkddr);
            address_u <= latched_frame.u_adr + address_uv_offset + 29'(window_x_clkddr / 2);
            address_v <= latched_frame.v_adr + address_uv_offset + 29'(window_x_clkddr / 2);
            fetch_and_show_frame <= latched_frame_valid && show_on_next_video_frame;
            luma_stride <= latched_frame.luma_width;
            chroma_stride <= latched_frame.chroma_width;
            target_y <= 0;
            target_u <= 0;
            target_v <= 0;
            line_alternate <= window_y_clkddr[0];
            u_requested <= 0;
            v_requested <= 0;
            y_requested <= 0;
        end else if (fetch_and_show_frame) begin
            if (new_line_started_clkddr && linecnt_clkddr < frame_height_clkddr) begin
                line_alternate <= !line_alternate;

                if (line_alternate) begin
                    u_requested <= 0;
                    v_requested <= 0;
                end

                y_requested <= 0;
            end

            case (fetchstate)
                IDLE: begin
                    if (!u_requested) begin
                        u_requested <= 1;
                        ddrif.addr <= {DDR_CORE_BASE, address_u[27:3]};
                        ddrif.read <= 1;
                        ddrif.acquire <= 1;
                        address_u <= address_u + 29'(chroma_stride);
                        ddrif.burstcnt <= 8'(9'(frame_width_clkddr + 15) / 16) + 1;
                        data_burst_cnt <= 7'(9'(frame_width_clkddr + 15) / 16) + 1;
                        fetchstate <= WAITING;
                        target_u <= 1;
                    end else if (!v_requested) begin
                        v_requested <= 1;
                        ddrif.addr <= {DDR_CORE_BASE, address_v[27:3]};
                        ddrif.read <= 1;
                        ddrif.acquire <= 1;
                        address_v <= address_v + 29'(chroma_stride);
                        ddrif.burstcnt <= 8'(9'(frame_width_clkddr + 15) / 16) + 1;
                        data_burst_cnt <= 7'(9'(frame_width_clkddr + 15) / 16) + 1;
                        fetchstate <= WAITING;
                        target_v <= 1;
                    end else if (!y_requested) begin
                        y_requested <= 1;
                        ddrif.addr <= {DDR_CORE_BASE, address_y[27:3]};
                        ddrif.read <= 1;
                        ddrif.acquire <= 1;
                        address_y <= address_y + 29'(luma_stride);
                        ddrif.burstcnt <= 8'(9'(frame_width_clkddr + 7) / 8) + 1;
                        data_burst_cnt <= 7'(9'(frame_width_clkddr + 7) / 8) + 1;
                        fetchstate <= WAITING;
                        target_y <= 1;
                    end
                end
                WAITING: begin
                    if (data_burst_cnt == 0) begin
                        fetchstate <= IDLE;
                        target_y   <= 0;
                        target_u   <= 0;
                        target_v   <= 0;
                    end
                end
                default: begin

                end
            endcase

        end
    end

    bit signed [9:0] r;
    bit signed [9:0] g;
    bit signed [9:0] b;

    function [7:0] clamp8(input signed [9:0] val);
        if (val > 255) clamp8 = 255;
        else if (val < 0) clamp8 = 0;
        else clamp8 = val[7:0];
    endfunction

    // We use an AVG filter with 4 elements to soften the picture during VCD pixel clock mode
    // This will not change the image quality on the analog video output,
    // but improves perceived quality on HDMI
    yuv_s color_window[3];
    yuv_s filtered_color;
    always_ff @(posedge clkvideo) begin
        // Reset the filter with black to allow a fade-in on the left side
        if (hblank) begin
            color_window[0].y <= 0;
            color_window[0].u <= 128;
            color_window[0].v <= 128;
        end else begin
            color_window[0] <= current_color;
        end

        color_window[1] <= color_window[0];
        color_window[2] <= color_window[1];

        filtered_color.y <= (color_window[0].y + color_window[1].y + color_window[2].y + current_color.y)/4;
        filtered_color.u <= (color_window[0].u + color_window[1].u + color_window[2].u + current_color.u)/4;
        filtered_color.v <= (color_window[0].v + color_window[1].v + color_window[2].v + current_color.v)/4;
    end

    always_comb begin
        bit signed [9:0] Y, Cb, Cr;

        if (vcd_pixel_clock && debug_activate_vcd_filter) begin
            Y  = {2'b00, filtered_color.y};
            Cb = {2'b00, filtered_color.u};
            Cr = {2'b00, filtered_color.v};
        end else begin
            Y  = {2'b00, current_color.y};
            Cb = {2'b00, current_color.u};
            Cr = {2'b00, current_color.v};
        end

        // According to ITU-R BT.601
        r = ((Y - 16) * 298 + 409 * (Cr - 128)) / 256;
        g = ((Y - 16) * 298 - 100 * (Cb - 128) - 208 * (Cr - 128)) / 256;
        b = ((Y - 16) * 298 + 516 * (Cb - 128)) / 256;

        vidout.r = clamp8(r);
        vidout.g = clamp8(g);
        vidout.b = clamp8(b);

        if ((pixelcnt >= frame_width_clkvideo) || (linecnt >= frame_height_clkvideo) || (vertical_offset_wait!=0) || (horizontal_offset_wait!=0) || !fetch_and_show_frame_clkvideo) begin
            vidout.r = 0;
            vidout.g = 0;
            vidout.b = 0;
        end
    end

endmodule
