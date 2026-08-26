# Multi-port pulse generator

This AVR program generates a nested pulse pattern across ports A through D.

## Behaviour

- Sets bit 0 of `DDRA`, `DDRB`, `DDRC`, and `DDRD`, making `PA0`–`PD0` outputs.
- Sets `PA0` high at the beginning of each cycle.
- Creates nested activity on `PB0`, `PC0`, and `PD0` using software delays.
- Clears each bit again through `R10` (which the source clears at label `a`).
- Repeats forever from the `oscl` label.

## Delay routine

`DELAY` is placed at `.ORG 200` and uses `R20` as a short countdown. Timing depends on the target MCU clock and instruction timing.

## Nested waveform structure

`R24`, `R16`, `R17`, and `R18` form successive two-iteration loops. At the innermost level, `PD0` is set, delayed, cleared, and delayed again. When that loop completes, the program clears `PC0`; the next outer loop clears `PB0`; the outermost cycle clears `PA0`. This produces a visible hierarchy of pulse activity rather than four independent square waves.

## Note

The comment says `2khz pulse on pa0`; the exact frequency should be measured or calculated for the selected AVR clock.
