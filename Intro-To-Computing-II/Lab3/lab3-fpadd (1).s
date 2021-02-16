;
; CS1022 Introduction to Computing II 2018/2019
; Lab 3 - Floating-Point
;

	AREA	RESET, CODE, READONLY
	ENTRY


; Test Data
FP_A	EQU	0x41C40000
FP_B	EQU	0x41960000


	; initialize system stack pointer (SP)
	LDR		SP, =0x40010000
	; test your subroutines here
	LDR		R1, =FP_A	
	LDR		R2, =FP_B
	
	; To add both floating point numbers, first let's find 
	; 1. the exponents of both.
	; 2. the signs(positive (0) or negative (1)) of both.
	; 3. the fraction of both.
	
	
	;step 1: find exponent of float a 	
	MOV		R0, R1	; Pass in FP_A into fpexp subroutine.
	BL		fpexp	
	MOV		R3, R0	; *R3 = exponent from float a*
	
	
	;step 2: find exponent of float b
	
	MOV		R0, R2	; Pass in FP_B into fpexp subroutine.
	BL		fpexp
	MOV		R4, R0	; *R4 = exponent from float b*
	
	
	;step 3: find sign of float b 
	
	MOV		R10, R2	; R10 = float b 
	LSR		R10, #31	; Shift left by 31 bits to access the 'sign' bit to compare with.
	CMP		R10, #0	; if (MSB == 0) {
	BNE		negative
	MOV		R5, #0	; *R5(sign for float b) = 0;* (i.e positive)
	B		completed ; }
negative			;  else {
	MOV		R5, #1	; *R5(sign for float b ) = 1;* (i.e negative)
completed			;  }
	
	
	;step 4: find sign of float a
	
	MOV		R10, R1 	; R10 = float a;
	LSR		R10, #31	; Shift left by 31 bits to access the 'sign' bit to compare with.
	CMP		R10, #0  ; if (MSB == 0) {
	BNE		negativealso
	MOV		R6, #0	; *R6(sign for float a ) = 0;* (i.e positive)
	B		completedalso ; }
negativealso		;	else {
	MOV		R6, #1	;	*R6(sign for float a) = 1;* (i.e negative)
completedalso		; }
	
	
	;step 5: find fraction from float a  
	
	MOV		R10, R6	; Move sign of float a into R10 for the subroutine
	MOV		R0, R1	; R0(ieee 754 float) = float a 
	BL		fpfrac
	MOV		R7, R0 	; R7 = fraction from float a 
	
	
	;step 6: find fraction from float b 
	MOV		R10, R5	; Move sign of float b into R10 for the subroutine
	MOV		R0, R2	; R0(ieee 754 float) = float b
	BL		fpfrac
	MOV		R8, R0	; R8 = fraction from float b 
	
	;After all these operations, we end up with :
	;R3 - exponent of float a 
	;R4 - exponent of float b  
	;R5 - sign of float b
	;R6 - sign of float a
	;R7 - fraction of float a 
	;R8 - fraction of float b 
	
	
	;step 7: finally, call the subroutine floatadd to add these two ieee 754 floating point values.	
	BL 		floatadd
	
stop	B	stop



; fpfrac
; decodes an IEEE 754 floating point value to the signed (2's complement)
; fraction
; parameters:
;	r0 - ieee 754 float
; return:
;	r0 - fraction (signed 2's complement word)
;
fpfrac
	PUSH	{R4}
	LDR		R4, =0x007FFFFF		; create a mask and store in R1.
	AND		R0, R0, R4		; AND the mask and the ieee 754 float.
	CMP		R10, #1			; Use counter to compare
	BNE		endfrac
	LDR		R4, = 0xFFFFFFFF	; create another mask	
	EOR		R0, R0, R11		; Use EOR with the mask and R0.
	ADD		R0, #1			; Increment R0 by 1.
endfrac
	POP		{R4}
	BX		LR
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

	LSL		R0, #1		; shift left to one bit to clear the signed bit
	LSR		R0, #24 	; shift right to clear the fraction bit and to find the exponent
	SUB		R0, R0, #127    ; subtract the bias (127) to decode the exponent to it's 2's complement value.
	BX		LR


;
; fpencode
; encodes an IEEE 754 value using a specified fraction and exponent
; parameters:
;	r0 - fraction (signed 2's complement word)
;	r3 - exponentA (signed 2's complement word) (same as exponentB)
; result:
;	r0 - ieee 754 float
;
fpencode

	PUSH	{R3, lr}	
	ADD		R3, R3, #127	; add 127 which is the bias for iee 754
	ROR		R3, #9			; convert the exponent to it's IEEE 754 value
	ORR		R0, R0, R3		; set the exponent bits in R0
	POP		{R3, pc}		


; floatadd
; this subroutine will add two IEEE 754 floating point values and return the answer.
; parameters :
; r3 - exponentA
; r4 - exponentB
; r7 - fractionA
; r8 - fractionB
; return:
; r0 - an iee 754 floating point number as an answer.

floatadd
	PUSH	{lr}
notEqualYet	
; Rule: for two floating point values to be added, the exponents need to be the same
; First let's make sure both exponents are the same
	SUB		R0, R4, R3	; if( (exponentB - ExponentA) == 0 ) {
	CMP		R0, #0		; 		ExponentB = ExponentA;  (i.e. both are the same)
	BEQ		sameExponent;  }
	
	
; However, if they are not equal, then one exponent is bigger than the other. 
; So, we can figure out which is greater/smaller and adjust them appropriately..
	CMP	 	R4, R3	; if (ExponentB > ExponentA)
	BLS		smallExponent
	ADD		R4, R4, #1  ; ExponentB++;
	LSR		R7, #1; lsr one bit for fraction a.
	B		notEqualYet
	
smallExponent
	SUB		R4, R4, #1	; ExponentB--;
	LSR		R7, #1; lsr one bit for fraction a.
	B		notEqualYet

sameExponent	
	; with the same exponent now, so we can add the fractions normally
	ADD		R0, R8, R7	
	; Now, we can use our fraction summation and equal exponent and pass it into the encoding subroutine.
	BL		fpencode
	; Since the R0 contains the iee 754 floating point result, it is returned.
	POP		{pc}
	END
