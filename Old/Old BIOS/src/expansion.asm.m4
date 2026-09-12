;******************************************************************************
; File: expansion.asm.m4
; Handles expansion slots
;******************************************************************************

;******************************************************************************
; Function: void * get_slot_base(int slot)
; Parameters:
;  A = int slot
; Returns:
;  HL = void *
; Notes:
;  No bounds check, A must be 1-7
;******************************************************************************
get_slot_base:
    LD HL, .table                       ; Load table base
    DEC A                               ; Make 0-indexed
    LEA HL, A, DWORD                    ; Index into table
    LD HL, [HL]                         ; Load address from table
    INC A                               ; Restore original index
    RET

.table:
    .DEFD ex_slots.slot1.base
    .DEFD ex_slots.slot2.base
    .DEFD ex_slots.slot3.base
    .DEFD ex_slots.slot4.base
    .DEFD ex_slots.slot5.base
    .DEFD ex_slots.slot6.base
    .DEFD ex_slots.slot7.base


;******************************************************************************
; Function: void detect_slots(void)
; Parameters:
;  void
; Returns:
;  void
; Notes:
;******************************************************************************
detect_slots:
    LD.B [IY+globals.presence], 0       ; Clear presence bits
    LD A, 1                             ; Start at card 1
.loop:
    CALL get_slot_base                  ; Get base address
    CP.D [HL], ex_header.magic_value    ; = "EXPC"?
    JR.B NZ, .nocard                    ; No, not present
    SET [IY+globals.presence], A        ; Yes, present
.nocard:
    INC A                               ; Next slot
    CP.B A, ex_slots.count + 1          ; Past maximum?
    JR.B C, .loop                       ; No, continue.
    RET


;******************************************************************************
; Function: void check_slots(void)
; Parameters:
;  void
; Returns:
;  void
; Notes:
;******************************************************************************
check_slots:
    LD B, 1                             ; Start at card 1
.loop:
    BIT [IY+globals.presence], B        ; Is card present?
    JR.B Z, .nocard                     ; No, skip
    CALL get_slot_base                  ; Yes, get base address
    LD IX, HL                           ; Move to index pointer
    LEA HL, ex_header.rom_length, BYTE  ; Point to ROM length/start of checked
    LD.D DE, [HL]                       ; Load ROM length in bytes
    SRL DE, 1                           ; /2 to words
    EX HL, DE                           ; HL = count, DE = pointer
    CALL fletcher32                     ; Calculate checksum
    CP.D HL, [IX+ex_header.checksum]    ; Compare calculated to stored checksum
    JR.B Z, .nocard                     ; Equal, continue
    LD HL, IY                           ; HL = global pointer
    LEA HL, globals.init_errors, BYTE   ; Index to init errors array
    LEA HL, B, BYTE                     ; Index to current slot's entry
    LD.B [HL], errors.checksum_failed   ; Write error code
.nocard:
    INC B                               ; Next slot
    CP.B B, ex_slots.count + 1          ; Past maximum?
    JR.B C, .loop                       ; No, continue
    RET


;******************************************************************************
; Function: void init_slots(void)
; Parameters:
;  void
; Returns:
;  void
; Notes:
;******************************************************************************
init_slots:
    LD A, 1                             ; Start at card 1
.loop:
    BIT [IY+globals.presence], A        ; Is card present?
    JR.B Z, .nocard                     ; No, skip
    LD HL, IY                           ; HL = global pointer
    LEA HL, globals.init_errors, BYTE   ; Index to init errors array
    LEA HL, B, BYTE                     ; Index to current slot's entry
    CP.B [HL], errors.ok                ; Is card OK?
    JR.B NZ, .nocard                    ; No, don't run init
    CALL get_slot_base                  ; Yes, get base address
    LD DE, HL                           ; Copy base address
    LEA HL, ex_header.init_offset, BYTE ; Index to init offset
    LD.D HL, [HL]                       ; Load init offset
    ADD DE, HL                          ; Form full address
    PUSH AF                             ; Save count
    CALL DE                             ; Call slot init routine
    POP AF                              ; Restore count
    LD IY, globals.base                 ; Restore global pointer (just in case)
.nocard:
    INC A                               ; Next slot
    CP.B A, ex_slots.count + 1          ; Past maximum?
    JR.B C, .loop                       ; No, continue
    RET


;******************************************************************************
; Function: void shutdown_slots(void)
; Parameters:
;  void
; Returns:
;  void
; Notes:
;******************************************************************************
shutdown_slots:
    LD A, 1                             ; Start at card 1
.loop:
    BIT [IY+globals.presence], A        ; Is card present?
    JR.B Z, .nocard                     ; No, skip
    LD HL, IY                           ; HL = global pointer
    LEA HL, globals.init_errors, BYTE   ; Index to init errors array
    LEA HL, B, BYTE                     ; Index to current slot's entry
    CP.B [HL], errors.ok                ; Is card OK?
    JR.B NZ, .nocard                    ; No, don't run shutdown
    CALL get_slot_base                  ; Yes, get base address
    LD DE, HL                           ; Copy base address
    LEA HL, ex_header.shutdown_offset, BYTE ; Index
    LD.D HL, [HL]                       ; Load shutdown offset
    ADD DE, HL                          ; Form full address
    PUSH AF                             ; Save count
    CALL DE                             ; Call slot shutdown routine
    POP AF                              ; Restore count
    LD IY, globals.base                 ; Restore global pointer (just in case)
.nocard:
    INC A                               ; Next slot
    CP.B A, ex_slots.count + 1          ; Past maximum?
    JR.B C, .loop                       ; No, continue
    RET
