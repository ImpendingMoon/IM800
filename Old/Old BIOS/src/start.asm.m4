;******************************************************************************
; File: main.m4
; The entrypoint for the IM800 BIOS
;******************************************************************************

start:
    ; Calculate BIOS checksum
    LD HL, bios_check_start             ; Pointer
    LD BC, (bios_length - bios_check_start) / 2
    XOR DE, DE                          ; E = Partial sum 1, D = Partial sum 2
    XOR A, A                            ; Constant 0
.check_loop:
    ADD.W E, [HL]                       ; sum1 += *data
    ADC E, A                            ; sum1 += Carry
    ADD D, E                            ; sum2 += sum1
    ADC D, A                            ; sum2 += Carry
    INC HL                              ; Pointer++
    INC HL
    DEC BC                              ; Length--
    JR.B NZ, .check_loop                ; If not zero, continue
    DEC A                               ; A = 65535 for normalizing -1 to 0
    CP E, A                             ; sum1 == 65535?
    JR.B NZ, .nocorrect1                ; No, nothing to do
    INC E                               ; Yes, adjust to 0
.nocorrect1:
    CP D, A                             ; sum2 == 65535?
    JR.B NZ, .nocorrect2                ; No, nothing to do
    INC D                               ; Yes, adjust to 0
.nocorrect2:

    BKPT 0

    CP.D DE, [bios_check]               ; Correct checksum?
    JR NZ, fatal_error_handler          ; No, error

; Quick BIOS RAM check
.check_bios_ram:
    LD A, 0x5555                        ; Check bit pattern 1
    LD E, 2                             ; 2 passes
.outer_ram_check_loop:
    LD HL, bios_ram.base                ; Pointer
    LD BC, bios_ram.length / 2          ; Length
.ram_check_loop:
    LD.W [HL], A                        ; Store bit pattern
    BCP I, S, WORD                      ; CP A, [HL++], Single
    JR NZ, fatal_error_handler          ; If changed, bad RAM
    JR.B PE, .ram_check_loop            ; If counter not zero, continue
    RR A, 1                             ; Shift to cover the rest
    DEC E                               ; Done with this pass
    JR.B NZ, .outer_ram_check_loop      ; If any more to do, continue

    ; BIOS and BIOS RAM are OK.

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
    ; TEMP: Inspect system in emulator debugger
    BKPT 0

    ; Set up expansion slots
    CALL detect_slots
    CALL check_slots
    CALL init_slots

    ; Check system RAM (do after expansions in case there's RAM expansions)
    CALL check_system_ram
    CP.B A, errors.ok
    JR NZ, fatal_error_handler

    ; Boot to software
    JP boot_default

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
