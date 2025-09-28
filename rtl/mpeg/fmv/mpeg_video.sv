`timescale 1 ns / 1 ps
`include "../util.svh"

module mpeg_video (
    input clk30,
    input clk60,
    input reset,
    input dsp_enable,
    input playback_active,

    input  [7:0] data_byte,
    input        data_strobe,
    output       fifo_full,

    ddr_if.to_host ddrif,

    output rgb888_s vidout,
    input           hsync,
    input           vsync,
    input           hblank,
    input           vblank
);

    ddr_if worker_2_ddr ();
    ddr_if worker_3_ddr ();
    ddr_if player_ddr ();

    ddr_mux3 ddrmux (
        .clk(clk60),
        .x  (ddrif),
        .a  (player_ddr),
        .b  (worker_2_ddr),
        .c  (worker_3_ddr)
    );

    assign worker_2_ddr.byteenable = 8'hff;
    assign worker_3_ddr.byteenable = 8'hff;

    flag_cross_domain cross_reset (
        .clk_a(clk30),
        .clk_b(clk60),
        .flag_in_clk_a(reset_dsp_enabled),
        .flag_out_clk_b(reset_dsp_enabled_clk60)
    );
    wire reset_dsp_enabled = reset || !dsp_enable;
    wire reset_dsp_enabled_clk60;

    bit [15:0] dct_coeff_result;
    bit dct_coeff_huffman_active = 0;
    wire dct_coeff_result_valid;
    dct_coeff_huffman_decoder huff (
        .clk(clk60),
        .reset(reset_dsp_enabled_clk60),
        .data_valid(dct_coeff_huffman_active && hw_read_mem_ready && !dct_coeff_result_valid),
        .data(mpeg_in_fifo_out[31-hw_read_bit_shift]),
        .result_valid(dct_coeff_result_valid),
        .result(dct_coeff_result)
    );

    // 8kB of MPEG stream memory to fill from outside
    wire [31:0] mpeg_in_fifo_out;

    bit  [12:0] mpeg_input_stream_fifo_raddr;
    always_comb begin
        mpeg_input_stream_fifo_raddr = dmem_cmd_payload_address_1[14:2];

        if (hw_read_count != 0) begin
            mpeg_input_stream_fifo_raddr = mpeg_stream_byte_index[14:2];

            if (hw_read_mem_ready && (!hw_read_aligned_access || mpeg_stream_bit_index[4:0]==5'b11111) )
                mpeg_input_stream_fifo_raddr = mpeg_input_stream_fifo_raddr + 1;
        end
    end

    mpeg_input_stream_fifo_32k in_fifo (
        .clkw(clk30),
        // In, invert endianness at the same time
        .waddr({mpeg_stream_fifo_write_adr[14:2], 2'b11 - mpeg_stream_fifo_write_adr[1:0]}),
        .wdata(data_byte),
        .we(data_strobe),
        // Out (32 bit CPU interface)
        .clkr(clk60),
        .raddr(mpeg_input_stream_fifo_raddr),
        .q(mpeg_in_fifo_out)
    );

    bit [4:0] hw_read_count = 0;
    bit [31:0] hw_read_result = 32;

    // Word Address
    bit [27:0] mpeg_stream_fifo_write_adr;
    bit [31:0] mpeg_stream_bit_index;
    wire [28:0] mpeg_stream_byte_index = mpeg_stream_bit_index[31:3];

    // Word address
    wire [27:0] mpeg_stream_fifo_read_adr = mpeg_stream_byte_index[27:0];

    wire [27:0] fifo_level /*verilator public_flat_rd*/ = mpeg_stream_fifo_write_adr - mpeg_stream_fifo_read_adr;

    wire fifo_underflow = mpeg_stream_fifo_write_adr_clk60 < mpeg_stream_fifo_read_adr;
    (* keep *) (* noprune *) bit [31:0] decoder_failing_address;
    (* keep *) (* noprune *) bit decoder_failing_address_set = 0;

    always_ff @(posedge clk60) begin
        if (reset_dsp_enabled_clk60) begin
            decoder_failing_address_set <= 0;
        end else if (fifo_underflow && !decoder_failing_address_set) begin
            // This is a bad sign! The reader just went faster than the writer. Prepare for impact!
            decoder_failing_address_set <= 1;
            decoder_failing_address <= imem_cmd_payload_address_1;
            $display("Underflow of FIFO at %x", imem_cmd_payload_address_1);
            $finish();
        end
    end

    wire fifo_full_clk60 = mpeg_stream_fifo_write_adr_clk60 > (mpeg_stream_fifo_read_adr + 28'd30500);

    bit hw_read_mem_ready = 0;
    wire [4:0] hw_read_bit_shift = mpeg_stream_bit_index[4:0];

    wire [5:0] hw_read_remaining_bits_in_dword = 32 - hw_read_bit_shift;
    wire hw_read_aligned_access = (6'(hw_read_count) <= hw_read_remaining_bits_in_dword);
    wire [ 4:0] hw_read_count_aligned = hw_read_aligned_access ? hw_read_count : hw_read_remaining_bits_in_dword[4:0];
    wire [31:0] hw_read_mask = ones_mask(hw_read_count_aligned);

    bit [3:0] sync_write_adr_cnt;
    bit [27:0] mpeg_stream_fifo_write_adr_syncval;
    bit mpeg_stream_fifo_write_adr_syncflag;
    bit mpeg_stream_fifo_write_adr_syncflag_clk60;
    bit [27:0] mpeg_stream_fifo_write_adr_clk60;

    // TODO This is a weird approach to sync the write address over
    // It has 16 clocks of latency but doesn't need any gray code
    always_ff @(posedge clk30) begin
        sync_write_adr_cnt <= sync_write_adr_cnt + 1;
        mpeg_stream_fifo_write_adr_syncflag <= 0;

        if (sync_write_adr_cnt == 0) begin
            mpeg_stream_fifo_write_adr_syncflag <= 1;
            mpeg_stream_fifo_write_adr_syncval  <= mpeg_stream_fifo_write_adr;
        end
    end

    flag_cross_domain cross_fifo_write_adr_syncflag (
        .clk_a(clk30),
        .clk_b(clk60),
        .flag_in_clk_a(mpeg_stream_fifo_write_adr_syncflag),
        .flag_out_clk_b(mpeg_stream_fifo_write_adr_syncflag_clk60)
    );

    signal_cross_domain cross_fifo_full (
        .clk_a(clk60),
        .clk_b(clk30),
        .signal_in_clk_a(fifo_full_clk60),
        .signal_out_clk_b(fifo_full)
    );

    always_ff @(posedge clk60) begin
        if (mpeg_stream_fifo_write_adr_syncflag_clk60)
            mpeg_stream_fifo_write_adr_clk60 <= mpeg_stream_fifo_write_adr_syncval;
    end

    always_ff @(posedge clk30) begin
        if (reset) begin
            mpeg_stream_fifo_write_adr <= 0;
        end else if (data_strobe) begin
            mpeg_stream_fifo_write_adr <= mpeg_stream_fifo_write_adr + 1;
        end
    end

    always_ff @(posedge clk60) begin
        if (fifo_full) begin
            $display("FIFO FULL");
            $finish();
        end

        hw_read_mem_ready <= 0;

        if (reset_dsp_enabled_clk60) begin
            mpeg_stream_bit_index <= 0;
            hw_read_count <= 0;
        end else begin

            if (dmem_cmd_payload_write_1 && dmem_cmd_valid_1) begin
                if (dmem_cmd_payload_address_1 == 32'h10002000) $finish();

                if (dmem_cmd_payload_address_1 == 32'h10002004)
                    mpeg_stream_bit_index <= dmem_cmd_payload_data_1;
                if (dmem_cmd_payload_address_1 == 32'h10002008) begin
                    hw_read_count  <= dmem_cmd_payload_data_1[4:0];
                    hw_read_result <= 0;
                end
                if (dmem_cmd_payload_address_1 == 32'h1000200c) begin
                    hw_read_count <= 1;
                    dct_coeff_huffman_active <= 1;
                end
            end

            if (hw_read_count_aligned != 0) begin
                hw_read_mem_ready <= 1;

                if (hw_read_mem_ready) begin

                    hw_read_result <= (hw_read_result<<hw_read_count_aligned) |
                        ((mpeg_in_fifo_out >> (32 - hw_read_count_aligned - hw_read_bit_shift)) & hw_read_mask);

                    mpeg_stream_bit_index <= mpeg_stream_bit_index + 32'(hw_read_count_aligned);
                    hw_read_count <= hw_read_count - hw_read_count_aligned;
                end
            end
        end

        if (reset_dsp_enabled_clk60 || dct_coeff_result_valid) begin
            dct_coeff_huffman_active <= 0;
            mpeg_stream_bit_index <= mpeg_stream_bit_index;
            hw_read_count <= 0;
        end else if (dct_coeff_huffman_active) begin
            hw_read_count <= 1;
            hw_read_mem_ready <= 1;
        end
    end

    bit  [31:0] frames_decoded;

    // Memory arrays
    wire [31:0] memory_out_i1;
    wire [31:0] memory_out_d1;
    decoder_firmware_memory core1mem (
        .clk(clk60),
        .addr2(imem_cmd_payload_address_1[13:2]),
        .data_out2(memory_out_i1),
        .be2(0),
        .we2(0),
        .data_in2(0),
        .addr1(dmem_cmd_payload_address_1[13:2]),
        .data_in1(dmem_cmd_payload_data_1),
        .we1(dmem_cmd_payload_address_1[31:28]==0 && dmem_cmd_valid_1 && dmem_cmd_ready_1 && dmem_cmd_payload_write_1),
        .be1(dmem_cmd_payload_mask_1),
        .data_out1(memory_out_d1)
    );

    wire [31:0] memory_out_i2;
    wire [31:0] memory_out_d2;
    worker_firmware_memory core2mem (
        .clk(clk60),
        .addr2(imem_cmd_payload_address_2[12:2]),
        .data_out2(memory_out_i2),
        .be2(0),
        .we2(0),
        .data_in2(0),
        .addr1(dmem_cmd_payload_address_2[12:2]),
        .data_in1(dmem_cmd_payload_data_2),
        .we1(dmem_cmd_payload_address_2[31:28]==0 && dmem_cmd_valid_2 && dmem_cmd_ready_2 && dmem_cmd_payload_write_2),
        .be1(dmem_cmd_payload_mask_2),
        .data_out1(memory_out_d2)
    );

    wire [31:0] memory_out_i3;
    wire [31:0] memory_out_d3;
    worker_firmware_memory core3mem (
        .clk(clk60),
        .addr2(imem_cmd_payload_address_3[12:2]),
        .data_out2(memory_out_i3),
        .be2(0),
        .we2(0),
        .data_in2(0),
        .addr1(dmem_cmd_payload_address_3[12:2]),
        .data_in1(dmem_cmd_payload_data_3),
        .we1(dmem_cmd_payload_address_3[31:28]==0 && dmem_cmd_valid_3 && dmem_cmd_ready_3 && dmem_cmd_payload_write_3),
        .be1(dmem_cmd_payload_mask_3),
        .data_out1(memory_out_d3)
    );

    wire [31:0] shared12_out_2;
    wire [31:0] shared12_out_1;
    dualport_shared_ram shared12 (
        .clk2(clk60),
        .addr2(dmem_cmd_payload_address_2[13:2]),
        .data_out2(shared12_out_2),
        .be2(dmem_cmd_payload_mask_2),
        .we2(dmem_cmd_payload_address_2[31:28]==4 && dmem_cmd_valid_2 && dmem_cmd_ready_2 && dmem_cmd_payload_write_2),
        .data_in2(dmem_cmd_payload_data_2),
        .addr1(dmem_cmd_payload_address_1[13:2]),
        .clk1(clk60),
        .data_in1(dmem_cmd_payload_data_1),
        .we1(dmem_cmd_payload_address_1[31:28]==4 && dmem_cmd_payload_address_1[27:24] == 1 && dmem_cmd_valid_1 && dmem_cmd_ready_1 && dmem_cmd_payload_write_1),
        .be1(dmem_cmd_payload_mask_1),
        .data_out1(shared12_out_1)
    );

    wire [31:0] shared13_out_3;
    wire [31:0] shared13_out_1;
    dualport_shared_ram shared13 (
        .clk2(clk60),
        .addr2(dmem_cmd_payload_address_3[13:2]),
        .data_out2(shared13_out_3),
        .be2(dmem_cmd_payload_mask_3),
        .we2(dmem_cmd_payload_address_3[31:28]==4 && dmem_cmd_valid_3 && dmem_cmd_ready_3 && dmem_cmd_payload_write_3),
        .data_in2(dmem_cmd_payload_data_3),
        .addr1(dmem_cmd_payload_address_1[13:2]),
        .clk1(clk60),
        .data_in1(dmem_cmd_payload_data_1),
        .we1(dmem_cmd_payload_address_1[31:28]==4 && dmem_cmd_payload_address_1[27:24] == 0 && dmem_cmd_valid_1 && dmem_cmd_ready_1 && dmem_cmd_payload_write_1),
        .be1(dmem_cmd_payload_mask_1),
        .data_out1(shared13_out_1)
    );

    // Core 1 signals
    wire        imem_cmd_valid_1;
    bit         imem_cmd_ready_1;
    wire [ 0:0] imem_cmd_payload_id_1;
    wire [31:0] imem_cmd_payload_address_1;
    bit         imem_rsp_valid_1;
    bit  [ 0:0] imem_rsp_payload_id_1;
    bit         imem_rsp_payload_error_1;
    bit  [31:0] imem_rsp_payload_word_1;
    wire        dmem_cmd_valid_1;
    bit         dmem_cmd_ready_1;
    wire [ 0:0] dmem_cmd_payload_id_1;
    wire        dmem_cmd_payload_write_1;
    wire [31:0] dmem_cmd_payload_address_1;
    wire [31:0] dmem_cmd_payload_data_1;
    wire [ 1:0] dmem_cmd_payload_size_1;
    wire [ 3:0] dmem_cmd_payload_mask_1;
    wire        dmem_cmd_payload_io_1;
    wire        dmem_cmd_payload_fromHart_1;
    wire [15:0] dmem_cmd_payload_uopId_1;
    bit         dmem_rsp_valid_1;
    bit  [ 0:0] dmem_rsp_payload_id_1;
    bit         dmem_rsp_payload_error_1;
    bit  [31:0] dmem_rsp_payload_data_1;

    // Core 2 signals
    wire        imem_cmd_valid_2;
    bit         imem_cmd_ready_2;
    wire [ 0:0] imem_cmd_payload_id_2;
    wire [31:0] imem_cmd_payload_address_2;
    bit         imem_rsp_valid_2;
    bit  [ 0:0] imem_rsp_payload_id_2;
    bit         imem_rsp_payload_error_2;
    bit  [31:0] imem_rsp_payload_word_2;
    wire        dmem_cmd_valid_2;
    bit         dmem_cmd_ready_2;
    wire [ 0:0] dmem_cmd_payload_id_2;
    wire        dmem_cmd_payload_write_2;
    wire [31:0] dmem_cmd_payload_address_2;
    wire [31:0] dmem_cmd_payload_data_2;
    wire [ 1:0] dmem_cmd_payload_size_2;
    wire [ 3:0] dmem_cmd_payload_mask_2;
    wire        dmem_cmd_payload_io_2;
    wire        dmem_cmd_payload_fromHart_2;
    wire [15:0] dmem_cmd_payload_uopId_2;
    bit         dmem_rsp_valid_2;
    bit  [ 0:0] dmem_rsp_payload_id_2;
    bit         dmem_rsp_payload_error_2;
    bit  [31:0] dmem_rsp_payload_data_2;

    // Core 3 signals
    wire        imem_cmd_valid_3;
    bit         imem_cmd_ready_3;
    wire [ 0:0] imem_cmd_payload_id_3;
    wire [31:0] imem_cmd_payload_address_3;
    bit         imem_rsp_valid_3;
    bit  [ 0:0] imem_rsp_payload_id_3;
    bit         imem_rsp_payload_error_3;
    bit  [31:0] imem_rsp_payload_word_3;
    wire        dmem_cmd_valid_3;
    bit         dmem_cmd_ready_3;
    wire [ 0:0] dmem_cmd_payload_id_3;
    wire        dmem_cmd_payload_write_3;
    wire [31:0] dmem_cmd_payload_address_3;
    wire [31:0] dmem_cmd_payload_data_3;
    wire [ 1:0] dmem_cmd_payload_size_3;
    wire [ 3:0] dmem_cmd_payload_mask_3;
    wire        dmem_cmd_payload_io_3;
    wire        dmem_cmd_payload_fromHart_3;
    wire [15:0] dmem_cmd_payload_uopId_3;
    bit         dmem_rsp_valid_3;
    bit  [ 0:0] dmem_rsp_payload_id_3;
    bit         dmem_rsp_payload_error_3;
    bit  [31:0] dmem_rsp_payload_data_3;

    /*verilator tracing_off*/
    VexiiRiscv vexii1 (
        .PrivilegedPlugin_logic_rdtime(0),
        .PrivilegedPlugin_logic_harts_0_int_m_timer(0),
        .PrivilegedPlugin_logic_harts_0_int_m_software(0),
        .PrivilegedPlugin_logic_harts_0_int_m_external(0),
        .FetchCachelessPlugin_logic_bus_cmd_valid(imem_cmd_valid_1),
        .FetchCachelessPlugin_logic_bus_cmd_ready(imem_cmd_ready_1),
        .FetchCachelessPlugin_logic_bus_cmd_payload_id(imem_cmd_payload_id_1),
        .FetchCachelessPlugin_logic_bus_cmd_payload_address(imem_cmd_payload_address_1),
        .FetchCachelessPlugin_logic_bus_rsp_valid(imem_rsp_valid_1),
        .FetchCachelessPlugin_logic_bus_rsp_payload_id(imem_rsp_payload_id_1),
        .FetchCachelessPlugin_logic_bus_rsp_payload_error(imem_rsp_payload_error_1),
        .FetchCachelessPlugin_logic_bus_rsp_payload_word(imem_rsp_payload_word_1),
        .LsuCachelessPlugin_logic_bus_cmd_valid(dmem_cmd_valid_1),
        .LsuCachelessPlugin_logic_bus_cmd_ready(dmem_cmd_ready_1),
        .LsuCachelessPlugin_logic_bus_cmd_payload_id(dmem_cmd_payload_id_1),
        .LsuCachelessPlugin_logic_bus_cmd_payload_write(dmem_cmd_payload_write_1),
        .LsuCachelessPlugin_logic_bus_cmd_payload_address(dmem_cmd_payload_address_1),
        .LsuCachelessPlugin_logic_bus_cmd_payload_data(dmem_cmd_payload_data_1),
        .LsuCachelessPlugin_logic_bus_cmd_payload_size(dmem_cmd_payload_size_1),
        .LsuCachelessPlugin_logic_bus_cmd_payload_mask(dmem_cmd_payload_mask_1),
        .LsuCachelessPlugin_logic_bus_cmd_payload_io(dmem_cmd_payload_io_1),
        .LsuCachelessPlugin_logic_bus_cmd_payload_fromHart(dmem_cmd_payload_fromHart_1),
        .LsuCachelessPlugin_logic_bus_cmd_payload_uopId(dmem_cmd_payload_uopId_1),
        .LsuCachelessPlugin_logic_bus_rsp_valid(dmem_rsp_valid_1),
        .LsuCachelessPlugin_logic_bus_rsp_payload_id(dmem_rsp_payload_id_1),
        .LsuCachelessPlugin_logic_bus_rsp_payload_error(dmem_rsp_payload_error_1),
        .LsuCachelessPlugin_logic_bus_rsp_payload_data(dmem_rsp_payload_data_1),
        .clk(clk60),
        .reset(reset_dsp_enabled_clk60)
    );


    VexiiRiscv vexii2 (
        .PrivilegedPlugin_logic_rdtime(0),
        .PrivilegedPlugin_logic_harts_0_int_m_timer(0),
        .PrivilegedPlugin_logic_harts_0_int_m_software(0),
        .PrivilegedPlugin_logic_harts_0_int_m_external(0),
        .FetchCachelessPlugin_logic_bus_cmd_valid(imem_cmd_valid_2),
        .FetchCachelessPlugin_logic_bus_cmd_ready(imem_cmd_ready_2),
        .FetchCachelessPlugin_logic_bus_cmd_payload_id(imem_cmd_payload_id_2),
        .FetchCachelessPlugin_logic_bus_cmd_payload_address(imem_cmd_payload_address_2),
        .FetchCachelessPlugin_logic_bus_rsp_valid(imem_rsp_valid_2),
        .FetchCachelessPlugin_logic_bus_rsp_payload_id(imem_rsp_payload_id_2),
        .FetchCachelessPlugin_logic_bus_rsp_payload_error(imem_rsp_payload_error_2),
        .FetchCachelessPlugin_logic_bus_rsp_payload_word(imem_rsp_payload_word_2),
        .LsuCachelessPlugin_logic_bus_cmd_valid(dmem_cmd_valid_2),
        .LsuCachelessPlugin_logic_bus_cmd_ready(dmem_cmd_ready_2),
        .LsuCachelessPlugin_logic_bus_cmd_payload_id(dmem_cmd_payload_id_2),
        .LsuCachelessPlugin_logic_bus_cmd_payload_write(dmem_cmd_payload_write_2),
        .LsuCachelessPlugin_logic_bus_cmd_payload_address(dmem_cmd_payload_address_2),
        .LsuCachelessPlugin_logic_bus_cmd_payload_data(dmem_cmd_payload_data_2),
        .LsuCachelessPlugin_logic_bus_cmd_payload_size(dmem_cmd_payload_size_2),
        .LsuCachelessPlugin_logic_bus_cmd_payload_mask(dmem_cmd_payload_mask_2),
        .LsuCachelessPlugin_logic_bus_cmd_payload_io(dmem_cmd_payload_io_2),
        .LsuCachelessPlugin_logic_bus_cmd_payload_fromHart(dmem_cmd_payload_fromHart_2),
        .LsuCachelessPlugin_logic_bus_cmd_payload_uopId(dmem_cmd_payload_uopId_2),
        .LsuCachelessPlugin_logic_bus_rsp_valid(dmem_rsp_valid_2),
        .LsuCachelessPlugin_logic_bus_rsp_payload_id(dmem_rsp_payload_id_2),
        .LsuCachelessPlugin_logic_bus_rsp_payload_error(dmem_rsp_payload_error_2),
        .LsuCachelessPlugin_logic_bus_rsp_payload_data(dmem_rsp_payload_data_2),
        .clk(clk60),
        .reset(reset_dsp_enabled_clk60)
    );

    VexiiRiscv vexii3 (
        .PrivilegedPlugin_logic_rdtime(0),
        .PrivilegedPlugin_logic_harts_0_int_m_timer(0),
        .PrivilegedPlugin_logic_harts_0_int_m_software(0),
        .PrivilegedPlugin_logic_harts_0_int_m_external(0),
        .FetchCachelessPlugin_logic_bus_cmd_valid(imem_cmd_valid_3),
        .FetchCachelessPlugin_logic_bus_cmd_ready(imem_cmd_ready_3),
        .FetchCachelessPlugin_logic_bus_cmd_payload_id(imem_cmd_payload_id_3),
        .FetchCachelessPlugin_logic_bus_cmd_payload_address(imem_cmd_payload_address_3),
        .FetchCachelessPlugin_logic_bus_rsp_valid(imem_rsp_valid_3),
        .FetchCachelessPlugin_logic_bus_rsp_payload_id(imem_rsp_payload_id_3),
        .FetchCachelessPlugin_logic_bus_rsp_payload_error(imem_rsp_payload_error_3),
        .FetchCachelessPlugin_logic_bus_rsp_payload_word(imem_rsp_payload_word_3),
        .LsuCachelessPlugin_logic_bus_cmd_valid(dmem_cmd_valid_3),
        .LsuCachelessPlugin_logic_bus_cmd_ready(dmem_cmd_ready_3),
        .LsuCachelessPlugin_logic_bus_cmd_payload_id(dmem_cmd_payload_id_3),
        .LsuCachelessPlugin_logic_bus_cmd_payload_write(dmem_cmd_payload_write_3),
        .LsuCachelessPlugin_logic_bus_cmd_payload_address(dmem_cmd_payload_address_3),
        .LsuCachelessPlugin_logic_bus_cmd_payload_data(dmem_cmd_payload_data_3),
        .LsuCachelessPlugin_logic_bus_cmd_payload_size(dmem_cmd_payload_size_3),
        .LsuCachelessPlugin_logic_bus_cmd_payload_mask(dmem_cmd_payload_mask_3),
        .LsuCachelessPlugin_logic_bus_cmd_payload_io(dmem_cmd_payload_io_3),
        .LsuCachelessPlugin_logic_bus_cmd_payload_fromHart(dmem_cmd_payload_fromHart_3),
        .LsuCachelessPlugin_logic_bus_cmd_payload_uopId(dmem_cmd_payload_uopId_3),
        .LsuCachelessPlugin_logic_bus_rsp_valid(dmem_rsp_valid_3),
        .LsuCachelessPlugin_logic_bus_rsp_payload_id(dmem_rsp_payload_id_3),
        .LsuCachelessPlugin_logic_bus_rsp_payload_error(dmem_rsp_payload_error_3),
        .LsuCachelessPlugin_logic_bus_rsp_payload_data(dmem_rsp_payload_data_3),
        .clk(clk60),
        .reset(reset_dsp_enabled_clk60)
    );

    /*verilator tracing_on*/

    bit [31:0] frame_struct_adr  /*verilator public_flat_rd*/;
    bit [31:0] frame_y_adr  /*verilator public_flat_rd*/;
    wire expose_frame_struct_adr_clk60  = (dmem_cmd_payload_address_1 == 32'h10000010 && dmem_cmd_payload_write_1 && dmem_cmd_valid_1) ;
    wire expose_frame_y_adr_clk60  = (dmem_cmd_payload_address_1 == 32'h10000018 && dmem_cmd_payload_write_1 && dmem_cmd_valid_1) ;
    bit [31:0] soft_state1  /*verilator public_flat_rd*/ = 0;
    bit [31:0] soft_state2  /*verilator public_flat_rd*/ = 0;
    bit [31:0] soft_state3  /*verilator public_flat_rd*/ = 0;
    wire expose_frame_struct_adr  /*verilator public_flat_rd*/;
    wire expose_frame_y_adr  /*verilator public_flat_rd*/;

    flag_cross_domain cross_expose_frame_struct_adr (
        .clk_a(clk60),
        .clk_b(clk30),
        .flag_in_clk_a(expose_frame_struct_adr_clk60),
        .flag_out_clk_b(expose_frame_struct_adr)
    );

    flag_cross_domain cross_expose_frame_y_adr (
        .clk_a(clk60),
        .clk_b(clk30),
        .flag_in_clk_a(expose_frame_y_adr_clk60),
        .flag_out_clk_b(expose_frame_y_adr)
    );

    always_ff @(posedge clk60) begin
        if (expose_frame_struct_adr_clk60) frame_struct_adr <= dmem_cmd_payload_data_1;
        if (expose_frame_y_adr_clk60) frame_y_adr <= dmem_cmd_payload_data_1;
    end

    bit cache_miss_2;
    bit [2:0] cache_hit_adr_2;
    bit [63:0] cache_2[8][3];
    bit [63:0] cache_2_out;
    bit [1:0] data_burst_cnt_2;
    bit [23-3:0] cache_adr_2[8] = '{default: 8000};
    bit [2:0] cache_write_adr_2 = 0;

`ifdef VERILATOR
    bit [23-3:0] missed_cache_adr_2[16] = '{default: 8000};
    bit [3:0] missed_cache_adr_index_2;
`endif

    bit cache_miss_3;
    bit [2:0] cache_hit_adr_3;
    bit [63:0] cache_3[8][3];
    bit [63:0] cache_3_out;
    bit [1:0] data_burst_cnt_3;
    bit [23-3:0] cache_adr_3[8] = '{default: 8000};
    bit [2:0] cache_write_adr_3 = 0;

`ifdef VERILATOR
    bit [23-3:0] missed_cache_adr_3[16] = '{default: 8000};
    bit [3:0] missed_cache_adr_index_3;
`endif

    always_comb begin
        integer i;
        bit cache_hit;

        imem_cmd_ready_3 = 1;
        imem_rsp_payload_word_3 = memory_out_i3;

        dmem_cmd_ready_3 = 1;
        dmem_rsp_payload_data_3 = memory_out_d3;

        // Stall on DDR write until resolved
        if (worker_3_ddr.acquire && dmem_cmd_valid_3 && dmem_cmd_payload_write_3 && dmem_cmd_payload_address_3[31:28] == 4'd5)
            dmem_cmd_ready_3 = 0;

        // Stall on DDR read until resolved
        if (dmem_cmd_payload_address_3_q[31:28] == 4'd5 && !dmem_cmd_payload_write_3_q && dmem_cmd_valid_3_q && worker_3_ddr.acquire)
            dmem_cmd_ready_3 = 0;

        // Handle read directly after write to avoid read and write at the same time
        if (dmem_cmd_payload_address_3[31:28] == 4'd5 && !dmem_cmd_payload_write_3 && dmem_cmd_valid_3 && worker_3_ddr.acquire)
            dmem_cmd_ready_3 = 0;

        cache_hit_adr_3 = 0;
        cache_miss_3 = 0;
        cache_hit = 0;
        for (i = 0; i < 8; i++) begin
            if ((dmem_cmd_payload_address_3[23:3] >= cache_adr_3[i]) && (dmem_cmd_payload_address_3[23:3] <= cache_adr_3[i] + 2)) begin
                cache_hit_adr_3 = 3'(i);
                cache_hit = 1;
            end
        end
        cache_miss_3 = !cache_hit;

        if (dmem_cmd_valid_3_q) begin
            case (dmem_cmd_payload_address_3_q[31:28])
                4'd5: begin  // Video SRAM region
                    dmem_rsp_payload_data_3 = dmem_cmd_payload_address_3_q[2] ?
                     cache_3_out[63:32] :
                     cache_3_out[31:0];
                end
                4'd4: begin  // Shared SRAM region
                    dmem_rsp_payload_data_3 = shared13_out_3;
                end
                4'd1: begin
                    // I/O Area
                    // Magic Number for Core 3
                    dmem_rsp_payload_data_3 = 32'h00004212;
                end
                4'd0: begin
                    dmem_rsp_payload_data_3 = memory_out_d3;
                end
                default: begin
                    dmem_rsp_payload_data_3 = memory_out_d3;
                end
            endcase
        end
    end

    always_comb begin
        integer i;
        bit cache_hit;

        imem_cmd_ready_2 = 1;
        imem_rsp_payload_word_2 = memory_out_i2;

        dmem_cmd_ready_2 = 1;
        dmem_rsp_payload_data_2 = memory_out_d2;

        // Stall on DDR write until resolved
        if (worker_2_ddr.acquire && dmem_cmd_valid_2 && dmem_cmd_payload_write_2 && dmem_cmd_payload_address_2[31:28] == 4'd5)
            dmem_cmd_ready_2 = 0;

        // Stall on DDR read until resolved
        if (dmem_cmd_payload_address_2_q[31:28] == 4'd5 && !dmem_cmd_payload_write_2_q && dmem_cmd_valid_2_q && worker_2_ddr.acquire)
            dmem_cmd_ready_2 = 0;

        // Handle read directly after write to avoid read and write at the same time
        if (dmem_cmd_payload_address_2[31:28] == 4'd5 && !dmem_cmd_payload_write_2 && dmem_cmd_valid_2 && worker_2_ddr.acquire)
            dmem_cmd_ready_2 = 0;

        cache_hit_adr_2 = 0;
        cache_miss_2 = 0;
        cache_hit = 0;
        for (i = 0; i < 8; i++) begin
            if ((dmem_cmd_payload_address_2[23:3] >= cache_adr_2[i]) && (dmem_cmd_payload_address_2[23:3] <= cache_adr_2[i] + 2)) begin
                cache_hit_adr_2 = 3'(i);
                cache_hit = 1;
            end
        end
        cache_miss_2 = !cache_hit;

        if (dmem_cmd_valid_2_q) begin
            case (dmem_cmd_payload_address_2_q[31:28])
                4'd5: begin  // Video SRAM region
                    dmem_rsp_payload_data_2 = dmem_cmd_payload_address_2_q[2] ?
                     cache_2_out[63:32] :
                     cache_2_out[31:0];
                end
                4'd4: begin  // Shared SRAM region
                    dmem_rsp_payload_data_2 = shared12_out_2;
                end
                4'd1: begin
                    // I/O Area
                    // Magic Number for Core 2
                    dmem_rsp_payload_data_2 = 32'h00004218;
                end
                4'd0: begin
                    dmem_rsp_payload_data_2 = memory_out_d2;
                end
                default: begin
                    dmem_rsp_payload_data_2 = memory_out_d2;
                end
            endcase
        end

    end

    always_comb begin
        imem_cmd_ready_1 = 1;
        imem_rsp_payload_word_1 = memory_out_i1;

        dmem_cmd_ready_1 = hw_read_count == 0;
        dmem_rsp_payload_data_1 = reverse_endian_32(mpeg_in_fifo_out);

        if (dmem_cmd_valid_1_q && dmem_cmd_ready_1_q) begin
            case (dmem_cmd_payload_address_1_q[31:28])
                4'd4: begin  // Shared SRAM region
                    if (dmem_cmd_payload_address_1_q[27:24] == 1)
                        dmem_rsp_payload_data_1 = shared12_out_1;
                    else dmem_rsp_payload_data_1 = shared13_out_1;
                end
                4'd1: begin
                    // I/O Area
                    if (!dmem_cmd_payload_write_1_q) begin
                        if (dmem_cmd_payload_address_1_q == 32'h10002000)
                            dmem_rsp_payload_data_1 = {4'b0000, mpeg_stream_fifo_write_adr_clk60};
                        if (dmem_cmd_payload_address_1_q == 32'h10002004)
                            dmem_rsp_payload_data_1 = mpeg_stream_bit_index;
                        if (dmem_cmd_payload_address_1_q == 32'h10002008)
                            dmem_rsp_payload_data_1 = hw_read_result;
                        if (dmem_cmd_payload_address_1_q == 32'h1000200c)
                            dmem_rsp_payload_data_1 = {16'b0, dct_coeff_result};
                    end
                end
                4'd0: begin
                    dmem_rsp_payload_data_1 = memory_out_d1;
                end
                default: begin
                    // Assign the rest of the memory to the MPEG FIFO to fake a real big file
                    dmem_rsp_payload_data_1 = reverse_endian_32(mpeg_in_fifo_out);
                end
            endcase
        end
    end

    planar_yuv_s just_decoded;

    bit signed [15:0] shared_buffer_level = 0;

    wire shared_buffer_level_inc = dmem_cmd_payload_address_1 == 32'h10000014 && dmem_cmd_payload_write_1 && dmem_cmd_valid_1;
    wire shared_buffer_level_dec1 = dmem_cmd_payload_address_2 == 32'h10000014 && dmem_cmd_payload_write_2 && dmem_cmd_valid_2;
    wire shared_buffer_level_dec2 = dmem_cmd_payload_address_3 == 32'h10000014 && dmem_cmd_payload_write_3 && dmem_cmd_valid_3;

    bit [31:0] dmem_cmd_payload_address_1_q;
    bit dmem_cmd_valid_1_q;
    bit dmem_cmd_ready_1_q;
    bit dmem_cmd_payload_write_1_q;

    bit [31:0] dmem_cmd_payload_address_2_q;
    bit dmem_cmd_valid_2_q;
    bit dmem_cmd_ready_2_q;
    bit dmem_cmd_payload_write_2_q;

    bit [31:0] dmem_cmd_payload_address_3_q;
    bit dmem_cmd_valid_3_q;
    bit dmem_cmd_ready_3_q;
    bit dmem_cmd_payload_write_3_q;

    always_ff @(posedge clk60) begin
        imem_rsp_valid_1 <= 0;
        dmem_rsp_valid_1 <= 0;

        dmem_cmd_payload_address_1_q <= dmem_cmd_payload_address_1;
        dmem_cmd_valid_1_q <= dmem_cmd_valid_1;
        dmem_cmd_ready_1_q <= dmem_cmd_ready_1;
        dmem_cmd_payload_write_1_q <= dmem_cmd_payload_write_1;

        shared_buffer_level <= shared_buffer_level + (shared_buffer_level_inc ? 1:0) - (shared_buffer_level_dec1 ? 1 : 0) - (shared_buffer_level_dec2 ? 1:0);

        if (dmem_cmd_payload_address_1 == 32'h1000000c && dmem_cmd_payload_write_1 && dmem_cmd_valid_1)begin
            $display("Core 1 stopped at %x with code %x", imem_cmd_payload_address_1,
                     dmem_cmd_payload_data_1);
            $finish();
        end
        if (dmem_cmd_payload_address_1 == 32'h10000030 && dmem_cmd_payload_write_1 && dmem_cmd_valid_1)
            soft_state1 <= dmem_cmd_payload_data_1;

        if (expose_frame_struct_adr_clk60) begin
            frames_decoded <= frames_decoded + 1;
        end

        if (dmem_cmd_payload_address_1 == 32'h10000000 && dmem_cmd_valid_1 && dmem_cmd_payload_write_1 && dmem_cmd_ready_1)
            $display("Debug out %x", dmem_cmd_payload_data_1);

        // Core 1 memory access
        if (dmem_cmd_valid_1 && dmem_cmd_ready_1) begin
            dmem_rsp_payload_id_1 <= dmem_cmd_payload_id_1;
            dmem_rsp_valid_1 <= 1;

            case (dmem_cmd_payload_address_1[31:28])
                4'd4: begin  // Shared SRAM region
                end
                4'd1: begin
                    if (dmem_cmd_payload_address_1[15:0] == 16'h3000)
                        just_decoded.y_adr <= dmem_cmd_payload_data_1[28:0];
                    if (dmem_cmd_payload_address_1[15:0] == 16'h3004)
                        just_decoded.u_adr <= dmem_cmd_payload_data_1[28:0];
                    if (dmem_cmd_payload_address_1[15:0] == 16'h3008)
                        just_decoded.v_adr <= dmem_cmd_payload_data_1[28:0];
                end
                4'd0: begin
                end
                default: ;
            endcase
        end

        // Instruction fetch logic for core 1
        if (imem_cmd_valid_1) begin
            imem_rsp_valid_1 <= 1;
            imem_rsp_payload_id_1 <= imem_cmd_payload_id_1;
        end
    end

    // 0011 like the N64 core to force a base of 0x30000000
    localparam bit [3:0] DDR_CORE_BASE = 4'b0011;

    // Instruction fetch logic for core 2
    always_ff @(posedge clk60) begin
        imem_rsp_valid_2 <= 0;

        if (imem_cmd_valid_2) begin
            imem_rsp_valid_2 <= 1;
            imem_rsp_payload_id_2 <= imem_cmd_payload_id_2;
        end
    end

    // Instruction fetch logic for core 3
    always_ff @(posedge clk60) begin
        imem_rsp_valid_3 <= 0;

        if (imem_cmd_valid_3) begin
            imem_rsp_valid_3 <= 1;
            imem_rsp_payload_id_3 <= imem_cmd_payload_id_3;
        end
    end

    always_ff @(posedge clk60) begin
        integer i;

        dmem_rsp_valid_2 <= 0;
        dmem_rsp_valid_3 <= 0;

        if (!worker_2_ddr.busy && worker_2_ddr.write) begin
            worker_2_ddr.write   <= 0;
            worker_2_ddr.acquire <= 0;
        end

        if (!worker_2_ddr.busy && worker_2_ddr.read) begin
            worker_2_ddr.read <= 0;
        end

        if (data_burst_cnt_2 != 3 && worker_2_ddr.rdata_ready) begin
            if (worker_2_ddr.rdata_ready) begin
                data_burst_cnt_2 <= data_burst_cnt_2 + 1;
                cache_2[cache_write_adr_2][data_burst_cnt_2] <= worker_2_ddr.rdata;
            end
            if (data_burst_cnt_2 == 2) begin
                worker_2_ddr.read <= 0;
                worker_2_ddr.acquire <= 0;
                dmem_rsp_valid_2 <= 1;
                cache_write_adr_2 <= cache_write_adr_2 + 1;
            end
        end

        if (worker_2_ddr.rdata_ready && data_burst_cnt_2 == 2) begin
            // After a cache miss, the first entry is always the right one!
            cache_2_out <= cache_2[cache_write_adr_2][0];
        end else begin
            // We have hit the cache. Lookup
            cache_2_out <= cache_2[cache_hit_adr_2][2'(dmem_cmd_payload_address_2[27:3]-cache_adr_2[cache_hit_adr_2])];
        end

        if (dmem_cmd_ready_2) begin
            if (dmem_cmd_valid_2) begin
                dmem_cmd_payload_address_2_q <= dmem_cmd_payload_address_2;
                dmem_cmd_payload_write_2_q   <= dmem_cmd_payload_write_2;
            end
            dmem_cmd_valid_2_q <= dmem_cmd_valid_2;
        end
        dmem_cmd_ready_2_q <= dmem_cmd_ready_2;

        if (!worker_3_ddr.busy && worker_3_ddr.write) begin
            worker_3_ddr.write   <= 0;
            worker_3_ddr.acquire <= 0;
        end

        if (!worker_3_ddr.busy && worker_3_ddr.read) begin
            worker_3_ddr.read <= 0;
        end

        if (data_burst_cnt_3 != 3 && worker_3_ddr.rdata_ready) begin
            if (worker_3_ddr.rdata_ready) begin
                data_burst_cnt_3 <= data_burst_cnt_3 + 1;
                cache_3[cache_write_adr_3][data_burst_cnt_3] <= worker_3_ddr.rdata;
            end
            if (data_burst_cnt_3 == 2) begin
                worker_3_ddr.read <= 0;
                worker_3_ddr.acquire <= 0;
                dmem_rsp_valid_3 <= 1;
                cache_write_adr_3 <= cache_write_adr_3 + 1;
            end
        end

        if (worker_3_ddr.rdata_ready && data_burst_cnt_3 == 2) begin
            // After a cache miss, the first entry is always the right one!
            cache_3_out <= cache_3[cache_write_adr_3][0];
        end else begin
            // We have hit the cache. Lookup
            cache_3_out <= cache_3[cache_hit_adr_3][2'(dmem_cmd_payload_address_3[27:3]-cache_adr_3[cache_hit_adr_3])];
        end


        if (dmem_cmd_ready_3) begin
            if (dmem_cmd_valid_3) begin
                dmem_cmd_payload_address_3_q <= dmem_cmd_payload_address_3;
                dmem_cmd_payload_write_3_q   <= dmem_cmd_payload_write_3;
            end
            dmem_cmd_valid_3_q <= dmem_cmd_valid_3;
        end
        dmem_cmd_ready_3_q <= dmem_cmd_ready_3;


        if (dmem_cmd_payload_address_2 == 32'h1000000c && dmem_cmd_payload_write_2 && dmem_cmd_valid_2 && dmem_cmd_ready_2) begin
            $display("Core 2 stopped at %x with code %x", imem_cmd_payload_address_2,
                     dmem_cmd_payload_data_2);
            $finish();
        end

        if (dmem_cmd_payload_address_3 == 32'h1000000c && dmem_cmd_payload_write_3 && dmem_cmd_valid_3 && dmem_cmd_ready_3) begin
            $display("Core 3 stopped at %x with code %x", imem_cmd_payload_address_3,
                     dmem_cmd_payload_data_3);
            $finish();
        end


        if (dmem_cmd_payload_address_2 == 32'h10000030 && dmem_cmd_payload_write_2 && dmem_cmd_valid_2)
            soft_state2 <= dmem_cmd_payload_data_2;
        if (dmem_cmd_payload_address_3 == 32'h10000030 && dmem_cmd_payload_write_3 && dmem_cmd_valid_3)
            soft_state3 <= dmem_cmd_payload_data_3;

        // Core 2 memory access
        if (dmem_cmd_valid_2 && dmem_cmd_ready_2) begin
            dmem_rsp_payload_id_2 <= dmem_cmd_payload_id_2;
            dmem_rsp_valid_2 <= 1;

            case (dmem_cmd_payload_address_2[31:28])
                4'd5: begin  // Core 1 private memory
                    //assert(dmem_cmd_payload_address_2[1:0] == 2'b00);

                    if (dmem_cmd_payload_write_2) begin
                        assert (worker_2_ddr.write == 0);
                        worker_2_ddr.addr <= {DDR_CORE_BASE, dmem_cmd_payload_address_2[27:3]};

                        if (dmem_cmd_payload_address_2[2] == 1'b1) begin
                            worker_2_ddr.write <= dmem_cmd_payload_mask_2[3];
                            worker_2_ddr.acquire <= dmem_cmd_payload_mask_2[3];
                            worker_2_ddr.burstcnt <= 1;
                            // verilog_format: off
                            if (dmem_cmd_payload_mask_2[0]) worker_2_ddr.wdata[39:32] <= dmem_cmd_payload_data_2[7:0];
                            if (dmem_cmd_payload_mask_2[1]) worker_2_ddr.wdata[47:40] <= dmem_cmd_payload_data_2[15:8];
                            if (dmem_cmd_payload_mask_2[2]) worker_2_ddr.wdata[55:48] <= dmem_cmd_payload_data_2[23:16];
                            if (dmem_cmd_payload_mask_2[3]) worker_2_ddr.wdata[63:56] <= dmem_cmd_payload_data_2[31:24];
                        end else begin
                            if (dmem_cmd_payload_mask_2[0]) worker_2_ddr.wdata[7:0] <= dmem_cmd_payload_data_2[7:0];
                            if (dmem_cmd_payload_mask_2[1]) worker_2_ddr.wdata[15:8] <= dmem_cmd_payload_data_2[15:8];
                            if (dmem_cmd_payload_mask_2[2]) worker_2_ddr.wdata[23:16] <= dmem_cmd_payload_data_2[23:16];
                            if (dmem_cmd_payload_mask_2[3]) worker_2_ddr.wdata[31:24] <= dmem_cmd_payload_data_2[31:24];
                        end
                        // verilog_format: on
                    end else if (cache_miss_2) begin
                        // $display("Cache Miss 2 %x %x", dmem_cmd_payload_address_2, dmem_cmd_payload_address_2[27:3]);
                        worker_2_ddr.read <= 1;
                        worker_2_ddr.acquire <= 1;
                        worker_2_ddr.burstcnt <= 3;
                        data_burst_cnt_2 <= 0;
                        dmem_rsp_valid_2 <= 0;
                        worker_2_ddr.addr <= {DDR_CORE_BASE, dmem_cmd_payload_address_2[27:3]};
                        cache_adr_2[cache_write_adr_2] <= dmem_cmd_payload_address_2[23:3];

`ifdef VERILATOR
                        // Check quality of cache. Can we get faster with a bigger cache?
                        for (i = 0; i < 16; i++) begin
                            if (dmem_cmd_payload_address_2[23:3] == missed_cache_adr_2[i]) begin
                                $display("Cache 2 Miss with recently requested address %x %x",
                                         dmem_cmd_payload_address_2,
                                         dmem_cmd_payload_address_2[27:3]);
                                //$finish();
                            end
                        end
                        missed_cache_adr_2[missed_cache_adr_index_2] <= dmem_cmd_payload_address_2[23:3];
                        missed_cache_adr_index_2 <= missed_cache_adr_index_2 + 1;
`endif
                    end else begin
                        //$display("Cache Hit %x %x",dmem_cmd_payload_address_2,dmem_cmd_payload_address_2[27:3]);
                    end

                end
                4'd4: begin  // Shared SRAM region
                end
                4'd0: begin  // Core 2 private memory

                end
                default: ;

            endcase
        end

        // Core 3 memory access
        if (dmem_cmd_valid_3 && dmem_cmd_ready_3) begin
            dmem_rsp_payload_id_3 <= dmem_cmd_payload_id_3;
            dmem_rsp_valid_3 <= 1;

            case (dmem_cmd_payload_address_3[31:28])
                4'd5: begin  // Core 1 private memory
                    //assert(dmem_cmd_payload_address_3[1:0] == 2'b00);

                    if (dmem_cmd_payload_write_3) begin
                        assert (worker_3_ddr.write == 0);
                        worker_3_ddr.addr <= {DDR_CORE_BASE, dmem_cmd_payload_address_3[27:3]};

                        if (dmem_cmd_payload_address_3[2] == 1'b1) begin
                            worker_3_ddr.write <= dmem_cmd_payload_mask_3[3];
                            worker_3_ddr.acquire <= dmem_cmd_payload_mask_3[3];
                            worker_3_ddr.burstcnt <= 1;
                            // verilog_format: off
                            if (dmem_cmd_payload_mask_3[0]) worker_3_ddr.wdata[39:32] <= dmem_cmd_payload_data_3[7:0];
                            if (dmem_cmd_payload_mask_3[1]) worker_3_ddr.wdata[47:40] <= dmem_cmd_payload_data_3[15:8];
                            if (dmem_cmd_payload_mask_3[2]) worker_3_ddr.wdata[55:48] <= dmem_cmd_payload_data_3[23:16];
                            if (dmem_cmd_payload_mask_3[3]) worker_3_ddr.wdata[63:56] <= dmem_cmd_payload_data_3[31:24];
                        end else begin
                            if (dmem_cmd_payload_mask_3[0]) worker_3_ddr.wdata[7:0] <= dmem_cmd_payload_data_3[7:0];
                            if (dmem_cmd_payload_mask_3[1]) worker_3_ddr.wdata[15:8] <= dmem_cmd_payload_data_3[15:8];
                            if (dmem_cmd_payload_mask_3[2]) worker_3_ddr.wdata[23:16] <= dmem_cmd_payload_data_3[23:16];
                            if (dmem_cmd_payload_mask_3[3]) worker_3_ddr.wdata[31:24] <= dmem_cmd_payload_data_3[31:24];
                        end
                        // verilog_format: on
                    end else if (cache_miss_3) begin
                        //$display("Cache Miss %x %x", dmem_cmd_payload_address_3,
                        //         dmem_cmd_payload_address_3[27:3]);
                        worker_3_ddr.read <= 1;
                        worker_3_ddr.acquire <= 1;
                        worker_3_ddr.burstcnt <= 3;
                        data_burst_cnt_3 <= 0;
                        dmem_rsp_valid_3 <= 0;
                        worker_3_ddr.addr <= {DDR_CORE_BASE, dmem_cmd_payload_address_3[27:3]};
                        cache_adr_3[cache_write_adr_3] <= dmem_cmd_payload_address_3[23:3];

`ifdef VERILATOR
                        // Check quality of cache. Can we get faster with a bigger cache?
                        for (i = 0; i < 16; i++) begin
                            if (dmem_cmd_payload_address_3[23:3] == missed_cache_adr_3[i]) begin
                                $display("Cache 3 Miss with recently requested address %x %x",
                                         dmem_cmd_payload_address_3,
                                         dmem_cmd_payload_address_3[27:3]);
                                //$finish();
                            end
                        end
                        missed_cache_adr_3[missed_cache_adr_index_3] <= dmem_cmd_payload_address_3[23:3];
                        missed_cache_adr_index_3 <= missed_cache_adr_index_3 + 1;
`endif
                    end else begin
                        //$display("Cache Hit %x %x",dmem_cmd_payload_address_3,dmem_cmd_payload_address_3[27:3]);
                    end

                end
                4'd4: begin  // Shared SRAM region
                end
                4'd0: begin  // Core 3 private memory

                end
                default: ;

            endcase
        end
    end


    planar_yuv_s for_display;
    wire just_decoded_commit = dmem_cmd_payload_write_1 && dmem_cmd_valid_1 && dmem_cmd_ready_1 && dmem_cmd_payload_address_1==32'h10003010;
    wire for_display_valid;
    bit for_display_strobe;
    bit latch_frame_for_display;
    wire latch_frame_for_display_clk60;

    // Assuming 30 MHz clock rate and 25 Hz frame rate
    localparam bit [23:0] TICKS_PER_FRAME = 24'(int'(30e6) / 25);
    bit [23:0] playback_frame_cnt;

    // In theory this machine could run with clk60.
    // But I'm not so sure about the final frequency and timing is vital
    always_ff @(posedge clk30) begin
        latch_frame_for_display <= 0;

        if (!playback_active) playback_frame_cnt <= 0;
        else begin
            playback_frame_cnt <= playback_frame_cnt + 1;

            // Only for simulation. Ensure that frames are always available - no underflow
            if (playback_frame_cnt == 0) assert (for_display_valid);

            if (playback_frame_cnt == TICKS_PER_FRAME - 1) playback_frame_cnt <= 0;
            if (playback_frame_cnt == 0 && for_display_valid) latch_frame_for_display <= 1;
        end
    end

    flag_cross_domain cross_latch_frame (
        .clk_a(clk30),
        .clk_b(clk60),
        .flag_in_clk_a(latch_frame_for_display),
        .flag_out_clk_b(latch_frame_for_display_clk60)
    );


    yuv_frame_adr_fifo readyframes (
        .clk_in(clk60),
        .reset_in(reset_dsp_enabled_clk60),
        .wdata(just_decoded),
        .we(just_decoded_commit),
        .reset_out(reset_dsp_enabled_clk60),
        .clk_out(clk60),
        .strobe(latch_frame_for_display_clk60),
        .valid(for_display_valid),
        .q(for_display)
    );

    frameplayer frameplayer (
        .clk(clk30),
        .clkddr(clk60),
        .reset,
        .ddrif(player_ddr),
        .vidout,
        .hsync,
        .vsync,
        .hblank,
        .vblank,
        .frame(for_display),
        .latch_frame(latch_frame_for_display)
    );
endmodule

