ldi r16 , high(ramend)
out sph , r16
ldi r16 , low(ramend)
out spl , r16
;;;;;;;;;
ldi r20 , 45
ldi r21 , 10
rcall devide
rjmp a

.org 100
devide:
	clr r16
	loop:
		sub r20 , r21
		brlo res
		inc r16
		rjmp loop
	res:
		add r20 , r21
		sts 0x00 , r20
		sts 0x01 , r16
ret

a : clr r10
