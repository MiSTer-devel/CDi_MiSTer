derive_pll_clocks
derive_clock_uncertainty

# core specific constraints

set_false_path -from {*|flag_cross_domain*|flagtoggle_clk_a*} -to {*|flag_cross_domain*|synca_clk_b*}
set_false_path -from {*|signal_cross_domain*|signal_clk_a} -to {*|signal_cross_domain*|synca_clk_b[0]}
set_false_path -from {*|ddr_to_byte_fifo:fifo_y|waddr_q*} -to {*|ddr_to_byte_fifo:fifo_y|waddr_q2*}
set_false_path -from {*|ddr_to_byte_fifo:fifo_y|raddr_q*} -to {*|ddr_to_byte_fifo:fifo_y|raddr_q2*}

set_false_path -from {*|mpeg_video:video|mpeg_stream_fifo_write_adr_syncval*} -to {*|mpeg_video:video|mpeg_stream_fifo_write_adr_clk_mpeg*}

set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|frame_period_clk_mpeg*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|frame_period*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|yuv_frame_adr_fifo:readyframes|valid} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|for_display_valid*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_height*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|frameplayer:frameplayer|frame_height_clkvideo*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_width*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|frameplayer:frameplayer|frame_width_clkvideo*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|pictures_in_output_fifo_clk_mpeg_gray_q*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|pictures_in_output_fifo_clk30_gray*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|frameplayer:frameplayer|linecnt*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|frameplayer:frameplayer|linecnt_clkddr*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|yuv_frame_adr_fifo:readyframes|altsyncram:ram_rtl_0|altsyncram_g3n1:auto_generated|ram_block1a0~PORT_B_WRITE_ENABLE_REG} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|first_intra_frame_of_gop_clk30}

# protected by latency between event_frame_decoded_clk_mpeg and event_frame_decoded
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_width_clk_mpeg*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_width*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_height_clk_mpeg*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_height*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_timecode_clk_mpeg*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_timecode*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_frameperiod_90khz_clk_mpeg*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_frameperiod_90khz*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_frameperiod_rawhdr_clk_mpeg*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_frameperiod_rawhdr*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_tempref_clk_mpeg*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|decoder_tempref*}

# protected by latch_frame_clkvideo
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|latched_window_height*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|frameplayer:frameplayer|frame_height_clkddr*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|latched_window_width*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|frameplayer:frameplayer|frame_width_clkddr*}

# protected by latch_frame_clkddr
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|latched_window_offset_y*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|frameplayer:frameplayer|window_y_clkddr*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|latched_window_offset_x*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|frameplayer:frameplayer|window_x_clkddr*}

# protection not required because of context
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|fmv_slow_motion*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|slow_motion_clkddr*}

# protected by latency between latch_frame_for_display and latch_frame_for_display_clk_mpeg
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|yuv_frame_adr_fifo:readyframes|*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|display_timecode*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|yuv_frame_adr_fifo:readyframes|*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|display_video_status*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|yuv_frame_adr_fifo:readyframes|*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|display_width*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|yuv_frame_adr_fifo:readyframes|*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|display_height*}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|yuv_frame_adr_fifo:readyframes|*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|first_intra_frame_of_gop_clk30}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|yuv_frame_adr_fifo:readyframes|*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|first_intra_frame_of_seq_clk30}
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|desync2_q*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|desync2_q_clk_mpeg*}


# protected by last_decoded_timestamp_updated phase latency
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|last_decoded_timestamp_clk_mpeg*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|last_decoded_timestamp*}

# protected by demuxer_decoding_timestamp_updated_clk_mpeg
set_false_path -from {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_demuxer:video_demuxer|decoding_timestamp*} -to {emu:emu|cditop:cditop|vmpeg:vmpeg_inst|mpeg_video:video|demuxer_decoding_timestamp_clk_mpeg*}
