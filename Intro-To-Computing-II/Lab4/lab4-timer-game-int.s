;
; CS1022 Introduction to Computing II 2018/2019
; Lab 4 - timer-game-int
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
	; Initialize Stack Pointers (SP) for each mode we are using
	;

	; Stack Top
	LDR	R0, =0x40010000

	; Enter undef mode and set initial SP
	MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
	MOV     SP, R0
	SUB     R0, R0, #Irq_Stack_Size

	; Enter user mode and set initial SP
	MSR     CPSR_c, #Mode_USR
	MOV	SP, R0

	;
	; Your program goes here
	;


	; 1. First, let's initialize the varibles in RAM

	LDR	R4, =Count		; R4 = count
	LDR	R5, =0			; Make sure R5 is empty
	STR	R5, [R4]		; count = 0;
	LDR	R4, =smallT		; R4 = Lower limit of time
	LDR	R5, =5000000		; Load 5,000,000 into R5 which is equivalent to 5 seconds (from ms)
	STR	R5, [R4]		; L_Limit = 5 seconds (lower time limit)
	LDR	R4, =bigT		; R4 = Upper limit of time 
	LDR	R5, =8000000		; Load 8,000,000 into R5 which is equivalent to 8 seconds (from ms)
	STR	R5, [R4]		; U_Limit = 8 seconds (upper time limit)
	
	; 2. Enable P2.10 for EINT0 (not GPIO from last time)
	LDR	R4, =PINSEL4
	LDR	R5, [R4]		; read the current value of PINSEL4
	BIC	R5, #(0x03 << 20)	; clear the bits 21:20
	ORR	R5, #(0x01 << 20) 	; then, set the bits 21:20 to 01
	STR	R5, [R4]		; write new value to enable P2.10 for EINT0
	
	; 3. Now, we set the edge-sensitive mode for EINT0
	LDR	R4, =EXTMODE
	LDR	R5, [R4]		; 1. first, read
	ORR	R5, #1			; 2. modify using the ORR instruction with #1
	STRB	R5, [R4]		; 3. finally, write
	
	; 4. Set rising-edge mode for EINT0
	LDR	R4, =EXTPOLAR
	LDR	R5, [R4]		; first, read
	ORR	R5, #1			; modify using the ORR instruction with #1
	STRB	R5, [R4]		; finally, write
	
	; 5. Reset EINT0
	LDR	R4, =EXTINT
	MOV	R5, #1			; use the MOV instruction to move #1 into R5 to reset EINTO
	STRB	R5, [R4]		; This is to make sure it's reset from any previous uses.
	
	; 6. Reset TIMER0 using Timer Control Register (from lab 4 part A - not changed)
	;    Set bit 0 of TCR to 0 to stop TIMER
	;    Set bit 1 of TCR to 1 to reset TIMER
	LDR	R5, =T0TCR
	LDR	R6, =0x2
	STRB	R6, [R5]
	

	; 7. Deal with uVision simulation bug (code given to us)
	LDR	R5, =T0TC	
	LDR	R6, =0
	STR	R6, [R5]
	
	;
	; Now, we shall configure VIC for the EINT0 interrupts
	;

	; 8. Some useful VIC Vector Numbers and Masks for following code
	LDR	R4, =VICVectEINT0		; The Vector fourteen
	LDR	R5, =(1 << VICVectEINT0) 	; a Bit mask for the Vector fourteen

	; 9. VICIntSelect - so clear bit 4 of VICIntSelect register to make Channel 14 (EINT0) to raise IRQs (and not FIQs)
	LDR	R6, =VICIntSelect	; address = VICVectSelect;
	LDR	R7, [R6]		; tmp = Memory.Word(addr);
	BIC	R7, R7, R5		; Clear the bit for Vector 14
	STR	R7, [R6]		; Memory.Word(addr) = tmp;

	; 10. Set the Priority for VIC channel 14 (EINT0) to the lowest (which is 15) by setting VICVectPri4 to the value 15. 
	; Note: VICVectPri4 is the element at index 14 of an array of 4-byte values that starts at VICVectPri0.
	; i.e. VICVectPri4=VICVectPri0+(4*4)
	LDR	R6, =VICVectPri0	; address = VICVectPri0;
	MOV	R7, #15			; pri = 15;
	STR	R7, [R6, R4, LSL #2]	; Memory.Word(address + vector * 4) = pri;

	; 11. Set the Handler routine address for the VIC channel 14 (EINT0) to address of our handler routine (ButtonHandler). 
	; Note: VICVectAddr14 is the element at index 14 of an array of 4-byte values that starts at VICVectAddr0.
	; i.e. VICVectAddr14=VICVectAddr0+(4*4)
	LDR	R6, =VICVectAddr0	; address = VICVectAddr0;
	LDR	R7, =Button_Handler	; handler = address of ButtonHandler;
	STR	R7, [R6, R4, LSL #2]	; Memory.Word(address + vector * 4) = handler;

	; 12. Enable VIC channel 14 (EINT0) by writing a 1 to bit 4 of VICIntEnable
	LDR	R6, =VICIntEnable	; addr = VICIntEnable;
	STR	R5, [R6]		; enable interrupts for vector 14
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
; EINT0 IRQ Handler (a device-specific handler called by the top-level IRQ_Handler)
;
Button_Handler

	STMFD	sp!, {r4-r5, lr}

	; 13.  Reset EINT0 interrupt by writing 1 to EXTINT register
	LDR	R4, =EXTINT	;first, read
	MOV	R5, #1		; modify by loading 1 into the EXTINT register
	STRB	R5, [R4]	; finally, write.
	
	
	; 14. Increment count
	
	LDR	R4, =Count		; address = count
	LDR	R5, [R4]		; temporary_count = Memory.Word(addr);
	ADD	R5, R5, #1		; count++;
	STR	R5, [R4]		; Memory.Word(addr) = temporary_count;
	CMP	R5, #1
	BNE	otherwise
	
	
	; Start TIMER0 using the Timer Control Register (from lab 4 part A)
	;   Set bit 0 of TCR to enable the timer
	LDR	R4, =T0TCR
	LDR	R5, =0x01
	STRB	R5, [R4]
	B	there1
otherwise	
	CMP	R5, #2
	BNE	there1
	
	
	; Set P2.10 for output (from lab 4 part A)
	LDR	R5, =FIO2DIR1	; load address of FIO2DIR1
	NOP
	LDRB	R6, [R5]	; read the current FIO2DIR1 value
	ORR	R6, #(0x1 << 2)	; modify bit 2 to 1 for output, so, the other bits are unmodified
	STRB	R6, [R5]	; write new FIO2DIR1 into memory
	
	LDR	R5, =smallT
	LDR	R9, [R5]
	LDR	R5, =bigT
	LDR	R10, [R5]
	LDR	R6, =T0TC	; 
	LDR	R8, [R6]	; read timer counter value
	CMP	R8, R9		; if(TC < 5 seconds || TC > 8 seconds)
	BLO	lost		;	lost = true;
	CMP	R8, R10		;
	BHI	lost		;
	
	;Turn off the led (from lab 4 part A)		; if(!lost) {
	LDR	R5, =FIO2PIN1	;	
	LDR	R6, [R5]	;	read FIO2PIN1 value
	ORR	R6, R6, #0x04	;	set bit 2 of FIO2PIN1 (LED off)
	STRB	R6, [R5]	;	load new FIO2PIN1 value 
	LDR	R5, =3000000	;	increment lower and upper time limit by 3 seconds
	ADD	R9, R5		;	setInput();
	LDR	R6, =smallT
	STR	R9, [R6]
	ADD	R10, R5		
	LDR	R6, =bigT
	STR	R10, [R6]
	B	setinput	; }
lost				; else if(lost){

	;Turn on led (from lab 4 part A)
	LDR	R5, =FIO2PIN1
	LDR	R6, [R5]	; read FIO2PIN1 value
	BIC	R6, R6, #0x04	; clear bit 2 of FIO2PIN1 (LED on)
	STRB	R6, [R5]	; load new FIO2PIN1 value
				; }
setinput
	; Set P2.10 for input
	LDR	R4, =FIO2DIR1	; load address of FIO2DIR1

	NOP			; on "real" hardware, we cannot place
				; an instruction at address 0x00000014
	LDRB	R5, [R4]	; read current FIO2DIR1 value
	BIC	R5, #(0x1 << 2)	; modify bit 2 to 0 for input, leaving other bits unmodified
	STRB	R5, [R4]	; write new FIO2DIR1
	
	LDR	R4, =Count		; addr = count
	LDR	R5, =0
	STR	R5, [R4]
	
	; Reset TIMER0 using Timer Control Register (from lab 4 part A)
	;   Set bit 0 of TCR to 0 to stop TIMER
	;   Set bit 1 of TCR to 1 to reset TIMER
	LDR	R5, =T0TCR
	LDR	R6, =0x2
	STRB	R6, [R5]
	
	
	; Deal with uVision simulation bug (code given to us)
	LDR	R5, =T0TC	
	LDR	R6, =0
	STR	R6, [R5]
there1
	
	;
	; New: Clear source of interrupt
	;
	LDR	R4, =VICVectAddr	; addr = VICVectAddr
	MOV	R5, #0			; tmp = 0;
	STR	R5, [R4]		; Memory.Word(addr) = tmp;
	
	LDMFD	sp!, {r4-r5, pc}

	AREA	TestData, DATA, READWRITE

;variables for our program
Count	SPACE	4
smallT	SPACE	4
bigT	SPACE	4



	END
