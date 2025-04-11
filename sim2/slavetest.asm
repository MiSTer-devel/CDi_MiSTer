	section .text

    org $400000

vector:
	dc.l $1234
    dc.l main

main:
	; Make a pause at the start to relax the UART on the linux side
	move #40000,d0
start_delay:
	add #-1,d0
	bne start_delay

	move.l #slaveirq,$68
	move.b #2,$80001001 ; LIR
	move #$2000,SR  


	move.b #$86,$310000
	move.b #$89,$310000
	move.b #$80,$310006
	move.b #$60,$310006
	move.b #$73,$310006
	move.b #$50,$310006
	move.b #$81,$310006
	move.b #$6f,$310006
	move.b #$7f,$310006
	move.b #$00,$310006
	move.b #$f2,$310004
	move.b #$09,$310002
	move.b #$21,$310002
	move.b #$40,$310002
	move.b #$24,$310002
	move.b #$0f,$310002
	move.b #$21,$310002
	move.b #$39,$310002
	move.b #$00,$310002

	;Request NTSC/PAL Status (0xf6)
	move.b #$f6,$310006

	move #4000,d0
	bsr wait

	move.b $310000,d0
	move.b $310000,d0
	move.b $310000,d0
	move.b $310002,d0
	move.b $310002,d0
	move.b $310002,d0
	move.b $310004,d0
	move.b $310004,d0
	move.b $310004,d0
	move.b $310004,d0

	;X-Bus Interrupt Enable (0xfa)
	move.b #$fa,$310006

	; Request Disc Status (0xb0)
	move.b #$b0,$310006
	move.b #$00,$310006
	move.b #$00,$310006
	move.b #$00,$310006

	move.b #$83,$310000
	move.b #$f8,$310006
	move.b #$fc,$310006

	move #4000,d0
	bsr wait

	;move #8000,d0
	;bsr wait

	move.b #$fc,$310006
	move.b #$fd,$310006
	; Request Pointer Type (0xf3)
	move.b #$f3,$310006

	move #4000,d0
	bsr wait

	move.b $310000,d0
	move.b $310000,d0
	move.b $310000,d0
	move.b $310002,d0
	move.b $310002,d0
	move.b $310002,d0
	move.b $310004,d0
	move.b $310004,d0
	move.b $310004,d0

	move.b #$f9,$310006
	move.b #$f8,$310006
	; Request Test Plug Status (0xf4)
	move.b #$f4,$310006

	move #4000,d0
	bsr wait

	move.b $310000,d0
	move.b $310000,d0
	move.b $310000,d0
	move.b $310002,d0
	move.b $310002,d0
	move.b $310002,d0
	move.b $310004,d0
	move.b $310004,d0
	move.b $310004,d0

	move.b #$f9,$310006
	move.b #$f8,$310006
	move.b #$8c,$310004

	; Activate Front LCD Buttons
	move.b #$8d,$310004

	; Request SLAVE Revision (0xf0)
	move.b #$f0,$310006

	move #4000,d0
	bsr wait

	move.b $310000,d0
	move.b $310000,d0
	move.b $310000,d0
	move.b $310002,d0
	move.b $310002,d0
	move.b $310002,d0
	move.b $310004,d0
	move.b $310004,d0
	move.b $310004,d0


	; Activate Input Polling (0xf7)
	move.b #$f7,$310006


endless:
	bra endless

wait:
	add #-1,d0
	bne wait
	rts
	

slaveirq:
	move.b $310001,d0
	move.b $310001,d0
	move.b $310001,d0
	move.b $310001,d0
	move.b $310003,d0
	move.b $310003,d0
	move.b $310003,d0
	move.b $310003,d0
	move.b $310005,d0
	move.b $310005,d0
	move.b $310005,d0
	move.b $310005,d0
	move.b $310007,d0
	move.b $310007,d0
	move.b $310007,d0
	move.b $310007,d0
	rte
