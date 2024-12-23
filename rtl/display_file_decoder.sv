

//`define DEBUG
`define dp(statement) `ifdef DEBUG $display``statement `endif

module display_file_decoder (
    input clk,
    input reset,
    output bit [21:0] address,
    output bit as,
    input [15:0] din,
    input bus_ack,

    input reload_vsr,
    input [21:0] vsr_in,
    input read_pixels,

    input burstdata_valid,

    pixelstream.source out
);
    parameter bit unit_index = 0;

`ifdef VERILATOR
    string unit_name;
    initial begin
        $sformat(unit_name, "FILE%d", unit_index);
    end
`endif

    bit  [21:0] vsr = 0;
    wire [21:0] vsr_next = vsr + 2;

    assign address = vsr;

    enum bit [3:0] {
        IDLE,
        READ
    } state = IDLE;

    // Number of words in the FIFO
    bit [2:0] count;

    // A high level shall indicate that a minimum of 4 words can be stored
    wire fifo_can_hold_burst = count < 4 && !reset;

    // A high state represents the current burstdata to be a wrapped around one
    // It has to be ignored
    bit burst_overflow;

    // Current position in burst
    bit [2:0] burst_index;

    wire din_valid = !burst_overflow && burstdata_valid;

    always_comb begin
        burst_overflow = 0;
        // After wraparound of a burst, the following data
        // is not the next, but the previous. It must be ignored.
        if (burst_index > 0 && vsr[2:1] == 0) burst_overflow = burstdata_valid;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            as <= 0;
            state <= IDLE;
            vsr <= 0;
            burst_index <= 0;
        end else if (reload_vsr) begin
            state <= IDLE;
            vsr <= vsr_in;
            burst_index <= 0;
        end else begin
            if (burstdata_valid) burst_index <= burst_index + 1;

            case (state)
                IDLE: begin
                    if (read_pixels && fifo_can_hold_burst) begin
                        state <= READ;
                        as <= 1;
                        burst_index <= 0;
                        `dp(("%s: read %x", unit_name, vsr));
                    end
                end
                READ: begin
                    if (bus_ack) begin
                        as <= 0;
                        state <= IDLE;
                    end

                    if (din_valid) vsr <= vsr_next;
                end
                default: begin
                end
            endcase
        end
    end

    bit [15:0] mem[8];
    bit [2:0] read_index_d;
    bit [2:0] read_index_q;
    bit [2:0] write_index;
    bit [15:0] mem_read;

    bit lower_byte;

    // The memory introduces one cycle delay. This is an issue
    // when the FIFO is empty. We want to avoid using the memory readout
    // when reading from a value that is just written
    bit indizes_equal_during_write_d;
    bit indizes_equal_during_write_q;

    assign out.write = count != 0 && !reset && !indizes_equal_during_write_q;

    always_comb begin
        read_index_d = read_index_q;
        if (out.strobe && lower_byte) read_index_d = read_index_q + 1;

        indizes_equal_during_write_d = write_index == read_index_d && din_valid;
    end

    always_ff @(posedge clk) begin

        if (reset || reload_vsr) begin
            write_index <= 0;
            read_index_q <= 0;
            count <= 0;
            lower_byte <= vsr_in[0];  // handle odd addresses by ignoring the first byte
            indizes_equal_during_write_q <= 0;
        end else begin
            if (din_valid && !(out.strobe && lower_byte)) count <= count + 1;
            if (!din_valid && (out.strobe && lower_byte)) count <= count - 1;

            if (din_valid) begin
                mem[write_index] <= din;
                write_index <= write_index + 1;
                `dp(("%s: got %x", unit_name, din));
            end

            if (out.strobe) lower_byte <= !lower_byte;

            mem_read <= mem[read_index_d];
            read_index_q <= read_index_d;
            indizes_equal_during_write_q <= indizes_equal_during_write_d;
        end
    end

    assign out.pixel = lower_byte ? mem_read[7:0] : mem_read[15:8];


endmodule
