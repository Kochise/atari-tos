*		VDIASM.S	10/11/85		Lowell Webster
	.text

	.globl	_gsx1
	.globl	_gsx2
	.globl	_iioff
	.globl	_iooff
	.globl	_pioff
	.globl	_pooff
	.globl	_vdi
	.globl	_i_ptr2
	.globl	_i_ptr
	.globl	_m_lptr2

	.xdef	_contrl


_vdi:
_gsx1:
_gsx2:
	move.l	#_contrl, pblock
	move.l	#pblock, d1
	move.l	#115, d0
	trap	#2
	rts
*
_i_ptr:
	move.l	4(sp),_contrl+14
	rts
*
_i_ptr2:
	move.l	4(sp),_contrl+18
	rts
*
_m_lptr2:
	move.l	4(sp),a0
	move.l	_contrl+18,(a0)
	rts

	.bss
	.even

pblock:	.ds.l	1
_iioff:	.ds.l	1
_pioff:	.ds.l	1
_iooff:	.ds.l	1
_pooff:	.ds.l	1


	.end

