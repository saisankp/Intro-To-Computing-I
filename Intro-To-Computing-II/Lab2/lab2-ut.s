;
; CS1022 Introduction to Computing II 2018/2019
; Lab 2 - Upper Triangular
;

N	EQU	4		

	AREA	RESET, CODE, READONLY
	ENTRY

	; initialize system stack pointer (SP)
	LDR	SP, =0x40010000

	;
	; write your program here to determine whether ARR_A
	;   (below) is a matrix in Upper Triangular form.
	;
	; Store 1 in R0 if the matrix is in Upper Triangular form
	;   and zero otherwise.
	;
	LDR	R0, =1			; uprTri = TRUE;
	LDR	R1, =N
	LDR	R2, =ARR_AY

	LDR	R3, =1			; for(j = 1;
jLoop	CMP	R3, R1			;	j < N;
	BHS	ejLoop			;	j++) {
	LDR	R4, =0			;	for(i = 0;
iLoop	CMP	R4, R3			;	i < j;
	BHS	eiLoop			;	i++) {
	MUL	R6, R3, R1		;	index = j*N;
	ADD	R6, R6, R4		;	index = index+ i;
	LDR	R5, [R2, R6, LSL #2]	;	val = array[i,j];
	CMP	R5, #0			;	if(val != 0)
	BEQ	isUppTri			
	LDR	R0, =0			;	uprTri = FALSE;
	B	notUpTri		;
isUppTri					
	ADD	R4, R4, #1		;	increment i
	B	iLoop
eiLoop	ADD	R3, R3, #1		; increment j
	B	jLoop
ejLoop

notUpTri


STOP	B	STOP


;
; test data
;

ARR_AY	DCD	 1,  2,  3,  4
	DCD	 0,  6,  7,  8
	DCD	 0,  0, 11, 12
	DCD	 0,  0,  0, 16

	END
