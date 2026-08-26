# Binary-to-ASCII setup

This project is the initial setup for a binary-to-ASCII conversion exercise on an Atmel AVR microcontroller.

## Current source

- Initializes the stack pointer using `RAMEND`.
- Loads `R24` with `48` (`0x30`, the ASCII code for `0`).
- Loads `R20` with `6`.
- Configures `PORTB`, `PORTC`, and `PORTD` as outputs by writing `0xFF` to `DDRB`, `DDRC`, and `DDRD`.

## Status

The checked-in program stops after initialization: it does not yet contain the conversion loop or output logic. This README documents the source as it currently exists.

## Register roles

- `R16` initializes `SPH` and `SPL` from `RAMEND`.
- `R24 = 48` supplies the character code `0x30`, the usual base value for converting a decimal digit to ASCII.
- `R20 = 6` is prepared as a working value, but is not consumed by the current code.
- `R18 = 0xFF` configures every bit of ports B, C, and D as an output.
