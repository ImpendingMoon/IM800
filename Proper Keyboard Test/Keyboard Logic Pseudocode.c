// Keyboard handling pseudocode
// Because it's remarkably complicated with state tracking and two conversions
// AND this only handles English keyboards and locale
// what the hell man
// Also this doesn't compile so don't try

enum Scancodes {
	SC_ESCAPE = 0x01,
	//...
};

enum Keycodes {
	KC_NULL = 0x00,
	KC_ESCAPE = 0x01,
	//...
};

enum KeyFlagMask {
	KF_SHIFT = 0x01,
	KF_CTRL = 0x02,
	KF_ALT = 0x04,
	KF_CAPS_LOCK = 0x08,
	KF_NUM_LOCK = 0x10,
	KF_BREAK = 0x80,
	// Global state needs to track if either left or right keys are pressed
	// Individual key events will only use combined state
	KF_LSHIFT = 0x100,
	KF_RSHIFT = 0x200,
	KF_LALT = 0x400
	KF_RALT = 0x800,
	KF_RCTRL = 0x1000,
	KF_RCTRL = 0x2000,
};

struct KeyEvent {
	char ascii;
	char flags;
	char keycode;
};

static uint8_t sc_to_kc_map[] = {
	[SC_ESCAPE] = [KC_ESCAPE],
};

static uint8_t sc_ext_to_kc_map[] = {
	[SC_RSHIFT] = [KC_RSHIFT],
}

static char kc_to_ascii_map[] = {
	[KC_A] = 'a',
};

static char kc_to_shifted_ascii_map[] = {
	[KC_A] = 'A',
}

volatile port kbd_queue = 0x04;

static uint16_t keyflags = 0;

static const int pause_bytes = 6;

uint8_t get_scancode() {
	// This would be replaced with a ring buffer
	// Interrupt handler just pushes scancodes to get in and out ASAP
	// Main thread converts them into key events as needed
	// This demo will just poll keyboard
	uint8_t scancode = 0;
	do {
		scancode = kbd_queue;
	} while (scancode == 0);
}

// This should be split into:
// 1. Get Keycode
// 2. Get Flags
// 3. Get ASCII
// Split into 2 BIOS services: GetKeyEvent() and GetASCII(KeyEvent)
struct KeyEvent getkeyevent() {
	// Do we want to split keycode + flags and ASCII?
	// ASCII conversion is a non-trivial step on a 4 MHz CPU
	// and we don't always want the printable character
	KeyEvent result = {
		.ascii = '\0',
		.flags = 0,
		.keycode = KC_NULL,
	};
	
	int extended_step = 0;
	int pause_step = 0;
	
	while (true) {
		uint8_t scancode = get_scancode();
		
		if (extended_step != 0) {
			// Handle extended scancode
			result.keycode = sc_ext_to_kc_map[scancode];
			extended_step == 0;
			break;
			
		}
		
		if (pause_step != 0) {
			// Handle pause scancode
			// For now just consume N bytes instead of validating 
			// sequence
			if (pause_step < pause_bytes) {
				pause_bytes++;
				continue;
			}
			result.keycode = KC_PAUSE;
			pause_step = 0;
			break;
		}
		
		if (scancode == 0xE0) {
			// Extended start byte
			extended_step = 1;
			continue;
		}
		
		if (scancode == 0xE1) {
			// Pause start byte
			pause_step = 1;
			continue;
		}
		
		// Finally, normal key
		result.keycode = sc_to_kc_map[scancode];
		break;
	}
	
	bool break_flag = false;
	// If break flag is set in the scancode
	if ((scancode & 0x80) != 0) {
		// Clear it and remember for later
		result.keycode &= 0x7F;
		break_flag = true;
	}
	
	// Set/clear ctrl, shift, alt as needed
	if (break_flag) {
		switch (keycode) {
			case KC_SHIFT:
				keyflags &= ~(KF_LSHIFT);
				break;
			case KC_CTRL:
				keyflags &= ~(KF_LCTRL);
				break;
			case KC_ALT:
				keyflags &= ~(KF_LALT);
				break;
			case KC_RSHIFT:
				keyflags &= ~(KF_RSHIFT);
				break;
			case KC_RCTRL:
				keyflags &= ~(KF_RCTRL);
				break;
			case KC_RALT:
				keyflags &= ~(KF_RALT);
				break;
			default: break;
		}
	} else {
		switch (keycode) {
			case KC_SHIFT:
				keyflags |= KF_LSHIFT;
				break;
			case KC_CTRL:
				keyflags |= KF_LCTRL;
				break;
			case KC_ALT:
				keyflags |= KF_LALT;
				break;
			case KC_RSHIFT:
				keyflags |= KF_RSHIFT;
				break;
			case KC_RCTRL:
				keyflags |= KF_RCTRL;
				break;
			case KC_RALT:
				keyflags |= KF_RALT;
				break;
			default: break;
		}
	}
	
	// Clear combined modifier flags, then set if needed
	keyflags &= ~(KF_SHIFT | KF_CTRL | KF_ALT);
	
	if ((keyflags & (KF_LSHIFT | KF_RSHIFT)) != 0) {
		keyflags |= KF_SHIFT;
	}
	
	if ((keyflags & (KF_LCTRL | KF_RCTRL)) != 0) {
		keyflags |= KF_CTRL;
	}
	
	if ((keyflags & (KF_LALT | KF_RALT)) != 0) {
		keyflags |= KF_ALT;
	}
	
	// Toggle lock keys
	if (!break_flag) {
		if (result.keycode == KC_CAPS_LOCK) {
			keyflags ^= KF_CAPS_LOCK;
		} else if (result.keycode == KC_NUM_LOCK) {
			keyflags ^= KF_NUM_LOCK;
		}
	}
	
	// Set key event flags
	result.flags = (uint8_t)keyflags;
	if (break_flag) {
		result.flags |= KF_BREAK;
	}
	
	// Set ASCII char
	// These tables should just cover the printable ASCII set and some
	// special cases for tab, enter, backspace.
	// If shift pressed
	if ((keyflags & KF_SHIFT) != 0) {
		// If caps lock is set and key is in alphabet, lowercase
		if ((keyflags & KF_CAPS_LOCK) != 0
			&& result.keycode > KC_A 
			&& result.keycode <= KC_Z
		) {
			result.ascii = kc_to_ascii[result.keycode];	
		} else {
			result.ascii = kc_to_ascii_shifted[result.keycode];
		}
	} else {
		// If caps lock is set and key is in alphabet, uppercase
		if ((keyflags & KF_CAPS_LOCK) != 0
			&& result.keycode > KC_A 
			&& result.keycode <= KC_Z
		) {
			result.ascii = kc_to_ascii_shifted[result.keycode];
		} else {
			result.ascii = kc_to_ascii[result.keycode];
		}
	}
	
	return result;
}

