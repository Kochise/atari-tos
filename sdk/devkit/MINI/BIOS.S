******************************************************************************
**
** bios.s - BIOS interface for MINI Run Time Library
**
** MODIFICATIONS
** 18 sep 85 scc	Converted for library format RTL.
**
** NAMES
**	scc	Steven C. Cavender
**
******************************************************************************

	.xref	_bios

	.text

_bios:
	move.l	(sp)+,retsave
	trap	#13
	move.l	retsave,-(sp)
	rts

	.bss
	.even

retsave:
	.ds.l	1

	.end
