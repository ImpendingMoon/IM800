;******************************************************************************
; File: core.asm.m4
; Core routines and services
;******************************************************************************

;******************************************************************************
; Function: unsigned long fletcher32(int *data, size_t count)
; Parameters:
;  HL = size_t count
;    - Number of 16-bit words to check
;  DE = int *data
;    - Base pointer of data
; Returns:
;  HL = unsigned long
;    - Checksum
; Notes:
;******************************************************************************
fletcher32:
    PUSH BC
    PUSH DE

    XOR BC, BC                          ; C = Partial sum 1, B = Partial sum 2
    XOR A, A                            ; Constant 0
.check_loop:
    ADD.W C, [DE]                       ; sum1 += *data
    ADC C, A                            ; sum1 += Carry
    ADD B, C                            ; sum2 += sum1
    ADC B, A                            ; sum2 += Carry
    INC DE                              ; Pointer++
    INC DE
    DEC HL                              ; Count--
    JR.B NZ, .check_loop                ; If not zero, continue
    DEC A                               ; A = 65535 for normalizing -1 to 0
    CP C, A                             ; sum1 == 65535?
    JR.B NZ, .nocorrect1                ; No, nothing to do
    INC C                               ; Yes, adjust to 0
.nocorrect1:
    CP B, A                             ; sum2 == 65535?
    JR.B NZ, .nocorrect2                ; No, nothing to do
    INC B                               ; Yes, adjust to 0
.nocorrect2:
    LD HL, BC                           ; Copy checksum to return value

    POP DE
    POP BC
    RET