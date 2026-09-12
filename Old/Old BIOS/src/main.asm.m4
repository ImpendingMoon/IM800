;******************************************************************************
; File: main.m4
; Includes the ROM header and all files
;******************************************************************************

    .ORG 0
reset_vector:
    .DEFD start

bios_check:
    .DEFD 0 ; TODO

bios_check_start:

include(constants.asm.m4)
include(start.asm.m4)
include(expansion.asm.m4)
include(core.asm.m4)
include(ivt.asm.m4)

    ; Fletcher-32 requires 16-bit alignment for the whole ROM
    .ALIGN 2
bios_length: .EQU $
