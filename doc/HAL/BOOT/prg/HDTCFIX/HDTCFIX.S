
 * TSR program for fixing Hddriver Timer C stopped lock
* needed by some games 

progbeg
	
	pea	inshand(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp


	clr.w	-(sp)
	pea          fin-progbeg+256   *len of program, bss and bp
	move.w	#49,-(sp)   *Ptermres
	trap	#1


* Install handler:

inshand	move.l	$476.w,tohdd+2
	move.l	#my_hfix,$476.w
	rts



my_hfix	* This starts timer C by every Rwabs call
* and restores entry state by Rwabs exit

                move.l	(sp),retcall+2
	move.l	#rether,(sp)
	move.l	$114.w,timcib+2	
	
* Maybe need to set status register too .... for now leave without .

* Save Timer C related registers:

	lea	mfpsav(pc),a1
	move.b	$FFFFFA09.w,(a1)+
	move.b	$FFFFFA15.w,(a1)+
	move.b	$FFFFFA1D.w,(a1)+

	*Timer  C needs accurate reading:

*So we read  some time and take
*Max value:

	lea	$FFFFFA23.w,a2
	move.w	#4777,d7   *Determines time for read, CPU speed
* dependant
	clr.b	d4

retimbl
	move.b	(a2),d3
	cmp.b	d3,d4
	bcc.s	renotbc

rebiggerc	move.b	d3,d4
renotbc	dbf	d7,retimbl
	
	move.b	d4,(a1)	  * Timer C Data reg.


	and.b	#$07,$FFFFFA1D.w
	or.b	#$50,$FFFFFA1D.w
	move.b	#$C0,$FFFFFA23.w   * C Timer Data, Cntrl set

* Use own Timer C interrupt code for sure - present may not
* count  $4BA !
	move.l	#tim200,$114.w

* Enable Timer C for sure :
	bset	#5,$FFFFFA09.w   * IE reg
	bset	#5,$FFFFFA15.w   * IM reg
	clr.b	$FFFFFA11.w   * Must clear ISRB
tohdd	jmp	0   *****  to driver


* Here returns from driver :
rether	lea	mfpsav(pc),a1
	move.b	(a1)+,$FFFFFA09.w
	move.b	(a1)+,$FFFFFA15.w
	move.b	(a1)+,$FFFFFA1D.w
	move.b	(a1),$FFFFFA23.w



timcib	move.l	#0,$114.w  ****

retcall	jmp	0  ****



tim200	addq.l	#1,$4BA.w
	clr.b	$FFFFFA11.w   * Must clear ISRB . Here too ...
	rte


mfpsav	dc.b	4



    section  bss

    ds.b  8

fin
