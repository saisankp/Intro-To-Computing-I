;
; CSU11021 Introduction to Computing I 2019/2020
; Anagrams
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R0, =tststr1	; first string
	LDR	R1, =tststr2	; second string
				;
	LDR	R4, =0 		; numberOfCharactersInString1 = 0
	LDR	R5, =0		; numberOfMatchingChracters = 0
	LDR	R7, =0		; numberOfCharactersInString2 = 0
				;
	MOV	R6, R1		; memory2 = second string
				; String2Char = String2[memory2]
				
countWh ; Checks how many chars in String 2
	LDRB	R3, [R6]	;
	ADD	R6, R6, #1	; memory2++
	CMP	R3, #0		; while(String2Char != 0) - check that it's not null terminated
	BEQ	endCountWh	;       if(String2Char == 0x20), then  continue;
	CMP	R3, #0x20	; else if {
	BEQ	countWh		; no.OfCharsInString2++
	ADD	R7, R7, #1      ; String2Char = String2Char[memory2++];
	B	countWh		;
endCountWh

while ; Checks how many chars in String 1
	LDRB	R2, [R0]	; String1Char = String1[memory]
	ADD	R0, R0, #1	;
	CMP	R2, #0		; while(String1Char != 0) - check that it's not null terminated
	BEQ	endwh		; 
	CMP	R2, #0x20	; if(String1Char == 0x20)
	BEQ	while		; continue
	ADD	R4, R4, #1	; else 
	MOV	R6, R1		; 	noOfCharactersInString1++
				; memory2 = second String
				
while2 ; Checks the number of matching characters
	LDRB	R3, [R6]	; Load memory of address stored in R6 into R3
	ADD	R6, R6, #1	;  memory2++
	CMP	R3, #0x20	;  if(String2Char == 0x20)
	BEQ	while2		; 	continue;
	CMP	R3, #0		;   while (String2Char != 0)
	BEQ	endwh2		;  else if (String2Char == String1Char)
				; 	numberOfnumberOfMatchingChracters++;
				;	break;
	CMP	R3, R2		; if String2char == string1char
	BEQ	anagram		;  it's an anagram
	ADD	R9, R2, #0x20	; 
	CMP	R3, R9		; convert to capital and compare to see if it's an anagram.
	BEQ	anagram		;
	SUB	R9, R2, #0x20   ;
	CMP	R3, R9
	BNE	while2		; 		continue;
	
anagram
	ADD 	R5, R5, #1	; String2Char = String2Char[Memory2]++;
endwh2	
				; String1Char = String1Char[Memory]++
	B while	

endwh				; if((numberOfCharsInString1 == numberOfCharactersInString2) && (numberOfCharsInString1 == numberOfCharsInString2)
				
	CMP	R4, R7		;  numberOfCharactersInString1 =  numberOfCharactersInString2
	BNE	notEqual
	CMP	R4, R5		;  numberOfCharactersInString1 = numberOfMatchingChracters
	BNE	notEqual
	LDR	R0, =1
	B 	STOP
notEqual
	LDR	R0, =0

STOP	B	STOP

tststr1	DCB	"abc",0
tststr2	DCB	"bbb",0

	END
