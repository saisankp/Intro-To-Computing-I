;
; CSU11021 Introduction to Computing I 2019/2020
; GCD
;

	AREA	RESET, CODE, READONLY
	ENTRY

	; a is stored in R2
	; b is stored in R3
	; the result is stored in R0
	LDR	R2, =4
	LDR	R3, =10
start
	CMP	R2, R3 ;Compare b and a 
	BEQ	label  ; if a = b, 

	CMP 	R2, R3 ;Compare b and a 
	BLE	label2 ; if b > a
	
	SUB	R2, R2, R3 ; A = A-B
	MOV	R0, R2	   ; Store thr result in R0
	B 	start
label2
	SUB 	R3, R3, R2 ; B = B-A
	B 	start
label
	MOV	R0, R3
	B	STOP
STOP
	END