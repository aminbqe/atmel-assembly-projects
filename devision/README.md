# Unsigned division by repeated subtraction

This AVR assembly exercise divides `45` by `10` through repeated subtraction.

## Registers and result

- `R20`: dividend on entry; remainder on return.
- `R21`: divisor (`10` in the example).
- `R16`: quotient.

The `devide` subroutine subtracts `R21` from `R20` until the subtraction borrows. It then restores the last subtraction, stores the remainder at SRAM address `0x00`, and stores the quotient at `0x01`.

For the supplied values, the expected result is quotient `4` and remainder `5`.

## Note

The label is spelled `devide` in the source and is preserved as-is.
