;******************************************************************************
; File: ivt.m4
; The starting IVT stored in ROM
;******************************************************************************

default_isr:
    EI
    RETI

default_service_handler:
    SCF
    LD A, errors.not_implemented
    RET

rom_ivt:
    .DEFD start                         ; 0x00: Reset
    .DEFD default_isr                   ; 0x01: IM 1, reserved
    .DEFD memory_parity_error_handler   ; 0x02: NMI (Memory Parity Error)
    .DEFD default_isr                   ; 0x03: Reserved
    .DEFD default_isr                   ; 0x04: Reserved
    .DEFD default_isr                   ; 0x05: Reserved
    .DEFD default_isr                   ; 0x06: Reserved
    .DEFD default_isr                   ; 0x07: Reserved
    .DEFD default_isr                   ; 0x08: Reserved
    .DEFD default_isr                   ; 0x09: Reserved
    .DEFD default_isr                   ; 0x0A: Reserved
    .DEFD default_isr                   ; 0x0B: Reserved
    .DEFD default_isr                   ; 0x0C: Reserved
    .DEFD default_isr                   ; 0x0D: Reserved
    .DEFD default_isr                   ; 0x0E: Reserved
    .DEFD default_isr                   ; 0x0F: Reserved
    .DEFD default_isr                   ; 0x10: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x11: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x12: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x13: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x14: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x15: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x16: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x17: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x18: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x19: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x1A: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x1B: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x1C: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x1D: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x1E: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x1F: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x20: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x21: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x22: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x23: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x24: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x25: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x26: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x27: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x28: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x29: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x2A: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x2B: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x2C: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x2D: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x2E: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x2F: Integrated Device Interrupt
    .DEFD default_isr                   ; 0x30: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x31: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x32: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x33: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x34: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x35: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x36: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x37: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x38: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x39: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x3A: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x3B: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x3C: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x3D: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x3E: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x3F: Slot 1 Interrupt
    .DEFD default_isr                   ; 0x40: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x41: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x42: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x43: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x44: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x45: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x46: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x47: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x48: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x49: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x4A: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x4B: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x4C: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x4D: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x4E: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x4F: Slot 2 Interrupt
    .DEFD default_isr                   ; 0x50: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x51: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x52: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x53: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x54: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x55: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x56: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x57: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x58: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x59: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x5A: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x5B: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x5C: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x5D: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x5E: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x5F: Slot 3 Interrupt
    .DEFD default_isr                   ; 0x60: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x61: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x62: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x63: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x64: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x65: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x66: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x67: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x68: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x69: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x6A: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x6B: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x6C: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x6D: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x6E: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x6F: Slot 4 Interrupt
    .DEFD default_isr                   ; 0x70: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x71: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x72: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x73: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x74: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x75: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x76: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x77: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x78: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x79: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x7A: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x7B: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x7C: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x7D: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x7E: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x7F: Slot 5 Interrupt
    .DEFD default_isr                   ; 0x80: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x81: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x82: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x83: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x84: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x85: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x86: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x87: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x88: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x89: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x8A: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x8B: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x8C: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x8D: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x8E: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x8F: Slot 6 Interrupt
    .DEFD default_isr                   ; 0x90: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x91: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x92: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x93: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x94: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x95: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x96: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x97: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x98: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x99: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x9A: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x9B: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x9C: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x9D: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x9E: Slot 7 Interrupt
    .DEFD default_isr                   ; 0x9F: Slot 7 Interrupt
    .DEFD default_isr                   ; 0xA0: Reserved
    .DEFD default_isr                   ; 0xA1: Reserved
    .DEFD default_isr                   ; 0xA2: Reserved
    .DEFD default_isr                   ; 0xA3: Reserved
    .DEFD default_isr                   ; 0xA4: Reserved
    .DEFD default_isr                   ; 0xA5: Reserved
    .DEFD default_isr                   ; 0xA6: Reserved
    .DEFD default_isr                   ; 0xA7: Reserved
    .DEFD default_isr                   ; 0xA8: Reserved
    .DEFD default_isr                   ; 0xA9: Reserved
    .DEFD default_isr                   ; 0xAA: Reserved
    .DEFD default_isr                   ; 0xAB: Reserved
    .DEFD default_isr                   ; 0xAC: Reserved
    .DEFD default_isr                   ; 0xAD: Reserved
    .DEFD default_isr                   ; 0xAE: Reserved
    .DEFD default_isr                   ; 0xAF: Reserved
    .DEFD default_isr                   ; 0xB0: Reserved
    .DEFD default_isr                   ; 0xB1: Reserved
    .DEFD default_isr                   ; 0xB2: Reserved
    .DEFD default_isr                   ; 0xB3: Reserved
    .DEFD default_isr                   ; 0xB4: Reserved
    .DEFD default_isr                   ; 0xB5: Reserved
    .DEFD default_isr                   ; 0xB6: Reserved
    .DEFD default_isr                   ; 0xB7: Reserved
    .DEFD default_isr                   ; 0xB8: Reserved
    .DEFD default_isr                   ; 0xB9: Reserved
    .DEFD default_isr                   ; 0xBA: Reserved
    .DEFD default_isr                   ; 0xBB: Reserved
    .DEFD default_isr                   ; 0xBC: Reserved
    .DEFD default_isr                   ; 0xBD: Reserved
    .DEFD default_isr                   ; 0xBE: Reserved
    .DEFD default_isr                   ; 0xBF: Reserved
    .DEFD default_service_handler       ; 0xC0: System Services TODO
    .DEFD default_service_handler       ; 0xC1: Disk Services TODO
    .DEFD default_service_handler       ; 0xC2: Port Services TODO
    .DEFD default_service_handler       ; 0xC3: Keyboard Services TODO
    .DEFD default_service_handler       ; 0xC4: Video Services TODO
    .DEFD default_service_handler       ; 0xC5: Time Services TODO
    .DEFD default_service_handler       ; 0xC6: Sound Services TODO
    .DEFD default_service_handler       ; 0xC7: Reserved
    .DEFD default_service_handler       ; 0xC8: Reserved
    .DEFD default_service_handler       ; 0xC9: Reserved
    .DEFD default_service_handler       ; 0xCA: Reserved
    .DEFD default_service_handler       ; 0xCB: Reserved
    .DEFD default_service_handler       ; 0xCC: Reserved
    .DEFD default_service_handler       ; 0xCD: Reserved
    .DEFD default_service_handler       ; 0xCE: Reserved
    .DEFD default_service_handler       ; 0xCF: Reserved
    .DEFD default_service_handler       ; 0xD0: Vendor Extension Services
    .DEFD default_service_handler       ; 0xD1: Vendor Extension Services
    .DEFD default_service_handler       ; 0xD2: Vendor Extension Services
    .DEFD default_service_handler       ; 0xD3: Vendor Extension Services
    .DEFD default_service_handler       ; 0xD4: Vendor Extension Services
    .DEFD default_service_handler       ; 0xD5: Vendor Extension Services
    .DEFD default_service_handler       ; 0xD6: Vendor Extension Services
    .DEFD default_service_handler       ; 0xD7: Vendor Extension Services
    .DEFD default_service_handler       ; 0xD8: Vendor Extension Services
    .DEFD default_service_handler       ; 0xD9: Vendor Extension Services
    .DEFD default_service_handler       ; 0xDA: Vendor Extension Services
    .DEFD default_service_handler       ; 0xDB: Vendor Extension Services
    .DEFD default_service_handler       ; 0xDC: Vendor Extension Services
    .DEFD default_service_handler       ; 0xDD: Vendor Extension Services
    .DEFD default_service_handler       ; 0xDE: Vendor Extension Services
    .DEFD default_service_handler       ; 0xDF: Vendor Extension Services
    .DEFD default_service_handler       ; 0xE0: Reserved
    .DEFD default_service_handler       ; 0xE1: Reserved
    .DEFD default_service_handler       ; 0xE2: Reserved
    .DEFD default_service_handler       ; 0xE3: Reserved
    .DEFD default_service_handler       ; 0xE4: Reserved
    .DEFD default_service_handler       ; 0xE5: Reserved
    .DEFD default_service_handler       ; 0xE6: Reserved
    .DEFD default_service_handler       ; 0xE7: Reserved
    .DEFD default_service_handler       ; 0xE8: Reserved
    .DEFD default_service_handler       ; 0xE9: Reserved
    .DEFD default_service_handler       ; 0xEA: Reserved
    .DEFD default_service_handler       ; 0xEB: Reserved
    .DEFD default_service_handler       ; 0xEC: Reserved
    .DEFD default_service_handler       ; 0xED: Reserved
    .DEFD default_service_handler       ; 0xEE: Reserved
    .DEFD default_service_handler       ; 0xEF: Reserved
    .DEFD default_service_handler       ; 0xF0: OS Services
    .DEFD default_service_handler       ; 0xF1: OS Services
    .DEFD default_service_handler       ; 0xF2: OS Services
    .DEFD default_service_handler       ; 0xF3: OS Services
    .DEFD default_service_handler       ; 0xF4: OS Services
    .DEFD default_service_handler       ; 0xF5: OS Services
    .DEFD default_service_handler       ; 0xF6: OS Services
    .DEFD default_service_handler       ; 0xF7: OS Services
    .DEFD default_service_handler       ; 0xF8: OS Services
    .DEFD default_service_handler       ; 0xF9: OS Services
    .DEFD default_service_handler       ; 0xFA: OS Services
    .DEFD default_service_handler       ; 0xFB: OS Services
    .DEFD default_service_handler       ; 0xFC: OS Services
    .DEFD default_service_handler       ; 0xFD: OS Services
    .DEFD default_service_handler       ; 0xFE: OS Services
    .DEFD default_service_handler       ; 0xFF: OS Services
