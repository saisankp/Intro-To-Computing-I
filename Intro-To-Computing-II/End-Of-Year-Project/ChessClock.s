;
; CS1022 Introduction to Computing II 2018/2019
; Chess Clock
;

T0IR		EQU	0xE0004000
T0TCR		EQU	0xE0004004
T0TC		EQU	0xE0004008
T0MR0		EQU	0xE0004018
T0MCR		EQU	0xE0004014

PINSEL4		EQU	0xE002C010

FIO2DIR1	EQU	0x3FFFC041
FIO2PIN1	EQU	0x3FFFC055

EXTINT		EQU	0xE01FC140
EXTMODE		EQU	0xE01FC148
EXTPOLAR	EQU	0xE01FC14C

VICIntSelect	EQU	0xFFFFF00C
VICIntEnable	EQU	0xFFFFF010
VICVectAddr0	EQU	0xFFFFF100
VICVectPri0	EQU	0xFFFFF200
VICVectAddr	EQU	0xFFFFFF00

VICVectT0	EQU	4
VICVectEINT0	EQU	14

Irq_Stack_Size	EQU	0x80

Mode_USR        EQU     0x10
Mode_IRQ        EQU     0x12
I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled



	AREA	RESET, CODE, READONLY
	ENTRY

	; Exception Vectors

	B	Reset_Handler	; 0x00000000
	B	Undef_Handler	; 0x00000004
	B	SWI_Handler	; 0x00000008
	B	PAbt_Handler	; 0x0000000C
	B	DAbt_Handler	; 0x00000010
	NOP			; 0x00000014
	B	IRQ_Handler	; 0x00000018
	B	FIQ_Handler	; 0x0000001C

;
; Reset Exception Handler
;
Reset_Handler

	;
	; 1. Initialize Stack Pointers (SP) for each mode we are using
	;

	; Stack Top
	LDR	R0, =0x40010000

	; 2. Enter irq mode and set initial SP
	MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
	MOV     SP, R0
	SUB     R0, R0, #Irq_Stack_Size

	; 3. Enter user mode and set initial SP
	MSR     CPSR_c, #Mode_USR
	MOV	SP, R0
	
	;
	; 4. Initialise variables stored in RAM
	;
	LDR	R4, =maxTime
	LDR	R5, =20000000 
	STR	R5, [R4]		; maximumTime = 10 seconds
	LDR	R4, =player1
	LDR	R5, =0
	STR	R5, [R4]		; Player1's total time spent = 0;
	LDR	R4, =player2
	LDR	R5, =0		
	STR	R5, [R4]		; Player2's total time spent = 0;
	LDR	R4, =count
	LDR	R5, =1		
	STR	R5, [R4]		; Count = 0;
	
	; 5. Enable P2.10 for EINT0
	LDR	R4, =PINSEL4
	LDR	R5, [R4]		; read current value
	BIC	R5, #(0x03 << 20)	; clear bits 21:20
	ORR	R5, #(0x01 << 20) 	; set bits 21:20 to 01
	STR	R5, [R4]		; write new value
	
	; 6. Set edge-sensitive mode for EINT0
	LDR	R4, =EXTMODE
	LDR	R5, [R4]		; read
	ORR	R5, #1			; modify
	STRB	R5, [R4]		; write
	
	; 7. Set rising-edge mode for EINT0
	LDR	R4, =EXTPOLAR
	LDR	R5, [R4]		; read
	ORR	R5, #1			; modify
	STRB	R5, [R4]		; write
	
	; 8. Reset EINT0
	LDR	R4, =EXTINT
	MOV	R5, #1
	STRB	R5, [R4]
	
	; 9. Reset TIMER0 using Timer Control Register
	;   Set bit 0 of TCR to 0 to stop TIMER
	;   Set bit 1 of TCR to 1 to reset TIMER
	LDR	R5, =T0TCR
	LDR	R6, =0x2
	STRB	R6, [R5]
	
	; 10. Reset TC
	;due to a bug in the peripherals i had to manually reset TC
	LDR	R5, =T0TC	
	LDR	R6, =0
	STR	R6, [R5]
	
	; 11. Clear any previous TIMER0 interrupt by writing 0xFF to the TIMER0
	; Interrupt Register (T0IR)
	LDR	R5, =T0IR
	LDR	R6, =0xFF
	STRB	R6, [R5]

	; 12. IRQ on match using Match Control Register
	; Set bit 0 of MCR to 1 to turn on interrupts
	; Set bit 1 of MCR to 1 to reset counter to 0 after every match
	; Set bit 2 of MCR to 0 to leave the counter enabled after match
	LDR	R4, =T0MCR
	LDR	R5, =0x03
	STRH	R5, [R4]


	; 13. Set match register for 30 secs using Match Register
	; Assuming a 1Mhz clock input to TIMER0, set MR
	; MR0 (0xE0004018) to 5,000,000
	LDR	R4, =T0MR0
	LDR	R5, =30000000
	STR	R5, [R4]

	
	;
	; 14. Configure VIC for EINT0 interrupts
	;

	; Useful VIC vector numbers and masks for following code
	LDR	R4, =VICVectEINT0		; vector 14
	LDR	R5, =(1 << VICVectEINT0) 	; bit mask for vector 14

	; VICIntSelect - Clear bit 4 of VICIntSelect register to cause
	; channel 14 (EINT0) to raise IRQs (not FIQs)
	LDR	R6, =VICIntSelect	; addr = VICVectSelect;
	LDR	R7, [R6]		; tmp = Memory.Word(addr);
	BIC	R7, R7, R5		; Clear bit for Vector 14
	STR	R7, [R6]		; Memory.Word(addr) = tmp;

	; Set Priority for VIC channel 14 (EINT0) to lowest (15) by setting
	; VICVectPri4 to 15. Note: VICVectPri4 is the element at index 14 of an
	; array of 4-byte values that starts at VICVectPri0.
	; i.e. VICVectPri4=VICVectPri0+(4*4)
	LDR	R6, =VICVectPri0	; addr = VICVectPri0;
	MOV	R7, #15			; pri = 15;
	STR	R7, [R6, R4, LSL #2]	; Memory.Word(addr + vector * 4) = pri;

	; Set Handler routine address for VIC channel 14 (EINT0) to address of
	; our handler routine (ButtonHandler). Note: VICVectAddr14 is the element
	; at index 14 of an array of 4-byte values that starts at VICVectAddr0.
	; i.e. VICVectAddr14=VICVectAddr0+(4*4)
	LDR	R6, =VICVectAddr0	; addr = VICVectAddr0;
	LDR	R7, =Button_Handler	; handler = address of ButtonHandler;
	STR	R7, [R6, R4, LSL #2]	; Memory.Word(addr + vector * 4) = handler

	; Enable VIC channel 14 (EINT0) by writing a 1 to bit 4 of VICIntEnable
	LDR	R6, =VICIntEnable	; addr = VICIntEnable;
	STR	R5, [R6]		; enable interrupts for vector 14


	; 15. Start TIMER0 using the Timer Control Register
	; Set bit 0 of TCR (0xE0004004) to enable the timer
	LDR	R4, =T0TCR
	LDR	R5, =0x01
	STRB	R5, [R4]
	
	
	
stop	B	stop


;
; TOP LEVEL EXCEPTION HANDLERS
;

;
; Software Interrupt Exception Handler
;
Undef_Handler
	B	Undef_Handler

;
; Software Interrupt Exception Handler
;
SWI_Handler
	B	SWI_Handler

;
; Prefetch Abort Exception Handler
;
PAbt_Handler
	B	PAbt_Handler

;
; Data Abort Exception Handler
;
DAbt_Handler
	B	DAbt_Handler

;
; Interrupt ReQuest (IRQ) Exception Handler (top level - all devices)
;
IRQ_Handler
	SUB	lr, lr, #4	; for IRQs, LR is always 4 more than the
				; real return address
	STMFD	sp!, {r0-r3,lr}	; save r0-r3 and lr

	LDR	r0, =VICVectAddr; address of VIC Vector Address memory-
				; mapped register

	MOV	lr, pc		; can’t use BL here because we are branching
	LDR	pc, [r0]	; to a different subroutine dependant on device
				; raising the IRQ - this is a manual BL !!

	LDMFD	sp!, {r0-r3, pc}^ ; restore r0-r3, lr and CPSR

;
; Fast Interrupt reQuest Exception Handler
;
FIQ_Handler
	B	FIQ_Handler


;
; write your interrupt handlers here
;
	
	
	;
; EINT0 IRQ Handler (device-specific handler called by top-level IRQ_Handler)
;
Button_Handler
	
	STMFD	sp!, {R1-R9, lr}

	; 1. Reset EINT0 interrupt by writing 1 to EXTINT register
	LDR	R4, =EXTINT
	MOV	R5, #1
	STRB	R5, [R4]
	
	
	; 2. Stop TIMER0 using the Timer Control Register
	;   Set bit 0 of TCR to enable the timer
	LDR	R4, =T0TCR
	LDR	R5, =0x00
	STRB	R5, [R4]
	
	
	; 3. Read values from RAM to compare with
	LDR	R6, =T0TC	
	LDR	R8, [R6]	; read current timer counter value (time when button was pressed)
	
	LDR	R6, =maxTime
	LDR	R7, [R6]	; get maximum time from memory (in this case, 5 seconds)
	
	;CMP	R8, R7		; if( timer <= maxTime)
	;BGT	tooLate
				; continue with game
	LDR	R1, =count	
	LDR	R2, [R1]
	AND	R1, R2, #1 ; Note : I use 'AND' to find (count%2), if count modulo 2 is equal to 0,
			   ; then, count is even and it's player two's turn. If count modulo 2 is 
			   ; not equal to zero, then count is odd, and it's player one's turn.
	
	CMP	R1, #0
	BEQ	playerTwo
	
playerOne
	LDR	R6, =player1
	LDR	R9, [R6]
	ADD	R9, R9, R8	; player1Time = player1Time + newTime;
	STR	R9, [R6]
	B	continue
	
playerTwo
	LDR	R6, =player2
	LDR	R9, [R6]
	ADD	R9, R9, R8	; player2Time = player1Time + newTime;
	STR	R9, [R6]
	B	continue
	
continue
	
	LDR	R6, =player1
	LDR	R9, [R6]
	CMP	R9, R7		; if (player1TotalTime > maxTime)
	BGE	playerTookTooMuchTime	; playerTookTooMuchTime = true;
	
	
	LDR	R6, =player2
	LDR	R9, [R6]
	CMP	R9, R7		; if (player2TotalTime > maxTime)
	BGE	playerTookTooMuchTime	;  playerTookTooMuchTime = true;
	B	continued
	
playerTookTooMuchTime
	; Since a player took too much time, we must stop the clock and indicate to the user that
	; this has happened.
	
	; Stop and reset TIMER0 using Timer Control Register
	; Set bit 0 of TCR to 0 to stop TIMER
	; Set bit 1 of TCR to 1 to reset TIMER
	LDR	R5, =T0TCR
	LDR	R6, =0x2
	STRB	R6, [R5]
	
	; 3. Reset TC
	;due to a bug in the peripherals i had to manually reset TC
	LDR	R5, =T0TC	
	LDR	R6, =0
	STR	R6, [R5]
	
	
	LDR	R6, =maxTime
	LDR	R9, [R6]
	LDR	R9, =999999999	; Make total time used to 999999999 to indicate Player 1 used too much time.
	STR	R9, [R6]
	B	continue1
	
continued	
	; 5. Increment the count by one
	LDR	R6, =count
	LDR	R9, [R6]
	ADD	R9, R9, #1
	STR	R9, [R6]

	
	; 6. Reset TIMER0 using Timer Control Register
	;   Set bit 0 of TCR to 0 to stop TIMER
	;   Set bit 1 of TCR to 1 to reset TIMER
	LDR	R5, =T0TCR
	LDR	R6, =0x2
	STRB	R6, [R5]
	
	; 7. Reset TC
	;due to a bug in the peripherals i had to manually reset TC
	LDR	R5, =T0TC	
	LDR	R6, =0
	STR	R6, [R5]

	
	; 8. Start TIMER0 using the Timer Control Register
	; Set bit 0 of TCR (0xE0004004) to enable the timer
	LDR	R4, =T0TCR
	LDR	R5, =0x01
	STRB	R5, [R4]
continue1
	
	; Clear any previous TIMER0 interrupt by writing 0xFF to the TIMER0
	; Interrupt Register (T0IR)
	LDR	R5, =T0IR
	LDR	R6, =0xFF
	STRB	R6, [R5]
	
	;
	; 9. Clear source of interrupt
	;
	LDR	R4, =VICVectAddr	; addr = VICVectAddr
	MOV	R5, #0			; tmp = 0;
	STR	R5, [R4]		; Memory.Word(addr) = tmp;
	LDMFD	sp!, {R1-R9, pc}
	
	AREA	TestData, DATA, READWRITE
; These are the 4 variables I used in this program

; maxTime indicates the maximum time a player has before they need to press the button after a move.
maxTime	SPACE	4
	
; player1 indicates the total amount of time player 1 has used between ALL of their moves so far.
player1	SPACE	4
	
; player2 indicates the total amount of time a player 2 has used between ALL of their moves so far.
player2	SPACE	4
	
; count indicates the number of times a move was made by both the players, and is key for the program to find 
; out which player played last (since only one timer is used).
count	SPACE	4	


	END
