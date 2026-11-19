;*******************************************************************************
; test.asm
; Tests converting scancodes into keycodes, and printing them as ASCII
;*******************************************************************************

reset_vector:
    .DEFD start

start:
    LD SP, stack_top
    LD IY, gp

.clear_mem:
    XOR A, A                            ; Constant 0

    LD HL, gp                           ; Clear global data with LDIR trick
    LD DE, gp+1
    LD.W [HL], A                        ; Seed 0
    LD BC, gp.size / 2 - 1              ; /2 for word size, -1 for seed 0
    BLD I, R, WORD                      ; Maybe add a FILL instruction?

    LD HL, vram                         ; Same trick to fill VRAM with 0
    LD DE, vram+1
    LD.W [HL], A
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

.loop:
    ; TODO:
    ; while(true)
    ;   GetKeycode
    ;   KeycodeToAscii
    ;   Putc

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
    
    XOR B, B                            ; Clear B for indexing
.loop:
    LD.B B, [IY+gp.sc_buf_w]            ; B = write index
    LD.B C, [IY+gp.sc_buf_r]            ; C = read index
    CP.B B, C                           ; B == C (buffer empty)?
    JR.W NZ, .read                      ; No, read the next scancode
    HALT                                ; Yes, wait for interrupt
    JR.W .loop                          ; Try again

.read:
    LD BC, gp + gp.sc_buf               ; Load base pointer
    LEA BC, B, BYTE                     ; Index into it
    LD.B A, [BC]                        ; Load scancode into A.lo

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
    PUSH HL

    LD.B [IX-.extended_step], 0
    LD.B [IX-.pause_step], 0
    LD.B [IX-.keycode], 0
    LD.B [IX-.released], 0

.loop:
    CR get_scancode                     ; A = scancode

    LD.B B, [IX-.extended_step]         ; Load current extended step
    TST.B B, B                          ; Processing an extended scancode?
    JR.W Z, .check_in_pause             ; No, check for pause scancode
.handle_extended:                       ; Yes, handle extended scancode
    TST.B A, break_bit                  ; Is break bit set?
    JR.W NZ, .ex_not_break              ; No, skip
    AND.B A, ~(break_bit) & 0xFF        ; Yes, clear the scancode bit
    LD.B [IX-.released], 1              ; Set released flag
.ex_not_break:
    XOR B, B                            ; Index counter
.ex_search_loop:
    CP B, ext_sc_to_kc.size             ; In bounds?
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
    CP.B B, pause_sequence.size         ; At the end of the sequence?
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
    LEA BC, A, BYTE                     ; Index to sc_to_kc[scancode]
    LD.B A, [BC]                        ; Load keycode
    LD.B [IX-.keycode], A               ; Store scancode

.end:
    POP HL
    POP BC

    LD.B A, [IX-.keycode]              ; Move scancode to return register
    LD.B L, [IX-.released]             ; Move released to return register

    LD SP, IX
    POP IX
    RET

.extended_step: .EQU 0
.pause_step: .EQU .extended_step + 1
.keycode: .EQU .pause_step + 1
.released: .EQU .keycode + 1
.frame_size: .EQU .released + 1

%include "tables.asm"
%include "ivt.asm"
%include "constants.asm"
