;******************************************************************************
; File: core.asm
; Core BIOS services
;******************************************************************************

core_svc_dispatch:
    CP A, core_svc_table.count          ; Past table bounds?
    JR.B NC, .invalid                   ; Yes, invalid
    PUSH HL                             ; Save HL parameter
    LD HL, core_svc_dispatch            ; Load base pointer
    LEA HL, A, WORD                     ; Index into table
    LD.W A, [HL]                        ; Load relative vector
    POP HL                              ; Restore HL parameter
.target:
    JR A                                ; Jump to service, which will RET

.invalid:
    SCF                                 ; Set carry for error
    LD A, errors.not_inplemented
    RET



; Core Service Jump Vectors
; 0x00 = Get BIOS Information
; 0x01 = Get Machine Information
; 0x02 = Get CPU Information
; 0x03 = Get Memory Size
core_svc_table:
    .DEFW svc_get_bios_information - core_svc_dispatch.target
    .DEFW svc_get_machine_information - core_svc_dispatch.target
    .DEFW svc_get_cpu_information - core_svc_dispatch.target
    .DEFW svc_get_memory_size - core_svc_dispatch.target
.count: .EQU ($-core_svc_dispatch) / 2



;*******************************************************************************
; Function:
;  T get_bios_version(void)
; Arguments:
;  void
; Returns:
;  A: int BIOS API version
;  HL: int Vendor ID
;  DE: long Vendor BIOS version
;*******************************************************************************
svc_get_bios_information:
    LD A, bios_api_version
    LD HL, bios_vendor
    LD DE, bios_revision
    TST A, A                            ; Clear carry flag, no error
    RET



;*******************************************************************************
; Function:
;  T svc_get_machine_information(void)
; Arguments:
;  void
; Returns:
;  A: int Part Number
;  HL: long Vendor ID
;  DE: char* Serial Number
;*******************************************************************************
svc_get_machine_information:
    LD HL, machine_vendor
    LD A, machine_part
    LD DE, str_serial_number
    TST A, A
    RET



;*******************************************************************************
; Function:
;  void svc_get_cpu_information(void)
; Arguments:
;  void
; Returns:
;  A: int CPU ID
;  HL: long CPU speed in KHz
;*******************************************************************************
svc_get_cpu_information:
    LD A, cpu_version ; This could probably be loaded from an emulator DIP
    LD HL, cpu_speed ; This could probably be loaded from an emulator DIP
    TST A, A
    RET



;*******************************************************************************
; Function:
;  void svc_get_memory_size(void)
; Arguments:
;  void
; Returns:
;  HL: Memory size in KiB
;*******************************************************************************
svc_get_memory_size:
    PUSH IY
    LD IY, mem.gp_base
    LD.D HL, [IY+gp.mem_size]
    POP IY
    TST A, A
    RET
