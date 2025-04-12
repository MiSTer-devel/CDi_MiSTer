module resetdelay (
    input clk,
    input reset,
    input vsync,  // Used to reduce the number of bits to count
    output bit delayedreset
);

    bit [2:0] cnt;
    bit vsync_q;

    always_ff @(posedge clk) begin
        vsync_q <= vsync;

        if (reset) begin
            cnt <= 0;
            delayedreset <= 1;
        end else if (vsync && !vsync_q) begin
            cnt <= cnt + 1;
            if (cnt == '1) delayedreset <= 0;
        end
    end
endmodule
