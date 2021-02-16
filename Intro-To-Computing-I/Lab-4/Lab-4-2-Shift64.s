;
; CSU11021 Introduction to Computing I 2019/2020
; 64-bit Shift
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R1, =0xD9448A9B		; most significaint 32 bits (63 ... 32)
	LDR	R0, =0xB7AA9D3B		; least significant 32 bits (31 ... 0)
	LDR	R2, =-2			; shift count

	CMP	R2, #0
	BEQ 	QUIT
	
	CMP 	R2, #0
	BGT 	shiftRight	
	MVN	R2, R2			; Bitwise manipulation NOT
	ADD	R2, R2, #1		; Invert the bits and ADD 1 to change it to positive.
	
while	
	CMP	R2, #0
	BEQ	QUIT
	MOVS	R0, R0, LSL #1		; Shift R0 LEFT
	BCC	here			; If there is a carry, continue.
	MOVS 	R1, R1, LSL #1 		; Shift R1 LEFT
	ADD	R1, R1, #1
	B	after
here					; If there no carry, Shift Left again
	MOVS	R1, R1, LSL #1
after
	SUB	R2, R2, #1		; Subtract 1 from our counter
	B	while
	
	
	
shiftRight
WHILE
	
	CMP	R2, #0
	BEQ	QUIT
	MOVS	R1, R1, LSR #1 		; Shift R1 RIGHT
	BCC	here1			; If there is a carry, continue.
	MOVS 	R0, R0, LSR #1		; Shift R0 RIGHT
	ADD	R0, R0, #0x80000000	; You need to add a 1 to the LHS of R0 if theres a carry from R1. 0x80000000 is 10000000 in binary.
	B	after2
here1	
	MOVS	R0, R0, LSR #1		; If there no carry, Shift Right again
after2
	SUB	R2, R2, #1		; Subtract 1 from our counter
	
	B	WHILE
	
QUIT

STOP	B	STOP

	END
