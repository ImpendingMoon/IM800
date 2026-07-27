;******************************************************************************
; File: main.m4
; Includes the ROM header and all files
;******************************************************************************

    .ORG 0
reset_vector:
    .DEFD start

include(constants.asm.m4)
include(start.asm.m4)
include(expansion.asm.m4)
include(ivt.asm.m4)
