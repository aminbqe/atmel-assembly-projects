# AVR Data Logger and Oximeter

An AVR assembly-language final project that combines a matrix keypad, EEPROM-backed data logging, an oximeter-style sensor input, and two seven-segment displays. The firmware is documented from the accompanying Persian project report and the source code in this folder.

## Overview

The program accepts keypad commands, captures two sensor samples from `PINB`, calculates a percentage-style result, saves it in internal EEPROM, and displays the result on two seven-segment displays. The project was designed for simulation with Proteus and development in Atmel Studio.

## Hardware interface

| Interface | AVR connection | Purpose |
| --- | --- | --- |
| Keypad | `PORTA` | Four upper bits scan keypad rows; the lower four bits are read with pull-ups enabled. |
| Sensor input | `PINB` | Receives the two sampled sensor values. |
| Display 1 | `PORTC` | Seven-segment output; `PC7` also generates the first sensor trigger. |
| Display 2 | `PORTD` | Seven-segment output; `PD7` also generates the second sensor trigger. |
| Internal EEPROM | `EEAR`, `EEDR`, `EECR` | Stores keypad decoding data and saved measurements. |

## Startup sequence

On reset, the firmware initializes the stack, ports, the SRAM input buffer (`0x0400`), and an EEPROM lookup table for keypad decoding. The code uses EEPROM writes at startup because the original report notes that the Atmel Studio simulation did not reliably apply the expected `ESEG` initialization.

## Keypad handling

`scan_key` drives each keypad row low in turn and reads `PINA`. A pressed key is decoded by reading the preloaded EEPROM lookup table. `keypad_routine` stores decoded keys in SRAM and sets the T flag. It then waits for key release, preventing one held key from being stored repeatedly.

`readkey` retrieves the most recently stored key from the SRAM buffer. When the buffer is empty, it returns `0xFF`.

## Command state machine

The state machine in `R23` accepts the following command sequences:

| Sequence | Action |
| --- | --- |
| `A`, slot `1`-`8`, `F` | Read the sensor, calculate the result, save it in EEPROM, and display it. |
| `B`, slot `1`-`8`, `F` | Read a previously saved result from EEPROM and display it. |

The selected slot is held in `R22`. Separate `A_WAIT_*` and `B_WAIT_*` states ensure that unrelated keys do not trigger a command partway through a sequence.

## Sensor read and calculation

`read_sensor` creates two rising-edge trigger pulses: first on `PC7`, then on `PD7`. After each one-millisecond delay, it samples `PINB`. Each sample is XORed with `STUDENT_CODE` (`39`).

`calculate_spo2` implements the following integer calculation:

```text
result = (second_sample * 100) / (first_sample + second_sample)
```

The division is implemented with repeated subtraction. If the two samples sum to zero, the result is set to zero.

## EEPROM data storage

Keypad lookup values use the EEPROM's low address range. Measured values are stored with `EEARH = 0x01`, so the user-selected slot in `R22` becomes an offset in the `0x0100` EEPROM page. `data_eeprom_write` waits for any existing write to finish, preserves `SREG`, briefly disables interrupts, and uses the `EEMWE`/`EEWE` sequence required for EEPROM writing.

## Display output

`display_spo2` separates the result into tens and ones using repeated subtraction by ten. `digit_to_segment` fetches each digit pattern from `segment_table` in program memory and writes the two patterns to `PORTC` and `PORTD`.

## Source layout

- `main.asm` - complete AVR assembly program.

## Notes

- The exact timing of `delay_1ms` and the resulting sensor triggers depend on the target AVR clock.
- The original Proteus test case reports a displayed value of `80`; other input values can produce the same percentage if they satisfy the calculation.
- EEPROM contents remain after a simulation reset unless the simulator clears them explicitly.
