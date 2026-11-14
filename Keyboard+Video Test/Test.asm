;*******************************************************************************
; Test.asm
; Tests basic video and keyboard functionality by making pretty colors when the
; user presses keys.
;
; Targets the IM800 fantasy CPU and im800emu v0.0.2 PC
;*******************************************************************************

reset_vector:
	.DEFD start
	
start:
	LD SP, stack_top

	; Clear globals
	LD HL, globals
	LD DE, globals + 2
	LD BC, globals.size / 2 - 1
	LD.W [HL], 0
	BLD I, R, WORD

	LD IY, globals                      ; Set global pointer

	; Clear VRAM
	LD HL, 0x00400000
	LD DE, 0x00400002
	LD BC, 1999
	LD.W [HL], 0
	BLD I, R, WORD
	
	; Enable display, cursor
	LD A, 3
	OUT.B [0x01], A
	
	LD I, ivt >> 10                     ; Set interrupt vector table address 
	IM 2                                ; Interrupt mode 2
	EI                                  ; Enable interrupts

	LD A, 1
	OUT.B [0x05], A                     ; Enable keyboard interrupts

	; Set HL to the start of VRAM
	LD HL, 0x00400000

.loop:
	; while(true) {
	;	if (scancode_base == scancode_top) { continue; }
	;	*vram = scancode_buffer[scancode_base];
	;	scancode_base++;
	;	vram++;
	;	if (vram > 0x00400FA0) { vram = 0x00400000; }
	; }

	; Poll keyboard buffer until a scancode is in the queue
	; Queue can safely be read as its written, single producer/consumer
	LD.B A, [IY+globals.scancode_base]  ; Load base
	CP.B A, [IY+globals.scancode_top]   ; Is top == base?
	JR.B Z, .loop                       ; Yes, wait

	LD DE, globals+globals.scancode_buffer ; Point to buffer
	XOR A, A                            ; Clear A to use as index
	LD.B A, [IY+globals.scancode_base]  ; Load scancode base
	LEA DE, A, BYTE                     ; Point to buffer[scancode_base]
	LD.B A, [DE]                        ; Load scancode
	INC.B [IY+globals.scancode_base]    ; Increment base

	LD.B [HL], A                        ; Write scancode to VRAM
	
	; Increment HL by 1 (next scancode will set the attribute)
	INC HL
	; If HL > VRAM, reset it
	CP HL, 0x00400FA0
	JR.B C, .noresethl
	LD HL, 0x00400000
.noresethl:
	JR.B .loop                          ; Repeat forever

empty_ivt:
	EI
	RETI

keyboard_ivt:
	EXA AF
	EXX
	EXI

	LD IY, globals

	; while (true) {
	;   if (scancode_top == scancode_base - 1) {
	;       break;
	;   }
	;   byte scancode = in(0x04);
	;   scancode_buffer[scancode_top] = scancode;
	;   scancode_top++;
	; }

	; TODO: Basic optimization pass, keep things in registers inside loop
.loop:
	LD.B A, [IY+globals.scancode_base]  ; Load base
	DEC.B A                             ; Base - 1
	CP.B A, [IY+globals.scancode_top]   ; Is top == base - 1?
	JR.B Z, .end                        ; Yes, no room, break

	IN.B A, [0x04]                      ; Get scancode from keyboard controller
	TST.B A, A                          ; Is it 0?
	JR.B Z, .end                        ; Yes, empty queue, break

	LD HL, globals+globals.scancode_buffer ; Point to buffer
	XOR B, B                            ; Clear B to use as index
	LD.B B, [IY+globals.scancode_top]   ; Load scancode top
	LEA HL, B, BYTE                     ; Point to buffer[scancode_top]
	LD.B [HL], A                        ; Store scancode
	INC.B [IY+globals.scancode_top]     ; Increment top
	JR.B .loop                          ; Repeat until full or empty

.end:
	EXI
	EXX
	EXA AF
	EI
	RETI

	.ALIGN 1024
ivt:
	.DEFD empty_ivt                     ; 0x00
	.DEFD empty_ivt                     ; 0x01
	.DEFD empty_ivt                     ; 0x02
	.DEFD empty_ivt                     ; 0x03
	.DEFD empty_ivt                     ; 0x04
	.DEFD empty_ivt                     ; 0x05
	.DEFD empty_ivt                     ; 0x06
	.DEFD empty_ivt                     ; 0x07
	.DEFD empty_ivt                     ; 0x08
	.DEFD empty_ivt                     ; 0x09
	.DEFD empty_ivt                     ; 0x0A
	.DEFD empty_ivt                     ; 0x0B
	.DEFD empty_ivt                     ; 0x0C
	.DEFD empty_ivt                     ; 0x0D
	.DEFD empty_ivt                     ; 0x0E
	.DEFD empty_ivt                     ; 0x0F
	.DEFD keyboard_ivt                  ; 0x10 - Keyboard
	; ... The rest that we aren't using for this demo
	
globals: .EQU 0x00200000
	.scancode_top: .EQU 0
	.scancode_base: .EQU .scancode_top + 1
	.scancode_buffer: .EQU .scancode_base + 1
	.size: .EQU .scancode_buffer + 256

stack_top: .EQU globals + globals.size + 256
