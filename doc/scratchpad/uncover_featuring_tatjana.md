# Uncover featuring Tatjana

Graphical problems with the photos. Those are MPEG decoded.
How are these even displayed?

Recorded on cdiemu, which also is not capable of correctly emulating this title. The graphics are broken

This is the last MV_Play

    @00DECBF0(cdi_appl) TRAP[25572] #0 I$SetStt <= d0.w=9 d1.w=MV_Window d2.w=1 d3.l=0 d4.l=$2100178 d5.b=0
    @00DECBF4(cdi_appl) TRAP[25572] #0 I$SetStt => 
    @00DECB62(cdi_appl) TRAP[25573] #0 I$SetStt <= d0.w=9 d1.w=MV_Trigger d3.w=$1BF3 <MV nis buf eos eoi cnp lpd pic der>
    @00DECB66(cdi_appl) TRAP[25573] #0 I$SetStt => 
    @00DEC96E(cdi_appl) TRAP[25574] #0 I$SetStt <= d0.w=9 d1.w=MV_Play d2.w=1 d3.l=0 d4.l=0 d5.l=$7FFFFFFF d6.w=8 d7.l=0 a1=$6781C (a4)=MV_STAT{ ASY_Stat=0 ASY_Sig=$1C00 }
    @00E4D8B2(MoviMan) TRAP[25575] #0 F$FindPD <= a0=$DFF360 d0.w=8
    @00E4D8B6(MoviMan) TRAP[25575] #0 F$FindPD => a1=$DFAE80
    @00E4F840(madriv) WR.W 00D03698 <= 0000 [S] MA_STAT{ ASY_Stat=0 }
    @00E4F846(madriv) WR.W 00D03698 <= 0000 [S] MA_STAT{ ASY_Stat=0 }
    @00DEC972(cdi_appl) TRAP[25574] #0 I$SetStt => 
    @00DEC85A(cdi_appl) TRAP[25576] #0 I$SetStt <= d0.w=9 d1.w=MV_Next d2.b=0 d3.l=0 a1=0

d4 is 0. So, this is from CD.
d5 is the speed value. 0x7FFFFFFF means "Single step mode" according to 8.2.3.3.2 from the green book.

I think I've never tested this actually. In the future SS_play is performed

    @00DF1340(cdi_appl) TRAP[25581] #0 I$SetStt <= d0.w=$B d1.w=SS_Play (a0)=PCB{ PCB_Stat=0 PCB_Sig=$116 PCB_Rec=$7FFFFFF PCB_Chan=$FFFFFFFF PCB_AChan=0 PCB_Video=$D011DA PCB_Audio=$D0125A PCB_Data=$D0129A }

