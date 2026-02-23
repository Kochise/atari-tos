	move.l	#1,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.b	d0
	beq	USER
	bra	SUPER
	bra	EXIT
USER	pea	USER_TXT
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	bra	EXIT
SUPER	pea	SUPER_TXT
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	bra	EXIT
EXIT	clr.w	-(sp)
	move.w	#$4C,-(sp)
	trap	#1
	
USER_TXT	dc.b	27,112,"USER MODE",27,113,0
SUPER_TXT	dc.b	27,112,"SUPER MODE",27,113,0
