module mpeg_demuxer (
    input clk,
    input reset,
    input [7:0] mpeg_data,
    input data_valid,
    output bit mpeg_packet_body,
    input [31:0] dclk,  // Increments with 45 kHz
    output bit signed [32:0] system_clock_reference_start_time,
    output bit system_clock_reference_start_time_valid
);
    parameter string unit = "";

    enum bit [4:0] {
        IDLE,
        MAGIC0,
        MAGIC1,
        MAGIC2,
        MAGIC3,
        MAGIC_MATCH,
        PACK0,
        PACK1,
        PACK2,
        PACK3,
        PACK4,
        PACK5,
        PES0,
        PES1,
        PES2,
        PES3,
        PES4,
        PES5,
        PES6,
        PES7,
        PES8,
        PES_DTS0,
        PES_DTS1,
        PES_DTS2,
        PES_DTS3,
        PES_DTS4

    } demux_state = IDLE;

    bit packet_length_decreasing;
    bit [15:0] packet_length;
    bit signed [32:0] system_clock_reference;
    bit [9:0] pack_cnt = 0;
    bit signed [32:0] presentation_time_stamp;
    bit signed [32:0] decoding_time_stamp;
    bit dts_present;

    always_ff @(posedge clk) begin
        if (reset) begin
            demux_state <= IDLE;
            system_clock_reference_start_time_valid <= 0;
        end else if (data_valid) begin

            if (packet_length_decreasing) begin
                packet_length <= packet_length - 1;
                if (packet_length == 1) begin
                    packet_length_decreasing <= 0;
                    mpeg_packet_body <= 0;
                end
            end

            casez ({
                demux_state, mpeg_data
            })

                // verilog_format: off
                {PACK5, 8'h??}: begin         
                    demux_state <= IDLE;
                    $display ("%s PACK %d", unit, system_clock_reference);
                end
                
                {PACK4, 8'h??}: begin                    
                    demux_state <= PACK5;
                    system_clock_reference[6:0] <= mpeg_data[7:1];
                    pack_cnt <= pack_cnt +1;
                end
                {PACK3, 8'h??}: begin
                    demux_state <= PACK4;
                    system_clock_reference[14:7] <= mpeg_data;
                end
                {PACK2, 8'h??}: begin
                    demux_state <= PACK3;
                    system_clock_reference[21:15] <= mpeg_data[7:1];
                end
                {PACK1, 8'h??}: begin
                    demux_state <= PACK2;
                    system_clock_reference[29:22] <= mpeg_data;
                end
                {PACK0, 8'h??}: begin
                    demux_state <= PACK1;
                    system_clock_reference[32:30] <= mpeg_data[3:1];
                end

                {PES8, 8'h??}: begin         
                    demux_state <= IDLE;

                    if (dts_present)
                        $display ("%s PES %d %d", unit, presentation_time_stamp, decoding_time_stamp);
                    else
                        $display ("%s PES %d", unit, presentation_time_stamp);

                    if (!system_clock_reference_start_time_valid) begin
                        system_clock_reference_start_time_valid <= 1;

                        system_clock_reference_start_time[32:1] <= dclk + presentation_time_stamp[32:1] - system_clock_reference[32:1];
                    end
                end

                {PES_DTS4, 8'b???????1}: begin // DTS
                    decoding_time_stamp[6:0] <= mpeg_data[7:1];
                    mpeg_packet_body <= 1;
                    demux_state <= PES8;
                end
                {PES_DTS3, 8'h??}: begin // DTS
                    demux_state <= PES_DTS4;
                    decoding_time_stamp[14:7] <= mpeg_data;
                end
                {PES_DTS2, 8'b???????1}: begin // DTS
                    decoding_time_stamp[21:15] <= mpeg_data[7:1];
                    demux_state <= PES_DTS3;
                end
                {PES_DTS1, 8'h??}: begin // DTS
                    demux_state <= PES_DTS2;
                    decoding_time_stamp[29:22] <= mpeg_data;
                end
                {PES_DTS0, 8'b0001???1}: begin // DTS
                    decoding_time_stamp[32:30] <= mpeg_data[3:1];
                    demux_state <= PES_DTS1;
                end

                {PES7, 8'b???????1}: begin // PTS
                    presentation_time_stamp[6:0] <= mpeg_data[7:1];
                    if (dts_present) begin
                        demux_state <= PES_DTS0;
                    end else begin
                        mpeg_packet_body <= 1;
                        demux_state <= PES8;
                    end
                end
                {PES6, 8'h??}: begin // PTS
                    demux_state <= PES7;
                    presentation_time_stamp[14:7] <= mpeg_data;
                end
                {PES5, 8'b???????1}: begin // PTS
                    presentation_time_stamp[21:15] <= mpeg_data[7:1];
                    demux_state <= PES6;
                end
                {PES4, 8'h??}: begin // PTS
                    demux_state <= PES5;
                    presentation_time_stamp[29:22] <= mpeg_data;
                end
                {PES2, 8'b0010???1}: begin // PTS (no DTS)
                    presentation_time_stamp[32:30] <= mpeg_data[3:1];
                    dts_present <= 0;
                    demux_state <= PES4;
                end
                {PES2, 8'b0011???1}: begin // PTS and DTS
                    presentation_time_stamp[32:30] <= mpeg_data[3:1];
                    dts_present <= 1;
                    demux_state <= PES4;
                end
                {PES2, 8'b00001111}: begin // Neither PTS nor DTS
                    demux_state <= IDLE;
                    mpeg_packet_body <= 1;
                    $display ("%s PES ...", unit);
                end
                {PES3, 8'h??}: begin
                    // just ignore STD buffer size second byte
                    demux_state <= PES2;
                end
                {PES2, 8'b01??????}: begin // STD buffer size
                    demux_state <= PES3;
                end

                {PES2, 8'hff}: begin // stuffing byte
                    demux_state <= PES2;
                end
                
                {PES1, 8'h??}: begin
                    demux_state <= PES2;
                    packet_length[7:0] <= mpeg_data;
                    packet_length_decreasing <= 1;
                end
                {PES0, 8'h??}: begin
                    demux_state <= PES1;
                    packet_length[15:8] <= mpeg_data;
                end

                {MAGIC_MATCH, 8'hba} : begin
                    demux_state <= PACK0;
                end
                {MAGIC_MATCH, 8'hC?} : begin
                    demux_state <= PES0;
                end
                {MAGIC_MATCH, 8'hE?} : begin
                    demux_state <= PES0;
                end
                {MAGIC2, 8'h01} : demux_state <= MAGIC_MATCH;
                {MAGIC2, 8'h00} : demux_state <= MAGIC2;
                {MAGIC0, 8'h00} : demux_state <= MAGIC2;
                {IDLE, 8'h00} : demux_state <= MAGIC0;
                default: demux_state <= IDLE;
            // verilog_format: on
            endcase

        end

    end

endmodule
