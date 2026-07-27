;******************************************************************************
; File: main.m4
; The entrypoint for the IM800 BIOS
;******************************************************************************

start:
    JR check_bios
.check_bios_ok:

    ; Set up pointers
    LD SP, bios_ram.top
    LD IY, globals.base

    ; Set up IVT
    LD DE, ivt.base
    LD HL, rom_ivt
    LD BC, ivt.length / 2
    BLD I, R, WORD
    LD I, ivt.base >> 10

    ; Initialize integrated devices if they exist

    BKPT 0

    ; Set up expansion slots
    CALL detect_slots
    CALL check_slots
    CALL init_slots

    ; Check system RAM
    CALL check_system_ram
    CP.B A, errors.ok
    JR NZ, fatal_error_handler

    ; Boot to software
    JP boot_default


;******************************************************************************
; Function: error check_bios(void)
; Parameters:
;  void
; Returns:
;  error
; Notes:
;******************************************************************************
check_bios:
    ; TODO
    XOR A, A
    JR check_bios_ram


;******************************************************************************
; Function: error check_bios_ram(void)
; Parameters:
;  void
; Returns:
;  A = error
; Notes:
;******************************************************************************
check_bios_ram:
    ; TODO
    XOR A, A
    JR start.check_bios_ok


;******************************************************************************
; Function: error check_system_ram(void)
; Parameters:
;  void
; Returns:
;  A = error
; Notes:
;******************************************************************************
check_system_ram:
    ; TODO
    XOR A, A
    RET


;******************************************************************************
; Function: void boot_default(void)
; Parameters:
;  void
; Returns:
;  N/A
; Notes:
;  Boots the first bootable disk if one is found, else starts BASIC
;******************************************************************************
boot_default:
    ; TODO
    ; TEMP
    BKPT 0
    HALT
    JR.B $-2


;******************************************************************************
; Function: void fatal_error_handler(void)
; Parameters:
;  void
; Returns:
;  N/A
; Notes:
;******************************************************************************
fatal_error_handler:
    ; TODO probably beep a speaker
    BKPT 0
    HALT
    JR.B $-2
