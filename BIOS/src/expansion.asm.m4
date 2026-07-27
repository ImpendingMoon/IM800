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
    LD A, 1                             ; Start at card 1
.loop:
    CALL get_slot_base                  ; Get base address
    CP.D [HL], ex_header.magic_value    ; = "EXPC"?
    JR.B NZ, .nocard                    ; No, not present
    SET [IY+global.presence], A         ; Yes, present
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
    ; TODO
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
    BIT [IY+global.presence], A         ; Is card present?
    JR.B Z, .nocard                     ; No, skip
    CALL get_slot_base                  ; Yes, get base address
    LD DE, HL                           ; Copy base address
    LEA HL, ex_header.init_offset, BYTE ; Index to init offset
    LD.D HL, [HL]                       ; Load init offset
    ADD DE, HL                          ; Form full address
    PUSH AF                             ; Save count
    CALL DE                             ; Call slot init routine
    POP AF                              ; Restore count
    LD IY, global.base                  ; Restore global pointer (just in case)
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
    BIT [IY+global.presence], A         ; Is card present?
    JR.B Z, .nocard                     ; No, skip
    CALL get_slot_base                  ; Yes, get base address
    LD DE, HL                           ; Copy base address
    LEA HL, ex_header.shutdown_offset, BYTE ; Index
    LD.D HL, [HL]                       ; Load shutdown offset
    ADD DE, HL                          ; Form full address
    PUSH AF                             ; Save count
    CALL DE                             ; Call slot shutdown routine
    POP AF                              ; Restore count
    LD IY, global.base                  ; Restore global pointer (just in case)
.nocard:
    INC A                               ; Next slot
    CP.B A, ex_slots.count + 1          ; Past maximum?
    JR.B C, .loop                       ; No, continue
    RET
