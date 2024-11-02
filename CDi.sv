`timescale 1 ns / 1 ns

//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module emu (
    //Master input clock
    input CLK_50M,

    //Async reset from top-level module.
    //Can be used as initial reset.
    input RESET,

    //Must be passed to hps_io module
    inout [48:0] HPS_BUS,

    //Base video clock. Usually equals to CLK_SYS.
    output CLK_VIDEO,

    //Multiple resolutions are supported using different CE_PIXEL rates.
    //Must be based on CLK_VIDEO
    output CE_PIXEL,

    //Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
    //if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
    output [12:0] VIDEO_ARX,
    output [12:0] VIDEO_ARY,

    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output       VGA_HS,
    output       VGA_VS,
    output       VGA_DE,      // = ~(VBlank | HBlank)
    output       VGA_F1,
    output [1:0] VGA_SL,
    output       VGA_SCALER,  // Force VGA scaler
    output       VGA_DISABLE, // analog out is off

    input  [11:0] HDMI_WIDTH,
    input  [11:0] HDMI_HEIGHT,
    output        HDMI_FREEZE,
    output        HDMI_BLACKOUT,

`ifdef MISTER_FB
    // Use framebuffer in DDRAM
    // FB_FORMAT:
    //    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
    //    [3]   : 0=16bits 565 1=16bits 1555
    //    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
    //
    // FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
    output        FB_EN,
    output [ 4:0] FB_FORMAT,
    output [11:0] FB_WIDTH,
    output [11:0] FB_HEIGHT,
    output [31:0] FB_BASE,
    output [13:0] FB_STRIDE,
    input         FB_VBL,
    input         FB_LL,
    output        FB_FORCE_BLANK,

`ifdef MISTER_FB_PALETTE
    // Palette control for 8bit modes.
    // Ignored for other video modes.
    output        FB_PAL_CLK,
    output [ 7:0] FB_PAL_ADDR,
    output [23:0] FB_PAL_DOUT,
    input  [23:0] FB_PAL_DIN,
    output        FB_PAL_WR,
`endif
`endif

    output LED_USER,  // 1 - ON, 0 - OFF.

    // b[1]: 0 - LED status is system status OR'd with b[0]
    //       1 - LED status is controled solely by b[0]
    // hint: supply 2'b00 to let the system control the LED.
    output [1:0] LED_POWER,
    output [1:0] LED_DISK,

    // I/O board button press simulation (active high)
    // b[1]: user button
    // b[0]: osd button
    output [1:0] BUTTONS,

    input         CLK_AUDIO,  // 24.576 MHz
    output [15:0] AUDIO_L,
    output [15:0] AUDIO_R,
    output        AUDIO_S,    // 1 - signed audio samples, 0 - unsigned
    output [ 1:0] AUDIO_MIX,  // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

    //ADC
    inout [3:0] ADC_BUS,

    //SD-SPI
    output SD_SCK,
    output SD_MOSI,
    input  SD_MISO,
    output SD_CS,
    input  SD_CD,

    //High latency DDR3 RAM interface
    //Use for non-critical time purposes
    output        DDRAM_CLK,
    input         DDRAM_BUSY,
    output [ 7:0] DDRAM_BURSTCNT,
    output [28:0] DDRAM_ADDR,
    input  [63:0] DDRAM_DOUT,
    input         DDRAM_DOUT_READY,
    output        DDRAM_RD,
    output [63:0] DDRAM_DIN,
    output [ 7:0] DDRAM_BE,
    output        DDRAM_WE,

    //SDRAM interface with lower latency
    output        SDRAM_CLK,
    output        SDRAM_CKE,
    output [12:0] SDRAM_A,
    output [ 1:0] SDRAM_BA,
`ifndef VERILATOR
    inout  [15:0] SDRAM_DQ,
`endif
    output        SDRAM_DQML,
    output        SDRAM_DQMH,
    output        SDRAM_nCS,
    output        SDRAM_nCAS,
    output        SDRAM_nRAS,
    output        SDRAM_nWE,

`ifdef MISTER_DUAL_SDRAM
    //Secondary SDRAM
    //Set all output SDRAM_* signals to Z ASAP if SDRAM2_EN is 0
    input         SDRAM2_EN,
    output        SDRAM2_CLK,
    output [12:0] SDRAM2_A,
    output [ 1:0] SDRAM2_BA,
    inout  [15:0] SDRAM2_DQ,
    output        SDRAM2_nCS,
    output        SDRAM2_nCAS,
    output        SDRAM2_nRAS,
    output        SDRAM2_nWE,
`endif

    input  UART_CTS,
    output UART_RTS,
    input  UART_RXD,
    output UART_TXD,
    output UART_DTR,
    input  UART_DSR,

    // Open-drain User port.
    // 0 - D+/RX
    // 1 - D-/TX
    // 2..6 - USR2..USR6
    // Set USER_OUT to 1 to read from USER_IN.
    input  [6:0] USER_IN,
    output [6:0] USER_OUT,

    input OSD_STATUS
);

    ///////// Default values for ports not used in this core /////////

`ifdef VERILATOR
    bit [15:0] SDRAM_DQ_in;
    bit [15:0] SDRAM_DQ_out;
`endif

    assign ADC_BUS = 'Z;
    assign USER_OUT[6:1] = '1;
    assign {UART_RTS, UART_DTR} = 0;
    assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
`ifdef VERILATOR
    assign {SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
`else
    assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
`endif

    assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;

    assign VGA_SL = 0;
    assign VGA_F1 = 0;
    assign VGA_SCALER = 0;
    assign VGA_DISABLE = 0;
    assign HDMI_FREEZE = 0;
    assign HDMI_BLACKOUT = 0;

    assign AUDIO_S = 1;
    assign AUDIO_MIX = 0;

    assign LED_DISK = 0;
    assign LED_POWER = 0;
    assign BUTTONS = 0;

    //////////////////////////////////////////////////////////////////

    `include "build_id.v"
    localparam CONF_STR = {
        "CD-i;UART115200;",
        "-;",
        "S0,CUECHD,Insert Disc;",
        "F1,ROM,Replace Boot ROM;",
        "O[122:121],Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
        "O[2],Disable MODE2 Filter,No,Yes;",
        "O[3],UART Fake Space,No,Yes;",
        "O[4],TV Mode,PAL,NTSC;",
        "O[5],Overclock input device,No,Yes;",
        "-;",
        "-;",
        "T[0],Reset;",
        "R[0],Reset and close OSD;",
        "v,0;",  // [optional] config version 0-99. 
                 // If CONF_STR options are changed in incompatible way, then change version number too,
        "J1,B1,B2;",
        "jn,A,B;",
        "jp,B,A;",
        // so all options will get default values on first start.
        "V,v",
        `BUILD_DATE
    };

    wire         forced_scandoubler;
    wire [  1:0] buttons;
    wire [127:0] status;

    wire [  1:0] ar = status[122:121];
    assign VIDEO_ARX = (ar == 0) ? 13'd4 : (13'(ar) - 13'd1);
    assign VIDEO_ARY = (ar == 0) ? 13'd3 : 13'd0;

    wire [10:0] ps2_key;

    wire [15:0] JOY0  /*verilator public_flat_rw*/;

    wire        ioctl_download  /*verilator public_flat_rw*/;
    wire        ioctl_wr  /*verilator public_flat_rw*/;
    wire [24:0] ioctl_addr  /*verilator public_flat_rw*/;
    wire [15:0] ioctl_dout  /*verilator public_flat_rw*/;
    wire [15:0] ioctl_index  /*verilator public_flat_rw*/;
    wire        ioctl_wait  /*verilator public_flat_rw*/ = 0;

    (* keep *)wire        clk_sys  /*verilator public_flat_rw*/;
    (* keep *)wire        clk_audio  /*verilator public_flat_rw*/;


    wire [31:0] sd_lba0;
    wire        sd_rd  /*verilator public_flat_rd*/;
    wire        sd_wr;
    wire        sd_ack  /*verilator public_flat_rw*/;
    wire [ 7:0] sd_buff_addr;
    wire [15:0] sd_buff_dout  /*verilator public_flat_rw*/;
    wire [15:0] sd_buff_din0;
    wire        sd_buff_wr  /*verilator public_flat_rw*/;
    wire        img_mounted;
    wire        img_readonly;
    wire [63:0] img_size;

`ifndef VERILATOR
    hps_io #(
        .CONF_STR(CONF_STR),
        .WIDE(1),
        .BLKSZ(3)
    ) hps_io (
        .clk_sys  (clk_sys),
        .HPS_BUS  (HPS_BUS),
        .EXT_BUS  (),
        .gamma_bus(),

        .forced_scandoubler(forced_scandoubler),

        .buttons(buttons),
        .status(status),
        .status_menumask(),

        .ioctl_download(ioctl_download),
        .ioctl_index(ioctl_index),
        .ioctl_wr(ioctl_wr),
        .ioctl_addr(ioctl_addr),
        .ioctl_dout(ioctl_dout),
        .ioctl_wait(ioctl_wait),

        .sd_lba('{sd_lba0}),
        .sd_blk_cnt('{0}),
        .sd_rd(sd_rd),
        .sd_wr(sd_wr),
        .sd_ack(sd_ack),
        .sd_buff_addr(sd_buff_addr),
        .sd_buff_dout(sd_buff_dout),
        .sd_buff_din('{sd_buff_din0}),
        .sd_buff_wr(sd_buff_wr),

        .img_mounted(img_mounted),
        .img_readonly(img_readonly),
        .img_size(img_size),

        .ps2_key(ps2_key),

        .joystick_0(JOY0)
    );
`endif

    ///////////////////////   CLOCKS   ///////////////////////////////

`ifndef VERILATOR
    pll pll (
        .refclk(CLK_50M),
        .rst(0),
        .outclk_0(clk_sys),  // 30 MHz
        .outclk_1(clk_audio)  // 22.2264 MHz
    );
`endif

    wire [24:0] sdram_addr;
    wire        sdram_rd;
    wire        sdram_wr;
    wire        sdram_word;
    wire [15:0] sdram_din;
    wire [15:0] sdram_dout;
    wire        sdram_busy;
    wire        sdram_burst;
    wire        sdram_refresh;
    wire        sdram_burstdata_valid;
    wire        sdram_init_done;

    bit         prepare_sdram;
    bit  [24:0] prepare_sdram_addr;
    bit  [15:0] prepare_sdram_din;
    bit         prepare_sdram_wr;
    bit         prepare_sdram_refresh;
    bit         prepare_sdram_rd;

    bit         cditop_reset = 1;

    // 1MB of RAM to zero, 512k 16 bit words
    // The highest bit 20 is only used for detection that the process was finished
    bit  [20:1] ram_zero_adr = 0;

    // Zeroing of RAM currently disabled. Seems to be not required.
    wire        ram_zero_done = 1;
    //wire ram_zero_done = ram_zero_adr[20];

`ifdef VERILATOR
    bit ram_zero_done_q = 0;
    always_ff @(posedge clk_sys) begin
        ram_zero_done_q <= ram_zero_done;

        if (ram_zero_done && !ram_zero_done_q) $display("RAM Zeroed");
    end
`endif

    typedef enum bit [3:0] {
        ROM_DOWNLOAD,  // most important
        RAM_ZERO,  // bulk afterwards
        REFRESH,
        IDLE
    } e_arbit_target;

    e_arbit_target        sdram_owner;
    e_arbit_target        sdram_owner_q;
    e_arbit_target        sdram_owner_next;

    bit                   ioctl_sdram_wr_latch  /*verilator public_flat_rw*/ = 0;

    // boot0.rom represented as ioctl_index==16h'0000
    // boot1.rom represented as ioctl_index==16h'0040
    wire                  ioctl_maincpu_rom_wr = ioctl_wr && ioctl_index[6] == 0;
    wire                  ioctl_slave_worm_wr = ioctl_wr && ioctl_index[6] == 1;

    bit                   ioctl_slave_worm_wr_q = 0;

    // We get 16 bit data from Main. The second 8 bit is stored here while writing the first
    bit            [ 7:0] slave_worm_second_data = 0;

    // Signals to write the "Write once read many" memory of the slave
    bit            [12:0] slave_worm_adr = 0;
    bit            [ 7:0] slave_worm_data = 0;
    bit                   slave_worm_wr;

    always_ff @(posedge clk_sys) begin
        ioctl_slave_worm_wr_q <= ioctl_slave_worm_wr;
        slave_worm_wr <= ioctl_slave_worm_wr_q || ioctl_slave_worm_wr;

        if (ioctl_slave_worm_wr) begin
            // Lower byte first
            slave_worm_adr <= ioctl_addr[12:0];
            slave_worm_data <= ioctl_dout[7:0];
            slave_worm_second_data <= ioctl_dout[15:8];
        end else begin
            // Afterwards the upper byte
            slave_worm_data   <= slave_worm_second_data;
            slave_worm_adr[0] <= 1;
        end
    end


    always_comb begin
        sdram_owner_next = IDLE;

        if (prepare_sdram) begin
            sdram_owner_next = REFRESH;

            if (!ram_zero_done) sdram_owner_next = RAM_ZERO;
            if (ioctl_sdram_wr_latch) sdram_owner_next = ROM_DOWNLOAD;
        end

        if (sdram_busy) sdram_owner = sdram_owner_q;
        else sdram_owner = sdram_owner_next;
    end

    bit sdram_busy_q = 0;

    always_comb begin
        prepare_sdram_din = 0;
        prepare_sdram_wr = 0;
        prepare_sdram_addr = {4'b0000, ram_zero_adr, 1'b0};
        prepare_sdram_rd = 0;
        prepare_sdram_refresh = 0;

        case (sdram_owner)
            ROM_DOWNLOAD: begin
                prepare_sdram_din  = {ioctl_dout[7:0], ioctl_dout[15:8]};
                prepare_sdram_addr = {3'b001, ioctl_addr[21:1], 1'b0};
                prepare_sdram_wr   = 1;
            end
            RAM_ZERO: begin
                if (!sdram_busy_q) prepare_sdram_wr = 1;
            end
            REFRESH: begin
                prepare_sdram_rd = 1;
                prepare_sdram_refresh = 1;
            end
            default: begin
            end
        endcase

        if (sdram_busy) begin
            prepare_sdram_rd = 0;
            prepare_sdram_wr = 0;
        end
    end

    bit ioctl_download_q = 0;
    bit ioctl_wr_overflow = 0;

    always_ff @(posedge clk_sys) begin
        if (ioctl_sdram_wr_latch && ioctl_wr) ioctl_wr_overflow <= 1;

        if (ioctl_maincpu_rom_wr) begin
            ioctl_sdram_wr_latch <= 1;
        end

        ioctl_download_q <= ioctl_download;
        sdram_busy_q <= sdram_busy;

        if (!ioctl_download_q && ioctl_download) begin
            // Use positive edge of ioctl_download as reset
            sdram_owner_q <= RAM_ZERO;
            ram_zero_adr  <= 0;
        end else begin
            sdram_owner_q <= sdram_owner;

            if (sdram_owner_q == RAM_ZERO && sdram_busy_q && !sdram_busy)
                ram_zero_adr <= ram_zero_adr + 1;

            if (sdram_owner_q == ROM_DOWNLOAD && sdram_busy_q && !sdram_busy)
                ioctl_sdram_wr_latch <= 0;
        end
    end

    assign prepare_sdram = cditop_reset;
    always_ff @(posedge clk_sys) begin
        cditop_reset <= RESET || status[0] || buttons[1] || ioctl_download || !ram_zero_done;
    end

    sdram sdram (
        .*,
        .init(0),  //~clock_locked),
        .clk(clk_sys),

        .addr(prepare_sdram ? prepare_sdram_addr : sdram_addr),
        .din(prepare_sdram ? prepare_sdram_din : sdram_din),
        .dout(sdram_dout),
        .rd(prepare_sdram ? prepare_sdram_rd : sdram_rd),
        .wr(prepare_sdram ? prepare_sdram_wr : sdram_wr),
        .word(prepare_sdram ? 1'b1 : sdram_word),
        .busy(sdram_busy),
        .refresh(prepare_sdram ? prepare_sdram_refresh : sdram_refresh),
        .burst(prepare_sdram ? 1'b0 : sdram_burst),
        .burstdata_valid(sdram_burstdata_valid)
    );

`ifdef VERILATOR
    bit [15:0] rom[262144]  /*verilator public_flat_rw*/;
    bit [15:0] ram[262144*2]  /*verilator public_flat_rw*/;
    bit [22:0] sdram_real_addr;
    initial begin
        $readmemh("cdi200.mem", rom);
        //$readmemh("ramdump.mem", ram);
    end

    bit [3:0] burstindex = 0;
    wire [22:0] burstwrap_corrected_address = {
        sdram_real_addr[22:2], sdram_real_addr[1:0] + burstindex[1:0]
    };

    always_comb begin
        SDRAM_DQ_in = 0;

        if (sdram_real_addr[21]) SDRAM_DQ_in = rom[burstwrap_corrected_address[17:0]];
        else SDRAM_DQ_in = ram[burstwrap_corrected_address[18:0]];
    end

    bit SDRAM_nWE_q;
    bit SDRAM_DQMH_q;
    bit SDRAM_DQML_q;
    bit alignment_fail = 0;

    always_ff @(posedge clk_sys) begin
        SDRAM_nWE_q  <= SDRAM_nWE;
        SDRAM_DQMH_q <= SDRAM_DQMH;
        SDRAM_DQML_q <= SDRAM_DQML;

        if (!SDRAM_nRAS) sdram_real_addr[21:9] <= SDRAM_A;
        if (!SDRAM_nCAS) sdram_real_addr[8:0] <= SDRAM_A[8:0];

        if (!SDRAM_nCAS) burstindex <= 0;
        else if (burstindex < 4) burstindex <= burstindex + 1;

        if (sdram_real_addr[21]) begin
            // no write during download
            //if (!SDRAM_nWE_q) assert (ioctl_download);

            if (!SDRAM_nWE_q && !SDRAM_DQMH_q)
                rom[burstwrap_corrected_address[17:0]][15:8] <= SDRAM_DQ_out[15:8];
            if (!SDRAM_nWE_q && !SDRAM_DQML_q)
                rom[burstwrap_corrected_address[17:0]][7:0] <= SDRAM_DQ_out[7:0];
        end else begin
            if (!SDRAM_nWE_q && !SDRAM_DQMH_q)
                ram[burstwrap_corrected_address[18:0]][15:8] <= SDRAM_DQ_out[15:8];
            if (!SDRAM_nWE_q && !SDRAM_DQML_q)
                ram[burstwrap_corrected_address[18:0]][7:0] <= SDRAM_DQ_out[7:0];
        end
    end
`endif

`ifdef VERILATOR
    bit  debug_uart_fake_space  /*verilator public_flat_rw*/;
    bit  tvmode_ntsc  /*verilator public_flat_rw*/;
    wire overclock_maneuvering_device = 1;
`else
    // status seems to be all zero after reset
    // Should be considered for defining the default
    wire debug_uart_fake_space = status[3];
    wire tvmode_ntsc = status[4];
    wire overclock_maneuvering_device = status[5];
`endif

    wire HBlank;
    wire HSync;
    wire VBlank;
    wire VSync;
    wire ce_pix;
    wire [7:0] r  /*verilator public_flat_rd*/;
    wire [7:0] g  /*verilator public_flat_rd*/;
    wire [7:0] b  /*verilator public_flat_rd*/;

    bytestream slave_serial_out ();
    bytestream slave_serial_in ();
    wire slave_rts;

    /*
    maneuvering_device spoon (
        .clk(clk_sys),
        .mister_joystick(JOY0),
        .rts(slave_rts),
        .serial_out(slave_serial_in),
        .overclock(overclock_maneuvering_device)
    );
    */

    assign USER_OUT[0] = slave_rts;

    uart_rx #(
        .CLK_FRE  (30),
        .BAUD_RATE(1200)
    ) uart_rx_inst (
        .clk          (clk_sys),
        .rst_n        (!cditop_reset),
        .rx_data      (slave_serial_in.data),
        .rx_data_valid(slave_serial_in.write),
        .rx_data_ready(1'b1),                // always ready
        .rx_pin       (USER_IN[1])
    );

    cditop cditop (
        .clk30(clk_sys),
        .clk_audio(clk_audio),
        .reset(cditop_reset),

        .debug_uart_loopback(0),
        .debug_disable_sector_filter(status[2]),
        .tvmode_pal(!tvmode_ntsc),
        .debug_uart_fake_space,
        .scandouble(forced_scandoubler),

        .ce_pix(ce_pix),

        .HBlank(HBlank),
        .HSync (HSync),
        .VBlank(VBlank),
        .VSync (VSync),

        .r(r),
        .g(g),
        .b(b),

        .sdram_addr(sdram_addr),
        .sdram_rd(sdram_rd),
        .sdram_wr(sdram_wr),
        .sdram_word(sdram_word),
        .sdram_din(sdram_din),
        .sdram_dout(sdram_dout),
        .sdram_busy(sdram_busy),
        .sdram_refresh(sdram_refresh),
        .sdram_burst,
        .sdram_burstdata_valid,
        .scc68_uart_tx(UART_TXD),
        .scc68_uart_rx(UART_RXD),

        .slave_worm_adr (slave_worm_adr),
        .slave_worm_data(slave_worm_data),
        .slave_worm_wr  (slave_worm_wr),

        .slave_serial_in(slave_serial_in),
        .slave_serial_out(slave_serial_out),
        .slave_rts(slave_rts),

        .cd_hps_req(sd_rd),
        .cd_hps_lba(sd_lba0),
        .cd_hps_ack(sd_ack),
        .cd_hps_data_valid(sd_buff_wr),
        // MiSTer uses little endian on linux. Swap over to big endian
        // to actually fit the way the 68k wants it
        .cd_hps_data({sd_buff_dout[7:0], sd_buff_dout[15:8]}),

        .audio_left (AUDIO_L),
        .audio_right(AUDIO_R)

    );


    assign CLK_VIDEO = clk_sys;
    assign CE_PIXEL = ce_pix;

    assign VGA_DE = ~(HBlank | VBlank);
    assign VGA_HS = HSync;
    assign VGA_VS = VSync;
    assign VGA_R = r;
    assign VGA_G = g;
    assign VGA_B = b;

    reg [26:0] act_cnt;
    always_ff @(posedge clk_sys) act_cnt <= act_cnt + 1'd1;
    assign LED_USER = act_cnt[26] ? act_cnt[25:18] > act_cnt[7:0] : act_cnt[25:18] <= act_cnt[7:0];

endmodule
