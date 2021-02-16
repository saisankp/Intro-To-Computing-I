;
; CS1022 Introduction to Computing II 2018/2019
; Lab 3 - Floating-Point
;

	AREA	RESET, CODE, READONLY
	ENTRY

;
; Test Data
;
FP_A	EQU	0x41C40000
FP_B	EQU	0x41960000


	; initialize system stack pointer (SP)
	LDR	SP, =0x40010000;
	
	; Test all subroutines:
	
	;Part 1 
	LDR	R0, =FP_A ; set RO as the ieee 754 float (for the parameters to the subroutine)
	BL	fpfrac    ; Branch and Link to subroutine (part 1)
	MOV	R2, R0    ; Move R0 (returned value) into R2 temporarily.
			
	;Part 2 
	LDR	R0, =FP_B ; Set R0 as the ieee 754 float (for the parameters to the subroutine)
	BL	fpexp     ; Branch and Link to subroutine (part 2)
	MOV	R3, R0    ; Move R0 (returned value) into R3 temporarily
		
	;Part 3
	MOV	R0, R2    ;  Move fraction (signed 2's complement word) from part 1 into R0 (for the parameters to the subroutine)
	MOV	R1, R3    ;  Move  exponent (signed 2's complement word) from part 2 into R1 (for the parameters to the subroutine)
	BL	fpencode  ;  Branch and Link to the subroutine (part 3)
	
stop	B	stop


;
; fpfrac 
; decodes an IEEE 754 floating point value to the signed (2's complement)
; fraction
; parameters:
;	r0 - ieee 754 float
; return:
;	r0 - fraction (signed 2's complement word)
;
fpfrac

	PUSH	{R1}
	LDR	R1, =0x007FFFFF		;create a mask and store in R1.
	AND	R0, R0, R1		; AND the mask and the ieee 754 float.
	CMP	R4, #1			; Use counter to compare
	BNE	endfrac
	LDR	R11, = 0xFFFFFFFF	; create another mask	
	EOR	R0, R0, R11		; Use EOR with the mask and R0.
	ADD	R0, #1			; Increment R0 by 1.
endfrac
	POP	{R1}
	BX	LR
	
;
; fpexp 
; decodes an IEEE 754 floating point value to the signed (2's complement)
; exponent
; parameters:
;	r0 - ieee 754 float
; return:
;	r0 - exponent (signed 2's complement word)
;
fpexp

	
	LSL	R0, #1		; shift left to one bit to clear the signed bit
	LSR	R0, #24 	; shift right to clear the fraction bit and to find the exponent
	SUB	R0, R0, #127    ; subtract the bias (127) to decode the exponent to it's 2's complement value.
	BX	LR

; 
; fpencode (4)
; encodes an IEEE 754 value using a specified fraction and exponent 
; parameters: 
; r0 - fraction (signed 2's complement word)
; r1 - exponent (signed 2's complement word)
; 
; result :
; r0 - IEEE 754 float
;
fpencode 

	PUSH	{R2, lr}	;
	ADD	R2, R2, #127	; add 127 which is the bias for iee 754
	ROR	R2, #9		; convert the exponent to it's IEEE 754 value
	ORR	R0, R0, R2	; set the exponent bits in R0
	POP	{R2, pc}	;
	
	


	END















