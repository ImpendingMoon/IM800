;*******************************************************************************
; constants.asm
; Constants and enums
;*******************************************************************************

; Global Pointer Structure
gp: .EQU 0x00200000
    .sc_buf_w: .EQU 0                   ; Scancode Buffer Write Index
    .sc_buf_r: .EQU .sc_buf_w + 1       ; Scancode Buffer Read Index
    .sc_buf: .EQU .sc_buf_r + 1         ; Scancode Buffer
    .keyflags: .EQU .sc_buf + 256       ; Global Keyflag tracking word
    .size: .EQU .keyflags + 2           ; Total struct size

stack_top: .EQU gp + gp.size + 256

vram: .EQU 0x00400000
    .size: .EQU 0x1000

ports:
    .vdp_mode: .EQU 0x00
    .vdp_state: .EQU 0x01
    .vdp_cur_row: .EQU 0x02
    .vdp_cur_col: .EQU 0x03
    .kbd_scancode: .EQU 0x04
    .kbd_state: .EQU 0x05

flags:
    .vdp_state_display: .EQU 0b00000001
    .vdp_state_cursor: .EQU 0b00000010
    .kbd_state_int: .EQU 0b00000001

; KeyEvent structure
KeyEvent:
    .kc: .EQU 0                         ; Keycode enum member
    .flags: .EQU .kc + 1                ; Keyflag Bitmask

ex_scancode: .EQU 0xE0
pause_scancode: .EQU 0xE1
break_bit: .EQU 0x80

Scancode: 
    .null: .EQU 0x00

; Keycodes match the physical layout of the US QWERTY 100% keyboard
; Some enum members use a "k_" prefix to avoid register name conflicts
Keycode:
    .null: .EQU 0x00

    ; Function Row
    .esc: .EQU 0x01
    .f1: .EQU 0x02
    .f2: .EQU 0x03
    .f3: .EQU 0x04
    .f4: .EQU 0x05
    .f5: .EQU 0x06
    .f6: .EQU 0x07
    .f7: .EQU 0x08
    .f8: .EQU 0x09
    .f9: .EQU 0x0A
    .f10: .EQU 0x0B
    .f11: .EQU 0x0C
    .f12: .EQU 0x0D

    ; First Row
    .grave: .EQU 0x0E
    .k_1: .EQU 0x0F
    .k_2: .EQU 0x10
    .k_3: .EQU 0x11
    .k_4: .EQU 0x12
    .k_5: .EQU 0x13
    .k_6: .EQU 0x14
    .k_7: .EQU 0x15
    .k_8: .EQU 0x16
    .k_9: .EQU 0x17
    .k_0: .EQU 0x18
    .minus: .EQU 0x19
    .equal: .EQU 0x1A
    .backspace: .EQU 0x1B

    ; Second Row
    .tab: .EQU 0x1C
    .k_q: .EQU 0x1D
    .k_w: .EQU 0x1E
    .k_e: .EQU 0x1F
    .k_r: .EQU 0x20
    .k_t: .EQU 0x21
    .k_y: .EQU 0x22
    .k_u: .EQU 0x23
    .k_i: .EQU 0x24
    .k_o: .EQU 0x25
    .k_p: .EQU 0x26
    .lbracket: .EQU 0x27
    .rbracket: .EQU 0x28
    .bslash: .EQU 0x29

    ; Third Row
    .caps_lock: .EQU 0x2A
    .k_a: .EQU 0x2B
    .k_s: .EQU 0x2C
    .k_d: .EQU 0x2D
    .k_f: .EQU 0x2E
    .k_g: .EQU 0x2F
    .k_h: .EQU 0x30
    .k_j: .EQU 0x31
    .k_k: .EQU 0x32
    .k_l: .EQU 0x33
    .semicolon: .EQU 0x34
    .apostrophe: .EQU 0x35
    .enter: .EQU 0x36

    ; Fourth Row
    .lshift: .EQU 0x37
    .k_z: .EQU 0x38
    .k_x: .EQU 0x39
    .k_c: .EQU 0x3A
    .k_v: .EQU 0x3B
    .k_b: .EQU 0x3C
    .k_n: .EQU 0x3D
    .k_m: .EQU 0x3E
    .comma: .EQU 0x3F
    .period: .EQU 0x40
    .slash: .EQU 0x41
    .rshift: .EQU 0x42

    ; Fifth Row
    .lctrl: .EQU 0x43
    .lsuper: .EQU 0x44
    .lalt: .EQU 0x45
    .space: .EQU 0x46
    .ralt: .EQU 0x47
    .rsuper: .EQU 0x48
    .meta: .EQU 0x49
    .rctrl: .EQU 0x4A

    ; Keypad
    .kp_0: .EQU 0x4B
    .kp_1: .EQU 0x4C
    .kp_2: .EQU 0x4D
    .kp_3: .EQU 0x4E
    .kp_4: .EQU 0x4F
    .kp_5: .EQU 0x50
    .kp_6: .EQU 0x51
    .kp_7: .EQU 0x52
    .kp_8: .EQU 0x53
    .kp_9: .EQU 0x54
    .num_lock: .EQU 0x55
    .kp_slash: .EQU 0x56
    .kp_star: .EQU 0x57
    .kp_minus: .EQU 0x58
    .kp_plus: .EQU 0x59
    .kp_enter: .EQU 0x5A
    .kp_period: .EQU 0x5B

    ; Navigation Cluster
    .print: .EQU 0x5C
    .scroll_lock: .EQU 0x5D
    .pause: .EQU 0x5E
    .insert: .EQU 0x5F
    .delete: .EQU 0x60
    .home: .EQU 0x61
    .end: .EQU 0x62
    .page_up: .EQU 0x63
    .page_down: .EQU 0x64
    .arrow_up: .EQU 0x65
    .arrow_left: .EQU 0x66
    .arrow_down: .EQU 0x67
    .arrow_right: .EQU 0x68

KeyFlag:
    .shift: .EQU 0x01                   ; LShift | RShift
    .ctrl: .EQU 0x02                    ; LCtrl | RCtrl
    .alt: .EQU 0x04                     ; LAlt | RAlt
    .caps: .EQU 0x08                    ; Caps Lock state
    .num: .EQU 0x10                     ; Num Lock state
    .scroll: .EQU 0x20                  ; Scroll Lock state
    .release: .EQU 0x80                 ; Key released?
    ; Only used in global state tracking to calculate combined flags
    .lshift: .EQU 0x0100                ; Left Shift
    .rshift: .EQU 0x0200                ; Right Shift
    .lctrl: .EQU 0x0400                 ; Left Ctrl
    .rctrl: .EQU 0x0800                 ; Right Ctrl
    .lalt: .EQU 0x1000                  ; Left Alt
    .ralt: .EQU 0x2000                  ; Right Alt
