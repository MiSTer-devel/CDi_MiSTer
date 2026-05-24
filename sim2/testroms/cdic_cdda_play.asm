	section .text

    org $400000

vector:
	dc.l $1234
	dc.l main

main:
	move.l #cdicirq,$200
	move #$2000,SR

	move.w #$2480,$303FFC ; IRQ vector

	move.w #$0024,$303C00 ; Command Register = Reset Mode 2
	move.w #$8000,$303FFE ; Data buffer

	move.w #$2480,$303FFC ; Interrupt Vector
	move.w #$0028,$303C00 ; Play CDDA
	;move.w #$0027,$303C00 ; Fetch TOC

	; Timer Register 
	; move.l #$15220000,$303C02 Apprentice - Title Screen
	; move.l #$19468000,$303C02 Apprentice - Level 1
	move.l #$00030200,$303C02 Karaoke CD

	move.w #$C000,$303FFE ; Start the Read by setting bit 15 of the data buffer

	jsr waitforirq

	move.w #$0800,$303FFA ; Start playback

	jsr waitforirq
	jsr waitforirq
	jsr waitforirq
	jsr waitforirq

	;move.w #$0000,$303FFE ; Deactivate cd reading

endless:
	bra endless

wait:
	add.l #-1,d0
	bne wait
	rts

waitforirq:
	move #0,d0
waitforirqloop:
	tst d0
	beq waitforirqloop
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
	; Subcode Q
	move.w $301324,d0
	move.w $301326,d0
	move.w $301328,d0
	move.w $30132a,d0
	move.w $30132c,d0
	move.w $30132e,d0

	move.w $301330,d0
	move.w $301332,d0
	move.w $301334,d0
	move.w $301336,d0
	move.w $301338,d0
	move.w $30133a,d0

	;Subcode RW Start
	move.w $300a00,d0
	move.w $300a02,d0
	move.w $300a04,d0
	move.w $300a06,d0
	move.w $300a08,d0
	move.w $300a0a,d0
	move.w $300a0c,d0
	move.w $300a0e,d0
	; and end
	move.w $300ab0,d0
	move.w $300ab2,d0
	move.w $300ab4,d0
	move.w $300ab6,d0
	move.w $300ab8,d0
	move.w $300aba,d0
	move.w $300abc,d0
	move.w $300abe,d0

	bra read_data
lower_buf:
	; Subcode Q
	move.w $300924,d0
	move.w $300926,d0
	move.w $300928,d0
	move.w $30092a,d0
	move.w $30092c,d0
	move.w $30092e,d0
	
	move.w $300930,d0
	move.w $300932,d0
	move.w $300934,d0
	move.w $300936,d0
	move.w $300938,d0
	move.w $30093a,d0

	;Subcode RW Start
	move.w $300000,d0
	move.w $300002,d0
	move.w $300004,d0
	move.w $300006,d0
	move.w $300008,d0
	move.w $30000a,d0
	move.w $30000c,d0
	move.w $30000e,d0
	; and end
	move.w $3000b0,d0
	move.w $3000b2,d0
	move.w $3000b4,d0
	move.w $3000b6,d0
	move.w $3000b8,d0
	move.w $3000ba,d0
	move.w $3000bc,d0
	move.w $3000be,d0

read_data:

	; Highest bit is set
	move #1,d0
	rte
noint:
	move #0,d0
	rte
