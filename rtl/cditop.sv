
module cditop (
    input clk30,
    input clk_audio,
    input external_reset,

    input tvmode_pal,
    input debug_uart_fake_space,

    input scandouble,

    output bit ce_pix,

    output bit HBlank,
    output bit HSync,
    output bit VBlank,
    output bit VSync,

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

    output [31:0] cd_hps_lba,
    output cd_hps_req,
    input cd_hps_ack,
    input cd_hps_data_valid,
    input [15:0] cd_hps_data,

    output signed [15:0] audio_left,
    output signed [15:0] audio_right,

    output fail_not_enough_words,
    output fail_too_much_data

);

    wire reset;

    parallelel_spi slave_servo_spi ();

    wire write_strobe;
    wire as;
    (* keep *) wire lds;
    (* keep *) wire uds;

    (* keep *) bit bus_ack  /*verilator public_flat_rd*/;

    (* keep *) bit [15:0] data_in;
    (* keep *) wire [15:0] cpu_data_out;
    (* keep *) wire [23:1] addr;
    wire [23:0] addr_byte = {addr[23:1], 1'b0};

    (* noprune *) wire [15:0] cpu_data = write_strobe ? cpu_data_out : data_in;

    // 8 kB of NVRAM
    wire [7:0] nvram_readout;
    wire nvram_cpu_side_write = !reset && attex_cs_nvram && uds && write_strobe && nvram_allow_cpu_access;
    nvram_dual_port_memory nvram (
        .clk(clk30),

        // CPU side interface
        .data_a(cpu_data_out[15:8]),
        .addr_a(addr[13:1]),
        .we_a(nvram_cpu_side_write),
        .q_a(nvram_readout),

        // HPS Backup/Restore side interface
        .data_b(nvram_restore_data),
        .addr_b(nvram_backup_restore_adr),
        .we_b(nvram_restore_write),
        .q_b(nvram_backup_data)
    );

    always_ff @(posedge clk30) begin
        nvram_cpu_changed <= !reset && nvram_cpu_side_write;
    end

    wire mcd212_bus_ack;
    wire [15:0] mcd212_dout;
    wire [15:0] cdic_dout;
    bit cdic_bus_ack;

    bit nvram_read_bus_ack;

    wire attex_cs_mcd212 = ((addr_byte <= 24'h27ffff) || (addr_byte >= 24'h400000)) && as && !addr[23];
    wire attex_cs_cdic = addr_byte[23:16] == 8'h30 && as;
    wire attex_cs_slave = addr_byte[23:16] == 8'h31 && as;
    wire attex_cs_nvram = addr_byte[23:16] == 8'h32 && as;

    bit [15:0] data_in_q = 0;
    bit attex_cs_slave_q = 0;

    wire bus_err_ram_area1 = (addr_byte >= 24'h600000 && addr_byte < 24'hd00000);
    wire bus_err_ram_area2 = (addr_byte >= 24'hf00000);
    wire bus_err = (bus_err_ram_area1 || bus_err_ram_area2) && as && (lds || uds);

    always_ff @(posedge clk30) begin
        data_in_q <= data_in;

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
                $display("Read SLAVE %x %x %d %d %d", addr[7:1], data_in_q, lds, uds, write_strobe);


            if ((lds || uds) && attex_cs_nvram)
                $display(
                    "Access NVRAM %x %x %x %d %d %d",
                    addr[7:1],
                    data_in_q,
                    cpu_data_out,
                    lds,
                    uds,
                    write_strobe
                );

        end
    end

    wire vdsc_int;

    mcd212 mcd212_inst (
        .clk(clk30),
        .reset,
        .cpu_address(addr[22:1]),
        .cpu_din(cdic_dma_ack ? cdic_dout : cpu_data_out),
        .cpu_dout(mcd212_dout),
        .cpu_bus_ack(mcd212_bus_ack),
        .cpu_uds(uds),
        .cpu_lds(lds),
        .cpu_write_strobe(write_strobe),
        .cs(attex_cs_mcd212),
        .r(r),
        .g(g),
        .b(b),
        .hsync(HSync),
        .vsync(VSync),
        .hblank(HBlank),
        .vblank(VBlank),
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
        .irq(vdsc_int)
    );

    wire in2in;
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
        .audio_left,
        .audio_right,
        .fail_not_enough_words(fail_not_enough_words),
        .fail_too_much_data(fail_too_much_data)
    );

    // TODO might not be correct
    // CDIC seems to want manual vector
    // For the SLAVE we must use autovectoring
    wire av = iack2;

`ifndef DISABLE_MAIN_CPU

    scc68070 scc68070_0 (
        .clk(clk30),
        .reset(reset),  // External sync reset on emulated system
        .write_strobe(write_strobe),
        .as(as),
        .lds(lds),
        .uds(uds),
        .bus_ack(bus_ack),
        .bus_err,
        .int1(vdsc_int),
        .int2(1'b0),  // unconnected in CDi MONO1
        .in2(!in2in),  // TODO fix polarity
        .in4(in4in),
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

`endif

    wire stand = !tvmode_pal;  // 1 NTSC, 0 PAL

    bit [7:0] ddra;
    bit [7:0] ddrb;
    bit [7:0] ddrc;

    bit quirk_force_mode_fault;
    wire [7:0] porta_in = cpu_data_out[7:0];
    bit [7:0] porta_out;
    wire [7:0] portb_in = 8'hff;
    bit [7:0] portb_out;
    wire [7:0] portc_in = {stand, 5'b11111, addr[2:1]};
    bit [7:0] portc_out;
    wire [7:0] portd_in = {!write_strobe, 7'b1111111};

    (* keep *) bit slave_bus_ack;

    always_comb begin
        bus_ack = 1;
        data_in = 0;

        if (attex_cs_slave) begin
            data_in = {porta_out, porta_out};
            bus_ack = slave_bus_ack;
        end else if (attex_cs_cdic) begin
            data_in = cdic_dout;
            bus_ack = cdic_bus_ack;
        end else if (attex_cs_nvram) begin
            data_in = {nvram_readout, nvram_readout};
            bus_ack = nvram_read_bus_ack || (write_strobe && nvram_allow_cpu_access);
        end else if (attex_cs_mcd212) begin
            data_in = mcd212_dout;
            bus_ack = mcd212_bus_ack;
        end

        if (iack4) begin
            data_in = cdic_dout;
            bus_ack = 1;
        end
    end

    always_ff @(posedge clk30) begin
        // nvram_readout takes one cycle, apply that to the bus_ack only during read.
        // only provide an ack if it wasn't given last cycle
        nvram_read_bus_ack <= (!reset && attex_cs_nvram && !write_strobe && !nvram_read_bus_ack && nvram_allow_cpu_access);

        if (nvram_cpu_side_write && bus_ack)
            $display("NVRAM Written %x %x", addr[13:1], cpu_data_out[15:8]);
    end

    wire resetsys = ddrc[2] ? portc_out[2] : 1'b0;
    wire disdat_from_uc = ddrc[3] ? portc_out[3] : 1'b1;
    wire disdat_to_ic;

    wire disdat = disdat_from_uc && disdat_to_ic;
    wire disclk = ddrc[4] ? portc_out[4] : 1'b1;

    wire dtackslaven = ddrb[6] ? portb_out[6] : 1'b1;
    assign slave_rts = ddrb[4] ? portb_out[4] : 1'b1;
    assign in2in = ddrb[5] ? portb_out[5] : 1'b1;

    bit dtackslaven_q = 0;
    bit in2in_q = 1;

    (* keep *)bit slave_irq;

    assign reset = external_reset || resetsys;

`ifndef DISABLE_SLAVE_UC
    /*verilator tracing_off*/
    uc68hc05 uc68hc05_0 (
        .clk30,
        .reset(reset),
        .porta_in,
        .porta_out,
        .portb_in,
        .portb_out,
        .portc_in({portc_in[7:5], disclk, disdat_to_ic, portc_in[2:0]}),
        .portc_out,
        .portd_in,
        .irq(!slave_irq),
        .ddra,
        .ddrb,
        .ddrc,

        .worm_adr (slave_worm_adr),
        .worm_data(slave_worm_data),
        .worm_wr  (slave_worm_wr),

        .serial_in(slave_serial_in),
        .serial_out(slave_serial_out),
        .spi(slave_servo_spi),
        .quirk_force_mode_fault(quirk_force_mode_fault)
    );
    /*verilator tracing_on*/

`endif

    u3090mg u3090mg (
        .clk(clk30),
        .sda_in(disdat_from_uc),
        .sda_out(disdat_to_ic),
        .scl(disclk)
    );

    servo_hle servo (
        .clk  (clk30),
        .reset(reset),
        .spi  (slave_servo_spi),
        .quirk_force_mode_fault
    );

    always_comb begin
        slave_bus_ack = dtackslaven && !dtackslaven_q;
        slave_irq = (attex_cs_slave && !attex_cs_slave_q);
    end

    always_ff @(posedge clk30) begin
        if (reset) begin
            attex_cs_slave_q <= 0;
            dtackslaven_q <= 0;
            in2in_q <= 1;
        end else begin
            attex_cs_slave_q <= attex_cs_slave;
            dtackslaven_q <= dtackslaven;
            in2in_q <= in2in;

            if (!in2in && in2in_q) $display("SLAVE IRQ2 1");
            if (in2in && !in2in_q) $display("SLAVE IRQ2 0");
        end

    end

endmodule


// According to
// https://www.intel.com/content/www/us/en/docs/programmable/683082/22-1/true-dual-port-synchronous-ram.html
// to ensure that this is indeed a True Dual-Port RAM with Single Clock
module nvram_dual_port_memory (
    input clk,
    input [7:0] data_a,
    input [7:0] data_b,
    input [12:0] addr_a,
    input [12:0] addr_b,
    input we_a,
    input we_b,
    output bit [7:0] q_a,
    output bit [7:0] q_b
);
    // Declare the RAM variable
    bit [7:0] ram[8192]  /*verilator public_flat_rw*/;

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

