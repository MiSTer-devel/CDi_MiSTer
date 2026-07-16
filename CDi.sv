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
    inout [45:0] HPS_BUS,

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
    output        HDMI_BOB_DEINT,

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
    output DDRAM_CLK,  // any clock, no restrictions. Typically main core clock
`ifndef VERILATOR
    input DDRAM_BUSY,  // every read and write request is only accepted in a cycle where busy is low
    output [7:0] DDRAM_BURSTCNT,  // amount of words to be written/read. Maximum is 128
    output [28:0] DDRAM_ADDR,         // starting address for read/write. In case of burst, the addresses will internally count up
    input [63:0] DDRAM_DOUT,  // data coming from (burst) read
    input         DDRAM_DOUT_READY,   // high for 1 clock cycle for every 64 bit dataword requested via (burst) read request
    output DDRAM_RD,  // request read at DDRAM_ADDR and DDRAM_BURSTCNT length
    output [63:0] DDRAM_DIN,  // data word to be written
    output  [7:0] DDRAM_BE,           // byte enable for each of the 8 bytes in DDRAM_DIN, only used for writing. (1=write, 0=ignore)
    output DDRAM_WE,  // request write at DDRAM_ADDR with DDRAM_DIN data and DDRAM_BE mask
`endif

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
    assign {UART_RTS, UART_DTR} = 0;
    assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
`ifdef VERILATOR
    assign {SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
`else
    assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
`endif

    assign VGA_SL = 0;
    assign VGA_SCALER = 0;
    assign VGA_DISABLE = 0;
    assign HDMI_FREEZE = 0;
    assign HDMI_BLACKOUT = 0;
    assign HDMI_BOB_DEINT = 0;

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
        "S0,CUECHD,Load CD;",
        "-;",

        "P1,Audio & Video;",
        "P1O[4],Video Region,PAL,NTSC;",
        "P1O[33:32],Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
        "P1O[35:34],Scale,Normal,V-Integer,Narrower HV-Integer,Wider HV-Integer;",
        "P1O[39],Vertical Crop,Off,On(270);",
        "P1O[10:9],RGB Scale,0-255,16-235,16-255;",

        "P2,Debug Options;",
        "P2-;",
        "P2F1,ROM,Replace Boot ROM;",
        "P2O[2],Disable Audio Att.,No,Yes;",
        "P2O[3],UART Fake Space,No,Yes;",
        "P2O[7:6],Force Video Plane,Original,A,B,DVC;",
        "P2O[12],SERVO Audio CD,No,Yes;",
        "P2O[17],Disable VCD pixel clock,No,Yes;",
        "P2O[18],Activate VCD filter,Yes,No;",
        "P2O[19],CD image live update,No,Yes;",

        "P3,Hardware Config;",
        "P3-;",
        "P3O[15],Ports,P1 Front + UART Back,P1 Back + P2 Front;",
        "P3O[21:20],SNAC,Disabled,Only Ir RC5,Front Split Port,Back Port;",
        "P3O[5],Overclock input device,No,Yes;",
        "P3O[13],Disable VMPEG DVC,No,Yes;",
        "P3-;",
        "P3-,(U) = unsafe, experimental;",
        "P3O[16],Fast CD Seek,No,Yes(U);",
        "P3O[11],CPU Turbo,No,Yes(U);",
        "P3O[8],NvRAM live update,No,Yes(U);",

        "-;",
        "O[21:19],Pointer Speed,22ER9021 N,22ER9021 II,RV 8701,22ER9021 I;",
        "O[14],Autoplay,Yes,No;",
        "-;",
        "T[0],Reset;",
        "R[0],Reset and close OSD;",
        "v,0;",  // [optional] config version 0-99. 
                 // If CONF_STR options are changed in incompatible way, then change version number too,
        "J1,B1,B2,B1+B2;",
        "jn,B,A,Y;",
        // so all options will get default values on first start.
        "I,",
        "NvRAM saved;",
        "V,v",
        `BUILD_DATE
    };

    wire         forced_scandoubler;
    wire [  1:0] buttons;
    wire [127:0] status;

    wire [ 10:0] ps2_key;

    wire [ 15:0] JOY0  /*verilator public_flat_rw*/;
    wire [ 15:0] JOY1  /*verilator public_flat_rw*/;
    wire [ 15:0] JOY0_ANALOG  /*verilator public_flat_rw*/;
    wire [ 15:0] JOY1_ANALOG  /*verilator public_flat_rw*/;

    wire [ 24:0] MOUSE  /*verilator public_flat_rw*/;

    wire         ioctl_download  /*verilator public_flat_rw*/;
    wire         ioctl_wr  /*verilator public_flat_rw*/;
    wire [ 24:0] ioctl_addr  /*verilator public_flat_rw*/;
    wire [ 15:0] ioctl_dout  /*verilator public_flat_rw*/;
    wire [ 15:0] ioctl_index  /*verilator public_flat_rw*/;
    wire         ioctl_wait  /*verilator public_flat_rw*/ = 0;

    wire         clk_sys  /*verilator public_flat_rw*/;
    wire         clk_audio  /*verilator public_flat_rw*/;
    wire         clk_mpeg  /*verilator public_flat_rw*/;

    wire [ 31:0] cd_hps_lba;
    wire         cd_hps_req  /*verilator public_flat_rd*/;
    wire         cd_hps_ack  /*verilator public_flat_rw*/;
    wire         cd_media_change  /*verilator public_flat_rw*/;

    wire         nvram_hps_ack  /*verilator public_flat_rw*/;
    bit          nvram_hps_wr;
    bit          nvram_hps_rd  /*verilator public_flat_rd*/;
    bit  [ 15:0] nvram_hps_din  /*verilator public_flat_rd*/;
    wire         nvram_media_change  /*verilator public_flat_rw*/;

    wire [  7:0] sd_buff_addr  /*verilator public_flat_rw*/;
    wire         sd_buff_wr  /*verilator public_flat_rw*/;
    wire [ 15:0] sd_buff_dout  /*verilator public_flat_rw*/;

    wire         img_readonly;
    wire [ 63:0] img_size  /*verilator public_flat_rw*/;

    wire [ 15:0] status_menumask = 0;

    bit          info_req;
    bit  [  7:0] info;

    wire [ 64:0] hps_rtc;

    // To reduce to a single clock cycle
    bit          cd_media_change_q;
    bit          nvram_media_change_q;

    // Flag which becomes active for some time when an NvRAM image is mounted
    wire         nvram_img_mount = nvram_media_change && !nvram_media_change_q && img_size != 0;
    // Flag which becomes active for some time when an NvRAM image is mounted
    wire         cd_img_mount = cd_media_change && !cd_media_change_q && img_size != 0;

    always_ff @(posedge clk_sys) begin
        cd_media_change_q <= cd_media_change;
        nvram_media_change_q <= nvram_media_change;
    end

`ifndef VERILATOR
    hps_io #(
        .CONF_STR(CONF_STR),
        .WIDE(1),
        .BLKSZ(6),  // NvRAM of 8kB size as block size
        .VDNUM(2)
    ) hps_io (
        .clk_sys  (clk_sys),
        .HPS_BUS  (HPS_BUS),
        .EXT_BUS  (),
        .gamma_bus(),

        .forced_scandoubler(forced_scandoubler),

        .buttons(buttons),
        .status(status),
        .status_menumask(status_menumask),

        .info_req(info_req),
        .info(info),

        .ioctl_download(ioctl_download),
        .ioctl_index(ioctl_index),
        .ioctl_wr(ioctl_wr),
        .ioctl_addr(ioctl_addr),
        .ioctl_dout(ioctl_dout),
        .ioctl_wait(ioctl_wait),

        .sd_lba('{cd_hps_lba, 0}),
        .sd_blk_cnt('{0, 0}),
        .sd_rd({nvram_hps_rd, cd_hps_req && cd_img_mounted}),
        .sd_wr({nvram_hps_wr, 1'b0}),
        .sd_ack({nvram_hps_ack, cd_hps_ack}),
        .sd_buff_addr(sd_buff_addr),
        .sd_buff_dout(sd_buff_dout),
        .sd_buff_din('{0, nvram_hps_din}),
        .sd_buff_wr(sd_buff_wr),

        .img_mounted({nvram_media_change, cd_media_change}),
        .img_readonly(img_readonly),
        .img_size(img_size),

        .ps2_key(ps2_key),

        .ps2_mouse(MOUSE),

        .joystick_l_analog_0(JOY0_ANALOG),
        .joystick_l_analog_1(JOY1_ANALOG),
        .joystick_0(JOY0),
        .joystick_1(JOY1),
        .RTC(hps_rtc)
    );

    wire [1:0] ar = status[33:32];
    wire vcrop_en = status[39];

    video_freak video_freak (
        .*,
        .VGA_DE_IN(~(HBlank | VBlank)),
        .ARX((!ar) ? 13'd4 : (13'(ar) - 13'd1)),
        .ARY((!ar) ? 13'd3 : 13'd0),
        .CROP_SIZE(vcrop_en ? 10'd270 : 10'd0),
        .CROP_OFF(0),
        .SCALE(status[35:34])
    );

`endif

    ///////////////////////   CLOCKS   ///////////////////////////////

`ifndef VERILATOR
    pll pll (
        .refclk(CLK_50M),
        .rst(0),
        .outclk_0(clk_sys),  // 30 MHz
        .outclk_1(clk_audio),  // 22.2264 MHz
        .outclk_2(clk_mpeg)  // 90 MHz
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
    // boot2.rom represented as ioctl_index==16h'0080
    wire                  ioctl_maincpu_rom_wr = ioctl_wr && ioctl_index[7:6] == 2'b00;
    wire                  ioctl_slave_worm_wr = ioctl_wr && ioctl_index[7:6] == 2'b01;
    wire                  ioctl_vmpega_worm_wr = ioctl_wr && ioctl_index[7:6] == 2'b10;

    bit                   ioctl_slave_worm_wr_q = 0;

    // We get 16 bit data from Main. The second 8 bit is stored here while writing the first
    bit            [ 7:0] slave_worm_second_data = 0;

    // Signals to write the "Write once read many" memory of the slave
    bit            [12:0] slave_worm_adr = 0;
    bit            [ 7:0] slave_worm_data = 0;
    bit                   slave_worm_wr;

    // Signals to manipulate the NvRAM from the Linux side
    bit            [12:0] nvram_backup_restore_adr;
    bit            [15:0] nvram_restore_data_temp;
    wire           [ 7:0] nvram_restore_data;
    wire           [ 7:0] nvram_backup_data;
    bit                   nvram_restore_write;
    wire                  nvram_cpu_changed;
    bit                   nvram_allow_cpu_access;

    assign nvram_restore_data = nvram_backup_restore_adr[0] ? nvram_restore_data_temp[15:8] : nvram_restore_data_temp[7:0];

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
                prepare_sdram_addr = {5'b00100, ioctl_index[7], ioctl_addr[18:1], 1'b0};
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

        if (ioctl_maincpu_rom_wr || ioctl_vmpega_worm_wr) begin
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

            if (sdram_owner == ROM_DOWNLOAD && sdram_busy_q && !sdram_busy)
                ioctl_sdram_wr_latch <= 0;
        end
    end

    // Latch which is set, when CD reading was performed at least once
    // If set, we must perform a reset when changing the disc
    // If not set, we can change the image even with a closed tray while keeping the machine running
    bit cd_hps_req_during_power_cycle;

    assign prepare_sdram = cditop_reset;
    always_ff @(posedge clk_sys) begin
        cditop_reset <= RESET || status[0] || buttons[1] || ioctl_download || !ram_zero_done ||
                (nvram_img_mount && enable_reset_on_nvram_img_mount) || 
                (cd_img_mount && cd_hps_req_during_power_cycle && tray_is_closed && enable_reset_on_cd_img_mount);

        if (cditop_reset) cd_hps_req_during_power_cycle <= 0;
        else if (cd_hps_req) cd_hps_req_during_power_cycle <= 1;
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
    // DDR3 simulation
    bit [63:0] ddram[16777216/8]  /*verilator public_flat_rd*/;

    int ddr_latencycnt;
    bit [7:0] ddr_words_to_prove;
    bit [28:0] ddr_addr;

    bit DDRAM_BUSY;  // every read and write request is only accepted in a cycle where busy is low
    wire [7:0] DDRAM_BURSTCNT;  // amount of words to be written/read. Maximum is 128
    wire [28:0] DDRAM_ADDR;         // starting address for read/write. In case of burst; the addresses will internally count up
    bit [63:0] DDRAM_DOUT;  // data coming from (burst) read
    bit         DDRAM_DOUT_READY;   // high for 1 clock cycle for every 64 bit dataword requested via (burst) read request
    wire DDRAM_RD;  // request read at DDRAM_ADDR and DDRAM_BURSTCNT length
    wire [63:0] DDRAM_DIN;  // data word to be written
    wire  [7:0] DDRAM_BE;           // byte enable for each of the 8 bytes in DDRAM_DIN; only used for writing. (1=write; 0=ignore)
    wire DDRAM_WE;  // request write at DDRAM_ADDR with DDRAM_DIN data and DDRAM_BE mask

    always_ff @(posedge DDRAM_CLK) begin
        DDRAM_DOUT_READY <= 0;

        if (DDRAM_WE && !DDRAM_BUSY) begin
            assert (DDRAM_ADDR[21] == 0);
            ddram[DDRAM_ADDR[20:0]] <= DDRAM_DIN;
            //$display("Write at %x %x",DDRAM_ADDR, DDRAM_DIN);
        end

        if (DDRAM_RD && !DDRAM_BUSY) begin
            ddr_latencycnt <= 13;
            ddr_words_to_prove <= DDRAM_BURSTCNT;
            ddr_addr <= DDRAM_ADDR;
            DDRAM_BUSY <= 1;
        end

        if (DDRAM_BUSY) begin
            if (ddr_latencycnt > 0) ddr_latencycnt <= ddr_latencycnt - 1;
            else begin
                DDRAM_DOUT <= ddram[ddr_addr[20:0]];
                ddr_addr <= ddr_addr + 1;
                DDRAM_DOUT_READY <= 1;
                ddr_words_to_prove <= ddr_words_to_prove - 1;
                if (ddr_words_to_prove == 1) DDRAM_BUSY <= 0;
            end

        end
    end

    // SDRAM simulation

    bit [15:0] rom[262144]  /*verilator public_flat_rw*/;
    bit [15:0] vmpega_rom[65536]  /*verilator public_flat_rw*/;
    bit [15:0] ram[2097152]  /*verilator public_flat_rw*/;
    bit [22:0] sdram_real_addr;
    initial begin
        $readmemh("cdi200.mem", rom);
        $readmemh("vmpega.mem", vmpega_rom);
        //$readmemh("ramdump.mem", ram);
    end

    bit [3:0] burstindex = 0;
    wire [22:0] burstwrap_corrected_address = {
        sdram_real_addr[22:2], sdram_real_addr[1:0] + burstindex[1:0]
    };

    always_comb begin
        SDRAM_DQ_in = 0;

        case (sdram_real_addr[21:18])
            4'b1000: SDRAM_DQ_in = rom[burstwrap_corrected_address[17:0]];
            4'b1001: SDRAM_DQ_in = vmpega_rom[burstwrap_corrected_address[15:0]];
            default: SDRAM_DQ_in = ram[burstwrap_corrected_address[20:0]];
        endcase
    end

    bit SDRAM_nWE_q;
    bit SDRAM_DQMH_q;
    bit SDRAM_DQML_q;

    always_ff @(posedge clk_sys) begin
        SDRAM_nWE_q  <= SDRAM_nWE;
        SDRAM_DQMH_q <= SDRAM_DQMH;
        SDRAM_DQML_q <= SDRAM_DQML;

        if (!SDRAM_nRAS) sdram_real_addr[21:9] <= SDRAM_A;
        if (!SDRAM_nCAS) sdram_real_addr[8:0] <= SDRAM_A[8:0];

        if (!SDRAM_nCAS) burstindex <= 0;
        else if (burstindex < 4) burstindex <= burstindex + 1;

        case (sdram_real_addr[21:18])
            4'b1000: begin
                if (!SDRAM_nWE_q && !SDRAM_DQMH_q)
                    rom[burstwrap_corrected_address[17:0]][15:8] <= SDRAM_DQ_out[15:8];
                if (!SDRAM_nWE_q && !SDRAM_DQML_q)
                    rom[burstwrap_corrected_address[17:0]][7:0] <= SDRAM_DQ_out[7:0];
            end
            4'b1001: begin
                if (!SDRAM_nWE_q && !SDRAM_DQMH_q)
                    vmpega_rom[burstwrap_corrected_address[15:0]][15:8] <= SDRAM_DQ_out[15:8];
                if (!SDRAM_nWE_q && !SDRAM_DQML_q)
                    vmpega_rom[burstwrap_corrected_address[15:0]][7:0] <= SDRAM_DQ_out[7:0];
            end
            default: begin
                if (!SDRAM_nWE_q && !SDRAM_DQMH_q)
                    ram[burstwrap_corrected_address[20:0]][15:8] <= SDRAM_DQ_out[15:8];
                if (!SDRAM_nWE_q && !SDRAM_DQML_q)
                    ram[burstwrap_corrected_address[20:0]][7:0] <= SDRAM_DQ_out[7:0];
            end
        endcase
    end
`endif

`ifdef VERILATOR
    bit debug_uart_fake_space  /*verilator public_flat_rw */;
    bit tvmode_ntsc  /*verilator public_flat_rw */;
    bit overclock_pointing_device = 1;
    bit [1:0] debug_force_video_plane = 0;
    bit enable_reset_on_nvram_img_mount = 0;
    bit enable_reset_on_cd_img_mount = 0;
    bit [1:0] debug_limited_to_full = 0;
    bit audio_cd_in_tray  /*verilator public_flat_rw */ = 0;
    bit config_disable_cpu_starve  /*verilator public_flat_rw */ = 1;
    bit config_auto_play  /*verilator public_flat_rw */ = 1;
    bit config_disable_vmpeg = 0;
    bit config_first_player_back_port = 0;
    bit config_disable_seek_time  /*verilator public_flat_rw */ = 1;
    bit debug_disable_vcd_clock = 0;
    bit debug_activate_vcd_filter = 1;
    bit [2:0] pointing_dev_speed = 0;
    wire snac_enable_split_port = 0;
    wire snac_enable_infrared = 0;
`else
    // Status seems to be all zero after reset
    // Should be considered for defining the default
    wire debug_uart_fake_space = status[3];
    wire tvmode_ntsc = status[4];
    wire overclock_pointing_device = status[5];
    wire [1:0] debug_force_video_plane = status[7:6];
    wire enable_reset_on_nvram_img_mount = !status[8];
    wire enable_reset_on_cd_img_mount = !status[19];
    wire [1:0] debug_limited_to_full = status[10:9];
    wire config_disable_cpu_starve = status[11];
    wire audio_cd_in_tray = status[12];
    bit config_disable_vmpeg = 0;
    wire config_auto_play = !status[14];
    wire config_first_player_back_port = status[15];
    wire config_disable_seek_time = status[16];
    wire debug_disable_vcd_clock = status[17];
    wire debug_activate_vcd_filter = !status[18];
    wire [2:0] pointing_dev_speed = status[21:19];
    wire snac_enable_split_port = status[21:20] == 2;
    wire snac_enable_infrared = status[21:20] != 0;

    always_ff @(posedge clk_sys) begin
        // only change during resets
        if (cditop_reset) config_disable_vmpeg <= status[13];
    end
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
    bytestream snac_rxd2_stream ();
    bytestream virtual_front_rxd2 ();

    wire slave_rts;

    bytestream scc68070_bypass_serial_out ();
    bytestream scc68070_bypass_serial_in ();
    wire scc68070_rts;

    // "INPUT" port at the front of a CDI 210/05
    pointing_device pointing_dev_front (
        .clk(clk_sys),
        .mister_joystick(config_first_player_back_port ? JOY1 : JOY0),
        .mister_joystick_analog(config_first_player_back_port ? JOY1_ANALOG : JOY0_ANALOG),
        .mister_mouse(config_first_player_back_port ? 0 : MOUSE),
        .rts(forced_rts_flag | slave_rts),
        .serial_out(virtual_front_rxd2),
        .overclock(overclock_pointing_device),
        .speed_setting(pointing_dev_speed)
    );

    // "INPUT 2" port at the back of a CDI 210/05
    pointing_device pointing_dev_back (
        .clk(clk_sys),
        .mister_joystick(config_first_player_back_port ? JOY0 : JOY1),
        .mister_joystick_analog(config_first_player_back_port ? JOY0_ANALOG : JOY1_ANALOG),
        .mister_mouse(config_first_player_back_port ? MOUSE : 0),
        .rts(forced_rts_flag | (config_first_player_back_port ? scc68070_rts : 1'b1)),
        .serial_out(scc68070_bypass_serial_in),
        .overclock(overclock_pointing_device),
        .speed_setting(pointing_dev_speed)
    );

    wire cd_sector_tick;
    wire cd_sector_delivered;
    wire [31:0] cd_seek_lba;
    wire cd_seek_lba_valid;
    wire [15:0] cd_data;
    wire cd_data_valid;
    wire cd_stop_sector_delivery;

    hps_cd_sector_cache hps_cd_sector_cache (
        .clk(clk_sys),
        .reset(cditop_reset),
        .cd_hps_req(cd_hps_req),
        .cd_hps_lba(cd_hps_lba),
        .cd_hps_ack(cd_hps_ack),
        .cd_hps_data_valid(sd_buff_wr && cd_hps_ack),
        // MiSTer uses little endian on linux. Swap over to big endian
        // to actually fit the way the 68k wants it
        .cd_hps_data({sd_buff_dout[7:0], sd_buff_dout[15:8]}),

        // Interface to CDi
        .cd_data_valid(cd_data_valid),
        .cd_data(cd_data),
        .seek_lba(cd_seek_lba),
        .stop_sector_delivery(cd_stop_sector_delivery),
        .seek_lba_valid(cd_seek_lba_valid),
        .sector_tick(cd_sector_tick),
        .sector_delivered(cd_sector_delivered),

        .config_disable_seek_time
    );

    wire forced_snac_rts;
    wire forced_rts_flag;

    // Comments represent the USB 3.0 signal name
    // together with the split port name
    assign USER_OUT[0] = 1;  // D+, RXD2
    assign USER_OUT[1] = 1;  // D-, RXD1
    assign USER_OUT[2] = 1;  // TX-, CTS1
    assign USER_OUT[3] = 1;  // GND DRAIN, RTS1
    assign USER_OUT[4] = ~(slave_rts | forced_snac_rts);  // RX+, RTS2
    assign USER_OUT[5] = 1;  // RX-, TXD1
    assign USER_OUT[6] = 1;  // TX+, RC-Eye

    rts_forcer rtsforcer (
        .clk(clk_sys),
        .config_state({status[21:20], config_first_player_back_port}),
        .rts_flag(forced_rts_flag),
        .rts_snac(forced_snac_rts)
    );

    wire snac_rxd2;
    wire snac_rc_eye;

    // To avoid metastability issues with external input
    signal_cross_domain deboune_snac_rxd2 (
        .clk_a(clk_sys),
        .signal_in_clk_a(~USER_IN[0]),
        .clk_b(clk_sys),
        .signal_out_clk_b(snac_rxd2)
    );

    // To avoid metastability issues with external input
    signal_cross_domain deboune_rc_eye (
        .clk_a(clk_sys),
        .signal_in_clk_a(USER_IN[6]),
        .clk_b(clk_sys),
        .signal_out_clk_b(snac_rc_eye)
    );

    // The SLAVE has no real UART at the moment
    // We fake it externally
    uart_rx #(
        .CLK_FRE  (30),
        .BAUD_RATE(1200)
    ) snac_uart_rxd2 (
        .clk          (clk_sys),
        .rst_n        (!cditop_reset),
        .rx_data      (snac_rxd2_stream.data),
        .rx_data_valid(snac_rxd2_stream.write),
        .rx_data_ready(1'b1),                    // always ready
        .rx_pin       (snac_rxd2)
    );

    // Connects the SLAVE RXD either to SNAC or the virtual pointing device
    bytestream_mux slave_rxd_mux (
        .use_b(snac_enable_split_port),
        .a(virtual_front_rxd2),
        .b(snac_rxd2_stream),
        .dst(slave_serial_in)
    );

    wire fail_not_enough_words;
    wire fail_too_much_data;

    wire rc_eye_double_debounce;
    wire rc_eye = snac_enable_infrared && rc_eye_double_debounce;

    // It is unclear whether this is really required. For now it doesn't hurt.
    rc5_debouncer rc5debounce (
        .clk(clk_sys),
        .in (snac_rc_eye),
        .out(rc_eye_double_debounce)
    );

    ddr_if ddr_host ();

    assign DDRAM_CLK = clk_mpeg;
    assign DDRAM_ADDR = ddr_host.addr;
    assign DDRAM_BE = ddr_host.byteenable;
    assign DDRAM_WE = ddr_host.write;
    assign DDRAM_RD = ddr_host.read;
    assign DDRAM_DIN = ddr_host.wdata;
    assign DDRAM_BURSTCNT = ddr_host.burstcnt;
    assign ddr_host.rdata = DDRAM_DOUT;
    assign ddr_host.rdata_ready = DDRAM_DOUT_READY;
    assign ddr_host.busy = DDRAM_BUSY;

    rgb888_s cdi_video_out;
    assign {r, g, b} = {cdi_video_out.r, cdi_video_out.g, cdi_video_out.b};

    cditop cditop (
        .clk30(clk_sys),
        .clk_audio(clk_audio),
        .clk_mpeg(clk_mpeg),
        .external_reset(cditop_reset),

        .tvmode_pal(!tvmode_ntsc),
        .debug_uart_fake_space,
        .debug_disable_vcd_clock,
        .debug_activate_vcd_filter,
        .debug_force_video_plane,
        .debug_limited_to_full,
        .audio_cd_in_tray,
        .debug_disable_audio_attenuation(status[2]),

        .ce_pix(ce_pix),

        .HBlank(HBlank),
        .HSync (HSync),
        .VBlank(VBlank),
        .VSync (VSync),
        .vga_f1(VGA_F1),

        .vidout(cdi_video_out),

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

        .ddrif(ddr_host),

        .slave_worm_adr (slave_worm_adr),
        .slave_worm_data(slave_worm_data),
        .slave_worm_wr  (slave_worm_wr),

        .nvram_backup_restore_adr(nvram_backup_restore_adr),
        .nvram_restore_data(nvram_restore_data),
        .nvram_backup_data(nvram_backup_data),
        .nvram_restore_write(nvram_restore_write),
        .nvram_cpu_changed(nvram_cpu_changed),
        .nvram_allow_cpu_access(nvram_allow_cpu_access),

        .slave_serial_in(slave_serial_in),
        .slave_serial_out(slave_serial_out),
        .slave_rts(slave_rts),

        .scc68070_bypass_serial_in(scc68070_bypass_serial_in),
        .scc68070_bypass_serial_out(scc68070_bypass_serial_out),
        .scc68070_rts(scc68070_rts),

        .rc_eye(rc_eye),

        .cd_seek_lba(cd_seek_lba),
        .cd_seek_lba_valid(cd_seek_lba_valid),
        .cd_stop_sector_delivery(cd_stop_sector_delivery),
        .cd_data_valid(cd_data_valid),
        .cd_data(cd_data),
        .cd_sector_tick(cd_sector_tick),
        .cd_sector_delivered(cd_sector_delivered),

        .cd_img_mount  (cd_img_mount),
        .cd_img_mounted(cd_img_mounted),
        .tray_is_closed,

        .audio_left (AUDIO_L),
        .audio_right(AUDIO_R),

        .fail_not_enough_words(fail_not_enough_words),
        .fail_too_much_data(fail_too_much_data),
        .config_disable_cpu_starve,
        .config_auto_play,
        .config_disable_vmpeg(config_disable_vmpeg),

        .hps_rtc(hps_rtc)
    );


    assign CLK_VIDEO = clk_sys;
    assign CE_PIXEL  = ce_pix;
`ifdef VERILATOR
    // when the videofreak is not used.
    assign VGA_DE = ~(HBlank | VBlank);
`endif
    assign VGA_HS = HSync;
    assign VGA_VS = VSync;
    assign VGA_R  = r;
    assign VGA_G  = g;
    assign VGA_B  = b;

    // ----- NvRAM Backup and Restore Handling -----

    // If set, a backup of NvRAM shall be performed as the content has changed.
    // Will be reset, as soon as a backup operation has begun
    // to allow yet another backup operation after the current one
    // to ensure the latest state on the SD card
    bit nvram_backup_pending = 0;

    // Make the USER LED indicate that we need to perform a backup
    assign LED_USER = nvram_backup_pending;

    enum bit [3:0] {
        NVRAM_IDLE,
        NVRAM_WAIT_FOR_ACK,
        NVRAM_BACKUP0,
        NVRAM_BACKUP1,
        NVRAM_BACKUP2,
        NVRAM_BACKUP3,
        NVRAM_RESTORE0,
        NVRAM_RESTORE1,
        NVRAM_RESTORE2
    } nvram_state;

    // Used to notice a change of the address
    bit sd_buff_addr_q;

    // Is set, if NvRAM image is mounted and usable
    bit nvram_img_mounted = 0;

    // Is set, if CD image is mounted and usable
    bit cd_img_mounted = 0;

    wire tray_is_closed;

    // Used to detect changes of OSD_STATUS
    bit OSD_STATUS_q;

    always_ff @(posedge clk_sys) begin
        info <= 0;
        info_req <= 0;
        sd_buff_addr_q <= sd_buff_addr[0];
        nvram_restore_write <= 0;
        OSD_STATUS_q <= OSD_STATUS;

        if (nvram_media_change) nvram_img_mounted <= (img_size != 0);
        if (cd_media_change) cd_img_mounted <= (img_size != 0);

        if (cditop_reset) begin
            nvram_backup_pending <= 0;
        end else if (nvram_cpu_changed && nvram_img_mounted) begin
            nvram_backup_pending <= 1;
        end

        if (nvram_hps_ack) begin
            nvram_hps_wr <= 0;
            nvram_hps_rd <= 0;
        end

        case (nvram_state)
            NVRAM_IDLE: begin
                nvram_allow_cpu_access   <= 1;
                nvram_backup_restore_adr <= 0;

                if (nvram_img_mount) begin
                    // NvRAM image mounted? Then restore that to NvRAM!
                    nvram_hps_rd <= 1;
                    nvram_state <= NVRAM_WAIT_FOR_ACK;
                    nvram_allow_cpu_access <= 0;
                end else if (nvram_backup_pending && OSD_STATUS && !OSD_STATUS_q) begin
                    // NvRAM has changed? And OSD was just opened? Well, then make a backup!
                    nvram_backup_pending <= 0;
                    nvram_hps_wr <= 1;
                    nvram_state <= NVRAM_WAIT_FOR_ACK;
                    nvram_allow_cpu_access <= 0;
                end
            end
            NVRAM_WAIT_FOR_ACK: begin
                if (nvram_hps_ack) begin
                    if (nvram_hps_rd) nvram_state <= NVRAM_RESTORE0;
                    if (nvram_hps_wr) nvram_state <= NVRAM_BACKUP0;
                end
            end
            NVRAM_BACKUP0: begin
                nvram_backup_restore_adr <= nvram_backup_restore_adr + 1;
                nvram_state <= NVRAM_BACKUP1;
            end
            NVRAM_BACKUP1: begin
                nvram_hps_din[7:0] <= nvram_backup_data;
                nvram_backup_restore_adr <= nvram_backup_restore_adr + 1;
                nvram_state <= NVRAM_BACKUP2;
            end
            NVRAM_BACKUP2: begin
                nvram_hps_din[15:8] <= nvram_backup_data;
                nvram_state <= NVRAM_BACKUP3;
            end
            NVRAM_BACKUP3: begin
                if (sd_buff_addr_q != sd_buff_addr[0]) begin
                    nvram_state <= NVRAM_BACKUP1;
                    nvram_backup_restore_adr <= nvram_backup_restore_adr + 1;
                end
                if (!nvram_hps_ack) nvram_state <= NVRAM_IDLE;
            end

            NVRAM_RESTORE0: begin
                if (sd_buff_wr) begin
                    nvram_restore_data_temp <= sd_buff_dout;
                    nvram_restore_write <= 1;
                    nvram_state <= NVRAM_RESTORE1;
                end

                if (!nvram_hps_ack) begin
                    nvram_state <= NVRAM_IDLE;
                    nvram_allow_cpu_access <= 1;
                end
            end
            NVRAM_RESTORE1: begin
                nvram_restore_write <= 1;
                nvram_backup_restore_adr <= nvram_backup_restore_adr + 1;
                nvram_state <= NVRAM_RESTORE2;
            end
            NVRAM_RESTORE2: begin
                nvram_backup_restore_adr <= nvram_backup_restore_adr + 1;
                nvram_state <= NVRAM_RESTORE0;
            end

            default: nvram_state <= NVRAM_IDLE;
        endcase
    end

endmodule

// It is unclear whether this is really required. For now it doesn't hurt.
module rc5_debouncer (
    input clk,
    input in,
    output bit out
);
    // The shortest pulse of RC5 is 439 microseconds
    // These are 13170 30 MHz ticks
    // We are going for 1024 ticks here to have a filter of 34 microseconds
    // Or let's only use 512 for half of it.

    bit [8:0] count;

    always_ff @(posedge clk) begin
        if (in && count != '1) count <= count + 1;
        else if (!in && count != '0) count <= count - 1;

        if (count[8:7] == 3) out <= 1;
        if (count[8:7] == 0) out <= 0;
    end
endmodule

// When replugging the controllers, we should force
// an RTS low phase to reset them.
module rts_forcer (
    input clk,
    input [2:0] config_state,
    output bit rts_flag,  // only a single clock cycle
    output rts_snac  // >10ms time for SNAC
);

    // According to "Technical Info Pointing Devices"
    // Device ID timing, the minimium RTS negation time
    // is 10ms without a defined maximum.
    // A 19 bit counter should work here.
    // It will start at 320000 and count down

    bit [18:0] count;
    bit [ 2:0] config_state_q;

    assign rts_snac = count != 0;

    always_ff @(posedge clk) begin
        config_state_q <= config_state;
        rts_flag <= 0;

        if (config_state_q != config_state) begin
            count <= 320000;
            rts_flag <= 1;
        end else if (count != 0) count <= count - 1;
    end

endmodule

module bytestream_mux (
    input use_b,
    bytestream.sink a,
    bytestream.sink b,
    bytestream.source dst
);
    assign dst.write = use_b ? b.write : a.write;
    assign dst.data  = use_b ? b.data : a.data;
endmodule
