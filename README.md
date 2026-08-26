# AVR Assembly Projects

A collection of small AVR assembly exercises plus an EEPROM-backed oximeter/data-logger final project. Projects are structured for Atmel Studio and use register-level I/O, timers, software delays, SRAM, and EEPROM.

## Project guide

| Folder | Core mechanism | Observable result |
| --- | --- | --- |
| `Delayfunc` | Nested `DEC`/`BRNE` software-delay loops | Returns to the caller after a fixed instruction-count delay. |
| `binarytoascii` | Stack and port setup for a conversion exercise | Prepares ASCII `0` and configures three output ports; conversion logic is not yet implemented. |
| `devision` | Unsigned repeated subtraction | Divides `45` by `10`; stores remainder `5` at SRAM `0x00` and quotient `4` at `0x01`. |
| `INTRUPT1_ENHANCED` | Timer0 overflow interrupt | Toggles `PA5` in the ISR while the main loop mirrors `PINC` to `PORTD`. |
| `pulse` | Nested loops plus a short delay subroutine | Produces nested activity on `PA0`-`PD0` as a software-timed pulse pattern. |
| `oximeter-data-logger` | Keypad state machine, EEPROM, sensor sampling, seven-segment output | Saves or recalls an oximeter-style percentage measurement by keypad-selected slot. |

## Shared AVR concepts

- **Stack setup:** each standalone program starts by loading `SPH:SPL` from `RAMEND` before any `RCALL`/`RET` use.
- **Memory-mapped I/O:** port direction is configured through `DDRx`; `PORTx` writes drive outputs or enable pull-ups for inputs.
- **Timing:** these exercises use instruction-count delays or Timer0. Actual frequency depends on the selected AVR device and clock configuration.
- **Unsigned arithmetic:** the division examples use `SUB` and the carry/borrow flags instead of the hardware `DIV` instruction.

Open a folder README for register-level behavior, calling conventions, memory locations, and limitations of that specific exercise.
