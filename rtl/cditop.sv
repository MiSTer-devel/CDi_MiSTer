
module cditop (
    input clk30,
    input clk_audio,
    input external_reset,

    input tvmode_pal,
    input debug_uart_fake_space,
    input [1:0] debug_force_video_plane,
    input [1:0] debug_limited_to_full,
    input audio_cd_in_tray,
    input debug_disable_audio_attenuation,

    output bit ce_pix,
    output bit HBlank,
    output bit HSync,
    output bit VBlank,
    output bit VSync,
    output vga_f1,

    output [7:0] r,
    output [7:0] g,
    output [7:0] b,

    output [24:0] sdram_addr,
    output        sdram_rd,
    output        sdram_wr,
    output        sdram_word,
    output [15:0] sdram_din,
    input  [15:0] sdram_dout,
    input         sdram_busy,
    output        sdram_burst,
    output        sdram_refresh,
    input         sdram_burstdata_valid,

    output scc68_uart_tx,
    input  scc68_uart_rx,

    input [12:0] slave_worm_adr,
    input [7:0] slave_worm_data,
    input slave_worm_wr,

    input [12:0] nvram_backup_restore_adr,
    input [7:0] nvram_restore_data,
    output [7:0] nvram_backup_data,
    input nvram_restore_write,
    output bit nvram_cpu_changed,
    input nvram_allow_cpu_access,

    bytestream.source slave_serial_out,
    bytestream.sink slave_serial_in,
    output slave_rts,
    input rc_eye,

    bytestream.source scc68070_serial_out,
    bytestream.sink scc68070_serial_in,
    output scc68070_rts,

    output [31:0] cd_hps_lba,
    output cd_hps_req,
    input cd_hps_ack,
    input cd_hps_data_valid,
    input [15:0] cd_hps_data,
    input cd_img_mount,
    input cd_img_mounted,

    output signed [15:0] audio_left,
    output signed [15:0] audio_right,

    output fail_not_enough_words,
    output fail_too_much_data,
    input  disable_cpu_starve,
    input  config_auto_play,

    input [64:0] hps_rtc
);

    wire reset;

    parallelel_spi slave_servo_spi ();

    wire write_strobe;
    wire as;
    wire lds;
    wire uds;

    bit bus_ack  /*verilator public_flat_rd*/;

    bit [15:0] data_in;
    wire [15:0] cpu_data_out;
    wire [23:1] addr;
    wire [23:0] addr_byte = {addr[23:1], 1'b0};

    wire [15:0] cpu_data = write_strobe ? cpu_data_out : data_in;

    wire mcd212_bus_ack;
    bit cdic_bus_ack;
    bit mk48_bus_ack;
    wire [15:0] mcd212_dout;
    wire [15:0] cdic_dout;
    wire [7:0] mk48_dout;

    wire attex_cs_mcd212 = ((addr_byte <= 24'h27ffff) || (addr_byte >= 24'h400000)) && as && !addr[23];
    wire dvc_ram_cs = ((addr_byte[23:20] == 4'hd) || (addr_byte[23:19] == 5'b11101)) && as;
    wire attex_cs_cdic = addr_byte[23:16] == 8'h30 && as;
    wire attex_cs_slave = addr_byte[23:16] == 8'h31 && as;
    wire attex_cs_mk48 = addr_byte[23:16] == 8'h32 && as;

    // Custom kernel module for OS9 to start a CD-i application after booting
    // Written by "CD-i Fan" for "CD-i Emulator"
    wire rom_playcdi_cs = ((addr_byte >= 24'hf00000) && (addr_byte <= 24'hf00068)) && as;
    bit [15:0] rom_playcdi[64];
    initial $readmemh("../mem/playcdi.mem", rom_playcdi);
    bit rom_playcdi_bus_ack;
    bit [15:0] rom_playcdi_dout;

    // Activate automatic playback of CD-i discs only when
    // an image is mounted, auto play is activated in OSD,
    // there is an actual CD-i disc in the tray (no audio cd) and
    // the last reset was not self imposed.
    // When software is quitting to system shell, this is done via reset using the SLAVE
    // In that case, we want to go back to the shell.
    // Also, when booting fails, we also want to go back to shell
    bit last_reset_by_slave = 0;
    wire playcdi_rom_activated = cd_img_mounted && config_auto_play && !audio_cd_in_tray && !last_reset_by_slave;

    always_ff @(posedge clk30) begin
        if (resetsys) last_reset_by_slave <= 1;
        if (external_reset) last_reset_by_slave <= 0;
    end

    bit attex_cs_slave_q = 0;

    wire bus_err_ram_area1 = (addr_byte >= 24'h080000 && addr_byte < 24'h200000);
    wire bus_err_ram_area2 = (addr_byte >= 24'h500000 && addr_byte < 24'hd00000);
    wire bus_err_ram_area3 = (addr_byte >= 24'hf10000);
    wire bus_err_ram_area4 = (addr_byte >= 24'hf00000) && !playcdi_rom_activated;
    wire bus_err = (bus_err_ram_area1 || bus_err_ram_area2 || bus_err_ram_area3 || bus_err_ram_area4) && as && (lds || uds);

    always_ff @(posedge clk30) begin

        if (reset) ce_pix <= 0;
        else ce_pix <= !ce_pix;

        if (bus_ack) begin
            if ((lds || uds) && attex_cs_cdic && write_strobe)
                $display(
                    "Write CDIC %x %x %d %d %d", addr_byte, cpu_data_out, lds, uds, write_strobe
                );

            if ((lds || uds) && attex_cs_cdic && !write_strobe)
                $display("Read CDIC %x %x %d %d %d", addr_byte, data_in, lds, uds, write_strobe);

            if ((lds || uds) && attex_cs_slave && write_strobe)
                $display(
                    "Write SLAVE %x %x %d %d %d", addr[7:1], cpu_data_out, lds, uds, write_strobe
                );

            if ((lds || uds) && attex_cs_slave && !write_strobe)
                $display("Read SLAVE %x %x %d %d %d", addr[7:1], data_in, lds, uds, write_strobe);


            if ((lds || uds) && attex_cs_mk48)
                $display(
                    "Access NVRAM %x %x %x %d %d %d",
                    addr[7:1],
                    data_in,
                    cpu_data_out,
                    lds,
                    uds,
                    write_strobe
                );

        end
    end


    mk48t08b mk48t (
        .clk(clk30),
        .reset,
        .cpu_address(addr[13:1]),
        .cpu_din(cpu_data_out[15:8]),
        .cpu_dout(mk48_dout),
        .cs(attex_cs_mk48),
        .write_strobe(write_strobe && uds),
        .bus_ack(mk48_bus_ack),

        .nvram_backup_restore_adr(nvram_backup_restore_adr),
        .nvram_restore_data(nvram_restore_data),
        .nvram_backup_data(nvram_backup_data),
        .nvram_restore_write(nvram_restore_write),
        .nvram_cpu_changed(nvram_cpu_changed),
        .nvram_allow_cpu_access(nvram_allow_cpu_access),

        .hps_rtc(hps_rtc)
    );

    wire vdsc_int  /*verilator public_flat_rd*/;

    mcd212 mcd212_inst (
        .clk(clk30),
        .reset,
        .cpu_address(addr[23:1]),
        .cpu_din(cdic_dma_ack ? cdic_dout : cpu_data_out),
        .cpu_dout(mcd212_dout),
        .cpu_bus_ack(mcd212_bus_ack),
        .cpu_uds(uds),
        .cpu_lds(lds),
        .cpu_write_strobe(write_strobe),
        .cs(attex_cs_mcd212),
        .dvc_ram_cs(dvc_ram_cs),
        .r(r),
        .g(g),
        .b(b),
        .hsync(HSync),
        .vsync(VSync),
        .hblank(HBlank),
        .vblank(VBlank),
        .vga_f1(vga_f1),
        .sdram_addr(sdram_addr),
        .sdram_rd(sdram_rd),
        .sdram_wr(sdram_wr),
        .sdram_word(sdram_word),
        .sdram_din(sdram_din),
        .sdram_dout(sdram_dout),
        .sdram_busy(sdram_busy),
        .sdram_burst(sdram_burst),
        .sdram_refresh(sdram_refresh),
        .sdram_burstdata_valid,
        .irq(vdsc_int),
        .debug_force_video_plane,
        .debug_limited_to_full,
        // Don't starve the CPU during DMA transfers
        .disable_cpu_starve(disable_cpu_starve || cdic_dma_ack || cdic_dma_req)
    );

    wire in2in  /*verilator public_flat_rd*/;
    wire in4in;
    wire iack2;
    wire iack4;
    wire iack5;
    wire cdic_dma_req;
    wire cdic_dma_ack;
    wire cdic_dma_rdy;
    wire cdic_dma_dtc;
    wire cdic_dma_done_in;
    wire cdic_dma_done_out;

    wire signed [15:0] cdic_audio_left;
    wire signed [15:0] cdic_audio_right;

    cdic cdic_inst (
        .clk(clk30),
        .clk_audio(clk_audio),
        .reset,
        .address(addr),
        .din(cdic_dma_ack ? mcd212_dout : cpu_data_out),
        .dout(cdic_dout),
        .uds(uds),
        .lds(lds),
        .write_strobe(write_strobe),
        .cs(attex_cs_cdic),
        .bus_ack(cdic_bus_ack),
        .intreq(in4in),
        .intack(iack4),
        .req(cdic_dma_req),
        .ack(cdic_dma_ack),
        .rdy(cdic_dma_rdy),
        .dtc(cdic_dma_dtc),
        .done_in(cdic_dma_done_out),
        .done_out(cdic_dma_done_in),
        .cd_hps_lba(cd_hps_lba),
        .cd_hps_req(cd_hps_req),
        .cd_hps_ack,
        .cd_hps_data_valid,
        .cd_hps_data,
        .audio_left(cdic_audio_left),
        .audio_right(cdic_audio_right),
        .fail_not_enough_words(fail_not_enough_words),
        .fail_too_much_data(fail_too_much_data)
    );

    // TODO might not be correct
    // CDIC seems to want manual vector
    // For the SLAVE we must use autovectoring
    wire av = iack2;

`ifndef DISABLE_MAIN_CPU
    wire reset68k;

    // On a real 210/05, the main CPU polls 152 times
    // for the PAL/NTSC region. The timeout is 500.
    // With CPU Turbo this timeout is reached...
    // This reset delay of 8 frames ensures
    // that the slave has enough time to react
    // It will result into 160 polls until the answer is available
    resetdelay cpuresetdelay (
        .clk(clk30),
        .reset,
        .vsync(VSync),
        .delayedreset(reset68k)
    );
    /*verilator tracing_off*/

    scc68070 scc68070_0 (
        .clk(clk30),
        .reset(reset68k),  // External sync reset on emulated system
        .write_strobe(write_strobe),
        .as(as),
        .lds(lds),
        .uds(uds),
        .bus_ack(bus_ack),
        .bus_err,
        .int1(vdsc_int),  // Video IRQ
        .int2(1'b0),  // unconnected in CDi MONO1
        .in2(in2in),  // Slave IRQ
        .in4(in4in),  // CDIC IRQ
        .in5(1'b0),
        .iack2(iack2),
        .iack4(iack4),
        .iack5(iack5),
        .av(av),
        .data_in(data_in),
        .data_out(cpu_data_out),
        .addr(addr),
        .uart_tx(scc68_uart_tx),
        .uart_rx(scc68_uart_rx),
        .bypass_uart_rx(scc68070_serial_in),
        .bypass_uart_rts(scc68070_rts),
        .debug_uart_fake_space,
        .req1(cdic_dma_req),
        .req2(0),
        .ack1(cdic_dma_ack),
        .ack2(),
        .rdy(cdic_dma_rdy),
        .dtc(cdic_dma_dtc),
        .done_in(cdic_dma_done_in),
        .done_out(cdic_dma_done_out)
    );
    /*verilator tracing_on*/

`endif

    wire stand = !tvmode_pal;  // 1 NTSC, 0 PAL

    wire [7:0] ddra;
    wire [7:0] ddrb;
    wire [7:0] ddrc;

    wire quirk_force_mode_fault;
    wire [7:0] porta_in = cpu_data_out[7:0];
    wire [7:0] porta_out;
    wire [7:0] portb_in = 8'hff;
    wire [7:0] portb_out;
    wire [7:0] portc_in = {stand, 5'b11111, addr[2:1]};
    wire [7:0] portc_out;
    wire [7:0] portd_in = {!write_strobe, 7'b1111111};

    bit slave_bus_ack;

    always_comb begin
        bus_ack = 1;
        data_in = 0;

        if (attex_cs_slave) begin
            data_in = {porta_out, porta_out};
            bus_ack = slave_bus_ack;
        end else if (attex_cs_cdic) begin
            data_in = cdic_dout;
            bus_ack = cdic_bus_ack;
        end else if (attex_cs_mk48) begin
            data_in = {mk48_dout, mk48_dout};
            bus_ack = mk48_bus_ack;
        end else if (attex_cs_mcd212 || dvc_ram_cs) begin
            data_in = mcd212_dout;
            bus_ack = mcd212_bus_ack;
        end else if (rom_playcdi_cs && playcdi_rom_activated) begin
            data_in = rom_playcdi_dout;
            bus_ack = rom_playcdi_bus_ack;
        end

        if (iack4) begin
            data_in = cdic_dout;
            bus_ack = 1;
        end
    end

    always_ff @(posedge clk30) begin
        rom_playcdi_dout <= rom_playcdi[addr[6:1]];
        rom_playcdi_bus_ack <= !reset && rom_playcdi_cs && !rom_playcdi_bus_ack;
    end

    wire resetsys  /*verilator public_flat_rd*/ = ddrc[2] ? portc_out[2] : 1'b0;
    wire disdat_from_uc = ddrc[3] ? portc_out[3] : 1'b1;
    wire disdat_to_ic;

    wire disdat = disdat_from_uc && disdat_to_ic;
    wire disclk = ddrc[4] ? portc_out[4] : 1'b1;

    wire dtackslaven = ddrb[6] ? portb_out[6] : 1'b1;
    assign slave_rts = ddrb[4] ? portb_out[4] : 1'b1;

    // The polarity must be altered as a real SCC68070 is low active
    assign in2in = !(ddrb[5] ? portb_out[5] : 1'b1);

    wire datadac = ddrb[0] ? portb_out[0] : 1'b0;
    wire clkdac = ddrb[1] ? portb_out[1] : 1'b0;
    wire csdac1n = ddrb[2] ? portb_out[2] : 1'b1;
    wire csdac2n = ddrb[3] ? portb_out[3] : 1'b1;

    bit  dtackslaven_q = 0;
    bit  in2in_q = 0;

    bit  slave_irq;

    assign reset = external_reset || resetsys;

`ifndef DISABLE_SLAVE_UC
    /*verilator tracing_off*/
    uc68hc05 uc68hc05_0 (
        .clk30,
        .reset(reset),
        .porta_in,
        .porta_out(porta_out),
        .portb_in,
        .portb_out(portb_out),
        .portc_in({portc_in[7:5], disclk, disdat_to_ic, portc_in[2:0]}),
        .portc_out(portc_out),
        .portd_in,
        .irq(!slave_irq),
        .ddra(ddra),
        .ddrb(ddrb),
        .ddrc(ddrc),

        .worm_adr (slave_worm_adr),
        .worm_data(slave_worm_data),
        .worm_wr  (slave_worm_wr),

        .tcap(rc_eye),
        .serial_in(slave_serial_in),
        .serial_out(slave_serial_out),
        .spi(slave_servo_spi),
        .quirk_force_mode_fault(quirk_force_mode_fault)
    );
    /*verilator tracing_on*/

`endif
    wire signed [15:0] att_audio_left;
    wire signed [15:0] att_audio_right;

    dual_ad7528_attenuation att (
        .clk(clk30),
        .datadac(datadac),
        .csdac2n(csdac2n),
        .csdac1n(csdac1n),
        .clkdac(clkdac),

        .audio_left_in  (cdic_audio_left),
        .audio_right_in (cdic_audio_right),
        .audio_left_out (att_audio_left),
        .audio_right_out(att_audio_right)
    );

    assign audio_left  = debug_disable_audio_attenuation ? cdic_audio_left : att_audio_left;
    assign audio_right = debug_disable_audio_attenuation ? cdic_audio_right : att_audio_right;

    u3090mg u3090mg (
        .clk(clk30),
        .sda_in(disdat_from_uc),
        .sda_out(disdat_to_ic),
        .scl(disclk)
    );

    servo_hle servo (
        .clk(clk30),
        .reset(reset),
        .spi(slave_servo_spi),
        .quirk_force_mode_fault(quirk_force_mode_fault),
        .audio_cd_in_tray,
        .cd_img_mount(cd_img_mount),
        .cd_img_mounted(cd_img_mounted)
    );

    always_comb begin
        slave_bus_ack = dtackslaven && !dtackslaven_q;
        slave_irq = (attex_cs_slave && !attex_cs_slave_q);
    end

    always_ff @(posedge clk30) begin
        if (reset) begin
            attex_cs_slave_q <= 0;
            dtackslaven_q <= 0;
            in2in_q <= 0;
        end else begin
            attex_cs_slave_q <= attex_cs_slave;
            dtackslaven_q <= dtackslaven;
            in2in_q <= in2in;

            if (!in2in && in2in_q) $display("SLAVE IRQ2 0");
            if (in2in && !in2in_q) $display("SLAVE IRQ2 1");
        end

    end

endmodule

