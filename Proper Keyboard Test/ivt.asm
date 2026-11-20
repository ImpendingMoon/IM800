;*******************************************************************************
; ivt.asm
; Interrupt Vector Table and service routines
;*******************************************************************************

default_isr:
    EI
    RETI



keyboard_isr:
    EXA AF                              ; Exchange to alternate register set
    EXX
    EXI
    LD IY, gp                           ; Set global pointer
    XOR B, B                            ; Clear B for indexing (LEA uses word)
    LD.B B, [IY+gp.sc_buf_w]            ; B = write index
    LD.B C, [IY+gp.sc_buf_r]            ; C = read index - 1
    DEC.B C
.loop:
    CP.B B, C                           ; Buffer full?
    JR.B Z, .end                        ; Yes, return immediately

    IN.B A, [ports.kbd_scancode]        ; Read next scancode
    TST.B A, A                          ; Zero?
    JR.B Z, .end                        ; Yes, no scancodes left

    LD HL, gp + gp.sc_buf               ; Point to scancode buffer
    LEA HL, B, BYTE                     ; Index (recalc for index wraparound)
    LD.B [HL], A                        ; Store scancode in buffer

    INC.B B                             ; Increment write index
    JR.B .loop                          ; Iterate

.end:
    LD.B [IY+gp.sc_buf_w], B            ; Store updated write index

    EXI                                 ; Restore user register set
    EXX
    EXA AF
    EI
    RETI



    .ALIGN 1024
ivt:                                    ; Interrupt Vector Table
    .DEFD default_isr                   ; 0x00
    .DEFD default_isr                   ; 0x01
    .DEFD default_isr                   ; 0x02
    .DEFD default_isr                   ; 0x03
    .DEFD default_isr                   ; 0x04
    .DEFD default_isr                   ; 0x05
    .DEFD default_isr                   ; 0x06
    .DEFD default_isr                   ; 0x07
    .DEFD default_isr                   ; 0x08
    .DEFD default_isr                   ; 0x09
    .DEFD default_isr                   ; 0x0A
    .DEFD default_isr                   ; 0x0B
    .DEFD default_isr                   ; 0x0C
    .DEFD default_isr                   ; 0x0D
    .DEFD default_isr                   ; 0x0E
    .DEFD default_isr                   ; 0x0F
    .DEFD keyboard_isr                  ; 0x10 (Keyboard)
    .DEFD default_isr                   ; 0x11
    .DEFD default_isr                   ; 0x12
    .DEFD default_isr                   ; 0x13
    .DEFD default_isr                   ; 0x14
    .DEFD default_isr                   ; 0x15
    .DEFD default_isr                   ; 0x16
    .DEFD default_isr                   ; 0x17
    .DEFD default_isr                   ; 0x18
    .DEFD default_isr                   ; 0x19
    .DEFD default_isr                   ; 0x1A
    .DEFD default_isr                   ; 0x1B
    .DEFD default_isr                   ; 0x1C
    .DEFD default_isr                   ; 0x1D
    .DEFD default_isr                   ; 0x1E
    .DEFD default_isr                   ; 0x1F
    .DEFD default_isr                   ; 0x20
    .DEFD default_isr                   ; 0x21
    .DEFD default_isr                   ; 0x22
    .DEFD default_isr                   ; 0x23
    .DEFD default_isr                   ; 0x24
    .DEFD default_isr                   ; 0x25
    .DEFD default_isr                   ; 0x26
    .DEFD default_isr                   ; 0x27
    .DEFD default_isr                   ; 0x28
    .DEFD default_isr                   ; 0x29
    .DEFD default_isr                   ; 0x2A
    .DEFD default_isr                   ; 0x2B
    .DEFD default_isr                   ; 0x2C
    .DEFD default_isr                   ; 0x2D
    .DEFD default_isr                   ; 0x2E
    .DEFD default_isr                   ; 0x2F
    .DEFD default_isr                   ; 0x30
    .DEFD default_isr                   ; 0x31
    .DEFD default_isr                   ; 0x32
    .DEFD default_isr                   ; 0x33
    .DEFD default_isr                   ; 0x34
    .DEFD default_isr                   ; 0x35
    .DEFD default_isr                   ; 0x36
    .DEFD default_isr                   ; 0x37
    .DEFD default_isr                   ; 0x38
    .DEFD default_isr                   ; 0x39
    .DEFD default_isr                   ; 0x3A
    .DEFD default_isr                   ; 0x3B
    .DEFD default_isr                   ; 0x3C
    .DEFD default_isr                   ; 0x3D
    .DEFD default_isr                   ; 0x3E
    .DEFD default_isr                   ; 0x3F
    .DEFD default_isr                   ; 0x40
    .DEFD default_isr                   ; 0x41
    .DEFD default_isr                   ; 0x42
    .DEFD default_isr                   ; 0x43
    .DEFD default_isr                   ; 0x44
    .DEFD default_isr                   ; 0x45
    .DEFD default_isr                   ; 0x46
    .DEFD default_isr                   ; 0x47
    .DEFD default_isr                   ; 0x48
    .DEFD default_isr                   ; 0x49
    .DEFD default_isr                   ; 0x4A
    .DEFD default_isr                   ; 0x4B
    .DEFD default_isr                   ; 0x4C
    .DEFD default_isr                   ; 0x4D
    .DEFD default_isr                   ; 0x4E
    .DEFD default_isr                   ; 0x4F
    .DEFD default_isr                   ; 0x50
    .DEFD default_isr                   ; 0x51
    .DEFD default_isr                   ; 0x52
    .DEFD default_isr                   ; 0x53
    .DEFD default_isr                   ; 0x54
    .DEFD default_isr                   ; 0x55
    .DEFD default_isr                   ; 0x56
    .DEFD default_isr                   ; 0x57
    .DEFD default_isr                   ; 0x58
    .DEFD default_isr                   ; 0x59
    .DEFD default_isr                   ; 0x5A
    .DEFD default_isr                   ; 0x5B
    .DEFD default_isr                   ; 0x5C
    .DEFD default_isr                   ; 0x5D
    .DEFD default_isr                   ; 0x5E
    .DEFD default_isr                   ; 0x5F
    .DEFD default_isr                   ; 0x60
    .DEFD default_isr                   ; 0x61
    .DEFD default_isr                   ; 0x62
    .DEFD default_isr                   ; 0x63
    .DEFD default_isr                   ; 0x64
    .DEFD default_isr                   ; 0x65
    .DEFD default_isr                   ; 0x66
    .DEFD default_isr                   ; 0x67
    .DEFD default_isr                   ; 0x68
    .DEFD default_isr                   ; 0x69
    .DEFD default_isr                   ; 0x6A
    .DEFD default_isr                   ; 0x6B
    .DEFD default_isr                   ; 0x6C
    .DEFD default_isr                   ; 0x6D
    .DEFD default_isr                   ; 0x6E
    .DEFD default_isr                   ; 0x6F
    .DEFD default_isr                   ; 0x70
    .DEFD default_isr                   ; 0x71
    .DEFD default_isr                   ; 0x72
    .DEFD default_isr                   ; 0x73
    .DEFD default_isr                   ; 0x74
    .DEFD default_isr                   ; 0x75
    .DEFD default_isr                   ; 0x76
    .DEFD default_isr                   ; 0x77
    .DEFD default_isr                   ; 0x78
    .DEFD default_isr                   ; 0x79
    .DEFD default_isr                   ; 0x7A
    .DEFD default_isr                   ; 0x7B
    .DEFD default_isr                   ; 0x7C
    .DEFD default_isr                   ; 0x7D
    .DEFD default_isr                   ; 0x7E
    .DEFD default_isr                   ; 0x7F
    .DEFD default_isr                   ; 0x80
    .DEFD default_isr                   ; 0x81
    .DEFD default_isr                   ; 0x82
    .DEFD default_isr                   ; 0x83
    .DEFD default_isr                   ; 0x84
    .DEFD default_isr                   ; 0x85
    .DEFD default_isr                   ; 0x86
    .DEFD default_isr                   ; 0x87
    .DEFD default_isr                   ; 0x88
    .DEFD default_isr                   ; 0x89
    .DEFD default_isr                   ; 0x8A
    .DEFD default_isr                   ; 0x8B
    .DEFD default_isr                   ; 0x8C
    .DEFD default_isr                   ; 0x8D
    .DEFD default_isr                   ; 0x8E
    .DEFD default_isr                   ; 0x8F
    .DEFD default_isr                   ; 0x90
    .DEFD default_isr                   ; 0x91
    .DEFD default_isr                   ; 0x92
    .DEFD default_isr                   ; 0x93
    .DEFD default_isr                   ; 0x94
    .DEFD default_isr                   ; 0x95
    .DEFD default_isr                   ; 0x96
    .DEFD default_isr                   ; 0x97
    .DEFD default_isr                   ; 0x98
    .DEFD default_isr                   ; 0x99
    .DEFD default_isr                   ; 0x9A
    .DEFD default_isr                   ; 0x9B
    .DEFD default_isr                   ; 0x9C
    .DEFD default_isr                   ; 0x9D
    .DEFD default_isr                   ; 0x9E
    .DEFD default_isr                   ; 0x9F
    .DEFD default_isr                   ; 0xA0
    .DEFD default_isr                   ; 0xA1
    .DEFD default_isr                   ; 0xA2
    .DEFD default_isr                   ; 0xA3
    .DEFD default_isr                   ; 0xA4
    .DEFD default_isr                   ; 0xA5
    .DEFD default_isr                   ; 0xA6
    .DEFD default_isr                   ; 0xA7
    .DEFD default_isr                   ; 0xA8
    .DEFD default_isr                   ; 0xA9
    .DEFD default_isr                   ; 0xAA
    .DEFD default_isr                   ; 0xAB
    .DEFD default_isr                   ; 0xAC
    .DEFD default_isr                   ; 0xAD
    .DEFD default_isr                   ; 0xAE
    .DEFD default_isr                   ; 0xAF
    .DEFD default_isr                   ; 0xB0
    .DEFD default_isr                   ; 0xB1
    .DEFD default_isr                   ; 0xB2
    .DEFD default_isr                   ; 0xB3
    .DEFD default_isr                   ; 0xB4
    .DEFD default_isr                   ; 0xB5
    .DEFD default_isr                   ; 0xB6
    .DEFD default_isr                   ; 0xB7
    .DEFD default_isr                   ; 0xB8
    .DEFD default_isr                   ; 0xB9
    .DEFD default_isr                   ; 0xBA
    .DEFD default_isr                   ; 0xBB
    .DEFD default_isr                   ; 0xBC
    .DEFD default_isr                   ; 0xBD
    .DEFD default_isr                   ; 0xBE
    .DEFD default_isr                   ; 0xBF
    .DEFD default_isr                   ; 0xC0
    .DEFD default_isr                   ; 0xC1
    .DEFD default_isr                   ; 0xC2
    .DEFD default_isr                   ; 0xC3
    .DEFD default_isr                   ; 0xC4
    .DEFD default_isr                   ; 0xC5
    .DEFD default_isr                   ; 0xC6
    .DEFD default_isr                   ; 0xC7
    .DEFD default_isr                   ; 0xC8
    .DEFD default_isr                   ; 0xC9
    .DEFD default_isr                   ; 0xCA
    .DEFD default_isr                   ; 0xCB
    .DEFD default_isr                   ; 0xCC
    .DEFD default_isr                   ; 0xCD
    .DEFD default_isr                   ; 0xCE
    .DEFD default_isr                   ; 0xCF
    .DEFD default_isr                   ; 0xD0
    .DEFD default_isr                   ; 0xD1
    .DEFD default_isr                   ; 0xD2
    .DEFD default_isr                   ; 0xD3
    .DEFD default_isr                   ; 0xD4
    .DEFD default_isr                   ; 0xD5
    .DEFD default_isr                   ; 0xD6
    .DEFD default_isr                   ; 0xD7
    .DEFD default_isr                   ; 0xD8
    .DEFD default_isr                   ; 0xD9
    .DEFD default_isr                   ; 0xDA
    .DEFD default_isr                   ; 0xDB
    .DEFD default_isr                   ; 0xDC
    .DEFD default_isr                   ; 0xDD
    .DEFD default_isr                   ; 0xDE
    .DEFD default_isr                   ; 0xDF
    .DEFD default_isr                   ; 0xE0
    .DEFD default_isr                   ; 0xE1
    .DEFD default_isr                   ; 0xE2
    .DEFD default_isr                   ; 0xE3
    .DEFD default_isr                   ; 0xE4
    .DEFD default_isr                   ; 0xE5
    .DEFD default_isr                   ; 0xE6
    .DEFD default_isr                   ; 0xE7
    .DEFD default_isr                   ; 0xE8
    .DEFD default_isr                   ; 0xE9
    .DEFD default_isr                   ; 0xEA
    .DEFD default_isr                   ; 0xEB
    .DEFD default_isr                   ; 0xEC
    .DEFD default_isr                   ; 0xED
    .DEFD default_isr                   ; 0xEE
    .DEFD default_isr                   ; 0xEF
    .DEFD default_isr                   ; 0xF0
    .DEFD default_isr                   ; 0xF1
    .DEFD default_isr                   ; 0xF2
    .DEFD default_isr                   ; 0xF3
    .DEFD default_isr                   ; 0xF4
    .DEFD default_isr                   ; 0xF5
    .DEFD default_isr                   ; 0xF6
    .DEFD default_isr                   ; 0xF7
    .DEFD default_isr                   ; 0xF8
    .DEFD default_isr                   ; 0xF9
    .DEFD default_isr                   ; 0xFA
    .DEFD default_isr                   ; 0xFB
    .DEFD default_isr                   ; 0xFC
    .DEFD default_isr                   ; 0xFD
    .DEFD default_isr                   ; 0xFE
    .DEFD default_isr                   ; 0xFF
