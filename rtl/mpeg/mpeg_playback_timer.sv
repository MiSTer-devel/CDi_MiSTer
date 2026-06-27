module mpeg_playback_timer (
    input clk,
    input reset,
    input [31:0] dclk,  // Increments with 45 kHz
    input signed [32:0] system_clock_reference,  // in 90 Khz ticks
    input signed [32:0] presentation_timestamp,  // in 90 Khz ticks
    input presentation_timestamp_strobe,
    output bit start_playback
);
    bit signed [32:0] system_clock_reference_start_time;
    bit system_clock_reference_start_time_valid;

    always_ff @(posedge clk) begin
        start_playback <= 0;

        if (reset) begin
            system_clock_reference_start_time_valid <= 0;
        end

        if (system_clock_reference_start_time_valid && dclk == system_clock_reference_start_time[32:1]) begin
            system_clock_reference_start_time_valid <= 0;
            start_playback <= 1;
        end

        if (presentation_timestamp_strobe && !system_clock_reference_start_time_valid) begin
            system_clock_reference_start_time_valid <= 1;
            system_clock_reference_start_time[32:1] <= dclk + presentation_timestamp[32:1] - system_clock_reference[32:1];
        end
    end
endmodule
