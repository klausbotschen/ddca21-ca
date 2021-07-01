	.text
	.globl	memory
	.bss
	.align	2
	.type	memory, @object
	.size	memory, 256
memory:
	.zero	256
	.text
	.align	2
	.globl	_start
_start:
	lui	x4, %hi(memory)  # 0x00000237
	addi x4, x0, %lo(memory) # 0x06C00213
	addi x5, x0, 0x40   # limit, 0x40000293
	addi x6, x0, 0      # cnt, 0x00000313
loop:
	jal x1, sub  # 0x034000ef
	lb x7, -1(x4)     # 0xfff20383
	blt x6, x5, loop  # 0xfe5344e3
fin:
	beq x0, x0, fin   # 0xfe000ae3
sub:
	sb x6, 0(x4)       # 0x00620023
	addi x4, x4, 1     # 0x00120213
	addi x6, x6, 1     # 0x00130313
	jalr x0, 0(x1)     # 0x00008067

	.end _start
	.size _start, .-_start
