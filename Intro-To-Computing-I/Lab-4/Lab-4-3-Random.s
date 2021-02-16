;
; CSU11021 Introduction to Computing I 2019/2020
; Pseudo-random number generator
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R0, =0x40000000		; start address for pseudo-random sequence
	LDR	R1, =64			; number of pseudo-random values to generate

	LDR	R2, =1 			; seed srandx	(seed X)
	LDR	R3, =0x0019660D 	; SRAND K (seed K)
	LDR	R4, =0x3C6EF35F 	; SRAND B (seed B)
	
	LDR	R7, =0 			; counter for while loop
	LDR	R9, =64 		; ending count
	
	
while
	LDRB	R8, [R0] 		; Store address in memory of R0 into R8
	CMP	R7, R9
	BGT	endwhile
					; Linear feedback shifter register
	MUL	R2, R3, R2 		; Random arithmetic to get a random number
	ADD	R2, R2, R4 		; Random arithmetic to get a random number
	
	MOV	R2, R2, ROR #1 		; Rotate Right 
	
	MOV	R8, R2			; Move random number into R8
	STRB	R8, [R0] 		; Store address of R0 back into memory
	ADD	R0, R0, #1 		; increment address for next random number
	ADD	R7, R7, #1 		; increment counter
	B while
endwhile

STOP	B	STOP

	END
