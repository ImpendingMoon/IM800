import sys
import struct
import warnings


def fletcher32(data):
    mod = 65535
    sum1 = 0
    sum2 = 0

    if len(data) & 1:
        warnings.warn(
            "Checksum region has an odd number of bytes; "
            "hardware checksum calculation may differ."
        )
        data = data[:-1]

    for i in range(0, len(data), 2):
        word = data[i] | (data[i + 1] << 8)

        sum1 = (sum1 + word) % mod
        sum2 = (sum2 + sum1) % mod

    return (sum2 << 16) | sum1

def update_rom_checksum(filename):
    with open(filename, "rb") as f:
        rom = bytearray(f.read())

    if len(rom) < 8:
        raise ValueError("ROM file is too small.")

    # Calculate checksum only from offset 8 onward
    checksum = fletcher32(rom[8:])

    # Write checksum as little-endian 32-bit value at offsets 4-7
    rom[4:8] = struct.pack("<I", checksum)

    with open(filename, "wb") as f:
        f.write(rom)

    print(f"Fletcher-32 checksum: 0x{checksum:08X}")
    print("Wrote little-endian check value to offsets 0x04-0x07")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <rom_file>")
        sys.exit(1)

    update_rom_checksum(sys.argv[1])
