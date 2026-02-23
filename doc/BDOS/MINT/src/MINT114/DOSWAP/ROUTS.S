	text
	XDEF	_Check_magic
	XDEF	_Put_magic
	XDEF	_Clear_magic
	
_Check_magic
	move.l	4(sp),a0		
	moveq.l	#0,d0
	lea	$20(a0),a0
	cmp.l	#'This',(a0)+
	bne	.skip
	cmp.l	#'is a',(a0)+
	bne	.skip
	cmp.l	#' MiN',(a0)+
	bne	.skip
	cmp.l	#'T VM',(a0)+
	bne	.skip
	cmp.l	#' swa',(a0)+
	bne	.skip
	cmp.l	#'ppar',(a0)+
	bne	.skip
	cmp.l	#'titi',(a0)+
	bne	.skip
	cmp.l	#'on. ',(a0)+
	bne	.skip
	cmp.l	#'Do N',(a0)+
	bne	.skip
	cmp.l	#'OT t',(a0)+
	bne	.skip
	cmp.l	#'ouch',(a0)+
	bne	.skip
	cmp.l	#'!!!!',(a0)+
	bne	.skip
	cmp.l	#'WARN',(a0)+
	bne	.skip
	cmp.l	#'ING:',(a0)+
	bne	.skip
	cmp.l	#'This',(a0)+
	bne	.skip
	cmp.l	#' par',(a0)+
	bne	.skip
	cmp.l	#'titi',(a0)+
	bne	.skip
	cmp.l	#'on w',(a0)+
	bne	.skip
	cmp.l	#'ill ',(a0)+
	bne	.skip
	cmp.l	#'be m',(a0)+
	bne	.skip
	cmp.l	#'odif',(a0)+
	bne	.skip
	cmp.l	#'ied ',(a0)+
	bne.s	.skip
	cmp.l	#'by t',(a0)+
	bne.s	.skip
	cmp.l	#'he s',(a0)+
	bne.s	.skip
	cmp.l	#'wapp',(a0)+
	bne.s	.skip
	cmp.l	#'er w',(a0)+
	bne.s	.skip
	cmp.l	#'hen ',(a0)+
	bne.s	.skip
	cmp.l	#'VM i',(a0)+
	bne.s	.skip
	cmp.l	#'s en',(a0)+
	bne.s	.skip
	cmp.l	#'able',(a0)+
	bne.s	.skip
	cmp.l	#'d!!!',(a0)+
	bne.s	.skip
	cmp.l	#'    ',(a0)+
	bne.s	.skip
	cmp.l	#'il P',(a0)+
	bne.s	.skip
	cmp.l	#'rofe',(a0)+
	bne.s	.skip
	cmp.l	#'sore',(a0)+
	bne.s	.skip
	cmp.l	#' 199',(a0)+
	bne.s	.skip
	cmp.l	#'6   ',(a0)+
	bne.s	.skip
	moveq.l	#1,d0
.skip	rts

_Put_magic
	move.l	4(sp),a0
	lea	$20(a0),a0
	move.l	#'This',(a0)+
	move.l	#'is a',(a0)+
	move.l	#' MiN',(a0)+
	move.l	#'T VM',(a0)+
	move.l	#' swa',(a0)+
	move.l	#'ppar',(a0)+
	move.l	#'titi',(a0)+
	move.l	#'on. ',(a0)+
	move.l	#'Do N',(a0)+
	move.l	#'OT t',(a0)+
	move.l	#'ouch',(a0)+
	move.l	#'!!!!',(a0)+
	move.l	#'WARN',(a0)+
	move.l	#'ING:',(a0)+
	move.l	#'This',(a0)+
	move.l	#' par',(a0)+
	move.l	#'titi',(a0)+
	move.l	#'on w',(a0)+
	move.l	#'ill ',(a0)+
	move.l	#'be m',(a0)+
	move.l	#'odif',(a0)+
	move.l	#'ied ',(a0)+
	move.l	#'by t',(a0)+
	move.l	#'he s',(a0)+
	move.l	#'wapp',(a0)+
	move.l	#'er w',(a0)+
	move.l	#'hen ',(a0)+
	move.l	#'VM i',(a0)+
	move.l	#'s en',(a0)+
	move.l	#'able',(a0)+
	move.l	#'d!!!',(a0)+
	move.l	#'    ',(a0)+
	move.l	#'il P',(a0)+
	move.l	#'rofe',(a0)+
	move.l	#'sore',(a0)+
	move.l	#' 199',(a0)+
	move.l	#'6   ',(a0)+
	rts

_Clear_magic
	move.l	4(sp),a0
	lea	$20(a0),a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	rts
	end	