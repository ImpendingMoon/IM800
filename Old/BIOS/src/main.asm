;*******************************************************************************
; File: main.asm
; Includes all other files
;*******************************************************************************

    .ORG 0
reset_vector:
    .DEFD start

.checksum:
    .DEFD 0                             ; Filled in after assembly

%include "internal/constants.asm"
%include "internal/start.asm"
%include "internal/functions.asm"
%include "internal/monitor.asm"
%include "internal/diagnostics.asm"
%include "internal/ivt.asm"
%include "internal/strings.asm"
%include "service/core.asm"

    .ALIGN 2
bios_length: .EQU $
