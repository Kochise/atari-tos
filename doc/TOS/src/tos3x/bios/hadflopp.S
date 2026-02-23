#include "hades.inc"

defhdinf	equ $302		/*  Default hdinf. byt 0 -> anzahl versuche byt 1 -> taktrate (hd default) */
save1		equ $f8		/*  L:ablageregister */
save2		equ $fC		/*  L:ablageregister */

ed		equ 0			/*  clockraten fr verschiedene format */
hd		equ 2
dd		equ 3
hlt		equ 15			/* head load time in milisekunden (in 1ms schriten 1-128ms) */
hut		equ 24			/* head unload time in ms (in 16ms schritten 8-120ms) */

/* fd_frb & fd_copyp not used by hades; use it for different purpose */
#define status_buffer fd_frb

#define rwflag     fd_motoron
#define moton      fd_desel
#define verifyflag fd_interlv

#define TTMFP_GPIP (TTMFP_REGS+0)

	text

/*
 * flopini - initialize floppies
 * int flopini(void *buffer, DSB *dsb, int devno)
 *
 * Returns:       EQ if initialization succeeded (drive attached).
 *                NE if initialization failed (no drive attached).
 */
/* 306de: 00e03ba8 */
/* 306us: 00e03b4e */

        xdef _flopini
_flopini:
		lea	dsb.w,a1
		tst.w	12(a7)			/* Disk Status Block setzen */
		beq.s	flopini1
		lea	(dsb+dsb_sizeof).w,a1

flopini1:
		move.w	_seekrate.w,fd_seekrate(a1)
		move.w  12(a7),fd_dev.w
		bsr	fdc_reset
		move.w	#-256,fd_curtrack(a1)	/* negative to execute restore */
		moveq	#-1,d0
		bsr.s	floplock		/* incl. select0 und restore */
		beq	flopok
		bra.s	flopfail

************************ no_flops  keine Floppies vorhanden	(Neu gg. 2.06)	***
no_flops:
		moveq	#-15,d0
		rts


/*
 * floplock - lock floppies and setup floppy parameters
 *
 * Passed (on the stack):
 *        24(sp) - count.W (sector count)
 *        22(sp) - side.W (side#)
 *        20(sp) - track.W (track#)
 *        18(sp) - sect.W (sector#)
 *        16(sp) - dev.W (device#)
 *        12(sp) - obsolete.L
 *         8(sp) - dma.L (dma pointer)
 *         4(sp) - ret1.L (caller's return address)
 *         0(sp) - ret.L (floplock's return address)
 *
 * Passed:       D0.W = default error number
 */
******************************* floplock  Floppy Parameter uebernehmen S.119	***
floplock:
		movem.l	d1-d7/a2-a3,flopsregs
		move.w	#1,_flock.w		/* aktiv */
		move.w	d0,fd_deferr.w
		move.w	d0,fd_curerr.w
		move.l	8(a7),a3                /* a3 zeigt auf buffer */
		move.l	a3,fd_buffer.w
		move.w	14(a7),verifyflag.w
		move.w	16(a7),fd_dev.w
		move.w	18(a7),d4               /* startsector nach d4 */
		move.w	d4,fd_sect.w
		move.w	20(a7),fd_track.w
		move.w	22(a7),fd_side.w
		move.w	24(a7),fd_scount.w
		move.w	#2,fd_retry.w
/* ------------------------------------------------- */
		lea	dsb.w,a1		/* Disk Status Block setzen */
		tst.w	fd_dev.w
		beq.s	flplock1
		lea	(dsb+dsb_sizeof).w,a1
/* ------------------------------------------------- */
flplock1:
		tst.w	fd_curtrack(a1)		/* dsb[devno].curtrack */
		bpl.s	lock_rts		/* positiv? dann fertig */
/* ------------------------------------------------- */
		bsr	select0			/* negativ? dann restore */
		bsr	restore			/* Track 0 */
		beq	end_ok
		move.w	#-1,fd_curtrack(a1)
end_err:
		moveq	#-1,d0			/* fehler */
        rts                             /* zurueck */

************************************** flopfail  Fehler	in Floppy Routine aufgetreten S.120	---
flopfail:
		bsr	fdc_reset
		moveq	#1,d0
		bsr	setdmode
     	move.w	fd_curerr.w,d0
		ext.l	d0
		bra.s	flopok1
**************************************** flopok	Floppy Routine fehlerfrei beendet S.120	---
flopok:
		clr.l	d0
flopok1:
		move.l	d0,-(a7)
/* ------------------------------------------------- */
		tst.b	moton.w                 /* motor aus? */
		beq.s	flopok3                 /* ja -> */
		move.l	_hz_200.w,d0
		addi.l	#1000,d0		/* Nachlaufzeit 5 sec */
		move.l	d0,fd_timeout
		move.b	#$3e,ldor		/* select aus,motor bleibt on */

flopok3:
		move.w	fd_dev.w,d0
		lsl.w	#2,d0
		lea	_fd_lastacc.w,a0
		move.l	_frclock.w,0(a0,d0.w)	/* Zugriffszeitpunkt */
		cmp.w	#1,_nflops.w		/* merken */
		bne.s	flopok2
		move.l	_frclock.w,4(a0)
/* ------------------------------------------------- */
flopok2:
		move.l	(a7)+,d0
        clr.w	_flock.w
		movem.l	flopsregs.w,d1-d7/a2-a3
lock_rts:
		rts

/*
 * XBIOS #41 - Floprate - Read or set the seek rate of a floppy drive.
 * floprate - sets the seek rate of the specified floppy drive
 * On the stack:
 *         6(sp) - rate.w (0: 6ms, 1: 12ms, 2:2ms, 3:3ms)
 *         4(sp) - dev.W (device#)
 *         0(sp) - return address
 *
 * Returns:      prior seek rate for the specified drive
 *
 */
        xdef _floprate
_floprate:
		lea	dsb,a1				/* a1	zeigt auf DSB */
		tst.w	4(a7)				/* von Laufwerk A: */
		beq.s	floprat1
		lea	(dsb+dsb_sizeof),a1				/* .w oder Laufwerk B: */
/* ------------------------------------------------- */
floprat1:
		move.w	fd_seekrate(a1),d0			/* alte seekrate holen */
		move.w	6(a7),d1			/* Parameter vom Stack */
		bmi.s	floprat2			/* get log_seekrate */
		move.w	d1,fd_seekrate(a1)			/* set log_seekrate */
		lea	steptab(pc),a0
		andi.w	#3,d1
		moveq	#3,d7				/* specify */
		bsr	sendcom
		bmi.s	floprat2
		move.b	0(a0,d1.w),d7			/* steprate, head unload time */
		bsr	sendcom
		bmi.s	floprat2
		moveq	#hlt*2+1,d7 			/* head load time, non dma */
		bsr.s	sendcom
floprat2:
		ext.l	d0
		rts
steptab:
		dc.b 	hut/8+$40,hut/8+$20,hut/8+$C0,hut/8+$a0
/*              6         7         2         3 ms   steprate */
***************************************** restore Kopf auf Track 0 positionieren S.121	---
restore:
		moveq	#$03,d7			/* specify */
		bsr.s	sendcom			/* send command */
		bmi	end_err
		lea	steptab(pc),a2          /* seekrate wandeln */
		move.w	fd_seekrate(a1),d7
		andi.w	#3,d7
		move.b  0(a2,d7.w),d7           /* steprate und head unload time */
/* 		move.b	#$af,d7			steprate immer 3ms und 120ms head unload time */
		bsr.s	sendcom
		bmi	end_err
		moveq	#hlt*2+1,d7		/* head load time, non dma */
        bsr.s	sendcom
        bmi	end_err
/* recalibrate */
		moveq	#$07,d7			/* FDC Kommando "recalibrate" */
		bsr.s	sendcom
		bmi	end_err
		move.w	fd_dev.w,d7             /* laufwerksnummer */
		bsr.s	sendcom
		bmi	end_err
/* int status */
		bsr.s	int_status		/* interrupt status erfragen */
		bmi	end_err
		move.b  status_buffer.w,d0
		andi.b	#$e0,d0
		cmpi.b	#$20,d0			/* ok? */
        bne	end_err         	/* nein-> */
		bra	end_ok

/* --------------------------------- laufwerk interrupt status erfragen */
int_status:
		bsr	wait_int		/* auf interrupt warten */
		bmi	end_err
		moveq	#$08,d7			/* sense interrupt status */
		bsr.s	sendcom
		bmi	end_err
		moveq	#1,d3   		/* 2 byts holen */
		bsr.s	holdata
		bmi	end_err
		moveq	#0,d0
		move.b  (status_buffer+1).w,d0
		move.w	d0,fd_curtrack(a1)		/* aktueller track setzen */
		rts

/* --------------------------------- sende daten in d7 nach fdc */
sendcom:
		move.l	_hz_200.w,d6
		addi.l	#100,d6                 /* 0.5 sec */
#if 0
		bsr		wait_mast
#endif
sdloop:
		cmp.l	_hz_200.w,d6		/* zeit abgelaufen? */
		bcs	end_err			/* ja */
        move.b	main_status,d0		/* status */
        andi.b   #$e0,d0			/* maske */
        cmpi.b	#$80,d0			/* bereit */
        bne	sdloop          	/* nein-> */
		move.b	d7,data_reg
		bsr.s	wait_mast
		bra.s	end_ok
/* --------------------------------- status holen anzahl byts in d3 */
holdata:
		lea	status_buffer.w,a2
holdatl:
		move.l	_hz_200.w,d6
 		addi.l	#100,d6                 /* 0.5 sec */
		bsr.s	wait_mast
hdloop:
		cmp.l	_hz_200.w,d6
		bcs	end_err			/* wenn zeit abgelaufen-> */
		move.b	main_status,d0
		andi.b	#$e0,d0			/* maske */
#if 0
		cmpi.b	#$e0,d0			/* daten? */
		beq	holdat2			/* ja-> */
#endif
		cmpi.b	#$c0,d0			/* status bereit? */
		bne	hdloop			/* nein-> */
		move.b	data_reg,(a2)+		/* statusdaten holen */
		bsr.s	wait_mast
		dbf	d3,hdloop
		bra.s 	end_ok
#if 0
holdat2:
		move.b	data_reg,d0             /* leeren */
		bsr.s	wait_mast
		bra	hdloop
#endif
/* --------------------------------- wait auf interrupt */
wait_int:
		move.l	_hz_200.w,d6
		addi.l	#100,d6			/* 1/2 sec warten */
		cmpi.b	#dd,fd_density+1(a1)	/* dd? */
		bne.s wait_int1
		addi.l	#200,d6			/* 1 sec warten */
wait_int1:
		cmp.l	_hz_200.w,d6            /* zeit abgelaufen? */
        bcs	end_err			/* ja-> */
		btst	#4,TTMFP_GPIP.w		/* int? */
        beq.s	wait_int1		/* nein nochmal-> */
end_ok:
		moveq	#0,d0			/* kein fehler */
        rts				/* zurueck */
/* -----------------------------------wait bis master status register valid */
wait_mast:
		moveq	#48,d0             	/*  --     -- ED=6us HD=12us DD=24us */
		cmp.b	#dd,fd_density+1(a1)	/* dd? */
		beq.s	wait_mastl              /* ja-> */
		moveq	#12,d0
		cmp.b   #ed,fd_density+1(a1)	/* ed? */
		beq.s	wait_mastl              /* ja-> */
wait6us:
		moveq	#24,d0                  /* sonst dd */
wait_mastl:
		tst.b	$fffffc00.w             /* dauert 0.5us wenn folgend */
		dbf	d0,wait_mastl
fdc_res_rts:
		rts
************************************* fdc_reset
fdc_reset:
		lea	_fd_latch.w,a0		/* status auf diskette gewechselt */
		add.w	fd_dev.w,a0
		move.b	#-1,(a0)
		lea	_fd_wp.w,a0
		add.w	fd_dev.w,a0
		move.b	#-1,(a0)
		move.w	#defhdinf,fd_density(a1)          /* fd_density auf default */
		btst	#4,TTMFP_GPIP.w
		beq.s	fdc_res1
		bsr	int_status
fdc_res1:
		bsr	wait_mast
		cmp.b	#$80,main_status
		beq	fdc_res_rts
		moveq	#6,d3
		bsr	holdata
		bsr	wait_mast
		cmp.b	#$80,main_status
		beq	fdc_res_rts
		move.b	#$0A,ldor		/* softreset, irq aktiv */
		move.l	_hz_200.w,d6
		addi.l	#40,d6			/* 0.2 sec */
fdc_res2:
		cmp.l	_hz_200.w,d6            /* zeit abgelaufen */
        bcc.s	fdc_res2                /* nein-> */
		move.b  #$0E,ldor
		clr.b	moton        	 	/* motor ist aus */
		bra	int_status
****************************** select taktrate  Laufwerk motor on
select0:
		move.b	fd_density+1(a1),ldcr	/* takt setzen */
		move.w	fd_dev.w,d0           	/* laufwerk nummer */
		addi.b	#$3C,d0               	/* motoren on kein softreset */
		move.b  d0,ldor			/* setzen */
        tst.b	moton.w
        bne.s	select0_rts		/* ja */
        move.l	_hz_200.w,d6
        addi.l	#200,d6                	/* 1.0 sec */
sel1:
		cmp.l	_hz_200.w,d6            /* abgelaufen */
		bcc	sel1                    /* nein-> */
        bsr	restore			/* zum anfang */
		move.b	#1,moton.w              /* moton on */
select0_rts:
		rts

****************************************** flopvbl Floppy VBL-Handler S.118	***
/* 		PART 'flopvbl' */
/*
 * _flopvbl - floppy vblank handler
 * Deselects floppies after the motor stops
 */
        xdef _flopvbl
_flopvbl:
		tst.w	_nflops.w
		beq	vbl_rts
		tst.w	_flock.w			/* aktiv? */
		bne	vbl_rts			/* ja-> */
/* ------------------------------------------ test auf diskettenwechsel ueber wp */
		move.l	_frclock.w,d1
		move.b	d1,d0
		andi.b	#7,d0                   /* 8. vbl ? */
		bne.s	vbl_rts                 /* nein -> */
/* ------------------------------------------------- */
		lsr.b	#3,d1
		andi.w	#1,d1				/* abwechslungsweise Laufwerk A: oder B: 0 or 1 */
		lea	_fd_wp.w,a0
		add.w	d1,a0                           /* floppy A byt 0. floppy B byt 1 */
		cmp.w	_nflops.w,d1                    /* floppy B und vorhanden? wenn nur 1 und ist 1 (nur lw A) */
		bne.s	vbl1                            /* nein -> lw B vorhanden */
		clr.w	d1                              /* sonst lw A */
/* ------------------------------------------------- */
vbl1:
		lea	dsb.w,a1
        tst.b	d1				/* lw B */
        beq.s	vbl3
        lea	(dsb+dsb_sizeof).w,a1
vbl3:
		move.b	#$3c,d6
		add.w	d1,d6                           /* +lw */
		move.b	d6,ldor				/* floppy on */
		moveq	#4,d7				/* sense drive status */
		bsr	sendcom
		move.w	d1,d7                           /* lw */
		bsr	sendcom
		moveq	#0,d3				/* 1 byt holen */
		bsr	holdata
		btst	#6,status_buffer.w		/* H=Schreibgeschuetzt */
        sne	(a0)                            /* changenew setzen */
        beq.s	vbl2                            /* nicht gewechselt resp. nicht wp */
		move.w	#defhdinf,fd_density(a1)          	/* fd_density auf default */
/* ------------------------------------------------- */
vbl2:
		move.w	_fd_wp.w,d0
		or.w	d0,_fd_latch.w         		/* wenn gewechselt auf gewechselt oder halten */
        tst.b	moton.w                         /* motor on? */
        beq.s	vbl4                            /* nein */
/* ------------------------------------------------- motor abstellen ? */
		move.l	_hz_200.w,d0
		cmp.l	fd_timeout,d0			/* .w waehrend Nachlaufzeit	... */
		bcs.s	vbl5	                         /* nein nicht abstellen */
/* ------------------------------------------------- */
vbl4:
		move.b  #$0E,ldor			/* alle LW abschalten */
		clr.b	moton.w
vbl_rts:
		rts
vbl5:
		move.b	#$3e,ldor
		rts
********************************** seek_cur	 aktuellen Track anfahren S.120	***
/* 		PART 'flopseek' */
/* -------------------------------------------- homeseek	Home und Seek S.120	--- */
homeseek:
		move.w	#-6,fd_curerr.w
		bra	restore
/* ---------------------------- seek_ver	aktuellen Track	anfahren mit Verify	--- */
seek_ver:
		move.w	#-6,fd_curerr.w
/* ------------------------------------------------- */
		moveq	#$0f,d7                  	/* seek */
		bsr	sendcom
		bmi	end_err
		move.w	fd_side.w,d7                    /* side */
		lsl.w	#2,d7                           /* nach bit 2 */
		add.w	fd_dev.w,d7                     /* +lw nr. */
		bsr	sendcom
		bmi	end_err
		move.w	fd_track.w,d7                   /* track */
		bsr	sendcom
		bmi	end_err
        bsr	int_status
        bmi	end_err
		move.w	fd_track.w,d0                   /* soll */
		cmp.w	fd_curtrack(a1),d0		 	/* richtig? */
		beq	end_ok
		bra	end_err
***********************************	change	Test auf Diskettenwechsel bei einem lw S.123	***
change:
		cmp.w	#1,_nflops.w
		bne.s	chg_rts

		move.w	16(a7),d0			/* fd_dev vom Stack */
		cmp.w	_curflop.w,d0               	/* lw gewechselt? */
		beq.s	change1                       	/* nein-> */

		move.w	d0,-(a7)
		move.w	#-17,-(a7)
		jsr	_callcrit			/* jsr */
		addq.w	#4,a7

		lea	_fd_lastacc.w,a0
		clr.l	(a0)+
		clr.l	(a0)
		move.w	16(a7),_curflop.w		/* neues logisches LW */

change1:
		clr.w	16(a7)				/* drive nummer auf LW A: */
chg_rts:
		rts
/* --------------------------------- setdmode	 Drive Change Mode setzen S.123	--- */
setdmode:
		lea	_drivechange.w,a0
		move.b	d0,-(a7)
		move.w	fd_dev.w,d0
		cmp.w	#1,_nflops.w
		bne.s	setdmod1

		move.w	_curflop.w,d0
setdmod1:
		move.b	(a7)+,0(a0,d0.w)
		rts

***************************************************** Xbios(8,9,19) Floprd,Flopwr,Flopver S.113	***
/* ------------------------------------------------- daten transfer VOM fdc */
fdc_rdint:
		bclr	#6,$fffffa89.w                  /* int off */
		movem.l	a0/d0-d1,-(sp)                  /* register sichern */
        move.l	fd_buffer.w,a0                    /* transferadresse */
        move.w	#512,d0                         /* 1 sector a 512 byts */
fdc_rdint2:
		btst	#4,TTMFP_GPIP.w			/* daten? */
        beq.s	fdc_rdint3			/* nein -> ende daten oder error */
        move.b	data_reg,(a0)+			/* daten transportieren */
		subq.w	#1,d0                           /* -1 */
		beq.s	fdc_rdint1                      /* wenn 0 dann ende */
		move.w	#200,d1                         /* timeout 50us */
fdc_rdint3:
        tst.b	$fffffc00.w			/* 0.5us warten */
        dbf	d1,fdc_rdint2                      /* abgelaufen? nein-> */
fdc_rdint1:
		move.l	a0,fd_buffer.w
		movem.l (sp)+,a0/d0-d1
		bclr    #6,$fffffa91                  /* in service loeschen */
		rte
/* ------------------------------------------------- daten transfer ZUM fdc */
fdc_wrint:
		bclr	#6,$fffffa89.w                  /* int off */
		movem.l	a0/d0-d1,-(sp)                  /* register sichern */
        move.l	fd_buffer.w,a0
        move.w	#512,d0                         /* 1 sector a 512 byts */
fdc_wrint2:
		btst	#4,TTMFP_GPIP.w			/* daten? */
        beq.s	fdc_wrint3			/* nein -> ende daten oder error */
        move.b	(a0)+,data_reg			/* daten transportieren */
		subq.w	#1,d0                           /* -1 */
		beq.s	fdc_wrint1                      /* wenn 0 dann ende */
		move.w	#200,d1                         /* timeout 50us */
fdc_wrint3:
        tst.b	$fffffc00.w			/* 0.5us warten */
        dbf		d1,fdc_wrint2                      /* abgelaufen? nein-> */
fdc_wrint1:
		move.l	a0,fd_buffer.w
		movem.l (sp)+,a0/d0-d1
		bclr    #6,$fffffa91                  /* in service loeschen */
		rte
/* ------------------------------------------------- daten transfer per interrupt VOM fdc fuer verify */
fdc_vrint:
		bclr	#6,$fffffa89.w                  /* int off */
		movem.l	a0/d0-d2,-(sp)                  /* register sichern */
        move.l	fd_buffer.w,a0
        move.w	#512,d0                         /* 1 sector a 512 byts */
fdc_vrint2:
		btst	#4,TTMFP_GPIP.w			/* daten? */
        beq.s	fdc_vrint3			/* nein -> ende daten oder error */
        move.b	data_reg,d2			/* daten holen */
        tst.w   verifyflag.w
        beq.s   fdc_vrint4
		cmp.b	(a0)+,d2			/* daten vergleichen */
		beq.s	fdc_vrint4                      /* ok gleich-> */
		move.b	#2,(rwflag+1).w                   /* sonst fehler setzen */
fdc_vrint4:
		subq.w	#1,d0                           /* -1 */
		beq.s	fdc_vrint1                      /* wenn 0 dann ende */
		move.w	#200,d1                         /* timeout 50us */
fdc_vrint3:
        tst.b	$fffffc00.w			/* 0.5us warten */
        dbf		d1,fdc_vrint2                      /* abgelaufen? nein-> */
fdc_vrint1:
		move.l	a0,fd_buffer.w
		movem.l (sp)+,a0/d0-d2
		bclr    #6,$fffffa91                  /* in service loeschen */
		rte


/*
 * XBIOS #8 - Floprd - Read individual sectors from floppy disk.
 *
 * Passed (on the stack):
 *       $14(sp) count
 *       $12(sp) sideno
 *       $10(sp) trackno
 *        $e(sp) sectno
 *        $c(sp) devno
 *        $8(sp) ->DSB
 *        $4(sp) ->buffer
 *        $0(sp) return address
 *
 * Returns       EQ, the read won (on all sectors),
 *               NE, the read failed (on some sector).
 */
        xdef _floprd
_floprd:
		clr.w	rwflag.w			/* auf lesen */
		move.l	#fdc_rdint,$158.w		/* vector setzen */

floprdwr:
		tst.w	_nflops.w
		beq		no_flops

		bsr	change
		move.w	#-11,fd_curerr.w
floprd11:
		bsr	floplock
        tst.b	rwflag.w			/* write */
        beq.s	floprd1                         /* nein-> */
/* -------------------------------------------------  nur write */
		move.w	fd_sect.w,d0			/* Zugriff auf Boosektor? */
		subq.w	#1,d0
		or.w	fd_track.w,d0
		or.w	fd_side.w,d0
		bne.s	floprd13
		moveq	#2,d0
		bsr	setdmode			/* ...dann _drivechange[dev]=2 */
floprd13:
		move.w	#-10,fd_curerr.w
/* ------------------------------------------------- */

floprd1:
		bsr	select0
		bsr	seek_ver
		bmi	floprd9				/* error -> end evt. nochmal */

/* ------------------------------------------------- floppy read,write,scan commando */
/* init int */
floprd2:
		move.l	fd_buffer.w,d5                    /* start sichern */
		bset	#4,$fffffa83.w			/* int bei low to high */
		bclr	#6,$fffffa8d.w			/* interrupt pending loeschen */
		bclr	#6,$fffffa91.w                  /* in service loeschen */
		bset	#6,$fffffa95.w                  /* maske freigeben -> interrupt */
		bset	#6,$fffffa89.w			/* int enable */
/* ----------------------------------------------------- */
                moveq	#$46,d7				/* mfm read sectoren */
                sub.b	rwflag.w,d7                     /* $45 fuer write */
	   	bsr	sendcom
                move.w	fd_side.w,d7            	/* seite */
                move.w	d7,d1
                lsl.w	#2,d7                   	/* nach bit 2 */
                add.w	fd_dev.w,d7             	/* lw nr */
                bsr	sendcom
                move.w	fd_track.w,d7			/* tracknummer */
                bsr	sendcom
                move.w	d1,d7				/* nochmal seite */
                bsr	sendcom
                move.w  fd_sect.w,d7			/* secktor nr. */
                move.w	d7,d1
                bsr	sendcom
                moveq	#2,d7				/* 512 byt sektoren */
                bsr	sendcom
                move.w	d1,d7				/* eot=gleicher sector */
                bsr	sendcom
                moveq	#27,d7				/* gap length */
                cmpi.b     #dd,fd_density+1(a1)
                bne.s   floprd21
                moveq.l    #42,d7
floprd21:
                bsr	sendcom
                moveq	#-1,d7                  	/* data length not valid */
		bsr	sendcom
		move.l	_hz_200.w,d6
        addi.l	#100,d6				/* 0.5 sec warten */
        cmpi.b     #dd,fd_density+1(a1)
        bne.s   floprd3
        addi.l	#200,d6				/* 1.5 sec warten */
floprd3:
		cmp.l	_hz_200.w,d6                    /* abgelaufen? */
		bcs.s	floprd4
        btst	#6,$fffffa89.w			/* int off? = kommando ende */
        bne.s	floprd3                         /* nein */
floprd4:
		bclr	#6,$fffffa89.w                  /* int disable */
/* ------------------------------------------------------- */
	    moveq	#6,d3                           /* 7 byt status lesen */
        bsr	holdata
        bmi.s	floprd51
/* ------------------------------------------------- */
		move.b	(status_buffer+1).w,d0		/* FDC Status register 1 */
		andi.b	#$37,d0                         /* relevante bits */
		bne.s	floprd5                 	/* wenn nicht null dann error */
		tst.b	(rwflag+1).w			/* verify? */
		bne.s	floprd8				/* nein-> */
		tst.w	verifyflag.w			/* setortest? */
		beq.s	floprd8				/* ja-> */
		cmp.b	#1,(rwflag+1).w			/* daten gleich ? */
		bne.s	floprd5                         /* nein -> */
/* ------------------------------------------------- */
floprd8:
		move.w	#2,fd_retry.w			/* 3 versuch */
		addq.w	#1,fd_sect.w                     /* naechster sector */
		subq.w	#1,fd_scount.w                     /* anzahl -1 */
		bne	floprd2
		tst.b	(rwflag+1).w			/* verify? */
		beq	flopok                          /* nein-> */
		tst.w	verifyflag.w			/* sectortest */
		bne	flopok				/* nein-> */
		clr.w	(a3)                            /* def. sector abschluss */
		bra	flopok				/* fertig */
/* ------------------------------------------------- */
floprd51:
		moveq.l    #16,d0
floprd5:
		move.l	d5,fd_buffer.w			/* alter start */
		tst.w	fd_retry.w			/* 2.versuch */
		bne.s	floprd91				/* nein-> */
		cmp.w	fd_sect.w,d4			/* startsector? */
		bne.s	floprd91				/* nein-> */
		tst.b	rwflag.w			/* read? */
		bne.s	floprd91				/* nein-> */
		subq.b	#1,fd_density(a1)	/* 1 versuche weniger */
		beq.s	floprd91                         /* ja-> */
		move.w	#2,fd_retry.w                      /* retry wieder auf 2 */
		cmp.b	#ed,fd_density+1(a1)		/* ed? */
		bne.s	noed                            /* nein-> */
		move.b	#hd,fd_density+1(a1)		/* ist ed weiter nach hd */
		bra.s	floprd12
noed:
		cmp.b	#dd,fd_density+1(a1)		/* dd? */
		bne.s	nodd                            /* nein */
		move.b	#ed,fd_density+1(a1)		/* ist dd weiter nach ed */
		bra.s	floprd12
nodd:
		move.b	#dd,fd_density+1(a1)		/* bleibt noch dd */
floprd12:
		move.b	fd_density+1(a1),ldcr			/* takt setzen */
		move.l  (_hz_200).w,d6
		addi.l  #100,d6
floprd14:
		cmp.l   (_hz_200).w,d6
		bcc.s   floprd14
		bsr	restore                         /* alles auf anfang */
		bra	floprd1				/* mit andererm takt probieren */
floprd9:
		move.b  #2,(status_buffer+2).w
		clr.l   d0
floprd91:
		bsr.s	errbits				/* Fehlerbehandlung */
floprd6:
		cmp.w	#1,fd_retry.w
		bne.s	floprd7
		bsr	homeseek
floprd7:
		subq.w	#1,fd_retry.w
		bpl	floprd2				/* nochmal versuchen */
		tst.b	(rwflag+1).w			/* verify? */
		beq	flopfail			/* nein-> */
		tst.w	verifyflag.w			/* sectortest? */
		bne	flopfail			/* nein-> error end */
		move.w	fd_sect.w,(a3)+                  /* defekter sector eintragen */
		bra	floprd8				/* und naechster */
************************************* errbits  Fehlernummer bestimmen S.114	***
errbits:
		moveq	#-13,d1               		/* write protect */
		btst	#1,d0
		bne.s	errbits1

		moveq	#-8,d1                		/* sektor error */
		btst	#0,d0
		bne.s	errbits1

		moveq	#-6,d1                		/* seek error */
		btst	#1,(status_buffer+2).w		/* st2 */
		bne.s	errbits1

		moveq	#-4,d1                		/* crc error */
		btst	#5,d0
		bne.s	errbits1

		moveq	#-2,d1  			/* timeout */
		btst	#4,d0
		bne.s	errbits1

		move.w	fd_deferr.w,d1
errbits1:
		move.w	d1,fd_curerr.w
		rts

/*
 * XBIOS #9 - Flopwr - Write individual sectors on a floppy disk.
 * flopwr - write sector to floppy
 * Passed (on the stack):
 *        20(sp) count
 *        18(sp) sideno
 *        16(sp) trackno
 *        14(sp) sectno
 *        12(sp) devno
 *         8(sp) ->DSB
 *         4(sp) ->buffer (unused)
 *         0(sp) return address
 *
 * Returns:      EQ, the write won (on all sectors),
 *               NE, the write failed (on some sectors).
 */
        xdef _flopwrt
_flopwrt:
		move.w	#$100,rwflag.w
		move.l	#fdc_wrint,$158.w		/* vector setzen */
		bra	floprdwr

/*
 * XBIOS #19 - Flopver - Verify sectors of a floppy disk.
 * _flopver - verify sectors on a track
 *       $14(sp) count
 *       $12(sp) sideno
 *       $10(sp) trackno
 *        $e(sp) sectno
 *        $c(sp) devno
 *        $8(sp) ->DSB
 *        $4(sp) ->buffer (at least 1K long)
 *        $0(sp) return address
 *
 * Returns:      NULL.W-terminated list of bad sectors in the buffer if D0 == 0,
 *               OR some kind of error (D0 < 0).
 *
 */
        xdef _flopver
_flopver:
		move.w	#1,rwflag.w                   	/* read zum verify */
		move.l	#fdc_vrint,$158.w		/* vector setzen */
		bra	floprdwr

/*
 * XBIOS #10 - Flopfmt - Format specific tracks on a floppy
 * _flopfmt - format a track
 * Passed (on the stack):
 *        26(sp) initial sector data
 *        22(sp) magic number
 *        20(sp) interleave
 *        18(sp) side
 *        16(sp) track
 *        14(sp) spt
 *        12(sp) devno
 *         8(sp) pointer to state block
 *         4(sp) dma address
 *         0(sp) [return]
 *
 * Returns:      EQ: track successfully written.  Zero.W-terminated list of
 *               bad sectors left in buffer (they might /all/ be bad.)
 *
 *               NE: could not write track (write-protected, drive failure,
 *               or something catastrophic happened).
 */
        xdef _flopfmt
_flopfmt:
		cmp.l	#-$789ABCDF,22(a7)
		beq.s	_flopfmt_ok
		moveq.l #-1,d0
		rts
_flopfmt_ok:
		tst.w	_nflops.w
		beq	no_flops

		bsr	change
		bsr	floplock

		move.w  14(a7),fd_spt.w                   /* anzahl sectoren */
		move.l	8(a7),fd_secmap.w                	/* sectortabelle */
		move.w	20(a7),fd_interlv.w               /* sectortabelle vorhanden? */
		bmi	fmt31                           /* ja */
/* ---------------------------------------------- sectorreihenfolge in tabelle erzeugen */
/* d0 = anzahl sectoren. d1 = standort im buffer. d2 = interleave. d3 = schleifenzaehler. d4 = momentane sectornummer. */
		moveq	#1,d4
		moveq	#0,d1                           /* 1. tabellenplatz */
		move.w	fd_spt.w,d0                       /* anzahl sectoren */
		move.w	d0,d3                           /* nach d3 als zaehler */
fmt24:
		clr.b	0(a3,d3.w)                      /* sectortabelle loeschen */
		dbf	d3,fmt24
		move.w	d0,d3
		move.w	fd_interlv.w,d2
		subq.w	#2,d3				/* -1 umlauf (resp. 2 wegen dbf) */
		move.b	d4,(a3)				/* 1. sector */
fmt22:
		add.w	d2,d1
		cmp.w	d1,d0                           /* groesser oder gleich max */
		bge.s	fmt23				/* nein-> */
		sub.w	d0,d1
fmt23:
		addq.w	#1,d4                           /* naechster sector */
fmt26:
		tst.b	0(a3,d1.w)			/* frei? */
		beq.s	fmt25
		addq.w	#1,d1				/* sonst next */
		bra.w	fmt26
fmt25:
		move.b	d4,0(a3,d1.w)			/* eintragen */
		dbf	d3,fmt22			/* next bis ende */
		moveq	#40,d3				/* rest fuellen */
fmt27:
		addq.w	#1,d4                           /* naechste sectornummer */
		addq.w	#1,d1                           /* naechster platz */
		move.b	d4,0(a3,d1.w)                   /* eintragen */
		dbf	d3,fmt27
/* ----------------------------------------------- */
fmt21:
		move.w	26(a7),fd_virgin.w  		/* datenwert */
		moveq	#2,d0
		bsr	setdmode
		moveq	#-1,d0
/* ------------------------------------------------- */
		moveq	#dd,d0
		cmp.w	#12,fd_spt.w			/* DD? */
		blt.s	fmt1                      	/* ja-> */
		moveq	#ed,d0
		cmp.w	#24,fd_spt.w			/* ed? */
		bgt.s   fmt1                            /* ja */
		moveq	#hd,d0
/* ------------------------------------------------- */
fmt1:
		addi.w  #$0300,d0
		move.w	d0,fd_density(a1)			/* dsb.fd_density setzen */
		bsr	select0
fmt6:
		move.w	#1,fd_sect.w			/* startsector auf 1 */
		bsr	seek_ver
		move.w	#-1,fd_curerr.w
/* init int */
                move.l	#fdc_format,$158.w		/* vector setzen */
		bset	#4,$fffffa83.w			/* int bei low to high */
		bclr	#6,$fffffa8d.w			/* interrupt pending loeschen */
		bclr	#6,$fffffa91.w          /* in service loeschen */
		bset	#6,$fffffa95.w          /* maske freigeben -> interrupt */
		bset	#6,$fffffa89.w			/* int enable */
/* ----------------------------------------------------- */
        moveq	#$4D,d7				/* mfm format track */
		bsr	sendcom
        move.w	fd_side.w,d7            	/* seite */
        lsl.w	#2,d7                   	/* nach bit 2 */
        add.w	fd_dev.w,d7             	/* lw nr */
        bsr	sendcom
        moveq	#2,d7				/* 512 byt sektoren */
        bsr	sendcom
        move.w  fd_spt.w,d7			/* anzahl sectoren */
        bsr	sendcom
        moveq	#108,d7				/* gap length */
        cmpi.b  #hd,fd_density+1(a1)
        beq.w   fmt2_1
        moveq   #80,d7
fmt2_1:
        bsr	sendcom
        move.b	fd_virgin.w,d7			/* datawert */
		bsr	sendcom
		move.l	_hz_200.w,d6
        addi.l	#300,d6				/* 1.5 sec warten */
fmt2:
		cmp.l	_hz_200.w,d6                    /* abgelaufen? */
		bcs.w	fmt3
		btst	#6,$fffffa89.w			/* fertig? */
		bne.w	fmt2				/* nein */
/* ---------------------------------------------------------- */
fmt3:
		bclr	#6,$fffffa89.w			/* int off */
		moveq	#6,d3                           /* 7 byt status lesen */
        bsr	holdata
        bmi	flopfail
/* ------------------------------------------------- */
		move.b	(status_buffer+1).w,d0		/* FDC Status register 1 */
		andi.b	#$37,d0                         /* relevante bits */
		bne.s	fmt5	                 	/* wenn nicht null dann error */
/* ------------------------------------------------- sectortest ausfuehren */
fmt8:
		clr.w	(a3)				/* keine def. sectoren */
		tst.w	$444.w				/* verfiy? */
		beq	flopok                          /* nein-> */
        move.l	a3,fd_buffer.w			/* bufferzeiger auf anfang */
		move.w	#1,fd_sect.w                     /* beginnen bei sector 1 */
		move.w	fd_spt.w,fd_scount.w                 /* alle sectoren pruefen */
		clr.w	verifyflag.w			/* sectortest */
		move.w	#2,fd_retry.w			/* 3 Versuche */
		move.w	#1,rwflag.w                   	/* read zum verify */
		move.l	#fdc_vrint,$158.w		/* vector setzen */
		bra	floprd2
/* ------------------------------------------------- */
fmt5:
		bsr		errbits				/* Fehlerbehandlung */
		cmp.w	#1,fd_retry.w
		bne.w	fmt7
		bsr	homeseek
fmt7:
		subq.w	#1,fd_retry.w
		bpl	fmt6				/* nochmal versuchen */
		bra  	flopfail
		rts
/* ------------------------------------------------------------ sectortabelle uebertragen */
fmt31:
		move.w	fd_spt.w,d0                       /* anzahl sectoren */
		move.w	d0,d2
		move.l	fd_secmap.w,a0                    /* tabelle */
		move.l	a3,a2                           /* bufferadresse */
		subq.w	#1,d0                           /* -1 wegen dbf */
fmt32:
		move.w	(a0)+,d1                        /* sectornr. als word holen */
		move.b	d1,(a2)+                        /* und als byt speichern */
		dbf	d0,fmt32                        /* wiederholen bis fertig */
		move.w	#40,d0                          /* rest fuellen */
fmt33:
		addq.w	#1,d2
		move.b	d2,(a2)+                        /* eintragen */
		dbf	d0,fmt33                        /* bis fertig */
		bra	fmt21                           /* weiter */
/* ----------------------------------------------- format int */
fdc_format:
		movem.l	d0-d1/a0,-(sp)                  /* register retten */
		bclr	#6,$fffffa89.w			/* int off */
		move.l	fd_buffer.w,a0                    /* bufferregister holen */
		move.w	fd_spt.w,d0			/* anzahl sectoren */
		subq.w	#1,d0				/* -1 wegen dbf */
#if 0
		btst	#5,main_status                  /* daten? */
		beq	form2                           /* nein -> fertig */
#endif
		bra.w	form3
form1:
		bsr.s	formintwaitb
		bmi.s	form2				/* error */
form3:
		move.b	(fd_track+1).w,data_reg		/* track nummer */
		bsr.s	formintwait                     /* wait auf int */
		bmi.s	form2                           /* error-> */
		move.b	(fd_side+1).w,data_reg		/* seite */
        bsr.s	formintwait
        bmi.w	form2                           /* error */
		move.b	(a0)+,data_reg			/* sector nummer */
        bsr.s	formintwait
        bmi.w	form2                           /* error */
		move.b	#2,data_reg			/* 512 byt sectoren */
        dbf	d0,form1                        /* wiederholen bis fertig */
form2:
		move.l	a0,fd_buffer.w                    /* bufferregister zurueck */
		movem.l	(sp)+,d0-d1/a0			/* register zurueck */
		bclr	#6,$fffffa91.w          /* in service loeschen */
		rte
/* ----------------------------------------------------------------------- */
formintwaitb:
		move.l	#100000,d1                      /* timeout 50ms */
		bra	formintwait1
formintwait:
		moveq	#100,d1                         /* timeout 50us */
formintwait1:
		btst	#4,TTMFP_GPIP.w                       /* int? */
		bne	formintwait2                    /* ja-> */
		tst.b	$fffffc00.w			/* 0.5us warten */
        subq.l	#1,d1                           /* abgelaufen */
        bpl.w	formintwait1                    /* nein-> */
		rts
formintwait2:
		btst	#5,main_status			/* daten? */
        bne	formintwait3			/* ja */
        moveq	#-1,d1                          /* sonst error */
		rts
formintwait3:
		moveq	#0,d1                           /* ok */
		rts

		RESERVE_SPACE(_flopini,$e03ba8,$e045d8)
