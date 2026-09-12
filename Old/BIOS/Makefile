ASSEMBLER := IM800Asm
EMULATOR := IM800Emu.App
PYTHON := python

BINARY := bios

MAIN := src/main.asm

CHECKSUM := ../fletcher32.py

BUILD := build
BIN := $(BUILD)/$(BINARY).bin
SYM := $(BUILD)/$(BINARY).sym
LST := $(BUILD)/$(BINARY).lst

ASM_FILES := $(MAIN) src/internal/constants.asm src/internal/diagnostics.asm src/internal/functions.asm src/internal/ivt.asm src/internal/monitor.asm src/internal/start.asm src/internal/strings.asm src/service/core.asm

.PHONY: all clean

all: $(BIN)

$(BIN): $(ASM_FILES)
	if not exist "$(BUILD)" mkdir "$(BUILD)"
	$(ASSEMBLER) "$(MAIN)" -o "$(BIN)" -s "$(SYM)" -l "$(LST)"
	$(PYTHON) $(CHECKSUM) $(BIN)

clean:
	if exist "$(BUILD)" rmdir /S /Q "$(BUILD)"
