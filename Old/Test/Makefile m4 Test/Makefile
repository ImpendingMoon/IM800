M4 ?= m4
ASSEMBLER ?= IM800Asm
EMULATOR ?= IM800Emu

PROGRAM_NAME := program

SRC_DIR := src
BUILD_DIR := build

MAIN := $(SRC_DIR)/main.m4

EXPANDED := $(BUILD_DIR)/${PROGRAM_NAME}_expanded.asm
BIN := $(BUILD_DIR)/$(PROGRAM_NAME).bin
SYMBOLS := $(BUILD_DIR)/$(PROGRAM_NAME).sym
LISTING := $(BUILD_DIR)/$(PROGRAM_NAME).lst

# Include all source files as dependencies to watch
M4_SOURCES := $(shell find $(SRC_DIR) -name '*.m4')

.PHONY: all run clean

all: $(BIN)

$(BUILD_DIR):
	mkdir -p $@

# Expand m4 into a single assembly source
$(EXPANDED): $(MAIN) $(M4_SOURCES) | $(BUILD_DIR)
	$(M4) $(MAIN) > $@ -I src

$(BIN): $(EXPANDED)
	$(ASSEMBLER) -o $(BIN) -s $(SYMBOLS) -l $(LISTING) $<

run: $(BIN)
	$(EMULATOR) $(BIN) $(SYMBOLS)

clean:
	rm -rf $(BUILD_DIR)
