;
; CS1022 Introduction to Computing II 2018/2019
; Lab 1 - Array Move
;

N	EQU	16		; number of elements

	AREA	globals, DATA, READWRITE

; N word-size values

ARRAY	SPACE	N*4		; N words


	AREA	RESET, CODE, READONLY
	ENTRY

	; for convenience, let's initialise test array [0, 1, 2, ... , N-1]

	LDR	R0, =ARRAY
	LDR	R1, =0
L1	CMP	R1, #N
	BHS	L2
	STR	R1, [R0, R1, LSL #2]
	ADD	R1, R1, #1
	B	L1
L2

	; initialise registers for your program

	LDR	R0, =ARRAY
	LDR	R1, =6
	LDR	R2, =3
	LDR	R3, =N

	; your program goes here
	
	CMP	R2, R1			; if (newIndex < previousIndex)
	BHS	finish1			; {
	LDR	R4, [R0, R1, LSL #2]	;	elementToMove = memory.word[startAddress+(previousIndex*4)];
	MOV	R6, R2			;	currentIndex = newIndex;
while1	
	CMP	R6, R1			;	while(currentIndex<=previousIndex)
	BHI	quit			;	{
	LDR	R5, [R0, R6, LSL #2]	;		previousElement = Memory.word[startAddress+(currentIndex*4)];
	STR	R4, [R0, R6, LSL #2]	;		Memory.word[startAddress+(currentIndex*4)] = elementToMove;
	MOV	R4, R5			;		elementToMove = previousElement;
	ADD	R6, R6, #1		;		currentIndex++;
	B	while1			;	}	
					; }
					
finish1	CMP	R2, R1			; else if (newIndex > previousIndex)
	BLS	finish2		; {
	LDR	R4, [R0, R1, LSL #2]	;	elementToMove = memory.word[startAddress+(previousIndex*4)];
	MOV	R6, R2			;	currentIndex = newIndex;
while2	
	CMP	R6, R1			;	while(currentIndex>=previousIndex)
	BLO	quit			;	{
	LDR	R5, [R0, R6, LSL #2]	;		previousElement = Memory.word[startAddress+(currentIndex*4)];
	STR	R4, [R0, R6, LSL #2]	;		Memory.word[startAddress+(currentIndex*4)] = elementToMove;
	MOV	R4, R5			;		elementToMove = previousElement;
	SUB	R6, R6, #1		;		currentIndex--;
	B	while2		;	}
					; }
finish2				
quit


STOP	B	STOP

	END
