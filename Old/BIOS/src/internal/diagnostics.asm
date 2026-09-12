;******************************************************************************
; File: diagnostics.asm
; Functions relating to printing diagnostic messages and handling basic I/O
;******************************************************************************

;*******************************************************************************
; Function:
;  char getc(void)
; Arguments:
;  void
; Returns:
;  A = char
;*******************************************************************************
getc:
    XOR A, A
.wait:
    IN.B A, [uart.port_status]
    AND.B A, uart.status_rx_ready
    JAZ .wait
    IN.B A, [uart.port_rx_data]
    RET



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
    IN.B A, [uart.port_status]
    AND.B A, uart.status_tx_ready
    JAZ .wait
    OUT.B [uart.port_tx_data], L
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