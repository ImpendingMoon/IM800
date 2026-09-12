;*******************************************************************************
; File: functions.asm
; Internal functions
;*******************************************************************************

;******************************************************************************
; Function: void discover_expansion_devices()
;  Discovers and initializes expansion devices. Sets global exp_presence and
;  exp_error bitmaps.
; Parameters:
;  void
; Returns:
;  void
; Notes:
;******************************************************************************
discover_expansion_devices:
    LD HL, str_exp_intro                ; Print a start message
    CR puts
    XOR A, A                            ; Clear presence and error bitfields
    LD.B [IY+gp.exp_presence], A
    LD.B [IY+gp.exp_error], A
    INC A                               ; Slot bit no., starts at 1
    LD IX, mem.exp_base                 ; Point to first slot
.loop:
    CP.D [IX+exp_header.magic], exp.magic_value
    JR.B NZ, .iterate                   ; No signature, no device
    LD DE, IX                           ; Checksum base address
    ADD DE, 8                           ; Start at +8 (after check value)
    LD.D HL, [IX+exp_header.length]     ; Load ROM length
    CP HL, exp.stride                   ; Is the size past bounds?
    JR.B NC, .error                     ; Yes, bad header
    SUB HL, 8                           ; Subtract 8 (from previous +8)
    SRL HL, 1                           ; Shift right to make into word count
    EXA A                               ; Save slot bit number
    CR fletcher32                       ; Calculate checksum
    CP.D [IX+exp_header.checksum], HL   ; Do checksums match?
    EXA A                               ; Restore slot bit number
    JR.B NZ, .error                     ; No, error
    SET.B [IY+gp.exp_presence], A       ; Set presence bit
    CP.D [IX+exp_header.init_offset], 0 ; Is there an init offset?
    JR.B Z, .iterate                    ; No, continue
    LD HL, IX                           ; Calculate address of init offset
    ADD HL, [IX+exp_header.init_offset] ; HL = full address of init routine
    PUSH AF                             ; Save slot bit number
    PUSH IX                             ; Save slot address
    CALL HL                             ; Call init routine (slot no. in A)
    POP IX                              ; Restore slot address
    POP AF                              ; Restore slot bit number
    LD IY, mem.gp_base                  ; Restore global pointer
    LD HL, str_exp_found                ; Print success message
    CR.B .putmessage
.iterate:
    CP.B A, exp.max_slots               ; At the end?
    RET NC                              ; Yes, return
    INC A                               ; Next bit
    ADD IX, exp.stride                  ; Point to next slot
    JR.B .loop
.error:
    SET.B [IY+gp.exp_error], A          ; Set error bit
    LD HL, str_exp_badcheck             ; Print error message
    CR.B .putmessage
    JR.B .iterate
.putmessage:
    PUSH BC
    LD B, A
    CR puts
    LD A, B
    ADD.B A, '0'
    CR putc
    LD.B A, '\n'
    CR putc
    LD B, A
    POP BC
    RET



;******************************************************************************
; Function: unsigned long fletcher32(int *data, size_t count)
;  Calculates the Fletcher-32 checksum of a block of data
; Parameters:
;  HL = size_t count
;    - Number of 16-bit words to check
;  DE = int *data
;    - Base pointer of data
; Returns:
;  HL = unsigned long
;    - Checksum
; Notes:
;******************************************************************************
fletcher32:
    PUSH BC
    PUSH DE
    XOR BC, BC                          ; C = Partial sum 1, B = Partial sum 2
    XOR A, A                            ; Constant 0
.check_loop:
    ADD.W C, [DE]                       ; sum1 += *data
    ADC C, A                            ; sum1 += Carry
    ADD B, C                            ; sum2 += sum1
    ADC B, A                            ; sum2 += Carry
    INC DE                              ; Pointer++
    INC DE
    DEC HL                              ; Count--
    JR.B NZ, .check_loop                ; If not zero, continue
    DEC A                               ; A = 65535 for normalizing -1 to 0
    CP C, A                             ; sum1 == 65535?
    JR.B NZ, .nocorrect1                ; No, nothing to do
    INC C                               ; Yes, adjust to 0
.nocorrect1:
    CP B, A                             ; sum2 == 65535?
    JR.B NZ, .nocorrect2                ; No, nothing to do
    INC B                               ; Yes, adjust to 0
.nocorrect2:
    LD HL, BC                           ; Copy checksum to return value
    POP DE
    POP BC
    RET
