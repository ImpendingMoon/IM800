;******************************************************************************
; File: main.m4
; The entrypoint for the IM800 BIOS
;******************************************************************************

start:
    ; TODO: Check BIOS checksum
    ; TODO: Check BIOS RAM

    LD SP, stack_top                    ; Load stack pointer
    LD IY, global_base                  ; Load global base

    ; Set up IVT
    LD DE, ivt_start
    LD HL, rom_ivt
    LD BC, ivt_length / 2
    BLD I, R, WORD

    ; TODO: Initialize integrated devices

    ; Scan expansion slots
find_expansion_cards:
    LD.B [IY+slot_presence], 0          ; Clear presence bitmap
    LD HL, slot1_start                  ; Start
    LD B, 1                             ; Start at slot/bit 1
.loop:
    CP.D [HL], slot_magic               ; Magic number at start?
    JR.B NZ, .nocard                    ; No, skip
    SET [IY+slot_presence], B           ; Yes, set presence bit
.nocard:
    INC B                               ; Increment slot
    ADD HL, slot_difference             ; Increment slot pointer
    CP.B B, 8                           ; Past final slot?
    JR.B C, .loop                       ; No, continue

    ; TODO: Check each card's checksum
    ; TODO: Check system RAM
    ; TODO: Check disks for bootable disk
    ; TODO: If bootable disk found, load block 1 into 0x20000 and jump
    ; TODO: Else, load built-in shell

    ; TODO: TEMP
    BKPT 0


run_expansion_init:
    LD IX, slot1_start                  ; Start at card
    LD A, 1                             ; Start at slot/bit 1
.loop:
    BIT.B [IY+slot_presence], A         ; Is card present? 
    JR.B Z, .nocard                     ; No, skip
    LD.D DE, [IX+16]                    ; Yes, load init routine offset
    LD HL, IX                           ; Load current slot memory start
    ADD HL, DE                          ; Add offset to get full init vector
    PUSH AF                             ; Save slot iterator
    PUSH IX                             ; Save offset
    PUSH IY                             ; Save global pointer
    CALL HL                             ; Call init routine
    POP IY                              ; Restore global pointer
    POP IX                              ; Restore offset
    POP AF                              ; Restore slot iterator
.nocard:
    INC A                               ; Increment slot
    ADD IX, slot_difference             ; Increment slot pointer
    CP.B A, 8                           ; Past final slot?
    JR.B C, .loop                       ; No, continue

memory_parity_error_handler:
    BKPT 0
    HALT
    JP $-2
