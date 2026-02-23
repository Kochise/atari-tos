
* Lower phystop to 512K or 1MB
* Purpose: software test, for some games not liking
* more RAM.

	
  	pea 	srut(pc)  * Code adr.
  	move.w 	#38,-(sp)     * Exec in supervisor mode
  	trap 	#14
	addq.l	#6,sp

	clr.w	 -(sp)   * Exit
  	trap 	#1


srut	pea	text(pc)
  	move.w 	#9,-(sp)   * String output
  	trap 	#1
  	addq.l 	#6,sp

  	move.w 	#1,-(sp)   * Wait keypress
  	trap 	#1
  	addq.l 	#2,sp

  	cmp.b 	#"1",d0
  	beq.s 	oneM

	cmp.b 	#"5",d0
  	bne.s	toCch
	move.l	#$80000,d2
	bra.s	setPhy

oneM	move.l	#$100000,d2

setPhy  	move.l 	d2,$42E.w   * Phystop
  
toR	move.l 	4.w,a1
  	jmp 	(a1)      *Reset

toCch	cmp.b 	#"c",d0
	beq.s	coldR
	cmp.b 	#"C",d0
	beq.s	coldR
toEx	rts

coldR	clr.l	$420.w   * Destroy memvalid
	bra.s	toR



text 	dc.b 13,10,"Press 5 to reduce Your ST(E)",13,10
  	dc.b "in 520 machine, or 1 to reduce",13,10
  	dc.b "in 1040 machine.",13,10
	dc.b  "Press C for cold reset",13,10
	dc.b  "- it restores normal RAM state.",13,10
	dc.b  "Other key just exits.",0
  end
