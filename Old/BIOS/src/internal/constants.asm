;*******************************************************************************
; File: constants.asm
; Constant values
;*******************************************************************************

errors:
    .ok: .EQU 0
    .unknown: .EQU 1
    .not_inplemented: .EQU 2

mem:
    .ivt_base: .EQU 0x10000
    .gp_base: .EQU 0x10400
    .stack_top: .EQU 0x11000
    .exp_base: .EQU 0x040000
    .ram_start: .EQU 0x200000
    .ram_end: .EQU 0x204000

exp:
    .stride: .EQU 0x040000
    .max_slots: .EQU 7
    .magic_value: .EQU 0x44505845

mon:
    .line_buffer_count: .EQU 80
    .args_buffer_count: .EQU 16

exp_header:
    .magic: .EQU 0
    .checksum: .EQU .magic + 4
    .length: .EQU .checksum + 4
    .version: .EQU .length + 4
    .vendor: .EQU .version + 2
    .device: .EQU .vendor + 4
    .init_offset: .EQU .device + 2
    .shutdown_offset: .EQU .init_offset + 4
    .reserved: .EQU .shutdown_offset + 4
    ._size: .EQU 64

uart:
    .port_status: .EQU 0x00
    .port_rx_data: .EQU 0x01
    .port_tx_data: .EQU 0x02
    .status_rx_ready: .EQU 0x01
    .status_tx_ready: .EQU 0x02

gp:
    .exp_presence: .EQU 0
    .exp_error: .EQU .exp_presence + 1
    .mon_argc: .EQU .exp_error + 1
    .mon_address: .EQU .mon_argc + 1
    .mon_count: .EQU .mon_address + 4
    .mon_argv: .EQU .mon_count + 4
    .mon_line: .EQU .mon_argv + (4 * mon.args_buffer_count)
    .mon_error: .EQU .mon_line + mon.line_buffer_count
    .mem_size: .EQU .mon_error + 1
    ._size: .EQU .mem_size + 4

bios_api_version: .EQU 1
bios_vendor: .EQU 0 ; I am Vendor 0 :)
bios_revision: .EQU 0

machine_vendor: .EQU 0
machine_part: .EQU 0

cpu_version: .EQU 0
cpu_speed: .EQU 4000