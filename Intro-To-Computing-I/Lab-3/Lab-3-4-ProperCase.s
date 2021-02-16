;
; CSU11021 Introduction to Computing I 2019/2020
; Proper Case
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R0, =tststr	; address of existing string
	LDR	R1, =0x40000000	; address for new string
	LDR	R3, =0x20	; previous char = space
; 
WhStr	
	LDRB	R4, [R0]        ; current char = Memory.byte[address]
	CMP	R4, #0          ; While (char != 0) 
	BEQ	eWhStr		
	CMP	R3, #0x20       ; If the last character was a space, Capatalize the next letter.
	BNE	checkCaps
	CMP	R4, #'a'        ; if (char >= a)
	BLO	endiff                ; AND 
	CMP	R4, #'z'        ; if (char <= 'z')
	BHI	endiff
	
	SUB	R4, R4, #0x20   ; Convert to Uppercase
	B	endiff
	
checkCaps
	CMP	R4, #'A'        ; if (char >= 'A')
	BLO	endiff                ; AND 
	CMP	R4, #'Z'        ; if (char <= 'Z')
	BHI	endiff
	ADD	R4, R4, #0x20   ; Convert to Lowercase 

endiff	
	MOV	R3, R4		; previous char = current char
	STRB	R4, [R1]	; Memory.byte[address] = char
	ADD	R0, R0, #1	; address++
	ADD	R1, R1, #1
	B	WhStr
	
eWhStr
	
STOP	B	STOP

tststr	DCB	"HeLLO woRld",0

	END
