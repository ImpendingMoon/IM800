// Working out the keyboard driver logic for my IM800 fantasy computer
// because holy cow this is more complicated than you might think at first
// This will be rewritten in assembly

// Supports Scancode Set 1, English QWERTY keyboard, English locale
// They keyboard controller handles typematic repeat, like old XT keyboards

// This will need ~1 KiB of lookup tables.
// Stored in 256K BIOS ROM and highly used feature, so acceptable.

// One of those early firmwares that blur the line between HAL and
// generic utility services

struct KeyEvent {
	Keycode keycode;
	uint8_t flags;
}

enum KeyFlag {
	KF_SHIFT = 0x01,
	KF_CTRL = 0x02,
	KF_ALT = 0x04,
	KF_CAPS_LOCK = 0x08,
	KF_NUM_LOCK = 0x10,
	KF_SCROLL_LOCK = 0x20, // might as well track this here
	KF_RELEASED = 0x80,
	// Only used in global tracking. KeyEvents use smaller combined state
	// to make the struct fit into a register.
	KF_LSHIFT = 0x0100,
	KF_RSHIFT = 0x0200,
	KF_LCTRL = 0x0400,
	KF_RCTRL = 0x0800,
	KF_LALT = 0x1000,
	KF_RALT = 0x2000,
}

extern volatile uint8_t scancode_buffer[256];
extern volatile uint8_t sc_buffer_head;
extern volatile uint8_t sc_buffer_tail;

static uint16_t keyflags = 0;

// These two need to match the interrupt handler exactly
// Define in the internal source file, forward in public source file
bool is_scancode_ready() {
	return sc_buffer_top != sc_buffer_base;
}

static uint8_t get_next_scancode() {
	uint8_t scancode = 0;

	// Busy wait for interrupt
	// Could HALT, but requires more interrupt enable state management
	while (!is_scancode_ready());
	
	critical {
		scancode = scancode_buffer[sc_buffer_tail];
		++sc_buffer_tail;
	}
	
	return scancode;
}

static const int pause_length = 6;
static const uint8_t pause_sequence[] = {
	0xE1, 0x1D, 0x45, 0xE1, 0x9D, 0xC5,
};
static const uint8_t extended_scancode = 0xE0;
static const uint8_t break_bit = 0x80;

struct GetNextKeycodeResult {
	Keycode keycode;
	bool released;
}

static GetNextKeycodeResult get_next_keycode() {
	uint8_t scancode = SC_NULL;
	int extended_step = 0; // Boolean? Int? All the same to a register.
	int pause_step = 0;
	GetNextKeycodeResult result;
	result.released = false;
	
	while (true) {
		scancode = get_next_scancode();
		
		// Handle in-progress extended scancode
		if (extended_step != 0) {
			extended_step = 0;
		
			// Do we want to handle print here? It doesn't even
			// work in the emulator since the OS intercepts it...
			// For now it will be two keycodes and it's
			// the program's problem.
		
			// If break bit is set, clear it and set flag
			if ((scancode & break_bit) != 0) {
				scancode &= 0x7F;
				result.released = true;
			}
		
			// Lookup table conversion
			result.keycode = sc_to_kc_ext[scancode];
			break;
		}
		
		// Handle in-progress pause scancode
		if (pause_step != 0) {
			if (scancode == pause_sequence[pause_step]) {
				if (pause_step < pause_length - 1) {
					pause_step++;
					continue;
				}
				
				result.keycode = KC_PAUSE;
				break;
			} else {
				// Incomplete, fallthrough to standard case
				pause_step = 0;
			}
		}
		
		// Start of extended scancode?
		if (scancode == extended_scancode) {
			extended_step = 1;
			continue;
		}
		
		// Start of pause scancode?
		if (scancode == pause_sequence[0]) {
			pause_step = 1;
			continue;
		}
		
		// If break bit is set, clear it and set flag
		if ((scancode & break_bit) != 0) {
			scancode &= 0x7F;
			result.released = true;
		}
		
		// Lookup table conversion
		result.keycode = sc_to_kc[scancode];
		break;
	}
	
	return result;
}

static void update_keyflag_state(Keycode keycode, bool released) {
	// Set/clear released and l/r flags as needed
	if (released) {
		// Might as well set this here
		keyflags |= KF_RELEASED;
		
		switch (keycode) {
		case KC_LSHIFT:
			keyflags &= ~(KF_LSHIFT);
			break;
		case KC_RSHIFT:
			keyflags &= ~(KF_RSHIFT);
			break;
		case KC_LCTRL:
			keyflags &= ~(KF_LCTRL);
			break;
		case KC_RCTRL:
			keyflags &= ~(KF_RCTRL);
			break;
		case KC_LALT:
			keyflags &= ~(KF_LALT);
			break;
		case KC_RALT:
			keyflags &= ~(KF_RALT);
			break;
		default:
			break;
		}
	} else {
		keyflags &= ~(KF_RELEASED);
	
		switch (keycode) {
		case KC_LSHIFT:
			keyflags |= KF_LSHIFT;
			break;
		case KC_RSHIFT:
			keyflags |= KF_RSHIFT;
			break;
		case KC_LCTRL:
			keyflags |= KF_LCTRL;
			break;
		case KC_RCTRL:
			keyflags |= KF_RCTRL;
			break;
		case KC_LALT:
			keyflags |= KF_LALT;
			break;
		case KC_RALT:
			keyflags |= KF_RALT;
			break;
		// Lock keys are toggled on press
		case KC_CAPS_LOCK:
			keyflags ^= KF_CAPS_LOCK;
			break;
		case KC_NUM_LOCK:
			keyflags ^= KF_NUM_LOCK;
			break;
		case KC_SCROLL_LOCK:
			keyflags ^= KF_SCROLL_LOCK;
			break;
		default:
			break;
		}
	}
	
	// Set combined state
	keyflags &= ~(KF_SHIFT | KF_CTRL | KF_ALT);
	
	if ((keyflags & KF_LSHIFT) != 0 || (keyflags & KF_RSHIFT) != 0) {
		keyflags |= KF_SHIFT;
	}
	
	if ((keyflags & KF_LCTRL) != 0 || (keyflags & KF_RCTRL) != 0) {
		keyflags |= KF_CTRL;
	}
	
	if ((keyflags & KF_LALT) != 0 || (keyflags & KF_RALT) != 0) {
		keyflags |= KF_ALT;
	}
}

// This will block. Might want a service for is_key_ready separate from
// checking if a scancode is ready. Although having an incomplete scancode
// is very unlikely since the interrupt handler consumes all bytes available
// from the keyboard controller each invocation, and the keyboard is faster
// than the CPU
// Also not reentrant, and not possible to make reentrant. If program is using
// this in two threads it needs to synchronize itself.
// Enables interrupts
KeyEvent get_next_key_event() {
	KeyEvent keyevent;
	
	GetNextKeycodeResult keycode_result = get_next_keycode();
	update_keyflag_state(keycode_result.keycode, keycode_result.released);
	
	keyevent.keycode = keycode_result.keycode;
	// Intentionally discard the upper byte
	keyevent.flags = (uint8_t)keyflags;
	
	return keyevent;
}

static bool toggled_by_caps_lock(Keycode keycode) {
	// These should absolutely be contiguous in keycode enum
	return keycode >= KC_A && keycode <= KC_Z;
}

static bool toggled_by_num_lock(Keycode keycode) {
	// Order enum for number pad like: 0,1,2,3,4,5,6,7,8,9,PERIOD
	return keycode >= KC_NP_0 && keycode <= KC_NP_PERIOD;
}

// Non-trivial at 4 MHz, so we keep this as a separate service so we don't
// slow down every key event calculation
char get_ascii(KeyEvent keyevent) {
	// Number pad logic
	if (toggled_by_num_lock(keyevent.keycode) {
		if ((keyevent.flags & KF_NUM_LOCK) != 0) {
			// Enables numbers and period
			return kc_to_ascii_num_locked[keyevent.keycode];
		}
		// Mostly non-printable
		return kc_to_ascii[keyevent.keycode];
	}

	// Shifted logic
	if ((keyevent.flags & KF_SHIFT) != 0) {
		// Caps lock returns alpha keys to non-shifted
		if ((keyevent.flags & KF_CAPS_LOCK) != 0
			&& toggled_by_caps_lock(keyevent.keycode)
		) {
			return kc_to_ascii[keyevent.keycode];
		}
		
		return kc_to_ascii_shifted[keyevent.keycode];
	}
	
	// Regular logic
	
	// Caps lock sets alpha keys to shifted
	if ((keyevent.flags & KF_CAPS_LOCK) != 0
		&& toggled_by_caps_lock(keyevent.keycode)
	) {
		return kc_to_ascii_shifted[keyevent.keycode];
	}
	
	return kc_to_ascii[keyevent.keycode];
}

// Do we want to maintain a key_down state? ~128 bytes of RAM of 4K BIOS RAM
// For now programs can deal with it themselves

