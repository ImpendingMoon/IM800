;*******************************************************************************
; Test.asm
; Tests converting keyboard scancodes into ASCII text 
;*******************************************************************************

reset_vector:
	.DEFD start
	
start:
	; Set global pointer
	LD IY, global

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
	CALL getkey
	
	JR.B .loop



;*******************************************************************************
; Waits for a full key event and returns it
;*******************************************************************************
getkey:
	PUSH BC
	PUSH DE
	PUSH HL
	
.loop:
	XOR A, A			; Clear A
.waitforscancode:
	IN.B A, [0x04]			; Load from keyboard queue 
	JAZ .waitforscancode		; Repeat until non-zero
	
	CP.B [IY+global.extended_step], 0 ; In extended scancode?
	JR.B NZ, .getextendedkey	; Yes, continue handling that

	CP.B [IY+global.pause_step], 0	; In pause scancode?
	JR.B NZ, .getpausekey		; Yes, continue handling that

	CP.B A, 0xE0			; Extended scancode start?
	JR.B NZ, .noextended		; No, skip
	INC.B [IY+global.extended_step] ; Set extended step
	JR.B .loop			; Get next scancode
	
.noextended:
	CP.B A, 0xE1			; Pause scancode start?
	JR.B NZ, .nopause		; No, skip
	INC.B [IY+global.pause_step]	; Set pause step
	JR.B .loop			; Get next scancode
	
.nopause:
	XOR B, B			; Clear B, used for break temp
	TST.B A, 0x80			; Break bit set?
	JR.B NZ, .nobreak		; No, skip
	INC B				; Yes, mark as set for later
.nobreak:

	LD HL, sc_to_kc_map		; Load pointer to conversion table
	LEA HL, A, BYTE			; Index into it
	LD.B H, [HL]			; Load keycode
	AND.B H, 0x00FF			; Clear leftover upper byte
					; Fallthrough to create keyevent
; Private subroutine:
; H = keycode
; B = break?
.create_keyevent:
	XOR HL, HL			; Clear HL for key event struct
	LD.B L, [IY.global.keyflags]	; Load current flag state
	TST.B B, B			; Is break?
	JR.B Z, .event_nobreak		; No, skip
	OR.B L, keyflags.break		; Yes, set flag
.event_nobreak:
	EXH L				; Move keyflag to upper byte of L
	LD DE, kc_to_char_map		; Load pointer to conversion table
	LEA DE, H, BYTE			; 
					; Fallthrough to end
.end:
	POP HL
	POP DE
	POP BC
	RET

.getextendedkey:

	RET

.getpausekey:
	RET

;*******************************************************************************
; Global variables
;*******************************************************************************
	.ORG 0x00200000
global:
.keyflags: .EQU global + 0		; State of ctrl, shift, alt, locks
.extended_step: .EQU .keyflags + 1	; What byte of extended/print next?
.pause_step: .EQU .extended_step + 1	; What byte of pause scancode next?

;*******************************************************************************
; Key Event struct
;*******************************************************************************
keyevent: .EQU 0
.character: .EQU 0
.flags: .EQU 1
.keycode: .EQU 2
._size: .EQU 4

;*******************************************************************************
; Key Event Flag bitmask
;*******************************************************************************
keyflag: .EQU 0
.shift: .EQU 0x01
.ctrl: .EQU 0x02
.alt: .EQU 0x04
.caps_lock: .EQU 0x08
.num_lock: .EQU 0x10
.scroll_lock: .EQU 0x20
.break: .EQU 0x80

;*******************************************************************************
; Keycode enum
; Maps printable characters to ASCII (lowercase)
; Maps non-printable keys around free space
;*******************************************************************************
keycodes: .EQU 0
.null: .EQU 0

; Printable ASCII set
.apostrophe: .EQU 39
.comma: .EQU 44
.minus: .EQU 45
.period: .EQU 46
.slash: .EQU 47
.num_0: .EQU 48
.num_1: .EQU 49
.num_2: .EQU 50
.num_3: .EQU 51
.num_4: .EQU 52
.num_5: .EQU 53
.num_6: .EQU 54
.num_7: .EQU 55
.num_8: .EQU 56
.num_9: .EQU 57
.semicolon: .EQU 59
.less_than: .EQU 60
.equal: .EQU 61
.greater_than: .EQU 62
.left_bracket: .EQU 91
.backslash: .EQU 92
.right_bracket: .EQU 93
.grave: .EQU 96
.a: .EQU 97
.b: .EQU 98
.c: .EQU 99
.d: .EQU 100
.e: .EQU 101
.f: .EQU 102
.g: .EQU 103
.h: .EQU 104
.i: .EQU 105
.j: .EQU 106
.k: .EQU 107
.l: .EQU 108
.m: .EQU 109
.n: .EQU 110
.o: .EQU 111
.p: .EQU 112
.q: .EQU 113
.r: .EQU 114
.s: .EQU 115
.t: .EQU 116
.u: .EQU 117
.v: .EQU 118
.w; .EQU 119
.x: .EQU 120
.y: .EQU 121
.z; .EQU 122

; ASCII control set
.backspace: .EQU 8
.tab: .EQU 9
.enter: .EQU 10
.delete: .EQU 127

; Other keys, fit in around ASCII keys
.escape: .EQU 1
.f1: .EQU 2
.f2: .EQU 3
.f3: .EQU 4
.f4: .EQU 5
.f5: .EQU 6
.f6: .EQU 7
.f7: .EQU 8
.f8: .EQU 9
.f9: .EQU 10
.f10: .EQU 11
.f11: .EQU 12
.f12: .EQU 13
.print: .EQU 14
.pause: .EQU 15
.insert: .EQU 16
.delete: .EQU 17
.home: .EQU 18
.end: .EQU 19
.page_up: .EQU 20
.page_down: .EQU 21
.arrow_up: .EQU 22
.arrow_down: .EQU 23
.arrow_left: .EQU 24
.arrow_right: .EQU 25
.np_slash: .EQU 26
.np_asterisk: .EQU 27 
.np_minus: .EQU 28
.np_plus: .EQU 29
.np_enter: .EQU 30
.np_0: .EQU 31
.np_1: .EQU 32
.np_2: .EQU 33
.np_3: .EQU 34
.np_4: .EQU 35
.np_5: .EQU 36
.np_6: .EQU 37
.np_7: .EQU 38
.np_8: .EQU 40
.np_9: .EQU 41
.caps_lock: .EQU 42
.num_lock: .EQU 43
.scroll_lock: .EQU 58
.shift: .EQU 63
.ctrl: .EQU 64
.alt: .EQU 65
.right_shift: .EQU 66
.right_ctrl: .EQU 67
.right_alt: .EQU 68

