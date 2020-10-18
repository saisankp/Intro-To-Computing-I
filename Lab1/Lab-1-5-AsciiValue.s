;
; CSU11021 Introduction to Computing I 2019/2020
; Convert a sequence of ASCII digits to the value they represent
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R1, ='2'	; Load R1 with ASCII code for symbol '2'
	LDR	R2, ='0'	; Load R2 with ASCII code for symbol '0'
	LDR	R3, ='3'	; Load R3 with ASCII code for symbol '3'
	LDR	R4, ='4'	; Load R4 with ASCII code for symbol '4'

	; your program goes here
	SUB	R1, R1, #0x30 ; R1 = 0x02 
	SUB	R2, R2, #0x30 ; R2 = 0x00
	SUB	R3, R3, #0x30 ; R3 = 0x03
	SUB 	R4, R4, #0x30 ; R4 = 0x04
	
	MOV	R0, #1000   ; R0 = 1000
	MUL	R1, R0, R1  ; R1 = 0x02 x 1000 = 0x2000
	MOV	R5, #100    ; R5 = 100
	MUL	R2, R5, R2  ; R2 = 0x00 x 10 = 0x00
	MOV 	R6, #10     ; R6 = 10
	MUL	R3, R6, R3  ; R3 = 0x03 x 10 = 0x30
	
	ADD	R0, R1, R2  ; R0 = 0x2000 + 0x00
	ADD	R0, R0, R3  ; R0 = 0x2000 + 0x00 + 0x30
	ADD	R0, R0, R4  ; R0 = 0x2000 + 0x00 + 0x30 + 0x04
	

STOP	B	STOP

	END
