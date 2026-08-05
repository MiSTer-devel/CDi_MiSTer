module hps_cd_sector_cache (
    input clk,
    input reset,

    // HPS IO for CD data
    output bit [31:0] cd_hps_lba,
    output bit cd_hps_req,
    input cd_hps_ack,
    input cd_hps_data_valid,
    input [15:0] cd_hps_data,

    // Interface to CDIC
    input [31:0] seek_lba,
    input seek_lba_valid,  // flag, seek and start reading
    output bit [15:0] cd_data,
    output bit cd_data_valid,
    input sector_tick,
    output bit sector_delivered,
    input stop_sector_delivery,  // flag, stop reading

    input config_disable_seek_time
);
    // With 13 bit adresses, we get 8192 words (of 16 bit)
    // A sector is currently 1188 words. (0x930 byte of CD sector data + 12 words subchannel)
    // So, the cache holds 6 sectors
    // After some tests with replugging USB devices, it turns out that
    // the FIFO level drops too much.
    // We go for 15 bit, to get 32768 words to hold 27 sectors.
    // With repeated replugging of USB devices, I can measure a minimum level of 0x3c54 words.
    // This is a little bit less than half of the whole FIFO and also the reason,
    // 16384 words are not enough sometimes. But 32768 should be safe...
    localparam ADDR_WIDTH = 15;
    localparam CACHE_SIZE = 2 ** ADDR_WIDTH;

    wire [15:0] cache_readout;
    bit [ADDR_WIDTH-1:0] cache_wrpos = 0;
    bit [ADDR_WIDTH-1:0] cache_rdpos = 0;
    wire [ADDR_WIDTH-1:0] cache_level = cache_wrpos - cache_rdpos;

    cd_sector_cache_memory #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) mem (
        .clk,
        .data(cd_hps_data),
        .addr(cd_hps_data_valid ? cache_wrpos : cache_rdpos),
        .we(cd_hps_data_valid),
        .q(cache_readout)
    );

    always_ff @(posedge clk) begin
        if (reset || empty_fifo_latch) begin
            cache_wrpos <= 0;
            cache_rdpos <= 0;
        end else begin
            if (cd_hps_data_valid) cache_wrpos <= cache_wrpos + 1;
            if (cd_data_valid) cache_rdpos <= cache_rdpos + 1;
        end
    end

    // Number of sectors to wait until requesting the first
    // after the reading was instructed to start.
    // Seeking on a real 210/05 takes about 200ms
    // But 19 (250ms) seems to be more stable
    localparam bit [5:0] kSeekTime = 19;

    // Simulates reading time. Remaining sectors to wait.
    bit [5:0] seeking_time_cnt = 0;

    bit reading_active = 0;

    // Used for calibration. Over the duration of development,
    // the size of a CD sector pulled from HPS has changed.
    bit [10:0] sector_size = 0;
    bit sector_size_calibrated = 0;

    // Used to detect edges of cd_hps_ack
    bit cd_hps_ack_q = 0;

    wire at_least_one_sector_in_cache = sector_size_calibrated && cache_level >= ADDR_WIDTH'(sector_size);
`ifdef VERILATOR
    // During simulation, data flow is guaranteed. Use the cache when at least one sector has been loaded
    wire at_least_half_full_cache = 1;
`else
    // In case of a physical CD drive, a seek might take longer. Try to catch this scenario by
    // pausing the simulated seek, until at least half of cache is full
    wire at_least_half_full_cache = sector_size_calibrated && cache_level[ADDR_WIDTH-1];
`endif
    wire cache_can_take_one_sector = !sector_size_calibrated || (cache_level < ADDR_WIDTH'(CACHE_SIZE - 5 - sector_size));

    bit [7:0] request_request_pause_cnt;
    bit [10:0] readout_cnt = 0;

    // If cd_hps_data_valid was not active last clock, the cache memory was read
    bit cd_hps_data_valid_q = 0;
    bit cd_data_valid_q = 0;

    // The CDIC implementation requires at least 3 clocks pause between valid data
    // This free running counter serves as timer to clock in data every 4 ticks
    // There is also a problem with CDDA. It is possible to destroy the currently
    // played audio data by being too fast here, depending on the time of playback.
    // If there is latency in starting CDDA playback, samples are overwritten.
    // This was an issue with the "Title Theme" of "The Apprentice".
    // To fix this, the data rate should be matched with a real one.
    bit [7:0] cd_data_valid_pause_cnt = 0;

    bit providing_data = 0;

    // When seeking, we want to reset this cache
    // All active transactions, reading from HPS or writing to CDIC have to be finished first
    bit empty_fifo_latch;

    always_ff @(posedge clk) begin
        cd_hps_ack_q <= cd_hps_ack;
        cd_data_valid_q <= cd_data_valid;
        cd_hps_data_valid_q <= cd_hps_data_valid;
        cd_data_valid <= 0;
        sector_delivered <= 0;
        cd_data_valid_pause_cnt <= cd_data_valid_pause_cnt + 1;

        if (cd_hps_ack) cd_hps_req <= 0;

        if (reset) begin
            seeking_time_cnt <= 0;
            cd_hps_req <= 0;
            reading_active <= 0;
            readout_cnt <= 0;
            providing_data <= 0;
            empty_fifo_latch <= 0;
        end else begin
            if (cd_hps_ack_q && !cd_hps_ack && !seek_lba_valid && !empty_fifo_latch) begin
                cd_hps_lba <= cd_hps_lba + 1;
            end

            if (cd_hps_ack_q && !cd_hps_ack && !sector_size_calibrated) begin
                sector_size_calibrated <= 1;
            end
            if (!sector_size_calibrated && cd_hps_ack && cd_hps_data_valid) begin
                sector_size <= sector_size + 1;
            end

            if (seek_lba_valid) begin
                empty_fifo_latch <= 1;
                seeking_time_cnt <= config_disable_seek_time ? 1 : kSeekTime;
                cd_hps_lba <= seek_lba;
                reading_active <= 1;
            end else if (sector_tick && seeking_time_cnt != 0) begin

                if (!at_least_half_full_cache && seeking_time_cnt == 1) begin
                    // Keep seeking! We should have more data before we play the cache!
                end else begin
                    seeking_time_cnt <= seeking_time_cnt - 1;
                end
            end

            if (sector_tick && !cd_hps_ack && !cd_hps_req) begin
                empty_fifo_latch <= 0;
            end

            if (reading_active && cache_can_take_one_sector && !cd_hps_ack && request_request_pause_cnt == 0 && !empty_fifo_latch) begin
                cd_hps_req <= 1;
                request_request_pause_cnt <= request_request_pause_cnt + 1;
            end

            if (request_request_pause_cnt != 0 && !cd_hps_ack)
                request_request_pause_cnt <= request_request_pause_cnt + 1;

            if (sector_tick) begin
                readout_cnt <= 0;
                if (at_least_one_sector_in_cache && seeking_time_cnt == 0) providing_data <= 1;
            end

            // cd_hps_data_valid_q must be 0 to ensure the cache was read
            if (!cd_hps_data_valid_q && !cd_hps_data_valid && readout_cnt != sector_size && providing_data && cd_data_valid_pause_cnt==0) begin
                cd_data_valid <= 1;
                readout_cnt   <= readout_cnt + 1;
            end

            if (readout_cnt == sector_size && cd_data_valid_q) begin
                providing_data   <= 0;
                sector_delivered <= 1;
            end

            if (stop_sector_delivery) reading_active <= 0;
        end
    end

    always_comb begin
        cd_data = cache_readout;
    end

endmodule


// Quartus Prime Verilog Template
// Single port RAM with single read/write address 

module cd_sector_cache_memory #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 13
) (
    input [(DATA_WIDTH-1):0] data,
    input [(ADDR_WIDTH-1):0] addr,
    input we,
    input clk,
    output [(DATA_WIDTH-1):0] q
);

    // Declare the RAM variable
    reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

    // Variable to hold the registered read address
    reg [ADDR_WIDTH-1:0] addr_reg;

    always @(posedge clk) begin
        // Write
        if (we) ram[addr] <= data;

        addr_reg <= addr;
    end

    // Continuous assignment implies read returns NEW data.
    // This is the natural behavior of the TriMatrix memory
    // blocks in Single Port mode.  
    assign q = ram[addr_reg];

endmodule
