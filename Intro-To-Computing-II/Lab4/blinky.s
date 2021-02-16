;
; CS1022 Introduction to Computing II 2019/2020
; Lab 4 Part A
;

; TIMER0 registers
T0TCR		EQU	0xE0004004
T0TC		EQU	0xE0004008

; Pin Control Block registers
PINSEL4		EQU	0xE002C010

; GPIO registers
FIO2DIR1	EQU	0x3FFFC041
FIO2PIN1	EQU	0x3FFFC055


	AREA	RESET, CODE, READONLY
	ENTRY

	;Following the pseudo code in the question :

	; STEP 1: Configure P2.10 as a GPIO output
	
        ; Enable P2.10 for GPIO
	LDR	R4, =PINSEL4	; load address of PINSEL4
	LDR	R5, [R4]	; read current PINSEL4 value
	BIC	R5, #(0x3 << 20); modify bits 20 and 21 to 00
	STR	R5, [R4]	; write new PINSEL4 value
	; Set P2.10 for input
	LDR	R4, =FIO2DIR1	; load address of FIO2DIR1
	NOP			
	LDRB	R5, [R4]	; read current FIO2DIR1 value
	BIC	R5, #(0x1 << 2)	; modify bit 2 to 0 for INPUT however other bits are unmodified
	STRB	R5, [R4]	; write new FIO2DIR1
	LDR	R4, =FIO2PIN1	; load address of FIO2PIN1
; Continuously examine the input to check if there's a button press to commence the game
waitStrt			;	do
				;	{
	LDRB	R9, [R4]	;		currentState = (FIO2PIN1 & 0x4)
	AND	R9, R9, #0x4
	CMP	R9, #0		;	} while(currentState is not equal to zero)
	BNE	waitStrt
	
	
	; STEP 2: Stop and reset the timer 
	
	; Reset TIMER0 using Timer Control Register
	;   Set bit 0 of TCR to 0 to stop TIMER
	;   Set bit 1 of TCR to 1 to reset TIMER
	LDR	R4, =T0TCR
	LDR	R5, =0x2
	STRB	R5, [R4]
	
	; Deal with uVision simulation bug (code given to us)
	LDR	R4, =T0TC
	LDR	R5, =0x0
	STR	R5, [R4]	
	
	;STEP 3: Start timer 0
	
	; Start TIMER0 using the TCR
	LDR	R4, =T0TCR
	LDR	R5, =0x01
	STRB	R5, [R4]
	
	; STEP 4: Wait till the button is pressed down again
	
	; variables needed for the game
	MOV	R7, #1		;	winner = true(1);
	MOV	R0, #0		;	roundsPassed = 0;
	LDR	R8, =5000000	;	shortestTime = 5 seconds;
	LDR	R6, =8000000	;	longestTime = 8 seconds;
	LDR	R10, =3000000	;	timeJump = 3 seconds;
	
	; For loop to loop the game until the player loses
whlWin	
	CMP	R7, #0		;	while(winner != false)
	BEQ	eGame		;	{
	LDR	R4, =FIO2PIN1
	LDRB	R9, [R4]	;   		lastState = (FIO2PIN1 & 0x4);
	AND	R9, R9, #0x4	;

	;STEP 5; Stop Timer 0
whPoll				;   		do 
				;		{
	LDRB	R5, [R4]	;     			currentState = FIO2PIN1 & 0x4
	AND	R5, R5, #0x4	;
	CMP	R5, R9		;
	BEQ	whPoll		;   		} while (currentState == lastState)
	;STEP 6: Elapsed Time = T0TC
	CMP	R5, #0		;   		if (currentState == 0)
	BNE	ifNoPrs		;		{
	LDR	R4, =T0TC	;			timer = timerCounter.getTime()
	LDR	R5, [R4]
	;STEP 7: Use if-statements to find if the player won or not.
	CMP	R5, R8		;			if(timer >= minTime
	BLO	lose		;				&&
	CMP	R5, R6		;				timer <= maxTime)
	BHI	lose		;			{
	ADD	R8, R8, R10	;				minTime += timeIncrement;
	ADD	R6, R6, R10	;				maxtime += timeIncrement;
	ADD	R0, R0, #1	;				roundsPassed++;
	
	; Reset timer
	MOV	R5, #0
	STR	R5, [R4]
	B	win		;			}
lose				;			else
				;			{
	MOV	R7, #0		;				winner = false;
	MOV	R11, R5	
win		;			}
	;STEP 8:  Turn on the LED
ifNoPrs				;		}
	B	whlWin		;	}
eGame	
	
	;STEP 9: Reconfigure P2.10 as a GPIO output 
	LDR	R4, =FIO2DIR1	; load the address of FIO2DIR1
	NOP
	LDRB	R5, [R4]	; read the current FIO2DIR1 value
	ORR	R5, #(0x1 << 2)	; modify bit 2 to 1 for output, so, the other bits are unmodified
	STRB	R5, [R4]	; write new FIO2DIR1 into memory
	LDR	R4, =FIO2PIN1	; load address of FIO2PIN1
	LDRB	R5, [R4]	; read FIO2PIN1
	ORR	R5, R5, #0x04	; set bit 2 (turn LED on)
	STRB	R5, [R4]	; write new FIO2PIN1
	
STOP	B	STOP
	
	END
				