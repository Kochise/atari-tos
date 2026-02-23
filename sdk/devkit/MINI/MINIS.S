******************************************************************************
**
** minis.s - startup code for MINI Run Time Library
**
** MODIFICATIONS
** 18 sep 85 scc	Converted to provide proper front end for library
**			format RTL.
**
** NAMES
**	scc	Steven C. Cavender
**
******************************************************************************

* Base Page equates

p_tlen	=	$0C
p_dlen	=	$14
p_blen	=	$1C

* GEMDOS function equate

M_Shrink =	$4A

	.xdef	_main

	.text

minis:
	move.l	4(sp),a0		* pick up base page address
	move.l	#stack_base,sp		* set up local stack
	move.l	a0,-(sp)		* and build initial stack frame

	move.l	#$100,d0		* compute size for M_Shrink()
	add.l	p_tlen(a0),d0
	add.l	p_dlen(a0),d0
	add.l	p_blen(a0),d0
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#M_Shrink,-(sp)
	trap	#1
	add.l	#12,sp

	jsr	_main

	clr.w	-(sp)			* this allows us to check function 00
	trap	#1

	.bss
	.even

	.ds.l	100
stack_base:
	.ds.w	1

	.end
