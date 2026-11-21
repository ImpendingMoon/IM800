;*******************************************************************************
; test.asm
; Tests converting scancodes into keycodes, and printing them as ASCII
; Note: This is currently broken. :(
;*******************************************************************************

reset_vector:
    .DEFD start

start:
    BKPT 0
    LD SP, stack_top
    LD IY, gp

.clear_mem:
    LD HL, gp                           ; Clear global data with LDIR trick
    LD DE, gp+2
    LD.W [HL], 0                        ; Seed 0
    LD BC, gp.size / 2 - 1              ; /2 for word size, -1 for seed 0
    BLD I, R, WORD                      ; Maybe add a FILL instruction?

    LD HL, vram                         ; Same trick to fill VRAM with 0
    LD DE, vram+2
    LD.W [HL], 0
    LD BC, vram.size / 2 - 1
    BLD I, R, WORD

.setup_devices:
    XOR A, A                            ; Constant 0
    OUT.B [ports.vdp_cur_col], A        ; Reset cursor column
    OUT.B [ports.vdp_cur_row], A        ; Reset cursor row

    LD A, flags.vdp_state_display | flags.vdp_state_cursor
    OUT.B [ports.vdp_state], A          ; Enable video and cursor

    LD I, ivt >> 10                     ; Load interrupt vector table base
    IM 2                                ; Interrupt Mode 2
    EI                                  ; Enable interrupts

    LD A, flags.kbd_state_int           ; Enable keyboard interrupts
    OUT.B [ports.kbd_state], A

    LD HL, vram                         ; Point to VRAM for printing
.loop:
    PUSH HL                             ; Save VRAM pointer
    CALL get_key                        ; Returns KeyEvent in A
    CALL get_ascii                      ; Returns char in A
    POP HL                              ; Restore VRAM pointer
    TST.B A, A                          ; Returned '\0'?
    JR.B Z, .loop                       ; Yes, continue.
    EXH A                               ; No, swap A.l/A.h to load attribute
    LD.B A, 0x07                        ; Attribute gray on black
    EXH A                               ; Swap it back
    LD [HL], A                          ; Write character to screen
    INC HL                              ; Increment pointer
    INC HL
    CP HL, vram+vram.size               ; In bounds?
    JR.B C, .no_wrap                    ; Yes, don't wrap
    LD HL, vram                         ; No, wrap back to start
.no_wrap:
    JR.B .loop                          ; Loop forever

.hadcf:                                 ; Halt and Don't Catch Fire
    HALT                                ; Because HALT is a low-power state
    JR.W .hadcf                         ; :)



;*******************************************************************************
; FUNCTION: byte get_scancode(void)
; Gets the next scancode from the keyboard driver. Blocks until one is available
;
; Parameters: N/A
; Returns:
; - A: (byte) Scancode
;*******************************************************************************
get_scancode:
    PUSH BC
    
    XOR C, C                            ; Clear C for indexing
.loop:
    DI
    LD.B B, [IY+gp.sc_buf_w]            ; B = write index
    LD.B C, [IY+gp.sc_buf_r]            ; C = read index
    CP.B B, C                           ; B == C (buffer empty)?
    JR.W NZ, .read                      ; No, read the next scancode
    EI
    HALT                                ; Yes, wait for interrupt
    JR.W .loop                          ; Try again

.read:
    LD HL, gp + gp.sc_buf               ; Load base pointer
    LEA HL, C, BYTE                     ; sc_buf[sc_buf_r]
    LD.B A, [HL]                        ; Load scancode into A.lo

    INC.B [IY+gp.sc_buf_r]              ; Increment read index

    POP BC
    RET



;*******************************************************************************
; FUNCTION: (byte, bool) get_keycode(void)
; Converts the next scancode(s) into a keycode. Blocks until one is available.
;
; Parameters: N/A
; Returns:
; - A: (byte) Scancode
; - L: (bool) Released
;*******************************************************************************
get_keycode:
    PUSH IX
    LD IX, SP
    SUB SP, .frame_size

    PUSH BC

    LD.B [IX-.extended_step], 0
    LD.B [IX-.pause_step], 0
    LD.B [IX-.keycode], 0
    LD.B [IX-.released], 0

.loop:
    CR get_scancode                     ; A = scancode
    XOR B, B                            ; Clear for later LEA
    LD.B B, [IX-.extended_step]         ; Load current extended step
    TST.B B, B                          ; Processing an extended scancode?
    JR.W Z, .check_in_pause             ; No, check for pause scancode
.handle_extended:                       ; Yes, handle extended scancode
    TST.B A, break_bit                  ; Is break bit set?
    JR.W Z, .ex_not_break               ; No, skip
    AND.B A, ~(break_bit) & 0xFF        ; Yes, clear the scancode bit
    LD.B [IX-.released], 1              ; Set released flag
.ex_not_break:
    XOR B, B                            ; Index counter
.ex_search_loop:
    CP B, ext_sc_to_kc.size / 2         ; In bounds?
    JR.W NC, .ex_search_not_found       ; No, scancode not found
    LD HL, ext_sc_to_kc                 ; Base pointer to linear search table
    LEA HL, B, WORD                     ; (scancode, keycode) ext_sc_to_kc[B]
    INC B                               ; B++
    CP.B A, [HL]                        ; Scancodes equal?
    JR.W NZ, .ex_search_loop            ; No, check next
.ex_search_found:
    INC HL                              ; Yes, point to keycode
    LD.B A, [HL]                        ; Load keycode from table
    LD.B [IX-.keycode], A               ; Store keycode
    JR.W .end                           ; End

.ex_search_not_found:
    LD.B [IX-.keycode], Keycode.null    ; Invalid keycode
    JR.W .end                           ; Skip to end

.check_in_pause:
    LD.B B, [IX-.pause_step]            ; Load current pause step
    TST.B B, B                          ; Processing a pause scancode?
    JR.W Z, .handle_normal              ; No, handle normally
.handle_pause:                          ; Yes, handle pause sequence
    LD HL, pause_sequence               ; Base pointer to search table
    LEA HL, B, BYTE                     ; pause_sequence[pause_step]
    LD.B C, [HL]                        ; Load expected byte
    CP.B A, C                           ; Match?
    JR.W NZ, .bad_pause                 ; No, bad sequence
    CP.B B, pause_sequence.size - 1     ; At the end of the sequence?
    JR.W NC, .pause_found               ; Yes, set keycode
    INC.B [IX-.pause_step]              ; No, increment step
    JR.W .loop                          ; Go again
.pause_found:
    LD.B [IX-.keycode], Keycode.pause   ; Yes, set keycode
    JR.W .end                           ; End
.bad_pause:
    LD.B [IX-.pause_step], 0            ; Clear pause step
    JR.W .handle_normal                 ; Retry processing

.handle_normal:
    CP.B A, ex_scancode                 ; Extended scancode?
    JR.W NZ, .not_extended              ; No, skip
    LD.B [IX-.extended_step], 1         ; Set extended step flag
    JR.W .loop                          ; Go again

.not_extended:
    CP.B A, pause_scancode              ; Start of pause scancode sequence?
    JR.W NZ, .not_pause                 ; No, skip
    LD.B [IX-.pause_step], 1            ; Set pause step counter
    JR.W .loop                          ; Go again

.not_pause:
    TST.B A, break_bit                  ; Is break bit set?
    JR.W Z, .not_break                  ; No, skip
    AND.B A, ~(break_bit) & 0xFF        ; Yes, clear the scancode bit
    LD.B [IX-.released], 1              ; Set released flag
.not_break:
    CP.B A, sc_to_kc.size               ; In bounds?
    JR.W C, .lookup                     ; Yes, index into table
    LD.B [IX-.keycode], Keycode.null    ; No, invalid keycode
    JR.W .end                           ; Skip to end
.lookup:
    LD BC, sc_to_kc                     ; Base pointer
    AND A, 0x00FF                       ; Clear high byte of A
    LEA BC, A, BYTE                     ; Index to sc_to_kc[scancode]
    LD.B A, [BC]                        ; Load keycode
    LD.B [IX-.keycode], A               ; Store scancode

.end:
    POP BC

    LD.B A, [IX-.keycode]               ; Move scancode to return register
    LD.B L, [IX-.released]              ; Move released to return register

    LD SP, IX
    POP IX
    RET

.extended_step: .EQU 1
.pause_step: .EQU .extended_step + 1
.keycode: .EQU .pause_step + 1
.released: .EQU .keycode + 1
.frame_size: .EQU .released + 1



;*******************************************************************************
; FUNCTION: byte update_keyflags(byte, bool)
; Updates keyflags based on the given keycode. This should called for every
; keycode in order of arrival.
;
; Parameters:
; - A: (byte) Scancode
; - L: (bool) Released
; Returns:
; - A: (byte) Truncated KeyEvent flags
;*******************************************************************************
update_keyflags:
    LD.W H, [IY+gp.keyflags]            ; Load current keyflags
    TST.B L, L                          ; Released?
    JR.W Z, .no_release                 ; No, skip

    OR.B H, KeyFlag.release             ; Set release flag

    CP.B A, Keycode.lshift              ; Is modifier key?
    JR.W NZ, .1                         ; No, go to next check
    AND.W H, ~KeyFlag.lshift            ; Yes, clear flag
    JR.W .calculate_combined            ; Break
.1:
    CP.B A, Keycode.rshift              ; Is a modifier key?
    JR.W NZ, .2                         ; No, go to next check
    AND.W H, ~KeyFlag.rshift            ; Yes, clear flag
    JR.W .calculate_combined            ; Break
.2:
    CP.B A, Keycode.lctrl               ; Is a modifier key?
    JR.W NZ, .3                         ; No, go to next check
    AND.W H, ~KeyFlag.lctrl             ; Yes, clear flag
    JR.W .calculate_combined            ; Break
.3:
    CP.B A, Keycode.rctrl               ; Is a modifier key?
    JR.W NZ, .4                         ; No, go to next check
    AND.W H, ~KeyFlag.rctrl             ; Yes, clear flag
    JR.W .calculate_combined            ; Break
.4:
    CP.B A, Keycode.lalt                ; Is a modifier key?
    JR.W NZ, .5                         ; No, go to next check
    AND.W H, ~KeyFlag.lalt              ; Yes, clear flag
    JR.W .calculate_combined            ; Break
.5:
    CP.B A, Keycode.ralt                ; Is a modifier key?
    JR.W NZ, .calculate_combined        ; No, go to next check
    AND.W H, ~KeyFlag.ralt              ; Yes, clear flag
    JR.W .calculate_combined            ; Break

.no_release:
    AND.B H, ~(KeyFlag.release) & 0xFF  ; Clear release flag

    CP.B A, Keycode.lshift              ; Is modifier key?
    JR.W NZ, .6                         ; No, go to next check
    OR.W H, KeyFlag.lshift              ; Yes, set flag
    JR.W .calculate_combined            ; Break
.6:
    CP.B A, Keycode.rshift              ; Is modifier key?
    JR.W NZ, .7                         ; No, go to next check
    OR.W H, KeyFlag.rshift              ; Yes, set flag
    JR.W .calculate_combined            ; Break
.7:
    CP.B A, Keycode.lctrl               ; Is modifier key?
    JR.W NZ, .8                         ; No, go to next check
    OR.W H, KeyFlag.lctrl               ; Yes, set flag
    JR.W .calculate_combined            ; Break
.8:
    CP.B A, Keycode.rctrl               ; Is modifier key?
    JR.W NZ, .9                         ; No, go to next check
    OR.W H, KeyFlag.rctrl               ; Yes, set flag
    JR.W .calculate_combined            ; Break
.9:
    CP.B A, Keycode.lalt                ; Is modifier key?
    JR.W NZ, .10                        ; No, go to next check
    OR.W H, KeyFlag.lalt                ; Yes, set flag
    JR.W .calculate_combined            ; Break
.10:
    CP.B A, Keycode.ralt                ; Is modifier key?
    JR.W NZ, .11                        ; No, go to next check
    OR.W H, KeyFlag.ralt                ; Yes, set flag
    JR.W .calculate_combined            ; Break
.11:
    CP.B A, Keycode.caps_lock           ; Is lock key?
    JR.W NZ, .12                        ; No, go to next check
    XOR.W H, KeyFlag.caps               ; Yes, toggle flag
    JR.W .calculate_combined            ; Break
.12:
    CP.B A, Keycode.num_lock            ; Is lock key?
    JR.W NZ, .13                        ; No, go to next check
    XOR.W H, KeyFlag.num                ; Yes, toggle flag
    JR.W .calculate_combined            ; Break
.13:
    CP.B A, Keycode.scroll_lock         ; Is lock key?
    JR.W NZ, .calculate_combined        ; No, break
    XOR.W H, KeyFlag.scroll             ; Yes, toggle flag

.calculate_combined:
    ; Clear combined keyflags
    AND.B H, ~(KeyFlag.shift | KeyFlag.ctrl | KeyFlag.alt)

    ; Is left shift or right shift pressed?
    TST.W H, KeyFlag.lshift | KeyFlag.rshift
    JR.B Z, .14                         ; No, next check
    OR.B H, KeyFlag.shift               ; Yes, set flag
.14:
    ; Is left ctrl or right ctrl pressed?
    TST.W H, KeyFlag.lctrl | KeyFlag.rctrl
    JR.B Z, .15                         ; No, next check
    OR.B H, KeyFlag.ctrl                ; Yes, set flag
.15:
    ; Is left alt or right alt pressed?
    TST.W H, KeyFlag.lalt | KeyFlag.ralt
    JR.B Z, .16                         ; No, return
    OR.B H, KeyFlag.alt                 ; Yes, set flag
.16:
    LD.W [IY+gp.keyflags], H            ; Save updated keyflags
    LD.B A, H                           ; Move KeyEvent flag subset to A
    RET



;*******************************************************************************
; FUNCTION: KeyEvent get_key()
; Parses and returns the next key event. Blocks until available.
;
; Parameters: N/A
; Returns:
; - A: (Word) KeyEvent
;   - A.h: KeyFlags
;   - A.l: Keycode
;*******************************************************************************
get_key:
    CALL get_keycode                    ; Get the next keycode
    CP.B A, Keycode.null                ; Is null? (failed to parse)
    JR.B Z, get_key                     ; Yes, retry
    PUSH AF                             ; No, save keycode
    CALL update_keyflags                ; Update keyflags, returned in A.l
    EXH A                               ; Move flags to A.h
    POP HL                              ; Pop keycode to HL
    LD.B A, H                           ; Move keycode to A.l
    RET

;*******************************************************************************
; FUNCTION: bool is_caps_kc
; Returns whether a keycode is affected by Caps Lock
;
; Parameters:
; - A: (Byte) Keycode
; Returns:
; - F: (Carry) Set if affected, cleared if not
;*******************************************************************************
is_caps_kc:
    ; Q-P, A-L, Z-M are sequential
    CP.B A, Keycode.k_q - 1             ; >= Q?
    JR.B C, .1                          ; No, next check
    CP.B A, Keycode.k_p + 1             ; <= P?
    RET C                               ; Yes, return with carry set
.1:
    CP.B A, Keycode.k_a - 1             ; >= A?
    JR.B C, .2                          ; No, next check
    CP.B A, Keycode.k_l + 1             ; <= L?
    RET C                               ; Yes, return with carry set
.2:
    CP.B A, Keycode.k_z - 1             ; >= Z?
    JR.B C, .3                          ; No, next check
    CP.B A, Keycode.k_m + 1             ; <= M?
    RET C                               ; Yes, return with carry set
.3:
    TST.B A, A                          ; Clear carry
    RET

;*******************************************************************************
; FUNCTION: bool is_num_kc
; Returns whether a keycode is affected by Num Lock
;
; Parameters:
; - A: (Byte) Keycode
; Returns:
; - F: (Carry) Set if affected, cleared if not
;*******************************************************************************
is_num_kc:
    ; 0-9 are sequential
    CP.B A, Keycode.kp_0 - 1            ; >= 0?
    JR.B C, .clear_carry                ; No, clear carry
    CP.B A, Keycode.kp_9 + 1            ; <= 9?
    RET C                               ; Yes, return with carry set
    CP.B A, Keycode.kp_period           ; == .?
    JR.B Z, .set_carry                  ; Yes, affected
.clear_carry:
    TST.B A, A                          ; No, clear carry
    RET
.set_carry:
    SCF
    RET

;*******************************************************************************
; FUNCTION: char get_ascii(KeyEvent)
; Converts a KeyEvent to an ASCII character. Returns 0 if non-printable or a
; release event.
;
; Parameters:
; - A: (Word) KeyEvent
; Returns:
; - A: (Byte) Character
;*******************************************************************************
get_ascii:
    TST A, (KeyFlag.release | KeyFlag.ctrl) << 8 ; Is control or release event?
    JR.B NZ, .non_printable             ; Yes, return 0

    TST A, KeyFlag.shift << 8           ; Shift pressed?
    JR.B NZ, .shift_pressed             ; Yes, use shifted keyset
    TST A, KeyFlag.caps << 8            ; No, is caps lock enabled?
    JR.B Z, .no_caps                    ; No, other key
    CALL is_caps_kc                     ; Yes, is this kc modified by caps?
    JR.B C, .load_shifted               ; Yes, load shifted char
.no_caps:
    TST A, KeyFlag.num << 8             ; Is num lock enabled?
    JR.B Z, .load_regular               ; No, regular key
    CALL is_num_kc                      ; Yes, is this kc modified by num?
    JR.B C, .load_shifted               ; Yes, load shifted char
.load_regular:
    AND A, 0x00FF                       ; Clear high byte of A for lookup
    CP.B A, kc_to_ascii.size            ; In bounds?
    JR.B NC, .non_printable             ; No, return 0
    LD HL, kc_to_ascii                  ; Yes, load table base pointer
    LEA HL, A, BYTE                     ; kc_to_ascii[keycode]
    LD.B A, [HL]                        ; Load char from table
    RET

.shift_pressed:
    TST A, KeyFlag.caps << 8            ; No, is caps lock enabled?
    JR.B Z, .shift_no_caps              ; No, other key
    CALL is_caps_kc                     ; Yes, is this kc modified by caps?
    JR.B C, .load_regular               ; Yes, load regular char
.shift_no_caps:
    TST A, KeyFlag.num << 8             ; Is num lock enabled?
    JR.B Z, .load_shifted               ; No, shifted key
    CALL is_num_kc                      ; Yes, is this kc modified by num?
    JR.B C, .load_regular               ; Yes, load regular char
.load_shifted:
    AND A, 0x00FF                       ; Clear high byte of A for lookup
    CP.B A, kc_to_shift_ascii.size      ; In bounds?
    JR.B NC, .non_printable             ; No, return 0
    LD HL, kc_to_shift_ascii            ; Yes, load table base pointer
    LEA HL, A, BYTE                     ; kc_to_ascii[keycode]
    LD.B A, [HL]                        ; Load char from table
    RET

.non_printable:
    XOR A, A
    RET

%include "tables.asm"
%include "ivt.asm"
%include "constants.asm"
