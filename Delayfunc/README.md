# Delay routine

This Atmel AVR assembly file contains a subroutine named `DELAY`.

## What the code does

1. Initializes the stack pointer from `RAMEND`.
2. Loads `R20` with `203` and `R21` with `8`.
3. Uses nested decrement-and-branch loops with `NOP` instructions.
4. Returns to the caller with `RET`.

## Use

Call the routine with `RCALL DELAY`. It clobbers `R20` and `R21`.

## Note

The current source loads `R20` only once, before the outer loop. If the intention is a fixed inner-loop delay for every outer-loop iteration, reload `R20` inside `LOP1`.
