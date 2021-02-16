;
; CS1022 Introduction to Computing II 2019/2020
; Lab 1B - Bubble Sort
;

N	EQU	10

	AREA	globals, DATA, READWRITE

; N word-size values

SORTED	SPACE	N*4		; N words (4 bytes each)


	AREA	RESET, CODE, READONLY
	ENTRY

	;
	; copy the test data into RAM
	;

	LDR	R4, =SORTED
	LDR	R5, =UNSORT
	LDR	R6, =0
whInit	CMP	R6, #N
	BHS	eWhInit
	LDR	R7, [R5, R6, LSL #2]
	STR	R7, [R4, R6, LSL #2]
	ADD	R6, R6, #1
	B	whInit
eWhInit

	LDR	R4, =SORTED
	LDR	R5, =UNSORT

	;
	; your sort program goes here
	;
	
do
	LDR		R1, = 0 ; false
	LDR		R2, = 1 ; true
for
	CMP		R2, #N 
	BHS		endfor
	SUB		R9,R2,#1  ;makes it true
	LDR		R3, [R4,R9,LSL #2] ;access the array
	LDR		R8, [R4,R2,LSL #2] ;access the array
	CMP		R3, R8 ;if (array (n-1) > array(n))
	BLS		endiff
	MOV		R10,R3 ;tmpswap = array[i-1]
	STR		R8, [R4, R9, LSL #2]  ;store back into memory
	STR		R3, [R4, R2, LSL #2]  ;store back into memory
	LDR		R1, =1 ; swapped = false;
endiff
	ADD		R2, R2, #1 ;move onto text value 
	B		for ; branch back to for
endfor
while
	CMP		R1, #1
	BEQ		do

stop	B stop

UNSORT	DCD	9,3,0,1,6,2,4,7,8,5

	END
