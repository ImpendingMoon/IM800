;******************************************************************************
; File: constants.m4
;
;******************************************************************************

; ERRORS
errors:
.unknown: .EQU 0
.not_implemented: .EQU 1



; BIOS RAM
bram_start:     .EQU 0x10000
bram_length:    .EQU 0x1000

; System RAM
sram_start:     .EQU 0x200000

; Expansion Slots
slot_magic: .EQU 0x58704364
slot_difference: .EQU 0x040000

slot1_start:    .EQU 0x040000
slot1_check:    .EQU slot1_start + 4
slot1_vendor:   .EQU slot1_check + 4
slot1_part:     .EQU slot1_vendor + 4
slot1_init:     .EQU slot1_part + 4
slot1_shutdown: .EQU slot1_init + 4

slot2_start:    .EQU 0x080000
slot2_check:    .EQU slot2_start + 4
slot2_vendor:   .EQU slot2_check + 4
slot2_part:     .EQU slot2_vendor + 4
slot2_init:     .EQU slot2_part + 4
slot2_shutdown: .EQU slot2_init + 4

slot3_start:    .EQU 0x0C0000
slot3_check:    .EQU slot3_start + 4
slot3_vendor:   .EQU slot3_check + 4
slot3_part:     .EQU slot3_vendor + 4
slot3_init:     .EQU slot3_part + 4
slot3_shutdown: .EQU slot3_init + 4

slot4_start:    .EQU 0x100000
slot4_check:    .EQU slot4_start + 4
slot4_vendor:   .EQU slot4_check + 4
slot4_part:     .EQU slot4_vendor + 4
slot4_init:     .EQU slot4_part + 4
slot4_shutdown: .EQU slot4_init + 4

slot5_start:    .EQU 0x140000
slot5_check:    .EQU slot5_start + 4
slot5_vendor:   .EQU slot5_check + 4
slot5_part:     .EQU slot5_vendor + 4
slot5_init:     .EQU slot5_part + 4
slot5_shutdown: .EQU slot5_init + 4

slot6_start:    .EQU 0x180000
slot6_check:    .EQU slot6_start + 4
slot6_vendor:   .EQU slot6_check + 4
slot6_part:     .EQU slot6_vendor + 4
slot6_init:     .EQU slot6_part + 4
slot6_shutdown: .EQU slot6_init + 4

slot7_start:    .EQU 0x1C0000
slot7_check:    .EQU slot7_start + 4
slot7_vendor:   .EQU slot7_check + 4
slot7_part:     .EQU slot7_vendor + 4
slot7_init:     .EQU slot7_part + 4
slot7_shutdown: .EQU slot7_init + 4

; BIOS RAM
stack_top: .EQU bram_start + bram_length
ivt_start: .EQU bram_start
ivt_length: .EQU 0x400

; GLOBALS (base + offset)
global_base: .EQU ivt_start + ivt_length
slot_presence: .EQU 0 ; (+1 byte) (b1-b7 bit set = card present)
