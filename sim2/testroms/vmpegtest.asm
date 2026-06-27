	section .text

    org $400000

vector:
	dc.l $1234
	dc.l main

main:
	move.w #$0000,$303FFE ; Data buffer

	move.w #$0002,$E03000 ; FMA CMD - On
	move.w #$0000,$E03008 ; FMA Stream

	move.w #$2000,$E040C0 ; FMV SYSCMD - Decoder off
	nop
	move.w #$0100,$E040C0 ; FMV SYSCMD - Clear FIFO
	nop
	move.w #$1000,$E040C0 ; FMV SYSCMD - Decoder on

	move.w #$02D4,$E040DC ; FMV IVEC
	move.w #$F7CF,$E04060 ; FMV IER
	move.l #fmvirq,$168

	move.w #$807B,$E0300C ; FMA IVEC
	move.w #$013C,$E0301C ; FMA IER
	move.l #fmairq,$1EC

	move.w #$2480,$303FFC ; CDIC IVEC
	move.l #cdicirq,$200

	move #$2000,SR

	move.w #$0024,$303C00 ; Command Register = Reset Mode 2
	move.w #$8000,$303FFE ; Data buffer

	; #$01274700 Dragon's Lair Intro
	; #$00323400 FMVtest
	; #$00397400 7th Guest Philips Logo
	; #$55387000 7th Guest ?
	; #$01341100 Space Ace Intro
	; #$02140600 Space Ace Intro - Nearly the end (15 frames left)
	; #$00425900 2 Unlimited – Beyond Limits (Channel 0001)
	; #$42252600 Burger King - Multilanguage?
	; #$00152100 VideoCD Example (Channel ffff)
	; #$01164500 Coneheads (USA)
	; #$01414300 Coneheads (USA) Continue
	; #$00363000 Secret of Nimh (Redump VCD)
	; #$09235200 Les Guignols de l’info - "Böööh" (Stream 6)
	; #$00333500 Lost Eden - When entering gameplay (Stream 0)
	; #$05402000 Star Trek VI - Terre Inconnue (France) (Disc 1) - Good match for SEQHDR of High CPU Load scene
	; #$00437300 Addams Family (Disc 2)
	; #$01133900 Brain Dead 13 - Intro
	; #$12224800 AIMS - Frogs and How they Live (mute on MiSTer?)

	move.w #$002a,$303C00 ; Read Mode 2
	move.w #$0100,$303C06 ; File Register
	move.l #$ffffffff,$303C08 ; Channel Register
	move.w #$0000,$303C0C ; Audio Channel Register
	move.l #$12224800,$303C02 ; Timer Register
	move.w #$C000,$303FFE ; Start the Read by setting bit 15 of the data buffer

	move.l #0,$0E0407C ;FMV_DECOFF
	move.l #$01800118,$0E04078 ;FMV_DECWIN 384 x 280
	move.l #0,$0E04074 ;FMV_DECOFF
	move.w #$8,$0E040C2; Request Update

	; Usually one would use the DTS and SCR to start playback
	; But I feel lazy and use the number of pics instead
waitforpics:
	jsr WaitForSectorAndUse
	cmp.w #2,$00E040A4 ; Compare 5 against pictures in FIFO
	bmi waitforpics

	move.w #$0008,$E040C0 ; FMV SYSCMD - Play

	move.b #'B',$80002019

	move.w #$0008,$E040C0 ; FMV SYSCMD - Play
	move.w #$0420,$E040C2 ; FMV VIDCMD - Show on next frame


endless:
	jsr WaitForSectorAndUse
	bra endless


WaitForSectorAndUse:
	jsr waitforcdicirq

	; We need to check for the Mode 2 header now. It can be either MPEG Audio or MPEG Video
	; MPEG Video should have submode 0x62 (Real Time Sector, Form and Video)
	; followed by a coding of 0x0f (for MPEG Video)
	; MPEG Audio should have 0x64 (Real Time Sector, Form and Video)
	; followed by a coding of 0x7f (for MPEG Audio)
	move.b 10(a0),d2
	cmp.b #$64,d2
	beq audio
	cmp.b #$62,d2
	beq video

	rts

audio:
	; DMA CDIC to Memory
	move.b d0,$80004000 ; reset status
	move.l #$3000,$8000400c ; Memory Address Counter
	move.w #$480,$8000400a  ; Size for MPEG Audio
	move.b #$92,$80004005 ; Dev. to Mem., 16 Bit Words, 
	move.b #$80,$80004007 ; start DMA
	move.w d1,$303FF8 ; DMA Control Register = Start Transmission at a00

	; DMA Memory to FMA
	move.b d0,$80004040 ; reset status
	move.l #$3000,$8000404c ; Memory Address Counter
	move.w #$480,$8000404a  ; Memory Transfer Counter
	move.b #$04,$80004046 ; SCR, MAC Count Up, DAC No Change (like the CDIC on CH1)
	move.b #$12,$80004045 ; Dev. to Mem., 16 Bit Words,
	move.b #$30,$80004044 ; ACK/RDY device (like the CDIC on CH1)
	move.b #$80,$80004047 ; start DMA

	move.w #$8002,$00E03000 ; Syscmd = Start DMA

	; Continue loop
	rts

video:
	; DMA CDIC to Memory
	move.b d0,$80004000 ; reset status
	move.l #$3000,$8000400c ; Memory Address Counter
	move.w #$48a,$8000400a  ; Size for MPEG Video
	move.b #$92,$80004005 ; Dev. to Mem., 16 Bit Words, 
	move.b #$80,$80004007 ; start DMA
	move.w d1,$303FF8 ; DMA Control Register = Start Transmission at a00

	; DMA Memory to FMV
	; The original driver uses 0x484 for memory transfer counter
	; since the first 6 words are transferred via CPU to XFER
	; We are doing the same
	move.w $3000,$0e040de
	move.w $3002,$0e040de
	move.w $3004,$0e040de
	move.w $3006,$0e040de
	move.w $3008,$0e040de
	move.w $300a,$0e040de

	move.b d0,$80004040 ; reset status
	move.l #$300c,$8000400c ; Memory Address Counter
	move.w #$484,$8000404a  ; Memory Transfer Counter
	move.b #$04,$80004046 ; SCR, MAC Count Up, DAC No Change (like the CDIC on CH1)
	move.b #$12,$80004045 ; Mem to Dev.., 16 Bit Words,
	move.b #$30,$80004044 ; ACK/RDY device (like the CDIC on CH1)
	move.b #$80,$80004047 ; start DMA

	move.w #$8000,$00E040C0 ; Syscmd = Start DMA

	rts


waitforcdicirq:
	move #0,d0
waitforcdicirqloop:
	cmp #0,d0
	beq waitforcdicirqloop
	move.b #'O',$80002019
	rts

cdicirq:
	move.b #'I',$80002019
	move.w $303FF4,d0 ; clear flags on ABUFD
	; ignore ABUF
	move.w $303FF6,d0 ; clear flags on XBUF

	btst.l #$f,d0
	beq noint

	move.w $303FFe,d0
	btst.l #$0,d0 ; check lowest bit of data buffer
	beq lower_buf
higher_buf:
	move.w #$8a0c,d1 ; DMA Control for 0x0A0C
	move.l #$300a00,a0 ; Buffer location in CDIC memory
	bra read_data
lower_buf:
	move.w #$800c,d1 ; DMA Control for 0x000C
	move.l #$300000,a0 ; Buffer location in CDIC memory
read_data:
	; Highest bit is set
	move #1,d0
	rte
noint:
	move #0,d0
	rte

fmvirq:
	move.b #'V',$80002019
	move $00E04062,d7
	rte

fmairq:
	move.b #'A',$80002019
	move $00E0301A,d7
	rte


