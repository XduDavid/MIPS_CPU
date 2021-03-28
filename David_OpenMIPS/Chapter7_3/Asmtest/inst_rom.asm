
inst_rom.om：     文件格式 elf32-tradbigmips


Disassembly of section .text:

00000000 <_start>:
   0:	3402ffff 	li	v0,0xffff
   4:	00021400 	sll	v0,v0,0x10
   8:	3442fff1 	ori	v0,v0,0xfff1
   c:	34030011 	li	v1,0x11
  10:	0043001a 	div	zero,v0,v1
  14:	0043001b 	divu	zero,v0,v1
  18:	0062001a 	div	zero,v1,v0
  1c:	00000000 	nop

Disassembly of section .reginfo:

00000020 <.reginfo>:
  20:	0000000c 	syscall
	...

Disassembly of section .MIPS.abiflags:

00000038 <_ram_end-0x18>:
  38:	00002001 	movf	a0,zero,$fcc0
  3c:	01010001 	movt	zero,t0,$fcc0
	...
  48:	00000001 	movf	zero,zero,$fcc0
  4c:	00000000 	nop

Disassembly of section .gnu.attributes:

00000000 <.gnu.attributes>:
   0:	41000000 	bc0f	4 <_start+0x4>
   4:	0f676e75 	jal	d9db9d4 <_ram_end+0xd9db984>
   8:	00010000 	sll	zero,at,0x0
   c:	00070401 	0x70401
