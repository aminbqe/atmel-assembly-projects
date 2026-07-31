ldi r16 , high(ramend)
out sph , r16
ldi r16 , low(ramend)
out spl , r16
;;;;;;;;;;;;;;;;;
ldi r24 , 48
ldi r20 , 6
ldi r18 , 0xff
out ddrb , r18
out ddrc , r18
out ddrd , r18


