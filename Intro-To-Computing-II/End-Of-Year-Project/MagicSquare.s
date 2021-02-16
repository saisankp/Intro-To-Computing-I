;
; CS1022 Introduction to Computing II 2018/2019
; Magic Square
;

	AREA	RESET, CODE, READONLY
	ENTRY

	; Initialize the system stack pointer (SP)
	LDR	SP, =0x40010000
	
	; Note: Do each of these tests independently, not all at the same go.
	; TEST USING ARRAY 1  (Predicted Result: R0 will be 1, since it's a VALID magic square)
	; Prepare registers for subroutine isMagic. 
	LDR	R0, =arr1
	LDR	R4, =size1
	LDR	R1, [R4]
	; Call the isMagic() Subroutine.
	BL	isMagic	

	; TEST USING ARRAY 2  (Predicted Result: R0 will be 0, since it's NOT A VALID magic square)
	; Prepare registers for subroutine isMagic. 
	LDR	R0, =arr2
	LDR	R4, =size2
	LDR	R1, [R4]
	; Call the isMagic() Subroutine.
	BL	isMagic	
	
	; TEST USING ARRAY 3  (Predicted Result: R0 will be 1, since it's a VALID magic square)
	; Prepare registers for subroutine isMagic. 
	LDR	R0, =arr3
	LDR	R4, =size3
	LDR	R1, [R4]
	; Call the isMagic() Subroutine.
	BL	isMagic	
	
	; TEST USING ARRAY 4  (Predicted Result: R0 will be 0, since it's a NOT A VALID magic square)
	; Prepare registers for subroutine isMagic. 
	LDR	R0, =arr4
	LDR	R4, =size4
	LDR	R1, [R4]
	; Call the isMagic() Subroutine.
	BL	isMagic	
	
finished	
stop	B	stop

	
; isMagic subroutine
; Determines if a nxn array is a magic square or not (using 5 checks).
; Parameters:
; R0 - the array
; R1 - the size of the array
; Return Value:
; Boolean (True if R0 = 1, False if R0 = 0)
isMagic

	;5 checks required to determine if a nxn array is a magic square.
	
	; Step 1: The sums of the horizontal rows must be the same for all rows.
	BL	horizontallyMagic		; If horizontally Magic, R4 = 1 (0 if false).
	
	; Step 2: The sums of the vertical columns must be the same for all columns.
	BL	verticallyMagic			; If vertically Magic, R3 = 1 (0 if false).
	
	; Step 3: The sum of elements across the main diagonal must be checked.
	BL	diagonallyMagicFromLeftToRight ; Sum returned in R10	.
	
	; Step 4: The sum of elements across the off-diagonal must be checked.
	BL	diagonallyMagicFromRightToLeft	; Sum returned in R11.
	
	;With these 4 steps completed, the sums of all the horizontal rows (R4) / vertical columns (R3) must be equal, 
	;and the sums of both diagonals(R10 & R11) must be equal as well.
	
	; Step 5: Check that R3 and R4 are both 1 (true) and R10 and R11 are equal to each other.
	CMP	R3, #1		; if (verticallyMagic == true) {
	BNE	notMagic
	CMP	R4, #1		;    if(horizontallyMagic == true) {
	BNE	notMagic
	CMP	R10, R11	;	if(diagonallyMagicFromLeftToRight == diagonallyMagicFromRightToLeft) {
	BNE	notMagic
	LDR	R0, =1		;		isMagic = true;
	B	finished
	
notMagic			;	else {
	LDR	R0, =0		; 		isMagic = false;
	B	finished




; horizontallyMagic subroutine
; Determines if the sum of a 3x3 array's rows (horizontal elements) are equal
; Parameters:
; R0 - the array
; R1 - the size of the array
; Return Value:
; Boolean (True if R4 = 1, False if R4 = 0)
horizontallyMagic

	PUSH 	{R5-R10, lr}
	LDR	R10, =0		; count = 0;
	LDR	R6, =0 		; previousSum = 0;
	LDR 	R12, =0		; sum = 0;
	LDR	R4, =0		; horizontallyMagic = false;
	SUB	R2, R1, #1 	; R2 = N -1

	LDR 	R9, =0  ; for (int i = 0
forloop
	CMP 	R9, R1	; i < N
	BGE	endforloop
	LDR 	R5, =0  ; for (int j = 0
forloop2
	CMP 	R5, R1	; j < N
	BGE	endforloop2
	;Next three lines are to get element array[i,j]
	MUL	R7, R9, R1 		; index = row * ROWSZ
	ADD	R7, R7, R5 		; index = index + col
	LDR	R8, [R0, R7, LSL #2] 	;  elem = Memory.Word[ pArr + (index*4) ]
	
	ADD	R12, R12, R8 		; int sum = sum  + array[i,j];
	
	CMP	R6, R12			; if (previousSum = sum) {
	BEQ	HorizontallyMagicTRUE	; 	count  ++
	B	after			;     }
	
HorizontallyMagicTRUE	
	ADD	R10, #1;		; 	count++;

after
	
	CMP	R5, R2		; if (j == n-1) (i.e at the end of the row)
	BNE	notLastColumn
	MOV	R6, R12  	; move sum of current row into R6
	LDR	R12, =0		; sum = 0;
notLastColumn	
	
	ADD	R5, R5, #1 		; j ++
	B	forloop2
endforloop2
	ADD	R9, R9, #1 		; i ++	
	B	forloop
endforloop

	CMP	R10, R2		; If (count == N-1) {
	BNE	fail
	LDR	R4, =1		; horizontallyMagic = true;
fail
	POP {R5-R10, pc}
	BX	lr


; verticallyMagic subroutine
; Determines if the sum of a 3x3 array's columns (vertical elements) are equal
; Parameters:
; R0 - the array
; R1 - the size of the array
; Return Value:
; Boolean (True if R3 = 1, False if R3 = 0)
verticallyMagic

	; Fundamentally the same as the subroutine horizontally magic, however there's
	; a few tweaks such as getting array[j,i] intead of array [i,j].

	PUSH	{R5-R10, lr} 
	LDR	R6, =0		; previousSum = 0;
	SUB	R2, R1, #1 	; R2 = N -1
	
	LDR	R9, = 0		; for(int i = 0
fLoop
	CMP	R9, R1		; i < N
	BGE	efLoop
	LDR	R5, =0		; for(int j = 0
fLoop2
	CMP	R5, R1		; j < N
	BGE	efLoop2

	MUL	R7, R5, R1		;  index = row * ROWSZ (in this case, N)
	ADD	R7, R7, R9		;  index = index + col
	LDR	R8, [R0, R7, LSL #2]	;  elem = Memory.Word[ pArr + (index*4) ]

	ADD	R12, R12, R8 		; int sum = sum  + array[j,i]; 	

	CMP	R6, R12			; if (previousSum = sum) {
	BEQ	VerticallyMagicTRUE	; 	count++
	B	after2			;     }
	
VerticallyMagicTRUE	
	ADD	R10, #1;		;	count++;

after2
	
	CMP	R5, R2		; if (j == n-1) (i.e at the end of the column)
	BNE	notLastRow
	MOV	R6, R12  	; move sum of current row into R6
	LDR	R12, =0
notLastRow	

	ADD	R5, R5, #1	; j++
	B	fLoop2
efLoop2
	ADD	R9, R9, #1	; i++
	B	fLoop
efLoop
	CMP	R10, R2		;	if (count == N-1) {
	BNE	fail2		;		
	LDR	R3, =1		;	verticallyMagic = true;
fail2				;	}
	POP	{R5-R10, pc}
	BX	LR

; diagonallyMagicFromLeftToRight subroutine
; Determines the sum of a 3x3 array's diagonal from left to right (main diagonal)
; Parameters:
; R0 - the array
; R1 - the size of the array
; Return Value:
; int sum (sum of values across diagonal) into R10.
diagonallyMagicFromLeftToRight
	PUSH 	{R5-R9,lr}
	LDR	R5, =0			; ROW = 0 
	LDR	R6, =0			; COLUMN = 0 
	LDR	R10, =0			; SUM = 0
	LDR	R9, =0			; for (int i = 0
for
	CMP	R9, R1	; 	i < N
	BGE	endfor		;i++

	MUL	R7, R5, R1 		; index = row * ROWSZ (which is N)
	ADD	R7, R7, R6 		; index = index + column
	LDR	R8, [R0, R7, LSL #2]	; elem = Memory.Word[ pArr + (index*4) ] 
	
	ADD	R10, R10, R8		; int Sum = Sum + newSum;
	
	ADD	R5, R5, #1		; ROW++
	ADD	R6, R6, #1		; COLUMN++
	ADD	R9, R9, #1		; i++
	B	for
endfor
	POP	{R5-R9, pc}
	

; diagonallyMagicFromRightToLeft subroutine
; Determines the sum of a 3x3 array's diagonal from right to left (off-diagonal).
; Parameters:
; R0 - the array
; R1 - the size of the array
; Return Value:
; int sum (sum of values across diagonal) into R11.
diagonallyMagicFromRightToLeft
	PUSH 	{R5-R9,lr}
	;LDR	R0, =arr1 
	;LDR	R4, =size1 - change to R1
	LDR	R5, =0			; ROW 0 
	LDR	R11, =0			; SUM = 0
	SUB	R6, R1, #1		; Column = N -1;
	LDR	R9, =0	; for (int i = 0
for2
	CMP	R9, R1	; 	i < N
	BGE	endfor2		;i++
	
	
	MUL	R7, R5, R1 		; index = row * ROWSZ (which is N)
	ADD	R7, R7, R6 		; index = index + column
	LDR	R8, [R0, R7, LSL #2]	; elem = Memory.Word[ pArr + (index*4) ] 
	
	ADD	R11, R11, R8		; int Sum = Sum + newSum;
	
	ADD	R5, R5, #1		; ROW++
	SUB	R6, R6, #1		; COLUMN--
	ADD	R9, R9, #1		; i++
	B	for2
endfor2
	POP	{R5-R9, pc}

;	Arrays to test with:

;Array 1 - VALID 3x3 magic square
size1	DCD	3		; a 3x3 array
arr1	DCD	2,7,6		; the array
	DCD	9,5,1
	DCD	4,3,8	

;Array 2 - INVALID 3x3 magic square
size2	DCD	4,8,5
arr2	DCD	9,4,2
	DCD	5,4,6
	
;Array 3 - VALID 4x4 magic square
size3	DCD	4
arr3	DCD	9,6,3,16
	DCD	4,15,10,5
	DCD	14,1,8,11
	DCD	7,12,13,2

;Array 4 - INVALID 4x4 magic square 
size4	DCD	4
arr4	DCD	4,5,3,2
	DCD	1,2,6,9
	DCD	4,2,0,1
	DCD	3,6,0,1

	END
