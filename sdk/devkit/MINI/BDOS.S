******************************************************************************
**
** bdos.s - BDOS interface for MINI Run Time Library
**
** MODIFICATIONS
** 18 sep 85 scc	Converted for library format RTL.
**
** NAMES
**	scc	Steven C. Cavender
**
******************************************************************************

	.xref	_bdos

	.text

_bdos:
	move.l	(sp)+,retsave
	trap	#1
	move.l	retsave,-(sp)
	rts

	.bss
	.even

retsave:
	.ds.l	1

	.end
