;
; CS1022 Introduction to Computing II 2018/2019
; Lab 2 - Matrix Multiplication
;

N	EQU	4		

	AREA	globals, DATA, READWRITE

; result array
ARR_R	SPACE	N*N*4		; N*N words (4 bytes each)


	AREA	RESET, CODE, READONLY
	ENTRY

	; initialize system stack pointer (SP)
	LDR	SP, =0x40010000

	;
	; write your matrix multiplication program here
	;
	; set registers to N the first addresses of the arrays
	LDR	R8, =N
	LDR	R1, =ARR_A
	LDR	R2, =ARR_B
	LDR	R3, =ARR_R

	LDR	R4, =0			; for ((/i) = 0; 
iLoop	CMP 	R4, R8			;	i < N; 
	BHS	eiLoop			;	i++) {
	LDR	R5, =0			;	for(j = 0; 
jLoop	CMP	R5, R8			;	j is less than N
	BHS	ejLoop			;	Increment J {
	LDR	R7, =0			;	r = 0;
	LDR	R6, =0			;	for (k = 0; 
kLoop	CMP	R6, R8			;	k is less than N //Loop for K
	BHS	ekLoop			;	k++) {
	MUL	R0, R4, R8		;	index = i*N;
	ADD	R0, R0, R6		;	index = k + index;
	LDR	R9, [R1, R0, LSL #2]	;	valueA = A[ARRAY_A + index*4];
	MUL	R0, R6, R8		;	index = k*N;
	ADD	R0, R0, R5		;	index += j;
	LDR	R10, [R2, R0, LSL #2]	;	valueB = B[ARRAY_B + index*4];
	MUL	R9, R10, R9		;	valueA *= valueB;
	ADD	R7, R7, R9		;	r = r + (A[i,k] * B[k,j]);
	ADD	R6, R6, #1		;	increment k
	B	kLoop
ekLoop	MUL	R0, R4, R8		;	index = i*N;
	ADD	R0, R0, R5		;	index += j;
	STR	R7, [R3, R0, LSL #2]	;	array R[i,j] = r;
	ADD	R5, R5, #1		;	increment j
	B	jLoop
ejLoop	ADD	R4, R4, #1		; } increment i
	B	iLoop
eiLoop



STOP	B	STOP


;
; test data
;

ARR_A	DCD	 1,  2,  3,  4
	DCD	 5,  6,  7,  8
	DCD	 9, 10, 11, 12
	DCD	13, 14, 15, 16

ARR_B	DCD	 1,  2,  3,  4
	DCD	 5,  6,  7,  8
	DCD	 9, 10, 11, 12
	DCD	13, 14, 15, 16

	END
