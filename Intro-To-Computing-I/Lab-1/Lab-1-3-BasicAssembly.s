;
; CSU11021 Introduction to Computing I 2019/2020
; Basic ARM Assembly Language
;

	AREA	RESET, CODE, READONLY
	ENTRY
	
; Write your solution for all parts (i) to (iv) below.

; Tip: Right-click on any instruction and select 'Run to cursor' to
; "fast forward" the processor to that instruction.

; (i) 3x+y

	LDR	R1, =2	; x = 2
	LDR	R2, =3	; y = 3
	
	; your program goes here
 	MOV	R0, #3     ; R0 = 3
	MUL	R0, R1, R0 ; R0 = 3x
	ADD	R0, R0, R2 ; 3x+y

; (ii) 3x^2+5x

	LDR	R1, =2	; x = 2

	; your program goes here
	MOV	R3, #3
	MUL	R0, R1, R1 ; R0 = x^2
	MUL	R0, R3, R0 ; R0 = 3x^2
	MOV	R3, #5     ; R3 = 5
	MUL	R4, R3, R1 ; R4 = 5x
	ADD	R0, R0, R4 ; R0 = 3x^2 + 5x

; (iii) 2x^2+6xy+3y^2

	LDR	R1, =2	; x = 2
	LDR	R2, =3	; y = 3

	; your program goes here
	MOV	R3, #2     ; R3 = 2
	MUL	R0, R3, R1 ; R0 = 2x
	MUL	R0, R1, R0 ; R0 = 2x^2
	MOV	R4, #6     ; R4 = 6
	MUL 	R4, R1, R4 ; R4 = 6x
	MUL	R4, R2, R4 ; R4 = 6xy
	MOV	R5, #3     ; R5 = 3
	MUL	R5, R2, R5 ; R5 = 3y
	MUL	R5, R2, R5 ; R5 = 3y^2
	ADD	R0, R0, R4 ; R0 = 2x^2 + 6xy
	ADD	R0, R0, R5 ; R0 = 2x^2 + 6xy + 3y^2

; (iv) x^3-4x^2+3x+8

	LDR	R1, =2	; x = 2
	LDR	R2, =3	; y = 3

	; your program goes here
	MUL	R0, R1, R1 ; R0 = x^2
	MUL	R0, R1, R0 ; R0 = x^3
	MOV	R3, #4     ; R3 = 4
	MUL 	R3, R1, R3 ; R3 = 4x
	MUL	R3, R1, R3 ; R3 = 4x^2
	MOV	R4, #3     ; R4 = 3
	MUL	R4, R1, R4 ; 3x
	MOV	R5, #8     ; R5 = 8
	SUB	R6, R0, R3 ; x^3 - 4x^2
	ADD	R6, R6, R4 ; x^3 - 4x^2 + 3x
	ADD	R0, R6, R5 ; x^3 - 4x^2 + 3x + 8
	
STOP	B	STOP

	END
