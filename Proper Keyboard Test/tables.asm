;*******************************************************************************
; tables.asm
; Arrays and stuff
;*******************************************************************************

pause_sequence:
    .DEFB 0xE1, 0x1D, 0x45, 0xE1, 0x9D, 0xC5
    .size: .EQU $-pause_sequence

; Scancode to Keycode
; Direct index
sc_to_kc:
    .DEFB Keycode.null      ; 0x00
    .DEFB Keycode.esc       ; 0x01
    .DEFB Keycode.k_1       ; 0x02
    .DEFB Keycode.k_2       ; 0x03
    .DEFB Keycode.k_3       ; 0x04
    .DEFB Keycode.k_4       ; 0x05
    .DEFB Keycode.k_5       ; 0x06
    .DEFB Keycode.k_6       ; 0x07
    .DEFB Keycode.k_7       ; 0x08
    .DEFB Keycode.k_8       ; 0x09
    .DEFB Keycode.k_9       ; 0x0A
    .DEFB Keycode.k_0       ; 0x0B
    .DEFB Keycode.minus     ; 0x0C
    .DEFB Keycode.equal     ; 0x0D
    .DEFB Keycode.backspace ; 0x0E
    .DEFB Keycode.tab       ; 0x0F
    .DEFB Keycode.k_q       ; 0x10
    .DEFB Keycode.k_w       ; 0x11
    .DEFB Keycode.k_e       ; 0x12
    .DEFB Keycode.k_r       ; 0x13
    .DEFB Keycode.k_t       ; 0x14
    .DEFB Keycode.k_y       ; 0x15
    .DEFB Keycode.k_u       ; 0x16
    .DEFB Keycode.k_i       ; 0x17
    .DEFB Keycode.k_o       ; 0x18
    .DEFB Keycode.k_p       ; 0x19
    .DEFB Keycode.lbracket  ; 0x1A
    .DEFB Keycode.rbracket  ; 0x1B
    .DEFB Keycode.enter     ; 0x1C
    .DEFB Keycode.lctrl     ; 0x1D
    .DEFB Keycode.k_a       ; 0x1E
    .DEFB Keycode.k_s       ; 0x1F
    .DEFB Keycode.k_d       ; 0x20
    .DEFB Keycode.k_f       ; 0x21
    .DEFB Keycode.k_g       ; 0x22
    .DEFB Keycode.k_h       ; 0x23
    .DEFB Keycode.k_j       ; 0x24
    .DEFB Keycode.k_k       ; 0x25
    .DEFB Keycode.k_l       ; 0x26
    .DEFB Keycode.semicolon ; 0x27
    .DEFB Keycode.apostrophe ; 0x28
    .DEFB Keycode.grave     ; 0x29
    .DEFB Keycode.lshift    ; 0x2A
    .DEFB Keycode.bslash    ; 0x2B
    .DEFB Keycode.k_z       ; 0x2C
    .DEFB Keycode.k_x       ; 0x2D
    .DEFB Keycode.k_c       ; 0x2E
    .DEFB Keycode.k_v       ; 0x2F
    .DEFB Keycode.k_b       ; 0x30
    .DEFB Keycode.k_n       ; 0x31
    .DEFB Keycode.k_m       ; 0x32
    .DEFB Keycode.comma     ; 0x33
    .DEFB Keycode.period    ; 0x34
    .DEFB Keycode.slash     ; 0x35
    .DEFB Keycode.rshift    ; 0x36
    .DEFB Keycode.kp_star   ; 0x37
    .DEFB Keycode.lalt      ; 0x38
    .DEFB Keycode.space     ; 0x39
    .DEFB Keycode.caps_lock ; 0x3A
    .DEFB Keycode.f1        ; 0x3B
    .DEFB Keycode.f2        ; 0x3C
    .DEFB Keycode.f3        ; 0x3D
    .DEFB Keycode.f4        ; 0x3E
    .DEFB Keycode.f5        ; 0x3F
    .DEFB Keycode.f6        ; 0x40
    .DEFB Keycode.f7        ; 0x41
    .DEFB Keycode.f8        ; 0x42
    .DEFB Keycode.f9        ; 0x43
    .DEFB Keycode.f10       ; 0x44
    .DEFB Keycode.num_lock  ; 0x45
    .DEFB Keycode.scroll_lock ; 0x46
    .DEFB Keycode.kp_7      ; 0x47
    .DEFB Keycode.kp_8      ; 0x48
    .DEFB Keycode.kp_9      ; 0x49
    .DEFB Keycode.kp_minus  ; 0x4A
    .DEFB Keycode.kp_4      ; 0x4B
    .DEFB Keycode.kp_5      ; 0x4C
    .DEFB Keycode.kp_6      ; 0x4D
    .DEFB Keycode.kp_plus   ; 0x4E
    .DEFB Keycode.kp_1      ; 0x4F
    .DEFB Keycode.kp_2      ; 0x50
    .DEFB Keycode.kp_3      ; 0x51
    .DEFB Keycode.kp_0      ; 0x52
    .DEFB Keycode.kp_period ; 0x53
    .DEFB Keycode.null      ; 0x54
    .DEFB Keycode.null      ; 0x55
    .DEFB Keycode.null      ; 0x56
    .DEFB Keycode.f11       ; 0x57
    .DEFB Keycode.f12       ; 0x58
    .size: .EQU $-sc_to_kc

; Extended Scancode to Keycode
; Linear search (scancode, keycode)
ext_sc_to_kc:
    .DEFB 0x1C, Keycode.kp_enter
    .DEFB 0x1D, Keycode.rctrl
    .DEFB 0x35, Keycode.kp_slash
    .DEFB 0x37, Keycode.print
    .DEFB 0x38, Keycode.ralt
    .DEFB 0x47, Keycode.home
    .DEFB 0x48, Keycode.arrow_up
    .DEFB 0x49, Keycode.page_up
    .DEFB 0x4B, Keycode.arrow_left
    .DEFB 0x4D, Keycode.arrow_right
    .DEFB 0x4F, Keycode.end
    .DEFB 0x50, Keycode.arrow_down
    .DEFB 0x51, Keycode.page_down
    .DEFB 0x52, Keycode.insert
    .DEFB 0x53, Keycode.delete
    .size: .EQU $-ext_sc_to_kc

; Keycode to ASCII
; Direct index
kc_to_ascii:
    .DEFB '\0' ; 0x00 Keycode.null

    ; Function Row
    .DEFB '\0' ; 0x01 Keycode.esc
    .DEFB '\0' ; 0x02 Keycode.f1
    .DEFB '\0' ; 0x03 Keycode.f2
    .DEFB '\0' ; 0x04 Keycode.f3
    .DEFB '\0' ; 0x05 Keycode.f4
    .DEFB '\0' ; 0x06 Keycode.f5
    .DEFB '\0' ; 0x07 Keycode.f6
    .DEFB '\0' ; 0x08 Keycode.f7
    .DEFB '\0' ; 0x09 Keycode.f8
    .DEFB '\0' ; 0x0A Keycode.f9
    .DEFB '\0' ; 0x0B Keycode.f10
    .DEFB '\0' ; 0x0C Keycode.f11
    .DEFB '\0' ; 0x0D Keycode.f12

    ; First Row
    .DEFB '`'  ; 0x0E Keycode.grave
    .DEFB '1'  ; 0x0F Keycode.k_1
    .DEFB '2'  ; 0x10 Keycode.k_2
    .DEFB '3'  ; 0x11 Keycode.k_3
    .DEFB '4'  ; 0x12 Keycode.k_4
    .DEFB '5'  ; 0x13 Keycode.k_5
    .DEFB '6'  ; 0x14 Keycode.k_6
    .DEFB '7'  ; 0x15 Keycode.k_7
    .DEFB '8'  ; 0x16 Keycode.k_8
    .DEFB '9'  ; 0x17 Keycode.k_9
    .DEFB '0'  ; 0x18 Keycode.k_0
    .DEFB '-'  ; 0x19 Keycode.minus
    .DEFB '='  ; 0x1A Keycode.equal
    .DEFB '\b' ; 0x1B Keycode.backspace

    ; Second Row
    .DEFB '\t' ; 0x1C Keycode.tab
    .DEFB 'q'  ; 0x1D Keycode.k_q
    .DEFB 'w'  ; 0x1E Keycode.k_w
    .DEFB 'e'  ; 0x1F Keycode.k_e
    .DEFB 'r'  ; 0x20 Keycode.k_r
    .DEFB 't'  ; 0x21 Keycode.k_t
    .DEFB 'y'  ; 0x22 Keycode.k_y
    .DEFB 'u'  ; 0x23 Keycode.k_u
    .DEFB 'i'  ; 0x24 Keycode.k_i
    .DEFB 'o'  ; 0x25 Keycode.k_o
    .DEFB 'p'  ; 0x26 Keycode.k_p
    .DEFB '['  ; 0x27 Keycode.lbracket
    .DEFB ']'  ; 0x28 Keycode.rbracket
    .DEFB '\\' ; 0x29 Keycode.bslash

    ; Third Row
    .DEFB '\0' ; 0x2A Keycode.caps_lock
    .DEFB 'a'  ; 0x2B Keycode.k_a
    .DEFB 's'  ; 0x2C Keycode.k_s
    .DEFB 'd'  ; 0x2D Keycode.k_d
    .DEFB 'f'  ; 0x2E Keycode.k_f
    .DEFB 'g'  ; 0x2F Keycode.k_g
    .DEFB 'h'  ; 0x30 Keycode.k_h
    .DEFB 'j'  ; 0x31 Keycode.k_j
    .DEFB 'k'  ; 0x32 Keycode.k_k
    .DEFB 'l'  ; 0x33 Keycode.k_l
    .DEFB ';'  ; 0x34 Keycode.semicolon
    .DEFB '\'' ; 0x35 Keycode.apostrophe
    .DEFB '\n' ; 0x36 Keycode.enter

    ; Fourth Row
    .DEFB '\0' ; 0x37 Keycode.lshift
    .DEFB 'z'  ; 0x38 Keycode.k_z
    .DEFB 'x'  ; 0x39 Keycode.k_x
    .DEFB 'c'  ; 0x3A Keycode.k_c
    .DEFB 'v'  ; 0x3B Keycode.k_v
    .DEFB 'b'  ; 0x3C Keycode.k_b
    .DEFB 'n'  ; 0x3D Keycode.k_n
    .DEFB 'm'  ; 0x3E Keycode.k_m
    .DEFB ','  ; 0x3F Keycode.comma
    .DEFB '.'  ; 0x40 Keycode.period
    .DEFB '/'  ; 0x41 Keycode.slash
    .DEFB '\0' ; 0x42 Keycode.rshift

    ; Fifth Row
    .DEFB '\0' ; 0x43 Keycode.lctrl
    .DEFB '\0' ; 0x44 Keycode.lsuper
    .DEFB '\0' ; 0x45 Keycode.lalt
    .DEFB ' '  ; 0x46 Keycode.space
    .DEFB '\0' ; 0x47 Keycode.ralt
    .DEFB '\0' ; 0x48 Keycode.rsuper
    .DEFB '\0' ; 0x49 Keycode.meta
    .DEFB '\0' ; 0x4A Keycode.rctrl

    ; Keypad
    .DEFB '0'  ; 0x4B Keycode.kp_0
    .DEFB '1'  ; 0x4C Keycode.kp_1
    .DEFB '2'  ; 0x4D Keycode.kp_2
    .DEFB '3'  ; 0x4E Keycode.kp_3
    .DEFB '4'  ; 0x4F Keycode.kp_4
    .DEFB '5'  ; 0x50 Keycode.kp_5
    .DEFB '6'  ; 0x51 Keycode.kp_6
    .DEFB '7'  ; 0x52 Keycode.kp_7
    .DEFB '8'  ; 0x53 Keycode.kp_8
    .DEFB '9'  ; 0x54 Keycode.kp_9
    .DEFB '\0' ; 0x55 Keycode.num_lock
    .DEFB '/'  ; 0x56 Keycode.kp_slash
    .DEFB '*'  ; 0x57 Keycode.kp_star
    .DEFB '-'  ; 0x58 Keycode.kp_minus
    .DEFB '+'  ; 0x59 Keycode.kp_plus
    .DEFB '\n' ; 0x5A Keycode.kp_enter
    .DEFB '.'  ; 0x5B Keycode.kp_period

    ; Navigation Cluster
    .DEFB '\0' ; 0x5C Keycode.print
    .DEFB '\0' ; 0x5D Keycode.scroll_lock
    .DEFB '\0' ; 0x5E Keycode.pause
    .DEFB '\0' ; 0x5F Keycode.insert
    .DEFB '\0' ; 0x60 Keycode.delete
    .DEFB '\0' ; 0x61 Keycode.home
    .DEFB '\0' ; 0x62 Keycode.end
    .DEFB '\0' ; 0x63 Keycode.page_up
    .DEFB '\0' ; 0x64 Keycode.page_down
    .DEFB '\0' ; 0x65 Keycode.arrow_up
    .DEFB '\0' ; 0x66 Keycode.arrow_left
    .DEFB '\0' ; 0x67 Keycode.arrow_down
    .DEFB '\0' ; 0x68 Keycode.arrow_right
    .size: .EQU $-kc_to_ascii

; Keycode to Shifted ASCII
; Direct index
kc_to_shift_ascii:
    ; Function Row
    .DEFB '\0' ; 0x00 Keycode.null
    .DEFB '\0' ; 0x01 Keycode.esc
    .DEFB '\0' ; 0x02 Keycode.f1
    .DEFB '\0' ; 0x03 Keycode.f2
    .DEFB '\0' ; 0x04 Keycode.f3
    .DEFB '\0' ; 0x05 Keycode.f4
    .DEFB '\0' ; 0x06 Keycode.f5
    .DEFB '\0' ; 0x07 Keycode.f6
    .DEFB '\0' ; 0x08 Keycode.f7
    .DEFB '\0' ; 0x09 Keycode.f8
    .DEFB '\0' ; 0x0A Keycode.f9
    .DEFB '\0' ; 0x0B Keycode.f10
    .DEFB '\0' ; 0x0C Keycode.f11
    .DEFB '\0' ; 0x0D Keycode.f12

    ; First Row
    .DEFB '~'  ; 0x0E Keycode.grave
    .DEFB '!'  ; 0x0F Keycode.k_1
    .DEFB '@'  ; 0x10 Keycode.k_2
    .DEFB '#'  ; 0x11 Keycode.k_3
    .DEFB '$'  ; 0x12 Keycode.k_4
    .DEFB '%'  ; 0x13 Keycode.k_5
    .DEFB '^'  ; 0x14 Keycode.k_6
    .DEFB '&'  ; 0x15 Keycode.k_7
    .DEFB '*'  ; 0x16 Keycode.k_8
    .DEFB '('  ; 0x17 Keycode.k_9
    .DEFB ')'  ; 0x18 Keycode.k_0
    .DEFB '_'  ; 0x19 Keycode.minus
    .DEFB '+'  ; 0x1A Keycode.equal
    .DEFB '\b' ; 0x1B Keycode.backspace

    ; Second Row
    .DEFB '\t' ; 0x1C Keycode.tab
    .DEFB 'Q'  ; 0x1D Keycode.k_q
    .DEFB 'W'  ; 0x1E Keycode.k_w
    .DEFB 'E'  ; 0x1F Keycode.k_e
    .DEFB 'R'  ; 0x20 Keycode.k_r
    .DEFB 'T'  ; 0x21 Keycode.k_t
    .DEFB 'Y'  ; 0x22 Keycode.k_y
    .DEFB 'U'  ; 0x23 Keycode.k_u
    .DEFB 'I'  ; 0x24 Keycode.k_i
    .DEFB 'O'  ; 0x25 Keycode.k_o
    .DEFB 'P'  ; 0x26 Keycode.k_p
    .DEFB '{'  ; 0x27 Keycode.lbracket
    .DEFB '}'  ; 0x28 Keycode.rbracket
    .DEFB '|'  ; 0x29 Keycode.bslash

    ; Third Row
    .DEFB '\0' ; 0x2A Keycode.caps_lock
    .DEFB 'A'  ; 0x2B Keycode.k_a
    .DEFB 'S'  ; 0x2C Keycode.k_s
    .DEFB 'D'  ; 0x2D Keycode.k_d
    .DEFB 'F'  ; 0x2E Keycode.k_f
    .DEFB 'G'  ; 0x2F Keycode.k_g
    .DEFB 'H'  ; 0x30 Keycode.k_h
    .DEFB 'J'  ; 0x31 Keycode.k_j
    .DEFB 'K'  ; 0x32 Keycode.k_k
    .DEFB 'L'  ; 0x33 Keycode.k_l
    .DEFB ':'  ; 0x34 Keycode.semicolon
    .DEFB '"'  ; 0x35 Keycode.apostrophe
    .DEFB '\n' ; 0x36 Keycode.enter

    ; Fourth Row
    .DEFB '\0' ; 0x37 Keycode.lshift
    .DEFB 'Z'  ; 0x38 Keycode.k_z
    .DEFB 'X'  ; 0x39 Keycode.k_x
    .DEFB 'C'  ; 0x3A Keycode.k_c
    .DEFB 'V'  ; 0x3B Keycode.k_v
    .DEFB 'B'  ; 0x3C Keycode.k_b
    .DEFB 'N'  ; 0x3D Keycode.k_n
    .DEFB 'M'  ; 0x3E Keycode.k_m
    .DEFB '<'  ; 0x3F Keycode.comma
    .DEFB '>'  ; 0x40 Keycode.period
    .DEFB '?'  ; 0x41 Keycode.slash
    .DEFB '\0' ; 0x42 Keycode.rshift

    ; Fifth Row
    .DEFB '\0' ; 0x43 Keycode.lctrl
    .DEFB '\0' ; 0x44 Keycode.lsuper
    .DEFB '\0' ; 0x45 Keycode.lalt
    .DEFB ' '  ; 0x46 Keycode.space
    .DEFB '\0' ; 0x47 Keycode.ralt
    .DEFB '\0' ; 0x48 Keycode.rsuper
    .DEFB '\0' ; 0x49 Keycode.meta
    .DEFB '\0' ; 0x4A Keycode.rctrl

    ; Keypad
    .DEFB '0'  ; 0x4B Keycode.kp_0
    .DEFB '1'  ; 0x4C Keycode.kp_1
    .DEFB '2'  ; 0x4D Keycode.kp_2
    .DEFB '3'  ; 0x4E Keycode.kp_3
    .DEFB '4'  ; 0x4F Keycode.kp_4
    .DEFB '5'  ; 0x50 Keycode.kp_5
    .DEFB '6'  ; 0x51 Keycode.kp_6
    .DEFB '7'  ; 0x52 Keycode.kp_7
    .DEFB '8'  ; 0x53 Keycode.kp_8
    .DEFB '9'  ; 0x54 Keycode.kp_9
    .DEFB '\0' ; 0x55 Keycode.num_lock
    .DEFB '/'  ; 0x56 Keycode.kp_slash
    .DEFB '*'  ; 0x57 Keycode.kp_star
    .DEFB '-'  ; 0x58 Keycode.kp_minus
    .DEFB '+'  ; 0x59 Keycode.kp_plus
    .DEFB '\n' ; 0x5A Keycode.kp_enter
    .DEFB '.'  ; 0x5B Keycode.kp_period

    ; Navigation Cluster
    .DEFB '\0' ; 0x5C Keycode.print
    .DEFB '\0' ; 0x5D Keycode.scroll_lock
    .DEFB '\0' ; 0x5E Keycode.pause
    .DEFB '\0' ; 0x5F Keycode.insert
    .DEFB '\0' ; 0x60 Keycode.delete
    .DEFB '\0' ; 0x61 Keycode.home
    .DEFB '\0' ; 0x62 Keycode.end
    .DEFB '\0' ; 0x63 Keycode.page_up
    .DEFB '\0' ; 0x64 Keycode.page_down
    .DEFB '\0' ; 0x65 Keycode.arrow_up
    .DEFB '\0' ; 0x66 Keycode.arrow_left
    .DEFB '\0' ; 0x67 Keycode.arrow_down
    .DEFB '\0' ; 0x68 Keycode.arrow_right
    .size: .EQU $-kc_to_shift_ascii

; Keycodes affected by Caps Lock
alpha_kc:
    .DEFB Keycode.k_a
    .DEFB Keycode.k_b
    .DEFB Keycode.k_c
    .DEFB Keycode.k_d
    .DEFB Keycode.k_e
    .DEFB Keycode.k_f
    .DEFB Keycode.k_g
    .DEFB Keycode.k_h
    .DEFB Keycode.k_i
    .DEFB Keycode.k_j
    .DEFB Keycode.k_k
    .DEFB Keycode.k_l
    .DEFB Keycode.k_m
    .DEFB Keycode.k_n
    .DEFB Keycode.k_o
    .DEFB Keycode.k_p
    .DEFB Keycode.k_q
    .DEFB Keycode.k_r
    .DEFB Keycode.k_s
    .DEFB Keycode.k_t
    .DEFB Keycode.k_u
    .DEFB Keycode.k_v
    .DEFB Keycode.k_w
    .DEFB Keycode.k_x
    .DEFB Keycode.k_y
    .DEFB Keycode.k_z
    .size: .EQU $-alpha_kc

; Keycodes affected by Num Lock
kp_kc:
    .DEFB Keycode.kp_0
    .DEFB Keycode.kp_1
    .DEFB Keycode.kp_2
    .DEFB Keycode.kp_3
    .DEFB Keycode.kp_4
    .DEFB Keycode.kp_5
    .DEFB Keycode.kp_6
    .DEFB Keycode.kp_7
    .DEFB Keycode.kp_8
    .DEFB Keycode.kp_9
    .DEFB Keycode.kp_period
    .size: .EQU $-kp_kc
