ldi r16 , high(ramend)
out sph,r16
ldi r16,low(ramend)
out spl , r16
;;;;;;;;;
ldi r16 , 0x1
out ddra , r16
out ddrb , r16
out ddrc , r16
out ddrd , r16
; 2khz pulse on pa0:
oscl:
ldi r23 , 1
ldi r24 , 2
out porta , r23
loop0:
ldi r16 , 2
;out porta , r23
loop1:
		ldi r17,2
		out portb , r23
		loop2:
				out portc , r23
				ldi r18,2
				loop3:
						out portd , r23
						nop
						rcall delay
						out portd , r10
						nop
						rcall delay
						out portc , r10
						dec r18
						brne loop3
				out portb , r10
				dec r17
				brne loop2
		;out porta , r10
		dec r16
		brne loop1
out porta , r10
dec r24
brne loop0
nop
nop
nop
nop
rjmp oscl




a : rjmp a


.org 200
DELAY:
		ldi r20 , 6
		lop : 
			dec r20
			brne lop
RET
