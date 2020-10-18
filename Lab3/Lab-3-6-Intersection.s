;
; CSU11021 Introduction to Computing I 2019/2020
; Intersection
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R0, =0x40000000	; address of sizeC
	LDR	R1, =0x40000004	; address of elemsC
	
	LDR	R6, =sizeA	; address of sizeA
	LDR	R2, [R6]	; load sizeA
	LDR	R3, =elemsA	; address of elemsA
	
	LDR	R6, =sizeB	; address of sizeB
	LDR	R4, [R6]	; load sizeB
	
	LDR	R7, =0		; firstCounter = 0
	LDR 	R9, =0		; sizeC = 0
	
	
while				
	CMP	R7, R2 		; While (firstCounter < sizeA)
	BHS	endwh
	LDR	R10, [R3] 	; Load element A
	LDR	R5, =elemsB	; address of elemsB
	LDR	R8, =0		; counter2 = 0;
WHILE	
	CMP	R8, R4 		; While (secondCounter < sizeB)
	BHS	ENDWH		; load element B
	LDR	R11, [R5]
	
	CMP	R11, R10	; if(elementB == elementA)
	BNE	els
	CMP	R9, #0		; if (sizeC == 0)
	BEQ	store 		; store elementB in C
	LDR	R12, =0		; thirdCounter == 0
	LDR	R10, =0x40000004 ; load.firstIndexOf(C)
	
wh
	CMP	R12, R9 	; While (thirdCounter <= sizeC)
	BHS	store		
	LDR	R6, [R10]	; nextElemC
	ADD	R10, R10, #4    ; load.nextIndexOf(C)
	ADD	R12, R12, #1    ; thirdCounter++
	CMP	R11, R6		; If (elemB == elemC)
	BEQ	ENDWH
	B	wh

store 	
	ADD	R9, R9, #1 	; sizeC++
	STR	R11, [R1]	; store elementB in address(C)
	ADD	R1, R1, #4      ; load nextAddress(C)
	B	ENDWH
	
els 	
	ADD	R5, R5, #4      ; load.nextAddress(B)
	ADD	R8, R8, #1    	; secondCounter++
	B 	WHILE
ENDWH	
	ADD	R3, R3, #4      ; load.nexrAddress(A)
	ADD	R7, R7, #1      ; firstCounter++
	B 	while
endwh
	STR	R9, [R0]	; store sizeC at R0
	
	;
	; Your program to compute the interaction of A and B goes here
	;
	; Store the size of the intersection in memory at the address in R0
	;
	; Store the elements in the intersection in memory beginning at the
	;   address in R1
	;

STOP	B	STOP

sizeA	DCD	6
elemsA	DCD	0, 14, 14, 2, 7, 7

sizeB	DCD	9
elemsB	DCD	20, 11, 14, 5, 7, 2, 9, 12, 17

	END
