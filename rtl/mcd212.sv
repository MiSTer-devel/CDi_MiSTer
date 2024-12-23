`include "bus.svh"
`include "videotypes.svh"

// MCD 212 - DRAM and Video

`define dp_vsr(statement) `ifdef DEBUG_VSR $display``statement `endif
`define dp_dca(statement) `ifdef DEBUG_DCA $display``statement `endif

`ifdef VERILATOR
function string coding_method_name(bit [3:0] coding, bit plane_b);
    if (plane_b) begin
        case (coding)
            4'b0000: coding_method_name = "OFF";
            4'b0001: coding_method_name = "CLUT8";
            4'b0011: coding_method_name = "CLUT7";
            4'b0100: coding_method_name = "CLUT7+7";
            4'b0101: coding_method_name = "DYUV";
            4'b1011: coding_method_name = "CLUT4";
            default: coding_method_name = "N/A";
        endcase
    end else begin
        case (coding)
            4'b0000: coding_method_name = "OFF";
            4'b0001: coding_method_name = "RGB555";
            4'b0011: coding_method_name = "CLUT7";
            4'b0101: coding_method_name = "DYUV";
            4'b1011: coding_method_name = "CLUT4";
            default: coding_method_name = "N/A";
        endcase
    end
endfunction
`endif

module mcd212 (
    input clk,
    input reset,
    input [22:1] cpu_address,
    input [15:0] cpu_din,
    output bit [15:0] cpu_dout,
    input cpu_uds,
    input cpu_lds,
    input cpu_write_strobe,
    output bit cpu_bus_ack,
    input cs,

    output     [7:0] r,
    output     [7:0] g,
    output     [7:0] b,
    output           hsync,
    output           vsync,
    output bit       hblank,
    output           vblank,

    output bit [24:0] sdram_addr,
    output bit        sdram_rd,
    output bit        sdram_wr,
    output bit        sdram_word,
    output bit [15:0] sdram_din,
    input      [15:0] sdram_dout,
    input             sdram_busy,
    output bit        sdram_burst,
    output bit        sdram_refresh,
    input             sdram_burstdata_valid,

    output irq,

    input [1:0] debug_force_video_plane
);

    // Memory Swapping according to chapter 3.4
    // of MCD212 datasheet.
    bit [3:0] early_rom_cnt = 0;
    wire cs_early_rom = early_rom_cnt < 4;
    always_ff @(posedge clk) begin
        // first 4 memory accesses must be mapped to ROM
        if (reset) begin
            early_rom_cnt <= 0;
        end else if (cs && cpu_uds && cs_early_rom && cpu_bus_ack) begin
            early_rom_cnt <= early_rom_cnt + 1;
        end
    end


    wire [22:0] cpu_addressb = {cpu_address[22:1], 1'b0};
    // implementation of memory map according to MCD212 datasheet
    wire cs_ram = cpu_addressb <= 23'h3fffff && cs && !cs_early_rom;  // 4MB
    wire cs_rom = cpu_addressb >= 23'h400000 && cpu_addressb <= 23'h4ffbff && cs;
    wire cs_system_io = cpu_addressb >= 23'h4ffc00 && cpu_addressb <= 23'h4fffdf && cs;
    wire cs_channel2 = cpu_addressb >= 23'h4fffe0 && cpu_addressb <= 23'h4fffef && cs;
    wire cs_channel1 = cpu_addressb >= 23'h4ffff0 && cpu_addressb <= 23'h4fffff && cs;

    wire cs_rom_fused = (cs_rom || cs_early_rom) && cs;

    // Bit 18 is the Bank selection for TD=0
    // CAS1 if A18=0, CAS2 if A18=1
    // TODO This might be not accurate. Investigation needed
    //wire [19:1] ram_address = {cpu_address[18], cpu_address[21], cpu_address[17:1]};
    wire [19:1] ram_address = {cpu_address[21], cpu_address[18], cpu_address[17:1]};

    bit sdram_busy_q = 0;
    bit parity = 0;

    bit [21:0] ica0_adr;
    bit ica0_as;
    bit ica0_bus_ack;
    bit ica0_burstdata_valid;

    bit [21:0] file0_adr;
    bit file0_as;
    bit file0_bus_ack;
    bit file0_burstdata_valid;

    bit [21:0] ica1_adr;
    bit ica1_as;
    bit ica1_bus_ack;
    bit ica1_burstdata_valid;

    bit [21:0] file1_adr;
    bit file1_as;
    bit file1_bus_ack;
    bit file1_burstdata_valid;

    wire cpu_sdram_access = (cs_ram || cs_rom_fused) && (cpu_uds || cpu_lds);
    wire sdram_refresh_request;

    typedef enum bit [3:0] {
        REFRESH,   // most important
        ICA_DCA0,
        ICA_DCA1,
        FILE0,
        FILE1,
        CPU        // least important
    } e_arbit_target;

    // must only be changed if sdram_busy == false
    e_arbit_target sdram_owner;
    e_arbit_target sdram_owner_q;
    e_arbit_target sdram_owner_next;

`ifdef VERILATOR
    // add a check to assert that sdram_owner is never changed during memory access
    always_ff @(posedge clk) begin
        if (sdram_busy) assert (sdram_owner_q == sdram_owner);
    end
`endif

    always_comb begin
        sdram_owner_next = CPU;
        if (file1_as) sdram_owner_next = FILE1;
        if (file0_as) sdram_owner_next = FILE0;
        if (ica1_as) sdram_owner_next = ICA_DCA1;
        if (ica0_as) sdram_owner_next = ICA_DCA0;
        if (sdram_refresh_request) sdram_owner_next = REFRESH;

        if (sdram_busy) sdram_owner = sdram_owner_q;
        else sdram_owner = sdram_owner_next;
    end

    bit video_fail = 0;

    struct packed {
        bit [7:0] reserved3;
        bit da;  // display active
        bit reserved2;
        bit pa;  // parity, 1 odd, 0 even frame
        bit [4:0] reserved1;
    } status_register1;

    struct packed {
        bit [7:0] reserved3;
        bit [4:0] reserved;
        bit it1;  // Channel 0 Interrupt Pending
        bit it2;  // Channel 1 Interrupt Pending
        bit be;
    } status_register2;

    // according to chapter 3.8 INTERRUPT GENERATION
    assign irq = (status_register2.it1 && !control_register_crsr1w.di1) || 
                    (status_register2.it2 && !control_register_crsr2w.di2);

`ifdef VERILATOR
    bit irq_q = 0;
    always_ff @(posedge clk) begin
        irq_q <= irq;

        if (irq && !irq_q) $display("VIDEO IRQ 1");
        if (!irq && irq_q) $display("VIDEO IRQ 0");
    end
`endif

    wire display_active;

    always_comb begin
        status_register1 = 0;
        // TODO This might not be accurate
        status_register1.da = display_active;
        status_register1.pa = parity;
    end

    always_comb begin
        cpu_dout = 0;
        sdram_burst = 0;
        sdram_refresh = 0;

        // per default everything is acked but not SDRAM
        cpu_bus_ack = !cpu_sdram_access;
        file0_bus_ack = 0;
        file0_burstdata_valid = 0;
        ica0_bus_ack = 0;
        ica0_burstdata_valid = 0;

        file1_bus_ack = 0;
        file1_burstdata_valid = 0;
        ica1_bus_ack = 0;
        ica1_burstdata_valid = 0;

        sdram_rd = 0;
        sdram_wr = 0;
        sdram_word = 0;
        sdram_addr = 0;

        if (!reset) begin
            case (sdram_owner)
                REFRESH: begin
                    // keep reading the same address to force auto refresh
                    sdram_refresh = 1;
                    sdram_rd = !sdram_busy;
                end
                ICA_DCA0: begin
                    sdram_word = 1;

                    if (ica0_as) begin
                        sdram_addr[19:1] = ica0_adr[19:1];
                        sdram_rd = !sdram_busy && !sdram_busy_q;
                        sdram_burst = 1;
                    end

                end
                FILE0: begin
                    sdram_word = 1;

                    if (file0_as) begin
                        sdram_addr[19:1] = file0_adr[19:1];
                        sdram_rd = !sdram_busy && !sdram_busy_q;
                        sdram_burst = 1;
                    end
                end
                ICA_DCA1: begin
                    sdram_word = 1;

                    if (ica1_as) begin
                        sdram_addr[18:1] = ica1_adr[18:1];
                        sdram_addr[19] = 1;  // TODO investigate
                        sdram_rd = !sdram_busy && !sdram_busy_q;
                        sdram_burst = 1;
                    end
                end
                FILE1: begin
                    sdram_word = 1;

                    if (file1_as) begin
                        sdram_addr[18:1] = file1_adr[18:1];
                        sdram_addr[19] = 1;  // TODO investigate
                        sdram_rd = !sdram_busy && !sdram_busy_q;
                        sdram_burst = 1;
                    end
                end
                CPU: begin
                    if (cpu_sdram_access) begin
                        if (cs_rom_fused) begin
                            sdram_word = 1;
                            sdram_addr[24:1] = {3'b001, cpu_address[21:1]};
                            sdram_addr[0] = 1'b0;
                            sdram_rd = !sdram_busy && !sdram_busy_q;
                            sdram_wr = 1'b0;
                        end else begin
                            sdram_addr[24:1] = {5'b0, ram_address[19:1]};
                            sdram_addr[0] = cpu_write_strobe ? !cpu_lds && cpu_uds : 1'b0;  // only active on odd byte accesses
                            sdram_word = (cpu_lds && cpu_uds) || !cpu_write_strobe;
                            sdram_rd = cs_ram && !cpu_write_strobe && !sdram_busy && !sdram_busy_q;
                            sdram_wr = cs_ram && cpu_write_strobe && !sdram_busy && !sdram_busy_q;
                        end

                    end
                end
                default: begin
                end
            endcase

            case (sdram_owner_q)
                CPU: begin
                    if (cpu_sdram_access) begin
                        cpu_bus_ack = !sdram_busy && sdram_busy_q;
                    end
                end
                FILE0: begin
                    if (file0_as) begin
                        file0_bus_ack = !sdram_busy && sdram_busy_q;
                        file0_burstdata_valid = sdram_burstdata_valid;
                    end
                end
                ICA_DCA0: begin
                    if (ica0_as) begin
                        ica0_bus_ack = !sdram_busy && sdram_busy_q;
                        ica0_burstdata_valid = sdram_burstdata_valid;
                    end
                end
                FILE1: begin
                    if (file1_as) begin
                        file1_bus_ack = !sdram_busy && sdram_busy_q;
                        file1_burstdata_valid = sdram_burstdata_valid;
                    end

                end
                ICA_DCA1: begin
                    if (ica1_as) begin
                        ica1_bus_ack = !sdram_busy && sdram_busy_q;
                        ica1_burstdata_valid = sdram_burstdata_valid;
                    end
                end
                default: begin
                end

            endcase
        end
        // only the CPU writes to SDRAM
        sdram_din = cpu_din;

        if (cs_ram || cs_rom_fused) begin
            cpu_dout = sdram_dout;
        end else if (cs_channel1) begin
            case (cpu_addressb[7:0])
                8'hf0: begin
                    cpu_dout = status_register1;
                end
                default: cpu_dout = 16'h0;
            endcase
        end else if (cs_channel2) begin
            case (cpu_addressb[7:0])
                8'he0: begin
                    cpu_dout = status_register2;
                end
                default: cpu_dout = 16'h0;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            sdram_busy_q <= 0;
            sdram_owner_q <= CPU;
            video_fail <= 0;
        end else begin
            sdram_busy_q  <= sdram_busy;
            sdram_owner_q <= sdram_owner;

            if (file0_as && ica0_as) video_fail <= 1;
            //if (file1_as && ica1_as) video_fail <= 1;

            // Ensure ICA list has ended before FILE access
            //assert (!(file0_as && ica0_as));
            //assert (!(file1_as && ica1_as));
        end

        /*
        if ((cpu_lds || cpu_uds) && cs_ram && !cpu_write_strobe && cpu_bus_ack) 
            $display("Read DRAM %x %x", cpu_addressb, cpu_dout);
        
        if (cpu_lds && cpu_uds && cs_ram && cpu_write_strobe) begin
            $display("Write DRAM %x %x", cpu_addressb, cpu_din);
            assert (!(cpu_addressb==0 && cpu_din ==16'h5aa5));
        end else if (cpu_lds && cs_ram && cpu_write_strobe)
            $display("Write Lower Byte RAM %x %x", cpu_addressb, cpu_din);
        else if (cpu_uds && cs_ram && cpu_write_strobe)
            $display("Write Upper Byte RAM %x %x", cpu_addressb, cpu_din);


        if ((cpu_lds || cpu_uds) && cs_channel1 && !cpu_write_strobe)
            $display("Read Channel 1 %x %x", cpu_addressb, cpu_dout);

        if ((cpu_lds || cpu_uds) && cs_channel2 && !cpu_write_strobe)
            $display("Read Channel 2 %x %x", cpu_addressb, cpu_dout);

        if ((cpu_lds || cpu_uds) && cs_system_io && cpu_write_strobe)
            $display("Write Sys %x %x", cpu_addressb, cpu_din);
        */

        if ((cpu_lds || cpu_uds) && cs_channel1 && cpu_write_strobe)
            $display("Write Channel 1 %x %x", cpu_addressb, cpu_din);

        if ((cpu_lds || cpu_uds) && cs_channel2 && cpu_write_strobe)
            $display("Write Channel 2 %x %x", cpu_addressb, cpu_din);
    end

    wire [8:0] video_y;
    wire [12:0] video_x;
    wire new_frame  /*verilator public_flat_rd*/;
    wire new_line;
    wire new_pixel;
    wire new_pixel_lores;
    wire new_pixel_hires;
    bit hblank_vt;
    bit hblank_vt_q;

    // we should have 8-9 refresh cycles per horizontal line
    // to fulfill 8192 refreshes per 64ms 
    assign sdram_refresh_request = video_x < 190 && video_x > 130;

    video_timing vt (
        .clk,
        .reset,
        .sm(command_register_dcr1.sm),
        .cf(1),  // TODO CF=1 Only accept TV resolutions for now
        .st(control_register_crsr1w.st),
        .cm(0),  // TODO Correct source
        .fd(command_register_dcr1.fd),
        .video_y(video_y),
        .video_x(video_x),
        .hsync(hsync),
        .vsync(vsync),
        .hblank(hblank_vt),
        .vblank(vblank),
        .new_frame(new_frame),
        .new_line(new_line),
        .new_pixel(new_pixel),
        .new_pixel_lores(new_pixel_lores),
        .new_pixel_hires(new_pixel_hires),
        .display_active(display_active)
    );


    struct packed {
        bit de;
        bit cf;  // 0=28MHz, 1=30 MHz in PAL and 30.2097 MHz in NTSC
        bit fd;  // 0=50 Hz, 1=60 Hz
        bit sm;  // 0=Non-interlace, 1=Interlace
        bit cm1;  // Probably ignored..
        bit reserved1;
        bit ic1;
        bit dc1;
        bit [1:0] reserved2;
        bit [5:0] adr;
    } command_register_dcr1  /*verilator public_flat_rw*/;

    struct packed {
        bit [3:0] reserved1;
        bit cm2;  // Pixel frequency
        bit reserved2;
        bit ic2;
        bit dc2;
        bit [1:0] reserved3;
        bit [5:0] adr;
    } command_register_dcr2;

    struct packed {
        bit mf1;
        bit mf2;
        bit ft1;
        bit ft2;
        bit [5:0] adr;
    } display_decoder_register_ddr1;

    struct packed {
        bit mf1;
        bit mf2;
        bit ft1;
        bit ft2;
        bit [5:0] adr;
    } display_decoder_register_ddr2;

    struct packed {
        bit di1;
        bit st;
    } control_register_crsr1w  /*verilator public_flat_rw*/;

    struct packed {bit di2;} control_register_crsr2w;

    display_parameters_s ica0_disp_param_out;
    display_parameters_s ica1_disp_param_out;

    always_ff @(posedge clk) begin
        if (reset) begin
            command_register_dcr1 <= 0;
            command_register_dcr2 <= 0;
            control_register_crsr1w <= 0;
            control_register_crsr2w <= 0;
            display_decoder_register_ddr1 <= 0;
            display_decoder_register_ddr2 <= 0;
            status_register2 <= 0;
        end else begin

            if (ica0_disp_param_out.strobe) begin
                display_decoder_register_ddr1.mf1 <= ica0_disp_param_out.mf1;
                display_decoder_register_ddr1.mf2 <= ica0_disp_param_out.mf2;
                display_decoder_register_ddr1.ft1 <= ica0_disp_param_out.ft1;
                display_decoder_register_ddr1.ft2 <= ica0_disp_param_out.ft2;
                command_register_dcr1.cm1 <= ica0_disp_param_out.cm;
            end

            if (ica1_disp_param_out.strobe) begin
                display_decoder_register_ddr2.mf1 <= ica1_disp_param_out.mf1;
                display_decoder_register_ddr2.mf2 <= ica1_disp_param_out.mf2;
                display_decoder_register_ddr2.ft1 <= ica1_disp_param_out.ft1;
                display_decoder_register_ddr2.ft2 <= ica1_disp_param_out.ft2;
                command_register_dcr2.cm2 <= ica1_disp_param_out.cm;
            end

            if ((cpu_lds || cpu_uds) && cs_channel1 && cpu_write_strobe) begin
                if (cpu_addressb[3:0] == 4'h2) begin
                    command_register_dcr1 <= cpu_din;
                    $display("DCR1 set to %x", cpu_din);
                    assert (cpu_lds && cpu_uds);
                end

                if (cpu_addressb[3:0] == 4'h0 && cpu_uds) begin
                    control_register_crsr1w.di1 <= cpu_din[15];
                    assert (cpu_lds && cpu_uds);
                end

                if (cpu_addressb[3:0] == 4'h0 && cpu_lds) begin
                    control_register_crsr1w.st <= cpu_din[1];
                    assert (cpu_lds && cpu_uds);
                end
            end

            if ((cpu_lds || cpu_uds) && cs_channel2 && cpu_write_strobe) begin
                if (cpu_addressb[3:0] == 4'h2) begin
                    command_register_dcr2 <= cpu_din;
                end
                if (cpu_addressb[3:0] == 4'h0) begin
                    control_register_crsr2w.di2 <= cpu_din[15];
                end
            end

            if (cpu_lds && cs_channel2 && !cpu_write_strobe && cpu_addressb[3:0] == 0) begin
                status_register2 <= 0;
            end

            if (ica0_irq) status_register2.it1 <= 1;
            if (ica1_irq) status_register2.it2 <= 1;
        end
    end


    typedef struct packed {
        bit [3:0] op;  // Operation Control Code
        bit rf;  // Region Flag
        bit [5:0] wf;  // Next Weight Factor
        bit [9:0] x;  // Distance from lefthand edge of display, double resolution
    } region_entry;

    region_entry region_control[8];

    clut_entry_s clut_out0;
    clut_entry_s clut_out1;

    clut_entry_s clut_wr_data0;
    clut_entry_s clut_wr_data1;
    bit [7:0] clut_wr_addr0;
    bit [7:0] clut_wr_addr1;

    bit [7:0] clut_addr0;
    bit [7:0] clut_addr1;
    bit clut_we0;
    bit clut_we1;

    clut_dual_port_memory clutmem (
        .clk(clk),
        .data_a(clut_wr_data0),
        .addr_a(clut_addr0),
        .we_a(clut_we0),
        .q_a(clut_out0),
        .data_b(clut_wr_data1),
        .addr_b(clut_addr1),
        .we_b(clut_we1),
        .q_b(clut_out1)
    );

    clut_entry_s trans_color_plane_a;
    clut_entry_s trans_color_plane_b;
    clut_entry_s mask_color_plane_a;
    clut_entry_s mask_color_plane_b;

    wire [15:0] ica0_din = sdram_dout;
    wire [15:0] ica1_din = sdram_dout;

    bit [6:0] ch0_register_adr;
    bit [23:0] ch0_register_data;
    bit ch0_register_write;

    bit ica0_reload_vsr;
    bit [21:0] ica0_vsr;
    bit ica0_irq;

    bit [6:0] ch1_register_adr;
    bit [23:0] ch1_register_data;
    bit ch1_register_write;

    bit ica1_reload_vsr;
    bit [21:0] ica1_vsr;
    bit ica1_irq;

    wire dca0_read = hblank_vt && !hblank_vt_q && !vblank && command_register_dcr1.dc1;
    ica_dca_ctrl #(
        .unit_index(0)
    ) ica0 (
        .clk,
        .reset(new_frame || reset || !command_register_dcr1.ic1),
        .address(ica0_adr),
        .as(ica0_as),
        .din(ica0_din),
        .bus_ack(ica0_bus_ack),
        .burstdata_valid(ica0_burstdata_valid),
        .register_adr(ch0_register_adr),
        .register_data(ch0_register_data),
        .register_write(ch0_register_write),
        .reload_vsr(ica0_reload_vsr),
        .vsr(ica0_vsr),
        .irq(ica0_irq),
        .disp_params(ica0_disp_param_out),
        // Fire at end of visible lines
        .dca_read(dca0_read),
        .hblank(hblank)
    );

    wire dca1_read = hblank_vt && !hblank_vt_q && !vblank && command_register_dcr2.dc2;
    ica_dca_ctrl #(
        .unit_index(1)
    ) ica1 (
        .clk,
        .reset(new_frame || reset || !command_register_dcr2.ic2),
        .address(ica1_adr),
        .as(ica1_as),
        .din(ica1_din),
        .bus_ack(ica1_bus_ack),
        .burstdata_valid(ica1_burstdata_valid),
        .register_adr(ch1_register_adr),
        .register_data(ch1_register_data),
        .register_write(ch1_register_write),
        .reload_vsr(ica1_reload_vsr),
        .vsr(ica1_vsr),
        .irq(ica1_irq),
        .disp_params(ica1_disp_param_out),
        // Fire at end of visible lines
        .dca_read(dca1_read),
        .hblank(hblank)
    );

    wire [15:0] file0_din = sdram_dout;
    wire [15:0] file1_din = sdram_dout;

    always_ff @(posedge clk) begin
        if (reset) begin
            hblank_vt_q <= 0;
            hblank <= 0;
            parity <= 0;
        end else begin
            hblank_vt_q <= hblank_vt;
            hblank <= hblank_vt_q;

            // TODO Remove this
            if (new_frame) parity <= !parity;
        end

    end

    pixelstream file0_out (.clk);

    // Plane A Display File Decoder
    display_file_decoder #(
        .unit_index(0)
    ) file0 (
        .clk,
        .reset(new_frame || reset || !command_register_dcr1.ic1),
        .address(file0_adr),
        .as(file0_as),
        .din(file0_din),
        .bus_ack(file0_bus_ack),
        .reload_vsr(ica0_reload_vsr),
        .burstdata_valid(file0_burstdata_valid),
        .vsr_in(ica0_vsr),
        .out(file0_out),
        .read_pixels(!vblank && image_coding_method_register.cm13_10_planea != 0)
    );


    pixelstream file1_out (.clk);

    display_file_decoder #(
        .unit_index(1)
    ) file1 (
        .clk,
        .reset(new_frame || reset || !command_register_dcr2.ic2),
        .address(file1_adr),
        .as(file1_as),
        .din(file1_din),
        .bus_ack(file1_bus_ack),
        .reload_vsr(ica1_reload_vsr),
        .burstdata_valid(file1_burstdata_valid),
        .vsr_in(ica1_vsr),
        .out(file1_out),
        .read_pixels(!vblank && image_coding_method_register.cm23_20_planeb != 0)
    );

    pixelstream dyuv0_in (.clk);
    pixelstream dyuv1_in (.clk);
    pixelstream rle0_in (.clk);
    pixelstream rle1_in (.clk);

    pixelstream_demux demux0 (
        .use_b(plane_a_dyuv_active),
        .in(file0_out),
        .b(dyuv0_in),
        .a(rle0_in)
    );

    pixelstream_demux demux1 (
        .use_b(plane_b_dyuv_active),
        .in(file1_out),
        .b(dyuv1_in),
        .a(rle1_in)
    );

    pixelstream rle0_out (.clk);
    pixelstream rle1_out (.clk);

    clut_rle rle0 (
        .clk,
        .reset(vblank || reset || ica0_reload_vsr),
        .st(control_register_crsr1w.st),
        .src(rle0_in),
        .dst(rle0_out),
        .passthrough(!display_decoder_register_ddr1.ft1)
    );

    clut_rle rle1 (
        .clk,
        .reset(vblank || reset || ica1_reload_vsr),
        .st(control_register_crsr1w.st),
        .src(rle1_in),
        .dst(rle1_out),
        .passthrough(!display_decoder_register_ddr2.ft1)
    );


    rgb888_s dyuv0_out;
    rgb888_s dyuv1_out;
    yuv_s dyuv0_abs_start;
    yuv_s dyuv1_abs_start;
    wire dyuv0_write;
    wire dyuv0_strobe;
    wire dyuv1_write;
    wire dyuv1_strobe;

    delta_yuv_decoder dyuv0 (
        .clk,
        .reset(reset || ica0_reload_vsr || vblank || new_line),
        .st(control_register_crsr1w.st),
        .absolute_start_yuv(dyuv0_abs_start),
        .src(dyuv0_in),
        .rgb_out(dyuv0_out),
        .write(dyuv0_write),
        .strobe(dyuv0_strobe)
    );

    delta_yuv_decoder dyuv1 (
        .clk,
        .reset(reset || ica1_reload_vsr || vblank || new_line),
        .st(control_register_crsr1w.st),
        .absolute_start_yuv(dyuv1_abs_start),
        .src(dyuv1_in),
        .rgb_out(dyuv1_out),
        .write(dyuv1_write),
        .strobe(dyuv1_strobe)
    );

    assign rle0_out.strobe = new_pixel;
    assign rle1_out.strobe = new_pixel;
    assign dyuv0_strobe = new_pixel;
    assign dyuv1_strobe = new_pixel;

    bit [7:0] synchronized_pixel0;
    bit [7:0] synchronized_pixel1;
    bit fail = 0;

    always_comb begin
        // CLUT7
        clut_addr0 = {1'b0, synchronized_pixel0[6:0]};

        // CLUT8 (only on Plane A)
        if (image_coding_method_register.cm13_10_planea == 4'b0001)
            clut_addr0 = synchronized_pixel0;

        // CLUT4
        if (image_coding_method_register.cm13_10_planea == 4'b1011)
            clut_addr0 = {4'b0000, synchronized_pixel0[7:4]};

        if (clut_we0) clut_addr0 = clut_wr_addr0;
    end

    always_comb begin
        // Setting highest bit according to Figure 7-2 for CLUT7
        clut_addr1 = {1'b1, synchronized_pixel1[6:0]};

        // CLUT4
        if (image_coding_method_register.cm23_20_planeb == 4'b1011)
            clut_addr1 = {4'b1000, synchronized_pixel1[7:4]};

        if (clut_we1) clut_addr1 = clut_wr_addr1;
    end

    always_ff @(posedge clk) begin
        if (new_line) begin
            synchronized_pixel0 <= 0;
            synchronized_pixel1 <= 0;
        end else begin
            if (rle0_out.write && rle0_out.strobe) synchronized_pixel0 <= rle0_out.pixel;
            if (rle1_out.write && rle1_out.strobe) synchronized_pixel1 <= rle1_out.pixel;

            // Implement CLUT4 shifting
            if (image_coding_method_register.cm13_10_planea == 4'b1011 && new_pixel_hires && !new_pixel_lores)
                synchronized_pixel0[7:4] <= synchronized_pixel0[3:0];
            if (image_coding_method_register.cm23_20_planeb == 4'b1011 && new_pixel_hires && !new_pixel_lores)
                synchronized_pixel1[7:4] <= synchronized_pixel1[3:0];
        end
    end

    always_ff @(posedge clk) begin
        if (ica0_reload_vsr) `dp_vsr(("Reload VSR %x", ica0_vsr));

        if (dca0_read) `dp_dca(("Start DCA0 on line %d", video_y));
        if (dca1_read) `dp_dca(("Start DCA1 on line %d", video_y));
    end


    bit [15:0] cursor[16];
    bit [1:0] clut_bank0;
    bit [1:0] clut_bank1;

    struct packed {
        bit [1:0] reserved1;
        bit [9:0] y;
        bit [1:0] reserved2;
        bit [9:0] x;
    } cursor_position_reg;

    struct packed {
        bit en;
        bit blkc;  // blink type
        bit [2:0] con;
        bit [2:0] cof;
        bit cuw;
        bit [10:0] reserved1;
        bit y;  // 1 full brightness, 0 half brightness
        bit r;
        bit g;
        bit b;
    } cursor_control_register;

    struct packed {
        bit y;  // 1 full brightness, 0 half brightness
        bit r;
        bit g;
        bit b;
    } backdrop_color_register;

    struct packed {
        bit cs;  // CLUT select for dual 7-bit CLUT
        bit nr;  // 0 One region flag, 1 Two region flags used
        bit ev;  // External video enable
        bit [3:0] cm23_20_planeb;
        bit [3:0] cm13_10_planea;
    } image_coding_method_register;

    struct packed {
        bit mx;
        bit [3:0] tb;
        bit [3:0] ta;
    } transparency_control_register;

    bit [5:0] weight_a;
    bit [5:0] weight_b;

    bit [9:0] active_line = 0;
    bit [9:0] active_pixel = 0;

    bit [15:0] active_cursor_line;
    bit cursor_pixel;
    bit inside_cursor_window;
    bit plane_b_in_front_of_a;

    // mouse cursor
    always_ff @(posedge clk) begin
        // TODO Initial values might not be correct. Adapt to rest of video timing.
        // TODO I'm also very unsure about the width of sprites. What is double? What is normal?
        // Accoring to chapter 7.6 the position is always based on double resolution
        if (hblank) active_pixel <= 0;
        else if (new_pixel_hires) active_pixel <= active_pixel + 1;

        if (vblank) active_line <= -1;
        else if (new_line) active_line <= active_line + 1;

        active_cursor_line <= cursor[4'(active_line-cursor_position_reg.y)];

        if (cursor_control_register.cuw) begin
            // Double Resolution
            inside_cursor_window <= (active_line >= cursor_position_reg.y) && (active_line < cursor_position_reg.y + 16) && 
                                    (active_pixel > cursor_position_reg.x) && (active_pixel <= cursor_position_reg.x + 16);
            cursor_pixel <= active_cursor_line[4'(cursor_position_reg.x-active_pixel)];

        end else begin
            // Normal Resolution - double the width
            inside_cursor_window <= (active_line >= cursor_position_reg.y) && (active_line < cursor_position_reg.y + 16) && 
                                    (active_pixel > cursor_position_reg.x) && (active_pixel <= cursor_position_reg.x + 32);
            cursor_pixel <= active_cursor_line[4'((cursor_position_reg.x-active_pixel)>>1)];
        end
    end

    // color mixing
    rgb888_s plane_a;
    rgb888_s plane_b;
    rgb888_s vidout;

    function clut_entry_s RGB888ToClut(input rgb888_s rgb);
        RGB888ToClut.r = rgb.r[7:2];
        RGB888ToClut.g = rgb.g[7:2];
        RGB888ToClut.b = rgb.b[7:2];
    endfunction

    assign {r, g, b} = {vidout.r, vidout.g, vidout.b};

    bit plane_a_visible;
    bit plane_b_visible;

    bit [1:0] region_flags = 0;

    wire plane_a_dyuv_active = image_coding_method_register.cm13_10_planea == 4'b0101;
    wire plane_b_dyuv_active = image_coding_method_register.cm23_20_planeb == 4'b0101;

    // Ignore Color Key for DYUV. Use it only for CLUT!
    wire plane_a_color_key_match = (clut_out0 == trans_color_plane_a) && !plane_a_dyuv_active;
    wire plane_b_color_key_match = (clut_out1 == trans_color_plane_b) && !plane_b_dyuv_active;

    function automatic [7:0] WeightCalc(input [7:0] rgb, input [5:0] weight);
        if (weight == 0) begin
            WeightCalc = 0;
        end else begin
            WeightCalc = 8'((15'(rgb) * (15'(weight) + 15'd1)) >> 6);
        end
    endfunction

    always_comb begin
        bit plane_a_transparent;  // Because logic in datasheet is also inverted
        bit [7:0] r, g, b;
        plane_a_transparent = 1;
        r = {clut_out0.r, 2'b00};
        g = {clut_out0.g, 2'b00};
        b = {clut_out0.b, 2'b00};

        if (plane_a_dyuv_active) begin
            r = dyuv0_out.r;
            g = dyuv0_out.g;
            b = dyuv0_out.b;
        end

        plane_a.r = WeightCalc(r, weight_a);
        plane_a.g = WeightCalc(g, weight_a);
        plane_a.b = WeightCalc(b, weight_a);

        if (image_coding_method_register.cm13_10_planea != 0 && command_register_dcr1.ic1) begin
            // Use only the lower 3 bits first as the highest bit just inverts the result

            assert (transparency_control_register.ta[2:0] != 3'b010);  // Transparency Bit?
            assert (transparency_control_register.ta[2:0] != 3'b111);  // N.U.
            case (transparency_control_register.ta[2:0])
                // Always (Plane Disabled)
                3'b000:  plane_a_transparent = 1;
                // Color Key = True
                3'b001:  plane_a_transparent = plane_a_color_key_match;
                // Region Flag 0
                3'b011:  plane_a_transparent = region_flags[0];
                // Region Flag 1
                3'b100:  plane_a_transparent = region_flags[1];
                // Region Flag 0 or Color Key = True
                3'b101:  plane_a_transparent = plane_a_color_key_match || region_flags[0];
                // Region Flag 1 or Color Key = True
                3'b110:  plane_a_transparent = plane_a_color_key_match || region_flags[1];
                // N.U.
                default: plane_a_transparent = 0;
            endcase

            // Invert original result
            if (transparency_control_register.ta[3]) plane_a_transparent = !plane_a_transparent;

            // Jeopardy Hack for Plane A just in case it's used elsewhere
            // This case is not defined in the datasheet
            if (transparency_control_register.ta == 4'b1001 && plane_a_dyuv_active)
                plane_a_transparent = 0;
        end
        plane_a_visible = !plane_a_transparent;
    end

    always_comb begin
        bit plane_b_transparent;  // Because logic in datasheet is also inverted
        bit [7:0] r, g, b;
        plane_b_transparent = 1;
        r = {clut_out1.r, 2'b00};
        g = {clut_out1.g, 2'b00};
        b = {clut_out1.b, 2'b00};

        if (plane_b_dyuv_active) begin
            r = dyuv1_out.r;
            g = dyuv1_out.g;
            b = dyuv1_out.b;
        end

        plane_b.r = WeightCalc(r, weight_b);
        plane_b.g = WeightCalc(g, weight_b);
        plane_b.b = WeightCalc(b, weight_b);

        if (image_coding_method_register.cm23_20_planeb != 0 && command_register_dcr2.ic2) begin
            // Use only the lower 3 bits first as the highest bit just inverts the result

            assert (transparency_control_register.tb[2:0] != 3'b010);  // Transparency Bit?
            assert (transparency_control_register.tb[2:0] != 3'b111);  // N.U.
            case (transparency_control_register.tb[2:0])
                // Always (Plane Disabled)
                3'b000:  plane_b_transparent = 1;
                // Color Key = True
                3'b001:  plane_b_transparent = plane_b_color_key_match;
                // Region Flag 0
                3'b011:  plane_b_transparent = region_flags[0];
                // Region Flag 1
                3'b100:  plane_b_transparent = region_flags[1];
                // Region Flag 0 or Color Key = True
                3'b101:  plane_b_transparent = plane_b_color_key_match || region_flags[0];
                // Region Flag 1 or Color Key = True
                3'b110:  plane_b_transparent = plane_b_color_key_match || region_flags[1];
                // N.U.
                default: plane_b_transparent = 0;
            endcase

            // Invert original result
            if (transparency_control_register.tb[3]) plane_b_transparent = !plane_b_transparent;

            // Jeopardy Hack
            // This case is not defined in the datasheet
            if (transparency_control_register.tb == 4'b1001 && plane_b_dyuv_active)
                plane_b_transparent = 0;
        end
        plane_b_visible = !plane_b_transparent;

    end

    function automatic [7:0] clamped_mix(input [7:0] a, input [7:0] b);
        bit [8:0] sum = a + b;
        if (sum > 255) clamped_mix = 255;
        else clamped_mix = sum[7:0];
    endfunction

    always_comb begin
        // start with the backdrop color
        vidout.r = backdrop_color_register.r ? 8'hff : 0;
        vidout.g = backdrop_color_register.g ? 8'hff : 0;
        vidout.b = backdrop_color_register.b ? 8'hff : 0;
        if (!backdrop_color_register.y) begin
            // Half brightness
            vidout.r[7] = 0;
            vidout.g[7] = 0;
            vidout.b[7] = 0;
        end

        if (transparency_control_register.mx) begin
            // No Mix. Only overlay
            if (plane_b_in_front_of_a) begin
                if (plane_a_visible) vidout = plane_a;
                if (plane_b_visible) vidout = plane_b;
            end else begin
                if (plane_b_visible) vidout = plane_b;
                if (plane_a_visible) vidout = plane_a;
            end
        end else begin
            // Perform mixing
            if (plane_a_visible && plane_b_visible) begin
                vidout.r = clamped_mix(plane_a.r, plane_b.r);
                vidout.g = clamped_mix(plane_a.g, plane_b.g);
                vidout.b = clamped_mix(plane_a.b, plane_b.b);
            end else if (plane_a_visible) begin
                vidout = plane_a;
            end else if (plane_b_visible) begin
                vidout = plane_b;
            end
        end

        if (debug_force_video_plane == 2'b01) vidout = plane_a;
        else if (debug_force_video_plane == 2'b10) vidout = plane_b;

        // cursor
        if (cursor_pixel && inside_cursor_window && cursor_control_register.en) begin
            vidout.r = cursor_control_register.r ? 8'hff : 0;
            vidout.g = cursor_control_register.g ? 8'hff : 0;
            vidout.b = cursor_control_register.b ? 8'hff : 0;

            if (!cursor_control_register.y) begin
                // Half brightness
                vidout.r[7] = 0;
                vidout.g[7] = 0;
                vidout.b[7] = 0;
            end
        end
    end

    // Implementation of Table 5-13 Register Map
    always_ff @(posedge clk) begin
        if (reset) begin
            clut_bank0 <= 0;
            cursor_position_reg <= 0;
            cursor_control_register <= 0;
            backdrop_color_register <= 0;
            image_coding_method_register <= 0;
            transparency_control_register <= 0;
            trans_color_plane_a <= 0;
            mask_color_plane_a <= 0;
            weight_a <= 0;
            plane_b_in_front_of_a <= 0;
        end else begin
            if (ch0_register_write) begin
                case (ch0_register_adr)
                    7'h40: begin
                        // Image Coding Method
                        $display("Line %3d Coding A:%b %s B:%b %s", video_y,
                                 ch0_register_data[3:0], coding_method_name(
                                 ch0_register_data[3:0], 0), ch0_register_data[11:8],
                                 coding_method_name(ch0_register_data[11:8], 1));
                        image_coding_method_register.cs <= ch0_register_data[22];
                        image_coding_method_register.nr <= ch0_register_data[19];
                        image_coding_method_register.ev <= ch0_register_data[18];
                        image_coding_method_register.cm23_20_planeb <= ch0_register_data[11:8];
                        image_coding_method_register.cm13_10_planea <= ch0_register_data[3:0];
                    end
                    7'h41: begin
                        // Transparency Control
                        $display("Line %3d Transparency Control MX:%b TB:%b TA:%b", video_y,
                                 ch0_register_data[23], ch0_register_data[11:8],
                                 ch0_register_data[3:0]);

                        transparency_control_register.mx <= ch0_register_data[23];
                        transparency_control_register.tb <= ch0_register_data[11:8];
                        transparency_control_register.ta <= ch0_register_data[3:0];

                        // To find games which use these
                        assert (ch0_register_data[3:0] != 4'b0010);
                        assert (ch0_register_data[11:8] != 4'b0010);
                    end
                    7'h42: begin
                        // Plane Order
                        plane_b_in_front_of_a <= ch0_register_data[0];
                        if (ch0_register_data[0]) $display("Plane B in front of Plane A");
                        else $display("Plane A in front of Plane B");
                    end
                    7'h43: begin
                        // CLUT Bank
                        clut_bank0 <= ch0_register_data[1:0];
                    end
                    7'h44: begin
                        $display("Trans Color Plane A %d %d %d", ch0_register_data[23:18],
                                 ch0_register_data[15:10], ch0_register_data[7:2]);
                        trans_color_plane_a <= {
                            ch0_register_data[23:18],
                            ch0_register_data[15:10],
                            ch0_register_data[7:2]
                        };
                    end
                    7'h47: begin
                        $display("Mask Color Plane A %d %d %d", ch0_register_data[23:18],
                                 ch0_register_data[15:10], ch0_register_data[7:2]);
                        mask_color_plane_a <= {
                            ch0_register_data[23:18],
                            ch0_register_data[15:10],
                            ch0_register_data[7:2]
                        };
                    end
                    7'h4a: begin
                        // DYUV Abs. Start Value for Plane A
                        dyuv0_abs_start <= ch0_register_data;
                        $display("DYUV Abs. Start Plane A %d %d %d", ch0_register_data[23:16],
                                 ch0_register_data[15:8], ch0_register_data[7:0]);
                    end
                    7'h4d: begin
                        // Cursor Position
                        cursor_position_reg <= ch0_register_data;
                        $display("Cursor X:%d Y:%d", ch0_register_data[9:0],
                                 ch0_register_data[21:12]);
                    end
                    7'h4e: begin
                        // Cursor Control
                        cursor_control_register <= ch0_register_data;
                        $display("Cursor Control %b", ch0_register_data);
                    end
                    7'h4f: begin
                        // Cursor Pattern
                        cursor[ch0_register_data[19:16]] <= ch0_register_data[15:0];
                        $display("Cursor %x %b", ch0_register_data[19:16], ch0_register_data[15:0]);
                    end
                    7'h58: begin
                        // Backdrop Color
                        $display("Backdrop Color %b", ch0_register_data[3:0]);
                        backdrop_color_register <= ch0_register_data[3:0];
                    end
                    7'h59: begin
                        // Mosaic Pixel Hold for Plane A
                        // TODO is ignored
                        $display("Mosaic A %b", ch0_register_data[3:0]);
                    end
                    7'h5b: begin
                        // Weight Factor for Plane A
                        weight_a <= ch0_register_data[5:0];
                        $display("Weight A %d", ch0_register_data[5:0]);
                    end
                    default: begin
                        // Mask out CLUT and Region writes
                        if (ch0_register_adr >= 7'h40 && ch0_register_adr[6:3] != 4'b1010) begin
                            $display("Plane A ignored %x", ch0_register_adr);
                        end
                    end
                endcase

                if (ch0_register_adr <= 7'h3f) begin
                    // CLUT Color 0 to 63
                    $display("CLUT A  %d  %d %d %d", {clut_bank0, ch0_register_adr[5:0]},
                             ch0_register_data[23:18], ch0_register_data[15:10],
                             ch0_register_data[7:2]);
                end
            end

            // TODO Only handles Explicit Control
            if (active_pixel == region_control[rf0_index].x) begin
                if (region_control[rf0_index].op[2:1] == 2'b10) begin
                    // Change Weight of Plane A
                    weight_a <= region_control[rf0_index].wf;
                    $display("Weight A changed with Region %d", region_control[rf0_index].wf);
                end
            end
        end
    end

    assign clut_wr_addr0 = {clut_bank0, ch0_register_adr[5:0]};
    assign clut_wr_addr1 = {clut_bank1, ch1_register_adr[5:0]};

    assign clut_wr_data0 = {
        ch0_register_data[23:18], ch0_register_data[15:10], ch0_register_data[7:2]
    };
    assign clut_wr_data1 = {
        ch1_register_data[23:18], ch1_register_data[15:10], ch1_register_data[7:2]
    };

    assign clut_we0 = (ch0_register_adr <= 7'h3f) && ch0_register_write;
    assign clut_we1 = (ch1_register_adr <= 7'h3f) && ch1_register_write;

    always_ff @(posedge clk) begin
        if (!reset) begin
            if (ch0_register_write && ch0_register_adr[6:3] == 4'b1010) begin
                $display("Line %3d Region A %d   CMD:%b   RF:%b   Weight:%d   X:%d", video_y,
                         ch0_register_adr[2:0], ch0_register_data[23:20], ch0_register_data[16],
                         ch0_register_data[15:10], ch0_register_data[9:0]);

                region_control[ch0_register_adr[2:0]] <= {
                    ch0_register_data[23:20], ch0_register_data[16:0]
                };
            end

            if (ch1_register_write && ch1_register_adr[6:3] == 4'b1010) begin
                $display("Line %3d Region A %d   CMD:%b   RF:%b   Weight:%d   X:%d", video_y,
                         ch1_register_adr[2:0], ch1_register_data[23:20], ch1_register_data[16],
                         ch1_register_data[15:10], ch1_register_data[9:0]);

                region_control[ch1_register_adr[2:0]] <= {
                    ch1_register_data[23:20], ch1_register_data[16:0]
                };
            end
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            clut_bank1 <= 0;
            trans_color_plane_b <= 0;
            mask_color_plane_b <= 0;
            weight_b <= 0;
        end else begin
            if (ch1_register_write) begin
                case (ch1_register_adr)
                    7'h43: begin
                        // CLUT Bank
                        clut_bank1 <= ch1_register_data[1:0];

                        // The second channel can only write to banks 2 and 3
                        assert (ch1_register_data[1]);
                    end
                    7'h46: begin
                        $display("Trans Color Plane B %d %d %d", ch1_register_data[23:18],
                                 ch1_register_data[15:10], ch1_register_data[7:2]);
                        trans_color_plane_b <= {
                            ch1_register_data[23:18],
                            ch1_register_data[15:10],
                            ch1_register_data[7:2]
                        };
                    end
                    7'h49: begin
                        $display("Mask Color Plane B %d %d %d", ch1_register_data[23:18],
                                 ch1_register_data[15:10], ch1_register_data[7:2]);
                        mask_color_plane_b <= {
                            ch1_register_data[23:18],
                            ch1_register_data[15:10],
                            ch1_register_data[7:2]
                        };
                    end
                    7'h4b: begin
                        // DYUV Abs. Start Value for Plane B
                        dyuv1_abs_start <= ch1_register_data;
                        $display("DYUV Abs. Start Plane B %d %d %d", ch1_register_data[23:16],
                                 ch1_register_data[15:8], ch1_register_data[7:0]);
                    end
                    7'h5c: begin
                        // Weight Factor for Plane B
                        weight_b <= ch1_register_data[5:0];
                        $display("Weight B %d", ch1_register_data[5:0]);
                    end
                    7'h5A: begin
                        // Mosaic Pixel Hold for Plane B
                        // TODO is ignored
                        $display("Mosaic B %b", ch0_register_data[3:0]);
                    end
                    default: begin
                        if (ch1_register_adr >= 7'h40 && ch1_register_adr[6:3] != 4'b1010) begin
                            $display("Plane B ignored %x", ch1_register_adr);
                        end
                    end
                endcase

                if (ch1_register_adr <= 7'h3f) begin
                    // CLUT Color 0 to 63
                    $display("CLUT B  %d  %d %d %d", {clut_bank1, ch1_register_adr[5:0]},
                             ch1_register_data[23:18], ch1_register_data[15:10],
                             ch1_register_data[7:2]);
                end
            end

            // TODO Only handles Explicit Control
            if (active_pixel == region_control[rf0_index].x) begin
                if (region_control[rf0_index].op[2:1] == 2'b11) begin
                    // Change Weight of Plane B
                    $display("Weight B changed with Region %d", region_control[rf0_index].wf);
                    weight_b <= region_control[rf0_index].wf;
                end
            end
        end
    end


    // --- Regions ---
    bit [2:0] rf0_index;  // 0 to 7 as it is used for Explicit Control
    bit [1:0] rf1_index;  // 0 to 3 as only required for Implicit Control

    always_ff @(posedge clk) begin
        if (hblank) begin
            region_flags <= 0;
            rf0_index <= 0;
            rf1_index <= 0;
        end else begin
            if (image_coding_method_register.nr) begin
                // Implicit Control of Regions Flags
                // RF0 is handles by Region Control Registers 0123 in that order
                // X0 < X1 < X2 < X3
                // RF1 is handles by Region Control Registers 4567 in that order
                // X4 < X5 < X6 < X7

                if (active_pixel == region_control[rf0_index].x) begin
                    // TODO
                end

                if (active_pixel == region_control[{1'b1, rf1_index}].x) begin
                    // TODO
                end

            end else begin
                // Explicit Control of Region Flags
                // X0 < X1 < X2 < X3 < X4 < X5 < X6 < X7
                if (active_pixel == region_control[rf0_index].x) begin
                    rf0_index <= rf0_index + 1;
                    if (region_control[rf0_index].op[3]) begin
                        region_flags[region_control[rf0_index].rf]<=region_control[rf0_index].op[0];
                    end
                end
            end
        end
    end

endmodule

module pixelstream_mux (
    input use_b,
    pixelstream.sink a,
    pixelstream.sink b,
    pixelstream.source dst
);
    assign a.strobe  = !use_b ? dst.strobe : 1'b0;
    assign b.strobe  = use_b ? dst.strobe : 1'b0;

    assign dst.write = use_b ? b.write : a.write;
    assign dst.pixel = use_b ? b.pixel : a.pixel;
endmodule


module pixelstream_demux (
    input use_b,
    pixelstream.sink in,
    pixelstream.source a,
    pixelstream.source b
);
    assign b.pixel   = in.pixel;
    assign b.write   = use_b && in.write;

    assign a.pixel   = in.pixel;
    assign a.write   = !use_b && in.write;

    assign in.strobe = use_b ? b.strobe : a.strobe;
endmodule


// According to
// https://www.intel.com/content/www/us/en/docs/programmable/683082/22-1/true-dual-port-synchronous-ram.html
// to ensure that this is indeed a True Dual-Port RAM with Single Clock
module clut_dual_port_memory (
    input clk,
    input clut_entry_s data_a,
    input clut_entry_s data_b,
    input [7:0] addr_a,
    input [7:0] addr_b,
    input we_a,
    input we_b,
    output clut_entry_s q_a,
    output clut_entry_s q_b
);
    // Declare the RAM variable
    clut_entry_s ram[256]  /*verilator public_flat_rw*/;

    // Port A 
    always @(posedge clk) begin
        if (we_a) begin
            ram[addr_a] = data_a;
        end
        q_a <= ram[addr_a];
    end

    // Port B 
    always @(posedge clk) begin
        if (we_b) begin
            ram[addr_b] = data_b;
        end
        q_b <= ram[addr_b];
    end
endmodule
