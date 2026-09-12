;******************************************************************************
; File: strings.asm
; String literals
;******************************************************************************

str_exp_intro: .DEFB "Searching for expansion devices...\n",0

str_exp_found: .DEFB "Expansion found in slot ",0

str_exp_badcheck: .DEFB "Expansion with bad checksum found in slot ",0

str_mon_intro: .DEFB "IM800 ROM Monitor v1.0\n",
    "Enter 'H' for help.\n",0

str_mon_cursor: .DEFB "\n>",0

str_mon_help: .DEFB "\nCommands:\n",
    "- [R]ead:  R <address> <count>\n",
    "- [W]rite: W <address> [...bytes] .\n",
    "- [J]ump:  J <address>\n",
    "- [H]elp:  H",0

str_mon_too_many_args: .DEFB "\nToo many arguments.",0

str_mon_truncated_to_byte: .DEFB "\nValue over FF truncated to byte.",0

str_mon_returned: .DEFB "\nReturned: ",0

str_mon_backspace: .DEFB "\b \b",0

str_serial_number: .DEFB "SERIAL-NUMBER-X123",0
