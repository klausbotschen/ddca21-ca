	.text
	.align	2
	.globl	_start
_start:
	addi x4 ,x0, 0x100  # idx 0x10000213
	addi x5, x0, 0x104  # lim 0x11000293
	addi x6, x0, 0      # xnt 0x00000313
	nop
	nop
loop:
	nop
	sb x6, 0(x4)       # 0x00620023
	addi x4, x4, 1     # 0x00420213
	addi x6, x6, 1     # 0x00130313
	nop
	nop
	nop
	lb x7, -1(x4)     # 0xffc22383
	bne x4, x5, loop  # 0xfe5210e3
fin:
	nop
	nop
	nop
	beq x0, x0, fin   # 0xfe000ae3
	nop
	nop
	nop

	.end _start
	.size _start, .-_start
