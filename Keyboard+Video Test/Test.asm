;*******************************************************************************
; Test.im800.asm
; Tests basic video and keyboard functionality by making pretty colors when the
; user presses keys.
;*******************************************************************************

reset_vector:
	.DEFD start
	
start:
	; Clear VRAM
	LD HL, 0x00400000
	LD DE, 0x00400002
	LD BC, 1999
	LD.W [HL], 0
	BLD I, R, WORD
	
	; Enable display, no cursor
	LD A, 1
	OUT.B [0x01], A
	
	; Set HL to the start of VRAM
	LD HL, 0x00400000
.loop:
	; Poll keyboard until a scancode is in the queue
	IN.B A, [0x04]
	JAZ .loop
	
	; Write it to VRAM
	LD.B [HL], A
	
	; Increment HL by 1 (1 scancode sets char, next sets attribute)
	INC HL
	; If HL > VRAM, reset it
	CP HL, 0x00400FA0
	JR.B C, .noresethl
	LD HL, 0x00400000
.noresethl:
	; Repeat forever
	JR.B .loop

