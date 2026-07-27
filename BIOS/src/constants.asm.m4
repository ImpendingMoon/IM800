;******************************************************************************
; File: constants.asm.m4
; Common BIOS constants and memory layout definitions
;******************************************************************************

errors:
    .ok:                    .EQU 0x00  ; Operation completed successfully
    .unknown:               .EQU 0x01  ; Unknown error
    .not_implemented:       .EQU 0x02  ; Function not implemented
    .invalid_parameter:     .EQU 0x03  ; Invalid argument supplied
    .invalid_address:       .EQU 0x04  ; Invalid memory address
    .no_space:              .EQU 0x05  ; Resource allocation failed
    .checksum_failed:       .EQU 0x06  ; Integrity check failed
    .device_missing:        .EQU 0x07  ; Device/card not present
    .device_error:          .EQU 0x08  ; Hardware/device failure
    .timeout:               .EQU 0x09  ; Operation timed out
    .busy:                  .EQU 0x0A  ; Resource busy
    .buffer_too_small:      .EQU 0x0D  ; Output buffer insufficient


bios_ram:
    .base:      .EQU 0x010000
    .length:    .EQU 0x001000
    .top:       .EQU bios_ram.base + bios_ram.length

system_ram:
    .base:      .EQU 0x200000

ivt:
    .base:      .EQU bios_ram.base
    .length:    .EQU 0x0400

globals:
    .base: .EQU ivt.base + ivt.length

    .presence:      .EQU 0      ; Slot presence (b1 = slot 1, ..., b7 = slot 7)
    .device_count:  .EQU 1      ; Number of devices (8 bytes) 
    .init_errors:   .EQU 2      ; Last device error code (8 bytes)
    .last_error:    .EQU 10     ; Last BIOS error code (1 byte)



;******************************************************************************
; Expansion Slot Layout
; Each slot is 256KB apart and if present, starts with the header structure.
;******************************************************************************

ex_header:
    .magic:             .EQU 0          ; Magic number (4 bytes)
    .checksum:          .EQU 4          ; Fletcher-32 checksum (4 bytes)
    .rom_length:        .EQU 8          ; ROM length (4 bytes)
    .api_version:       .EQU 12         ; API version (4 bytes)
    .init_offset:       .EQU 16         ; Init routine offset (4 bytes)
    .shutdown_offset:   .EQU 20         ; Shutdown routine offset (4 bytes)
    .vendor_id:         .EQU 24         ; Vendor ID (2 bytes)
    .part_id:           .EQU 26         ; Part ID (2 bytes)
    .reserved:          .EQU 28         ; Reserved area
    .size:              .EQU 64         ; Header size
    .magic_value:       .EQU 0x67808869 ; "EXPC"

ex_slots:
    .count:         .EQU 7
    .stride:        .EQU 0x040000
    .base:          .EQU 0x040000

    .slot1.base: .EQU ex_slots.base + (0 * ex_slots.stride)
    .slot2.base: .EQU ex_slots.base + (1 * ex_slots.stride)
    .slot3.base: .EQU ex_slots.base + (2 * ex_slots.stride)
    .slot4.base: .EQU ex_slots.base + (3 * ex_slots.stride)
    .slot5.base: .EQU ex_slots.base + (4 * ex_slots.stride)
    .slot6.base: .EQU ex_slots.base + (5 * ex_slots.stride)
    .slot7.base: .EQU ex_slots.base + (6 * ex_slots.stride)
