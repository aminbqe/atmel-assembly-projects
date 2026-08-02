.equ STUDENT_CODE  = 39

.equ WAIT_COMMAND  = 0
.equ A_WAIT_NUMBER = 1
.equ A_WAIT_F      = 2
.equ B_WAIT_NUMBER = 3
.equ B_WAIT_F      = 4

.cseg
.org 0x0000
rjmp reset

reset:
    ldi r16,high(RAMEND)
    out SPH,r16
    ldi r16,low(RAMEND)
    out SPL,r16

    clr r1
	; port init
    ldi r16,0xf0
    out DDRA,r16
    ldi r16,0xff
    out PORTA,r16

    ; port b input from oxymeter
    clr r16
    out DDRB,r16
    out PORTB,r16

    ;portc output
    ldi r16,0xff
    out DDRC,r16
    out DDRD,r16
    cbi PORTC,7
    cbi PORTD,7

    ; sram address init:
    ldi ZL,low(0x0400)
    ldi ZH,high(0x0400)

    ; allocating e2prom memory:
    rcall init_eeprom

    clr r22
    clr r23
    clr r24
    clt

main_loop:
    rcall keypad_routine
	; CHECKS T FLAG EVERYTIME
    brts key_available
    rjmp main_loop

key_available:
    clt
    rcall readkey
    cpi r16,0xff
    brne check_state
    rjmp main_loop

check_state:
    cpi r23,WAIT_COMMAND
    brne state_a_number
    rjmp check_command
state_a_number:
    cpi r23,A_WAIT_NUMBER
    brne state_a_f
    rjmp check_a_number
state_a_f:
    cpi r23,A_WAIT_F
    brne state_b_number
    rjmp check_a_f
state_b_number:
    cpi r23,B_WAIT_NUMBER
    brne state_b_f
    rjmp check_b_number
state_b_f:
    cpi r23,B_WAIT_F
    brne reset_state
    rjmp check_b_f

reset_state:
    clr r23
    clr r22
    rjmp main_loop

check_command:
    cpi r16,0x0a
    breq command_a
    cpi r16,0x0b
    breq command_b
    rjmp main_loop

command_a:
    clr r22
    ldi r23,A_WAIT_NUMBER
    rjmp main_loop

command_b:
    clr r22
    ldi r23,B_WAIT_NUMBER
    rjmp main_loop

check_a_number:
    cpi r16,0x01
    brsh check_a_number_max
    rjmp main_loop
check_a_number_max:
    cpi r16,0x09
    brlo save_a_number
    rjmp main_loop
save_a_number:
    mov r22,r16
    ldi r23,A_WAIT_F
    rjmp main_loop

check_a_f:
    cpi r16,0x0f
    breq store_new_data
    rjmp main_loop
store_new_data:
    rcall read_sensor
    rcall calculate_spo2
    rcall data_eeprom_write
    rcall display_spo2
    clr r23
    clr r22
    rjmp main_loop

check_b_number:
    cpi r16,0x01
    brsh check_b_number_max
    rjmp main_loop
check_b_number_max:
    cpi r16,0x09
    brlo save_b_number
    rjmp main_loop
save_b_number:
    mov r22,r16
    ldi r23,B_WAIT_F
    rjmp main_loop

check_b_f:
    cpi r16,0x0f
    breq load_old_data
    rjmp main_loop
load_old_data:
    rcall data_eeprom_read
    rcall display_spo2
    clr r23
    clr r22
    rjmp main_loop

keypad_routine:
    rcall scan_key
    cpi r16,0xff
    breq keypad_end
    rcall keypad_eeprom_read
    st Z+,r19
    set
wait_key_release:
    rcall scan_key
    cpi r16,0xff
    brne wait_key_release
keypad_end:
    ret

scan_key:
    ldi r16,0x7f
    out PORTA,r16
    nop
    nop
    in r16,PINA
    cpi r16,0x7f
    brne keysel
    ldi r16,0xbf
    out PORTA,r16
    nop
    nop
    in r16,PINA
    cpi r16,0xbf
    brne keysel
    ldi r16,0xdf
    out PORTA,r16
    nop
    nop
    in r16,PINA
    cpi r16,0xdf
    brne keysel
    ldi r16,0xef
    out PORTA,r16
    nop
    nop
    in r16,PINA
    cpi r16,0xef
    brne keysel
    ldi r16,0xff
keysel:
    ret

readkey:
    cpi ZL,low(0x0400)
    brne buffer_not_empty
    cpi ZH,high(0x0400)
    brne buffer_not_empty
    ldi r16,0xff
    ret
buffer_not_empty:
    ld r16,-Z
    ret

keypad_eeprom_read:
keypad_read_wait:
    sbic EECR,EEWE
    rjmp keypad_read_wait
    out EEARL,r16
    clr r20
    out EEARH,r20
    sbi EECR,EERE
    in r19,EEDR
    ret

read_sensor:
    cbi PORTC,7
    nop
    sbi PORTC,7
    rcall delay_1ms
    in r24,PINB
    cbi PORTC,7
    ldi r16,STUDENT_CODE
    eor r24,r16

    cbi PORTD,7
    nop
    sbi PORTD,7
    rcall delay_1ms
    in r25,PINB
    cbi PORTD,7
    ldi r16,STUDENT_CODE
    eor r25,r16
    ret

calculate_spo2:
    mov r20,r24
    add r20,r25
    tst r20
    breq spo2_zero
    ldi r18,100
    mul r25,r18
    mov r24,r0
    mov r25,r1
    clr r1
    clr r16
spo2_divide:
    tst r25
    brne spo2_subtract
    cp r24,r20
    brlo spo2_done
spo2_subtract:
    sub r24,r20
    sbc r25,r1
    inc r16
    rjmp spo2_divide
spo2_done:
    ret
spo2_zero:
    clr r16
    ret

data_eeprom_write:
data_write_wait:
    sbic EECR,EEWE
    rjmp data_write_wait
    out EEARL,r22
    ldi r18,0x01
    out EEARH,r18
    out EEDR,r16
    in r19,SREG
    cli
    sbi EECR,EEMWE
    sbi EECR,EEWE
    out SREG,r19
    ret

data_eeprom_read:
data_read_wait:
    sbic EECR,EEWE
    rjmp data_read_wait
    out EEARL,r22
    ldi r18,0x01
    out EEARH,r18
    sbi EECR,EERE
    in r16,EEDR
    ret

display_spo2:
    mov r18,r16
    clr r19
display_divide_10:
    cpi r18,10
    brlo display_digits_ready
    subi r18,10
    inc r19
    rjmp display_divide_10
display_digits_ready:
    rcall digit_to_segment
    mov r21,r20
    mov r18,r19
    rcall digit_to_segment
    out PORTC,r20
    out PORTD,r21
    ret

digit_to_segment:
    push ZL
    push ZH
    ldi ZL,low(segment_table*2)
    ldi ZH,high(segment_table*2)
    add ZL,r18
    adc ZH,r1
    lpm r20,Z
    pop ZH
    pop ZL
    ret

delay_1ms:
    ldi r18,250
delay_1ms_loop:
    nop
    dec r18
    brne delay_1ms_loop
    ret

keypad_eeprom_write:
keypad_write_wait:
    sbic EECR,EEWE
    rjmp keypad_write_wait
    out EEARL,r17
    clr r18
    out EEARH,r18
    out EEDR,r16
    in r19,SREG
    cli
    sbi EECR,EEMWE
    sbi EECR,EEWE
    out SREG,r19
    ret

init_eeprom:
    ldi r17,0x77
    ldi r16,0x03
    rcall keypad_eeprom_write
    ldi r17,0x7b
    ldi r16,0x02
    rcall keypad_eeprom_write
    ldi r17,0x7d
    ldi r16,0x01
    rcall keypad_eeprom_write
    ldi r17,0x7e
    ldi r16,0x00
    rcall keypad_eeprom_write
    ldi r17,0xb7
    ldi r16,0x07
    rcall keypad_eeprom_write
    ldi r17,0xbb
    ldi r16,0x06
    rcall keypad_eeprom_write
    ldi r17,0xbd
    ldi r16,0x05
    rcall keypad_eeprom_write
    ldi r17,0xbe
    ldi r16,0x04
    rcall keypad_eeprom_write
    ldi r17,0xd7
    ldi r16,0x0b
    rcall keypad_eeprom_write
    ldi r17,0xdb
    ldi r16,0x0a
    rcall keypad_eeprom_write
    ldi r17,0xdd
    ldi r16,0x09
    rcall keypad_eeprom_write
    ldi r17,0xde
    ldi r16,0x08
    rcall keypad_eeprom_write
    ldi r17,0xe7
    ldi r16,0x0f
    rcall keypad_eeprom_write
    ldi r17,0xeb
    ldi r16,0x0e
    rcall keypad_eeprom_write
    ldi r17,0xed
    ldi r16,0x0d
    rcall keypad_eeprom_write
    ldi r17,0xee
    ldi r16,0x0c
    rcall keypad_eeprom_write
init_eeprom_wait:
    sbic EECR,EEWE
    rjmp init_eeprom_wait
    ret

segment_table:
    .db 0x3f,0x06,0x5b,0x4f
    .db 0x66,0x6d,0x7d,0x07,0x7f,0x6f
