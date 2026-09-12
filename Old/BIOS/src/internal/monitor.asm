;******************************************************************************
; File: monitor.asm
; The ROM montior program, started if no bootable disk is found.
;******************************************************************************

;*******************************************************************************
; Function:
;  void monitor(void)
; Arguments:
;  void
; Returns:
;  N/A
;*******************************************************************************
monitor:
    LD IY, mem.gp_base
    LD SP, mem.ram_end
    LD A, '\n'
    CR putc

    XOR HL, HL                          ; Zero out important bits
    LD.W [IY+gp.mon_argc], L
    LD.D [IY+gp.mon_address], HL
    LD.D [IY+gp.mon_count], 16          ; Default to print 16 bytes

    LD HL, str_mon_intro                ; Print intro message
    CR puts
.loop:
    LD.B [IY+gp.mon_error], 0           ; Clear error from last run
    LD HL, str_mon_cursor               ; Print cursor
    CR puts

    CR getline                          ; Read a line from the input
    CR tokenize                         ; Convert it to tokens

    LD.W A, [IY+gp.mon_argc]            ; Get argument count
    JAZ .loop                           ; If no arguments, continue

    CP.B [IY+gp.mon_error], 0           ; If error set, continue
    JR.B NZ, .loop

    ; char mode = argv[0][0]
    LD HL, mem.gp_base+gp.mon_argv      ; HL = &argv[0]
    LD.D HL, [HL]                       ; HL = argv[0]
    LD.B A, [HL]                        ; A = argv[0][0]

    CP.B A, 'H'                         ; H = Help
    JR.B NZ, .read_case
    CR cmdhelp
    JR.B .loop
.read_case:
    CP.B A, 'R'                         ; R = Read
    JR.B NZ, .write_case
    CR cmdread
    JR.B .loop
.write_case:
    CP.B A, 'W'                         ; W = Write
    JR.B NZ, .jump_case
    CR Z, cmdwrite
    JR.B .loop
.jump_case:
    CP.B A, 'J'                         ; J = Jump
    JR.B NZ, .default_case
    CR cmdjump
    JR.B .loop
.default_case:                          ; Echo '\n' + argv[0] + ?
    LD DE, HL
    LD.B A, '\n'
    CR putc
    LD HL, DE
    CR puts
    LD.B A, '?'
    CR putc
    JR.B .loop
.end:
    HALT
    JR.B .end



;*******************************************************************************
; Function:
;  void getline(void)
; Arguments:
;  void
; Returns:
;  void
;*******************************************************************************
getline:
    PUSH BC
    PUSH DE

    LD BC, mem.gp_base + gp.mon_line    ; Base pointer
    LD DE, BC                           ; Running pointer

    XOR A, A
    LD.B [DE], A                        ; Add null terminator to line[0]
.loop:
    CR getc                             ; Get character in A
    CP.B A, '\n'                        ; Newline?
    JR.B Z, .end                        ; Yes, end
    CP.B A, '\b'                        ; Backspace?
    JR.B NZ, .standard                  ; No, handle normally
.backspace:
    CP DE, BC                           ; If base == current, no chars to erase
    JR.B Z, .loop
    DEC DE                              ; Decrement current
    LD HL, str_mon_backspace            ; Print "\b \b"
    CR puts
    JR.B .loop                          ; Continue
.standard:
    ; If (current - base >= line_buffer_count - 1) continue
    LD HL, DE
    SUB HL, BC
    CP HL, mon.line_buffer_count-1
    JR.B NC, .loop
    LD.B [DE], A                        ; Put char in line[line_idx]
    INC DE                              ; Increment current
    CR putc                             ; Echo char back
    JR.B .loop                          ; Continue
.end:
    LD.B [DE], 0                        ; Add null terminator to end

    POP DE
    POP BC
    RET



;*******************************************************************************
; Function:
;  void tokenize(void)
; Arguments:
;  void
; Returns:
;  void
;*******************************************************************************
tokenize:
    PUSH BC
    PUSH DE

    LD B, 1                             ; Does next char start argument?
    LD HL, mem.gp_base+gp.mon_line      ; Char pointer
    LD DE, mem.gp_base+gp.mon_argv      ; Argument pointer
    XOR C, C                            ; Argument count
.loop:
    LD.B A, [HL]                        ; Get char
    JAZ .end                            ; If null terminator, end.
    CP.B A, ' '                         ; Space?
    JR.B NZ, .handle_char               ; No, handle char
    LD.B [HL], 0                        ; Replace space with null
    INC B                               ; Next char starts argument
    JR.B .iterate                       ; Iterate
.handle_char:
    TST B, B                            ; Does this char start an argument?
    JR.B Z, .iterate                    ; No, iterate
    CP C, mon.args_buffer_count         ; Are we at max arg count?
    JR.B NZ, .add_arg                   ; No, add this as argument
    LD HL, str_mon_too_many_args        ; Print "Too many args"
    CR puts
    LD.B [IY+gp.mon_error], 1           ; Set error flag
    JR.B .end                           ; Return
.add_arg:
    LD.D [DE], HL                       ; Arg = char address
    INC C                               ; Increment arg count
    ADD DE, 4                           ; Point to next arg
    XOR B, B                            ; Next char does not start argument
.iterate:
    INC HL                              ; Point to next char
    JR.B .loop                          ; Loop
.end:
    LD.W [IY+gp.mon_argc], C            ; Save argc

    POP DE
    POP BC
    RET



;*******************************************************************************
; Function:
;  unsigned long parsehex(const char *s)
; Arguments:
;  HL = const char *s
; Returns:
;  HL = unsigned long
;*******************************************************************************
parsehex:
    PUSH BC                             ; CRee-saved register
    PUSH DE
    LD B, 9                             ; Max digits+1
    XOR DE, DE                          ; Initialize value
.loop:
    LD.B A, [HL]                        ; Load character
    TST.B A, A                          ; Null?
    JR.B Z, .end                        ; Yes, end.
.check_digit:
    CP.B A, '0'-1                       ; >= '0'?
    JR.B C, .check_upper                ; No, next check
    CP.B A, '9'+1                       ; Yes, <= '9'?
    JR.B NC, .check_upper               ; No, next check
    SUB.B A, '0'                        ; Yes, make digit
    JR.B .iterate                       ; Iterate
.check_upper:
    CP.B A, 'A'-1                       ; >= 'A'?
    JR.B C, .check_lower                ; No, next check
    CP.B A, 'F'+1                       ; Yes, <= 'F'?
    JR.B NC, .check_lower               ; No, next check
    SUB.B A, 'A'-10                     ; Yes, make digit
    JR.B .iterate                       ; Iterate
.check_lower:
    CP.B A, 'a'-1                       ; >= 'a'?
    JR.B C, .error                      ; No, error
    CP.B A, 'f'+1                       ; Yes, <= 'f'?
    JR.B NC, .error                     ; No, error
    SUB.B A, 'a'-10                     ; Yes, make digit
.iterate:
    INC HL                              ; Increment pointer
    SLA DE, 4                           ; Shift value by 1 digit
    OR.B E, A                           ; OR onto value
    DJNZ .loop                          ; If can fit more digits, continue
.error:                                 ; Else, error, ran out of space
    LD.B [IY+gp.mon_error], 1           ; Error happened
    LD DE, HL                           ; Save string pointer
    LD A, '\n'                          ; Print newline
    CR putc
    LD HL, DE                           ; Restore string pointer
    CR puts                             ; Print error part of string
    LD A, '?'                           ; Print '?'
    CR putc                             ; Fallthrough to end
.end:
    LD HL, DE                           ; Move to return value
    POP DE
    POP BC
    RET



;*******************************************************************************
; Function:
;  void putaddress(void)
; Arguments:
;  void
; Returns:
;  void
;*******************************************************************************
putaddress:
    LD.B A, '\n'
    CR putc
    LD.D HL, [IY+gp.mon_address]
    LD A, 8
    CR puthex
    LD.B A, ':'
    CR putc
    LD.B A, ' '
    CR putc
    RET



;*******************************************************************************
; Function:
;  void cmdhelp(void)
; Arguments:
;  void
; Returns:
;  void
;*******************************************************************************
cmdhelp:
    LD HL, str_mon_help
    CR puts
    RET



;*******************************************************************************
; Function:
;  void cmdread(void)
; Arguments:
;  void
; Returns:
;  void
;*******************************************************************************
cmdread:
    PUSH BC
    PUSH DE

    LD.W C, [IY+gp.mon_argc]            ; Get argument count
    CP C, 4                             ; >3 arguments?
    JR.B C, .parse_address              ; No, check address
    LD HL, str_mon_too_many_args        ; Yes, print error
    CR puts
    JR.B .end
.parse_address:
    CP C, 2                             ; >2 arguments?
    JR.B C, .setup_loop                 ; No, go to loop
    LD DE, mem.gp_base+gp.mon_argv      ; Yes, parse argv[1] as address
    LEA DE, 1, DWORD                    ; Add 4 fast (click here to learn how!)
    LD HL, [DE]                         ; HL = &argv[1]
    CR parsehex                         ; Parse
    CP.B [IY+gp.mon_error], 0           ; Did it succeed?
    JR.B NZ, .end                       ; No, return
    LD.D [IY+gp.mon_address], HL        ; Yes, set current address
.parse_count:
    CP C, 3                             ; 3 arguments?
    JR.B NZ, .setup_loop                ; No, go to loop
    LEA DE, 1, DWORD                    ; Add 4 fast 2
    LD HL, [DE]                         ; HL = &argv[2]
    CR parsehex                         ; Parse
    CP.B [IY+gp.mon_error], 0           ; Did it succeed?
    JR.B NZ, .end                       ; No, return
    TST L, L                            ; Is the count zero?
    JR.B NZ, .set_count                 ; No, just set
    INC L                               ; Yes, min 1 byte
.set_count:
    LD.W [IY+gp.mon_count], L           ; Yes, set current count (truncated)
.setup_loop:
    XOR C, C                            ; Up counter (for printing address)
    LD.W B, [IY+gp.mon_count]           ; Counter
    LD.D DE, [IY+gp.mon_address]        ; Address
.loop:
    AND C, 0b111                        ; %8 == 0?
    JR.B NZ, .print_byte                ; No, print next byte
    LD.D [IY+gp.mon_address], DE        ; Yes, save current address
    CR putaddress                       ; Print address
.print_byte:
    XOR HL, HL                          ; Clear value
    LD.B L, [DE]                        ; Load current byte
    LD A, 2                             ; Print 2 digits
    CR puthex
    LD.B A, ' '                         ; Space in between
    CR putc
    INC DE                              ; Increment pointer
    INC C                               ; Increment up counter
    DJNZ .loop
    LD.D [IY+gp.mon_address], DE        ; Save final address
.end:
    POP DE
    POP BC
    RET



;*******************************************************************************
; Function:
;  void cmdwrite(void)
; Arguments:
;  void
; Returns:
;  void
;*******************************************************************************
cmdwrite:
    PUSH BC
    PUSH DE
    LD B, 1                             ; Current arg (skip command)
    LD.W C, [IY+gp.mon_argc]            ; Get argument count
    CP C, 2                             ; >1 arguments?
    JR.B C, .setup_loop                 ; No, jump to interactive
.parse_address:
    LD DE, mem.gp_base+gp.mon_argv      ; Yes, parse argv[1] as address
    LEA DE, 1, DWORD                    ; Add 4 fast (click here to learn how!)
    LD HL, [DE]                         ; HL = &argv[1]
    CR parsehex                         ; Parse
    CP.B [IY+gp.mon_error], 0           ; Did it succeed?
    JR.B NZ, .end                       ; No, return
    LD.D [IY+gp.mon_address], HL        ; Yes, set current address
    INC B                               ; Increment current arg (skip address)
.setup_loop:
    LD DE, [IY+gp.mon_address]          ; Load address
.loop:
    XOR HL, HL                          ; Clear value
    CP B, C                             ; Current == argc?
    JR.B NZ, .load_arg                  ; No, load argument
.get_new_line:                          ; Yes, get new line
    LD.D [IY+gp.mon_address], DE        ; Save current address
    CR putaddress                       ; Print address as prompt
    CR getline                          ; Read new line
    CR tokenize                         ; Tokenize it
    CP.B [IY+gp.mon_error], 0           ; Error?
    JR.B NZ, .end                       ; Yes, end
    XOR B, B                            ; Reset current arg
    LD C, [IY+gp.mon_argc]              ; Load new argc
.load_arg:
    LD HL, mem.gp_base+gp.mon_argv      ; HL = argv
    LEA HL, B, DWORD                    ; HL = &argv[current_arg]
    LD.D HL, [HL]                       ; HL = argv[current_arg]
    LD.B A, [HL]                        ; A = argv[current_arg][0]
    CP.B A, '.'                         ; Stop char?
    JR.B Z, .endloop                    ; Yes, done.
.parse_value:
    CR parsehex                         ; No, parse argv[current_arg] as hex
    CP.B [IY+gp.mon_error], 0           ; Error?
    JR.B Z, .store_value                ; No, store byte
    LD.B [IY+gp.mon_error], 0           ; Yes, clear flag
    JR.B .get_new_line                  ; Force redo of line after failed byte
.store_value:
    CP HL, 0xFF                         ; >255?
    JR.B C, .no_truncate                ; No, store normally
    PUSH HL                             ; Yes, print warning
    LD HL, str_mon_truncated_to_byte
    CR puts
    POP HL
.no_truncate:
    LD.B [DE], L                        ; Store parsed value
    INC DE                              ; Increment pointer
    INC B                               ; Increment current arg
    JR.B .loop                          ; Iterate
.endloop:
    LD.D [IY+gp.mon_address], DE        ; Save final address
.end:
    POP DE
    POP BC
    RET



;*******************************************************************************
; Function:
;  void cmdjump(void)
; Arguments:
;  void
; Returns:
;  void
;*******************************************************************************
cmdjump:
    PUSH BC
    PUSH DE

    LD.W C, [IY+gp.mon_argc]            ; Get argument count
    CP C, 3                             ; >2 arguments?
    JR.B C, .parse_address              ; No, check address
    LD HL, str_mon_too_many_args        ; Yes, print error
    CR puts
    JR.B .end
.parse_address:
    CP C, 2                             ; >2 arguments?
    JR.B C, .jump                       ; No, go to jump
    LD DE, mem.gp_base+gp.mon_argv      ; Yes, parse argv[1] as address
    LEA DE, 1, DWORD                    ; Add 4 fast (click here to learn how!)
    LD HL, [DE]                         ; HL = &argv[1]
    CR parsehex                         ; Parse
    CP.B [IY+gp.mon_error], 0           ; Did it succeed?
    JR.B NZ, .end                       ; No, return
    LD.D [IY+gp.mon_address], HL        ; Yes, set current address
.jump:
    LD.D HL, [IY+gp.mon_address]        ; Load address
    CALL HL                             ; Call address
    ; if the CRed program returns
    LD B, A                             ; Save return value
    LD HL, str_mon_returned             ; Print "\nReturned: "
    CR puts
    XOR HL, HL                          ; Clear value
    LD L, B                             ; Print return value
    LD A, 4                             ; 4 digits
    CR puthex
    LD.B A, '\n'                        ; Print newline
    CR putc
    JR monitor                          ; Restart monitor
.end:
    POP DE
    POP BC
    RET
