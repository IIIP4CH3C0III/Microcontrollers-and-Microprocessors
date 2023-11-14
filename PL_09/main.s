	.file	"main.c"
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__SREG__ = 0x3f
__tmp_reg__ = 0
__zero_reg__ = 1
.global	timeFlagD
	.section .bss
	.type	timeFlagD, @object
	.size	timeFlagD, 1
timeFlagD:
	.zero	1
.global	timeFlagF
	.type	timeFlagF, @object
	.size	timeFlagF, 1
timeFlagF:
	.zero	1
.global	counter
	.data
	.type	counter, @object
	.size	counter, 1
counter:
	.byte	-56
.global	counter1
	.type	counter1, @object
	.size	counter1, 1
counter1:
	.byte	4
.global	displayWordSelection
	.section	.rodata
	.type	displayWordSelection, @object
	.size	displayWordSelection, 4
displayWordSelection:
	.byte	-12
	.byte	-76
	.byte	116
	.byte	52
.global	displayDigits
	.type	displayDigits, @object
	.size	displayDigits, 11
displayDigits:
	.byte	-64
	.byte	-7
	.byte	-92
	.byte	-80
	.byte	-103
	.byte	-110
	.byte	-126
	.byte	-8
	.byte	-128
	.byte	-112
	.byte	-1
	.comm	display,12,1
.global	selectedDisplay
	.section .bss
	.type	selectedDisplay, @object
	.size	selectedDisplay, 1
selectedDisplay:
	.zero	1
	.text
.global	main
	.type	main, @function
main:
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 0 */
/* stack size = 2 */
.L__stack_usage = 2
	rcall setup
.L2:
	rcall loop
	rjmp .L2
	.size	main, .-main
.global	setup
	.type	setup, @function
setup:
	push r28
	push r29
	push __zero_reg__
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 1 */
/* stack size = 3 */
.L__stack_usage = 3
	ldi r24,lo8(49)
	ldi r25,0
	ldi r18,lo8(-64)
	mov r30,r24
	mov r31,r25
	st Z,r18
	ldi r24,lo8(106)
	ldi r25,0
	ldi r18,lo8(-1)
	mov r30,r24
	mov r31,r25
	st Z,r18
	ldi r24,lo8(89)
	ldi r25,0
	ldi r18,lo8(11)
	mov r30,r24
	mov r31,r25
	st Z,r18
	ldi r24,lo8(52)
	ldi r25,0
	ldi r18,lo8(-1)
	mov r30,r24
	mov r31,r25
	st Z,r18
	ldi r24,lo8(81)
	ldi r25,0
	ldi r18,lo8(77)
	mov r30,r24
	mov r31,r25
	st Z,r18
	ldi r24,lo8(83)
	ldi r25,0
	ldi r18,lo8(63)
	mov r30,r24
	mov r31,r25
	st Z,r18
	ldi r24,lo8(87)
	ldi r25,0
	ldi r18,lo8(2)
	mov r30,r24
	mov r31,r25
	st Z,r18
/* #APP */
 ;  76 "main.c" 1
	sei
 ;  0 "" 2
/* #NOAPP */
	std Y+1,__zero_reg__
	rjmp .L4
.L5:
	ldd r24,Y+1
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display))
	sbci r25,hi8(-(display))
	ldi r18,lo8(10)
	mov r30,r24
	mov r31,r25
	st Z,r18
	ldd r24,Y+1
	mov r18,r24
	ldi r19,0
	ldd r24,Y+1
	mov r24,r24
	ldi r25,0
	subi r24,lo8(-(displayWordSelection))
	sbci r25,hi8(-(displayWordSelection))
	mov r30,r24
	mov r31,r25
	ld r20,Z
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display+1))
	sbci r25,hi8(-(display+1))
	mov r30,r24
	mov r31,r25
	st Z,r20
	ldd r24,Y+1
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display+2))
	sbci r25,hi8(-(display+2))
	mov r30,r24
	mov r31,r25
	st Z,__zero_reg__
	ldd r24,Y+1
	subi r24,lo8(-(1))
	std Y+1,r24
.L4:
	ldd r24,Y+1
	cpi r24,lo8(4)
	brlo .L5
	nop
/* epilogue start */
	pop __tmp_reg__
	pop r29
	pop r28
	ret
	.size	setup, .-setup
.global	loop
	.type	loop, @function
loop:
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 0 */
/* stack size = 2 */
.L__stack_usage = 2
	lds r24,timeFlagD
	tst r24
	brne .+2
	rjmp .L7
	sts timeFlagD,__zero_reg__
	lds r24,selectedDisplay
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display))
	sbci r25,hi8(-(display))
	mov r30,r24
	mov r31,r25
	ld r24,Z
	cpi r24,lo8(11)
	brlo .L8
	lds r24,selectedDisplay
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display))
	sbci r25,hi8(-(display))
	mov r30,r24
	mov r31,r25
	st Z,__zero_reg__
.L8:
	ldi r20,lo8(50)
	ldi r21,0
	lds r24,selectedDisplay
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display+1))
	sbci r25,hi8(-(display+1))
	mov r30,r24
	mov r31,r25
	ld r24,Z
	mov r30,r20
	mov r31,r21
	st Z,r24
	ldi r20,lo8(53)
	ldi r21,0
	lds r24,selectedDisplay
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display))
	sbci r25,hi8(-(display))
	mov r30,r24
	mov r31,r25
	ld r24,Z
	mov r24,r24
	ldi r25,0
	subi r24,lo8(-(displayDigits))
	sbci r25,hi8(-(displayDigits))
	mov r30,r24
	mov r31,r25
	ld r24,Z
	mov r30,r20
	mov r31,r21
	st Z,r24
	lds r24,timeFlagF
	tst r24
	brne .+2
	rjmp .L7
	lds r24,selectedDisplay
	mov r24,r24
	ldi r25,0
	cpi r24,1
	cpc r25,__zero_reg__
	brne .+2
	rjmp .L9
	cpi r24,2
	cpc r25,__zero_reg__
	brge .L10
	or r24,r25
	breq .L11
	rjmp .L7
.L10:
	cpi r24,2
	cpc r25,__zero_reg__
	brne .+2
	rjmp .L12
	sbiw r24,3
	brne .+2
	rjmp .L13
	rjmp .L7
.L11:
	lds r24,selectedDisplay
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display+2))
	sbci r25,hi8(-(display+2))
	mov r30,r24
	mov r31,r25
	ld r24,Z
	tst r24
	breq .L14
	lds r24,selectedDisplay
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display))
	sbci r25,hi8(-(display))
	mov r30,r24
	mov r31,r25
	ld r24,Z
	ldi r20,lo8(1)
	add r20,r24
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display))
	sbci r25,hi8(-(display))
	mov r30,r24
	mov r31,r25
	st Z,r20
	lds r24,counter1
	subi r24,lo8(-(-1))
	sts counter1,r24
.L14:
	lds r24,selectedDisplay
	subi r24,lo8(-(1))
	sts selectedDisplay,r24
	rjmp .L7
.L9:
	lds r24,selectedDisplay
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display+2))
	sbci r25,hi8(-(display+2))
	mov r30,r24
	mov r31,r25
	ld r24,Z
	tst r24
	breq .L15
	lds r24,selectedDisplay
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display))
	sbci r25,hi8(-(display))
	mov r30,r24
	mov r31,r25
	ld r24,Z
	ldi r20,lo8(1)
	add r20,r24
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display))
	sbci r25,hi8(-(display))
	mov r30,r24
	mov r31,r25
	st Z,r20
	lds r24,counter1
	subi r24,lo8(-(-1))
	sts counter1,r24
.L15:
	lds r24,selectedDisplay
	subi r24,lo8(-(1))
	sts selectedDisplay,r24
	rjmp .L7
.L12:
	lds r24,selectedDisplay
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display+2))
	sbci r25,hi8(-(display+2))
	mov r30,r24
	mov r31,r25
	ld r24,Z
	tst r24
	breq .L16
	lds r24,selectedDisplay
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display))
	sbci r25,hi8(-(display))
	mov r30,r24
	mov r31,r25
	ld r24,Z
	ldi r20,lo8(1)
	add r20,r24
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display))
	sbci r25,hi8(-(display))
	mov r30,r24
	mov r31,r25
	st Z,r20
	lds r24,counter1
	subi r24,lo8(-(-1))
	sts counter1,r24
.L16:
	lds r24,selectedDisplay
	subi r24,lo8(-(1))
	sts selectedDisplay,r24
	rjmp .L7
.L13:
	lds r24,selectedDisplay
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display+2))
	sbci r25,hi8(-(display+2))
	mov r30,r24
	mov r31,r25
	ld r24,Z
	tst r24
	breq .L17
	lds r24,selectedDisplay
	mov r18,r24
	ldi r19,0
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display))
	sbci r25,hi8(-(display))
	mov r30,r24
	mov r31,r25
	ld r24,Z
	ldi r20,lo8(1)
	add r20,r24
	mov r24,r18
	mov r25,r19
	lsl r24
	rol r25
	add r24,r18
	adc r25,r19
	subi r24,lo8(-(display))
	sbci r25,hi8(-(display))
	mov r30,r24
	mov r31,r25
	st Z,r20
	lds r24,counter1
	subi r24,lo8(-(-1))
	sts counter1,r24
.L17:
	sts selectedDisplay,__zero_reg__
	nop
.L7:
	lds r24,counter1
	tst r24
	brne .L19
	ldi r24,lo8(4)
	sts counter1,r24
	sts timeFlagF,__zero_reg__
.L19:
	nop
/* epilogue start */
	pop r29
	pop r28
	ret
	.size	loop, .-loop
.global	__vector_1
	.type	__vector_1, @function
__vector_1:
	push r1
	push r0
	lds r0,95
	push r0
	clr __zero_reg__
	push r24
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: Signal */
/* frame size = 0 */
/* stack size = 6 */
.L__stack_usage = 6
	ldi r24,lo8(1)
	sts display+2,r24
	nop
/* epilogue start */
	pop r29
	pop r28
	pop r24
	pop r0
	sts 95,r0
	pop r0
	pop r1
	reti
	.size	__vector_1, .-__vector_1
.global	__vector_2
	.type	__vector_2, @function
__vector_2:
	push r1
	push r0
	lds r0,95
	push r0
	clr __zero_reg__
	push r24
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: Signal */
/* frame size = 0 */
/* stack size = 6 */
.L__stack_usage = 6
	ldi r24,lo8(1)
	sts display+5,r24
	nop
/* epilogue start */
	pop r29
	pop r28
	pop r24
	pop r0
	sts 95,r0
	pop r0
	pop r1
	reti
	.size	__vector_2, .-__vector_2
.global	__vector_5
	.type	__vector_5, @function
__vector_5:
	push r1
	push r0
	lds r0,95
	push r0
	clr __zero_reg__
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: Signal */
/* frame size = 0 */
/* stack size = 5 */
.L__stack_usage = 5
	sts display+2,__zero_reg__
	sts display+5,__zero_reg__
	nop
/* epilogue start */
	pop r29
	pop r28
	pop r0
	sts 95,r0
	pop r0
	pop r1
	reti
	.size	__vector_5, .-__vector_5
.global	__vector_15
	.type	__vector_15, @function
__vector_15:
	push r1
	push r0
	lds r0,95
	push r0
	clr __zero_reg__
	push r24
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: Signal */
/* frame size = 0 */
/* stack size = 6 */
.L__stack_usage = 6
	ldi r24,lo8(1)
	sts timeFlagD,r24
	lds r24,counter
	tst r24
	brne .L24
	ldi r24,lo8(-56)
	sts counter,r24
	ldi r24,lo8(1)
	sts timeFlagF,r24
	rjmp .L26
.L24:
	lds r24,counter
	subi r24,lo8(-(-1))
	sts counter,r24
.L26:
	nop
/* epilogue start */
	pop r29
	pop r28
	pop r24
	pop r0
	sts 95,r0
	pop r0
	pop r1
	reti
	.size	__vector_15, .-__vector_15
	.ident	"GCC: (GNU) 5.4.0"
.global __do_copy_data
.global __do_clear_bss
