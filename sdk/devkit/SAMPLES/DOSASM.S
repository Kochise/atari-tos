*	DOSASM.S	10/02/85		Lowell Webster
*
*
	.text
	.globl	___DOS
	.globl	_DOS_ERR
	.globl	_DOS_AX
*
___DOS:
	move.l	(sp)+,retsav			* save the return value
	move.w	#0,_DOS_ERR			* clear the error
	move.w	#0,_DOS_AX			*  and return codes
	trap	#1				* call gemdos
	cmp.l	#0,d0				* Error?
	bge oktrap				* no
	  move.w	#1,_DOS_ERR		* yes
	  move.w	d0,_DOS_AX		* convert to PCDOS error num
	  cmp.w		#-32,d0
	  bgt		oktrap
	  not.w		_DOS_AX			* code := (!code) - 30
	  subi.w	#30,_DOS_AX
oktrap:
	move.l	retsav,-(sp)			* restore return
	rts

	.bss
	.even
retsav:	.ds.l	1

	.end
