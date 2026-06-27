`include "../util.svh"

module mpeg_timestamp_fifo (
    input clk,
    input reset,
    // Input
    input signed [32:0] wdata,
    input we,
    // Output
    input strobe,
    output bit valid,
    output signed [32:0] q,
    // State
    output [5:0] cnt
);

    bit signed [32:0] ram[64];

    // Clock domain of output
    bit [5:0] raddr;

    // Clock domain of input
    bit [5:0] waddr;

    assign cnt = waddr - raddr;

    always_ff @(posedge clk) begin
        if (reset) begin
            waddr <= 0;
            raddr <= 0;
        end else if (we) begin
            ram[waddr] <= wdata;
            waddr <= waddr + 1;

            assert (cnt < 62);
        end

        if (strobe) begin
            raddr <= raddr + 1;

            assert (cnt > 0);
        end

        q <= ram[raddr];
        valid <= raddr != waddr;
    end

endmodule : mpeg_timestamp_fifo

