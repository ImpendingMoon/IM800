;******************************************************************************
; File: controller.asm
; A simple test of reading controller inputs
;******************************************************************************

; CONSTANTS:
mem_start: .EQU 0x00200000
stack_top: .EQU 0x00200100
global_start: .EQU 0x00200100

port_status: .EQU 0x00
port_rx_data: .EQU 0x01
port_tx_data: .EQU 0x02
status_rx_ready: .EQU 0x01
status_tx_ready: .EQU 0x02
port_controller: .EQU 0x04

reset_vector:
    .DEFD main

main:
    LD SP, stack_top
    XOR D, D                            ; Pressed
    XOR C, C                            ; Changed
.loop:
    LD B, 65535                         ; Stall so we don't spam
    DJNZ $
    IN.W A, [port_controller]           ; Read controller state
    CPL A                               ; Invert
    LD C, A                             ; Move new buttons to changed
    XOR C, D                            ; Set which buttons changed
    LD D, A                             ; Move new buttons to pressed
    TST C, C                            ; Any buttons changed?
    JR.B Z, .loop                       ; No, loop.
    LD A, 4                             ; Yes, print button state in hex
    XOR H, H
    LD L, D
    CR puthex
    LD A, '\n'                          ; Print newline
    CR putc
    JR.B .loop                          ; Loop

;*******************************************************************************
; Function:
;  void putc(char c)
; Arguments:
;  A = char c
; Returns:
;  void
;*******************************************************************************
putc:
    LD L, A
    XOR A, A
.wait:
    IN.B A, [port_status]
    AND.B A, status_tx_ready
    JAZ .wait
    OUT.B [port_tx_data], L
    RET

;*******************************************************************************
; Function:
;  void puts(const char *s)
; Arguments:
;  HL = const char *s
; Returns:
;  void
;*******************************************************************************
puts:
    PUSH DE
    LD DE, HL
.loop:
    XOR A, A
    LD.B A, [DE]
    JAZ .end
    INC DE
    CR putc
    JR.B .loop
.end:
    POP DE
    RET

;*******************************************************************************
; Function:
;  void puthex(unsigned long value, int length)
; Arguments:
;  A = int length
;  HL = unsigned long value
; Returns:
;  void
;*******************************************************************************
puthex:
    PUSH BC
    PUSH DE
    LD B, A                             ; Move counter to saved register
    LD DE, HL                           ; Move value to saved register
    LD A, 8                             ; Shift DE up by number of digits < 8
    SUB A, B
    SLA A, 2                            ; 4 bits per digit
    SLA DE, A
.loop:
    LD A, D                             ; Move high word to A
    AND A, 0xF000                       ; Filter to nibble
    SRL A, 12                           ; Shift to low nibble
    CP.B A, 0x0A                        ; 'A' or higher?
    JR.B C, .print                      ; No, print
    ADD A, 'A'-'9'-1                    ; Add diff to put char in A-F range
.print:
    ADD A, '0'                          ; Convert number to ASCII char
    CR putc                             ; Print ascii char
    SLA DE, 4                           ; Shift to next nibble
    DJNZ .loop
    POP DE
    POP BC
    RET
