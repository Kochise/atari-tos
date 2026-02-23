;**************************************************************************
;
; CDBIND.s	Example "C" style binding routines to the Atari CD ROM
;		Extended Bios routines and assembly lauguage interface.
;
;		Started: 	04/04/88	Mike Schmal
;		Last Update:	04/04/88
;
;**************************************************************************


	.globl	_CDROM


;**************************************************************************
;
; CDROM	"C" interface for the Atari CD ROM Extended Bios.
;
;**************************************************************************
_CDROM:
	move.l	(sp)+,savsp
	trap	#14
	move.l	savsp,-(sp)
	rts


	.bss
savsp:	.ds.l	1	; Save calling routines return address
	.end
