;
; CS1022 Introduction to Computing II 2018/2019
; Lab 2 - Subarray
;

N	EQU	7
M	EQU	3		

	AREA	RESET, CODE, READONLY
	ENTRY

	;initialize system stack pointer (SP)
	LDR	SP, =0x40010000

	;
	; Write your program here to determine whether SMALL_A
	;   is a subarray of LARGE_A
	;
	; Store 1 in R0 if SMALL_A is a subarray and zero otherwise
	;
	LDR	R0, =LARGE_A
	LDR	R1, =SMALL_A
	LDR	R2, =N
	LDR	R3, =M
	BL	isSub

STOP	B	STOP

;chIfSub subroutine
	;Subroutine to check if SMALL_A is a subarray of LARGE_A
	;R0 = start address of large array
	;R1 = start address of small array
	;R2 = Number of elements in large array (i.e it's size)
	;R3 = Number of elements in small array  (i.e it's size)
	
isSub					; boolean isSub(LargeArray, SmallArray, int LrgSize, int SmlSize){
	SUB	R4, R2, R3		;	int jump = Bsize - Asize;
	MUL	R5, R2, R2		;	int noOfElemsLarge = N * N;
	MUL	R6, R3, R3		;	int noOfElemsSmall = M * M;
	LDR	R7, =0			; 
	PUSH	{lr}
					; 	
for					;	for(int i = 0; i < noOfElemsLarge; i++){
	CMP	R7, R5			;
	BHS	endfor			;
	MOV	R8, R7			; 		int temp_i = i;  stores the start address of the array in memory, and down in words (full descending)
	LDR	R9, =0			; 		int count = 0;
	LDR	R10, =0			;
	BL	isSub1			;		checkIfWillFit(index);
	PUSH	{R5}			;
for2					;
	CMP	R10, R6			;		for(int j = 0; j < noOfElemsSmall; j++){ ;check if they match 
	BHS	endfor2			;			
	LDR	R11, [R1, R10, LSL #2] 	;			int small = SMALL_A[j];
	LDR	R12, [R0, R8, LSL #2]	;			int large = LARGE_A[temp_i];
	ADD	R8, #1			;			temp_i++;
	CMP	R11, R12		;			if(small == large){
	BNE	endfor2			;				count++;
	ADD	R9, #1			;
	CMP	R9, R3			;				if(count == M)
	BNE     nextIF			;
	ADD	R8, R4			;					temp_i += jump;
	LDR	R9, =0			; If we reach the side of the small array, we need to jump a certain number of 
nextIF					; indexes in the big array
	SUB	R5, R6, #1
	CMP	R10, R5			;				if(j == noOfElemsSmall - 1)
	BNE	postInc			;					return true;
	LDR	R0, =1			;		        } ;, if we reach the index of the small array then it must be a subarray
	POP	{R5}			;
	B	true			;		}
postInc	
	ADD	R10, #1
	B	for2			;
endfor2					;
	POP	{R5}			;	}
	ADD	R7, #1			;
	B	for			;
endfor					;
	LDR	R0, =0			;	false is returned
true					; }
	
	POP 	{lr}
	BX	lr
	
	
	
isSub1					;	checkIfWillFit(index){ ; check for overlapping 
	PUSH 	{R4-R6, R8-R12, lr}	;
	LDR	R4, =1			;
FOR					;
	CMP	R4, R2			;	for(int i = 1; i <= 7; i++){
	BHI	ENDFOR			;	
	MUL	R5, R4, R2		;		int lastPossPosition = i*M - N;
	SUB	R5, R3			;
	ADD	R4, #1			;
	CMP	R7, R5			;		if(index == lastPossPosition){
	BNE	FOR			;			index += (M + 1);
	ADD	R7, R3			;			break;
	ADD	R7, #1			;		}
ENDFOR					;	}
	POP	{R4-R6, R8-R12, lr}	;
	BX	lr			;}
	

;
; test data
;
;

LARGE_A	DCD	 48, 37, 15, 44,  3, 17, 26
	DCD	  2,  9, 12, 18, 14, 33, 16
	DCD	 13, 20,  1, 22,  7, 48, 21
	DCD	 27, 19, 44, 49, 44, 18, 10
	DCD	 29, 17, 22,  4, 46, 43, 41
	DCD	 37, 35, 38, 34, 16, 25,  0
	DCD	 17,  0, 48, 15, 27, 35, 11

SMALL_A	DCD	 49, 44, 18
	DCD	  4, 46, 43
	DCD	 34, 16, 25

	END
