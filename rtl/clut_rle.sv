/// CLUT7 RLE Decompression

module clut_rle (
    input clk,
    input reset,
    input st,
    pixelstream.sink src,
    pixelstream.source dst,
    input passthrough,
    output bit on_rle
);

    enum bit [3:0] {
        SINGLE,
        GET_NUMBER,
        LIMITED_RLE,
        END_OF_LINE_RLE
    } state = SINGLE;

    bit [7:0] rle_counter = 0;
    bit [7:0] rle_counter_start = 0;
    bit [6:0] stored_pixel = 0;

    bit [10:0] pixelcounter;
    wire reset_pixelcounter = pixelcounter == 0;

    always_ff @(posedge clk) begin
        if (reset || reset_pixelcounter) pixelcounter <= st ? 360 : 384;
        else if (dst.write && dst.strobe) pixelcounter <= pixelcounter - 1;
    end

    always_comb begin
        dst.write = 0;
        src.strobe = 0;
        dst.pixel = {1'b0, stored_pixel};
        on_rle = rle_counter != rle_counter_start;

        if (passthrough || reset) begin
            dst.pixel = src.pixel;
            //on_rle = 0;
            src.strobe = dst.strobe;
            dst.write = src.write;
        end else begin
            case (state)
                SINGLE: begin
                    if (src.pixel[7] || passthrough) begin
                        src.strobe = src.write;
                        //on_rle = 0;
                    end else begin
                        dst.pixel = {1'b0, src.pixel[6:0]};
                        //on_rle = 0;
                        dst.write = src.write;
                        src.strobe = dst.strobe;
                    end
                end
                GET_NUMBER: begin
                    if (src.write) src.strobe = 1;
                end
                LIMITED_RLE: begin
                    if (rle_counter != 0) dst.write = 1;
                end
                END_OF_LINE_RLE: begin
                    if (pixelcounter != 0) dst.write = 1;
                end
                default: begin
                end

            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (reset || passthrough) begin
            state <= SINGLE;
            rle_counter <= 0;
        end else begin
            case (state)
                SINGLE: begin
                    if (src.write && src.pixel[7]) begin
                        stored_pixel <= src.pixel[6:0];
                        state <= GET_NUMBER;
                    end
                end
                GET_NUMBER: begin
                    if (src.write) begin
                        rle_counter <= src.pixel;
                        rle_counter_start <= src.pixel;

                        //$display("RLE %d %d", src.pixel, dst.pixel);
                        if (src.pixel == 0) state <= END_OF_LINE_RLE;
                        else state <= LIMITED_RLE;
                    end
                end
                LIMITED_RLE: begin
                    if (rle_counter == 0) begin
                        state <= SINGLE;
                    end else if (dst.strobe) begin
                        rle_counter <= rle_counter - 1;
                    end
                end
                END_OF_LINE_RLE: begin
                    if (pixelcounter == 0) state <= SINGLE;
                end
                default: begin
                end
            endcase
        end
    end
endmodule



