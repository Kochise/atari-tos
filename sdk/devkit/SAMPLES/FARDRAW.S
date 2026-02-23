*	FARDRAW.S	10/02/85		Lowell Webster
*
	.text
	.globl	_dr_code
	.globl	_drawaddr
*
*
*	Sample code for user defined draw object.
*	_far_draw(pb)
*		PARMBLK		*pb;	pointer to PARMBLK
*
*	need to get on a local stack and call dr_code(ppb) routine
*	with the pointer to PARMBLK. N B registers not saved.
*
_far_draw:
	move.l	4(a7),d0		* get pointer to PARMBLK
	move.l	a7,drawsp		* save current stack
	movea.l	#drawstk,a7		* get on new stack
	move.l	d0,-(a7)		* pass pointer to PARMBLK to dr_code
	jsr	_dr_code
	movea.l	drawsp,a7		* restore stack
	rts


	.data
	.even
_drawaddr:	.dc.l	_far_draw

	.bss
	.even
 drawsp:	.ds.l	1
 		.ds.l	256
 drawstk:	.ds.l	1

	.end
