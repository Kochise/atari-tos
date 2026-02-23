/*
 * BIOS functions for hades that don't
 * fit as patches in the original routines
 */

#include "config.h"
#include "asmdefs.h"
#include "tosvars.inc"
#include "biosdefs.h"

#if HADES /* whole file */

#include "hades.inc"

/*
 * Dateiversion:		4.43
 * Erstellt am:		03.09.1994
 * letzte Aenderung vom :	27.03.1997
 *
 * .26 .28
 * Hier eine wichtige Aenderung !!!
 * wenn ein Programm so heftig abstuerzt, das es die memval
 * Variablen zerschiesst, konnte bei tos im ram (pmmu an)
 * ein derber Haenger passieren. Also hier schon ALLES AUS !!!
 * und Hardware nicht cachen.
 *
 * .29
 * Nach dem ERSTEN Einschalten reagiert auch die PMMU des 68040
 * allergisch auf einen PFLUSHA Befehl. Nachdem dieser hier erst
 * wieder rausgeflogen ist (passiert beim Cookie-Test sowieso
 * nochmal) ist auch dieser ominoese Einschalt-Haenger verschwunden.
 * Natuerlich steht auch zu diesem 'Problem' nix in der Motorola-Doku ...
 *
 * kein 68030,romport,mmu und scu
 * 68040 init -> mmu aus etc.
 * (fa_8.11.94):mmu cacr etc nur einmal setzen
 */


/* maschinen und tos id */
hadesid		equ $68616465 /* 'hade' */

/* offsets to emulator binaries */
#define mach64_pci_offset $70000
#define mach64_isa_offset $72000
/* absolute address where it will be executed */
#define mach64_org $300000

/*
 * Yes, we assemble to the data segment here, so that the code ends up at the end of the ROM image
 */
	data

/*  Der Anhaengsel hinter dem TOS wurde ein wenig weiter nach hinten verlegt */
/*  um auch noch Platz fuer groessere Resourcen (TOS-Patch) und Winx zu haben */
/*	org HADES_XBIOS */

hades_xbios: ds.b 0

serialno:
	.ascii "SN:E55G2030"
	.even

nullframe:	dc.l	0		/* statt $FF kann hier auch der Null-Frame hin */

/*  Hier erst mal der zweite Teil des Cookie-Setzers */

	xdef morecook
morecook:
/*  .24 .26 .27 .28 */
/*  Die naechste grosse Aenderung ist beim _FPU cookie passiert !!! */
/*  Hier wird jetzt nicht mehr nur einfach auf 8=68040 gesetzt, sondern */
/*  'ganz ordentlich' alles das was bei Atari so dokumentiert ist auch */
/*  geprueft. Dabei gibt es jedoch eine kleine Ausnahme - der 68060 ist */
/*  bei Atari noch nicht bekannt, hierfuer wird Bit 4 im Highword (16) */
/*  gesetzt. Das duerfte der weiteren Nomenklatur entsprechen ... */
/*  Da der _FPU-cookie nun geprueft wird, kann man wohl auch einen */
/*  68LC040 einsetzen - der meldet als _FPU dann eben 0 */

		move.l #$5F465055,(a0)+  /* '_FPU' */

/*  Nach Atari Dokumentation ist die Belegung wie folgt: */
/*  _FPU Cookie ist IMMER da !!! */
/*  Belegung im Highword: */
/*   0 = keine Hardware- FPU */
/*   1 = Atari Register FPU (memory mapped)  -> wird nicht getestet */
/*   2 = LineF FPU */
/*   3 = Atari Register FPU + LineF FPU */
/*   4 = mit Sicherheit 68881 LineF FPU */
/*   5 = Atari Register FPU + mit Sicherheit 68881 LineF FPU */
/*   6 = mit Sicherheit 68882 LineF FPU */
/*   7 = Atari Register FPU + mit Sicherheit 68882 LineF FPU */
/*   8 = 68040 internal LineF FPU */
/*   9 = Atari Register FPU + 68040 internal LineF FPU */
/*  16 = 68060 internal LineF FPU */

/*  Das Loword ist fuer eine spaetere eventuelle */
/*  softwaremaessige LineF- Emulation reserviert und derzeit immer 0 */

		moveq	#0,d1
noafpu:
		move.l	a3,sp
		move.l	a2,_buserror.w	/*  Busfehler zurueck */

/*  Test auf (Line F) */

		move.l	_lineftrap.w,a1		/*  LineF retten */
		lea	nolfpu(pc),a2			/*  bei LineF Trap gehts dahin */
		move.l	a2,_lineftrap.w

/*  .29 */
/*  wenn schon die FPU getestet wird, koeenen wir sie zur Sicherheit */
/*  vor dem Test auch noch in einen definierten Zustand bringen - dazu */
/*  einfach den NULL-Frame eingefuegt ... */

		lea	nullframe(pc),a2	/*  NULL-Frame fuer FPU-Reset */
		dc.w	$f352			/*  frestore (a2) */
		move.l	sp,a2

/*  .28 */
/*  Diese Stelle war eine der Trickreichsten !!! */
/*  Beim 68881 und 68882 reicht ein schlichtes FNOP um beim */
/*  naechsten FSAVE statt eines NULL-Frame (habe noch nichts getan) */
/*  einen IDLE-Frame (habe schon was getan, aber gerade nix mehr zu tun) */
/*  zu erhalten, der dann auch ein Version Byte enthaelt. Das dieses Version */
/*  Byte beim 68040 und 68060 an anderer Stelle zu finden ist, konnte man */
/*  ja noch so halbwegs der Doku entnehmen, dass der 68040 ein FNOP aber */
/*  schlichtweg wegoptimiert und danach immer noch einen NULL-Frame liefert */
/*  allerdings nicht (Puh, DAS zu finden hat mich 2 Tage und ich weiss nicht */
/*  wie viele gebrannte Eproms gekostet (wann bekommt die Medusa endlich */
/*  Static-Rams statt EPROMs ...), denn wenn ich's als externes */
/*  Programm probiert habe, hatte die FPU ja schon was getan und antwortete */
/*  auch auf ein FNOP mit dem erwarteten IDLE-Frame. Beim Booten stand im */
/*  FPU-cookie aber natuerlich immer nur 2 (LineF-FPU Typ unbekannt)). Jetzt */
/*  wird statt FNOP einfach ein FTST.X FP0 verwendet - und siehe da - es geht ... */

/* (fa_10.11.94)(1_12_94):einigie aenderungen */

		dc.l	$F2004000		/*  fmove.l d0,fp0 */
		dc.w	$F327			/*  fsave	-(sp) */
		move.l	(sp),d2 		/*  Version Bytes ($18=881,$38=882,... */
		move.l	a2,sp			/*  Stack korrigieren */
		move.l	d2,d0

		cmp.w	#60,_longframe.w		/*  mc68060 */
		bne.s	no060			/*  ja-> */
		cmpi.w	#$6000,d2		/*  68060 internal FPU ? */
		beq.s	is060	       	/*  ja-> */

no060:
		rol.l	#8,d0
		cmpi.b	#$41,d0			/*  68040 internal FPU ? */
		beq.s	is040
		cmpi.b	#$40,d0			/*  68040 internal FPU ? */
		beq.s	is040
		move.l	d2,d0
		ror.l	#8,d0
		ror.l	#8,d0
		cmpi.b	#$18,d0			/*  68881 ? */
		beq.s	is881
		cmpi.b	#$38,d0			/*  68882 ? */
		beq.s	is882           /*  ja -> */
        bne.s   nolfpu          /*  sonst linef */

is060:
		addq.w	#8,d1			/* 16: 68060 */
is040:
		addq.w	#2,d1			/*  8: 68040 */
is882:
		addq.w	#2,d1			/*  6: 68882 */
is881:
		addq.w	#2,d1			/*  4: 68881 */
linef_emu:
		addq.w 	#2,d1			/*  2: LineF- FPU */
nolfpu:			    			/*  keine LineF FPU */
		move.l	a3,sp			/*  Stack korrigieren */
		move.l	a1,_lineftrap.w	/*  LineF Error zurueck */
		swap	d1
		move.l	d1,(a0)+

/*  .28 */
/*  im _MCH cookie wird jetzt TT eingetragen. */

		moveq	#6,d0                   /*  scsi und vme immer */
		move.l	#$5F4D4348,(a0)+	/* '_MCH' */
		move.l	#$20000,(a0)+		/*  machine type auf TT */

/*  Test auf Atari DMA */
		move.l	a7,a2
		move.l	_buserror.w,a1
		move.l	#no_atari_dma,_buserror.w      /* buserrorvector setzen */
		moveq	#6,d0                   /* vme und scsi immer */
		tst.w	DMA_DATA
		bset	#3,d0			/*  merken */
no_atari_dma:
		move.l	a2,a7
		move.l	a1,_buserror.w

/*  .24 .25 .30 */
/*  *** Der 'id'-Cookie: */
/*  Hier kann man nun die im Hades vorhandene Zusatzhardware */
/*  abfragen bzw. eintragen. */
/*  16 Bits duerften erst einmal eine Weile reichen */

/* Bit 0..15:  im Hades gefundene Hardware */
/* 	     (ist das jeweilige Bit Null ist diese Hardware nicht vorhanden). */
/*  Bit	0	ROM-Port */
/*  Bit	1	VME-Bus */
/*  Bit	2	SCSI-Karte */
/*  Bit   3       Atari DMA */
/*  Bit 3-11	reserviert */
/*  Bit 12-15	reserviert fuer Video Hardware */
/* 		Bit 12 = ET4000 am ISA Bus */
/* 		Bit 13 = Videokarte am VME Bus */
/* 		Bit 14 = PCI-Bus Graphikkarte */
/*  Bit 16-31     Maschinenversion (derzeit 0) */

		move.l	#hadesid,(a0)+
	    move.l	_v_bas_ad.w,d1	/*  adresse bildspeicher */
	    cmpi.l	#pci_base,d1	/* pci */
	    bcc.s	nopcigk			/* nein-> */
		bset	#14,d0			/* pci grafikkarte eintragen */
		bra.s	gkset
nopcigk:
		cmpi.l	#$ff000000,d1	/* vme? */
		bcc.s	novmegk         /* nein-> */
		bset	#13,d0          /* set vme grafikkarte */
		bra.s	gkset
novmegk:
		bset	#12,d0			/* sonst isa bus grafikkarte eintragen */
gkset:
		move.l	d0,(a0)+		/* Hade setzen */

		move.l	#$5F534E44,(a0)+	/* '_SND' */

/*  _SND Cookie. normaler st sound eintragen */
		moveq	#1,d0			/*  d0 initialisieren (kein DMA Sound) */
		move.l	d0,(a0)+

		move.b	#8,dsb.w		/* select HD density for drive A */
		move.l	#$5F464443,(a0)+	/* '_FDC' */

/*  .24 */
/*  als Benutzerkennung wird im _FDC jetzt 'id' eingetragen... */
/*  (Ordnung muss sein .-))) */
/* THO: not quite right. Highest byte should be max. density allowed */

		move.l	#hadesid,(a0)+	/* hades floppy */

/*  .23 .24 .25 */
/*  fuer MultiTOS Anwender tragen wir auch gleich noch den _AKP und */
/*  _IDT cookie ein, das spart schon wieder ein Autoordnerprogramm */

		move.l	#$5F414B50,(a0)+	/* '_AKP' */
		move.l	_sysbase.w,a2		/* sysbase nach a0 */
		move.l	8(a2),a2
		move.w	28(a2),d0		/* laenderkennung */
		asr.w	#1,d0			/* Syncmode ausblenden */
		move.w	d0,d1			/* merken */
		asl.w	#8,d1			/* in High-Bit */
		or.w	d1,d0			/* und einkopieren */
		move.l	d0,(a0)+

/*  .23 .24 .25 */
**** Der "_IDT"-Cookie:
/* Bit 0..7:   Trennzeichen fuer Datumsangaben */
/* 	     (Null steht als Default fuer '/'). */
/* Bit 8..11:  Datumsformat, */
/* 	     (0: MM-TT-JJ, 1: TT-MM-JJ, */
/* 	      2: JJ-MM-TT, 3: JJ-TT-MM.) */
/* Bit 12..15: Zeitformat */
/* 	     (0: am/pm, 1: 24 Stunden) */
/* Bit 16..31: reserviert */

	      move.l	#$5F494454,(a0)+	/* '_IDT' */
	      moveq		#0,d1
	      cmpi.b	#CTRY_DE,d0		/* FRG */
	      beq.s		isger
	      cmpi.b	#CTRY_SG,d0		/* SWG */
	      bne.s		noswg
isger:
	      move.w	#$112e,d1
	      bra.s		instidt
noswg:
	      cmpi.b	#CTRY_UK,d0		/* UK */
#if BINEXACT
	      bne.s		instidt
#else
/* THO: BUG: this is missing */
	      beq.s		iseng
	      cmpi.b	#CTRY_US,d0		/* USA */
	      bne.s		instidt
#endif
iseng:
	      move.w	#$1000,d1
instidt:
	      move.l	d1,(a0)+	/* und eintragen */
	      jmp		cook_wei	/* weiter in der normalen cookie installation */


***********************************************************************************************
/* fa 1.1.96:pseudo dma fuer scsi */
/*  a0=basis adresse register */
/*  a1=dma adresse */
/*  a2=alter stackwert/adresse letztes zu uebertragendes long (restdaten!!) */
/*  a3=sprungadresse/write back 3 adresse */
/*  a4=endadresse */
/*  d0=divers */
/*  d1=anzahl byts resp. restbyts des letzten sectors -1 */
/*  d2=dma start adresse */
/*  d3=dtt0 alt */
/*  d4=10000-anzahl buserrors */
/*  d5=anzahl sectoren-1 */

	xdef int_scsi
int_scsi:
		movem.l d0-d7/a0-a4,-(sp)
		move.b  auu.w,d2
		lsl.l	#8,d2
		move.b  amu.w,d2
		lsl.l   #8,d2
		move.b  aml.w,d2
		lsl.l   #8,d2
		move.b  all.w,d2
		move.b  cuu.w,d1
		lsl.l	#8,d1
		move.b  cmu.w,d1
		lsl.l   #8,d1
		move.b  cml.w,d1
		lsl.l	#8,d1
		move.b  cll.w,d1
/* 		tst.l	d1 */
/* 		beq	scsiendx */
		move.l	_buserror.w,-(sp)		/* alter buserrorvector sichern */
		bclr	#1,dma_sctr1.w		/* dma off -> int 2 off */
        and.b	#$fc,dma_sctr2.w		/* eop, bus error off */
		move.l  #scsibuserror,_buserror.w 	/* neuen setzen */
		DTT0_Dn(3)			/* dtt0 nach d3 */
		ITT0_Dn(6)       /* itt0 nach d6 */
		CACR_D7          /* cacr nach d7 */
		move.l	#$7fc020,d0		/* ram und eprom copy back */
		D0_DTT0					/* copy back setzen */
		D0_ITT0
		move.l	#$A0808000,d0
		D0_CACR              	/* cache on */
		CPUSHA_BC
		nop
		move.w  #$2400,sr
		move.l	a7,a2			/* alter stack */
		move.w	#10000,d4		/* 10000 versuche = ca. 40ms (1 buserror ist 4us(=min. transferrate=250kb/sec)) -> min. 1500U/min */
		lea	psdm.w,a0
		move.l  d2,a1           	/* dma adresse */
		move.l	d2,a4			/* startadresse */
		add.l	d1,a4			/* +laenge=endadresse */
scsijmp:
		subq.l	#1,d1
		move.l	d1,d5			/* anzahl byts-1 */
		lsr.l	#8,d5                   /* /512 */
		lsr.l	#1,d5			/* =anzahl ganze sectoren */
		andi.l  #$1ff,d1		/* anzahl byts -1 im naechsten sector */
		lea     scsiwrlb,a3		/* sonst tabelle read nach a3 */
		btst	#0,dma_sctr1.w              /* write? */
		bne.s	scsibs			/* ja-> */
		lea     scsirdlb,a3		/* sonst tabelle read nach a3 */
scsibs:
		sub.l   d1,a3			/* x2 weil jeder befehl wordlaenge hat */
		sub.l	d1,a3			/* - = aktuelle einsprungadresse */
		jmp	(a3)			/* verzweigen */
scsiwrloop:
		/* REPT 511 */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
        move.b  (a1)+,(a0)      /* byt verschieben */
scsiwrlb:
		subq.l  #1,d5
		bmi.s	scsiwrdone
        move.b  (a1)+,(a0)      /* byt verschieben */
		bra     scsiwrloop   /* wiederholen bis fertig */
scsiwrdone:
		bset	#0,dma_sctr2.w	/* sonst count0/eop on */
		move.b	(a1)+,(a0)	/* dummy byt nachschieben */
		bra	scsiweiter
scsirdloop:
		/* REPT 511 */
        move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
		move.b  (a0),(a1)+		/* byt verschieben */
scsirdlb:
		subq.l  #1,d5
		bmi.s 	scsirddone
		move.b  (a0),(a1)+		/* byt verschieben */
		bra		scsirdloop		/* wiederholen bis fertig */
scsirddone:
		bset	#0,dma_sctr2.w		/* count0 on */
		move.b	(a0),(a1)+		/* dummy byt nachschieben */
		move.l  a1,d2
		andi.b	#$fc,d2			/* letztes long */
		move.l  d2,a0
		move.l  (a0),residue.w	/* restdaten nach register */
scsiweiter:
		moveq	#0,d1			/* fertig */
scsiend:
        bset	#1,dma_sctr1.w		/* dma on = ein int 7 scharf */
        Dn_DTT0(3)				/* dtt0 zurueck */
		Dn_ITT0(6)				/* itt0 zurueck */
		D7_CACR					/* cacr zurueck */
		CPUSHA_BC
		nop
		move.b  d1,cll.w 		/* byt zaehler zurueck */
        lsr.l	#8,d1
        move.b  d1,cml.w
        lsr.l	#8,d1
        move.b  d1,cmu.w
        lsr.l   #8,d1
        move.b  d1,cuu.w
        move.l  a1,d1			/* neue dma adresse */
		move.b  d1,all.w
		lsr.l	#8,d1
		move.b  d1,aml.w
		lsr.l   #8,d1
		move.b  d1,amu.w
		lsr.l   #8,d1
		move.b  d1,auu.w
		move.l  (sp)+,_buserror.w		/* alter buserrorvector wieder herstellen */
		movem.l (sp)+,d0-d7/a0-a4
		rte
/* ----------------------------------------------- scsi buserror */
scsibuserror:
		cmp.w	#40,_longframe.w		/* mc68040? */
		bne.s	scsibuer60              /* nein-> mc68060 */
		btst	#0,dma_sctr1.w		/* read? */
		beq.s	scbueread40		/* ja-> */
		move.b	15(a7),d0		/* wb3s? */
		bpl.s   scb2			/* nein */
        cmp.l	24(a7),a0		/* scsiadresse */
        bne.s	scb2x			/* nein */
		subq.l	#1,a1			/* -1 wegen prefecht (a1)+,(a0) */
scb2:
		tst.b	17(a7)			/* wb2s? */
		bpl.s   scb1			/* nein */
        cmp.l	32(a7),a0		/* scsiadresse */
        bne.s	scb1x			/* nein-> */
		subq.l	#1,a1			/* -1 wegen prefecht (a1)+,(a0) */
scb1:
		tst.b	19(a7)			/* wb1s? */
		bpl.s   scbuer40w		/* nein-> */
		cmp.l	40(a7),a0       /* scsiadresse */
		bne.s	scbuer40w		/* nein-> */
		subq.l	#1,a1			/* -1 wegen prefecht (a1)+,(a0) */
		bra.s	scbuer40w
scbueread40:
		move.b	15(a7),d0		/* wb3s */
		bpl.s	scbuer40w       /* nein-> */
		move.l	24(a7),a3		/* adresse */
		move.l	28(a7),d1		/* daten */
        bsr.s	savewb
scbuer40w:
		cmp.l	20(a7),a0		/* scsidaten bereich? */
		beq.s	scsitimeout	     	/* ja -> timout */
scsibuerer:
		bset	#1,dma_sctr1.w		/* dma on = ein, int 7 scharf */
        move.l	a2,a7           /* alter stack */
        Dn_DTT0(3)				/* dtt0 zurueck */
        Dn_ITT0(6)				/* itt0 zurueck */
        D7_CACR					/* cacr zurueck */
        CPUSHA_BC
        nop
		ori.b	#$03,dma_sctr2.w  		/* buserror- und eop-bit setzen */
		move.l  (sp)+,_buserror.w		/* alter buserrorvector wieder herstellen */
		movem.l (sp)+,d0-d7/a0-a4
		rte
scsibuer60:
		cmp.l   8(a7),a0		/* scsidaten bereich? */
        bne.s	scsibuerer              /* nein-> bus error */
scsitimeout:
	    move.l	a2,a7			/* alter stack */
		move.l	a4,d1			/* enadresse */
		sub.l	a1,d1			/* -aktelle adresse=restbyt */
		subq.w	#1,d4			/* -1 versuch */
		bpl	scsijmp			/* abgelaufen? nein->wiedereinstieg */
		bra	scsiend
scb2x:
		move.l	24(a7),a3
		move.l	28(a7),d1
		bsr.s	savewb
		bra.w	scb2
scb1x:
		move.l	32(a7),a3
		move.l	36(a7),d1
		bsr.s	savewb
		bra	scb1
/* ------------------------------------------------------------------------------------------------------------------- */
savewb:
		move.l	#savewbber,_buserror.w		/* neuer buserrorvector */
		andi.b	#$60,d0			/* relevante bits */
		bne.s	nolong                  /* ist nicht long-> */
		move.l	d1,(a3)                 /* sonst long schreiben */
		nop
		rts
nolong:
		cmpi.b	#$20,d0			/* byt? */
		beq.s	ibyt                    /* ja-> */
nolong2:
		move.w	d1,(a3)                 /* sonst word speichern */
		nop
		rts
ibyt:
		move.b	d1,(a3)                 /* byt speichern */
		nop
		rts
savewbber:
		move.l	#scsibuserror,_buserror.w
		rte
********************************************************************************************************************

/* include the FPSP060 */

#include "fpsp060/skel060.S"

**********************************************************************************************
/*  .22 */
/* neue exception routine fuer mehr Information */
	xdef hades_exception
hades_exception:
	    move.l	2(SP),_proc_enum.w /* pc merken */
		movem.l d0-d7/a0-a7,_proc_dregs.w /* die Register merken */
		move	usp,a0
		move.l	a0,_proc_usp.w	/* den USP merken */
		move.l	SP,a1
		moveq	#0,d1
		move.w	6(SP),d1	/* formatword holen */
		andi.w	#$0FFF,d1	/* format weg=offset */
		asr.w	#2,d1		/* /4 ergibt vector */
exception4:
		lea	(SUPSIZ*2+_supstk).w,SP /* den Stack initialisieren */
		moveq	#15,d0
		lea	_proc_stk.w,a0
exception2:
		move.w	(a1)+,(a0)+	/* 16 Worte vom SSP merken */
		dbra	d0,exception2
		move.l	#$12345678,_proc_lives.w /* Daten fuer gueltig erklaeren */

bombs:
		lea	tb1(pc),a0	/* zeiger auf starttext */
		bsr	string_out	/* ausgeben */
		cmpi.w	#56,d1		/* vector =56? (MMU configuration error) */
		blt.s	bomb_fa4	/* nein kleiner-> */
		lea	tbuv(pc),a0	/* zeiger auf text */
		bsr	string_out	/* text ausgeben */
		move.w	d1,d2		/* vector nummer nach d2 */
		move.w  d1,d7		/* vector nummer nach d7 */
		ror.l	#8,d2		/* an richtige stelle bringen */
		moveq	#1,d0		/* 2 Stellen */
		bsr	reg_aus1	/* ausgeben */
		bra.s	bomb_fa5
bomb_fa4:
		lea	tbev(pc),a0	/* zeiger auf exception text */
		subq.w	#1,d1		/* mit bus error beginnen */
bomb_fa1:
		subq.w	#1,d1
		beq.s	bomb_fa2	/* ok->weg */
bomb_fa3:
		move.b	(a0)+,d6	/* naechstes zeichen */
		beq.s	bomb_fa1	/* ende zeichenkette-> */
		bra.s	bomb_fa3	/* nein next */
bomb_fa2:
		bsr	string_out	/* text ausgeben */
bomb_fa5:
		lea	tb2(pc),a0	/* zeiger auf text */
		bsr	string_out	/* text ausgeben PC= */
		move.l	_proc_enum.w,d2	/* pc wert holen */
		bsr	reg_aus 	/* ausgeben */
		bsr	string_out	/* sr= */
		move.w	_proc_stk.w,d2	/* sr holen */
		swap	d2		/* an richtige position bringen */
		moveq	#3,d0		/* nur 4 stellen */
		bsr	reg_aus1	/* ausgeben */
		bsr	string_out	/* usp= */
		move.l	_proc_usp.w,d2	/* usp wert holen */
		bsr	reg_aus 	/* und ausgeben */
		bsr	string_out	/* formatword= */
		move.w	(_proc_stk+6).w,d2 /* formatword holen */
		swap	d2		/* an richtige position bringen */
		moveq	#3,d0		/* nur 4 stellen */
		bsr	reg_aus1	/* und ausgeben */
		bsr	string_out	/* (PC-4)= */
		move.l	_buserror.w,a4		/* buserrorvektor sichern */
		move.l	#bomb_fa6,_buserror.w	/* buserrorvektor setzen */
		move.l	sp,a5		/* stack sichern */
		move.l	_proc_enum.w,a6	/* pc laden */
		move.l	-4(a6),d2	/* werte vor pc stand */
		bsr.s	reg_aus
		move.l	(a6),d2 	/* werte bei pc stand */
		bsr.s	reg_aus
bomb_fa6:
		move.l	a4,_buserror.w		/* alter buserrorvektor */
		move.l	a5,sp		/* alter stack */
		lea	tb3(pc),a0	/* zeiger auf text */
		lea	_proc_dregs.w,a1	/* zeiger auf registerwerte */
		moveq	#2,d4		/* daten,adressregister und stack */
bomb_fa8:
		bsr.s	string_out	/* text ausgeben */
		moveq	#7,d3		/* 8 register */
bomb_fa7:
		move.l	(a1)+,d2	/* wert holen */
		bsr.s	reg_aus 	/* und ausgeben */
		dbra	d3,bomb_fa7
		subq.l	#1,d4		/* -1 */
		bgt.s	bomb_fa8	/* >0 wiederholen */
		lea	_proc_stk.w,a1	/* zeiger auf stackwert */
		beq.s	bomb_fa8	/* =0->wiederholen */
		lea	tb4(pc),a0	/* zeiger auf text */
		bsr.s	string_out	/* text ausgeben */
		move	#$2100,SR	/* Interrupts erlauben */
		move.w	#2,-(SP)	/* tastatur */
		move.w	#2,-(SP)
		trap	#13		/* auf tastendruck warten */
		addq.l	#4,SP		/* stack korrigieren */
		cmpi.w  #140,d7		/* vector number = 140? */
		beq.s   exitcont
exitcrash:
		move.l	#_trap_save_area,_savptr.w	/* BIOS-Stackpointer zuruecksetzen */
		move.l	#$4CFFFF,-(SP)
		trap	#1		/* Pterm(-1) versuchen */
		jmp	coldboot	/* RESET, wenn misslungen */
exitcont:
		movea.l    (_proc_usp).w,a0
		move.l     a0,usp
		movem.l    (_proc_dregs).w,d0-d7/a0-a7
		rte
		
reg_aus:
		moveq	#7,d0
reg_aus1:
		rol.l	#4,d2		/* next hex zahl */
		move.b	d2,d6
		andi.b	#15,d6 		/* nur 4 bits werden gebraucht */
		addi.b	#'0',d6 	/* + ascii 0 */
		cmpi.b	#'9',d6 	/* <=9? */
		ble.s	reg_aus2	/* ja,ok-> */
		addi.b	#'A'-'9'-1,d6	/* sonst differenz zuaddieren */
reg_aus2:
		bsr.s	zei_out 	/* ausgeben */
		dbra	d0,reg_aus1	/* wiederholen bis fertig */
		moveq	#32,d6
		bra.s	zei_out 	/* ein leerschlag */

string_out:
		move.b	(a0)+,d6	/* zeichen holen */
		bne.s	str_out1	/* fertig? nein-> */
		rts			/* zurueck */
str_out1:
		bsr.s	zei_out 	/* zeichen out */
		bra.s	string_out	/* und von vorn */

zei_out:
		movem.l d0-d4/a0-a1,-(SP) /* register sichern */
		andi.w	#255,d6 	/* nur bytwert */
		move.w	d6,-(SP)	/* zeichen */
		move.w	#2,-(SP)	/* bildschirm */
		move.w	#3,-(SP)
		trap	#13		/* zeichen ausgeben */
		addq.l	#6,SP
		movem.l (SP)+,d0-d4/a0-a1 /* register zurueck */
		rts

/*  .24 .28 */
/*  ... und die Texte des Handlers auch gleich noch ein wenig aufgeraeumt ... */
/*  .29 */
/*  ausserdem sind auch noch die 68060 exeptions dabei. */


/* THO: FIXME: needs translation */
tb1:		dc.b 27,'H',10,10,10,10,10,10,27,'p',27,'KException ausgel',$94,'st durch: ',0
tb2:		dc.b 10,13,27,'K',10,13,27,'KPC=',0,' SR=',0,' USP=',0,' Formatword=',0,' (PC-4)=',0
tb3:		dc.b 10,13,27,'KD0-D7=',0,10,13,27,'KA0-A7=',0,10,13,27,'KStack=',0
tb4:		dc.b 10,13,27,'K',10,13,27,'K < weiter mit beliebiger Taste >',27,'q',0
tbuv:		dc.b 'Vector nummer $',0
tbev:		dc.b 'Access fault (Bus Error) !',0
		dc.b 'Adress error !',0
		dc.b 'Illegal instruction !',0
		dc.b 'Integer divide by zero !',0
		dc.b 'CHK, CHK2 instruction !',0
		dc.b 'FTRAPcc, TRAPcc, TRAPV instruction !',0
		dc.b 'Privileg violation !',0
		dc.b 'Trace !',0
		dc.b 'Line A Emulator !',0
		dc.b 'Line F Emulator !',0
		dc.b 'Unassigned, reserved !',0
		dc.b 'Coprocessor protocol violation !',0
		dc.b 'Format error !',0
		dc.b 'Uninitialized interrupt !',0
		dc.b 'Unassigned, reserved !',0
		dc.b 'Unassigned, reserved !',0
		dc.b 'Unassigned, reserved !',0
		dc.b 'Unassigned, reserved !',0
		dc.b 'Unassigned, reserved !',0
		dc.b 'Unassigned, reserved !',0
		dc.b 'Unassigned, reserved !',0
		dc.b 'Unassigned, reserved !',0
		dc.b 'Spurious interrupt !',0
		dc.b 'Level 1 interrupt autovektor !',0
		dc.b 'Level 2 interrupt autovektor !',0
		dc.b 'Level 3 interrupt autovektor !',0
		dc.b 'Level 4 interrupt autovektor !',0
		dc.b 'Level 5 interrupt autovektor !',0
		dc.b 'Level 6 interrupt autovektor !',0
		dc.b 'Level 7 interrupt autovektor !',0
		dc.b 'Trap #0 instruction vector !',0
		dc.b 'Trap #1 instruction vector !',0
		dc.b 'Trap #2 instruction vector !',0
		dc.b 'Trap #3 instruction vector !',0
		dc.b 'Trap #4 instruction vector !',0
		dc.b 'Trap #5 instruction vector !',0
		dc.b 'Trap #6 instruction vector !',0
		dc.b 'Trap #7 instruction vector !',0
		dc.b 'Trap #8 instruction vector !',0
		dc.b 'Trap #9 instruction vector !',0
		dc.b 'Trap #10 instruction vector !',0
		dc.b 'Trap #11 instruction vector !',0
		dc.b 'Trap #12 instruction vector !',0
		dc.b 'Trap #13 instruction vector !',0
		dc.b 'Trap #14 instruction vector !',0
		dc.b 'Trap #15 instruction vector !',0
		dc.b 'FPCP Branch or Set on unordered condition !',0
		dc.b 'FPCP inexact result !',0
		dc.b 'FPCP divide by zero !',0
		dc.b 'FPCP underflow !',0
		dc.b 'FPCP operand error !',0
		dc.b 'FPCP overflow !',0
		dc.b 'FPCP signaling NAN !',0
		dc.b 'FPCP unimplemented data type !',0
		dc.b '68030/68851 PMMU configuration error !',0
		dc.b 'Unassigned, reserved for 68851 !',0
		dc.b 'Unassigned, reserved for 68851 !',0
		dc.b 'Unassigned, reserved !',0
		dc.b 'Addressing mode unimplemented in 68060 !',0
		dc.b 'Integer instruction unimplemented in 68060 !',0
		dc.b 'Unassigned, reserved !',0
		dc.b 'Unassigned, reserved !',0

		even

/*
 * Actually 0x4758, but we read it as little-endian value
 */
/* mach64GX (ATI888GX00) */
#define PCI_MACH64_GX_ID	$5847

/* grafik karte initialisieren */
		xdef screen_init
screen_init:
		lea		pci_conf1,a3
		cmp.b   #$32,3(a3)
		beq		config
		lea		pci_conf2,a3
		cmp.b	#$32,3(a3)
		beq		config
		lea		pci_conf3,a3
		cmp.b	#$32,3(a3)
		beq.s	config
		lea		pci_conf4,a3
		cmp.b	#$32,3(a3)
		beq.s	config

pcim64t:
		cmp.w	#PCI_MACH64_GX_ID,pci_conf1+2
		beq.s	m64init
		cmp.w	#PCI_MACH64_GX_ID,pci_conf2+2
		beq.s	m64init
		cmp.w	#PCI_MACH64_GX_ID,pci_conf3+2
		beq.s	m64init
		cmp.w	#PCI_MACH64_GX_ID,pci_conf4+2
		bne		isainit

m64init:
        lea	mach64_pci_init,a0         /* source emulator.bin mach64 pci */
m64init2:
		lea	mach64_org,a1              /* dest (uebersetzt mit org $300000) */
		move.l	a1,a2
		move.w	#430,d0                /* laenge(6824)/16 */
m64copy:
		move.l	(a0)+,(a1)+            /* copieren */
		move.l	(a0)+,(a1)+
		move.l  (a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbf	d0,m64copy             /* wiederholen bis fertig */
		move.l  a6,-(a7)		   /* push return address from caller */
		jmp	(a2)                   /* einsprung */

et6000tab:
		dc.b $00,$51,$64
		dc.b $01,$69,$64
		dc.b $02,$7d,$63
		dc.b $03,$6a,$44
		dc.b $04,$56,$25
		dc.b $05,$56,$24
		dc.b $06,$52,$23
		dc.b $07,$5d,$23
		dc.b $0a,$4c,$25
		even

/* pci et4000 grafikkarte initialisieren */
config:
		move.b	#3,4(a3)		/* io und mem on */
		lea		pci_vga_reg,a2
		cmp.b	#8,2(a3)                /* et6000? */
		bne		no_et6000		/* nein-> */
		move.b	#3,$40(a3)              /* et6000 init */
		move.b  #$78,$41(a3)
		clr.b   $42(a3)
		move.b  #$02,$43(a3)
		moveq.l #8,d0
		lea.l   et6000tab(pc),a1
et6000_1:
		move.b  (a1)+,$68(a3)
		move.b  (a1)+,$69(a3)
		move.b  (a1)+,$69(a3)
		dbf     d0,et6000_1
		move.b  #$65,$45(a3)
		nop
		nop
		tst.b   $803FFF00
		nop
		nop
		tst.b   $803FFF80
		nop
		nop
		move.b  #$75,$45(a3)
		nop
		nop
		cmpi.b  #$60,8(a3)
		blt.s   et6000_2
		tst.b   $80000000
		nop
		nop
		tst.b   $80000080
		nop
		nop
		move.b  #$14,$44(a3)
		bra.s   et6000_3
et6000_2:
		tst.b   $80000200
		nop
		nop
		tst.b   $80000280
		nop
		nop
		move.b	#$15,$44(a3)		/* et6000 init */
et6000_3:
		move.b  #$05,$45(a3)
		move.b  #$40,$46(a3)
		move.b  #$07,$47(a3)
		move.b  #$03,$4e(a3)
		move.b  #$02,$58(a3)

no_et6000:
		move.b	#$27,$03C2(a2)		/* misc */
		move.b	#1,$03C3(a2)		/* videosub */
		move.b	#$17,$03D4(a2)
		clr.b	$03D5(a2)			/* color */
		move.b	#$11,$03D4(a2)		/* color */
		clr.b	$03D5(a2)
		move.b  #$ff,$3c6(a2)       /* pel mask */
		clr.b	$03C4(a2)			/* ts */
		clr.b	$03C5(a2)
		move.b	#3,$03BF(a2)
		move.b	#$a0,$03D8(a2)

		lea		$03C4(a2),a0
		lea		ts+1,a1
		cmp.b	#8,2(a3)			/* et6000? */
		bne.s   iset1               /* nein-> */
		lea		ts6+1,a1
iset1:
		moveq	#1,d1
		moveq	#8,d0
/* ts registersatz transferieren */
loop_ts:
		move.b	d1,(a0)
		move.b	(a1)+,1(a0)
		addq.w	#1,d1
		cmp.w	d1,d0
		bne.s	loop_ts
		clr.b	(a0)
		move.b	ts,1(a0)		/* fa_8.11.94: */

		lea     $03c6(a2),a0    /* pel mask */
		move.b  (a0),d0
		move.b  (a0),d0
		move.b  (a0),d0
		move.b  (a0),d0
		moveq	#0,d0
		cmp.b	#8,2(a3)		/* et6000? */
		bne.s	iset2           /* nein-> */
		moveq	#-1,d0
iset2:
        move.b	d0,(a0)         /* pel mask */

		lea	$03D4(a2),a0
		lea	crtc,a1
		moveq	#0,d1
		moveq	#$3e,d0
/* crtc registersatz transferieren */
loop_crtc:
		move.b	d1,(a0)
		move.b	(a1)+,1(a0)
		addq.w	#1,d1
		cmp.w	d1,d0
		bne.s	loop_crtc
		lea		$03CE(a2),a0
		lea		gdc,a1
		moveq	#0,d1
		moveq	#9,d0
/* gdc registersatz transferieren */
loop_gdc:
		move.b	d1,(a0)
		move.b	(a1)+,1(a0)
		addq.w	#1,d1
		cmp.w	d1,d0
		bne.s	loop_gdc
		move.b	$03DA(a2),d0
		lea		$03C0(a2),a0
		lea		atc,a1
		moveq	#0,d1
		moveq	#$18,d0
/* atc registersatz transferieren */
loop_atc:
		move.b	d1,(a0)
		move.b	(a1)+,(a0)
		addq.w	#1,d1
		cmp.w	d1,d0
		bne.s	loop_atc
		move.b	#$20,(a0)
		lea		$03C8(a2),a0
		moveq	#0,d1
		move.w	#$0100,d0
		move.b	d1,(a0)
		move.b	#$FF,1(a0)
		move.b	#$FF,1(a0)
		move.b	#$FF,1(a0)
		addq.w	#1,d1
/* farbregister auf monochrom */
loop_dac:
		move.b	d1,(a0)
		clr.b	1(a0)
		clr.b	1(a0)
		clr.b	1(a0)
		addq.w	#1,d1
		cmp.w	d0,d1
		bne.s	loop_dac
		lea		pci_vga_base,a0
		jmp		(a6)			/* back to caller */

/* Attribute Controller: registers 0 - 0x17 */
atc:	dc.b $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
		dc.b $01,$00,$0F,$00,$00,$00,$00,$00
/* CRT Controller: registers 0 - 0x3d */
crtc:	dc.b $60,$4F,$4F,$84,$56,$86,$c1,$1F,$00,$40,$00,$00,$00,$00,$07,$30
		dc.b $98,$00,$8F,$28,$40,$8F,$C2,$a3,$FF,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$80,$28,$00,$00,$00,$13,$09,$00,$00,$00,$00,$00,$00,$00,$00
gdc:	dc.b $00,$00,$00,$00,$00,$00,$01,$0F,$FF

/* MISC_W + Timing Sequencer registers 1...6 */
ts:		dc.b $03
		dc.b $01,$0F,$00,$06,$00,$00,$B4
ts6:	dc.b $03
		dc.b $05,$0F,$00,$06,$00,$00,$B4
		even

/* isa et4000 grafikkarte initialisieren */
isainit:
		lea		mach64_isa_init,a0		/* source emulator.bin mach64 isa */
		cmp.b   #$ff,$fff103c0      /* mach64? */
		beq		m64init2            /* ja-> */
		lea		isa_vga_reg,a2
		move.b	#$07,$03C2(a2)		/* misc */
		move.b	#1,$03C3(a2)		/* videosub */
		move.b	#$17,$03B4(a2)		/* crtc mode control */
		clr.b	$03B5(a2)			/* mono */
		move.b	#$17,$03D4(a2)
		clr.b	$03D5(a2)			/* color */
		move.b	#$11,$03B4(a2)		/* vertical start */
		clr.b	$03B5(a2)
		move.b	#$11,$03D4(a2)		/* color */
		clr.b	$03D5(a2)
		move.b  #$FF,$03C6(a2)		/* pel mask */
		clr.b	$03C4(a2)			/* ts */
		clr.b	$03C5(a2)
		move.b	#3,$03BF(a2)
		move.b	#$a0,$03D8(a2)

		lea		$03C4(a2),a0
		lea		isats+1,a1
		moveq	#1,d1
		moveq	#$07,d0
/* ts registersatz transferieren */
isaloop_ts:
		move.b	d1,(a0)
		move.b	(a1)+,1(a0)
		addq.w	#1,d1
		cmp.w	d1,d0
		bne.s	isaloop_ts
		clr.b	(a0)
		move.b	isats,1(a0)		 /* fa_8.11.94: */

		lea     $03c6(a2),a0             /* pel mask */
		move.b  (a0),d0
		move.b  (a0),d0
		move.b  (a0),d0
		move.b  (a0),d0
		move.b  #0,(a0)

		lea	$03D4(a2),a0
		lea	isacrtc,a1
		moveq	#0,d1
		moveq	#$38,d0
/* crtc registersatz transferieren */
isaloop_crtc:
		move.b	d1,(a0)
		move.b	(a1)+,1(a0)
		addq.w	#1,d1
		cmp.w	d1,d0
		bne.s	isaloop_crtc
		lea	$03CE(a2),a0
		lea	isagdc,a1
		moveq	#0,d1
		moveq	#10,d0
/* gdc registersatz transferieren */
isaloop_gdc:
		move.b	d1,(a0)
		move.b	(a1)+,1(a0)
		addq.w	#1,d1
		cmp.w	d1,d0
		bne.s	isaloop_gdc
		move.b	$03DA(a2),d0
		lea	$03C0(a2),a0
		lea	isaatc,a1
		moveq	#0,d1
		moveq	#$18,d0
/* atc registersatz transferieren */
isaloop_atc:
		move.b	d1,(a0)
		move.b	(a1)+,(a0)
		addq.w	#1,d1
		cmp.w	d1,d0
		bne.s	isaloop_atc
		move.b	#$20,(a0)
		lea	$03C8(a2),a0
		moveq	#0,d1
		move.w	#$0100,d0
		move.b	d1,(a0)
		move.b	#$FF,1(a0)
		move.b	#$FF,1(a0)
		move.b	#$FF,1(a0)
		addq.w	#1,d1
/* farbregister auf monochrom */
isaloop_dac:
		move.b	d1,(a0)
		clr.b	1(a0)
		clr.b	1(a0)
		clr.b	1(a0)
		addq.w	#1,d1
		cmp.w	d0,d1
		bne.s	isaloop_dac
		lea	isa_vga_base,a0
		jmp		(a6)			/* back to caller */

isaatc:
		dc.b $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
		dc.b $01,$FF,$0F,$00,$00,$00,$00,$00
isacrtc:
		dc.b $6A,$4F,$4F,$8E,$59,$87,$BF,$1F,$00,$40,$00,$00,$00,$00,$00,$00
		dc.b $9A,$04,$8F,$28,$00,$8F,$C0,$C3,$FF,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$10,$70,$0F
isagdc:
		dc.b $00,$00,$00,$00,$00,$00,$01,$0F,$FF,0
isats:
		dc.b $03,$09,$0F,$00,$06,$00,$00,$A4
		even

	xdef check_hardware
check_hardware:
		clr.l      d5
		moveq.l    #90,d0
		cmpi.l     #$00400000,d4
		bcc.s      check_hardware1
		moveq.l    #3,d5
		bra        check_hardware11
check_hardware1:
		move.l     #check_hardware2,(_buserror).w
		tst.b      ($FFFF8000).w
		nop
		bra.s      check_hardware3
check_hardware2:
		addi.w     #$30,d5
		bra        check_hardware11
check_hardware3:
		move.l     #check_hardware4,(_buserror).w
		move.b     d0,(MFP_IMRB).w
		nop
		tst.b      (MFP_GPIP).w
		nop
		cmp.b      (MFP_IMRB).w,d0
		beq.s      check_hardware5
		subi.w     #$200,d5
check_hardware4:
		addi.w     #$300,d5
check_hardware5:
		move.l     #check_hardware6,(_buserror).w
		move.b     d0,(MFP_IMRB+(TTMFP_REGS-MFP_REGS)).w /* IMRB of TTMFP */
		nop
		tst.b      (MFP_GPIP).w /* THO: BUG? should be GPIP of TTMFP */
		nop
		cmp.b      (MFP_IMRB+(TTMFP_REGS-MFP_REGS)).w,d0
		beq.s      check_hardware7
		subi.w     #$2000,d5
check_hardware6:
		addi.w     #$3000,d5
check_hardware7:
		move.l     #check_hardware8,(_buserror).w
		clr.b      (psgsel).w
		nop
		move.b     d0,(psgwr).w
		nop
		clr.b      (psgsel).w
		nop
		cmp.b      (psgrd).w,d0
		beq.s      check_hardware9
		subi.l     #$00020000,d5
check_hardware8:
		addi.l     #$00030000,d5
check_hardware9:
		move.l     #check_hardware10,(_buserror).w
		move.b     #13,NVRAM_ADDR_REG
		nop
		cmpi.b     #$80,NVRAM_DATA_REG
		beq.s      check_hardware11
		subi.l     #$00200000,d5
check_hardware10:
		addi.l     #$00300000,d5
check_hardware11:
		move.l     #$007FC000,d0
		D0_ITT0
		D0_DTT0
		move.l     #$80008000,d0
		D0_CACR

banksize equ $1fffe
numbanks equ 4
		move.l     #banksize,d7
		moveq.l    #numbanks-1,d6
		lea.l      _os_entry,a5
/*
 * calculate crc (same logic as in check_rom_crc)
 */
crccheck2:
		movea.l    a5,a0
		move.l     d7,d2
		clr.w      d0
		clr.w      d1
		clr.w      d3
		movea.l    rom_crc_addr+2,a2 /* fetch address of crc table from check_rom_crc function */
ckcrc2:
		move.w     d0,d1
		lsl.w      #8,d0
		lsr.w      #8,d1
		move.b     (a0),d3
		addq.l     #4,a0
		eor.b      d3,d1
		add.w      d1,d1
		move.w     0(a2,d1.w),d4
		eor.w      d4,d0
		subq.l     #1,d2
		bne.s      ckcrc2
/* crc done */
		movea.l    a5,a0
		adda.l     #banksize*numbanks,a0
		move.b     (a0),d1   /* high byte of CRC */
		lsl.w      #8,d1
		move.b     4(a0),d1  /* low byte of CRC */
		cmp.w      d1,d0
		beq.s      crcok
		move.l     d6,d0
		addi.l     #28,d0
		bset       d0,d5
crcok:
		dbf        d6,crccheck2
		move.l     #$007FC040,d0
		D0_ITT0
		D0_DTT0
		clr.l      d0
		D0_CACR
		CINVA_BC
		tst.l      d5
		bne.s      memconf_error
goback:
		jmp        (a6)		/* back to caller */

memconf_error:
		adda.w     #$34A4,a1
		moveq.l    #15,d0
#if hades_vidmo == 2
		moveq.l    #80,d2
#else
		move.l     #160,d2
#endif
memconf_error1:
		move.l     #$F0333333,(a1)
		adda.l     d2,a1
		dbf        d0,memconf_error1
		moveq.l    #31,d0
		adda.l     d2,a1
		adda.l     d2,a1
		adda.l     d2,a1
		adda.l     d2,a1
memconf_error2:
		move.l     d5,(a1)
		adda.l     d2,a1
		dbf        d0,memconf_error2
		move.w     #$0BB8,d0
memconf_error3:
		move.w     #$0BB8,d2
memconf_error4:
		move.l     #$87654321,d3
		divu.w     #$1234,d3
		dbf        d2,memconf_error4
		dbf        d0,memconf_error3
		lea.l      (SUPSIZ*2+_supstk).w,a7  /* reset supervisor stack */
		andi.l     #$0022FFFF,d5
		beq.s      goback
		stop       #$2700


		xdef pcicheck
pcicheck:
		lea.l      pci_base,a1
		move.l     #$00010000,d1
		moveq.l    #3,d6
		suba.l     a0,a0
pcicheck_1:
		cmpi.b     #$FF,0(a1,d1.l)
		beq.s      pcicheck_3
		move.l     #$0100000F,48(a1,d1.l)
		move.b     4(a1,d1.l),d7
		bset       #1,4(a1,d1.l)
		cmp.l      $8F000000,d0
		bne.s      pcicheck_2
		lea.l      pcicheck_2(pc),a5
		jmp        $8F000004
pcicheck_2:
		move.b     d7,4(a1,d1.l)
		clr.b      48(a1,d1.l)
pcicheck_3:
		lsl.l      #1,d1
		dbf        d6,pcicheck_1
		jmp        (a6)		/* back to caller */

/* hadesuk: 7FE59998 */
/* 376x135 pixel */
	  xdef medusalogo
medusalogo:
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$ff,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$ff,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$ff,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$ff,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$ff,$ff,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$ff,$ff,$ff,$fe,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$ff,$ff,$ff,$ff,$fc,$0f,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$ff,$ff,$ff,$ff,$f8,$1f,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$ff,$ff,$ff,$ff,$f8,$1f,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$ff,$ff,$ff,$ff,$f0,$3f,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$e0,$7f,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$ff,$ff,$ff,$c0,$ff,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$ff,$ff,$ff,$ff,$ff,$81,$ff,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$ff,$ff,$ff,$ff,$ff,$03,$ff,$fe,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$ff,$ff,$ff,$ff,$fe,$07,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$ff,$ff,$ff,$ff,$fc,$07,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$ff,$ff,$ff,$ff,$fc,$0f,$ff,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$ff,$ff,$ff,$f8,$1f,$ff,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$ff,$ff,$ff,$ff,$ff,$f0,$3f,$ff,$ff,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$ff,$ff,$ff,$ff,$ff,$e0,$7f,$ff,$ff,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$ff,$ff,$ff,$ff,$ff,$c0,$ff,$ff,$ff,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$ff,$ff,$ff,$ff,$ff,$81,$ff,$ff,$ff,$fe,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$ff,$ff,$ff,$ff,$ff,$01,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$7f,$ff,$ff,$ff,$03,$ff,$ff,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$3f,$ff,$ff,$fe,$07,$ff,$ff,$ff,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$ff,$fe,$3f,$ff,$ff,$fc,$0f,$ff,$ff,$ff,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$ff,$fc,$3f,$ff,$ff,$f8,$1f,$ff,$ff,$ff,$ff,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$ff,$fc,$3f,$ff,$ff,$f0,$3f,$ff,$ff,$ff,$ff,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$ff,$f8,$3f,$ff,$ff,$e0,$7f,$ff,$ff,$ff,$ff,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$ff,$f8,$3f,$ff,$ff,$c0,$7f,$ff,$ff,$ff,$ff,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$f0,$1f,$ff,$ff,$80,$ff,$ff,$ff,$ff,$ff,$fe,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$ff,$ff,$e0,$1f,$ff,$ff,$81,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$ff,$ff,$e0,$1f,$ff,$ff,$03,$ff,$ff,$ff,$ff,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$ff,$ff,$c0,$1f,$ff,$fe,$07,$ff,$ff,$ff,$ff,$ff,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$ff,$ff,$c0,$1f,$ff,$fc,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$80,$1f,$ff,$f0,$1f,$ff,$ff,$ff,$ff,$ff,$ff,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$ff,$80,$0f,$ff,$e0,$1f,$ff,$ff,$ff,$ff,$ff,$ff,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$ff,$ff,$ff,$00,$0f,$ff,$c0,$3f,$ff,$ff,$ff,$ff,$ff,$ff,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$ff,$ff,$fe,$00,$0f,$ff,$80,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$ff,$ff,$fe,$00,$0f,$ff,$80,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$fe,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$ff,$ff,$fc,$00,$0f,$ff,$01,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$ff,$ff,$fc,$00,$0f,$fe,$03,$ff,$ff,$ff,$fd,$ff,$ff,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$ff,$f8,$00,$07,$fc,$0f,$ff,$ff,$ff,$f8,$ff,$ff,$ff,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$ff,$ff,$ff,$f0,$00,$07,$f8,$0f,$ff,$ff,$ff,$f0,$3f,$ff,$ff,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$ff,$ff,$ff,$f0,$00,$07,$f0,$1f,$ff,$ff,$ff,$c0,$1f,$ff,$ff,$ff,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$ff,$ff,$ff,$e0,$00,$07,$e0,$3f,$ff,$ff,$ff,$80,$0f,$ff,$ff,$ff,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$ff,$ff,$ff,$e0,$00,$07,$c0,$7f,$ff,$ff,$ff,$00,$03,$ff,$ff,$ff,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$ff,$ff,$ff,$c0,$00,$07,$c0,$ff,$ff,$ff,$fe,$00,$01,$ff,$ff,$ff,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$80,$00,$03,$81,$ff,$ff,$ff,$f8,$00,$00,$ff,$ff,$ff,$fe,$00,$00,$00,$00,$00,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$ff,$ff,$80,$00,$03,$01,$ff,$ff,$ff,$f0,$00,$00,$7f,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$68,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$03,$ff,$ff,$ff,$ff,$00,$00,$02,$03,$ff,$ff,$ff,$e0,$00,$00,$1f,$ff,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$68,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$0f,$ff,$ff,$ff,$ff,$00,$00,$00,$07,$ff,$ff,$ff,$c0,$00,$00,$07,$ff,$ff,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,$68,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$1f,$ff,$ff,$ff,$fe,$00,$00,$00,$0f,$ff,$ff,$ff,$00,$00,$00,$03,$ff,$ff,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$68,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$3f,$ff,$ff,$ff,$fc,$00,$00,$00,$1f,$ff,$ff,$fe,$00,$00,$00,$00,$ff,$ff,$ff,$f0,$00,$00,$00,$00,$00,$00,$00,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$7f,$ff,$ff,$ff,$fc,$00,$00,$40,$3f,$ff,$ff,$fc,$00,$00,$00,$00,$7f,$ff,$ff,$f8,$00,$00,$00,$00,$00,$00,$00,$e8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$ff,$ff,$f8,$3f,$ff,$80,$7f,$ff,$ff,$f8,$00,$00,$00,$00,$3f,$ff,$ff,$fc,$00,$00,$00,$00,$00,$00,$00,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$03,$ff,$ff,$ff,$ff,$f8,$18,$8b,$00,$7f,$ff,$ff,$e0,$00,$00,$00,$00,$0f,$ff,$ff,$fc,$00,$00,$00,$00,$00,$00,$00,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$07,$ff,$ff,$ff,$ff,$f0,$10,$04,$00,$ff,$ff,$ff,$c0,$00,$00,$00,$00,$07,$ff,$ff,$fe,$00,$00,$00,$00,$00,$00,$01,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$0f,$ff,$ff,$ff,$ff,$e0,$32,$2c,$01,$ff,$ff,$ff,$80,$00,$00,$00,$00,$03,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$01,$68,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$3f,$ff,$ff,$ff,$ff,$e0,$10,$03,$03,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$80,$00,$00,$00,$00,$00,$01,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$7f,$ff,$ff,$ff,$ff,$c0,$18,$88,$c7,$ff,$ff,$fc,$00,$00,$00,$00,$00,$00,$7f,$ff,$ff,$c0,$00,$00,$00,$00,$00,$03,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$c0,$10,$80,$2f,$ff,$ff,$f8,$00,$00,$00,$00,$00,$00,$3f,$ff,$ff,$e0,$00,$00,$00,$00,$00,$02,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$01,$ff,$ff,$ff,$ff,$ff,$80,$13,$62,$3f,$ff,$ff,$f0,$00,$00,$00,$00,$00,$00,$0f,$ff,$ff,$f0,$00,$00,$00,$00,$00,$02,$68,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$07,$ff,$ff,$ff,$ff,$ff,$00,$16,$10,$07,$ff,$ff,$e0,$80,$00,$00,$30,$00,$00,$07,$ff,$ff,$f8,$00,$00,$00,$00,$00,$02,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$0f,$ff,$ff,$ff,$ff,$ff,$00,$18,$0c,$89,$ff,$ff,$81,$60,$00,$00,$48,$00,$00,$03,$ff,$ff,$fc,$00,$00,$00,$00,$00,$0d,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$1f,$ff,$ff,$ff,$ff,$fe,$00,$10,$03,$00,$7f,$ff,$06,$10,$00,$01,$86,$00,$00,$11,$ff,$ff,$fe,$00,$00,$00,$00,$00,$10,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$3f,$ff,$ff,$ff,$ff,$fe,$00,$00,$00,$a2,$3f,$fe,$09,$1c,$00,$03,$11,$80,$00,$6c,$7f,$ff,$fe,$00,$00,$00,$00,$00,$64,$68,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$f8,$00,$00,$01,$e0,$07,$fc,$30,$02,$00,$0c,$00,$60,$00,$82,$3f,$ff,$ff,$03,$ff,$ff,$ff,$80,$83,$04,$00,$00,$18,$00,$00,$00,$01,$ff,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$03,$ff,$ff,$ff,$ff,$ff,$f8,$00,$00,$03,$f8,$8b,$e0,$44,$45,$80,$14,$44,$58,$03,$23,$1f,$ff,$ff,$81,$11,$11,$13,$03,$15,$0a,$00,$00,$2e,$00,$00,$38,$1f,$45,$c0,$00,$00
      dc.b      $00,$00,$00,$00,$00,$07,$ff,$ff,$ff,$ff,$ff,$f0,$00,$00,$07,$fc,$00,$c0,$80,$00,$40,$60,$20,$06,$0c,$00,$c7,$ff,$ff,$c0,$8f,$ff,$8c,$04,$19,$02,$00,$00,$41,$80,$3f,$f0,$20,$00,$30,$00,$00
      dc.b      $00,$00,$00,$00,$00,$0f,$ff,$ff,$ff,$ff,$ff,$e0,$00,$00,$07,$ff,$22,$33,$11,$91,$30,$91,$d9,$19,$98,$88,$a3,$ff,$ff,$f0,$44,$03,$70,$1c,$61,$63,$00,$00,$a2,$7f,$fe,$00,$d3,$fd,$10,$00,$00
      dc.b      $00,$00,$00,$00,$00,$3f,$ff,$ff,$ff,$ff,$ff,$e0,$00,$00,$0f,$ff,$80,$0c,$03,$60,$0b,$01,$04,$00,$60,$00,$11,$ff,$ff,$f8,$22,$0c,$c0,$61,$81,$08,$80,$01,$08,$01,$c0,$01,$04,$06,$10,$00,$00
      dc.b      $00,$00,$00,$00,$00,$7f,$ff,$ff,$ff,$ff,$ff,$c0,$00,$00,$1f,$ff,$e8,$8c,$44,$14,$44,$46,$03,$42,$22,$32,$2c,$7f,$ff,$ff,$f1,$31,$00,$93,$01,$0c,$c0,$02,$96,$8b,$80,$02,$48,$02,$50,$00,$00
      dc.b      $00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$c0,$00,$00,$3f,$ff,$f8,$00,$08,$0c,$00,$08,$00,$80,$00,$4c,$02,$60,$00,$00,$00,$c6,$03,$0c,$01,$0a,$20,$02,$21,$80,$80,$0c,$10,$06,$10,$00,$00
      dc.b      $00,$00,$00,$00,$01,$ff,$ff,$ff,$ff,$ff,$ff,$80,$00,$00,$7f,$ff,$f6,$21,$30,$03,$11,$30,$00,$78,$89,$82,$89,$88,$88,$84,$44,$5c,$04,$5e,$01,$6a,$30,$06,$40,$62,$60,$11,$20,$fd,$10,$00,$00
      dc.b      $00,$00,$00,$00,$03,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$ff,$ff,$e3,$00,$40,$00,$80,$40,$00,$18,$06,$01,$80,$03,$ff,$ff,$fc,$20,$18,$01,$e1,$09,$10,$08,$80,$18,$10,$20,$41,$00,$10,$00,$00
      dc.b      $00,$00,$00,$00,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$01,$ff,$ff,$80,$cd,$80,$00,$65,$80,$00,$06,$28,$00,$62,$2f,$ff,$ff,$83,$10,$33,$11,$1f,$08,$88,$19,$00,$04,$8d,$c4,$82,$7f,$50,$00,$00
      dc.b      $00,$00,$00,$00,$1f,$ff,$ff,$ff,$ff,$ff,$fe,$00,$00,$01,$ff,$ff,$00,$22,$00,$00,$12,$00,$00,$01,$30,$00,$30,$11,$ff,$ff,$c1,$10,$c4,$f0,$01,$08,$44,$22,$00,$03,$02,$01,$04,$81,$10,$00,$00
      dc.b      $00,$00,$00,$00,$3f,$ff,$ff,$ff,$ff,$ff,$fe,$00,$00,$03,$ff,$fe,$00,$1c,$00,$00,$0c,$00,$00,$00,$c0,$00,$08,$e0,$7f,$ff,$e0,$c9,$58,$0f,$44,$68,$23,$e4,$00,$00,$e2,$12,$05,$81,$10,$00,$00
      dc.b      $00,$00,$00,$00,$7f,$ff,$ff,$ff,$ff,$ff,$fc,$00,$00,$07,$ff,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$80,$3f,$ff,$f0,$46,$20,$00,$f0,$08,$20,$08,$00,$00,$30,$04,$09,$ff,$10,$00,$00
      dc.b      $00,$00,$00,$01,$ff,$ff,$ff,$ff,$ff,$ff,$f8,$00,$00,$0f,$ff,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$1f,$ff,$f8,$51,$c0,$00,$0f,$08,$18,$90,$00,$3f,$e8,$c8,$14,$44,$50,$00,$00
      dc.b      $00,$00,$00,$03,$ff,$ff,$ff,$ff,$ff,$ff,$f8,$00,$00,$1f,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$ff,$fc,$21,$00,$00,$00,$f8,$0f,$e0,$3f,$ff,$ff,$f0,$3f,$ff,$10,$00,$00
      dc.b      $00,$00,$00,$07,$ff,$ff,$ff,$ff,$ff,$ff,$f0,$00,$00,$3f,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$ff,$fe,$16,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$f0,$00,$00
      dc.b      $00,$00,$00,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$f0,$00,$00,$7f,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$3f,$ff,$ff,$ff,$ff,$ff,$ff,$e0,$00,$00,$7f,$fe,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$c0,$00,$00,$ff,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$e0,$00,$00,$01,$ff,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$01,$ff,$ff,$ff,$ff,$ff,$f8,$00,$00,$00,$03,$ff,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$07,$ff,$ff,$ff,$ff,$fc,$00,$00,$00,$00,$07,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$0f,$ff,$ff,$ff,$fe,$00,$00,$00,$00,$00,$0f,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$1f,$ff,$ff,$ff,$80,$00,$00,$00,$00,$00,$1f,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$3f,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$1f,$fe,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$fe,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$ff,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,$3f,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$01,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$03,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$fe,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      even

/* hadesuk: 7FE5B262 */
/* 184x102 pixel */
	  xdef hadeslogo
hadeslogo:
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$80,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$0e,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$03,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$1e,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$07,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$80,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$80,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$80,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$80,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$80,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$80,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$40,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$a0,$00,$00,$00,$00,$00,$00,$00,$00,$1c,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$60,$00,$00,$00,$00,$00,$00,$00,$00,$14,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$a0,$00,$00,$00,$00,$00,$00,$00,$00,$1a,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$3e,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$a0,$00,$00,$00,$00,$00,$00,$00,$00,$2a,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$70,$00,$00,$00,$00,$00,$00,$00,$00,$36,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$b0,$00,$00,$00,$00,$00,$00,$00,$00,$6a,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$7e,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$b8,$00,$00,$00,$00,$00,$00,$00,$00,$aa,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$01,$78,$00,$00,$00,$00,$00,$00,$00,$00,$f6,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$03,$a8,$00,$00,$00,$00,$00,$00,$00,$01,$aa,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$03,$fc,$00,$00,$00,$00,$00,$00,$00,$03,$fe,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$02,$ac,$00,$00,$00,$00,$00,$00,$00,$02,$aa,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$03,$74,$00,$00,$00,$00,$00,$00,$00,$07,$77,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$02,$ae,$00,$00,$00,$00,$00,$00,$00,$0a,$ab,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$07,$fe,$00,$00,$00,$00,$00,$00,$00,$1f,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$06,$aa,$00,$00,$00,$00,$00,$00,$00,$1a,$ab,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$07,$77,$00,$00,$00,$00,$00,$00,$00,$37,$77,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$06,$ab,$00,$00,$00,$00,$00,$00,$00,$6a,$ab,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$0f,$ff,$80,$00,$00,$fc,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$c0,$00,$00,$c0,$00,$00
      dc.b      $00,$00,$00,$0a,$aa,$80,$00,$03,$af,$00,$00,$07,$aa,$aa,$aa,$aa,$aa,$c0,$00,$07,$80,$00,$00
      dc.b      $00,$00,$00,$0f,$77,$60,$00,$07,$77,$c0,$00,$3f,$77,$77,$77,$77,$77,$80,$00,$3f,$00,$00,$00
      dc.b      $00,$00,$00,$0a,$aa,$b8,$00,$0a,$aa,$e0,$00,$ea,$aa,$aa,$aa,$aa,$ab,$00,$00,$eb,$00,$00,$00
      dc.b      $00,$00,$00,$1f,$ff,$ff,$00,$1f,$ff,$f0,$03,$ff,$ff,$ff,$ff,$ff,$fe,$00,$03,$fe,$00,$00,$00
      dc.b      $00,$00,$00,$1a,$aa,$ab,$80,$2a,$aa,$b8,$06,$aa,$aa,$aa,$aa,$aa,$ae,$00,$06,$ac,$00,$00,$00
      dc.b      $00,$00,$00,$17,$77,$77,$40,$77,$77,$7c,$0f,$77,$7f,$f7,$77,$77,$7c,$00,$0f,$7c,$00,$00,$00
      dc.b      $00,$00,$00,$1a,$aa,$aa,$a0,$aa,$fe,$ac,$1a,$aa,$f0,$6a,$bf,$fa,$a8,$00,$1a,$a8,$00,$00,$00
      dc.b      $00,$00,$00,$1f,$ff,$ff,$f1,$ff,$c7,$fe,$3f,$ff,$80,$1f,$f8,$3f,$f0,$00,$3f,$f8,$00,$00,$00
      dc.b      $00,$00,$00,$2a,$aa,$aa,$bb,$ab,$81,$aa,$6a,$ae,$00,$0e,$ac,$2a,$b0,$00,$ea,$b0,$00,$00,$00
      dc.b      $00,$00,$00,$37,$77,$77,$7f,$77,$01,$f7,$77,$78,$00,$03,$76,$77,$60,$01,$f7,$70,$00,$00,$00
      dc.b      $00,$00,$00,$2a,$ba,$aa,$ae,$ae,$00,$ab,$aa,$e0,$00,$01,$ab,$6a,$c0,$03,$aa,$a0,$00,$00,$00
      dc.b      $00,$00,$00,$3f,$ef,$ff,$ff,$fc,$00,$ff,$ff,$80,$00,$00,$ff,$ff,$c0,$03,$ff,$e0,$00,$00,$00
      dc.b      $00,$00,$00,$2a,$c0,$1a,$aa,$b8,$00,$aa,$ab,$00,$00,$00,$ea,$aa,$80,$06,$aa,$c0,$00,$00,$00
      dc.b      $00,$00,$00,$37,$40,$07,$77,$70,$00,$f7,$76,$00,$00,$00,$77,$77,$00,$0f,$77,$40,$00,$00,$00
      dc.b      $00,$00,$00,$2a,$c0,$06,$aa,$b0,$00,$aa,$ac,$00,$00,$00,$6a,$aa,$00,$0a,$aa,$c0,$00,$00,$00
      dc.b      $00,$00,$00,$3f,$c0,$03,$ff,$e0,$00,$ff,$fc,$00,$00,$00,$3f,$fe,$00,$1f,$ff,$80,$00,$00,$00
      dc.b      $00,$00,$00,$2a,$80,$02,$aa,$c0,$01,$aa,$ac,$00,$00,$00,$2a,$ac,$00,$3a,$aa,$80,$00,$00,$00
      dc.b      $00,$00,$00,$37,$80,$03,$77,$c0,$01,$77,$76,$00,$00,$00,$37,$76,$00,$37,$77,$60,$00,$00,$00
      dc.b      $00,$00,$00,$2b,$80,$01,$ab,$80,$01,$aa,$aa,$00,$00,$00,$2a,$ab,$00,$6a,$aa,$b0,$00,$00,$00
      dc.b      $00,$00,$00,$3f,$80,$01,$ff,$00,$03,$ff,$ff,$00,$00,$00,$3f,$ff,$80,$ff,$ff,$f8,$00,$00,$00
      dc.b      $00,$00,$00,$2b,$00,$01,$ab,$00,$02,$aa,$ab,$80,$00,$00,$2a,$aa,$c0,$aa,$aa,$ac,$00,$00,$00
      dc.b      $00,$00,$00,$37,$00,$01,$77,$00,$03,$77,$77,$80,$00,$00,$37,$77,$41,$f7,$77,$77,$00,$00,$00
      dc.b      $00,$00,$00,$2a,$00,$01,$ab,$00,$06,$ab,$aa,$c0,$00,$00,$6a,$aa,$a1,$aa,$aa,$ab,$80,$00,$00
      dc.b      $00,$00,$00,$3f,$00,$01,$ff,$00,$07,$ff,$ff,$e0,$00,$00,$7f,$ff,$f3,$f7,$ff,$ff,$e0,$00,$00
      dc.b      $00,$00,$00,$2e,$00,$03,$ab,$80,$0e,$ab,$ea,$b8,$00,$00,$6a,$aa,$ae,$b3,$aa,$aa,$b0,$00,$00
      dc.b      $00,$00,$00,$36,$00,$03,$77,$80,$0f,$77,$f7,$76,$00,$00,$f7,$f7,$77,$60,$f7,$77,$7c,$00,$00
      dc.b      $00,$00,$00,$2e,$00,$02,$aa,$c0,$1a,$aa,$aa,$ab,$80,$01,$ab,$2a,$aa,$e0,$6a,$aa,$ae,$00,$00
      dc.b      $00,$00,$00,$7e,$00,$07,$ff,$f0,$3f,$ff,$9f,$ff,$f0,$1f,$ff,$1f,$ff,$c0,$3f,$ff,$fc,$00,$00
      dc.b      $00,$00,$00,$68,$00,$06,$aa,$b8,$6a,$aa,$ce,$aa,$bf,$fa,$aa,$0a,$aa,$80,$0e,$aa,$ac,$00,$00
      dc.b      $00,$00,$00,$7c,$00,$0f,$77,$77,$f7,$77,$43,$77,$77,$77,$76,$07,$77,$80,$07,$77,$78,$00,$00
      dc.b      $00,$00,$00,$68,$00,$1a,$ae,$aa,$aa,$aa,$c1,$aa,$aa,$aa,$ac,$03,$ab,$00,$01,$aa,$b8,$00,$00
      dc.b      $00,$00,$00,$78,$00,$3f,$ff,$ff,$ff,$ff,$c0,$7f,$ff,$ff,$fc,$01,$ff,$00,$01,$ff,$f0,$00,$00
      dc.b      $00,$00,$00,$78,$00,$6a,$a9,$aa,$ab,$aa,$a0,$3a,$aa,$aa,$a8,$00,$ea,$00,$02,$aa,$a0,$00,$00
      dc.b      $00,$00,$00,$70,$01,$f7,$70,$f7,$7e,$f7,$60,$0f,$77,$77,$78,$00,$74,$00,$03,$77,$60,$00,$00
      dc.b      $00,$00,$00,$78,$03,$fb,$e0,$7a,$f8,$7f,$e0,$00,$ea,$af,$80,$00,$3c,$00,$02,$aa,$c0,$00,$00
      dc.b      $00,$00,$00,$70,$00,$0c,$00,$07,$80,$00,$00,$00,$1f,$f8,$00,$00,$08,$00,$07,$ff,$80,$00,$00
      dc.b      $00,$00,$00,$70,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0e,$ab,$00,$00,$00
      dc.b      $00,$00,$00,$70,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$74,$00,$00,$00
      dc.b      $00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1a,$b8,$00,$00,$00
      dc.b      $00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$f0,$00,$00,$00
      dc.b      $00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3a,$e0,$00,$00,$00
      dc.b      $00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$37,$80,$00,$00,$00
      dc.b      $00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$6e,$00,$00,$00,$00
      dc.b      $00,$00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$78,$00,$00,$00,$00
      dc.b      $00,$00,$01,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$e0,$00,$00,$00,$00
      dc.b      $00,$00,$00,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$00,$00,$00,$00
      dc.b      $00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      dc.b      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      even

#if BINEXACT
	/* fill up space between here and start of pci emulation */
	dcb.b hades_xbios-HADES_XBIOS+mach64_pci_offset-*,-1
#endif

#endif
