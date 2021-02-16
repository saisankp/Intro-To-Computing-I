;
; CSU11021 Introduction to Computing I 2019/2020
; Adding the values represented by ASCII digit symbols
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R1, ='2'	; Load R1 with ASCII code for symbol '2'
	LDR	R2, ='4'	; Load R2 with ASCII code for symbol '4'

	; your program goes here
	SUB	R1, R1, #0x30 ; Subtract 0x30 from 0x32 to get 0x02
	SUB	R2, R2, #0x30 ; Subtract 0x30 from 0x34 to get 0x04
	ADD	R0, R1, R2    ; Add the values of 0x02 and 0x04 to get 0x06 stored in R0
	ADD	R0, R0, #0x30 ; Add 0x30 to 0x06 to get 0x36 stored in R0
	

STOP	B	STOP

	END
