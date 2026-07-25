;******************************************************************************
; File: main.m4
; The entrypoint for the IM800 BIOS
;******************************************************************************

include(constants.m4)

    .ORG 0
reset_vector:
    .DEFD start

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
    LD B, 1                             ; Start at slot/bit 1 (slot 0 is BIOS/on-board (kind of))
.loop:
    CP.D [HL], slot_magic               ; Magic number at start?
    JR.B NZ, .nocard                    ; No, skip
    SET [IY+slot_presence], B           ; Yes, set presence bit
.nocard:
    INC B                               ; Increment slot
    ADD HL, slot_difference             ; Increment slot pointer
    CP.B B, 8                           ; Past final slot?
    JR C, .loop                         ; No, continue

    ; TODO: Check each card's checksum
    ; TODO: Check system RAM
    ; TODO: Check disks for bootable disk
    ; TODO: If bootable disk found, load block 1 into 0x20000 and jump
    ; TODO: Else, load built-in shell

    ; TODO: TEMP
    BKPT 0
    HALT
    JP $-2




memory_parity_error_handler:
    BKPT 0
    HALT
    JP $-2



include(ivt.m4)
