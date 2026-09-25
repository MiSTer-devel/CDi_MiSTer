// Only for gtkwave to align video images with the signals in the waveform
int frame_index  /*verilator public_flat_rw*/;
bit executing_dvc_rom_instructions  /*verilator public_flat_rw*/ = 0;

// Tool to observe variables in the MV Map Descriptor returned by MV_Info()
bit [23:0] mvmapdesc  /*verilator public_flat_rw*/ = 0;

struct {
    bit [15:0] MD_Id, MD_Type, MD_Stream;
    bit [31:0] MD_StLoop, MD_EnLoop;
    bit [15:0] MD_LpCnt, MD_LCntr;
    bit [31:0] MD_ImgSz, MD_DecWin, MD_DecOff, MD_ScrOrg, MD_ScrOff;
    bit [31:0] MD_BCol, MD_Speed, MD_TimeCd;
    bit [15:0] MD_TmpRef;
    bit [7:0] MD_PicRt;
    bit [87:0] MD_Res1;
} mvmap = '{default: 0};

always @(posedge clk30) begin
    if (mvmapdesc != 0 && bus_ack && write_strobe && as && (lds || uds)) begin
        case (addr_byte - mvmapdesc)
            24'h00: begin
                mvmap.MD_Id = cpu_data;
                $display("MVmapDesc MD_Id = %x", cpu_data);
            end
            24'h02: begin
                mvmap.MD_Type = cpu_data;
                $display("MVmapDesc MD_Type = %x", cpu_data);
            end
            24'h04: begin
                mvmap.MD_Stream = cpu_data;
                $display("MVmapDesc MD_Stream = %x", cpu_data);
            end
            24'h06: begin
                mvmap.MD_StLoop[31:16] = cpu_data;
                $display("MVmapDesc MD_StLoop = %x", {cpu_data, mvmap.MD_StLoop[15:0]});
            end
            24'h08: begin
                mvmap.MD_StLoop[15:0] = cpu_data;
                $display("MVmapDesc MD_StLoop = %x", {mvmap.MD_StLoop[31:16], cpu_data});
            end
            24'h0a: begin
                mvmap.MD_EnLoop[31:16] = cpu_data;
                $display("MVmapDesc MD_EnLoop = %x", {cpu_data, mvmap.MD_EnLoop[15:0]});
            end
            24'h0c: begin
                mvmap.MD_EnLoop[15:0] = cpu_data;
                $display("MVmapDesc MD_EnLoop = %x", {mvmap.MD_EnLoop[31:16], cpu_data});
            end
            24'h0e: begin
                mvmap.MD_LpCnt = cpu_data;
                $display("MVmapDesc MD_LpCnt = %x", cpu_data);
            end
            24'h10: begin
                mvmap.MD_LCntr = cpu_data;
                $display("MVmapDesc MD_LCntr = %x", cpu_data);
            end
            24'h12: begin
                mvmap.MD_ImgSz[31:16] = cpu_data;
                $display("MVmapDesc MD_ImgSz = %x", {cpu_data, mvmap.MD_ImgSz[15:0]});
            end
            24'h14: begin
                mvmap.MD_ImgSz[15:0] = cpu_data;
                $display("MVmapDesc MD_ImgSz = %x", {mvmap.MD_ImgSz[31:16], cpu_data});
            end
            24'h16: begin
                mvmap.MD_DecWin[31:16] = cpu_data;
                $display("MVmapDesc MD_DecWin = %x", {cpu_data, mvmap.MD_DecWin[15:0]});
            end
            24'h18: begin
                mvmap.MD_DecWin[15:0] = cpu_data;
                $display("MVmapDesc MD_DecWin = %x", {mvmap.MD_DecWin[31:16], cpu_data});
            end
            24'h1a: begin
                mvmap.MD_DecOff[31:16] = cpu_data;
                $display("MVmapDesc MD_DecOff = %x", {cpu_data, mvmap.MD_DecOff[15:0]});
            end
            24'h1c: begin
                mvmap.MD_DecOff[15:0] = cpu_data;
                $display("MVmapDesc MD_DecOff = %x", {mvmap.MD_DecOff[31:16], cpu_data});
            end
            24'h1e: begin
                mvmap.MD_ScrOrg[31:16] = cpu_data;
                $display("MVmapDesc MD_ScrOrg = %x", {cpu_data, mvmap.MD_ScrOrg[15:0]});
            end
            24'h20: begin
                mvmap.MD_ScrOrg[15:0] = cpu_data;
                $display("MVmapDesc MD_ScrOrg = %x", {mvmap.MD_ScrOrg[31:16], cpu_data});
            end
            24'h22: begin
                mvmap.MD_ScrOff[31:16] = cpu_data;
                $display("MVmapDesc MD_ScrOff = %x", {cpu_data, mvmap.MD_ScrOff[15:0]});
            end
            24'h24: begin
                mvmap.MD_ScrOff[15:0] = cpu_data;
                $display("MVmapDesc MD_ScrOff = %x", {mvmap.MD_ScrOff[31:16], cpu_data});
            end
            24'h26: begin
                mvmap.MD_BCol[31:16] = cpu_data;
                $display("MVmapDesc MD_BCol = %x", {cpu_data, mvmap.MD_BCol[15:0]});
            end
            24'h28: begin
                mvmap.MD_BCol[15:0] = cpu_data;
                $display("MVmapDesc MD_BCol = %x", {mvmap.MD_BCol[31:16], cpu_data});
            end
            24'h2a: begin
                mvmap.MD_Speed[31:16] = cpu_data;
                $display("MVmapDesc MD_Speed = %x", {cpu_data, mvmap.MD_Speed[15:0]});
            end
            24'h2c: begin
                mvmap.MD_Speed[15:0] = cpu_data;
                $display("MVmapDesc MD_Speed = %x", {mvmap.MD_Speed[31:16], cpu_data});
            end
            24'h2e: begin
                mvmap.MD_TimeCd[31:16] = cpu_data;
                $display("MVmapDesc MD_TimeCd = %x", {cpu_data, mvmap.MD_TimeCd[15:0]});
            end
            24'h30: begin
                mvmap.MD_TimeCd[15:0] = cpu_data;
                $display("MVmapDesc MD_TimeCd = %x", {mvmap.MD_TimeCd[31:16], cpu_data});
            end
            24'h32: begin
                mvmap.MD_TmpRef = cpu_data;
                $display("MVmapDesc MD_TmpRef = %x", cpu_data);
            end
            24'h34:
            if (uds) begin
                mvmap.MD_PicRt = cpu_data[15:8];
                $display("MVmapDesc MD_PicRt = %x", cpu_data[15:8]);
            end
            default: ;
        endcase
    end
end

always @(posedge clk30) begin
    // Print only when read by the application. Not the driver
    if (mvmapdesc != 0 && bus_ack && !write_strobe && !executing_dvc_rom_instructions && as && (lds || uds)) begin
        case (addr_byte - mvmapdesc)
            24'h00:  $display("MVmapDesc Read MD_Id = %x", data_in);
            24'h02:  $display("MVmapDesc Read MD_Type = %x", data_in);
            24'h04:  $display("MVmapDesc Read MD_Stream = %x", data_in);
            24'h06:  $display("MVmapDesc Read MD_StLoop[31:16] = %x", data_in);
            24'h08:  $display("MVmapDesc Read MD_StLoop[15:0] = %x", data_in);
            24'h0a:  $display("MVmapDesc Read MD_EnLoop[31:16] = %x", data_in);
            24'h0c:  $display("MVmapDesc Read MD_EnLoop[15:0] = %x", data_in);
            24'h0e:  $display("MVmapDesc Read MD_LpCnt = %x", data_in);
            24'h10:  $display("MVmapDesc Read MD_LCntr = %x", data_in);
            24'h12:  $display("MVmapDesc Read MD_ImgSz[31:16] = %x", data_in);
            24'h14:  $display("MVmapDesc Read MD_ImgSz[15:0] = %x", data_in);
            24'h16:  $display("MVmapDesc Read MD_DecWin[31:16] = %x", data_in);
            24'h18:  $display("MVmapDesc Read MD_DecWin[15:0] = %x", data_in);
            24'h1a:  $display("MVmapDesc Read MD_DecOff[31:16] = %x", data_in);
            24'h1c:  $display("MVmapDesc Read MD_DecOff[15:0] = %x", data_in);
            24'h1e:  $display("MVmapDesc Read MD_ScrOrg[31:16] = %x", data_in);
            24'h20:  $display("MVmapDesc Read MD_ScrOrg[15:0] = %x", data_in);
            24'h22:  $display("MVmapDesc Read MD_ScrOff[31:16] = %x", data_in);
            24'h24:  $display("MVmapDesc Read MD_ScrOff[15:0] = %x", data_in);
            24'h26:  $display("MVmapDesc Read MD_BCol[31:16] = %x", data_in);
            24'h28:  $display("MVmapDesc Read MD_BCol[15:0] = %x", data_in);
            24'h2a:  $display("MVmapDesc Read MD_Speed[31:16] = %x", data_in);
            24'h2c:  $display("MVmapDesc Read MD_Speed[15:0] = %x", data_in);
            24'h2e:  $display("MVmapDesc Read MD_TimeCd[31:16] = %x", data_in);
            24'h30:  $display("MVmapDesc Read MD_TimeCd[15:0] = %x", data_in);
            24'h32:  $display("MVmapDesc Read MD_TmpRef = %x", data_in);
            24'h34:  $display("MVmapDesc Read MD_PicRt = %x", data_in);
            default: ;
        endcase
    end
end

// Tool to observe variables in madriv module
struct {
    bit [31:0] dma_addr;    // 0x122
    bit [15:0] irq_stat;    // 0x120
    bit [15:0] irq_enable;  // 0x150
} madriv = '{default: 0};
bit [23:0] madriv_static  /*verilator public_flat_rw*/ = 0;

always @(posedge clk30) begin
    if (madriv_static != 0 && bus_ack && write_strobe && as && (lds || uds)) begin
        if (addr_byte == madriv_static + 24'h122) begin
            madriv.dma_addr[31:16] = cpu_data;
            $display("FMA dma_addr = %x", {cpu_data, madriv.dma_addr[15:0]});
        end

        if (addr_byte == madriv_static + 24'h124) begin
            madriv.dma_addr[15:0] = cpu_data;
            $display("FMA dma_addr = %x", {madriv.dma_addr[31:16], cpu_data});
        end

        if (addr_byte == madriv_static + 24'h0150) begin
            madriv.irq_stat = cpu_data;
            $display("FMA irq_stat = %x", cpu_data);
        end

        if (addr_byte == madriv_static + 24'h0120) begin
            madriv.irq_enable = cpu_data;
            $display("FMA irq_enable = %x", cpu_data);
        end
    end
end

// Tool to observe variables in fdrvs1 module
struct {
    bit [7:0] V_StepDone; // 0x17a char*
    bit [7:0] V_BufStat;  // 0x17b char*
    bit [7:0] V_UpdFlag;  // 0x12e char*
    bit [15:0] V_Stat;    // 0x134
    bit [15:0] V_VCMD;    // 0x16c
    bit [15:0] V_Scroll;  // 0x16a
    bit [15:0] V_DTSVal;  // 0x1c0
    bit [31:0] V_SCR;     // 0xca
    bit [15:0] V_Status;  // 0x136
    bit [15:0] V_SigStat; // 0x13c
    bit [15:0] V_AsyStat; // 0x16e
    bit [31:0] V_Window;  // 0xe6
    bit [31:0] V_DecOff;  // 0xea
    bit [31:0] V_ScrOrg;  // 0xee
    bit [31:0] V_ScrOff;  // 0xf2
    bit [31:0] V_NISFnd;  // 0x170
    bit [7:0]  V_PicRt; // 0x0x17f char*
    bit [31:0] V_PWI; // 0x180
    bit [15:0] V_PRPA; //0x194
    bit [31:0] V_Speed; // 0x100
    bit [15:0] V_PlayType; // 0x9a
    bit [7:0] V_Sync;  // 0xc9 char*
    bit [7:0] V_SyncDone;  // 0x12c char*
    bit [15:0] V_LCntr;  // 0xac
    bit [7:0] V_Frozen;  // 0xde char*
    bit [31:0] V_PausedSCR; // 0x144
    bit [31:0] V_ChipSpd; // 0x196 long*
} fdrvs1 = '{default: 0};
bit [23:0] fdrvs1_static  /*verilator public_flat_rw*/ = 0;
always @(posedge clk30) begin

    if (fdrvs1_static != 0 && bus_ack && write_strobe && as && (lds || uds)) begin

        if (addr_byte == fdrvs1_static + 24'h0136) begin
            fdrvs1.V_Status = cpu_data;
            $display("FMV V_Status = %d dez", cpu_data);
        end
        if (addr_byte == fdrvs1_static + 24'h013c) begin
            fdrvs1.V_SigStat = cpu_data;
            $display("FMV V_SigStat = %d dez", cpu_data);
        end
        if (addr_byte == fdrvs1_static + 24'h016e) begin
            fdrvs1.V_AsyStat = cpu_data;
            $display("FMV V_AsyStat = %x hex %d dez", cpu_data, cpu_data);
        end
        if (addr_byte == fdrvs1_static + 24'h0134) begin
            fdrvs1.V_Stat = cpu_data;
            $display("FMV V_Stat = %d dez", cpu_data);
        end
        if (addr_byte == fdrvs1_static + 24'h0194) begin
            fdrvs1.V_PRPA = cpu_data;
            $display("FMV V_PRPA = %d dez", cpu_data);
        end
        if (addr_byte == fdrvs1_static + 24'h009a) begin
            fdrvs1.V_PlayType = cpu_data;
            $display("FMV V_PlayType = %d dez", cpu_data);
        end

        // I assume that fdrvs1_static is always aligned to words
        if (addr_byte == fdrvs1_static + 24'h017a && uds) begin  // Location is 0x17a -> high byte
            fdrvs1.V_StepDone = cpu_data[15:8];
            $display("FMV V_StepDone = %d dez", cpu_data[15:8]);
        end

        if (addr_byte == fdrvs1_static + 24'h017a && lds) begin  // Location is 0x17b -> low byte
            fdrvs1.V_BufStat = cpu_data[7:0];
            $display("FMV V_BufStat = %d dez", cpu_data[7:0]);
        end

        if (addr_byte == fdrvs1_static + 24'h012e && uds) begin  // Location is 0x12e -> high byte
            fdrvs1.V_UpdFlag = cpu_data[15:8];
            $display("FMV V_UpdFlag = %d dez", cpu_data[15:8]);
        end

        if (addr_byte == fdrvs1_static + 24'h017e && lds) begin  // Location is 0x17f -> low byte
            fdrvs1.V_PicRt = cpu_data[7:0];
            $display("FMV V_PicRt = %d dez", cpu_data[7:0]);
        end

        if (addr_byte == fdrvs1_static + 24'h00c8 && lds) begin  // Location is 0xc9 -> low byte
            fdrvs1.V_Sync = cpu_data[7:0];
            $display("FMV V_Sync = %d dez", cpu_data[7:0]);
        end

        if (addr_byte == fdrvs1_static + 24'h012c && uds) begin  // Location is 0x12c -> high byte
            fdrvs1.V_SyncDone = cpu_data[7:0];
            $display("FMV V_SyncDone = %d dez", cpu_data[7:0]);
        end

        if (addr_byte == fdrvs1_static + 24'h0de && uds) begin  // Location is 0xde -> high byte
            fdrvs1.V_Frozen = cpu_data[7:0];
            $display("FMV V_Frozen = %d dez", cpu_data[7:0]);
        end

        if (addr_byte == fdrvs1_static + 24'h00ac) begin
            fdrvs1.V_LCntr = cpu_data;
            $display("FMV V_LCntr = %x", cpu_data);
        end

        if (addr_byte == fdrvs1_static + 24'h016a) begin
            fdrvs1.V_Scroll = cpu_data;
            $display("FMV V_Scroll = %x", cpu_data);
        end

        if (addr_byte == fdrvs1_static + 24'h016c) begin
            fdrvs1.V_VCMD = cpu_data;
            $display("FMV V_VCMD = %x", cpu_data);
        end

        if (addr_byte == fdrvs1_static + 24'h01c0) begin
            fdrvs1.V_DTSVal = cpu_data;
            $display("FMV V_DTSVal = %x", cpu_data);
        end

        if (addr_byte == fdrvs1_static + 24'h0ca) begin
            fdrvs1.V_SCR[31:16] = cpu_data;
            $display("FMV V_SCR = %x", {cpu_data, fdrvs1.V_SCR[15:0]});
        end

        if (addr_byte == fdrvs1_static + 24'h0cc) begin
            fdrvs1.V_SCR[15:0] = cpu_data;
            $display("FMV V_SCR = %x", {fdrvs1.V_SCR[31:16], cpu_data});
        end

        if (addr_byte == fdrvs1_static + 24'h0e6) begin
            fdrvs1.V_Window[31:16] = cpu_data;
            $display("FMV V_Window = %x", {cpu_data, fdrvs1.V_Window[15:0]});
        end

        if (addr_byte == fdrvs1_static + 24'h0e8) begin
            fdrvs1.V_Window[15:0] = cpu_data;
            $display("FMV V_Window = %x", {fdrvs1.V_Window[31:16], cpu_data});
        end

        if (addr_byte == fdrvs1_static + 24'h0ea) begin
            fdrvs1.V_DecOff[31:16] = cpu_data;
            $display("FMV V_DecOff = %x", {cpu_data, fdrvs1.V_DecOff[15:0]});
        end

        if (addr_byte == fdrvs1_static + 24'h0ec) begin
            fdrvs1.V_DecOff[15:0] = cpu_data;
            $display("FMV V_DecOff = %x", {fdrvs1.V_DecOff[31:16], cpu_data});
        end

        if (addr_byte == fdrvs1_static + 24'h0ee) begin
            fdrvs1.V_ScrOrg[31:16] = cpu_data;
            $display("FMV V_ScrOrg = %x", {cpu_data, fdrvs1.V_ScrOrg[15:0]});
        end

        if (addr_byte == fdrvs1_static + 24'h0f0) begin
            fdrvs1.V_ScrOrg[15:0] = cpu_data;
            $display("FMV V_ScrOrg = %x", {fdrvs1.V_ScrOrg[31:16], cpu_data});
        end

        if (addr_byte == fdrvs1_static + 24'h0f2) begin
            fdrvs1.V_ScrOff[31:16] = cpu_data;
            $display("FMV V_ScrOff = %x", {cpu_data, fdrvs1.V_ScrOff[15:0]});
        end

        if (addr_byte == fdrvs1_static + 24'h0f4) begin
            fdrvs1.V_ScrOff[15:0] = cpu_data;
            $display("FMV V_ScrOff = %x", {fdrvs1.V_ScrOff[31:16], cpu_data});
        end

        if (addr_byte == fdrvs1_static + 24'h170) begin
            fdrvs1.V_NISFnd[31:16] = cpu_data;
            $display("FMV V_NISFnd = %x", {cpu_data, fdrvs1.V_NISFnd[15:0]});
        end

        if (addr_byte == fdrvs1_static + 24'h172) begin
            fdrvs1.V_NISFnd[15:0] = cpu_data;
            $display("FMV V_NISFnd = %x", {fdrvs1.V_NISFnd[31:16], cpu_data});
        end

        if (addr_byte == fdrvs1_static + 24'h180) begin
            fdrvs1.V_PWI[31:16] = cpu_data;
            $display("FMV V_PWI = %x", {cpu_data, fdrvs1.V_PWI[15:0]});
        end

        if (addr_byte == fdrvs1_static + 24'h182) begin
            fdrvs1.V_PWI[15:0] = cpu_data;
            $display("FMV V_PWI = %x", {fdrvs1.V_PWI[31:16], cpu_data});
        end

        if (addr_byte == fdrvs1_static + 24'h100) begin
            fdrvs1.V_Speed[31:16] = cpu_data;
            $display("FMV V_Speed = %x", {cpu_data, fdrvs1.V_Speed[15:0]});
        end

        if (addr_byte == fdrvs1_static + 24'h102) begin
            fdrvs1.V_Speed[15:0] = cpu_data;
            $display("FMV V_Speed = %x", {fdrvs1.V_Speed[31:16], cpu_data});
        end

        if (addr_byte == fdrvs1_static + 24'h144) begin
            fdrvs1.V_PausedSCR[31:16] = cpu_data;
            $display("FMV V_PausedSCR = %x", {cpu_data, fdrvs1.V_PausedSCR[15:0]});
        end

        if (addr_byte == fdrvs1_static + 24'h146) begin
            fdrvs1.V_PausedSCR[15:0] = cpu_data;
            $display("FMV V_PausedSCR = %x", {fdrvs1.V_PausedSCR[31:16], cpu_data});
        end

        if (addr_byte == fdrvs1_static + 24'h196) begin
            fdrvs1.V_ChipSpd[31:16] = cpu_data;
            $display("FMV V_ChipSpd = %x", {cpu_data, fdrvs1.V_ChipSpd[15:0]});
        end

        if (addr_byte == fdrvs1_static + 24'h198) begin
            fdrvs1.V_ChipSpd[15:0] = cpu_data;
            $display("FMV V_ChipSpd = %x", {fdrvs1.V_ChipSpd[31:16], cpu_data});
        end
    end
end
