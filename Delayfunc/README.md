# Delay routine

This Atmel AVR assembly file contains a subroutine named `DELAY`.

## What the code does

1. Initializes the stack pointer from `RAMEND`.
2. Loads `R20` with `203` and `R21` with `8`.
3. Uses nested decrement-and-branch loops with `NOP` instructions.
4. Returns to the caller with `RET`.

## Use

Call the routine with `RCALL DELAY`. It clobbers `R20` and `R21`.

## Control flow and timing

`R20` starts at 203. The inner `LOP2` loop executes two `NOP`s, decrements `R20`, and repeats while `R20` is nonzero. `LOP1` then decrements `R21`; its initial value is 8. This makes the delay instruction-count based rather than a timer-based delay, so its duration changes with the CPU clock.

## Note

The current source loads `R20` only once, before the outer loop. If the intention is a fixed inner-loop delay for every outer-loop iteration, reload `R20` inside `LOP1`.
