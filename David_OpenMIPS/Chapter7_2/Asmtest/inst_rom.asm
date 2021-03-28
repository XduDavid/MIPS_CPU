
inst_rom.om：     文件格式 elf32-tradbigmips


Disassembly of section .text:

00000000 <_start>:
   0:	3401ffff 	li	at,0xffff
   4:	00010c00 	sll	at,at,0x10
   8:	3421fffb 	ori	at,at,0xfffb
   c:	34020006 	li	v0,0x6
  10:	00220018 	mult	at,v0
  14:	70220000 	madd	at,v0
  18:	70220001 	maddu	at,v0
  1c:	70220004 	msub	at,v0
  20:	70220005 	msubu	at,v0
	...

Disassembly of section .reginfo:

00000030 <.reginfo>:
  30:	00000006 	srlv	zero,zero,zero
	...

Disassembly of section .MIPS.abiflags:

00000048 <_ram_end-0x18>:
  48:	00002001 	movf	a0,zero,$fcc0
  4c:	01010001 	movt	zero,t0,$fcc0
	...
  58:	00000001 	movf	zero,zero,$fcc0
  5c:	00000000 	nop

Disassembly of section .gnu.attributes:

00000000 <.gnu.attributes>:
   0:	41000000 	bc0f	4 <_start+0x4>
   4:	0f676e75 	jal	d9db9d4 <_ram_end+0xd9db974>
   8:	00010000 	sll	zero,at,0x0
   c:	00070401 	0x70401
