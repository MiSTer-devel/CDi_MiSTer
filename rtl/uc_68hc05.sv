// 68HC05 Microcontroller
// Uses naked 6805 core and attaches peripherals to it
// Used core is https://opencores.org/projects/68hc05 which only implements basic functionality
// and no peripherals

`define DEBUG
`define dp(statement) `ifdef DEBUG $display``statement `endif

module uc68hc05 (
    input clk30,
    input reset,
    input [7:0] porta_in,
    output bit [7:0] porta_out,
    input [7:0] portb_in,
    output bit [7:0] portb_out,
    input [7:0] portc_in,
    output bit [7:0] portc_out,
    input [7:0] portd_in,
    input irq,
    output bit [7:0] ddra,
    output bit [7:0] ddrb,
    output bit [7:0] ddrc,

    // ROM is implemented as a write once read many memory
    input [12:0] worm_adr,
    input [7:0] worm_data,
    input worm_wr,

    bytestream.source serial_out,
    bytestream.sink serial_in,
    input tcap,

    parallelel_spi.master spi,
    input quirk_force_mode_fault
);

    bit [7:0] datain;
    bit [7:0] memory_readout = 0;

    wire [15:0] addr;
    bit [15:0] lastaddr;
    wire wrn;
    wire wr = !wrn;
    wire [3:0] state;
    wire [7:0] dataout;

    bit [7:0] memory[8192]  /*verilator public_flat_rd*/;

`ifdef VERILATOR
    initial begin
        $readmemh("slave.mem", memory);
    end
`endif

    // Readback of PORTx registers depend on DDRx
    // With a pin being 1, provided the output value
    // With a pin being 0, provide the input when read
    wire [7:0] porta_mix;
    wire [7:0] portb_mix;
    wire [7:0] portc_mix;

    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : ports
            assign porta_mix[i] = ddra[i] ? porta_out[i] : porta_in[i];
            assign portb_mix[i] = ddrb[i] ? portb_out[i] : portb_in[i];
            assign portc_mix[i] = ddrc[i] ? portc_out[i] : portc_in[i];
        end
    endgenerate

    // lower 2 bit are invisible
    bit [15:0] free_running_counter = 0;
    bit [7:0] free_running_counter_shadowcnt = 0;

    bit [7:0] latched_counter = 0;
    bit timerirq = 0;
    bit [7:0] serial_periph_miso_data = 0;
    bit [7:0] serial_periph_mosi_data = 0;
    bit tcap_q;

    struct packed {
        bit spie;
        bit spe;
        bit dw0m;
        bit mstr;
        bit cpol;
        bit cpha;
        bit [1:0] spr;
    } serial_periph_control_register = 0;


    bit [15:0] output_capture = 0;
    bit [15:0] input_capture = 0;

    struct packed {
        bit input_capture_interrupt_enable;
        bit output_capture_interrupt_enable;
        bit timer_overflow_interrupt_enable;
        bit [2:0] reserved;
        bit input_capture_edge_select;
        bit output_compare_output_level;
    } timer_control_register;

    struct packed {
        bit input_capture_flag;
        bit output_compare_flag;
        bit timer_overflow_flag;
        bit [4:0] reserved;
    } timer_status_register;


    struct packed {
        bit tdre;  // Transmit Data Register Empty
        bit tc;  // Transmit Complete
        bit rdrf;  // Receive Data Register Full
        bit idle;  // Idle Line Detect
        bit overrun;  // Overrun Error
        bit nf;  // Noise Error
        bit fe;  // Framing Error
        bit reserved;
    } serial_communications_status_register;

    struct packed {
        bit tie;   // Transmit Interrupt Enable
        bit tcie;  // Transmit Complete Interrupt Enable
        bit rie;   // Receive Interrupt Enable
        bit ilie;  // Idle Line Interrupt Enable
        bit te;    // Transmit Enable
        bit re;    // Receive Enable
        bit rwu;   // Receiver Wake-up
        bit sbk;   // Send break
    } serial_communications_control2_register;

    bit [7:0] serial_communications_control1_register;
    bit [7:0] serial_communications_baud_rate_register;

    struct packed {
        bit spif;
        bit wcol;
        bit reserved;
        bit modf;
        bit [3:0] reserved2;
    } serial_peripheral_status_register;

    wire sciirq = serial_communications_control2_register.rie ? serial_communications_status_register.rdrf : 0;

    bit [7:0] serial_com_receive_data;
    bit [7:0] serial_com_transmit_data;

    bit reset_after_memory_init = 0;
    bit [8:0] memory_reset_addr = 0;

    bit [12:0] memory_addr;
    bit [7:0] memory_in;
    bit memory_wr;

    bit clken = 0;

    always_ff @(posedge clk30) begin
        if (reset) begin
            reset_after_memory_init <= 1;
            memory_reset_addr <= 0;
            clken <= 0;
        end else if (memory_reset_addr < 9'h0100) begin
            memory_reset_addr <= memory_reset_addr + 1;
        end else begin
            reset_after_memory_init <= 0;
            clken <= !clken;
        end
    end

    always_comb begin
        memory_in   = dataout;
        memory_wr   = wr && addr < 16'h0100;
        memory_addr = addr[12:0];

        if (reset_after_memory_init && memory_reset_addr < 9'h0100) begin
            memory_in   = 0;
            memory_wr   = 1;
            memory_addr = {4'b0, memory_reset_addr};
        end

        if (worm_wr) begin
            memory_in   = worm_data;
            memory_wr   = 1;
            memory_addr = worm_adr;
        end
    end

    always_ff @(posedge clk30) begin
        if (memory_wr) memory[memory_addr] <= memory_in;
        else memory_readout <= memory[memory_addr];
    end

    always_comb begin
        serial_out.data = 0;
        serial_out.write = 0;

        datain = memory_readout;
        case (addr)
            16'h0000: begin
                datain = porta_mix;
                // `dp(("PORTA %x %d %x", dataout, wr, porta_mix));
            end
            16'h0001: begin
                datain = portb_mix;
                // `dp(("PORTB %x %d %x", dataout, wr, portb_mix));
            end
            16'h0002: begin
                datain = portc_mix;
                // `dp(("PORTC %x %d %x", dataout, wr, portc_mix));
            end
            16'h0003: begin
                // Only input for PORTD
                datain = portd_in;
                // `dp(("PORTD %x %d %x", dataout, wr, portd_in));
            end
            16'h0004: begin
                datain = ddra;
                // `dp(("DDRA %x %d", dataout, wr));
            end
            16'h0005: begin
                datain = ddrb;
                // `dp(("DDRB %x %d", dataout, wr));
            end
            16'h0006: begin
                datain = ddrc;
                // `dp(("DDRC %x %d", dataout, wr));
            end
            16'h000a: begin
                datain = serial_periph_control_register;
            end
            16'h000b: begin
                datain = serial_peripheral_status_register;
            end

            16'h000c: begin
                datain = serial_periph_miso_data;
            end
            16'h000d: begin
                datain = serial_communications_baud_rate_register;
            end
            16'h000e: begin
                datain = serial_communications_control1_register;
            end
            16'h000f: begin
                datain = serial_communications_control2_register;
            end
            16'h0010: begin
                datain = serial_communications_status_register;
            end

            16'h0011: begin
                datain = serial_com_receive_data;
                serial_out.data = dataout;
                serial_out.write = wr;
            end

            16'h0013: begin
                datain = timer_status_register;
                //`dp(("TIMER STATUS Read %x %x", datain, wr));
            end
            16'h0014: begin
                datain = input_capture[15:8];
                //`dp(("INPUT CAPTURE HIGH %x %x", datain, wr));
            end
            16'h0015: begin
                datain = input_capture[7:0];
                //`dp(("INPUT CAPTURE LOW %x %x", datain, wr));
            end

            16'h001a: begin
                // Alternate counter High
                datain = free_running_counter[15:8];
                //`dp(("ALTERNATE COUNTER HIGH %x %x", datain, wr));
            end
            16'h001b: begin
                datain = latched_counter;
                //`dp(("ALTERNATE COUNTER LOW %x %x", datain, wr));
            end
            default: begin  // do nothing
            end
        endcase
    end

    /*verilator tracing_off*/
    UR6805 slave_core (
        .clk(clk30),
        .clken(clken),
        .rst(!reset),
        .extirq(irq),
        .timerirq(!timerirq),
        .sciirq(!sciirq),
        .datain(datain),
        .addr(addr),
        .wr(wrn),
        .state(state),
        .dataout(dataout)
    );
    /*verilator tracing_on*/


    always_ff @(posedge clk30) begin

        if (reset) begin
            lastaddr <= 0;
            free_running_counter <= 0;
            timer_status_register <= 0;
            timer_control_register <= 0;
            timerirq <= 0;
            porta_out <= 0;
            portb_out <= 0;
            portc_out <= 0;
            ddra <= 0;
            ddrb <= 0;
            ddrc <= 0;
            latched_counter <= 0;
            output_capture <= 0;
            serial_communications_status_register <= 8'b11000000;
            serial_periph_control_register <= 0;
            serial_peripheral_status_register <= 0;
        end else begin
            if (!clken) begin
                lastaddr <= addr;
                timerirq <= 0;
                tcap_q   <= tcap;

                if (free_running_counter_shadowcnt == 30-1) begin
                    free_running_counter_shadowcnt <= 0;
                    free_running_counter <= free_running_counter + 1;
                end else free_running_counter_shadowcnt <= free_running_counter_shadowcnt + 1;

                if (free_running_counter == output_capture) begin
                    timer_status_register.output_compare_flag <= 1;
                    if (timer_control_register.output_capture_interrupt_enable) begin
                        timerirq <= 1;
                        //`dp(("SLAVE TIMER IRQ"));
                    end
                end

                //if (!tcap && tcap_q) begin
                if (tcap && !tcap_q) begin
                    timer_status_register.input_capture_flag <= 1;
                    input_capture <= free_running_counter;
                    if (timer_control_register.input_capture_interrupt_enable) begin
                        timerirq <= 1;
                        //`dp(("SLAVE TIMER IRQ"));
                    end
                end


                case (addr)
                    16'h0000: begin
                        if (wr) porta_out <= dataout;
                        //`dp(("PORTA %x %d %x", dataout, wr, porta_mix));
                    end
                    16'h0001: begin
                        if (wr) portb_out <= dataout;
                        //`dp(("PORTB %x %d %x", dataout, wr, portb_mix));

                        //if (wr) `dp(("RTS %d %d", dataout[4], ddrb[4]));
                    end
                    16'h0002: begin
                        if (wr) portc_out <= dataout;
                        //`dp(("PORTC %x %d %x", dataout, wr, portc_mix));
                    end
                    16'h0003: begin
                        // Only input for PORTD
                        //`dp(("PORTD %x %d %x", dataout, wr, portd_in));
                    end
                    16'h0004: begin
                        if (wr) ddra <= dataout;
                        //`dp(("DDRA %x %d", dataout, wr));
                    end
                    16'h0005: begin
                        if (wr) ddrb <= dataout;
                        //`dp(("DDRB %x %d", dataout, wr));
                    end
                    16'h0006: begin
                        if (wr) ddrc <= dataout;
                        //`dp(("DDRC %x %d", dataout, wr));
                    end
                    16'h000a: begin
                        `dp(("SERIAL PERIPH CONTROL %x %x", dataout, wr));
                        if (wr) begin
                            serial_periph_control_register <= dataout;
                            serial_peripheral_status_register.modf <= 0;
                        end
                    end

                    16'h000b: begin
                        /*
                        `dp(("SERIAL PERIPH STATUS %x %x %x %x", dataout, wr,
                                 serial_peripheral_status_register, lastaddr));
		                */
                    end

                    16'h000c: begin

                        `dp(("SERIAL PERIPH DATA %x %x %x", dataout, wr, serial_periph_miso_data));

                        if (wr) begin
                            serial_peripheral_status_register.spif <= 1;
                            spi.write <= 1;
                            spi.mosi <= dataout;
                            `dp(("SLAVE SPI MOSI:%x MISO:%x", dataout, spi.miso));

                        end else begin
                            serial_peripheral_status_register.spif <= 0;
                        end
                    end

                    16'h000d: begin
                        `dp(("SERIAL COM BAUD %x %x", dataout, wr));
                        if (wr) serial_communications_baud_rate_register <= dataout;
                    end
                    16'h000e: begin
                        `dp(("SERIAL COM CONTROL1 %x %x", dataout, wr));
                        if (wr) serial_communications_control1_register <= dataout;
                    end
                    16'h000f: begin
                        `dp(("SERIAL COM CONTROL2 %x %x", dataout, wr));
                        if (wr) serial_communications_control2_register <= dataout;
                    end

                    16'h0010: begin
                        `dp(("SERIAL COM STATUS %x %x %d", datain, dataout, wr));
                    end

                    16'h0011: begin
                        //if (wr) timer_control_register <= dataout;
                        if (!wr) begin
                            serial_communications_status_register.rdrf <= 0;
                            `dp(("SERIAL COM DATA READ %x %x", datain, wr));
                        end

                        if (wr) begin
                            `dp(("SERIAL COM DATA WRITE %x %x", dataout, wr));
                        end
                    end

                    16'h0012: begin
                        `dp(("TIMER CONTROL %x %x", dataout, wr));
                        if (wr) timer_control_register <= dataout;
                    end

                    16'h0013: begin
                        `dp(("TIMER STATUS %x %x", dataout, wr));
                    end

                    16'h0014: `dp(("INPUT CAPTURE H %x %x", dataout, wr));
                    16'h0015: begin
                        `dp(("INPUT CAPTURE L %x %x", dataout, wr));
                        timer_status_register.input_capture_flag <= 0;

                    end
                    16'h0016: begin
                        //`dp(("OUTPUT CAPTURE H %x %x", dataout, wr));
                        if (wr) output_capture[15:8] <= dataout;
                    end
                    16'h0017: begin
                        //`dp(("OUTPUT CAPTURE L %x %x", dataout, wr));
                        if (wr) begin
                            output_capture[7:0] <= dataout;
                            // TODO this is not correct. but might work anyway...
                            timer_status_register.output_compare_flag <= 0;
                        end
                    end
                    16'h0018: `dp(("TIMER MSB %x %x", dataout, wr));
                    16'h0019: `dp(("TIMER LSB %x %x", dataout, wr));

                    16'h001a: begin
                        // Alternate counter High
                        latched_counter <= free_running_counter[7:0];
                    end
                    16'h001b: begin
                        // Alternate counter Low
                    end
                    default: begin
                        // The rest is just RAM and ROM. But check for out of bounds
                        assert (addr[15:13] == 0);

                        if (wr && addr == 16'h009e) $display("IR0 %x %x WR", addr, dataout);
                        if (wr && addr == 16'h009f) $display("IR1 %x %x WR", addr, dataout);
                        if (wr && addr == 16'h00a0) $display("IR2 %x %x WR", addr, dataout);
                        if (wr && addr == 16'h00a1) $display("IR3 %x %x WR", addr, dataout);

                        if (wr && addr == 16'h00a6) $display("IRCNT %x %x WR", addr, dataout);

                        if (wr && addr == 16'h00a7) $display("TL %x %x WR", addr, dataout);
                        if (wr && addr == 16'h00a8) $display("TH %x %x WR", addr, dataout);

                        if (wr && addr == 16'h00a9) $display("LAST TL %x %x WR", addr, dataout);
                        if (wr && addr == 16'h00aa) $display("LAST TH %x %x WR", addr, dataout);
                    end
                endcase
            end

            if (spi.write) begin
                spi.write <= 0;
                spi.mosi <= 0;
                serial_periph_miso_data <= spi.miso;
            end

            if (serial_in.write) begin
                serial_communications_status_register.rdrf <= 1;
                serial_com_receive_data <= serial_in.data;
            end

            if (quirk_force_mode_fault) begin
                serial_peripheral_status_register.modf <= 1;
            end
        end

    end



endmodule
