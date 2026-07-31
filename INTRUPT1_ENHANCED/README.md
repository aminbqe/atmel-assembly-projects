# Timer0 interrupt and port mirroring

This AVR program configures Timer0 and uses its overflow interrupt to toggle `PA5`.

## Behaviour

- `PORTC` is configured as input and `PORTD` as output.
- The main loop continuously copies `PINC` to `PORTD`.
- Timer0 is preloaded with `-41` and started with no prescaling (`CS00`).
- The Timer0 overflow ISR reloads the counter and toggles bit `PA5` on `PORTA`.

## Structure

- Reset vector: `.ORG 0`
- Timer0 overflow vector: `.ORG 0x16`
- Main program: `.ORG 100`
- ISR: `.ORG 1000`

The exact output frequency depends on the MCU clock and the Timer0 configuration.
