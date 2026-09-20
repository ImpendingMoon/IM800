;******************************************************************************
; File: videotest.asm
; A simple test of the 320x200 indexed bitmap mode
; Forked from controllertest
;******************************************************************************

; CONSTANTS:
mem_start: .EQU 0x00200000
stack_top: .EQU 0x00200100
global_start: .EQU 0x00200100
vram_start: .EQU 0x400000
palette_start: .EQU vram_start + 0xFA00

port_status: .EQU 0x00
port_rx_data: .EQU 0x01
port_tx_data: .EQU 0x02
status_rx_ready: .EQU 0x01
status_tx_ready: .EQU 0x02
port_controller: .EQU 0x04
port_video_mode: .EQU 0x08
port_video_config: .EQU 0x09
video_enable: .EQU 0x01

reset_vector:
    .DEFD main

main:
    LD SP, stack_top

.setup_video:
    LD A, video_enable
    OUT.B [port_video_config], A        ; Enable video so we can watch the magic
    LD HL, vram_start                   ; Source = vram_start
    LD DE, vram_start + 2               ; Dest = start + word
    LD BC, 0x7FFF                       ; 64 KiB = 32k words
    LD.W [HL], 0                        ; Seed 0
    BLD I, R, WORD                      ; Fill vram with 0
    LD HL, palette_start                ; Set color 0
    LD.D [HL], 0x800080                 ; #800080 purple

.controller_test:
    XOR D, D                            ; Pressed
    XOR C, C                            ; Changed
.loop:
    INC.D [palette_start]               ; Change the color a bit
    LD B, 32768                         ; Stall so we don't spam
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
