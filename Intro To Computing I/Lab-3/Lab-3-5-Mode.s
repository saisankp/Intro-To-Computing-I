;
; CSU11021 Introduction to Computing I 2019/2020
; Mode
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R4, =tstN	; load address of tstN
	LDR	R1, [R4]	; load value of tstN

	LDR	R2, =tstvals	; load address of numbers
	
	LDR 	R4, =0		; firstCounter = 0
	LDR	R7, =0		; occuranceOfMode = 0
	LDR	R0, =0		; mode = 0
	
WHILE				; While (counter > numberOfNumbers)
	CMP	R4, R1		
	BEQ	ENDWH	
	LDR	R6, [R2]	; potentialMode = getValue(address) of Potential Mode
	MOV	R10, R2		; R10 = address
	MOV	R9, R4		; secondCounter = firstCounter
	LDR	R5, =0		; potential Mode Occurances = 0
	
while				; While (secondCounter <= NumberOfNumbers), 
	ADD	R9, R9, #1	; secondCounter++
	ADD	R10, R10, #4    ; R10 = addressOfNextNumber
	LDR	R8, [R10]       ; currentNumber = contentOf (address)
	CMP	R9, R1		
	BHI	endwh
	CMP	R6, R8		; if (currentNumber == potentialMode)
	BNE	while
	ADD	R5, R5, #1	; potentialModeOccurances++
	B	while
endwh
	CMP	R7, R5		; if(modeOccurances < potentialModeOccurances)
	BHS	endiff		; mode = potentialMode
	MOV	R0, R6		
	MOV	R7, R5		; modeOccurances = potentialModeOccurances
endiff
	ADD	R4, R4, #1      ; firstCounter++
	ADD	R2, R2, #4	; load addressOfNextPotentialMode
	B 	WHILE
ENDWH

	
STOP	B	STOP

tstN	DCD	8			; N (number of numbers)
tstvals	DCD	7, 3, 7, 5, 3, 7, 1, 9 	; numbers

	END
