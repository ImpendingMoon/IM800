;*******************************************************************************
; File: math.asm
; Basic math utility routines
; All routines use the fastcall calling convention
;*******************************************************************************

; signed char min8(signed char a, signed char b)
min8:
    CP.B A, L
    JR.B L, .noswap
    LD.B A, L
.noswap:
    RET

; int min16(int a, int b)
min:
min16:
    CP A, L
    JR.B L, .noswap
    LD.B A, L
.noswap:
    RET

; long min32(long a, long b)
min32:
    CP HL, DE
    JR.B L, .noswap
    LD HL, DE
.noswap:
    RET

; signed char max8(signed char a, signed char b)
max8:
    CP.B A, L
    JR.B GE, .noswap
    LD.B A, L
.noswap:
    RET

; int max16(int a, int b)
max:
max16:
    CP A, L
    JR.B GE, .noswap
    LD A, L
.noswap:
    RET

; long max32(long a, long b)
max32:
    CP HL, DE
    JR.B GE, .noswap
    LD HL, DE
.noswap:
    RET

; signed char clamp8(signed char value, signed char min, signed char max)
clamp8:
    ; A = max
    ; L = min
    ; H = value

    ; if (value < min) { return min; }
    CP.B H, L
    JR.B GE, .check_max
    LD.B A, L
    RET
    ; if (value < max) { return value; }
.check_max:
    CP.B H, A
    ; else { return max; }
    RET GE
    LD.B A, H
    RET

; int clamp16(int value, int min, int max)
clamp:
clamp16:
    CP H, L
    JR.B GE, .check_max
    LD A, L
    RET
.check_max:
    CP.B H, A
    RET GE
    LD A, H
    RET

; long clamp32(long value, long min, long max)
clamp32:
    ; HL = max
    ; DE = min
    ; BC = value

    CP BC, DE
    JR.B GE, .check_max
    LD HL, DE
    RET
.check_max:
    CP BC, HL
    RET GE
    LD HL, BC
    RET

; char umin8(char a, char b)
umin8:
    CP.B A, L
    JR.B C, .noswap
    LD.B A, L
.noswap:
    RET

; unsigned int umin16(unsigned int a, unsigned int b)
umin:
umin16:
    CP A, L
    JR.B C, .noswap
    LD A, L
.noswap:
    RET

; unsigned long umax32(unsigned long a, unsigned long b)
umin32:
    CP HL, DE
    JR.B NC, .noswap
    LD HL, DE
.noswap:
    RET

; char umax8(char a, char b)
umax8:
    CP.B A, L
    JR.B NC, .noswap
    LD.B A, L
.noswap:
    RET

; unsigned int umax16(unsigned int a, unsigned int b)
umax:
umax16:
    CP A, L
    JR.B NC, .noswap
    LD A, L
.noswap:
    RET

; unsigned long umax32(unsigned long a, unsigned long b)
umax32:
    CP HL, DE
    JR.B NC, .noswap
    LD HL, DE
.noswap:
    RET

; char clamp8(char value, char min, char max)
uclamp8:
    ; A = max
    ; L = min
    ; H = value

    ; if (value < min) { return min; }
    CP.B H, L
    JR.B NC, .check_max
    LD.B A, L
    RET
    ; if (value < max) { return value; }
.check_max:
    CP.B H, A
    ; else { return max; }
    RET NC
    LD.B A, H
    RET

; unsigned int uclamp16(unsigned int value, unsigned int min, unsigned int max)
uclamp:
uclamp16:
    CP H, L
    JR.B NC, .check_max
    LD A, L
    RET
.check_max:
    CP.B H, A
    RET NC
    LD A, H
    RET

; unsigned long uclamp32(unsigned long value, unsigned long min, unsigned long max)
uclamp32:
    ; HL = max
    ; DE = min
    ; BC = value

    CP BC, DE
    JR.B NC, .check_max
    LD HL, DE
    RET
.check_max:
    CP BC, HL
    RET NC
    LD HL, BC
    RET
