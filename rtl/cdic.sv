`timescale 1 ns / 1 ns
// CD-Interface Controller

`include "bus.svh"
`include "audiotypes.svh"

`define dp_hps_data(statement) `ifdef DEBUG_HPS_DATA $display``statement `endif
`define dp_dma_write(statement) `ifdef DEBUG_CDIC_DMA $display``statement `endif

module cdic (
    input clk,
    input clk_audio,
    input reset,

    // CPU interface
    input [23:1] address,
    input [15:0] din,
    output bit [15:0] dout,
    input uds,
    input lds,
    input write_strobe,
    input cs,
    output bit bus_ack,
    output intreq,
    input intack,
    output req,
    input ack,
    output bit rdy,
    input dtc,
    input done_in,
    output done_out,

    // IO for CD data
    output bit [31:0] cd_seek_lba,
    output bit cd_seek_lba_valid,
    input [15:0] cd_data,
    input cd_data_valid,
    input cd_sector_tick,
    input cd_sector_delivered,
    output cd_stop_sector_delivery,

    // Audio out
    output signed [15:0] audio_left,
    output signed [15:0] audio_right,
    input sample_tick37,
    input sample_tick44,

    // Debugging
    output bit fail_not_enough_words,
    output bit fail_too_much_data
);

    // Register set according to MAME and
    // https://github.com/cdifan/cdichips/blob/master/ims66490cdic.md
    // Together with some observations from MAME

    // MODE2 Channel Audio Mask
    // If not matching, sector is ignored
    // No IRQs are generated for ignored sectors
    bit [31:0] channel_register = 0;

    // MODE2 Channel Audio Mask
    // If matching, the data is delivered to one of the ADPCM buffers
    bit [15:0] audio_channel_register = 0;

    bit [15:0] command_register = 0;

    // Set when writing 1 to data_buffer_register[15]
    // Reset after the command was accepted
    bit execute_command = 0;

    // DBUF @ 303FFE
    // Bit 0 is toggled on every received sector and
    // points to the just refreshed buffer
    // Bit 2 is reset on data sector
    // Bit 2 is set on audio sector
    // Bit 15 starts the CD reading and parses command register
    // Resetting Bit 14 stops CD reading
    // Buffer of the stored sector is visible here
    // Setting bit 15 seems to reset all other bits
    // 000 0x0000 = 0 * 0xA00
    // 001 0x0A00 = 1 * 0xA00
    // 100 0x2800 = 4 * 0xA00
    // 101 0x3200 = 5 * 0xA00
    bit [15:0] data_buffer_register = 0;

    // XBUF @ 303FF6
    // Bit 15 causes IRQ
    // Bit 15 is set when a sector is stored
    // in either data or ADPCM buffer
    // Reading register clears bit 15 after the read
    // The CPU still gets the set bit
    bit [15:0] x_buffer_register = 0;

    // ABUF @ 303FF4
    // Bit 15 causes IRQ
    // Bit 15 is set when an audio buffer was played
    // when bit 13 of AUDCTL is set
    // Reading register clears bit 15 after the read
    // The CPU still gets the set bit
    bit [15:0] audio_buffer_register = 0;

    // Interrupt vector to present to the M68k CPU
    bit [15:0] interrupt_vector_register = 0;

    // DMACTL @ 303FF8
    // Bit 15 activates DMA transfer
    // Bit 14 ??? has no use?
    // Bits 13:0 are the current address in CDIC memory according to MAME
    bit [15:0] dma_control_register = 0;

    // AUDCTL @ 303FFA (called Z buffer in MAME)
    // Bit 0 is set when the audiomap has finished playback
    // with 0xff coding
    // Resetting bit 11 stops audio map playback directly.
    // CPU does write 0x0000 to do so, ignoring the previous content
    // Setting bit 11 starts audio map playback at ADPCM buffer 0
    // Bit 13 activates IRQs when a single ADPCM buffer was played
    bit [15:0] audio_control_register = 0;

    // Matching value for File in MODE2 header
    // If the file is not matching, the sector will be ignored
    bit [15:0] file_register = 0;

`ifdef VERILATOR
    wire sample_tick  /*verilator public_flat_rd*/ = read_cdda ? sample_tick44 : sample_tick37;
`endif

    // some info is from https://github.com/cdifan/cdichips/blob/master/ims66490cdic.md
    // behaviour is reconstructed from MAME
    // https://github.com/mamedev/mame/blob/master/src/mame/philips/cdicdic.cpp
    // CDIC memory should be from 0x0000 ot 0x3C7F according to the low level test
    // All access must be word aligned according to ims66490cdic.md

    // 16 kB of CDIC memory

    wire [15:0] mem_cpu_readout;
    wire [12:0] mem_cpu_addr = (req && ack) ? dma_control_register[13:1] : address[13:1];
    wire [15:0] mem_cpu_data = din;

    // CDIC memory write caused by DMA Access
    wire mem_dma_we = (dtc && ack && !write_strobe);

    // CDIC memory write caused by normal CPU instructions
    wire mem_cpu_we = (address[13:1] <= 13'h1E3F && access && write_strobe && bus_ack);

    // Cut off the sync pattern by starting with the sixth word
    // A real CDIC also does that
    // Also cut of the time code to later insert that. The driver seems
    // to be unhappy when it is presented too early.
    // TODO This is not yet confirmed
    wire mem_cd_hps_we = cd_data_valid && (sector_word_index >= 8 || read_raw) && use_sector_data;

    wire [15:0] mem_cdic_readout;
    bit [15:0] mem_cdic_data;
    bit [12:0] mem_cdic_addr;
    bit mem_cdic_we;

    cdic_dual_port_memory mem (
        .clk(clk),

        // CPU side interface
        .data_a(mem_cpu_data),
        .addr_a(mem_cpu_addr),
        .we_a(mem_cpu_we || mem_dma_we),
        .q_a(mem_cpu_readout),

        // CDIC side interface
        .data_b(mem_cdic_data),
        .addr_b(mem_cdic_addr),
        .we_b(mem_cdic_we),
        .q_b(mem_cdic_readout)
    );


    bit [12:0] mem_cd_audio_addr;  // Address for CDIC memory
    bit mem_cd_audio_rd;
    bit mem_cd_audio_ack;
    bit mem_cd_audio_ack_q;

    header_submode_s header_submode;
    header_coding_s header_coding;
    bit channel_match;
    bit audio_channel_match;
    bit file_match;
    bit header_mode2;
    bit read_mode2;
    bit read_cdda;
    bit read_raw;

    bit [15:0] header_timecode1;  // For inserting the timecode after reception
    bit [15:0] header_timecode2;  // For inserting the timecode after reception

    wire signed [15:0] adpcm_left  /*verilator public_flat_rd*/;
    wire signed [15:0] adpcm_right  /*verilator public_flat_rd*/;

    assign audio_left  = adpcm_left;
    assign audio_right = adpcm_right;

    bit  audio_start_playback  /*verilator public_flat_rd*/;
    bit  audio_stop_playback;
    wire audio_playback_active  /*verilator public_flat_rd*/;
    wire finished_audio_buffer_playback;
    wire decoder_disable_audiomap;

    audioplayer adpcm (
        .clk(clk),
        .sample_tick37,
        .sample_tick44,
        .reset(reset),
        .mem_addr(mem_cd_audio_addr),
        .mem_data(mem_cdic_readout),
        .mem_rd(mem_cd_audio_rd),
        .mem_ack(mem_cd_audio_ack),
        .mem_ack_q(mem_cd_audio_ack_q),

        .start_playback(audio_start_playback),
        .stop_playback(audio_stop_playback),
        .cdda_mode(read_cdda),
        .playback_active(audio_playback_active),
        .finished_buffer_playback(finished_audio_buffer_playback),
        .decoder_disable_audiomap(decoder_disable_audiomap),

        .audio_left (adpcm_left),
        .audio_right(adpcm_right)
    );

    bit cd_data_valid_q;
    bit cd_data_valid_q2;
    bit data_target_buffer;
    bit audio_target_buffer;

    bit reset_write_timecode1;
    bit reset_write_timecode2;
    bit write_timecode1 = 0;
    bit write_timecode2 = 0;

    bit [1:0] spin_down_cnt = 0;

    always_comb begin
        reset_write_timecode1 = 0;
        reset_write_timecode2 = 0;

        mem_cdic_addr = cd_data_target_adr;
        mem_cdic_we = mem_cd_hps_we;
        mem_cdic_data = cd_data;
        mem_cd_audio_ack = 0;

        if (mem_cd_hps_we) begin
            // Highest priority is to write incoming CD data into memory
        end else if (write_timecode1) begin
            reset_write_timecode1 = 1;
            mem_cdic_addr = data_target_buffer ? 0 : 13'h500;
            mem_cdic_we = 1;
            mem_cdic_data = header_timecode1;
        end else if (write_timecode2) begin
            reset_write_timecode2 = 1;
            mem_cdic_addr = data_target_buffer ? 1 : 13'h501;
            mem_cdic_we = 1;
            mem_cdic_data = header_timecode2;
        end else if (mem_cd_audio_rd) begin
            mem_cdic_addr = mem_cd_audio_addr;
            mem_cdic_we = 0;
            mem_cd_audio_ack = 1;
        end
    end

    always_ff @(posedge clk) begin
        if (reset) mem_cd_audio_ack_q <= 0;
        else mem_cd_audio_ack_q <= mem_cd_audio_ack;
    end
    wire access = cs && (uds || lds);

    struct packed {
        bit [3:0] mins_upper_digit;
        bit [3:0] mins_lower_digit;
        bit [3:0] secs_upper_digit;
        bit [3:0] secs_lower_digit;
        bit [3:0] frac_upper_digit;
        bit [3:0] frac_lower_digit;
        bit [7:0] reserved;
    } time_register  /*verilator public_flat_rd*/;

    bit [31:0] time_register_as_lba;

    always_comb begin
        bit [31:0] mins, secs, frac;

        mins = 32'(time_register.mins_upper_digit) * 32'd10 + 32'(time_register.mins_lower_digit);
        secs = 32'(time_register.secs_upper_digit) * 32'd10 + 32'(time_register.secs_lower_digit);
        frac = 32'(time_register.frac_upper_digit) * 32'd10 + 32'(time_register.frac_lower_digit);

        // The highest bit of the fraction is usually never set as
        // it ends with BCD 0x74 before the next second
        // However, it causes the fraction to be nullified
        // This feature is used by the Seek command
        if (time_register.frac_upper_digit[3]) frac = 0;

        time_register_as_lba = ((mins * 60) + secs) * 75 + frac;
    end

    // Subcode Q data is added at the end of the raw sector data
    // The 12 bytes are mapped to 12 words
    localparam bit [14:0] kWordsPerSubcodeQFrame = 12;

    // Subcode RSTUVW data is written to the data buffers when CDDA mode is in use
    // The 96 bytes are mapped to 96 words
    localparam bit [14:0] kWordsPerSubcodeRWFrame = 96;

    // 2352 bytes per sector. Always.
    localparam bit [14:0] kCdSectorSize = 2352;

    // Total number of words, the CDIC will provide per requested sector
    localparam bit [14:0] kWordsPerSector = kCdSectorSize / 2 + kWordsPerSubcodeRWFrame + kWordsPerSubcodeQFrame;

    // Index of word in CD sector. Useful for selecting specific words
    bit [14:0] sector_word_index = 0;

    // Current write address for RAM to store CD data
    bit [12:0] cd_data_target_adr = 0;

    // CD is spinning and we are reading data
    // HPS will be advised to give data as long as this is set
    bit cd_reading_active = 0;

    // Reset if MODE2 filters decided to skip the current sector
    // Set on every start of a sector
    bit use_sector_data = 0;

`ifdef VERILATOR
    always_ff @(posedge clk) begin
        if (cd_data_valid && use_sector_data)
            `dp_hps_data(("CDIC CD Data %x %d %x WE:%d", {cd_data_target_adr, 1'b0
                         }, sector_word_index, cd_data, mem_cd_hps_we));

        if (mem_dma_we) begin
            `dp_dma_write(("DMA Write %x %x", {mem_cpu_addr, 1'b0}, mem_cpu_data));
        end
    end
`endif

    assign intreq = (x_buffer_register[15] & data_buffer_register[14]) | audio_buffer_register[15];
    assign req = dma_control_register[15];

    localparam kSectorHeader_Mode = 15 / 2;  // Low Byte

    localparam kSectorHeader_File = 16 / 2;  // High Byte
    localparam kSectorHeader_Channel = 17 / 2;  // Low Byte

    localparam kSectorHeader_Submode = 18 / 2;  // High Byte
    localparam kSectorHeader_Coding = 19 / 2;  // Low Byte

    always_ff @(posedge clk) begin
        bus_ack <= 0;
        rdy <= 0;
        cd_data_valid_q2 <= cd_data_valid_q;
        cd_data_valid_q <= cd_data_valid;
        cd_seek_lba_valid <= 0;
        cd_stop_sector_delivery <= 0;

        audio_start_playback <= 0;
        audio_stop_playback <= 0;

        if (reset_write_timecode1) write_timecode1 <= 0;
        if (reset_write_timecode2) write_timecode2 <= 0;

        if (reset) begin
            data_target_buffer <= 0;
            audio_target_buffer <= 0;
            execute_command <= 0;
            bus_ack <= 0;
            time_register <= 0;
            command_register <= 0;
            audio_buffer_register <= 0;
            dma_control_register <= 0;
            data_buffer_register <= 0;
            x_buffer_register <= 0;
            audio_control_register <= 0;
            interrupt_vector_register <= 0;
            file_register <= 0;
            audio_channel_register <= 0;
            sector_word_index <= 0;
            channel_register <= 0;
            cd_reading_active <= 0;
            use_sector_data <= 0;
            header_coding <= 0;
            cd_seek_lba <= 0;
            cd_data_target_adr <= 0;
            file_match <= 0;
            audio_channel_match <= 0;
            channel_match <= 0;
            header_mode2 <= 0;
            read_mode2 <= 0;
            fail_not_enough_words <= 0;
            fail_too_much_data <= 0;
            write_timecode1 <= 0;
            write_timecode2 <= 0;
            spin_down_cnt <= 0;
        end else begin
            if (mem_cd_hps_we) begin
                cd_data_target_adr <= cd_data_target_adr + 1;
            end

            if (cd_sector_delivered && cd_reading_active) begin
                $display("Sector written to RAM / has ended");
                write_timecode1 <= !read_raw;
                write_timecode2 <= !read_raw;
            end

            if (spin_down_cnt != 0 && cd_sector_tick) begin
                spin_down_cnt <= spin_down_cnt - 1;
                if (spin_down_cnt == 1) x_buffer_register[15] <= 1'b1;
            end

            if (cd_data_valid && cd_reading_active) begin
                // Later than on real hardware but should be fine.
                data_buffer_register[15] <= 0;

                sector_word_index <= sector_word_index + 1;

                // Reading Order of MODE2 Header Information
                // Example Header
                // 00 ff ff ff ff ff ff ff ff ff ff 00 01 42 71 02 01 04 64 05 01 04 64 05
                // 00 ff ff ff ff ff ff ff ff ff ff 00 Sync
                // 01 42 71 Timecode
                // 02 Mode 2
                // 01 File
                // 04 Channel
                // 64 Submode
                // 05 Coding
                // 01 04 64 05 Repeat of the last 4 bytes

                if (sector_word_index == kSectorHeader_Mode) begin
                    // Mode is in Low byte
                    header_mode2 <= (cd_data[7:0] == 2) && read_mode2;
                end

                if (header_mode2) begin
                    if (sector_word_index == kSectorHeader_Submode) begin
                        // Submode is in High Byte
                        // Coding is in Low Byte
                        header_submode <= cd_data[15:8];
                        header_coding  <= cd_data[7:0];
                    end

                    if (sector_word_index == kSectorHeader_File) begin
                        // File header value must match the file register for all MODE2 sectors
                        $display("File / Channel %x %x", file_register, cd_data);
                        if (file_register[15:8] != cd_data[15:8]) begin
                            $display("File ignored!");
                        end

                        // High Byte is File
                        file_match <= file_register[15:8] == cd_data[15:8];
                        // Low Byte is Channel
                        audio_channel_match <= audio_channel_register[cd_data[3:0]];
                        channel_match <= channel_register[cd_data[4:0]];

                        $display("File Match ? %x %x", file_register[15:8], cd_data[15:8]);
                        $display("Channel match %b %b bit %d", audio_channel_register,
                                 channel_register, cd_data[3:0]);
                    end

                end

                if (sector_word_index == 6) begin
                    // Time Code 1
                    header_timecode1 <= cd_data;
                end
                if (sector_word_index == 7) begin
                    // Time Code 2 and Mode
                    header_timecode2 <= cd_data;
                end
            end

            if (cd_data_valid_q) begin
                if (sector_word_index == 10) begin
                    // Inspired by cdicdic_device::is_mode2_sector_selected(const uint8_t *buffer)
                    // Only apply the filter if MODE2 is used
                    // MODE1 is always let through
                    if (header_mode2) begin
                        if (file_match) begin
                            if (header_submode.eof || header_submode.trig || header_submode.eor) begin
                                // Don't analyze the sub mode or the channel mask.
                                // Just accept this sector.
                            end else if (header_submode.data || header_submode.audio || header_submode.video) begin
                                // This sector has applicable data
                                if (!channel_match) use_sector_data <= 0;
                            end else begin
                                // Message Sector
                                use_sector_data <= 0;
                            end
                        end else begin
                            // For a Mode 2 sector, the file must match!
                            use_sector_data <= 0;
                        end
                    end
                end
            end


            if (cd_data_valid_q2) begin
                if (header_mode2 && use_sector_data && audio_channel_match && sector_word_index == 10 && header_submode.audio) begin
`ifdef VERILATOR
                    $display("Switching to ADPCM Buffer %x : %s %s %s", header_coding,
                             header_coding.bps.name(), header_coding.rate.name(),
                             header_coding.chan.name());
`endif

                    $display("Use sector %x %x %x for audio", header_timecode1[15:8],
                             header_timecode1[7:0], header_timecode2[15:8]);

                    cd_data_target_adr <= audio_target_buffer ? 13'h1904 : 13'h1404;
                end else if (use_sector_data && sector_word_index == 10 && !read_raw) begin
                    $display("Use sector %x %x %x for data in buffer %x", header_timecode1[15:8],
                             header_timecode1[7:0], header_timecode2[15:8], {
                             cd_data_target_adr[12:3], 4'b0});
                end

                if (header_mode2 && use_sector_data && audio_channel_match && sector_word_index == 12 && header_submode.audio) begin
                    $display("Select ADPCM buffer %x", {audio_target_buffer ? 13'h1906 : 13'h1406,
                                                        1'b0});

                    cd_data_target_adr <= audio_target_buffer ? 13'h1906 : 13'h1406;
                end

                // Move target address to write the Q subchannel data next
                if (read_raw && sector_word_index == 1176) begin
                    cd_data_target_adr <= !data_target_buffer ? 13'h992 : 13'h492;
                end

                // Move target address to write the RW subchannel data next
                if (read_raw && sector_word_index == 1176 + 12) begin
                    cd_data_target_adr <= !data_target_buffer ? 13'h500 : 13'h000;
                end
            end

            // Audio map finished? Cause an IRQ to inform the CPU
            if (finished_audio_buffer_playback && audio_control_register[13]) begin
                audio_buffer_register[15] <= 1;
            end

            if (decoder_disable_audiomap) begin
                audio_control_register[0]  <= 1;
                audio_control_register[11] <= 0;
            end

            if (done_in && ack) dma_control_register[15] <= 0;

            if (cd_sector_tick) begin
                sector_word_index <= 0;
            end

            if (cd_reading_active && cd_sector_tick) begin
                // Use the same sector buffer again if the current one was filtered out
                // MAME does that too and it makes sense.
                // Offset 2 for skipping Time Code, which is inserted later
                if (read_raw) cd_data_target_adr <= data_target_buffer ? 13'h0a00 : 13'h0f00;
                else cd_data_target_adr <= data_target_buffer ? 2 : 13'h0502;

                // With a real CD, it takes one sector to read one sector.
                // This is not the case here as the CD emulator should be
                // faster, so we wait until the next sector tick until evaluating it.
                if (use_sector_data && sector_word_index != 0) begin
                    assert (sector_word_index == kWordsPerSector);
                    if (sector_word_index < kWordsPerSector) fail_not_enough_words <= 1;
                    if (sector_word_index > kWordsPerSector) fail_too_much_data <= 1;

                    // Now that we use this sector, select the other buffer one for the next
                    // Offset 2 for skipping Time Code
                    if (read_raw) cd_data_target_adr <= !data_target_buffer ? 13'h0a00 : 13'h0f00;
                    else cd_data_target_adr <= !data_target_buffer ? 2 : 13'h0502;

                    // Bit 0 is toggled on every received sector which
                    // indicates to the CPU which buffer was refreshed
                    // with new data.
                    // For some reason, the driver wants the first
                    // sector to have the bit set.
                    // TODO Can this be confirmed?
                    data_target_buffer <= !data_target_buffer;
                    data_buffer_register[0] <= !data_target_buffer;

                    if (read_cdda) begin
                        $display("Audio Sector delivery ended at %x", {cd_data_target_adr, 1'b0});
                    end else begin
                        $display(
                            "Sector %x %x %x delivery ended at %x. Cause IRQ. Buffer bit set to %d. %s",
                            header_timecode1[15:8], header_timecode1[7:0], header_timecode2[15:8],
                            {cd_data_target_adr, 1'b0},
                            (header_submode.audio && audio_channel_match && header_mode2) ? !audio_target_buffer : !data_target_buffer,
                            (header_submode.audio && audio_channel_match && header_mode2) ? "Audio" : "Data");
                    end
                    // Bit 2 is reset on data sector
                    // Bit 2 is set on audio sector
                    data_buffer_register[2] <= header_submode.audio && audio_channel_match && header_mode2;

                    // Bit 15 is set when a sector is stored
                    // This causes an IRQ to occur
                    x_buffer_register[15] <= 1'b1;

                    // Reset Mode 1&2 cause reading to stop after reading
                    // a sector
                    if (command_register == 16'h23 || command_register == 16'h24) begin
                        cd_reading_active <= 0;
                        cd_stop_sector_delivery <= 1;
                    end

                    if (header_submode.audio && audio_channel_match && header_mode2) begin
                        data_buffer_register[0] <= audio_target_buffer;
                        audio_target_buffer <= !audio_target_buffer;
                    end
                end

                use_sector_data <= 1;
            end

            if (execute_command) begin
                execute_command <= 0;
                x_buffer_register[15] <= 1'b0;
                read_cdda <= 0;
                read_raw <= 0;

                case (command_register)
                    16'h23: begin
                        data_buffer_register[15] <= 0;  // TODO really instant?
                        $display("CDIC Command: Stop disc");
                        cd_seek_lba <= time_register_as_lba;
                        read_mode2 <= 0;
                        spin_down_cnt <= 3;
                        // It might be tempting to do x_buffer_register[15] <= 1'b1; immediatly here.
                        // But it won't work. It needs to be delayed. spin_down_cnt will do the job
                    end
                    16'h24: begin
                        data_buffer_register[15] <= 0;  // TODO really instant?
                        $display("CDIC Command: Reset Mode 2");
                        cd_seek_lba <= time_register_as_lba;
                        read_mode2  <= 1;
                    end
                    16'h2b: begin
                        // Unknown purpose
                        data_buffer_register[15] <= 0;  // TODO really instant?
                        $display("CDIC Command: Stop CDDA?");
                    end
                    16'h2e: begin
                        data_buffer_register[15] <= 0;  // TODO really instant?
                        $display("CDIC Command: Update");
                    end
                    16'h27: begin
                        $display("CDIC Command: Fetch TOC");
                        // Use negative LBA ask for TOC
                        cd_seek_lba <= 32'hffff0000;
                        cd_seek_lba_valid <= 1;
                        cd_reading_active <= 1;
                        read_raw <= 1;
                        read_mode2 <= 0;
                    end
                    16'h28: begin
                        $display("CDIC Command: Play CDDA");
                        cd_seek_lba <= time_register_as_lba;
                        cd_seek_lba_valid <= 1;
                        cd_reading_active <= 1;
                        read_raw <= 1;
                        read_cdda <= 1;
                        read_mode2 <= 0;
                    end
                    16'h29: begin
                        $display("CDIC Command: Read Mode 1");
                        cd_reading_active <= 1;
                        cd_seek_lba <= time_register_as_lba;
                        cd_seek_lba_valid <= 1;
                        read_mode2 <= 0;
                    end
                    16'h2c: begin
                        data_buffer_register[15] <= 0;  // TODO really instant?
                        $display("CDIC Command: Seek");
                        // MAME and cdiemu implement seek as Read Mode 1
                        cd_reading_active <= 1;
                        cd_seek_lba <= time_register_as_lba;
                        cd_seek_lba_valid <= 1;
                        read_mode2 <= 0;
                    end
                    16'h2a: begin
                        $display("CDIC Command: Read Mode 2");
                        cd_reading_active <= 1;
                        cd_seek_lba <= time_register_as_lba;
                        cd_seek_lba_valid <= 1;
                        read_mode2 <= 1;
                    end
                    default: begin
                        assert (0);
                    end
                endcase

            end

            if (address[13:1] <= 13'h1E3F && access && write_strobe && !bus_ack) begin
                if (address[13:1] < 13'h1E00) $display("CDIC Write RAM %x %x", address[13:1], din);
            end else if (req && ack) begin
                if (dtc) begin
                    dma_control_register[14:0] <= dma_control_register[14:0] + 2;
                    rdy <= 0;
                end else rdy <= 1;

            end else begin
                if (access && address[13:1] < 13'h1E00 && bus_ack)
                    $display("CDIC Read RAM %x %x", {address[13:1], 1'b0}, dout);
            end

            if (bus_ack) begin
                if (!write_strobe && address[13:1] == 13'h1FFA) begin
                    // Reading the Audio Buffer Register resets the highest bit
                    audio_buffer_register[15] <= 0;
                    // but for the moment of reading it has to still be 1
                end

                if (!write_strobe && address[13:1] == 13'h1FFB) begin
                    // Reading the X Buffer Register resets the highest bit
                    x_buffer_register[15] <= 0;
                    // but for the moment of reading it has to still be 1
                end

                if (!write_strobe && address[13:1] == 13'h1FFD) begin
                    // Reading the AUDCTL Buffer Register resets the lowest bit
                    audio_control_register[0] <= 0;
                    // but for the moment of reading it has to still be 1
                end
            end

            if (access) begin
                bus_ack <= !bus_ack;

                if (write_strobe && bus_ack) begin
                    case (address[13:1])
                        13'h1E00: begin  // 0x3C00 Command Register
                            $display("CDIC Write Command Register %x %x", address[13:1], din);
                            command_register <= din;
                        end
                        13'h1E01: begin  // 0x3C02 Time High Register
                            $display("CDIC Write Time High Register %x %x", address[13:1], din);
                            time_register[31:16] <= din;
                        end
                        13'h1E02: begin  // 0x3C04 Time Low Register
                            $display("CDIC Write Time Low Register %x %x", address[13:1], din);
                            time_register[15:0] <= din;
                        end
                        13'h1E03: begin  // 0x3C06 File Register
                            $display("CDIC Write File Register %x %x", address[13:1], din);
                            file_register <= din;
                        end
                        13'h1E04: begin  // 0x3C08 Channel High Register
                            $display("CDIC Write Channel High Register %x %x", address[13:1], din);
                            channel_register[31:16] <= din;
                        end
                        13'h1E05: begin  // 0x3C0a Channel Low Register
                            $display("CDIC Write Channel Low Register %x %x", address[13:1], din);
                            channel_register[15:0] <= din;
                        end
                        13'h1E06: begin  // 0x3C0c Audio Channel Register
                            $display("CDIC Write Audio Channel Register %x %x", address[13:1], din);
                            audio_channel_register <= din;
                        end
                        13'h1FFA: begin  // 0x3FF4 ABUF Audio buffer register
                            $display("CDIC Write Audio Buffer Register %x %x", address[13:1], din);
                            audio_buffer_register <= din;
                        end
                        13'h1FFB: begin  // 0x3FF6 X Buffer Register
                            $display("CDIC Write X Buffer Register %x %x", address[13:1], din);
                            x_buffer_register <= din;
                        end
                        13'h1FFC: begin  // 0x3FF8 DMA Control Register
                            $display("CDIC Write DMA Control Register %x %x", address[13:1], din);
                            dma_control_register <= din;
                        end
                        13'h1FFD: begin  // 0x3FFA Z Buffer Register / Audio Control Register
                            $display("CDIC Write Z Buffer Register / Audio Control Register %x %x",
                                     address[13:1], din);
                            audio_control_register <= din;
                            audio_start_playback <= din[11];
                            audio_stop_playback <= !din[11];
                        end
                        13'h1FFE: begin  // 0x3FFC IVEC Interrupt Vector register
                            $display("CDIC Write Interrupt Vector Register %x %x", address[13:1],
                                     din);
                            interrupt_vector_register <= din;
                        end
                        13'h1FFF: begin  // 0x3FFE DBUF Data buffer register
                            $display("CDIC Write Data Buffer Register %x %x", address[13:1], din);
                            data_buffer_register <= din;

                            if (din[15]) execute_command <= 1;
                            if (!din[14]) begin
                                // Reset everything related to CD reading.
                                cd_reading_active <= 0;
                                cd_stop_sector_delivery <= 1;

                                data_target_buffer <= 0;

                                // Note: The first audio buffer must be delivered to 2800
                                // Only then, the Unmute will be performed
                                audio_target_buffer <= 0;
                                use_sector_data <= 0;

                                // Force bit 1 on first read after fresh sector
                                // Only then, the Unmute will be performed
                                audio_control_register[0] <= 0;
                                sector_word_index <= 0;
                            end
                        end
                        default: begin
                        end
                    endcase
                end else if (bus_ack) begin

                    // Just some debug info on reading

                    case (address[13:1])
                        13'h1E00: begin  // 0x3C00 Command Register
                            $display("CDIC Read Command Register %x %x", address[13:1], dout);
                        end
                        13'h1E01: begin  // 0x3C02 Time High Register
                            $display("CDIC Read Time High Register %x %x", address[13:1], dout);
                        end
                        13'h1E02: begin  // 0x3C04 Time Low Register
                            $display("CDIC Read Time Low Register %x %x", address[13:1], dout);
                        end
                        13'h1E03: begin  // 0x3C06 File Register
                            $display("CDIC Read File Register %x %x", address[13:1], dout);
                        end
                        13'h1E04: begin  // 0x3C08 Channel High Register
                            $display("CDIC Read Channel High Register %x %x", address[13:1], dout);
                        end
                        13'h1E05: begin  // 0x3C0a Channel Low Register
                            $display("CDIC Read Channel Low Register %x %x", address[13:1], dout);
                        end
                        13'h1E06: begin  // 0x3C0c Audio Channel Register
                            $display("CDIC Read Audio Channel Register %x %x", address[13:1], dout);
                        end
                        13'h1FFA: begin  // 0x3FF4  ABUF	Audio buffer register
                            $display("CDIC Read Audio Buffer Register %x %x", address[13:1], dout);
                        end
                        13'h1FFB: begin  // 0x3FF6 X Buffer Register
                            $display("CDIC Read X Buffer Register %x %x", address[13:1], dout);
                        end
                        13'h1FFC: begin  // 0x3FF8 DMA Control Register
                            $display("CDIC Read DMA Control Register %x %x", address[13:1], dout);
                        end
                        13'h1FFD: begin  // 0x3FFA Z Buffer Register / Audio Control Register
                            $display("CDIC Read Z Buffer Register / Audio Control Register %x %x",
                                     address[13:1], dout);
                        end
                        13'h1FFE: begin  // 0x3FFC IVEC Interrupt Vector register
                            $display("CDIC Read Interrupt Vector Register %x %x", address[13:1],
                                     dout);
                        end
                        13'h1FFF: begin  // 0x3FFE DBUF Data buffer register
                            $display("CDIC Read Data Buffer Register %x %x", address[13:1], dout);
                        end
                        default: begin
                        end
                    endcase
                end
            end
        end
    end

    always_comb begin
        dout = 16'h0;

        case (address[13:1])
            // 13'h00a00: dout = 16'h1234;  // force debug mode of ROM code
            // 13'h00a01: dout = 16'h1234;  // force debug mode of ROM code

            13'h1E00: begin  // 0x3C00 Command Register
                dout = command_register;
            end
            13'h1E01: begin  // 0x3C02 Time High Register
                dout = time_register[31:16];
            end
            13'h1E02: begin  // 0x3C04 Time Low Register
                dout = time_register[15:0];
            end
            13'h1E03: begin  // 0x3C06 File Register
                dout = file_register;
            end
            13'h1E04: begin  // 0x3C08 Channel High Register
                dout = channel_register[31:16];
            end
            13'h1E05: begin  // 0x3C0a Channel Low Register
                dout = channel_register[15:0];
            end
            13'h1E06: begin  // 0x3C0c Audio Channel Register
                dout = audio_channel_register;
            end
            13'h1FFA: begin  // 0x3FF4 ABUF Audio buffer register
                dout = audio_buffer_register;
            end
            13'h1FFB: begin  // 0x3FF6 XBUF Extra buffer register
                dout = x_buffer_register;
            end
            13'h1FFC: begin  // 0x3FF8 DMA Control Register
                dout = dma_control_register;
            end
            13'h1FFD: begin  // 0x3FFA AUDCTL Audio control register
                dout = audio_control_register;
                dout[11] = audio_playback_active;
            end
            13'h1FFE: begin  // 0x3FFC IVEC Interrupt Vector register
                dout = interrupt_vector_register;
            end
            13'h1FFF: begin  // 0x3FFE DBUF Data buffer register
                dout = data_buffer_register;
            end
            default: begin
                dout = mem_cpu_readout;
            end
        endcase

        if (intack) begin
            dout = {interrupt_vector_register[7:0], interrupt_vector_register[7:0]};
        end

        // During DMA cycles we only provide the RAM
        if (ack) dout = mem_cpu_readout;

    end

endmodule


// According to
// https://www.intel.com/content/www/us/en/docs/programmable/683082/22-1/true-dual-port-synchronous-ram.html
// to ensure that this is indeed a True Dual-Port RAM with Single Clock
module cdic_dual_port_memory (
    input clk,
    input [15:0] data_a,
    input [15:0] data_b,
    input [12:0] addr_a,
    input [12:0] addr_b,
    input we_a,
    input we_b,
    output bit [15:0] q_a,
    output bit [15:0] q_b
);
    // Declare the RAM variable
    bit [15:0] ram[8192]  /*verilator public_flat_rw*/;

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

