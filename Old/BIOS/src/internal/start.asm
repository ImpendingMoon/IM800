;*******************************************************************************
; File: start.asm
; Contains the start routine
;*******************************************************************************

start:
    ; Check BIOS ROM checksum
    ; Check BIOS RAM

    ; Load BIOS pointers
    LD IY, mem.gp_base
    LD SP, mem.stack_top

    LD.D [IY+gp.mem_size], 16384 / 1024 ; This should be read from emu config DIP

    ; Initialize expansion cards
    CR discover_expansion_devices

    ; Go to monitor
    CR monitor

fatal_handler:
    DI
    HALT
    JR.B fatal_handler
