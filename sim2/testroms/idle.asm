	section .text

    org $400000

vector:
	dc.l $1234
	dc.l main

main:

endless:
	bra endless

illegal_instruction:
	bra illegal_instruction

zero_divide:
	bra zero_divide

bus_error:
	bra bus_error

address_error:
	bra address_error







