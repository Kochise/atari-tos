;Korrekturen zum TOS 3.06

;Dateiversion:		4.43
;Erstellt am:		03.09.1994
;letzte Aenderung vom :	27.03.1997

lang_dif2:	equ -$4b  	   ;   0 = german
				   ;-$4b = englisch
		                   ;$161 = france
				   ;-$3E = swedisch
				   ;?$2C = swiss german 
				   ;? $E = italien 
		                   
		org  $7fe407a2+lang_dif2
		load   $3407a2+lang_dif2
		dc.b	"Medusa Computer System",0
		dc.b	"Atari Corporation",0
		dc.b	"Hades TOS : 27.03.1997"
;********************************************************************************

;fa_27.3.95:patche TOS. "img" extension verwenden ist default im seka
;1. TOSxxx.s auf seka.tos ziehen (starten)
;2a. assemblieren mit a<return> o<return>
;2b. reloziertes TOS306 image laden mit ri<return> TOSRG(fÅr deutsch)<return> $300000<return> -1<return>
;2c. nochmal assemblieren mit a <return>
;3. neues TOS image abspeichern mit wi<return> TOSH<return> $300000<return> $380000<return>
;4. HADES.FIL auf TOSPATCH.TTP ziehen.
;5. TOS.IMG ist neues TOS image file

;Lade Orginal TOS 3.06 auf Adresse $300000-$380000

;maschinen und tos id
id:		equ "hade"

;Sprachkorrektur wechsel zwischen $3400-$37C6 (max.)
lang_dif:	equ -$5a  	   ;   0 = german
				   ; $2C = swiss german
				   ;-$5A = englisch
				   ;  $E = italien 
		                   ; $1E = france,swedisch
		                   
;video auflîsung  2=st high 6=tt high           
vidmo:          equ 2
vidmo00:        equ vidmo*$100           
pci_vga_base:	equ $80000000	;screen ram beginn
isa_vga_base:	equ $ff000000	;screen ram beginn
pci_vga_reg:	equ $b0000000	;vga register
isa_vga_reg:	equ $fff00000	;vga register
pci_conf1:	equ $a0010000   ;pci config 
pci_conf2:	equ $a0020000   ;pci config 
pci_conf3:	equ $a0040000   ;pci config 
pci_conf4:	equ $a0080000   ;pci config 
mem_max:	equ $40000000	;memory maximum 1 GB

proc_lives:	equ $380	   ;ab hier werden die
proc_regs:	equ $384	   ;bei einer exception 
proc_pc:	equ $3c4	   ;abgelegt
proc_usp:	equ $3c8
proc_stk:	equ $3cc
sysbase:	equ $4f2
adr_CPU:        equ $986           ;adresse word cpu type
adr_MCH:        equ $99c           ;fa_8.11.94: adresse wert _MCH cookie
startup_stk:	equ $5758
longframe:	equ $59e	   ;w: stackformat (0=68000) 40=68040 60=mc68060
movec:		equ $4e7b	   ;d0->control reg
movecd: 	equ $4e7a	   ;control reg -> d0
cacr:		equ 2
tc:  		equ 3
itt0:		equ 4
itt1:		equ 5
dtt0:		equ 6
dtt1:		equ 7
pcr:		equ $808
cinva:		equ $f4d8	   ;invalidate all cache lines
cpusha: 	equ $f4f8	   ;push und invalidate all cache lines
cpushd: 	equ $f478          ;push und invalidate daten cache lines
USA:		EQU	0	;
FRG:		EQU	1	;
FRA:		EQU	2	;
UK:		EQU	3	;
SPA:		EQU	4	;
ITA:		EQU	5	; Country- Codes laut Atari Doku
SWE:		EQU	6	;
SWF:		EQU	7	;
SWG:		EQU	8	;
TUR:		EQU	9	;
FIN:		EQU	10	;
NOR:		EQU	11	;
DEN:		EQU	12	;
SAU:		EQU	13	;
HOL:		EQU	14	;
CSFR:		EQU	15	;
HUN:		EQU	16	;

;push und invalidate data cache lines
cpushala0:	equ $f4e8	;push und invalidet d+i cache line by a0

;--- DMA Sound
sounddmactl:	equ $ffff8900	;DMA Sound Subsystem (STe)
microwiredata:	equ $ffff8922
microwiremask:	equ $ffff8924

Buserr:		equ $08
Illerr:		equ $10
LineF:		equ $2c		;Line-F / TRAP-No. 11
Exept61:	equ $f4		;Exeption 61 vom 68060


; .26 .28
; Hier eine wichtige Aenderung !!!
; wenn ein Programm so heftig abstuerzt, das es die memval
; Variablen zerschiesst, konnte bei tos im ram (pmmu an)
; ein derber Haenger passieren. Also hier schon ALLES AUS !!!
; und Hardware nicht cachen.
;
; .29
; Nach dem ERSTEN Einschalten reagiert auch die PMMU des 68040
; allergisch auf einen PFLUSHA Befehl. Nachdem dieser hier erst
; wieder rausgeflogen ist (passiert beim Cookie-Test sowieso
; nochmal) ist auch dieser ominoese Einschalt-Haenger verschwunden.
; Natuerlich steht auch zu diesem 'Problem' nix in der Motorola-Doku ...

;kein 68030,romport,mmu und scu
;68040 init -> mmu aus etc.
;(fa_8.11.94):mmu cacr etc nur einmal setzen

kmmu1:

		org  $7fe016ec
		load   $3016ec
		rts
		blk.b $7fe01724-*,$ff

;neues init 
		org  	$7fe00030
		load 	  $300030
		move.w  #$2700,sr	;interrupt aus
		reset
		move.b	#$a,ldor	;floppy reset
                move.l  #$807fc040,d0	;transparent 2: $8000'0000-ffff'ffff = no cache serialized
                dc.w 	movec,dtt1
                dc.w 	movec,itt1
		move.l	#$7fc040,d0	;no cache serialized
 		dc.w	movec,dtt0	;transparent translation daten 0
		move.l	#$7fc000,d0	;instruction = write trough
		dc.w	movec,itt0	;transparent translation intstruction 0
		clr.l	d0		;cache aus
                dc.w    movec,cacr      ;cache setzen
		dc.w	cinva		;caches invalid
	        dc.w    movec,$801      ;VBR = 0
                move.l 	#$210,d0
                dc.w 	movec,3         ;setze no cache, precise fÅr mc68060 (geht auch fÅr mc68040)

                move.b	#$e,ldor        ;floppy normal int activ
                clr.b	moton           ;motor aus
                clr.b	sctr2		;vme int off, scsi count0/eop und buserror off
                
;memory konfig setzen (in d6 sichern)
sweite:		equ  $20000			;schrittweite ramtest
mtadr1:		equ  $8000000			;doppelseitig
mtadr2:		equ  $2000000			;4mx32
mtadr3:		equ  $800000                    ;1mx32
mem_set_adr:	equ  $70000000

		lea     mem_set_adr,a0	;adressen setzen
		lea	mtadr1,a1       ;adressen setzen
		lea 	mtadr2,a2
		lea 	mtadr3,a3
		move.l  #id,d3		;testmuster
		move.l  #-id,d4		;testmuster
		clr.l   (a0)            ;default maximum
		clr.l   d6		;default 32mx32 module
		clr.l   (a3)            ;1mx32
		clr.l   4(a3)		;1mx32 modul 2
		clr.l   (a2)            ;4mx32
		clr.l   4(a2)		;4mx32 modul 2
		move.l  d3,(a1)		;zweiseitig
		move.l  d3,4(a1)	;zweiseitig modul 2
		move.l  d3,0.w 		;start mit testmuster -> spiegelung eruieren
		move.l  d3,4.w          ;2. modul
		move.l	d4,$c.w		;2. modul
		nop
		cmp.l   (a1),d3		;zweiseitige module? -> wenn testmuster vorhanden
		bne	not_zweiseitig	;nein ->
		cmp.l	4(a1),d3	;zweiseitig modul 2
		beq	zweiseitig	;ja ->
not_zweiseitig:	moveq	#1,d6		;sonst auf einseitig setzen
zweiseitig:	tst.l   (a2)            ;nicht 32mx32? noch null? (wenn 4mx32 steht wegen spiegelung der 'id' drin)
                bne	non32mx32	;nein -> max 4mx32
                tst.l	4(a2)		;nicht 32mx32 module 2
                beq	mem_set_fertig	;doch->
non32mx32:      addq.l  #2,d6           ;sonst auf 4mx32 
		tst.l   (a3)		;nicht 4mx32? noch null
                bne	non4mx32	;nein -> 1mx32
                tst.l	4(a3)		;nicht 4mx32
                beq	mem_set_fertig	;doch ->
non4mx32:       addq.l  #2,d6           ;sonst auf 1mx32
mem_set_fertig: cmp.l   4.w,d3		;nur 1 modul?
		bne	set1m		;ja -> setzen
		cmp.l   $c.w,d4		;test
		beq	mem_set_end	;2 module->
set1m:		moveq   #9,d6		;nur ein modul einseitig
mem_set_end:	move.l  d6,d0
                swap	d0
		lsl.l	#4,d0
		add.l	d0,a0
		clr.b   (a0)		;und wert setzen

;resetvektor testen und springen wenn ok
		lea	mtra1(pc),a6
		bra	$7fe00c06         ;mem val test
mtra1:		bne	sndinit		;wenn nicht ok kein reset vektor sprung
rsvektst:	cmp.l	#$31415926,$426.w
		bne	sndinit
		move.l  $42a.w,d0
		btst	#0,d0
		bne	sndinit
		move.l  d0,a0
		lea	rsvektst(pc),a6
		jmp 	(a0)

;init soundchip
sndinit:	lea	$ffff8800.w,a0
		move.b  #7,(a0)
		move.b  #$c0,2(a0)
		move.b  #$e,(a0)
		move.b  #7,2(a0)

;memvalid test2		
                lea 	mtra(pc),a6     ;ruecksprungadresse memtest
                bra	$7fe00c06        ;testen
mtra:		beq	L0019           ;wenn 0 dann ok ->


; .24 .25 .26 .27 .28
; Beim Ramtest ist sowieso noch Platz, also kann man
; zum Speicherloeschen auch ein paar movem.l spendieren ...
; (geht naemlich deutlich schneller als nur move.l)

;neuer ramtest
        	lea 	startup_stk.w,a7	;stack init
		move.l 	#id,d3			;bitmuster
		move.l 	#-id,d4
		move.l  #mem_max,d5
                clr.l 	$4f6.w
		move.l 	#idinerr,Buserr.w	;neuer buserrorvektor
		move.l 	#sweite,d7		;startadresse und scrittweite
		move.l 	d7,a0			;startadresse setzen
		move.l 	a0,a1
idin:		move.l 	d3,-4(a1)
		move.l 	d4,-8(a1)
		add.l	d7,a1
		bra	idin	

idinerr:	move.l 	#L0017,Buserr.w		;neuer buserrorvektor
L0014:		move.l 	a0,a1    		;test auf spiegelung. wenn nicht da dann spiegelung
		cmp.l	-4(a1),d3
		bne	L0017
		cmp.l	-8(a1),d4
		bne	L0017
		move.l 	d0,d2			;0->d2
		moveq 	#$15,d1			;schleifenindex
L0015:		move.l 	d2,-(a1) 		;bitmuster einschreiben
		add.l 	d3,d2			;bitmuster verÑndern
		dbf 	d1,L0015		;next
		move.l 	a0,a1
		moveq 	#$15,d1			;schleifenindex
L0016:		cmp.l 	-(a1),d0		;bitmuster vergleichen
		bne 	L0017			;ungleich -> weg + fertig
		add.l 	d3,d0
		dbf 	d1,L0016
		add.l 	d7,a0			;nÑchster 128 KB
                bra	L0014			;bis buserror

L0017:		move.l	#$8000,d0		;instruction cache on
                dc.w    movec,cacr      	;cache setzen
                
		sub.l 	d7,a0			;endadresse speicher
		move.l 	a0,d4
		lea 	$100,a0			;beginn lîschen
		moveq 	#0,d0
		moveq 	#0,d1
		moveq 	#0,d2
		moveq 	#0,d3
L0018:		movem.l D0-D3,0(a0)		;speicher
		movem.l D0-D3,16(a0)		;...
		movem.l D0-D3,32(a0)		;...
		movem.l D0-D3,48(a0)		;...
		movem.l D0-D3,64(a0)		;...
		movem.l D0-D3,80(a0)		;...
		movem.l D0-D3,96(a0)		;...
		movem.l D0-D3,112(a0)		;lîschen
		add.l	#128,a0
		cmp.l 	#$800000,a0		;schon fertig (nur erste 8 MB loeschen -> geht sonst zu lang und zudem wird der speicher vom memtest geloescht!)
		blt 	L0018			;nein -> wiederhohlen
		move.b 	d6,$424.w		;config sichern
		move.l 	d4,$42e.w		;memtop sichern
		clr.l 	$5a4.w			;kein TT Ram
		move.l 	#$752019f3,$420.w	;memvalidwerte
		move.l 	#$237698aa,$43a.w
		move.l 	#$5555aaaa,$51a.w
		move.l 	#$1357bd13,$5a8.w
L0019:		lea 	startup_stk,a7		;stack startup
		lea 	$a12.w,a0
		lea 	$e6fc,a1	
L001F:		clr.w 	(a0)+	 		;tos bereich lîschen
		cmp.l 	a0,a1
		bne.s 	L001F

		clr.l	d0			;cache aus
                dc.w    movec,cacr      	;cache setzen
                dc.w	cinva

		jsr 	screen_init 		;screen karte initialisieren
				
		move.l	#$8000,d0		;instruction cache on
                dc.w    movec,cacr      	;cache setzen

                if vidmo=2
		move.w #1999,d1			; 640x400 bits = 32000/16-1 byt lîschen
		else
		move.w #9599,d1               	;1280*960 bits = 153600/16-1
		endif
		
		move.l 	a0,$44e.w		;screen adr setzen
L0020:		clr.l 	(a0)+	 		;screen lîschen
		clr.l 	(a0)+
		clr.l 	(a0)+
		clr.l	(a0)+
		dbf d1,L0020

;(fa_8.11.94):resetvektor gleich setzen
                move.l $7fe00000,0.w
                move.l $7fe00004,4.w
             
		bra ende_ram_test
		blk.b $7fe002c8-*,$ff
ende_ram_test:

;memtop kommt woanders her
		org  $7fe00336
		load   $300336
		move.l $42e.w,$436.w
	 
;***************************************************************************************
;neue ramanzeige
		org  $7fe06076+lang_dif
		load   $306076+lang_dif
		moveq	#10,d7		;7 Stelle statt 5 = total 11 ("kB" und 2xleerschlag)

;nicht "ST RAM" sondern "FASTRAM"  
		org  $7fe062b2+lang_dif
		load   $3062b2+lang_dif
		dc.b	"FASTRAM"

		org  $7fe063d4+lang_dif
		load   $3063d4+lang_dif
L03C9:  	move.l  #1000000,D2 
      		CLR.w	D3     		;vornullunterdrÅckung on
L03CA:		dc.w    $4c42,$1        ;divul.l d2,d1:d0
      		MOVEM.L D1-D2,-(A7) 
      		tst.B   D0            	;zahl?
      		BNE.S   L03CB           ;ja->
      		TST.W   D3              ;noch keine zahl?
      		BNE.S   L03CB           ;nein
      		CMP.L  	#1,D2           ;divisor=1
      		BEQ.S   L03CB           ;ja->
      		MOVE.B  #" ",D0         ;sonst leerzeichen
      		BRA.S   L03CC 
L03CB:		ADD.B   #"0",D0         ;add ascii 0
      		MOVEQ   #1,D3           ;vornull aus
L03CC:		MOVE.W  D0,-(A7)        ;zeichen ausgeben
      		MOVE.L  #$30002,-(A7) 
      		TRAP    #$D 
      		ADDQ.W  #6,A7 
L03CD:		MOVEM.L (A7)+,D1-D2 
      		MOVE.L  D1,D0           ;rest nach d0
      		MOVEQ   #10,D1          ;divisor = 10
      		dc.w	$4c41,$2002	;DIVUL.L D1,D2:D2       ;auf ein zehntel setzen
      		BNE.S   L03CA 
L03CE:		MOVEM.L (A7)+,D3-d4 
      		RTS 
                blk.b	$7fe06476-*,$ff /* THO: BUG: +lang_dif missing */
;======================================================================================
; .28
; Prozessortest abÑndern  (fa_8.11.94):mmu cacr etc. ist schon gemacht
; und cookie setzen
; Hier gab's mit die groessten Aenderungen - aber mal ganz von vorn:
; Prozessor-default ist jetzt 68040, es wird aber auch auf einen 68060
; getestet !!! Wenn der gefunden wird, wird er natuerlich auch in _CPU
; eingetragen. Dazu wird diese ominoese Exeption 61 verwendet ... (keine
; Ahnung ob's wirklich funktioniert - in der Motorola Doku steht's
; jedenfalls so drin - wenn sie denn diesmal stimmt ...)
; Fredi, wo bleibt der 68060 zum ausprobieren ???

		org  $7fe003a0
		load   $3003a0

		moveq	#40,d1		; prozessor default ist mindestens 68040
		move.l	Exept61.w,a1	; Exeption61 retten
		lea	chk68060(pc),a2	; dann fliegen wir nach dort raus
 		move.l	a2,Exept61.w	;
		move.l	sp,a3		; Stack retten falls Exeption
		dc.w	%0000000011010000	; cmp2.b (a0),d0
		dc.w	%0000000000000000	; (geht beim 68060 nicht mehr)
		bra	chk_68060	; ging gut, also nur Exeption restaurieren
chk68060:				; wenn wir hier vorbeikommen gab es eine Exeption
		move.l	a3,sp		; Stack zurueck
		moveq	#60,d1		; dann 68060 eintragen
chk_68060:				; sonst nur
		move.l	a1,Exept61.w	; Exeption61 zurÅck

;(fa_8.11.94):
		moveq	#0,d0			;beide cache aus
		move.l	d0,$e4.w		;cacr save setzen

		move.l	d1,(a0)+		;cpu typ setzen
; .26
		move.w	d1,longframe.w		;und auch noch in longframe setzen
						;(da longframe nur <>0 sein muss, kann man
						;sich hier sehr schoen die CPU merken ...
						;(Merke: auch 40 oder 60 ist <> 0)
		move.l	#"_VDO",(a0)+		;video

; .28 .30
; Um ein wenig mehr 'Luft' zwischen den von Atari belegten _VDOs und
; der Medusa zu haben, melden wir nun als _VDO = 40 (von ET4000 - passt
; irgendwie auch besser)
; ab .30 Video default = -1 (laut Eric Smith) fÅr nicht ST/TT/Falcon-Video
; Hardware
;(fa_8.11.94):-1 funktioniert nicht mit nvdi
;(fa_2.05.96):40000 funktioniert nicht mit nvdi
		move.l	#$20000,d1
		move.l	d1,(a0)+		;standart  = 20000(=mode 2 -> 640x400) von ET4000
						;
; .28
; fuer weitere cookie Spielereien ist hier kein Platz mehr
; es muss also weiter hinten angesprungen werden

		jmp	morecook

; .29
; der oben gebrauchte NULL-Frame hat hier noch Platz, dann geht
; es oben mit einer (PC) Adressierung.

cook_wei:	clr.l  	(a0)+		;cookie endkennunung
                move.l #$10,(a0)

;fa_9.11.94:fÅr mc68060 zusaetzlich uii
;exception vektoren setzen
                lea 	la_rte,a3
                lea 	la_rts,a4
                lea 	exception,a1
                lea 	8.w,a0
                moveq 	#$3d,d0
exc_loop:       move.l 	a1,(a0)+
                dbf 	d0,exc_loop
                moveq	#6,d0
                lea	$64.w,a1
exc_loop2:	move.l  a3,(a1)+
		dbf	d0,exc_loop2
                move.l 	a3,$14.w  		;integer divide by zero                              
		move.l  $44e.w,$e8.w		;physbas setzen
                cmp.w	#60,longframe.w
                bne	exc_wei
       		MOVE.L 	#unim_int_instr,$F4.W
       		move.l	#xFP_CALL_TOP+$80+$30,$2c.w	;fline
       		move.l	#xFP_CALL_TOP+$80+$00,$d8.w	;snan
       		move.l	#xFP_CALL_TOP+$80+$08,$d0.w	;operr
       		move.l	#xFP_CALL_TOP+$80+$10,$d4.w	;overflow
       		move.l	#xFP_CALL_TOP+$80+$18,$cc.w	;underflow
       		move.l	#xFP_CALL_TOP+$80+$20,$c8.w	;divide by zero
       		move.l	#xFP_CALL_TOP+$80+$28,$c4.w	;inex
       		move.l	#xFP_CALL_TOP+$80+$38,$dc.w	;unsupp
       		move.l	#xFP_CALL_TOP+$80+$40,$f0.w	;effadd
       		dc.l	$f23c,$9000,0,0			;fmove.l #0,fpcr
                bra 	exc_wei
la_rte:         rte
la_rts:         rts                
                blk.b $7fe004f0-*,$ff
exc_wei:

		org  $7fe004f8
		load   $3004f8
                move.l 	#int2,$68.w             ;int 2 interrrupt

;st high
		org  $7fe005ae
		load   $3005ae
		moveq #vidmo,d1
		nop
		nop

;sr setzen scsi int on
		org  $7fe005dc
		load   $3005dc
		move	#$2100,sr
		
		org  $7fe00740
		load   $300740
;medusa logo ausgeben 376x135 Pixel = 47 Byts x 135 Zeilen
		lea 	logo,a0 		;logo 
		move.l 	$44e.w,a1
		move.l 	a1,a2
		move.w 	#134,d1
lolo1:	
                if vidmo=2
        	add.w 	#80-47,a2       ;ST hoch
        	else 
        	add.w 	#160-47,a2      ;TT hoch
        	endif
        	
		moveq 	#46,d2
lolo2:		move.b 	(a0)+,(a2)+
		dbf 	d2,lolo2
		dbf 	d1,lolo1

		lea 	hadeslogo,a0 	;hades logo 
		move.l 	$44e.w,a1
		move.l 	a1,a2
		add.w   #240+27,a2	;4.Zeile 4.byt
		move.w 	#101,d1
lolo3:	
                if vidmo=2
        	add.w 	#80-23,a2       ;ST hoch
        	else 
        	add.w 	#160-23,a2      ;TT hoch
        	endif
        	
		moveq 	#22,d2
lolo4:		move.b 	(a0)+,(a2)+
		dbf 	d2,lolo4
		dbf 	d1,lolo3
		bra 	end_logo
		blk.b 	$7fe0079e-*,$ff
end_logo:

; .28
; Wenn man auf das gepatchte TOS noch den TOS-Patch und WINX loslaesst, darf
; der CRC-Test ruhig drinbleiben, die Checksumme wird 'eh neu berechnet.
	      
;kein crc test bei proms
;		 org  $7fe00804
;		 load   $300804
;		 nop
;		 nop
;st high auflîsung
		org  $7fe00886
		load   $300886
		cmp.b #vidmo,$44c.w

;keine TT-SCU und mit IDE harddisk beginnen
		org  $7fe00b12
		load   $300b12
		moveq #$10,d4			;beginn mit ide 0
		moveq #0,d0			;dma boot
		move.w d0,$a00.w
		bra boot
boot1:		cmp.w #$11,d4			;ide 1?
		bne boot			;nein -> weiter
boot2:		moveq #8,d4			;ja bei scsi 0 weitermachen
		bra boot
boot3:		moveq #0,d4			;bei acsi 0 weitermachen
		bra boot
		blk.b $7fe00b3e-*,$ff
boot:						     
				
;ide und harddisk
		org  $7fe00b80
		load   $300b80
		cmp.w #7,d4		;acsi 7?
		bne.s no_ni_fer		;nein->
		rts			;sonst fertig
no_ni_fer:	cmp.w #$f,d4		;scsi 7?
		beq boot3		;ja ->
		bra boot1
		blk.b $7fe00b94-*,$ff

;kein monitor change
		org  $7fe005a4
		load   $3005a4
		nop
		nop
		nop
		nop
		nop

;cache push bei trap 13 und trap 14
		org  $7fe00db8
		load   $300db8
		move.l	a1,$4a2.w
		dc.w	cpusha
	
;kein screen change in vertikal blank interrupt
		org  $7fe00c9a
		load   $300c9a
		jsr 	$7fe0761a+lang_dif
		jsr	flopvbl
		bra 	mon_chg

;scsi arbitration
arbitr: 	BSR	  $7fe01d18
L0174:		BTST	  #6,$ffff8789.w
		BEQ.S	  L0175 
		CMP.L	  (A0),D1 
		BHI.S	  L0174 
		BRA.S	  L0177 
L0175:		clr.b	  $ffff8787.w
		clr.b	  $ffff8789.w
		MOVE.B	  #$80,$ffff8781.w
		MOVE.B	  #1,$ffff8783.w
		MOVE.B	  #9,$ffff8783.w 
		TST.B	  $fffffa01.w 
		TST.B	  $fffffa01.w 
		TST.B	  $fffffa01.w 
		TST.B	  $fffffa01.w 
		TST.B	  $fffffa01.w 
		TST.B	  $fffffa01.w 
		MOVE.B	  #$D,$ffff8783.w
		TST.B	  $fffffa01.w 
		TST.B	  $fffffa01.w 
		TST.B	  $fffffa01.w 
		MOVE.W	  4(A7),D1
		BSET	  D1,$ffff8781.w
		bclr	  #0,$ffff8785.w
		BCLR	  #3,$ffff8783.w 
		BSR	  $7fe01d18 
L0176:		BTST	  #6,$ffff8789.w
		BNE.S	  L0178 
		CMP.L	  (A0),D1 
		BHI.S	  L0176 
L0177:		MOVEQ	  #-1,D0
		BCLR	  #0,$ffff8783.w 
		clr.b	  $ffff8783.w 
		RTS 
L0178:		moveq	  #0,D0
		BCLR	  #2,$ffff8783.w 
		clr.b	  $ffff8783.w 
		RTS 
                blk.b     $7fe00d64-*,$ff
mon_chg:

;----------------------------------------------------------------------------------------------------------------------------
;scc andere takrate 14.7456 statt 8 MHz
;default wert 9600 Baud
		org  $7fe02d13
		load   $302d13
		dc.b	46
		
;neue scc transferraten
		org  $7fe031E4
		load   $3031e4
		dc.w	22	;0=19200 baud
		dc.w	46	;1=9600
		dc.w	94	;2=4800
		dc.w	126	;3=3600
		dc.w	190	;4=2400
		dc.w	228	;5=2000
		dc.w	254	;6=1800
		dc.w	382	;7=1200
		dc.w	766	;8=600
		dc.w	1534	;9=300
		dc.w	10	;10=38400
		dc.w	6	;11=57600
		dc.w	4	;12=76800
		dc.w	2	;13=115200
		dc.w	1	;14=153600
		dc.w	0	;15=230400
		

;Åberall st high auflîsung 
		org  $7fe01166
		load   $301166
		moveq #vidmo,d0
		rts
		blk.b $7fe01172-*,$ff
		rts
		blk.b $7fe011c8-*,$ff
		rts
		blk.b $7fe011d0-*,$ff
		rts
		blk.b $7fe01202-*,$ff

		org  $7fe01756
		load   $301756
		move.l #vidmo00,d0
		rts
		blk.b $7fe01786-*,$ff
		move.l #vidmo00,d0
		rts
		move.l #vidmo00,d0
		rts
		blk.b $7fe017a6-*,$ff
		moveq #0,d0
		rts
		blk.b $7fe017c8-*,$ff
		move.w 4(a7),d0
		and.w #$ff,d0
		sub.w #$100,d0
		neg.w d0
		rts
		blk.b $7fe017f6-*,$ff
		move.w 4(a7),d0
		and.w #$ff,d0
		sub.w #$100,d0
		neg.w d0
		rts
		blk.b $7fe01824-*,$ff
		moveq #vidmo,d0
		rts
		blk.b $7fe01848-*,$ff
		moveq #vidmo,d0
		add.b d0,d0
		subx.w d0,d0
		neg.w d0
		rts
		blk.b $7fe0186c-*,$ff

		org  $7fe06742+lang_dif
		load   $306742+lang_dif
		cmp.w #vidmo,d0

		org  $7fe06972+lang_dif
		load   $306972+lang_dif
		cmp.w #vidmo,d0

		org  $7fe06eb2+lang_dif
		load   $306eb2+lang_dif
		move.l #vidmo00,d5

		org  $7fe06eba+lang_dif
		load   $306eba+lang_dif
		and.w #7,d5

		org  $7fe06eec+lang_dif
		load   $306eec+lang_dif
		move.l #vidmo00,d4

		org  $7fe06fae+lang_dif
		load   $306fae+lang_dif
		move.l #vidmo00,d0

		org  $7fe07066+lang_dif
		load   $307066+lang_dif
		move.l #vidmo00,d5

		org  $7fe070fe+lang_dif
		load   $3070fe+lang_dif
		move.l #vidmo00,d7

		org  $7fe07172+lang_dif
		load   $307172+lang_dif
		move.l #vidmo00,d0

;neues physbase
		org  $7fe01144
		load   $301144
		move.l $e8.w,d0        		;phys base holen
		rts
		blk.b $7fe01160-*,$ff

;weniger xbios aufrufe
		org  $7fe00e2c
		load   $300e2c
		dc.w $41

;kein blitter
		org  $7fe015dc
		load   $3015dc
		moveq #0,d0
		rts

;scsi arbitration anders ansprechen

		org  $7fe01c1c
		load   $301c1c
		bra arbitr
		blk.b $7fe01c7c-*,$ff
		
		org  $7fe01d26
		load   $301d26
		move.l #66,d1	 ; nur 1/3 sec und nicht 1 sec warten

;keine tt palette
		org  $7fe06ea4+lang_dif
		load   $306ea4+lang_dif
		rts

		org  $7fe07052+lang_dif
		load   $307052+lang_dif
		rts


;floppy komplett neu
;************************************
		org  $7fe00e4e
		load   $300e4e
                dc.l floprd,flopwr,flopfmt

		org  $7fe00e7a
		load   $300e7a
                dc.l flopver
                
		org  $7fe00ed2
		load   $300ed2
                dc.l floprate
                
		org  $7fe05616+lang_dif
		load   $305616+lang_dif
		jsr  flopini.l
		
		org  $7fe05968+lang_dif
		load   $305968+lang_dif
		jsr  floprd.l
		
		org  $7fe05db4+lang_dif
		load   $305db4+lang_dif
		jsr  floprd.l
		
;floppy hardware routinen
		org  $7fe03ba8+lang_dif
		load   $303ba8+lang_dif

;hades hardwareregister
main_status:	equ $fff00080
data_reg:	equ $fff00082
ldor:		equ $fff000c0
ldcr:		equ $fff000e0

; Hardwareregister
dmahigh:	equ $FFFF8608
dmamid:		equ $FFFF860B
dmalow:		equ $FFFF860D
gpip:		equ $FFFFFA81	; TTMFP: Interface Port Datenregister

; sonstige Variablen
defhdinf:	equ $302		; Default hdinf. byt 0 -> anzahl versuche byt 1 -> taktrate (hd default)
ed:		equ 0			; clockraten fÅr verschiedene format
hd:		equ 2
dd:		equ 3
hlt:		equ 3			;head load time in milisekunden (in 1ms schriten 1-128ms)
hut:		equ 120			;head unload time in ms (in 16ms schritten 8-120ms)

; dokumentierte	Systemvariablen
etv_critic:	equ $0404
phystop:	equ $042E	; Obergrenze ST-RAM
flock:		equ $043E	; Sperren von FDC-Aktionen
seekrate:	equ $0440
xfrclock:	equ $0466
hdv_bpb:	equ $0472	; BPB holen
hdv_rw:		equ $0476	; Lesen-/Schreiben von Sektoren
hdv_med:	equ $047E	; Test auf Mediumwechsel
xnflops:	equ $04A6
xhz_200:	equ $04BA	; 200Hz	ZÑhler
xdrvbits:	equ $04C2	; Bitvektor	fÅr	angeschl. Laufwerke
xdskbufp:	equ $04C6	; Zeiger auf 1k	Diskbuffer
xcookies:	equ $05A0	; zeigt	auf	Cookiejar

; nicht	dokumentierte Systemvariablen
retry:		equ $17CA	; W: Anz. Versuche
changenew:	equ $17CC	; W: (Vbl) neuer Disk change Status 
changeold:	equ $17CE	; W: (Vbl, change) alter Disk change Status
lastuseda:	equ $17D0	; L: _frclock nach letztem Zugriff (LW A:)
lastusedb:	equ $17D4	; L: _frclock nach letztem Zugriff (LW B:)
deseltime:	equ $17D8	; L: (Vbl) Nachlaufzeit
rwflag:		equ $17DC	; w: lesen schreiben flag:1.Byt lesen=0 schreiben=1. 2.Byt 0=read 1=verify 2=daten ungleich bei verify
moton:		equ $17DE	; W: (Vbl) Flag: <>0 -> moton on
cdevno:		equ $17E0	; W: Laufwerk (0,1)
ctrackno:	equ $17E2	; W: Track (0..82)
csecno:		equ $17E4	; W: Sektor	(1..36)
csideno:	equ $17E6	; W: Seite (0,1)
ccount:		equ $17E8	; W: Anzahl	Sektoren
cbuffer:	equ $17EA	; L: zeigt auf Buffer fÅr DMA
cspt:		equ $17EE	; W: (Format) Sektoren pro Track
cinterlv:	equ $17F0	; L: (Format) interleave
cvirgin:	equ $17F2	; W: (Format)
verifyflag:	equ $17f0	; W: 0 = sectortest. <>0 = verify
cfiller:	equ $17F4	; L: (Format)
def_err:	equ $17F8	; W: Standard-Fehlernummer
cerror:		equ $17FA	; W: aktuelle Fehlernummer
regsave:	equ $17FC	; L: zeigt auf Reg.Save	Area
;
;					 Disk Status Block LW A:
dsb0:		equ $1820	; B: $1820:	 dsb[0].cmdflag
curtrk:		equ 2		; W: $1822:	 dsb[0].curtrack
hdinfo:		equ 4		; W: $1824:	 dsb[0].hd_info
skrate:		equ 6		; W: $1826:	 dsb[0].seekrate
;					 Disk Status Block LW B:
dsb1:		equ $1828	; B: $1828:	 dsb[1].cmdflag
;		equ $182A	; W: $182A:	 dsb[1].curtrack
;		equ $182C	; W: $182C:	 dsb[1].hd_info
;		equ $182E	; W: $182E:	 dsb[1].seekrate
trycount:	equ $1830	; HD/DD Leseversuche
status_buffer:  equ $1832       ; max. 7 byts bis $1838

save1:		equ $f8		; L:ablageregister
save2:		equ $fC		; L:ablageregister
;
chg_mode:	equ $5B86	; L: zeigt auf Drive Change	Mode
log_dev:	equ $5B92	; W: aktuelles logisches Laufwerk

; externe ROM-Routinen
xetv_crit:	equ $7FE00D92	; etv_critic  Critical Event Handler
xwait_xtc:	equ $7FE0162E	; wait_tctick  MFP Timer C Ticks warten

;**********************************	flopini	 Laufwerk initialisieren) S.113	***
flopini:	lea	dsb0.w,A1
		tst.w	12(A7)			;Disk Status Block setzen
		beq.s	flopini1
		lea	dsb1.w,A1
;-------------------------------------------------
flopini1:	move.w	seekrate.w,skrate(A1)
		bsr	fdc_reset
		move.w	#-256,curtrk(A1)	;*negativ, damit restore ausgefÅhrt wird
		moveq	#-1,d0			;
		bsr	floplock		;*incl. select0 und restore
		beq	flopok			;*
		bra	flopfail		;*
;------------------------------------------------------------------------------
;*********************** no_flops  keine Floppies vorhanden	(Neu ggÅ. 2.06)	***
no_flops:	moveq	#-15,D0
		rts
;****************************** floplock  Floppy Parameter Åbernehmen S.119	***
;hades
floplock:	movem.l	D1-D7/a2-a3,regsave	;.w
		move.w	#1,flock.w		;aktiv
		move.w	D0,def_err.w
		move.w	D0,cerror.w
		move.l	8(A7),a3                ;a3 zeigt auf buffer
		move.l	a3,cbuffer.w
		move.w	14(a7),verifyflag.w
		move.w	16(A7),cdevno.w
		move.w	18(A7),d4               ;startsector nach d4
		move.w	d4,csecno.w
		move.w	20(A7),ctrackno.w
		move.w	22(A7),csideno.w
		move.w	24(A7),ccount.w
		move.w	#2,retry.w
;-------------------------------------------------
		lea	dsb0.w,A1		;Disk Status Block setzen
		tst.w	cdevno.w
		beq	flplock1
		lea	dsb1.w,A1
;-------------------------------------------------
flplock1:	tst.w	curtrk(A1)		;dsb[devno].curtrack
		bpl	lock_rts		;positiv? dann fertig
;-------------------------------------------------
		bsr	select0			;negativ? dann restore
		bsr	restore			;Track 0
		beq	end_ok
		move.w	#-1,curtrk(A1)
end_err:        moveq	#-1,d0			;fehler
                rts                             ;zurÅck
;************************************* flopfail  Fehler	in Floppy Routine aufgetreten S.120	---
flopfail:	bsr	fdc_reset
		moveq	#1,D0
		bsr	setdmode
     		move.w	cerror.w,D0
		ext.l	D0
		bra	flopok1
;*************************************** flopok	Floppy Routine fehlerfrei beendet S.120	---
flopok:		clr.l	D0
flopok1:	move.l	D0,-(A7)
;-------------------------------------------------
		tst.b	moton.w                 ;motor aus?
		beq	flopok3                 ;ja ->
		move.l	xhz_200.w,D0
		add.l	#1000,D0		;Nachlaufzeit 5 sec
		move.l	D0,deseltime
		move.b	#$3e,ldor		;select aus,motor bleibt on

flopok3:	move.w	cdevno.w,D0
		lsl.w	#2,D0
		lea	lastuseda.w,A0
		move.l	xfrclock.w,0(A0,D0.w)	;Zugriffszeitpunkt
		cmp.w	#1,xnflops.w		;merken
		bne.s	flopok2
		move.l	xfrclock.w,4(A0)
;-------------------------------------------------
flopok2:	move.l	(A7)+,D0
                clr.w	flock.w
		movem.l	regsave.w,D1-D7/a2-a3
lock_rts:	rts
;******************************************************* Xbios(41) Floprate	***
;		PART 'floprate'
floprate:	lea	dsb0,A1				;.w A1	zeigt auf DSB
		tst.w	4(A7)				;von Laufwerk A:
		beq.s	floprat1
		lea	dsb1,A1				;.w oder Laufwerk B:
;-------------------------------------------------
floprat1:	move.w	skrate(A1),D0			;alte seekrate holen
		move.w	6(A7),D1			;Parameter vom Stack
		bmi	floprat2			;get log_seekrate
		move.w	D1,skrate(A1)			;set log_seekrate
		lea	steptab(pc),a0
		and.w	#3,d1
		moveq	#3,d7				;specify
		bsr	sendcom
		bmi	floprat2
		move.b	0(a0,d1.w),d7			;steprate, head unload time
		bsr	sendcom
		bmi	floprat2
		moveq	#hlt*2+1,d7 			;head load time, non dma
		bsr	sendcom
floprat2:	ext.l	D0
		rts
steptab:	dc.b 	hut/8+$40,hut/8+$20,hut/8+$C0,hut/8+$a0
;                       6         7         2         3 ms   steprate
;**************************************** restore Kopf auf Track 0 positionieren S.121	---
restore:	moveq	#$03,d7			;specify
		bsr	sendcom			;send command
		bmi	end_err
		lea	steptab(pc),a2          ;seekrate wandeln
		move.w	skrate(a1),d7
		and.w	#3,d7
		move.b  0(a2,d7.w),d7           ;steprate und head unload time
;		move.b	#$af,d7			;steprate immer 3ms und 120ms head unload time
		bsr	sendcom
		bmi	end_err
		moveq	#hlt*2+1,d7		;head load time, non dma
                bsr	sendcom
                bmi	end_err
;recalibrate
		moveq	#$07,D7			;*FDC Kommando "recalibrate"
		bsr	sendcom
		bmi	end_err
		move.w	cdevno.w,d7             ;laufwerksnummer
		bsr	sendcom
		bmi	end_err
;int status
		bsr	int_status		;interrupt status erfragen
		bmi	end_err
		move.b  status_buffer.w,d0
		and.b	#$e0,d0
		cmp.b	#$20,d0			;ok?
                bne	end_err         	;nein->
		bra	end_ok

;--------------------------------- laufwerk interrupt status erfragen
int_status:	bsr	wait_int		;auf interrupt warten
		bmi	end_err
		moveq	#$08,d7			;sense interrupt status
		bsr	sendcom
		bmi	end_err
		moveq	#1,d3   		;2 byts holen
		bsr	holdata
		bmi	end_err
		moveq	#0,d0
		move.b  status_buffer+1.w,d0
		move.w	d0,curtrk(a1)		;aktueller track setzen
		rts

;--------------------------------- sende daten in d7 nach fdc
sendcom:	move.l	xhz_200.w,d6
		add.l	#100,d6                 ;0.5 sec
		bsr	wait_mast
sdloop:		cmp.l	xhz_200.w,d6		;zeit abgelaufen?
		bcs	end_err			;ja
                move.b	main_status,d0		;status
                and.b   #$e0,d0			;maske
                cmp.b	#$80,d0			;bereit
                bne	sdloop          	;nein->
		move.b	d7,data_reg
		bra	end_ok
;--------------------------------- status holen anzahl byts in d3
holdata:	lea	status_buffer.w,a2     	;
holdatl:	move.l	xhz_200.w,d6
 		add.l	#100,d6                 ;0.5 sec
		bsr	wait_mast
hdloop:		cmp.l	xhz_200.w,d6
		bcs	end_err			;wenn zeit abgelaufen->
		move.b	main_status,d0
		and.b	#$e0,d0			;maske
		cmp.b	#$e0,d0			;daten?
		beq	holdat2			;ja->
		cmp.b	#$c0,d0			;status bereit?
		bne	hdloop			;nein->
		move.b	data_reg,(a2)+		;statusdaten holen
		bsr	wait_mast
		dbf	d3,hdloop
		bra 	end_ok
holdat2:	move.b	data_reg,d0             ;leeren
		bsr	wait_mast
		bra	hdloop
;--------------------------------- wait auf interrupt
wait_int:	move.l	xhz_200.w,d6
		add.l	#200,d6			;1 sec warten
wait_int1:      cmp.l	xhz_200.w,d6            ;zeit abgelaufen?
                bcs	end_err			;ja->
		btst	#4,gpip.w		;int?
                beq	wait_int1		;nein nochmal->
end_ok:		moveq	#0,d0			;kein fehler
                rts				;zurÅck
;-----------------------------------wait bis master status register valid
wait_mast:	moveq	#48,d0             	; --     -- ED=6us HD=12us DD=24us
		cmp.b	#dd,hdinfo+1(a1)	;dd?
		beq	wait_mastl              ;ja->
		moveq	#12,d0
		cmp.b   #ed,hdinfo+1(a1)	;ed?
		beq	wait_mastl              ;ja->
wait6us:	moveq	#24,d0                  ;sonst dd
wait_mastl:	tst.b	$fffffc00.w             ;dauert 0.5us wenn folgend
		dbf	d0,wait_mastl
fdc_res_rts:	rts
;************************************ fdc_reset
fdc_reset:	lea	changeold.w,a0		;status auf diskette gewechselt
		add.w	cdevno.w,a0
		move.b	#-1,(a0)
		lea	changenew.w,a0
		add.w	cdevno.w,a0
		move.b	#-1,(a0)
		move.w	#defhdinf,hdinfo(a1)          ;hdinfo auf default
		btst	#4,gpip.w
		beq	fdc_res1
		bsr	int_status
fdc_res1:	bsr	wait_mast
		cmp.b	#$80,main_status
		beq	fdc_res_rts
		moveq	#6,d3
		bsr	holdata
		bsr	wait_mast
		cmp.b	#$80,main_status
		beq	fdc_res_rts
		move.b	#$0A,ldor		;softreset, irq aktiv
		move.l	xhz_200.w,d6
		add.l	#40,d6			;0.2 sec
fdc_res2:       cmp.l	xhz_200.w,d6            ;zeit abgelaufen
                bcc	fdc_res2                ;nein->
		move.b  #$0E,ldor
		clr.b	moton        	 	;motor ist aus
		bra	int_status
;***************************** select taktrate  Laufwerk motor on
select0:	move.b	hdinfo+1(a1),ldcr	;takt setzen
		move.w	cdevno.w,D0           	;laufwerk nummer
		add.b	#$3C,d0               	;motoren on kein softreset
		move.b  d0,ldor			;setzen
                tst.b	moton.w
                bne	select0_rts		;ja
                move.l	xhz_200.w,d6
                add.l	#100,d6                	;0.5 sec
sel1:		cmp.l	xhz_200.w,d6            ;abgelaufen
		bcc	sel1                    ;nein->
                bsr	restore			;zum anfang
		move.b	#1,moton.w              ;moton on
select0_rts:    rts
;***************************************** flopvbl Floppy VBL-Handler S.118	***
;		PART 'flopvbl'
flopvbl:	tst.w	xnflops.w
		beq	vbl_rts
		tst.w	flock.w			;aktiv?
		bne	vbl_rts			;ja->
;------------------------------------------ test auf diskettenwechsel Åber wp
		move.l	xfrclock.w,D1
		move.b	D1,D0
		and.b	#7,D0                   ;8. vbl ?
		bne.s	vbl_rts                 ;nein -> 
;-------------------------------------------------
		lsr.b	#3,D1                           ;
		and.w	#1,D1				;abwechslungsweise Laufwerk A: oder B: 0 or 1
		lea	changenew.w,A0
		add.w	D1,A0                           ;floppy A byt 0. floppy B byt 1
		cmp.w	xnflops.w,D1                    ;floppy B und vorhanden? wenn nur 1 und ist 1 (nur lw A)
		bne.s	vbl1                            ;nein -> lw B vorhanden
		clr.w	D1                              ;sonst lw A
;-------------------------------------------------
vbl1:		lea	dsb0.w,a1
                tst.b	d1				;lw B
                beq	vbl3
                lea	dsb1.w,a1
vbl3:		move.b	#$3c,d6
		add.w	d1,d6                           ;+lw
		move.b	d6,ldor				;floppy on
		moveq	#4,d7				;sense drive status
		bsr	sendcom
		move.w	d1,d7                           ;lw
		bsr	sendcom
		moveq	#0,d3				;1 byt holen
		bsr	holdata
		btst	#6,status_buffer.w		;H=SchreibgeschÅtzt
                sne	(a0)                            ;changenew setzen
                beq	vbl2                            ;nicht gewechselt resp. nicht wp
		move.w	#defhdinf,hdinfo(a1)          	;hdinfo auf default
;-------------------------------------------------
vbl2:		move.w	changenew.w,D0                  ;
		or.w	D0,changeold.w         		;wenn gewechselt auf gewechselt oder halten
                tst.b	moton.w                         ;motor on?
                beq	vbl4                            ;nein
;------------------------------------------------- motor abstellen ?
		move.l	xhz_200.w,D0
		cmp.l	deseltime,D0			;.w wÑhrend Nachlaufzeit	...
		bcs.s	vbl5	                         ;nein nicht abstellen
;-------------------------------------------------
vbl4:		move.b  #$0E,ldor			;alle LW abschalten
		clr.b	moton.w
vbl_rts:	rts
vbl5:		move.b	#$3e,ldor
		rts
;********************************* seek_cur	 aktuellen Track anfahren S.120	***
;		PART 'flopseek'
;-------------------------------------------- homeseek	Home und Seek S.120	---
homeseek:	move.w	#-6,cerror.w
		bra	restore
;---------------------------- seek_ver	aktuellen Track	anfahren mit Verify	---
seek_ver:	move.w	#-6,cerror.w
;-------------------------------------------------
		moveq	#$0f,d7                  	;seek
		bsr	sendcom
		bmi	end_err
		move.w	csideno.w,d7                    ;side
		lsl.w	#2,d7                           ;nach bit 2
		add.w	cdevno.w,d7                     ;+lw nr.
		bsr	sendcom
		bmi	end_err
		move.w	ctrackno.w,D7                   ;track
		bsr	sendcom
		bmi	end_err
                bsr	int_status
                bmi	end_err
		move.w	ctrackno.w,d0                   ;soll
		cmp.w	curtrk(A1),d0		 	;richtig?
		beq	end_ok
		bra	end_err
;**********************************	change	Test auf Diskettenwechsel bei einem lw S.123	***
change:		cmp.w	#1,xnflops.w
		bne.s	chg_rts

		move.w	16(A7),D0			;cdevno vom Stack
		cmp.w	log_dev.w,d0               	;lw gewechselt?
		beq.s	change1                       	;nein->

		move.w	D0,-(A7)
		move.w	#-17,-(A7)
		jsr	xetv_crit			;*jsr
		addq.w	#4,A7

		lea	lastuseda.w,A0
		clr.l	(A0)+
		clr.l	(A0)
		move.w	16(A7),log_dev.w		;neues logisches LW
                
change1:	clr.w	16(A7)				;drive nummer auf LW A:
chg_rts:	rts
;--------------------------------- setdmode	 Drive Change Mode setzen S.123	---
setdmode:	lea	chg_mode.w,A0
		move.b	D0,-(A7)
		move.w	cdevno.w,D0
		cmp.w	#1,xnflops.w
		bne.s	setdmod1

		move.w	log_dev.w,D0
setdmod1:	move.b	(A7)+,0(A0,D0.w)
		rts
;**************************************************** Xbios(8,9,19) Floprd,Flopwr,Flopver S.113	***
;------------------------------------------------- daten transfer VOM fdc
fdc_rdint:      bclr	#6,$fffffa89.w                  ;int off
		movem.l	a0/d0-d1,-(sp)                  ;register sichern
                move.l	cbuffer.w,a0                    ;transferadresse
                move.w	#512,d0                         ;1 sector a 512 byts
fdc_rdint2:	btst	#5,main_status			;daten?
                beq	fdc_rdint1			;nein -> ende daten oder error
                move.b	data_reg,(a0)+			;daten transportieren
		subq.w	#1,d0                           ;-1
		beq	fdc_rdint1                      ;wenn 0 dann ende
		moveq	#100,d1                         ;timeout 50us
fdc_rdint3:	btst	#4,gpip.w                       ;int?
		bne	fdc_rdint2                      ;ja->
                tst.b	$fffffc00.w			;0.5us warten
                subq.w	#1,d1                           ;abgelaufen
                bpl	fdc_rdint3                      ;nein->
fdc_rdint1:	move.l	a0,cbuffer.w
		movem.l (sp)+,a0/d0-d1
		rte
;------------------------------------------------- daten transfer ZUM fdc
fdc_wrint:      bclr	#6,$fffffa89.w                  ;int off
		movem.l	a0/d0-d1,-(sp)                  ;register sichern
                move.l	cbuffer.w,a0
                move.w	#512,d0                         ;1 sector a 512 byts
fdc_wrint2:	btst	#5,main_status			;daten?
                beq	fdc_wrint1			;nein -> ende daten oder error
                move.b	(a0)+,data_reg			;daten transportieren
		subq.w	#1,d0                           ;-1
		beq	fdc_wrint1                      ;wenn 0 dann ende
		moveq	#100,d1                         ;timeout 50us
fdc_wrint3:	btst	#4,gpip.w                       ;int?
		bne	fdc_wrint2                      ;ja->
                tst.b	$fffffc00.w			;0.5us warten
                subq.w	#1,d1                           ;abgelaufen
                bpl	fdc_wrint3                      ;nein->
fdc_wrint1:	move.l	a0,cbuffer.w
		movem.l (sp)+,a0/d0-d1
		rte
;------------------------------------------------- daten transfer per interrupt VOM fdc fÅr verify
fdc_vrint:      bclr	#6,$fffffa89.w                  ;int off
		movem.l	a0/d0-d2,-(sp)                  ;register sichern
                move.l	cbuffer.w,a0
                move.w	#512,d0                         ;1 sector a 512 byts
fdc_vrint2:	btst	#5,main_status			;daten?
                beq	fdc_vrint1			;nein -> ende daten oder error
                move.b	data_reg,d2			;daten holen
		cmp.b	(a0)+,d2			;daten vergleichen
		beq	fdc_vrint4                      ;ok gleich->
		move.b	#2,rwflag+1.w                   ;sonst fehler setzen
fdc_vrint4:	subq.w	#1,d0                           ;-1
		beq	fdc_vrint1                      ;wenn 0 dann ende
		moveq	#100,d1                         ;timeout 50us
fdc_vrint3:	btst	#4,gpip.w                       ;int?
		bne	fdc_vrint2                      ;ja->
                tst.b	$fffffc00.w			;0.5us warten
                subq.w	#1,d1                           ;abgelaufen
                bpl	fdc_vrint3                      ;nein->
fdc_vrint1:	move.l	a0,cbuffer.w
		movem.l (sp)+,a0/d0-d2
		rte
;-----------------------------------------------------------------------------------------
floprd:		clr.w	rwflag.w			;auf lesen
		move.l	#fdc_rdint,$158.w		;vector setzen

floprdwr:	tst.w	xnflops.w
		beq.s	no_flops
                
		bsr	change
		move.w	#-11,cerror.w
floprd11:	bsr	floplock
                tst.b	rwflag.w			;write
                beq	floprd1                         ;nein->
;-------------------------------------------------  nur write
		move.w	csecno.w,D0			;Zugriff auf Boosektor?
		subq.w	#1,D0
		or.w	ctrackno.w,D0
		or.w	csideno.w,D0
		bne.s	floprd13
		moveq	#2,D0
		bsr	setdmode			;...dann chg_mode[dev]=2
floprd13:	move.w	#-10,cerror.w
;-------------------------------------------------

floprd1:	bsr	select0
		bsr	seek_ver
		bmi	floprd6				;error -> end evt. nochmal

;------------------------------------------------- floppy read,write,scan commando
;init int
floprd2:	move.l	cbuffer.w,d5                    ;start sichern
		bset	#4,$fffffa83.w			;int bei low to high
		bclr	#6,$fffffa8d.w			;interrupt pending lîschen
		bclr	#6,$fffffa91.w                  ;in service lîschen
		bset	#6,$fffffa95.w                  ;maske freigeben -> interrupt
		bset	#6,$fffffa89.w			;int enable
;-----------------------------------------------------		
                moveq	#$46,d7				;mfm read sectoren
                sub.b	rwflag.w,d7                     ;$45 fÅr write
	   	bsr	sendcom
                move.w	csideno.w,d7            	;seite
                move.w	d7,d1
                lsl.w	#2,d7                   	;nach bit 2
                add.w	cdevno.w,d7             	;lw nr
                bsr	sendcom
                move.w	ctrackno.w,d7			;tracknummer
                bsr	sendcom
                move.w	d1,d7				;nochmal seite
                bsr	sendcom
                move.w  csecno.w,d7			;secktor nr.
                move.w	d7,d1
                bsr	sendcom
                moveq	#2,d7				;512 byt sektoren
                bsr	sendcom
                move.w	d1,d7				;eot=gleicher sector
                bsr	sendcom
                moveq	#$1B,d7				;gap length
                bsr	sendcom
                moveq	#-1,d7                  	;data length not valid
		bsr	sendcom
		move.l	xhz_200.w,d6
                add.l	#300,d6				;1.5 sec warten
floprd3:	cmp.l	xhz_200.w,d6                    ;abgelaufen?
		bcs	floprd4
                btst	#6,$fffffa89.w			;int off? = kommando ende
                bne	floprd3                         ;nein
floprd4:	bclr	#6,$fffffa89.w                  ;int disable
;-------------------------------------------------------
	        moveq	#6,d3                           ;7 byt status lesen
                bsr	holdata
                bmi	flopfail
;-------------------------------------------------
		move.b	status_buffer+1.w,d0		;FDC Status register 1
		and.b	#$37,d0                         ;relevante bits
		bne.s	floprd5                 	;wenn nicht null dann error
		tst.b	rwflag+1.w			;verify?
		bne	floprd8				;nein->
		tst.w	verifyflag.w			;setortest?
		beq	floprd8				;ja->
		cmp.b	#1,rwflag+1.w			;daten gleich ?
		bne	floprd5                         ;nein ->
;-------------------------------------------------
floprd8:	move.w	#2,retry.w			;3 versuch
		addq.w	#1,csecno.w                     ;nÑchster sector
		subq.w	#1,ccount.w                     ;anzahl -1
		bne	floprd2
		tst.b	rwflag+1.w			;verify?
		beq	flopok                          ;nein->
		tst.w	verifyflag.w			;sectortest
		bne	flopok				;nein->
		clr.w	(a3)                            ;def. sector abschluss
		bra	flopok				;fertig
;-------------------------------------------------
floprd5:	move.l	d5,cbuffer.w			;alter start
		cmp.w	#1,retry.w			;2.versuch
		bne	floprd9				;nein->
		cmp.w	csecno.w,d4			;startsector?
		bne	floprd9				;nein->
		tst.b	rwflag.w			;read?
		bne	floprd9				;nein->
		tst.b	hdinfo(a1)			;versuchszÑhler = 0
		beq	floprd9                         ;ja->
		subq.b	#1,hdinfo(a1)			;1 versuche weniger
		move.w	#2,retry.w                      ;retry wieder auf 2
		cmp.b	#ed,hdinfo+1(a1)		;ed?
		bne	noed                            ;nein->
		move.b	#hd,hdinfo+1(a1)		;ist ed weiter nach hd
		bra	floprd12
noed:		cmp.b	#dd,hdinfo+1(a1)		;dd?
		bne	nodd                            ;nein
		move.b	#ed,hdinfo+1(a1)		;ist dd weiter nach ed
		bra	floprd12
nodd:		move.b	#dd,hdinfo+1(a1)		;bleibt noch dd
floprd12:	move.b	hdinfo+1,ldcr			;takt setzen THO: BUG: (a1) missing
		bsr	restore                         ;alles auf anfang
		bra	floprd1				;mit andererm takt probieren
floprd9:	bsr.s	errbits				;Fehlerbehandlung
floprd6:	cmp.w	#1,retry.w
		bne.s	floprd7
		bsr	homeseek
floprd7:	subq.w	#1,retry.w
		bpl	floprd2				;nochmal versuchen
		tst.b	rwflag+1.w			;verify?
		beq	flopfail			;nein->
		tst.w	verifyflag.w			;sectortest?
		bne	flopfail			;nein-> error end
		move.w	csecno.w,(a3)+                  ;defekter sector eintragen
		bra	floprd8				;und nÑchster
;************************************ errbits  Fehlernummer bestimmen S.114	***
errbits:	moveq	#-13,D1               		;write protect
		btst	#1,d0
		bne.s	errbits1

		moveq	#-8,D1                		;sektor error
		btst	#0,d0			
		bne.s	errbits1

		moveq	#-6,D1                		;seek error
		btst	#1,status_buffer+2.w		;st2
		bne.s	errbits1

		moveq	#-4,D1                		;crc error
		btst	#5,D0
		bne.s	errbits1

		moveq	#-2,D1  			;timeout
		btst	#4,D0                
		bne.s	errbits1

		move.w	def_err.w,D1
errbits1:	move.w	D1,cerror.w
		rts
;**************************************************** Xbios(9) Flopwr S.114	***
;		PART 'flopwr'
flopwr:		move.w	#$100,rwflag.w
		move.l	#fdc_wrint,$158.w		;vector setzen
		bra	floprdwr
;**************************************************	Xbios(19) Flopver S.117	***
;		PART 'flopver'
flopver:	move.w	#1,rwflag.w                   	;read zum verify
		move.l	#fdc_vrint,$158.w		;vector setzen
		bra	floprdwr
;======================================================================================== hades end

;**************************************************	Xbios(10) Flopfmt S.115	***
;		PART 'flopfmt'
flopfmt:	cmp.l	#-$789ABCDF,22(A7)
		bne	flopfail

		tst.w	xnflops			;.w
		beq	no_flops

		bsr	change
		bsr	floplock

		move.w  14(a7),cspt.w                   ;anzahl sectoren
		move.l	8(A7),cfiller.w                	;sectortabelle
		move.w	20(A7),cinterlv.w               ;sectortabelle vorhanden?
		bmi	fmt31                           ;ja
;---------------------------------------------- sectorreihenfolge in tabelle erzeugen
;d0 = anzahl sectoren. d1 = standort im buffer. d2 = interleave. d3 = schleifenzÑhler. d4 = momentane sectornummer.
		moveq	#1,d4
		moveq	#0,d1                           ;1. tabellenplatz
		move.w	cspt.w,d0                       ;anzahl sectoren
		move.w	d0,d3                           ;nach d3 als zÑhler
fmt24:		clr.b	0(a3,d3.w)                      ;sectortabelle lîschen
		dbf	d3,fmt24
		move.w	d0,d3
		move.w	cinterlv.w,d2
		subq.w	#2,d3				;-1 umlauf (resp. 2 wegen dbf)
		move.b	d4,(a3)				;1. sector
fmt22:		add.w	d2,d1
		cmp.w	d1,d0                           ;grîsser oder gleich max
		bge	fmt23				;nein->
		sub.w	d0,d1
fmt23:		addq.w	#1,d4                           ;nÑchster sector
fmt26:		tst.b	0(a3,d1.w)			;frei?
		beq	fmt25
		addq.w	#1,d1				;sonst next
		bra	fmt26
fmt25:		move.b	d4,0(a3,d1.w)			;eintragen
		dbf	d3,fmt22			;next bis ende
		moveq	#40,d3				;rest fÅllen
fmt27:		addq.w	#1,d4                           ;nÑchste sectornummer
		addq.w	#1,d1                           ;nÑchster platz
		move.b	d4,0(a3,d1.w)                   ;eintragen
		dbf	d3,fmt27
;-----------------------------------------------
fmt21:		move.w	26(A7),cvirgin.w  		;datenwert
		moveq	#2,D0
		bsr	setdmode
		moveq	#-1,D0
;-------------------------------------------------
		moveq	#dd,D0
		cmp.w	#12,cspt.w			;DD?
		blt	fmt1                      	;ja->
		moveq	#ed,d0
		cmp.w	#24,cspt.w			;ed?
		bgt     fmt1                            ;ja
		moveq	#hd,D0
;-------------------------------------------------
fmt1:		move.w	D0,hdinfo(A1)			;dsb.hdinfo setzen
		bsr	select0
fmt6:		move.w	#1,csecno.w			;startsector auf 1
		bsr	seek_ver
		move.w	#-1,cerror.w
;init int
                move.l	#fdc_format,$158.w		;vector setzen
		bset	#4,$fffffa83.w			;int bei low to high
		bclr	#6,$fffffa8d.w			;interrupt pending lîschen
		bclr	#6,$fffffa91.w                  ;in service lîschen
		bset	#6,$fffffa95.w                  ;maske freigeben -> interrupt
		bset	#6,$fffffa89.w			;int enable
;-----------------------------------------------------		
                moveq	#$4D,d7				;mfm format track
		bsr	sendcom
                move.w	csideno.w,d7            	;seite
                lsl.w	#2,d7                   	;nach bit 2
                add.w	cdevno.w,d7             	;lw nr
                bsr	sendcom
                moveq	#2,d7				;512 byt sektoren
                bsr	sendcom
                move.w  cspt.w,d7			;anzahl sectoren
                bsr	sendcom
                moveq	#$54,d7				;gap length
                bsr	sendcom
                move.b	cvirgin.w,d7			;datawert
		bsr	sendcom
		move.l	xhz_200.w,d6
                add.l	#300,d6				;1.5 sec warten
fmt2:		cmp.l	xhz_200.w,d6                    ;abgelaufen?
		bcs	fmt3
		btst	#6,$fffffa89.w			;fertig?
		bne	fmt2				;nein
;----------------------------------------------------------
fmt3:	        bclr	#6,$fffffa89.w			;int off
		moveq	#6,d3                           ;7 byt status lesen
                bsr	holdata
                bmi	flopfail
;-------------------------------------------------
		move.b	status_buffer+1.w,d0		;FDC Status register 1
		and.b	#$37,d0                         ;relevante bits
		bne.s	fmt5	                 	;wenn nicht null dann error
;------------------------------------------------- sectortest ausfÅhren
fmt8: 	        clr.w	(a3)				;keine def. sectoren
		tst.w	$444.w				;verfiy?
		beq	flopok                          ;nein->
                move.l	a3,cbuffer.w			;bufferzeiger auf anfang
		move.w	#1,csecno.w                     ;beginnen bei sector 1
		move.w	cspt.w,ccount.w                 ;alle sectoren prÅfen
		clr.w	verifyflag.w			;sectortest
		move.w	#2,retry.w			;3 Versuche
		move.w	#1,rwflag.w                   	;read zum verify
		move.l	#fdc_vrint,$158.w		;vector setzen
		bra	floprd2
;-------------------------------------------------
fmt5:		bsr.s	errbits				;Fehlerbehandlung
		cmp.w	#1,retry.w
		bne.s	fmt7
		bsr	homeseek
fmt7:		subq.w	#1,retry.w
		bpl	fmt6				;nochmal versuchen
		bra  	flopfail
		rts
;------------------------------------------------------------ sectortabelle Åbertragen
fmt31:		move.w	cspt.w,d0                       ;anzahl sectoren
		move.w	d0,d2
		move.l	cfiller.w,a0                    ;tabelle
		move.l	a3,a2                           ;bufferadresse
		subq.w	#1,d0                           ;-1 wegen dbf
fmt32:		move.w	(a0)+,d1                        ;sectornr. als word holen
		move.b	d1,(a2)+                        ;und als byt speichern
		dbf	d0,fmt32                        ;wiederholen bis fertig
		move.w	#40,d0                          ;rest fÅllen
fmt33:		addq.w	#1,d2
		move.b	d2,(a2)+                        ;eintragen
		dbf	d0,fmt33                        ;bis fertig
		bra	fmt21                           ;weiter
;----------------------------------------------- format int
fdc_format:	movem.l	d0-d1/a0,-(sp)                  ;register retten
		bclr	#6,$fffffa89.w			;int off
		move.l	cbuffer.w,a0                    ;bufferregister holen
		move.w	cspt.w,d0			;anzahl sectoren
		subq.w	#1,d0				;-1 wegen dbf
		btst	#5,main_status                  ;daten?
		beq	form2                           ;nein -> fertig
		bra	form3
form1:		bsr	formintwaitb
		bmi	form2				;error
form3:		move.b	ctrackno+1.w,data_reg		;track nummer
		bsr	formintwait                     ;wait auf int
		bmi	form2                           ;error->
		move.b	csideno+1.w,data_reg		;seite
                bsr	formintwait
                bmi	form2                           ;error
		move.b	(a0)+,data_reg			;sector nummer
                bsr	formintwait
                bmi	form2                           ;error
		move.b	#2,data_reg			;512 byt sectoren
                dbf	d0,form1                        ;wiederholen bis fertig
form2:		move.l	a0,cbuffer.w                    ;bufferregister zurÅck
		movem.l	(sp)+,d0-d1/a0			;register zurÅck
		rte
;-----------------------------------------------------------------------
formintwaitb:	move.l	#100000,d1                      ;timeout 50ms
		bra	formintwait1			
formintwait:	moveq	#100,d1                         ;timeout 50us
formintwait1:	btst	#4,gpip.w                       ;int?
		bne	formintwait2                    ;ja->
		tst.b	$fffffc00.w			;0.5us warten
                subq.l	#1,d1                           ;abgelaufen
                bpl	formintwait1                    ;nein->
		rts
formintwait2:   btst	#5,main_status			;daten?
                bne	formintwait3			;ja
                moveq	#-1,d1                          ;sonst error
		rts
formintwait3:   moveq	#0,d1                           ;ok
		rts
;**************************************************** Beginn der C-Routinen	***

		blk.b $7fe045d8+lang_dif-*,$ff

;_bios1
		org  $7fe0565c+lang_dif
		load   $30565c+lang_dif
		LINK	A6,#0 
		MOVEM.L	A4-A5/D6-D7,-(A7) 
		MOVE.W	#$77AA,A5 
		MOVE.W	8(A6),D0
		BEQ.S	B1000 
		ADD.W	#$24,A5	
		SUBQ.W	#1,D0 
		BNE.S	B1003 
B1000:		MOVE.L	A5,A4 
B1001:		MOVE.W	#6,-(A7)
		CLR.L	-(A7) 
		MOVE.W	#1,-(A7)
		MOVE.W	8(A6),-(A7)	
		CLR.L	-(A7) 
		MOVE.L	$4C6.L,-(A7)
		JSR	floprd	
		LEA	$12(A7),A7
		TST.L	D0
		BGE.S	B1002 
		MOVE.W	8(A6),-(A7)	
		MOVE.W	D0,-(A7)
		JSR	xetv_crit	
		ADDQ.L	#4,A7 
B1002:		CMP.L	#$10000,D0
		BEQ.S	B1001 
		TST.L	D0
		BMI.S	B1003 
		MOVE.L	$4C6.L,A0 
		MOVE.B	$C(A0),D0 
		ASL.W	#8,D0 
		MOVE.B	$B(A0),D0 
		MOVE.W	D0,D7 
		BLE.S	B1003 
		CLR.W	D6
		MOVE.B	$D(A0),D6 
		BNE.S	B1004 
B1003:		CLR.L	D0
		BRA	B100D 
B1004:		MOVE.W	D7,(A4)	
		MOVE.W	D6,2(A4)
		MOVE.B	$17(A0),D0
		ASL.W	#8,D0 
		MOVE.B	$16(A0),D0
		MOVE.W	D0,8(A4)
		CLR.W	D7
		CMP.B	#2,$10(A0)
		BCC.S	B1005 
		CLR.W	D0
		OR.W	#2,D7 
B1005:		MOVE.W	D7,$10(A4)
		ADDQ.W	#1,D0 
		MOVE.W	D0,$A(A4) 
		MOVE.W	(A4),D0	
		MULS	2(A4),D0
		MOVE.W	D0,4(A4)
		MOVE.B	$12(A0),D0
		ASL.W	#8,D0 
		MOVE.B	$11(A0),D0
		ASL.W	#5,D0 
		EXT.L	D0
		DIVS	(A4),D0	
		MOVE.W	D0,6(A4)
		MOVE.W	$A(A4),D0 
		ADD.W	6(A4),D0
		ADD.W	8(A4),D0
		MOVE.W	D0,$C(A4) 
		MOVE.B	$14(A0),D0
		ASL.W	#8,D0 
		MOVE.B	$13(A0),D0
		SUB.W	$C(A4),D0 
		EXT.L	D0
		DIVS	2(A4),D0
		MOVE.W	D0,$E(A4) 
		CMP.W	#$FEE,D0
		BLS.S	B1006 
		OR.W	#1,$10(A4)
B1006:		MOVE.B	$1B(A0),D0
		ASL.W	#8,D0 
		MOVE.B	$1A(A0),D0
		MOVE.W	D0,$14(A5)
		MOVE.B	$19(A0),D0
		ASL.W	#8,D0 
		MOVE.B	$18(A0),D0
		MOVE.W	D0,$18(A5)
		MULS	$14(A5),D0
		MOVE.W	D0,$16(A5)
		MOVE.B	$1D(A0),D0
		ASL.W	#8,D0 
		MOVE.B	$1C(A0),D0
		MOVE.W	D0,$1A(A5)
		MOVE.B	$14(A0),D0
		ASL.W	#8,D0 
		MOVE.B	$13(A0),D0
		EXT.L	D0
		DIVS	$16(A5),D0
		MOVE.W	D0,$12(A5)
		MOVEQ	#2,D7 
B1007:		MOVE.B	8(A0,D7.W),$1C(A5,D7.W)	
		DBF	D7,B1007
		MOVEQ	#3,D7 
B1008:		MOVE.B	$27(A0,D7.W),$1F(A5,D7.W) 
		DBF	D7,B1008
		MOVE.W	#$7350,A1 
		TST.W	8(A6) 
		BEQ.S	B1009 
		ADD.W	#$C,A1
B1009:		MOVEQ	#5,D7 
B100A:		CLR.W	D0
		MOVE.W	#$FF,D6	
B100B:		ADD.W	(A0)+,D0
		DBF	D6,B100B
		MOVE.W	D0,(A1)+
		DBF	D7,B100A
		MOVE.W	8(A6),D7                ;lw nr.
		lea	changeold.w,A0 
		lea	changenew.w,A1 
		CLR.l	D0                      ;default not change
		MOVE.B	0(A1,D7.W),0(A0,D7.W) 	;new->old
		BEQ.S	B100C                   ;nicht null = change??
		MOVEQ	#1,D0                   ;disk gewechselt
B100C:		lea	chg_mode.w,A1 
		MOVE.B	D0,0(A1,D7.W)		;changemode setzen 
		MOVE.L	A4,D0 
B100D:		MOVEM.L	(A7)+,A4-A5/D6-D7 
		UNLK	A6
		RTS 
		blk.b	$7fe058ae+lang_dif-*,$ff		

;_bios floppy write
		org  $7fe05b1e+lang_dif
		load   $305b1e+lang_dif
		LINK	A6,#$FFF4 
		MOVEM.L	A5/D2-D7,-(A7)
		MOVE.W	#$77AA,A5 
		TST.W	$10(A6) 
		BEQ.S	B2000 
		ADD.W	#$24,A5 
B2000:		CLR.W	D0
;		BTST	#0,$D(A6) 
;		BEQ.S	B2001 
;		MOVEQ	#1,D0 
B2001:		MOVE.W	D0,-2(A6) 
		TST.W	$16(A5) 
		BNE.S	B2002 
		MOVEQ	#9,D0 
		MOVE.W	D0,$16(A5)
		MOVE.W	D0,$18(A5)
B2002:		BRA	B2013 
B2003:		MOVE.L	$A(A6),D0 
		TST.W	-2(A6)
		BEQ.S	B2004 
		MOVE.L	$4C6.L,D0 
B2004:		MOVE.L	D0,-6(A6) 
		MOVE.W	$E(A6),D6 
		EXT.L	D6
		DIVS	$16(A5),D6
		MOVE.W	$E(A6),D4 
		EXT.L	D4
		DIVS	$16(A5),D4
		SWAP	D4
		CLR.W	D5
		CMP.W	$18(A5),D4
		BCS.S	B2005 
		MOVEQ	#1,D5 
		SUB.W	$18(A5),D4
B2005:		MOVEQ	#1,D3 
		TST.W	-2(A6)
		BNE.S	B2007 
		MOVE.W	$18(A5),D0
		SUB.W	D4,D0 
		CMP.W	$12(A6),D0
		BGE.S	B2006 
		MOVE.W	$18(A5),D3
		SUB.W	D4,D3 
		BRA.S	B2007 
B2006:		MOVE.W	$12(A6),D3
B2007:		TST.W	-2(A6)
		BEQ.S	B2008 
		MOVE.L	-6(A6),-(A7) 
		MOVE.L	$A(A6),-(A7)
		JSR	$7FE012FE 
		ADDQ.L	#8,A7 
B2008:		BTST	#0,9(A6)
		BEQ.S	B200D 
		MOVE.W	D6,D0 
		OR.W	D5,D0 
		BNE.S	B200D 
		CMP.W	#6,D4 
		BCC.S	B200D 
		MOVEM.L	A5/D6-D7,-(A7)
		MOVE.W	D4,D0 
		ASL.W	#1,D0 
		MOVE.W	#$7350,A5 
		TST.W	$10(A6) 
		BEQ.S	B2009 
		ADD.W	#$C,A5
B2009:		ADD.W	D0,A5 
		MOVEQ	#6,D7 
		SUB.W	D4,D7 
		CMP.W	D3,D7 
		BCS.S	B200A 
		MOVE.W	D3,D7 
B200A:		SUBQ.W	#1,D7 
		MOVE.L	-6(A6),A0 
B200B:		MOVE.W	#$FF,D6 
		CLR.W	D0
B200C:		ADD.W	(A0)+,D0
		DBF	D6,B200C
		MOVE.W	D0,(A5)+
		DBF	D7,B200B
		MOVEM.L	(A7)+,A5/D6-D7
B200D:		ADDQ.W	#1,D4 
B200E:		BTST	#0,9(A6)
		BEQ.S	B2010 
		MOVE.W	D3,(A7) 
		MOVE.W	D5,-(A7)
		MOVE.W	D6,-(A7)
		MOVE.W	D4,-(A7)
		MOVE.W	$10(A6),-(A7) 
		CLR.L	-(A7) 
		MOVE.L	-6(A6),-(A7)
		JSR	flopwr 
		LEA	16(A7),A7
		MOVE.L	D0,D7 
		BNE.S	B2011 
		TST.W	$444.L
		BEQ.S	B2011 
		MOVE.W	D3,(A7) 
		MOVE.W	D5,-(A7)
		MOVE.W	D6,-(A7)
		MOVE.W	D4,-(A7)
		MOVE.W	$10(A6),-(A7) 
		move.w	#-1,-(a7)		;verify
		clr.w	-(a7)                   ;
		MOVE.L	-6(a6),-(A7)
		JSR	flopver 
		LEA	16(A7),A7
		MOVE.L	D0,D7 
		BRA.S	B2011 
B2010:		MOVE.W	D3,(A7) 
		MOVE.W	D5,-(A7)
		MOVE.W	D6,-(A7)
		MOVE.W	D4,-(A7)
		MOVE.W	$10(A6),-(A7) 
		CLR.L	-(A7) 
		MOVE.L	-6(A6),-(A7)
		JSR	floprd 
		LEA	16(A7),A7
		MOVE.L	D0,D7 
		TST.W	-2(A6)
		BEQ.S	B2011 
		MOVE.L	$A(A6),(A7) 
		MOVE.L	-6(A6),-(A7)
		JSR	$7FE012FE 
		ADDQ.L	#4,A7 
B2011:		TST.L	D7
		BGE.S	B2012 
		MOVE.W	$10(A6),(A7)
		MOVE.L	D7,D0 
		MOVE.W	D0,-(A7)
		JSR	xetv_crit
		ADDQ.L	#2,A7 
		MOVE.L	D0,D7 
		CMP.W	#2,8(A6)
		BGE.S	B2012 
		CMP.L	#$10000,D7
		BNE.S	B2012 
		MOVE.W	$10(A6),(A7)
		JSR	$7FE05918+lang_dif
		CMP.W	#2,D0 
		BNE.S	B2012 
		MOVEQ	#-14,D7 
B2012:		CMP.L	#$10000,D7
		BEQ	B200E 
		MOVE.L	D7,D0 
		BMI.S	B2014 
		MOVE.W	D3,D0 
		EXT.L	D0
		MOVEQ	#9,D1 
		ASL.L	D1,D0 
		ADD.L	D0,$A(A6) 
		ADD.W	D3,$E(A6) 
		SUB.W	D3,$12(A6)
B2013:		TST.W	$12(A6) 
		BNE	B2003 
		CLR.L	D0
B2014:		TST.L	(A7)+ 
		MOVEM.L	(A7)+,A5/D3-D7
		UNLK	A6
		RTS 
		blk.b	$7fe05d2a+lang_dif-*,$ff
;************************************************************************************


;anderer cache wie Atari-TT

		org  $7fe005f2
		load   $3005f2
cache_clear:	dc.w cpusha
		nop
		rts		   
		blk.b $7fe0060a-*,$ff

		org  $7fe008b2
		load   $3008b2
		dc.w	cpusha
		nop
                nop
                nop
                nop

		org  $7fe01990
		load   $301990
		dc.w cpusha
		nop
		bra.s $7fe019a4
		blk.b $7fe019a4-*,$ff

;cache clear (un)nîtig bei dma (bei 60er sicher nîtig)
		org  $7fe01a06
		load   $301a06
		dc.w cpusha
		bra.s $7fe01a1a
		blk.b $7fe01a1a-*,$ff

		org  $7fe07d4e+lang_dif
		load   $307d4e+lang_dif
		dc.w cpusha
		nop
		bra.s $7fe07d5a+lang_dif
		blk.b $7fe07d5a+lang_dif-*,$ff

		org  $7fe0d300+lang_dif
		load   $30d300+lang_dif
		dc.w cpusha
		nop
		bra.s $7fe0d30c+lang_dif
		blk.b $7fe0d30c+lang_dif-*,$ff

;neue buserrorroutine
		org  $7fe0121c
		load   $30121c
		jmp exception

;Platz fÅr neue Programmteile an altem exceptionhandler

cache_aus1:	st 	$43e.w
cache_aus:	move.l 	d0,-(sp)
		dc.w 	movecd,cacr
		move.l 	d0,$e4.w
		moveq 	#0,d0
		dc.w 	movec,cacr
		dc.w 	cpusha
		move.l 	(sp)+,d0
		rts

cache_ein1:	sf 	$43e.w
cache_ein:	move.l 	d0,-(sp)
		move.l 	$e4.w,d0
		dc.w 	movec,cacr
		move.l 	(sp)+,d0
		rts

		blk.b $7fe012fe-*,$ff

;***************************************************
;neuer kaltstart
		org  $7fe0380c+lang_dif
		load   $30380c+lang_dif

kaltstart:	move.w	#$2700,sr
		move.l	#$ffc040,d0	;no cache serialized
 		dc.w	movec,dtt0	;transparent translation daten 0
		move.l	#$7fc000,d0	;write trough
		dc.w	movec,itt0	;transparent translation intstruction 0
		move.l	#$8000,d0	;instruction cache on
                dc.w    movec,cacr      ;cache setzen
		dc.w	cinva		;caches invalid
                moveq   #0,d0
		dc.w	movec,dtt1	;transparent translation daten 1 aus
		dc.w	movec,itt1	;transparent translation instruction 1 aus

		move.l  d0,a0		;beginn loschen =0

                move.l 	#$210,d0
                dc.w 	movec,tc        ;setze no cache, precise fÅr mc68060 (geht auch fÅr mc68040)

		move.w  #$7fff,d0	;1. MB loeschen
loopclr:	clr.l	(a0)+
		clr.l   (a0)+
		clr.l   (a0)+
		clr.l   (a0)+
		clr.l   (a0)+
		clr.l   (a0)+
		clr.l   (a0)+
		clr.l   (a0)+
		dbf	d0,loopclr
		move.l	$7fe00004,a0	;resetvektor holen
		jmp	(a0)
		
		blk.b $7fe0387c+lang_dif-*,$ff

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; .28 
; Der Anhaengsel hinter dem TOS wurde ein wenig weiter nach hinten verlegt
; um auch noch Platz fuer groessere Resourcen (TOS-Patch) und Winx zu haben
		org    $7FE49000
		load   $349000

; Hier erst mal der zweite Teil des Cookie-Setzers

nullframe:	dc.l	0		;statt $FF kann hier auch der Null-Frame hin
morecook:

; .24 .26 .27 .28
; Die naechste grosse Aenderung ist beim _FPU cookie passiert !!!
; Hier wird jetzt nicht mehr nur einfach auf 8=68040 gesetzt, sondern
; 'ganz ordentlich' alles das was bei Atari so dokumentiert ist auch
; geprueft. Dabei gibt es jedoch eine kleine Ausnahme - der 68060 ist
; bei Atari noch nicht bekannt, hierfuer wird Bit 4 im Highword (16)
; gesetzt. Das duerfte der weiteren Nomenklatur entsprechen ...
; Da der _FPU-cookie nun geprueft wird, kann man wohl auch einen
; 68LC040 einsetzen - der meldet als _FPU dann eben 0

		move.l #"_FPU",(a0)+

; Nach Atari Dokumentation ist die Belegung wie folgt:
; _FPU Cookie ist IMMER da !!!
; Belegung im Highword:
;  0 = keine Hardware- FPU
;  1 = Atari Register FPU (memory mapped)  -> wird nicht getestet
;  2 = LineF FPU
;  3 = Atari Register FPU + LineF FPU
;  4 = mit Sicherheit 68881 LineF FPU
;  5 = Atari Register FPU + mit Sicherheit 68881 LineF FPU
;  6 = mit Sicherheit 68882 LineF FPU
;  7 = Atari Register FPU + mit Sicherheit 68882 LineF FPU
;  8 = 68040 internal LineF FPU
;  9 = Atari Register FPU + 68040 internal LineF FPU
; 16 = 68060 internal LineF FPU
;
; Das Loword ist fÅr eine spÑtere eventuelle
; softwaremÑûige LineF- Emulation reserviert und derzeit immer 0

		moveq	#0,d1
noafpu:
		move.l	a3,sp
		move.l	a2,Buserr.w		; Busfehler zurueck

; Test auf (Line F)

		move.l	LineF.w,a1		; LineF retten
		lea	nolfpu(pc),a2		; bei LineF Trap gehts dahin
		move.l	a2,LineF.w		;

; .29
; wenn schon die FPU getestet wird, koeenen wir sie zur Sicherheit
; vor dem Test auch noch in einen definierten Zustand bringen - dazu
; einfach den NULL-Frame eingefuegt ...

		lea	nullframe(pc),a2	; NULL-Frame fuer FPU-Reset
		dc.w	$f352			; frestore (a2)
		move.l	sp,a2

; .28
; Diese Stelle war eine der Trickreichsten !!!
; Beim 68881 und 68882 reicht ein schlichtes FNOP um beim
; naechsten FSAVE statt eines NULL-Frame (habe noch nichts getan)
; einen IDLE-Frame (habe schon was getan, aber gerade nix mehr zu tun)
; zu erhalten, der dann auch ein Version Byte enthaelt. Das dieses Version
; Byte beim 68040 und 68060 an anderer Stelle zu finden ist, konnte man
; ja noch so halbwegs der Doku entnehmen, dass der 68040 ein FNOP aber
; schlichtweg wegoptimiert und danach immer noch einen NULL-Frame liefert
; allerdings nicht (Puh, DAS zu finden hat mich 2 Tage und ich weiss nicht
; wie viele gebrannte Eproms gekostet (wann bekommt die Medusa endlich
; Static-Rams statt EPROMs ...), denn wenn ich's als externes
; Programm probiert habe, hatte die FPU ja schon was getan und antwortete
; auch auf ein FNOP mit dem erwarteten IDLE-Frame. Beim Booten stand im
; FPU-cookie aber natuerlich immer nur 2 (LineF-FPU Typ unbekannt)). Jetzt
; wird statt FNOP einfach ein FTST.X FP0 verwendet - und siehe da - es geht ...

;(fa_10.11.94)(1_12_94):einigie Ñnderungen

		dc.l	$F2004000		; fmove.l d0,fp0
		dc.w	$F327			; fsave	-(sp)
		move.l	(sp),d2 		; Version Bytes ($18=881,$38=882,...
		move.l	a2,sp			; Stack korrigieren
		move.l	d2,d0			;

		cmp.w	#60,longframe.w		; mc68060
		bne	no060			; ja->
		cmp.w	#$6000,d2		; 68060 internal FPU ?
		beq	is060	        	; ja->

no060:		rol.l	#8,d0
		cmp.b	#$41,d0			; 68040 internal FPU ?
		beq	is040
		cmp.b	#$40,d0			; 68040 internal FPU ?
		beq	is040
		move.l	d2,d0
		ror.l	#8,d0
		ror.l	#8,d0
		cmp.b	#$18,d0			; 68881 ?
		beq	is881
		cmp.b	#$38,d0			; 68882 ?
		beq	is882                   ; ja ->
                bne     nolfpu                  ; sonst linef
                
is060:
		addq.w	#8,d1			;16: 68060
is040:
		addq.w	#2,d1			; 8: 68040
is882:
		addq.w	#2,d1			; 6: 68882
is881:
		addq.w	#2,d1			; 4: 68881
linef_emu:
		addq.w 	#2,d1			; 2: LineF- FPU
nolfpu:			    			; keine LineF FPU
		move.l	a3,sp			; Stack korrigieren
		move.l	a1,LineF.w		; LineF Error zurueck
		swap	d1
		move.l	d1,(a0)+

; .28
; im _MCH cookie wird jetzt TT eingetragen.

		moveq	#6,d0                   ; scsi und vme immer
		move.l	#"_MCH",(a0)+
		move.l	#$20000,(a0)+		; machine type auf TT

; Test auf Atari DMA
		move.l	a7,a2
		move.l	$8.w,a1
		move.l	#no_atari_dma,$8.w      ;buserrorvector setzen
		moveq	#6,d0                   ;vme und scsi immer
		tst.w	$ffff8604
		bset	#3,d0			; merken
no_atari_dma:   move.l	a2,a7
		move.l	a1,8.w

; .24 .25 .30
; *** Der 'id'-Cookie:
; Hier kann man nun die im Hades vorhandene Zusatzhardware
; abfragen bzw. eintragen.
; 16 Bits duerften erst einmal eine Weile reichen

;Bit 0..15:  im Hades gefundene Hardware
;	     (ist das jeweilige Bit Null ist diese Hardware nicht vorhanden).
; Bit	0	ROM-Port 
; Bit	1	VME-Bus
; Bit	2	SCSI-Karte
; Bit   3       Atari DMA
; Bit 3-11	reserviert
; Bit 12-15	reserviert fÅr Video Hardware
;		Bit 12 = ET4000 am ISA Bus 
;		Bit 13 = Viedeokarte am VME Bus
;		Bit 14 = PCI-Bus Graphikkarte 
; Bit 16-31     Maschinenversion (derzeit 0)

		move.l	#id,(a0)+
	        move.l	$44e.w,d1		; adresse bildspeicher
	        cmp.l	#$a0000000,d1		;pci
	        bcc	nopcigk			;nein->
		bset	#14,d0			;pci grafikkarte eintragen
		bra	gkset
nopcigk:	cmp.l	#$ff000000,d1		;vme?
		bcc	novmegk                 ;nein->
		bset	#13,d0                  ;set vme grafikkarte
		bra	gkset
novmegk:	bset	#12,d0			;sonst isa bus grafikkarte eintragen
gkset:		move.l	d0,(a0)+		;Hade setzen

		move.l	#"_SND",(a0)+

; _SND Cookie. nurmaler st sound eintragen
		moveq	#1,d0			; d0 initialisieren (kein DMA Sound)
		move.l	d0,(a0)+

		move.b	#8,$1820.w		;??
		move.l	#"_FDC",(a0)+

; .24
; als Benutzerkennung wird im _FDC jetzt 'id' eingetragen...
; (Ordnung muss sein .-)))

		move.l	#id,(a0)+		;hades floppy

; .23 .24 .25
; fuer MultiTOS Anwender tragen wir auch gleich noch den _AKP und
; _IDT cookie ein, das spart schon wieder ein Autoordnerprogramm

		move.l	#'_AKP',(a0)+		;
		move.l	sysbase.w,a2		;sysbase nach a0
		move.l	8(a2),a2		;
		move.w	$1c(a2),d0		;laenderkennung
		asr.w	#1,d0			;Syncmode ausblenden
		move.w	d0,d1			;merken
		asl.w	#8,d1			;in High-Bit
		or.w	d1,d0			;und einkopieren
		move.l	d0,(a0)+		;

; .23 .24 .25
;*** Der "_IDT"-Cookie:
;Bit 0..7:   Trennzeichen fÅr Datumsangaben
;	     (Null steht als Default fÅr '/').
;Bit 8..11:  Datumsformat,
;	     (0: MM-TT-JJ, 1: TT-MM-JJ,
;	      2: JJ-MM-TT, 3: JJ-TT-MM.)
;Bit 12..15: Zeitformat
;	     (0: am/pm, 1: 24 Stunden)
;Bit 16..31: reserviert

	      move.l	#'_IDT',(a0)+	;
	      moveq	#0,d1		;
	      cmp.b	#1,d0		;FRG
	      beq	isger		;
	      cmp.b	#8,d0		;SWG
	      bne	noswg		;
isger:					;
	      move.w	#$112e,d1	;
	      bra	instidt		;
noswg:					;
	      cmp.b	#3,d0		;UK
	      bne	instidt		;
	      move.w	#$1000,d1	;
instidt:				;
	      move.l	d1,(a0)+	;und eintragen
	      jmp	cook_wei	;weiter in der normalen cookie installation

;**********************************************************************************************
;fa 1.1.96:pseudo dma fuer scsi
; a0=basis adresse register
; a1=dma adresse
; a2=alter stackwert/adresse letztes zu Åbertragendes long (restdaten!!)
; a3=sprungadresse/write back 3 adresse 
; a4=endadresse
; d0=divers
; d1=anzahl byts resp. restbyts des letzten sectors -1
; d2=dma start adresse
; d3=dtt0 alt
; d4=10000-anzahl buserrors
; d5=anzahl sectoren-1
restdaten:	equ	$ffff8710
sctr1:		equ	$ffff8715	;normales scsi control register.    bit 0 = scsi write. bit 1 = dma on. bit 6 = count 0. bit 7 = buserror
sctr2:		equ	$ffff8717	;zusÑtzlicher scsi control register.bit 0 = count0/eop. bit 1 = buserror
psdm:		equ	$ffff8741     	;pseudo dma adresse fÅr daten
auu:		equ	$ffff8701
amu:		equ	$ffff8703
aml:		equ	$ffff8705
all:		equ	$ffff8707
cuu:		equ	$ffff8709
cmu:		equ	$ffff870B
cml:		equ	$ffff870D
cll:		equ	$ffff870F

int2:		movem.l d0-d7/a0-a4,-(sp)
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
;		tst.l	d1
;		beq	scsiendx
		move.l	8.w,-(sp)		;alter buserrorvector sichern
		bclr	#1,sctr1.w		;dma off -> int 2 off
                and.b	#$fc,sctr2.w		;eop, bus error off
		move.l  #scsibuserror,8.w 	;neuen setzen
		dc.w	movecd,dtt0+$3000	;dtt0 nach d3
		dc.w	movecd,itt0+$6000       ;itt0 nach d6
		dc.w	movecd,cacr+$7000       ;cacr nach d7
		move.l	#$7fc020,d0		;ram und eprom copy back
		dc.w	movec,dtt0		;copy back setzen
		dc.w	movec,itt0		
		move.l	#$80008000,d0
		dc.w	movec,cacr              ;cache on
		dc.w	cpusha
		nop
		move.l	a7,a2			;alter stack
		move.w	#10000,d4		;10000 versuche = ca. 40ms (1 buserror ist 4us(=min. transferrate=250kb/sec)) -> min. 1500U/min
		lea	psdm.w,a0
		move.l  d2,a1           	;dma adresse
		move.l	d2,a4			;startadresse
		add.l	d1,a4			;+lÑnge=endadresse
scsijmp:	subq.l	#1,d1
		move.l	d1,d5			;anzahl byts-1
		lsr.l	#8,d5                   ;/512
		lsr.l	#1,d5			;=anzahl ganze sectoren
		and.l   #$1ff,d1		;anzahl byts -1 im nÑchsten sector
		lea     scsiwrlb,a3		;sonst tabelle read nach a3
		btst	#0,sctr1.w              ;write?
		bne	scsibs			;ja->
		lea     scsirdlb,a3		;sonst tabelle read nach a3
scsibs:		sub.l   d1,a3			;x2 weil jeder befehl wordlÑnge hat
		sub.l	d1,a3			;- = aktuelle einsprungadresse
		jmp	(a3)			;verzweigen
scsiwrloop:	move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
      		move.b  (a1)+,(a0)	;byt verschieben
		move.b  (a1)+,(a0)	;byt verschieben
scsiwrlb:	move.b  (a1)+,(a0)	;byt verschieben
		dbf	d5,scsiwrloop   ;wiederholen bis fertig
		bset	#0,sctr2.w	;sonst count0/eop on
		move.b	(a1),(a0)	;dummy byt nachschieben
		bra	scsiweiter
scsirdloop:	move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
		move.b  (a0),(a1)+		;byt verschieben
scsirdlb:	move.b  (a0),(a1)+		;byt verschieben
		dbf	d5,scsirdloop		;wiederholen bis fertig
		bset	#0,sctr2.w		;count0 on
		move.l  a1,d2
		and.b	#$fc,d2			;letztes long
		move.l  d2,a0
		move.l  (a0),restdaten.w	;restdaten nach register
scsiweiter:	moveq	#0,d1			;fertig
scsiend:        bset	#1,sctr1.w		;dma on = ein int 7 scharf
        	dc.w	movec,dtt0+$3000	;dtt0 zurÅck
		dc.w	movec,itt0+$6000	;itt0 zurÅck
		dc.w	movec,cacr+$7000	;cacr zurÅck
		dc.w	cpusha
		nop
		move.b  d1,cll.w 		;byt zaehler zurÅck
                lsr.l	#8,d1
                move.b  d1,cml.w
                lsr.l	#8,d1
                move.b  d1,cmu.w
                lsr.l   #8,d1
                move.b  d1,cuu.w
                move.l  a1,d1			;neue dma adresse
		move.b  d1,all.w
		lsr.l	#8,d1
		move.b  d1,aml.w
		lsr.l   #8,d1
		move.b  d1,amu.w
		lsr.l   #8,d1
		move.b  d1,auu.w
		move.l  (sp)+,8.w		;alter buserrorvector wieder herstellen
		movem.l (sp)+,d0-d7/a0-a4
		rte
;----------------------------------------------- scsi buserror
scsibuserror:	cmp.w	#40,longframe.w		;mc68040?
		bne	scsibuer60              ;nein-> mc68060
		btst	#0,sctr1.w		;read?
		beq	scbueread40		;ja->
		move.b	$f(a7),d0		;wb3s?
		bpl     scb2			;nein
                cmp.l	$18(a7),a0		;scsiadresse
                bne	scb2x			;nein
		subq.l	#1,a1			;-1 wegen prefecht (a1)+,(a0)
scb2:		tst.b	$11(a7)			;wb2s?
		bpl     scb1			;nein
                cmp.l	$20(a7),a0		;scsiadresse
                bne	scb1x			;nein->
		subq.l	#1,a1			;-1 wegen prefecht (a1)+,(a0)
scb1:		tst.b	$13(a7)			;wb1s?
		bpl     scbuer40w		;nein->
		cmp.l	$28(a7),a0              ;scsiadresse
		bne	scbuer40w		;nein->
		subq.l	#1,a1			;-1 wegen prefecht (a1)+,(a0)
		bra	scbuer40w
scbueread40:	move.b	$0f(a7),d0		;wb3s
		bpl	scbuer40w               ;nein->
		move.l	$18(a7),a3		;adresse
		move.l	$1c(a7),d1		;daten
                bsr	savewb
scbuer40w:	cmp.l	$14(a7),a0		;scsidaten bereich?
		beq	scsitimeout	     	;ja -> timout
scsibuerer:	bset	#1,sctr1.w		;dma on = ein, int 7 scharf
                move.l	a2,a7                   ;alter stack
                dc.w	movec,dtt0+$3000	;dtt0 zurÅck
                dc.w	movec,itt0+$6000	;itt0 zurÅck
                dc.w	movec,cacr+$7000	;cacr zurÅck
                dc.w	cpusha
                nop
		or.b	#$03,sctr2.w  		;buserror- und eop-bit setzen
		move.l  (sp)+,8.w		;alter buserrorvector wieder herstellen
		movem.l (sp)+,d0-d7/a0-a4
		rte
scsibuer60:	cmp.l   8(a7),a0		;scsidaten bereich?
                bne	scsibuerer              ;nein-> bus error
scsitimeout:    move.l	a2,a7			;alter stack
		move.l	a4,d1			;enadresse
		sub.l	a1,d1			;-aktelle adresse=restbyt
		subq.w	#1,d4			;-1 versuch
		bpl	scsijmp			;abgelaufen?nein->wiedereinstieg
		bra	scsiend
scb2x:		move.l	$18(a7),a3
		move.l	$1c(a7),d1
		bsr	savewb
		bra	scb2
scb1x:		move.l	$20(a7),a3
		move.l	$24(a7),d1
		bsr	savewb
		bra	scb1
;-------------------------------------------------------------------------------------------------------------------
savewb:		move.l	#savewbber,8.w		;neuer buserrorvector
		and.b	#$60,d0			;relevante bits
		bne	nolong                  ;ist nicht long->
		move.l	d1,(a3)                 ;sonst long schreiben
		nop
		rts
nolong:	        cmp.b	#$20,d0			;byt?
		beq	ibyt                    ;ja->
nolong2:	move.w	d1,(a3)                 ;sonst word speichern
		nop
		rts
ibyt:		move.b	d1,(a3)                 ;byt speichern
		nop
		rts
savewbber:	move.l	#scsibuserror,8.w
		rte
;*******************************************************************************************************************

;unimplemented integer instruction handler (fÅr movep,mulx.l,divx.l)

x060_real_fline:
UIIADR:
	pea	exception
	rts

;========================================================
;unimplementet integer routinen
;=========================================================

x060_fpsp_done:
x060_real_trap:
x060_real_trace:
x060_real_access:
x060_isp_done:
	rte

x060_real_cas:
	bra.l		xI_CALL_TOP+$80+$08

x060_real_cas2:
	bra.l		xI_CALL_TOP+$80+$10

; INPUTS:
;	a0 - source address	
;	a1 - destination address
;	d0 - number of bytes to transfer	
; 	$4(a6),bit5 - 1 = supervisor mode, 0 = user mode
; OUTPUTS:
;	d1 - 0 = success, !0 = failure
x060_dmem_write:
x060_imem_read:
x060_dmem_read:
	dc.w		$4efb,$0522,$6,0		;jmp		([mov_tab,pc,d0.w*4],0)
mov_tab:dc.l		mov0,mov1,mov2,mov3,mov4,mov5
        dc.l            mov6,mov7,mov8,mov9,mov10,mov11,mov12
mov1:	move.b		(a0)+,(a1)+
mov0:	clr.l		d1
	rts
mov3:	move.b		(a0)+,(a1)+
mov2:	move.w		(a0)+,(a1)+
	clr.l		d1
	rts
mov5:	move.b		(a0)+,(a1)+
mov4:	move.l		(a0)+,(a1)+
	clr.l		d1
	rts
mov7:	move.b		(a0)+,(a1)+
mov6:	move.w		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	clr.l		d1
	rts
mov9:	move.b		(a0)+,(a1)+
mov8:	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	clr.l		d1
	rts	
mov11:	move.b		(a0)+,(a1)+
mov10:	move.w		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	clr.l		d1
	rts	
mov12:	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	clr.l		d1
	rts	
	


; INPUTS:
;	a0 - user source address
;	$4(a6),bit5 - 1 = supervisor mode, 0 = user mode
; OUTPUTS:
;	d0 - data byte in d0
;	d1 - 0 = success, !0 = failure
x060_dmem_read_byte:
	clr.l		d0			;clear whole longword
	move.b		(a0),d0			;fetch super byte
	clr.l		d1			;return success
	rts
;INPUTS:
;	a0 - user source address
;	$4(a6),bit5 - 1 = supervisor mode, 0 = user mode
;OUTPUTS:
;	d0 - data word in d0
;	d1 - 0 = success, !0 = failure
x060_dmem_read_word:
	clr.l		d0			;clear whole longword
	move.w		(a0),d0			;fetch super word
	clr.l		d1			;return success
	rts

;INPUTS:
;	a0 - user source address
;	$4(a6),bit5 - 1 = supervisor mode, 0 = user mode
;OUTPUTS:
;	d0 - instruction longword in d0
;	d1 - 0 = success, !0 = failure
x060_imem_read_long:
x060_dmem_read_long:
	move.l		(a0),d0			;fetch super longword
	clr.l		d1			;return success
	rts
;INPUTS:
;	a0 - user destination address
;	d0 - data byte in d0
;	$4(a6),bit5 - 1 = supervisor mode, 0 = user mode
;OUTPUTS:
;	d1 - 0 = success, !0 = failure
;
x060_dmem_write_byte:
	move.b		d0,(a0)			;store super byte
	clr.l		d1			;return success
	rts

;INPUTS:
;	a0 - user destination address
;	d0 - data word in d0
;	$4(a6),bit5 - 1 = supervisor mode, 0 = user mode
;OUTPUTS:
;	d1 - 0 = success, !0 = failure
;
x060_dmem_write_word:
	move.w		d0,(a0)			;store super word
	clr.l		d1			;return success
	rts

;INPUTS:
;	a0 - user destination address
;	d0 - data longword in d0
;	$4(a6),bit5 - 1 = supervisor mode, 0 = user mode
;OUTPUTS:
;	d1 - 0 = success, !0 = failure
x060_dmem_write_long:
	move.l		d0,(a0)			;store super longword
	clr.l		d1			;return success
	rts

;INPUTS:
;	a0 - user source address
;	$4(a6),bit5 - 1 = supervisor mode, 0 = user mode
;OUTPUTS:
;	d0 - instruction word in d0
;	d1 - 0 = success, !0 = failure
x060_imem_read_word:
	move.w		(a0),d0			;fetch super word
	clr.l		d1			;return success
	rts


;################################
;# CALL-OUT SECTION #
;################################

; The size of this section MUST be 128 bytes!!!

xI_CALL_TOP:
	dc.l	UIIADR-xI_CALL_TOP		
	dc.l	UIIADR-xI_CALL_TOP		
	dc.l	x060_real_trace-xI_CALL_TOP
	dc.l	x060_real_access-xI_CALL_TOP
	dc.l	x060_isp_done-xI_CALL_TOP
	dc.l	x060_real_cas-xI_CALL_TOP
	dc.l	x060_real_cas2-xI_CALL_TOP
	dc.l	UIIADR-xI_CALL_TOP
	dc.l	UIIADR-xI_CALL_TOP
	dc.l	0,0,0,0,0,0,0
	dc.l	x060_imem_read-xI_CALL_TOP
	dc.l	x060_dmem_read-xI_CALL_TOP
	dc.l	x060_dmem_write-xI_CALL_TOP
	dc.l	x060_imem_read_word-xI_CALL_TOP
	dc.l	x060_imem_read_long-xI_CALL_TOP
	dc.l	x060_dmem_read_byte-xI_CALL_TOP
	dc.l	x060_dmem_read_word-xI_CALL_TOP
	dc.l	x060_dmem_read_long-xI_CALL_TOP
	dc.l	x060_dmem_write_byte-xI_CALL_TOP
	dc.l	x060_dmem_write_word-xI_CALL_TOP
	dc.l	x060_dmem_write_long-xI_CALL_TOP
	dc.l	0,0,0
	dc.b	"XBRA"
	dc.l	ID
unim_int_instr:
	dc.l	$60ff0000,$02360000,$60ff0000,$16260000
	dc.l	$60ff0000,$12dc0000,$60ff0000,$11ea0000
	dc.l	$60ff0000,$10de0000,$60ff0000,$12a40000
	dc.l	$60ff0000,$12560000,$60ff0000,$122a0000
	dc.l	$51fc51fc,$51fc51fc,$51fc51fc,$51fc51fc
	dc.l	$51fc51fc,$51fc51fc,$51fc51fc,$51fc51fc
	dc.l	$51fc51fc,$51fc51fc,$51fc51fc,$51fc51fc
	dc.l	$51fc51fc,$51fc51fc,$51fc51fc,$51fc51fc
	dc.l	$2f00203a,$fefc487b,$0930ffff,$fef8202f
	dc.l	$00044e74,$00042f00,$203afeea,$487b0930
	dc.l	$fffffee2,$202f0004,$4e740004,$2f00203a
	dc.l	$fed8487b,$0930ffff,$fecc202f,$00044e74
	dc.l	$00042f00,$203afec6,$487b0930,$fffffeb6
	dc.l	$202f0004,$4e740004,$2f00203a,$feb4487b
	dc.l	$0930ffff,$fea0202f,$00044e74,$00042f00
	dc.l	$203afea2,$487b0930,$fffffe8a,$202f0004
	dc.l	$4e740004,$2f00203a,$fe90487b,$0930ffff
	dc.l	$fe74202f,$00044e74,$00042f00,$203afe7e
	dc.l	$487b0930,$fffffe5e,$202f0004,$4e740004
	dc.l	$2f00203a,$fe6c487b,$0930ffff,$fe48202f
	dc.l	$00044e74,$00042f00,$203afe76,$487b0930
	dc.l	$fffffe32,$202f0004,$4e740004,$2f00203a
	dc.l	$fe64487b,$0930ffff,$fe1c202f,$00044e74
	dc.l	$00042f00,$203afe52,$487b0930,$fffffe06
	dc.l	$202f0004,$4e740004,$2f00203a,$fe40487b
	dc.l	$0930ffff,$fdf0202f,$00044e74,$00042f00
	dc.l	$203afe2e,$487b0930,$fffffdda,$202f0004
	dc.l	$4e740004,$2f00203a,$fe1c487b,$0930ffff
	dc.l	$fdc4202f,$00044e74,$00042f00,$203afe0a
	dc.l	$487b0930,$fffffdae,$202f0004,$4e740004
	dc.l	$2f00203a,$fdf8487b,$0930ffff,$fd98202f
	dc.l	$00044e74,$00042f00,$203afde6,$487b0930
	dc.l	$fffffd82,$202f0004,$4e740004,$2f00203a
	dc.l	$fdd4487b,$0930ffff,$fd6c202f,$00044e74
	dc.l	$00042f00,$203afdc2,$487b0930,$fffffd56
	dc.l	$202f0004,$4e740004,$4e56ffa0,$48ee3fff
	dc.l	$ffc02d56,$fff8082e,$00050004,$66084e68
	dc.l	$2d48fffc,$600841ee,$000c2d48,$fffc422e
	dc.l	$ffaa3d6e,$0004ffa8,$2d6e0006,$ffa4206e
	dc.l	$ffa458ae,$ffa461ff,$ffffff26,$2d40ffa0
	dc.l	$0800001e,$67680800,$00166628,$61ff0000
	dc.l	$0cb0082e,$00050004,$670000ac,$082e0002
	dc.l	$ffaa6700,$00a2082e,$00070004,$66000186
	dc.l	$600001b0,$61ff0000,$0a28082e,$0002ffaa
	dc.l	$660e082e,$0005ffaa,$6600010a,$60000078
	dc.l	$082e0005,$000467ea,$082e0005,$ffaa6600
	dc.l	$01264a2e,$00046b00,$014c6000,$01760800
	dc.l	$0018670a,$61ff0000,$07ae6000,$004a0800
	dc.l	$001b6730,$48400c00,$00fc670a,$61ff0000
	dc.l	$0e926000,$0032206e,$ffa454ae,$ffa461ff
	dc.l	$fffffe68,$4a816600,$019861ff,$00000d20
	dc.l	$60000014,$61ff0000,$08c40c2e,$0010ffaa
	dc.l	$66000004,$605c1d6e,$ffa90005,$082e0005
	dc.l	$00046606,$206efffc,$4e604cee,$3fffffc0
	dc.l	$082e0007,$00046612,$2d6effa4,$00062cae
	dc.l	$fff84e5e,$60ffffff,$fd622d6e,$fff8fffc
	dc.l	$3d6e0004,$00002d6e,$00060008,$2d6effa4
	dc.l	$00023d7c,$20240006,$598e4e5e,$60ffffff
	dc.l	$fd0e1d6e,$ffa90005,$4cee3fff,$ffc03cae
	dc.l	$00042d6e,$00060008,$2d6effa4,$00023d7c
	dc.l	$20180006,$2c6efff8,$dffc0000,$006060ff
	dc.l	$fffffcb0,$1d6effa9,$00054cee,$3fffffc0
	dc.l	$3cae0004,$2d6e0006,$00082d6e,$ffa40002
	dc.l	$3d7c2014,$00062c6e,$fff8dffc,$00000060
	dc.l	$60ffffff,$fc941d6e,$ffa90005,$4cee3fff
	dc.l	$ffc02d6e,$0006000c,$3d7c2014,$000a2d6e
	dc.l	$ffa40006,$2c6efff8,$dffc0000,$006460ff
	dc.l	$fffffc66,$1d6effa9,$00054cee,$3fffffc0
	dc.l	$2d6e0006,$000c3d7c,$2024000a,$2d6effa4
	dc.l	$00062c6e,$fff8dffc,$00000064,$60ffffff
	dc.l	$fc4e1d6e,$ffa90005,$4cee3fff,$ffc03d7c
	dc.l	$00f4000e,$2d6effa4,$000a3d6e,$00040008
	dc.l	$2c6efff8,$dffc0000,$006860ff,$fffffc4c
	dc.l	$2c882d40,$fffc4fee,$ffc04cdf,$7fff2f2f
	dc.l	$000c2f6f,$00040010,$2f6f000c,$00042f6f
	dc.l	$0008000c,$2f5f0004,$3f7c4008,$00066028
	dc.l	$4cee3fff,$ffc04e5e,$514f2eaf,$00083f6f
	dc.l	$000c0004,$3f7c4008,$00062f6f,$00020008
	dc.l	$2f7c0942,$8001000c,$08170005,$670608ef
	dc.l	$0002000d,$60ffffff,$fbcc0c2e,$0040ffaa
	dc.l	$660c4280,$102effab,$2daeffac,$0ce04e75
	dc.l	$2040302e,$ffa03200,$0240003f,$02810000
	dc.l	$0007303b,$020a4efb,$00064afc,$00400000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000080
	dc.l	$0086008c,$00920098,$009e00a4,$00aa00b0
	dc.l	$00ce00ec,$010a0128,$01460164,$01820196
	dc.l	$01b401d2,$01f0020e,$022c024a,$0268027c
	dc.l	$029a02b8,$02d602f4,$03120330,$034e036c
	dc.l	$036c036c,$036c036c,$036c036c,$036c03d6
	dc.l	$03f0040a,$042a03ca,$00000000,$0000206e
	dc.l	$ffe04e75,$206effe4,$4e75206e,$ffe84e75
	dc.l	$206effec,$4e75206e,$fff04e75,$206efff4
	dc.l	$4e75206e,$fff84e75,$206efffc,$4e752008
	dc.l	$206effe0,$d0882d40,$ffe02d48,$ffac1d7c
	dc.l	$0000ffab,$1d7c0040,$ffaa4e75,$2008206e
	dc.l	$ffe4d088,$2d40ffe4,$2d48ffac,$1d7c0001
	dc.l	$ffab1d7c,$0040ffaa,$4e752008,$206effe8
	dc.l	$d0882d40,$ffe82d48,$ffac1d7c,$0002ffab
	dc.l	$1d7c0040,$ffaa4e75,$2008206e,$ffecd088
	dc.l	$2d40ffec,$2d48ffac,$1d7c0003,$ffab1d7c
	dc.l	$0040ffaa,$4e752008,$206efff0,$d0882d40
	dc.l	$fff02d48,$ffac1d7c,$0004ffab,$1d7c0040
	dc.l	$ffaa4e75,$2008206e,$fff4d088,$2d40fff4
	dc.l	$2d48ffac,$1d7c0005,$ffab1d7c,$0040ffaa
	dc.l	$4e752008,$206efff8,$d0882d40,$fff82d48
	dc.l	$ffac1d7c,$0006ffab,$1d7c0040,$ffaa4e75
	dc.l	$1d7c0004,$ffaa2008,$206efffc,$d0882d40
	dc.l	$fffc4e75,$202effe0,$2d40ffac,$90882d40
	dc.l	$ffe02040,$1d7c0000,$ffab1d7c,$0040ffaa
	dc.l	$4e75202e,$ffe42d40,$ffac9088,$2d40ffe4
	dc.l	$20401d7c,$0001ffab,$1d7c0040,$ffaa4e75
	dc.l	$202effe8,$2d40ffac,$90882d40,$ffe82040
	dc.l	$1d7c0002,$ffab1d7c,$0040ffaa,$4e75202e
	dc.l	$ffec2d40,$ffac9088,$2d40ffec,$20401d7c
	dc.l	$0003ffab,$1d7c0040,$ffaa4e75,$202efff0
	dc.l	$2d40ffac,$90882d40,$fff02040,$1d7c0004
	dc.l	$ffab1d7c,$0040ffaa,$4e75202e,$fff42d40
	dc.l	$ffac9088,$2d40fff4,$20401d7c,$0005ffab
	dc.l	$1d7c0040,$ffaa4e75,$202efff8,$2d40ffac
	dc.l	$90882d40,$fff82040,$1d7c0006,$ffab1d7c
	dc.l	$0040ffaa,$4e751d7c,$0008ffaa,$202efffc
	dc.l	$90882d40,$fffc2040,$4e75206e,$ffa454ae
	dc.l	$ffa461ff,$fffff9d4,$4a8166ff,$fffffd04
	dc.l	$3040d1ee,$ffe04e75,$206effa4,$54aeffa4
	dc.l	$61ffffff,$f9b64a81,$66ffffff,$fce63040
	dc.l	$d1eeffe4,$4e75206e,$ffa454ae,$ffa461ff
	dc.l	$fffff998,$4a8166ff,$fffffcc8,$3040d1ee
	dc.l	$ffe84e75,$206effa4,$54aeffa4,$61ffffff
	dc.l	$f97a4a81,$66ffffff,$fcaa3040,$d1eeffec
	dc.l	$4e75206e,$ffa454ae,$ffa461ff,$fffff95c
	dc.l	$4a8166ff,$fffffc8c,$3040d1ee,$fff04e75
	dc.l	$206effa4,$54aeffa4,$61ffffff,$f93e4a81
	dc.l	$66ffffff,$fc6e3040,$d1eefff4,$4e75206e
	dc.l	$ffa454ae,$ffa461ff,$fffff920,$4a8166ff
	dc.l	$fffffc50,$3040d1ee,$fff84e75,$206effa4
	dc.l	$54aeffa4,$61ffffff,$f9024a81,$66ffffff
	dc.l	$fc323040,$d1eefffc,$4e752f01,$206effa4
	dc.l	$54aeffa4,$61ffffff,$f8e24a81,$66ffffff
	dc.l	$fc12221f,$207614e0,$08000008,$670e48e7
	dc.l	$3c002a00,$260860ff,$000000ec,$2f022200
	dc.l	$e9590241,$000f2236,$14c00800,$000b6602
	dc.l	$48c12400,$ef5a0282,$00000003,$e5a949c0
	dc.l	$d081d1c0,$241f4e75,$1d7c0080,$ffaa206e
	dc.l	$ffa44e75,$206effa4,$54aeffa4,$61ffffff
	dc.l	$f87a4a81,$66ffffff,$fbaa3040,$4e75206e
	dc.l	$ffa458ae,$ffa461ff,$fffff876,$4a8166ff
	dc.l	$fffffb90,$20404e75,$206effa4,$54aeffa4
	dc.l	$61ffffff,$f8464a81,$66ffffff,$fb763040
	dc.l	$d1eeffa4,$55884e75,$206effa4,$54aeffa4
	dc.l	$61ffffff,$f8264a81,$66ffffff,$fb56206e
	dc.l	$ffa45588,$08000008,$670e48e7,$3c002a00
	dc.l	$260860ff,$00000030,$2f022200,$e9590241
	dc.l	$000f2236,$14c00800,$000b6602,$48c12400
	dc.l	$ef5a0282,$00000003,$e5a949c0,$d081d1c0
	dc.l	$241f4e75,$08050006,$67044282,$6016e9c5
	dc.l	$24042436,$24c00805,$000b6602,$48c2e9c5
	dc.l	$0542e1aa,$08050007,$67024283,$e9c50682
	dc.l	$0c000002,$6d346718,$206effa4,$58aeffa4
	dc.l	$61ffffff,$f7ac4a81,$66ffffff,$fac66018
	dc.l	$206effa4,$54aeffa4,$61ffffff,$f77e4a81
	dc.l	$66ffffff,$faae48c0,$d680e9c5,$07826700
	dc.l	$006a0c00,$00026d34,$6718206e,$ffa458ae
	dc.l	$ffa461ff,$fffff76a,$4a8166ff,$fffffa84
	dc.l	$601c206e,$ffa454ae,$ffa461ff,$fffff73c
	dc.l	$4a8166ff,$fffffa6c,$48c06002,$42802800
	dc.l	$08050002,$67122043,$61ffffff,$f7764a81
	dc.l	$6624d082,$d0846016,$d6822043,$61ffffff
	dc.l	$f7624a81,$6610d084,$6004d682,$20032040
	dc.l	$4cdf003c,$4e752043,$203c0101,$000160ff
	dc.l	$fffff9f0,$322effa0,$10010240,$00072076
	dc.l	$04e0d0ee,$ffa20801,$00076700,$008c3001
	dc.l	$ef580240,$00072036,$04c00801,$00066752
	dc.l	$24002448,$e19a2002,$61ffffff,$f71c4a81
	dc.l	$660000fc,$544a204a,$e19a2002,$61ffffff
	dc.l	$f7084a81,$660000e8,$544a204a,$e19a2002
	dc.l	$61ffffff,$f6f44a81,$660000d4,$544a204a
	dc.l	$e19a2002,$61ffffff,$f6e04a81,$660000c0
	dc.l	$4e752400,$2448e048,$61ffffff,$f6cc4a81
	dc.l	$660000ac,$544a204a,$200261ff,$fffff6ba
	dc.l	$4a816600,$009a4e75,$08010006,$675c2448
	dc.l	$61ffffff,$f6624a81,$66000092,$2400544a
	dc.l	$204a61ff,$fffff650,$4a816600,$0080e14a
	dc.l	$1400544a,$204a61ff,$fffff63c,$4a816600
	dc.l	$006ce18a,$1400544a,$204a61ff,$fffff628
	dc.l	$4a816600,$0058e18a,$1400122e,$ffa0e209
	dc.l	$02410007,$2d8214c0,$4e752448,$61ffffff
	dc.l	$f6064a81,$66000036,$2400544a,$204a61ff
	dc.l	$fffff5f4,$4a816600,$0024e14a,$1400122e
	dc.l	$ffa0e209,$02410007,$3d8214c2,$4e75204a
	dc.l	$203c00a1,$000160ff,$fffff8a8,$204a203c
	dc.l	$01210001,$60ffffff,$f89a61ff,$fffff914
	dc.l	$102effa2,$e9180240,$000f2436,$04c00c2e
	dc.l	$0002ffa0,$6d506728,$244861ff,$fffff5c4
	dc.l	$4a816600,$009e2600,$588a204a,$61ffffff
	dc.l	$f5b24a81,$6600008c,$22002003,$60000048
	dc.l	$244861ff,$fffff59c,$4a816600,$00763200
	dc.l	$484048c0,$48c1082e,$0007ffa2,$66000028
	dc.l	$48c26000,$00222448,$61ffffff,$f5604a81
	dc.l	$6600005e,$1200e048,$49c049c1,$082e0007
	dc.l	$ffa26602,$49c29480,$42c30203,$00049280
	dc.l	$b28242c4,$86040203,$0005382e,$ffa80204
	dc.l	$001a8803,$3d44ffa8,$082e0003,$ffa26602
	dc.l	$4e750804,$00006602,$4e751d7c,$0010ffaa
	dc.l	$4e75204a,$203c0101,$000160ff,$fffff7c4
	dc.l	$204a203c,$01410001,$60ffffff,$f7b6102e
	dc.l	$ffa10200,$00386600,$0208102e,$ffa10240
	dc.l	$00072e36,$04c06700,$00c0102e,$ffa3122e
	dc.l	$ffa20240,$0007e809,$02410007,$3d40ffb2
	dc.l	$3d41ffb4,$2a3604c0,$2c3614c0,$082e0003
	dc.l	$ffa2671a,$4a875dee,$ffb06a02,$44874a85
	dc.l	$5deeffb1,$6a0844fc,$00004086,$40854a85
	dc.l	$66164a86,$67000048,$be866306,$cb466000
	dc.l	$00124c47,$6005600a,$be85634e,$61ff0000
	dc.l	$0068082e,$0003ffa2,$67244a2e,$ffb16702
	dc.l	$4485102e,$ffb0b12e,$ffb1670c,$0c868000
	dc.l	$00006226,$44866006,$0806001f,$661c44ee
	dc.l	$ffa84a86,$42eeffa8,$302effb2,$322effb4
	dc.l	$2d8504c0,$2d8614c0,$4e7508ee,$0001ffa9
	dc.l	$08ae0000,$ffa94e75,$022e001e,$ffa9002e
	dc.l	$0020ffaa,$4e750c87,$0000ffff,$621e4281
	dc.l	$48454846,$3a068ac7,$32054846,$3a068ac7
	dc.l	$48413205,$42454845,$2c014e75,$42aeffbc
	dc.l	$422effb6,$42810807,$001f660e,$52aeffbc
	dc.l	$e38fe38e,$e3956000,$ffee2607,$24054842
	dc.l	$4843b443,$6606323c,$ffff600a,$220582c3
	dc.l	$02810000,$ffff2f06,$42464846,$26072401
	dc.l	$c4c74843,$c6c12805,$98834844,$30043806
	dc.l	$4a406600,$000ab484,$63045381,$60de2f05
	dc.l	$2c014846,$2a0761ff,$0000006a,$24052606
	dc.l	$2a1f2c1f,$9c839b82,$64ff0000,$001a5381
	dc.l	$42822607,$48434243,$dc83db82,$26074243
	dc.l	$4843da83,$4a2effb6,$66163d41,$ffb84281
	dc.l	$48454846,$3a064246,$50eeffb6,$6000ff6c
	dc.l	$3d41ffba,$3c054846,$48452e2e,$ffbc670a
	dc.l	$5387e28d,$e29651cf,$fffa2a06,$2c2effb8
	dc.l	$4e752406,$26062805,$48434844,$ccc5cac3
	dc.l	$c4c4c6c4,$42844846,$dc45d744,$dc42d744
	dc.l	$48464245,$42424845,$4842da82,$da834e75
	dc.l	$700461ff,$fffff61c,$0c2e0080,$ffaa6712
	dc.l	$244861ff,$fffff2dc,$4a81661e,$2e006000
	dc.l	$fde658ae,$ffa461ff,$fffff286,$4a8166ff
	dc.l	$fffff5a0,$2e006000,$fdce61ff,$fffff5ce
	dc.l	$204a203c,$01010001,$60ffffff,$f556102e
	dc.l	$ffa10c00,$00076e00,$00b40240,$00072636
	dc.l	$04c0342e,$ffa24241,$1202e95a,$02420007
	dc.l	$283624c0,$4a846700,$00884a83,$67000082
	dc.l	$422effb0,$082e0003,$ffa26718,$4a836c08
	dc.l	$4483002e,$0001ffb0,$4a846c08,$44840a2e
	dc.l	$0001ffb0,$2a032c03,$2e044846,$4847c6c4
	dc.l	$c8c6cac7,$ccc74287,$4843d644,$dd87d645
	dc.l	$dd874843,$42444245,$48444845,$d885d886
	dc.l	$4a2effb0,$67084683,$46845283,$d9872d83
	dc.l	$24c044fc,$00002d84,$14c042c7,$02070008
	dc.l	$1c2effa9,$02060010,$8c071d46,$ffa94e75
	dc.l	$42b624c0,$42b614c0,$7e0460e4,$700461ff
	dc.l	$fffff510,$0c2e0080,$ffaa6714,$244861ff
	dc.l	$fffff1d0,$4a816600,$00202600,$6000ff34
	dc.l	$58aeffa4,$61ffffff,$f1784a81,$66ffffff
	dc.l	$f4922600,$6000ff1c,$61ffffff,$f4c0204a
	dc.l	$203c0101,$000160ff,$fffff448,$2d40ffb4
	dc.l	$2200e958,$0240000f,$227604c0,$2d49ffb0
	dc.l	$2001ec49,$02410007,$2a3614c0,$02400007
	dc.l	$263604c0,$3d40ffba,$302effa2,$2200e958
	dc.l	$0240000f,$207604c0,$2d48ffbc,$2001ec49
	dc.l	$02410007,$283614c0,$02400007,$243604c0
	dc.l	$3d40ffb8,$082e0001,$ffa056c7,$082e0005
	dc.l	$000456c6,$24482649,$22072006,$61ffffff
	dc.l	$f05c204a,$4a8066ff,$000001c8,$22072006
	dc.l	$204b61ff,$fffff046,$204b4a80,$660a204a
	dc.l	$224b60ff,$fffff020,$2f002207,$2006204a
	dc.l	$61ffffff,$f03e201f,$204b60ff,$00000194
	dc.l	$082e0001,$ffa06648,$44eeffa8,$b0426602
	dc.l	$b24342ee,$ffa84a04,$6610362e,$ffba3d81
	dc.l	$34c2342e,$ffb83d80,$24c2082e,$00050004
	dc.l	$56c22002,$51c1206e,$ffbc61ff,$ffffeff4
	dc.l	$200251c1,$206effb0,$61ffffff,$efe64e75
	dc.l	$44eeffa8,$b0826602,$b28342ee,$ffa84a04
	dc.l	$6610362e,$ffba2d81,$34c0342e,$ffb82d80
	dc.l	$24c0082e,$00050004,$56c22002,$50c1206e
	dc.l	$ffbc61ff,$ffffefac,$200250c1,$206effb0
	dc.l	$61ffffff,$ef9e4e75,$202effb4,$6000feae
	dc.l	$082e0001,$ffa06610,$700261ff,$fffff364
	dc.l	$2d48ffb4,$51c7600e,$700461ff,$fffff354
	dc.l	$2d48ffb4,$50c7302e,$ffa22200,$ec480240
	dc.l	$00072436,$04c00241,$00072836,$14c03d41
	dc.l	$ffb8082e,$00050004,$56c62448,$22072006
	dc.l	$61ffffff,$ef284a80,$66000096,$204a60ff
	dc.l	$ffffeeee,$082e0001,$ffa0662c,$44eeffa8
	dc.l	$b04442ee,$ffa84a01,$6608362e,$ffb83d80
	dc.l	$34c2206e,$ffb451c1,$082e0005,$000456c0
	dc.l	$61ffffff,$eefe4e75,$44eeffa8,$b08442ee
	dc.l	$ffa84a01,$6608362e,$ffb82d80,$34c0206e
	dc.l	$ffb450c1,$082e0005,$000456c0,$61ffffff
	dc.l	$eed24e75,$4e7b6000,$4e7b6001,$0c2e00fc
	dc.l	$ffa167ff,$ffffff24,$206effb4,$082e0001
	dc.l	$ffa056c7,$6000ff40,$4e7b6000,$4e7b6001
	dc.l	$24482f00,$61ffffff,$f264201f,$588f518f
	dc.l	$518e721a,$41ef0008,$43ef0000,$22d851c9
	dc.l	$fffc3d7c,$4008000a,$2d4a000c,$2d400010
	dc.l	$4cee3fff,$ffc04e5e,$60ffffff,$edf84280
	dc.l	$43fb0170,$000005ae,$b3c86d0e,$43fb0170
	dc.l	$00000010,$b1c96d02,$4e7570ff,$4e754a06
	dc.l	$66047001,$60027005,$4a076700,$01e42448
	dc.l	$26492848,$2a49568c,$568d220a,$40c7007c
	dc.l	$07004e7a,$60004e7b,$00004e7b,$0001f58a
	dc.l	$f58cf58b,$f58df46a,$f46cf46b,$f46d2441
	dc.l	$56812841,$f5caf5cc,$247c8000,$0000267c
	dc.l	$a0000000,$287c0000,$00002008,$02000003
	dc.l	$671c0c00,$00026700,$00966000,$010251fc
	dc.l	$4e7ba008,$0e911000,$0e900000,$6002600e
	dc.l	$b082661c,$b2836618,$0e915800,$6002600e
	dc.l	$4e7bb008,$0e904800,$4e7bc008,$6034600e
	dc.l	$4e7bb008,$0e900800,$4e7bc008,$6012600e
	dc.l	$4e714e71,$4e714e71,$4e714e71,$4e7160b0
	dc.l	$4e7b6000,$4e7b6001,$46c751c4,$60ffffff
	dc.l	$fd424e7b,$60004e7b,$600146c7,$50c460ff
	dc.l	$fffffd30,$51fc51fc,$51fc51fc,$51fc51fc
	dc.l	$4e7ba008,$0e911000,$0e900000,$6002600e
	dc.l	$b082662c,$b2836628,$0e915800,$6002600e
	dc.l	$48440e58,$48004e7b,$b0084844,$6002600e
	dc.l	$0e504800,$4e7bc008,$6000ffa8,$4e71600e
	dc.l	$48400e58,$08004e7b,$b0084840,$6002600e
	dc.l	$0e500800,$4e7bc008,$6000ff76,$4e71600e
	dc.l	$4e714e71,$4e714e71,$4e714e71,$4e716090
	dc.l	$4e7ba008,$0e911000,$0e900000,$6002600e
	dc.l	$b082663c,$b2836638,$0e915800,$6002600e
	dc.l	$e19c0e18,$48004844,$0e584800,$6002600e
	dc.l	$e19c4e7b,$b0080e10,$48006004,$4e71600e
	dc.l	$4e7bc008,$6000ff2c,$4e714e71,$4e71600e
	dc.l	$e1980e18,$08004840,$0e580800,$6002600e
	dc.l	$e1984e7b,$b0080e10,$08006004,$4e71600e
	dc.l	$4e7bc008,$6000feea,$4e714e71,$4e71600c
	dc.l	$4e714e71,$4e714e71,$4e714e71,$6000ff72
	dc.l	$24482649,$28482a49,$528c528d,$220a40c7
	dc.l	$007c0700,$4e7a6000,$4e7b0000,$4e7b0001
	dc.l	$f58af58c,$f58bf58d,$f46af46c,$f46bf46d
	dc.l	$24415681,$2841f5ca,$f5cc247c,$80000000
	dc.l	$267ca000,$0000287c,$00000000,$20080800
	dc.l	$00006600,$009a6016,$51fc51fc,$51fc51fc
	dc.l	$4e7ba008,$0e511000,$0e500000,$6002600e
	dc.l	$b042661c,$b2436618,$0e515800,$6002600e
	dc.l	$4e7bb008,$0e504800,$4e7bc008,$6034600e
	dc.l	$4e7bb008,$0e500800,$4e7bc008,$6012600e
	dc.l	$4e714e71,$4e714e71,$4e714e71,$4e7160b0
	dc.l	$4e7b6000,$4e7b6001,$46c751c4,$60ffffff
	dc.l	$fb624e7b,$60004e7b,$600146c7,$50c460ff
	dc.l	$fffffb50,$51fc51fc,$51fc51fc,$51fc51fc
	dc.l	$4e7ba008,$0e511000,$0e500000,$6002600e
	dc.l	$b042662c,$b2436628,$0e515800,$6002600e
	dc.l	$e09c0e18,$48004e7b,$b008e19c,$6002600e
	dc.l	$0e104800,$4e7bc008,$6000ffa8,$4e71600e
	dc.l	$e0980e18,$08004e7b,$b008e198,$6002600e
	dc.l	$0e100800,$4e7bc008,$6000ff76,$4e71600e
	dc.l	$4e714e71,$4e714e71,$4e714e71,$4e716090
	dc.l	$4a066604,$70016002,$70054a07,$660000c6
	dc.l	$22482448,$528a2602,$e04a40c7,$007c0700
	dc.l	$4e7a6000,$4e7b0000,$4e7b0001,$f589f58a
	dc.l	$f469f46a,$227c8000,$0000247c,$a0000000
	dc.l	$267c0000,$00006016,$51fc51fc,$51fc51fc
	dc.l	$4e7b9008,$0e500000,$b0446624,$6002600e
	dc.l	$0e182800,$4e7ba008,$0e103800,$6002600e
	dc.l	$4e7bb008,$604c4e71,$4e714e71,$4e71600e
	dc.l	$e0980e18,$08004e7b,$a008e198,$6002600e
	dc.l	$0e100800,$4e7bb008,$60164e71,$4e71600e
	dc.l	$4e714e71,$4e714e71,$4e714e71,$4e7160a0
	dc.l	$4e7b6000,$4e7b6001,$46c751c1,$60ffffff
	dc.l	$fb164e7b,$60004e7b,$600146c7,$50c160ff
	dc.l	$fffffb04,$22482448,$568a2208,$08010000
	dc.l	$660000c2,$26024842,$40c7007c,$07004e7a
	dc.l	$60004e7b,$00004e7b,$0001f589,$f58af469
	dc.l	$f46a227c,$80000000,$247ca000,$0000267c
	dc.l	$00000000,$601851fc,$51fc51fc,$51fc51fc
	dc.l	$4e7b9008,$0e900000,$b0846624,$6002600e
	dc.l	$0e582800,$4e7ba008,$0e503800,$6002600e
	dc.l	$4e7bb008,$604c4e71,$4e714e71,$4e71600e
	dc.l	$48400e58,$08004840,$4e7ba008,$6002600e
	dc.l	$0e500800,$4e7bb008,$60164e71,$4e71600e
	dc.l	$4e714e71,$4e714e71,$4e714e71,$4e7160a0
	dc.l	$4e7b6000,$4e7b6001,$46c751c1,$60ffffff
	dc.l	$fa464e7b,$60004e7b,$600146c7,$50c160ff
	dc.l	$fffffa34,$2a02e08a,$26024842,$40c7007c
	dc.l	$07004e7a,$60004e7b,$00004e7b,$0001f589
	dc.l	$f58af469,$f46a227c,$80000000,$247ca000
	dc.l	$0000267c,$00000000,$601451fc,$51fc51fc
	dc.l	$4e7b9008,$0e900000,$b0846624,$6002600e
	dc.l	$0e182800,$0e583800,$4e7ba008,$6002600e
	dc.l	$0e105800,$4e7bb008,$6000ff88,$4e71600e
	dc.l	$e1980e18,$08004840,$0e580800,$6002600e
	dc.l	$e1984e7b,$a0080e10,$08006004,$4e71600e
	dc.l	$4e7bb008,$6000ff4a,$4e714e71,$4e71600e
	dc.l	$4e714e71,$4e714e71,$4e714e71,$4e716090
       
;=======================================================
;floating point routinen
;======================================================
;# The sample routine below simply clears the exception status bit and
;# does an "rte".
x060_real_ovfl:
x060_real_unfl:
x060_real_operr:
x060_real_snan:
x060_real_dz:
x060_real_inex:
	dc.w		$f327				;fsave		-(sp)
	move.w		#$6000,2(sp)
	dc.w		$f35f				;frestore	(sp)+
	dc.l		$f23c,$9000,0,0			;fmove.l #0,fpcr
	rte

;# The sample routine below clears the exception status bit, clears the NaN
;# bit in the FPSR, and does an "rte". The instruction that caused the 
;# bsun will now be re-executed but with the NaN FPSR bit cleared.
x060_real_bsun:
	dc.w		$f327				;fsave		-(sp)
	dc.l		$f23c,$9000,0,0			;fmove.l #0,fpcr
	and.b		#$fe,(sp)
	dc.l		$f21f,$8800			;fmove.l (sp)+,fpsr
	add.w		#$c,sp
	dc.l		$f23c,$9000,0,0			;fmove.l #0,fpcr
	rte

x060_real_fpu_disabled:
	move.l		d0,-(sp)			;# enabled the fpu
	dc.w		movec,pcr
	bclr		#1,d0
	dc.w		movecd,pcr
	move.l		(sp)+,d0
	move.l		$c(sp),2(sp)			;# set "Current PC"
	dc.l		$f23c,$9000,0,0			;fmove.l #0,fpcr
	rte

;# The size of this section MUST be 128 bytes!!!

xFP_CALL_TOP:
	dc.l	x060_real_bsun-xFP_CALL_TOP
	dc.l	x060_real_snan-xFP_CALL_TOP
	dc.l	x060_real_operr-xFP_CALL_TOP
	dc.l	x060_real_ovfl-xFP_CALL_TOP
	dc.l	x060_real_unfl-xFP_CALL_TOP
	dc.l	x060_real_dz-xFP_CALL_TOP
	dc.l	x060_real_inex-xFP_CALL_TOP
	dc.l	x060_real_fline-xFP_CALL_TOP
	dc.l	x060_real_fpu_disabled-xFP_CALL_TOP
	dc.l	x060_real_trap-xFP_CALL_TOP
	dc.l	x060_real_trace-xFP_CALL_TOP
	dc.l	x060_real_access-xFP_CALL_TOP
	dc.l	x060_fpsp_done-xFP_CALL_TOP
	dc.l	0,0,0
	dc.l	x060_imem_read-xFP_CALL_TOP
	dc.l	x060_dmem_read-xFP_CALL_TOP
	dc.l	x060_dmem_write-xFP_CALL_TOP
	dc.l	x060_imem_read_word-xFP_CALL_TOP
	dc.l	x060_imem_read_long-xFP_CALL_TOP
	dc.l	x060_dmem_read_byte-xFP_CALL_TOP
	dc.l	x060_dmem_read_word-xFP_CALL_TOP
	dc.l	x060_dmem_read_long-xFP_CALL_TOP
	dc.l	x060_dmem_write_byte-xFP_CALL_TOP
	dc.l	x060_dmem_write_word-xFP_CALL_TOP
	dc.l	x060_dmem_write_long-xFP_CALL_TOP
	dc.l	0,0,0,0,0

;#############################################################################
;# 060 FPSP KERNEL PACKAGE NEEDS TO GO HERE!!!

	dc.l	$60ff0000,$17400000,$60ff0000,$15f40000
	dc.l	$60ff0000,$02b60000,$60ff0000,$04700000
	dc.l	$60ff0000,$1b100000,$60ff0000,$19aa0000
	dc.l	$60ff0000,$1b5a0000,$60ff0000,$062e0000
	dc.l	$60ff0000,$102c0000,$51fc51fc,$51fc51fc
	dc.l	$51fc51fc,$51fc51fc,$51fc51fc,$51fc51fc
	dc.l	$51fc51fc,$51fc51fc,$51fc51fc,$51fc51fc
	dc.l	$51fc51fc,$51fc51fc,$51fc51fc,$51fc51fc
	dc.l	$2f00203a,$ff2c487b,$0930ffff,$fef8202f
	dc.l	$00044e74,$00042f00,$203afef2,$487b0930
	dc.l	$fffffee2,$202f0004,$4e740004,$2f00203a
	dc.l	$fee0487b,$0930ffff,$fecc202f,$00044e74
	dc.l	$00042f00,$203afed2,$487b0930,$fffffeb6
	dc.l	$202f0004,$4e740004,$2f00203a,$fea4487b
	dc.l	$0930ffff,$fea0202f,$00044e74,$00042f00
	dc.l	$203afe96,$487b0930,$fffffe8a,$202f0004
	dc.l	$4e740004,$2f00203a,$fe7c487b,$0930ffff
	dc.l	$fe74202f,$00044e74,$00042f00,$203afe76
	dc.l	$487b0930,$fffffe5e,$202f0004,$4e740004
	dc.l	$2f00203a,$fe68487b,$0930ffff,$fe48202f
	dc.l	$00044e74,$00042f00,$203afe56,$487b0930
	dc.l	$fffffe32,$202f0004,$4e740004,$2f00203a
	dc.l	$fe44487b,$0930ffff,$fe1c202f,$00044e74
	dc.l	$00042f00,$203afe32,$487b0930,$fffffe06
	dc.l	$202f0004,$4e740004,$2f00203a,$fe20487b
	dc.l	$0930ffff,$fdf0202f,$00044e74,$00042f00
	dc.l	$203afe1e,$487b0930,$fffffdda,$202f0004
	dc.l	$4e740004,$2f00203a,$fe0c487b,$0930ffff
	dc.l	$fdc4202f,$00044e74,$00042f00,$203afdfa
	dc.l	$487b0930,$fffffdae,$202f0004,$4e740004
	dc.l	$2f00203a,$fde8487b,$0930ffff,$fd98202f
	dc.l	$00044e74,$00042f00,$203afdd6,$487b0930
	dc.l	$fffffd82,$202f0004,$4e740004,$2f00203a
	dc.l	$fdc4487b,$0930ffff,$fd6c202f,$00044e74
	dc.l	$00042f00,$203afdb2,$487b0930,$fffffd56
	dc.l	$202f0004,$4e740004,$2f00203a,$fda0487b
	dc.l	$0930ffff,$fd40202f,$00044e74,$00042f00
	dc.l	$203afd8e,$487b0930,$fffffd2a,$202f0004
	dc.l	$4e740004,$2f00203a,$fd7c487b,$0930ffff
	dc.l	$fd14202f,$00044e74,$00042f00,$203afd6a
	dc.l	$487b0930,$fffffcfe,$202f0004,$4e740004
	dc.l	$40c62d38,$d3d64634,$3d6f90ae,$b1e75cc7
	dc.l	$40000000,$c90fdaa2,$2168c235,$00000000
	dc.l	$3fff0000,$c90fdaa2,$2168c235,$00000000
	dc.l	$3fe45f30,$6dc9c883,$4e56ff40,$f32eff6c
	dc.l	$48ee0303,$ff9cf22e,$bc00ff60,$f22ef0c0
	dc.l	$ffdc2d6e,$ff68ff44,$206eff44,$58aeff44
	dc.l	$61ffffff,$ff042d40,$ff40082e,$0005ff42
	dc.l	$66000116,$41eeff6c,$61ff0000,$051c41ee
	dc.l	$ff6c61ff,$0000c1dc,$1d40ff4e,$082e0005
	dc.l	$ff436726,$e9ee0183,$ff4261ff,$0000bd22
	dc.l	$41eeff78,$61ff0000,$c1ba0c00,$00066606
	dc.l	$61ff0000,$c11e1d40,$ff4f4280,$102eff63
	dc.l	$122eff43,$0241007f,$02ae00ff,$01ffff64
	dc.l	$f23c9000,$00000000,$f23c8800,$00000000
	dc.l	$41eeff6c,$43eeff78,$223b1530,$00007112
	dc.l	$4ebb1930,$0000710a,$e9ee0183,$ff4261ff
	dc.l	$0000bd4e,$082e0004,$ff626622,$082e0001
	dc.l	$ff626644,$f22ed0c0,$ffdcf22e,$9c00ff60
	dc.l	$4cee0303,$ff9c4e5e,$60ffffff,$fcc6f22e
	dc.l	$f040ff6c,$3d7ce005,$ff6ef22e,$d0c0ffdc
	dc.l	$f22e9c00,$ff604cee,$0303ff9c,$f36eff6c
	dc.l	$4e5e60ff,$fffffcb2,$f22ef040,$ff6c1d7c
	dc.l	$00c4000b,$3d7ce001,$ff6ef22e,$d0c0ffdc
	dc.l	$f22e9c00,$ff604cee,$0303ff9c,$f36eff6c
	dc.l	$4e5e60ff,$fffffcae,$1d7c0000,$ff4e4280
	dc.l	$102eff63,$02aeffff,$00ffff64,$f23c9000
	dc.l	$00000000,$f23c8800,$00000000,$41eeff6c
	dc.l	$61ff0000,$b2ce082e,$0004ff62,$6600ff70
	dc.l	$082e0001,$ff626600,$ff90f22e,$d0c0ffdc
	dc.l	$f22e9c00,$ff604cee,$0303ff9c,$4e5e0817
	dc.l	$000767ff,$fffffc0c,$f22fa400,$00083f7c
	dc.l	$20240006,$60ffffff,$fcec4e56,$ff40f32e
	dc.l	$ff6c48ee,$0303ff9c,$f22ebc00,$ff60f22e
	dc.l	$f0c0ffdc,$2d6eff68,$ff44206e,$ff4458ae
	dc.l	$ff4461ff,$fffffd42,$2d40ff40,$082e0005
	dc.l	$ff426600,$013241ee,$ff6c61ff,$0000035a
	dc.l	$41eeff6c,$61ff0000,$c01a1d40,$ff4e082e
	dc.l	$0005ff43,$672e082e,$0004ff43,$6626e9ee
	dc.l	$0183ff42,$61ff0000,$bb5841ee,$ff7861ff
	dc.l	$0000bff0,$0c000006,$660661ff,$0000bf54
	dc.l	$1d40ff4f,$4280102e,$ff63122e,$ff430241
	dc.l	$007f02ae,$00ff01ff,$ff64f23c,$90000000
	dc.l	$0000f23c,$88000000,$000041ee,$ff6c43ee
	dc.l	$ff78223b,$15300000,$6f484ebb,$19300000
	dc.l	$6f40e9ee,$0183ff42,$61ff0000,$bb84082e
	dc.l	$0003ff62,$6622082e,$0001ff62,$664ef22e
	dc.l	$d0c0ffdc,$f22e9c00,$ff604cee,$0303ff9c
	dc.l	$4e5e60ff,$fffffafc,$082e0003,$ff666700
	dc.l	$ffd6f22e,$f040ff6c,$3d7ce003,$ff6ef22e
	dc.l	$d0c0ffdc,$f22e9c00,$ff604cee,$0303ff9c
	dc.l	$f36eff6c,$4e5e60ff,$fffffaf4,$082e0001
	dc.l	$ff666700,$ffaaf22e,$f040ff6c,$1d7c00c4
	dc.l	$000b3d7c,$e001ff6e,$f22ed0c0,$ffdcf22e
	dc.l	$9c00ff60,$4cee0303,$ff9cf36e,$ff6c4e5e
	dc.l	$60ffffff,$fad01d7c,$0000ff4e,$4280102e
	dc.l	$ff6302ae,$ffff00ff,$ff64f23c,$90000000
	dc.l	$0000f23c,$88000000,$000041ee,$ff6c61ff
	dc.l	$0000b0f0,$082e0003,$ff626600,$ff66082e
	dc.l	$0001ff62,$6600ff90,$f22ed0c0,$ffdcf22e
	dc.l	$9c00ff60,$4cee0303,$ff9c4e5e,$08170007
	dc.l	$67ffffff,$fa2ef22f,$a4000008,$3f7c2024
	dc.l	$000660ff,$fffffb0e,$4e56ff40,$f32eff6c
	dc.l	$48ee0303,$ff9cf22e,$bc00ff60,$f22ef0c0
	dc.l	$ffdc082e,$00050004,$66084e68,$2d48ffd8
	dc.l	$600841ee,$00102d48,$ffd82d6e,$ff68ff44
	dc.l	$206eff44,$58aeff44,$61ffffff,$fb4c2d40
	dc.l	$ff40422e,$ff4a082e,$0005ff42,$66000208
	dc.l	$e9ee0006,$ff420c00,$00136700,$049e02ae
	dc.l	$00ff00ff,$ff64f23c,$90000000,$0000f23c
	dc.l	$88000000,$000041ee,$ff6c61ff,$0000013a
	dc.l	$41eeff6c,$61ff0000,$bdfa0c00,$00066606
	dc.l	$61ff0000,$bd5e1d40,$ff4ee9ee,$0183ff42
	dc.l	$082e0005,$ff436728,$0c2e003a,$ff436720
	dc.l	$61ff0000,$b92c41ee,$ff7861ff,$0000bdc4
	dc.l	$0c000006,$660661ff,$0000bd28,$1d40ff4f
	dc.l	$4280102e,$ff63e9ee,$1047ff43,$41eeff6c
	dc.l	$43eeff78,$223b1d30,$00006d36,$4ebb1930
	dc.l	$00006d2e,$102eff62,$6634102e,$ff430200
	dc.l	$00380c00,$0038670c,$e9ee0183,$ff4261ff
	dc.l	$0000b95e,$f22ed0c0,$ffdcf22e,$9c00ff60
	dc.l	$4cee0303,$ff9c4e5e,$60ffffff,$f8e6c02e
	dc.l	$ff66edc0,$06086614,$082e0004,$ff6667ba
	dc.l	$082e0001,$ff6267b2,$60000066,$04800000
	dc.l	$00180c00,$00066614,$082e0003,$ff666600
	dc.l	$004a082e,$0004ff66,$66000046,$2f0061ff
	dc.l	$000007e0,$201f3d7b,$0222ff6e,$f22ed0c0
	dc.l	$ffdcf22e,$9c00ff60,$4cee0303,$ff9cf36e
	dc.l	$ff6c4e5e,$60ffffff,$f87ae000,$e006e004
	dc.l	$e005e003,$e002e001,$e001303c,$000460bc
	dc.l	$303c0003,$60b6e9ee,$0006ff42,$0c000011
	dc.l	$67080c00,$00156750,$4e753028,$00000240
	dc.l	$7fff0c40,$3f806708,$0c40407f,$672c4e75
	dc.l	$02a87fff,$ffff0004,$671861ff,$0000bbbc
	dc.l	$44400640,$3f810268,$80000000,$81680000
	dc.l	$4e750268,$80000000,$4e750228,$007f0004
	dc.l	$00687fff,$00004e75,$30280000,$02407fff
	dc.l	$0c403c00,$67080c40,$43ff67de,$4e7502a8
	dc.l	$7fffffff,$00046606,$4aa80008,$67c461ff
	dc.l	$0000bb68,$44400640,$3c010268,$80000000
	dc.l	$81680000,$4e75e9ee,$00c3ff42,$0c000003
	dc.l	$670004a2,$0c000007,$6700049a,$02aeffff
	dc.l	$00ffff64,$f23c9000,$00000000,$f23c8800
	dc.l	$00000000,$302eff6c,$02407fff,$671041ee
	dc.l	$ff6c61ff,$0000bb5c,$1d40ff4e,$60061d7c
	dc.l	$0004ff4e,$4280102e,$ff6341ee,$ff6c2d56
	dc.l	$ffd461ff,$0000adec,$102eff62,$66000086
	dc.l	$2caeffd4,$082e0005,$00046626,$206effd8
	dc.l	$4e60f22e,$d0c0ffdc,$f22e9c00,$ff604cee
	dc.l	$0303ff9c,$4e5e0817,$0007667a,$60ffffff
	dc.l	$f7220c2e,$0008ff4a,$66d8f22e,$f080ff6c
	dc.l	$f22ed0c0,$ffdcf22e,$9c00ff60,$4cee0303
	dc.l	$ff9c2c56,$2f6f00c4,$00b82f6f,$00c800bc
	dc.l	$2f6f002c,$00c42f6f,$003000c8,$2f6f0034
	dc.l	$00ccdffc,$000000b8,$08170007,$662860ff
	dc.l	$fffff6d0,$c02eff66,$edc00608,$662a082e
	dc.l	$0004ff66,$6700ff6a,$082e0001,$ff626700
	dc.l	$ff606000,$01663f7c,$20240006,$f22fa400
	dc.l	$000860ff,$fffff78e,$04800000,$0018303b
	dc.l	$020a4efb,$00064afc,$00080000,$0000003a
	dc.l	$00640094,$00000140,$0000f22e,$d0c0ffdc
	dc.l	$f22e9c00,$ff604cee,$0303ff9c,$3d7c30d8
	dc.l	$000a3d7c,$e006ff6e,$f36eff6c,$4e5e60ff
	dc.l	$fffff6d4,$f22ed0c0,$ffdcf22e,$9c00ff60
	dc.l	$4cee0303,$ff9c3d7c,$30d0000a,$3d7ce004
	dc.l	$ff6ef36e,$ff6c4e5e,$60ffffff,$f694f22e
	dc.l	$f040ff6c,$f22ed0c0,$ffdcf22e,$9c00ff60
	dc.l	$4cee0303,$ff9c3d7c,$30d4000a,$3d7ce005
	dc.l	$ff6ef36e,$ff6c4e5e,$60ffffff,$f60c2cae
	dc.l	$ffd4082e,$00050004,$66000038,$206effd8
	dc.l	$4e60f22e,$f040ff6c,$f22ed0c0,$ffdcf22e
	dc.l	$9c00ff60,$4cee0303,$ff9c3d7c,$30cc000a
	dc.l	$3d7ce003,$ff6ef36e,$ff6c4e5e,$60ffffff
	dc.l	$f5de0c2e,$0008ff4a,$66c8f22e,$f080ff6c
	dc.l	$f22ef040,$ff78f22e,$d0c0ffdc,$f22e9c00
	dc.l	$ff604cee,$0303ff9c,$3d7c30cc,$000a3d7c
	dc.l	$e003ff7a,$f36eff78,$2c562f6f,$00c400b8
	dc.l	$2f6f00c8,$00bc2f6f,$00cc00c0,$2f6f002c
	dc.l	$00c42f6f,$003000c8,$2f6f0034,$00ccdffc
	dc.l	$000000b8,$60ffffff,$f576f22e,$f040ff6c
	dc.l	$f22ed0c0,$ffdcf22e,$9c00ff60,$4cee0303
	dc.l	$ff9c3d7c,$30c4000a,$3d7ce001,$ff6ef36e
	dc.l	$ff6c4e5e,$60ffffff,$f55c02ae,$00ff00ff
	dc.l	$ff64f23c,$90000000,$0000f23c,$88000000
	dc.l	$000061ff,$0000bdba,$41eeff6c,$61ff0000
	dc.l	$b9621d40,$ff4ee9ee,$0183ff42,$082e0005
	dc.l	$ff436728,$0c2e003a,$ff436720,$61ff0000
	dc.l	$b4a041ee,$ff7861ff,$0000b938,$0c000006
	dc.l	$660661ff,$0000b89c,$1d40ff4f,$4280102e
	dc.l	$ff63e9ee,$1047ff43,$41eeff6c,$43eeff78
	dc.l	$223b1d30,$000068aa,$4ebb1930,$000068a2
	dc.l	$102eff62,$6600008a,$102eff43,$02000038
	dc.l	$0c000038,$670ce9ee,$0183ff42,$61ff0000
	dc.l	$b4d0082e,$00050004,$6600002a,$206effd8
	dc.l	$4e60f22e,$d0c0ffdc,$f22e9c00,$ff604cee
	dc.l	$0303ff9c,$4e5e0817,$00076600,$012660ff
	dc.l	$fffff440,$082e0002,$ff4a67d6,$f22ed0c0
	dc.l	$ffdcf22e,$9c00ff60,$4cee0303,$ff9c4e5e
	dc.l	$2f6f0004,$00102f6f,$0000000c,$dffc0000
	dc.l	$000c0817,$00076600,$00ea60ff,$fffff404
	dc.l	$c02eff66,$edc00608,$6618082e,$0004ff66
	dc.l	$6700ff66,$082e0001,$ff626700,$ff5c6000
	dc.l	$006e0480,$00000018,$0c000006,$6d14082e
	dc.l	$0003ff66,$66000060,$082e0004,$ff666600
	dc.l	$004e082e,$00050004,$66000054,$206effd8
	dc.l	$4e603d7b,$022aff6e,$f22ed0c0,$ffdcf22e
	dc.l	$9c00ff60,$4cee0303,$ff9cf36e,$ff6c4e5e
	dc.l	$08170007,$6600006c,$60ffffff,$f386e000
	dc.l	$e006e004,$e005e003,$e002e001,$e001303c
	dc.l	$00036000,$ffae303c,$00046000,$ffa6082e
	dc.l	$0002ff4a,$67ac3d7b,$02d6ff6e,$f22ed0c0
	dc.l	$ffdcf22e,$9c00ff60,$4cee0303,$ff9cf36e
	dc.l	$ff6c4e5e,$2f6f0004,$00102f6f,$0000000c
	dc.l	$dffc0000,$000c0817,$00076606,$60ffffff
	dc.l	$f3223f7c,$20240006,$f22fa400,$000860ff
	dc.l	$fffff402,$02aeffff,$00ffff64,$f23c9000
	dc.l	$00000000,$f23c8800,$00000000,$e9ee0183
	dc.l	$ff4261ff,$0000b22a,$41eeff6c,$61ff0000
	dc.l	$b7520c00,$00066606,$61ff0000,$b6b61d40
	dc.l	$ff4e4280,$102eff63,$41eeff6c,$2d56ffd4
	dc.l	$61ff0000,$a94e102e,$ff626600,$00842cae
	dc.l	$ffd4082e,$00050004,$6628206e,$ffd84e60
	dc.l	$f22ed0c0,$ffdcf22e,$9c00ff60,$4cee0303
	dc.l	$ff9c4e5e,$08170007,$6600ff68,$60ffffff
	dc.l	$f282082e,$0003ff4a,$67d6f22e,$d0c0ffdc
	dc.l	$f22e9c00,$ff604cee,$0303ff9c,$2c562f6f
	dc.l	$00c400b8,$2f6f00c8,$00bc2f6f,$003800c4
	dc.l	$2f6f003c,$00c82f6f,$004000cc,$dffc0000
	dc.l	$00b80817,$00076600,$ff1a60ff,$fffff234
	dc.l	$c02eff66,$edc00608,$6700ff74,$2caeffd4
	dc.l	$0c00001a,$6e0000e8,$67000072,$082e0005
	dc.l	$0004660a,$206effd8,$4e606000,$fb8e0c2e
	dc.l	$0008ff4a,$6600fb84,$f22ed0c0,$ffdcf22e
	dc.l	$9c00ff60,$4cee0303,$ff9c3d7c,$30d8000a
	dc.l	$3d7ce006,$ff6ef36e,$ff6c2c56,$2f6f00c4
	dc.l	$00b82f6f,$00c800bc,$2f6f00cc,$00c02f6f
	dc.l	$003800c4,$2f6f003c,$00c82f6f,$004000cc
	dc.l	$dffc0000,$00b860ff,$fffff22c,$082e0005
	dc.l	$00046600,$000c206e,$ffd84e60,$6000fb46
	dc.l	$0c2e0008,$ff4a6600,$fb3cf22e,$d0c0ffdc
	dc.l	$f22e9c00,$ff604cee,$0303ff9c,$3d7c30d0
	dc.l	$000a3d7c,$e004ff6e,$f36eff6c,$2c562f6f
	dc.l	$00c400b8,$2f6f00c8,$00bc2f6f,$00cc00c0
	dc.l	$2f6f0038,$00c42f6f,$003c00c8,$2f6f0040
	dc.l	$00ccdffc,$000000b8,$60ffffff,$f1a4082e
	dc.l	$00050004,$6600000c,$206effd8,$4e606000
	dc.l	$fbda0c2e,$0008ff4a,$6600fbd0,$f22ed0c0
	dc.l	$ffdcf22e,$9c00ff60,$4cee0303,$ff9c3d7c
	dc.l	$30c4000a,$3d7ce001,$ff6ef36e,$ff6c2c56
	dc.l	$2f6f00c4,$00b82f6f,$00c800bc,$2f6f00cc
	dc.l	$00c02f6f,$003800c4,$2f6f003c,$00c82f6f
	dc.l	$004000cc,$dffc0000,$00b860ff,$fffff106
	dc.l	$e9ee00c3,$ff420c00,$00016708,$0c000005
	dc.l	$67344e75,$302eff6c,$02407fff,$67260c40
	dc.l	$3f806e20,$44400640,$3f81222e,$ff70e0a9
	dc.l	$08c1001f,$2d41ff70,$026e8000,$ff6c006e
	dc.l	$3f80ff6c,$4e75302e,$ff6c0240,$7fff673a
	dc.l	$0c403c00,$6e344a2e,$ff6c5bee,$ff6e3d40
	dc.l	$ff6c4280,$41eeff6c,$323c3c01,$61ff0000
	dc.l	$b156303c,$3c004a2e,$ff6e6704,$08c0000f
	dc.l	$08ee0007,$ff703d40,$ff6c4e75,$082e0005
	dc.l	$000467ff,$fffff176,$2d680000,$ff782d68
	dc.l	$0004ff7c,$2d680008,$ff804281,$4e752f00
	dc.l	$4e7a0808,$08000001,$66000460,$201f4e56
	dc.l	$ff4048ee,$0303ff9c,$f22ebc00,$ff60f22e
	dc.l	$f0c0ffdc,$2d6e0006,$ff44206e,$ff4458ae
	dc.l	$ff4461ff,$fffff152,$2d40ff40,$4a406b00
	dc.l	$020e02ae,$00ff00ff,$ff640800,$000a6618
	dc.l	$206eff44,$43eeff6c,$700c61ff,$fffff0d2
	dc.l	$4a816600,$04926048,$206eff44,$43eeff6c
	dc.l	$700c61ff,$fffff0ba,$4a816600,$047ae9ee
	dc.l	$004fff6c,$0c407fff,$6726102e,$ff6f0200
	dc.l	$000f660c,$4aaeff70,$66064aae,$ff746710
	dc.l	$41eeff6c,$61ff0000,$b88cf22e,$f080ff6c
	dc.l	$06ae0000,$000cff44,$41eeff6c,$61ff0000
	dc.l	$b3c21d40,$ff4e0c00,$0006660a,$61ff0000
	dc.l	$b3221d40,$ff4e422e,$ff53082e,$0005ff43
	dc.l	$6748082e,$0004ff43,$662ce9ee,$0183ff42
	dc.l	$61ff0000,$aeec41ee,$ff7861ff,$0000b384
	dc.l	$1d40ff4f,$0c000006,$662061ff,$0000b2e4
	dc.l	$1d40ff4f,$6014082e,$0003ff43,$670c50ee
	dc.l	$ff53082e,$0001ff43,$67c04280,$102eff63
	dc.l	$122eff43,$0241007f,$f23c9000,$00000000
	dc.l	$f23c8800,$00000000,$41eeff6c,$43eeff78
	dc.l	$223b1530,$000062ca,$4ebb1930,$000062c2
	dc.l	$102eff62,$66404a2e,$ff53660c,$e9ee0183
	dc.l	$ff4261ff,$0000aefa,$2d6e0006,$ff682d6e
	dc.l	$ff440006,$f22ed0c0,$ffdcf22e,$9c00ff60
	dc.l	$4cee0303,$ff9c4e5e,$08170007,$66000096
	dc.l	$60ffffff,$ee6ec02e,$ff66edc0,$06086612
	dc.l	$082e0004,$ff6667ae,$082e0001,$ff6267ac
	dc.l	$60340480,$00000018,$0c000006,$6610082e
	dc.l	$0004ff66,$6620082e,$0003ff66,$66203d7b
	dc.l	$0206ff6e,$601ee002,$e006e004,$e005e003
	dc.l	$e002e001,$e0013d7c,$e005ff6e,$60063d7c
	dc.l	$e003ff6e,$2d6e0006,$ff682d6e,$ff440006
	dc.l	$f22ed0c0,$ffdcf22e,$9c00ff60,$4cee0303
	dc.l	$ff9cf36e,$ff6c4e5e,$08170007,$660660ff
	dc.l	$ffffede0,$2f173f6f,$00080004,$3f7c2024
	dc.l	$0006f22f,$a4000008,$60ffffff,$eeb80800
	dc.l	$000e6700,$01c2082e,$00050004,$66164e68
	dc.l	$2d48ffd8,$61ff0000,$9564206e,$ffd84e60
	dc.l	$600001aa,$422eff4a,$41ee000c,$2d48ffd8
	dc.l	$61ff0000,$95480c2e,$0008ff4a,$67000086
	dc.l	$0c2e0004,$ff4a6600,$0184082e,$00070004
	dc.l	$66363dae,$00040804,$2daeff44,$08063dbc
	dc.l	$00f0080a,$41f60804,$2d480004,$f22ed0c0
	dc.l	$ffdcf22e,$9c00ff60,$4cee0303,$ff9c4e5e
	dc.l	$2e5f60ff,$ffffed3c,$3dae0004,$08002dae
	dc.l	$ff440802,$3dbc2024,$08062dae,$00060808
	dc.l	$41f60800,$2d480004,$f22ed0c0,$ffdcf22e
	dc.l	$9c00ff60,$4cee0303,$ff9c4e5e,$2e5f60ff
	dc.l	$ffffedf2,$1d41000a,$1d40000b,$f22ed0c0
	dc.l	$ffdcf22e,$9c00ff60,$4cee0303,$ff9c2f16
	dc.l	$2f002f01,$2f2eff44,$4280102e,$000b4480
	dc.l	$082e0007,$0004671c,$3dae0004,$08002dae
	dc.l	$00060808,$2d9f0802,$3dbc2024,$08064876
	dc.l	$08006014,$3dae0004,$08042d9f,$08063dbc
	dc.l	$00f0080a,$48760804,$4281122e,$000a4a01
	dc.l	$6a0cf236,$f080080c,$06800000,$000ce309
	dc.l	$6a0cf236,$f040080c,$06800000,$000ce309
	dc.l	$6a0cf236,$f020080c,$06800000,$000ce309
	dc.l	$6a0cf236,$f010080c,$06800000,$000ce309
	dc.l	$6a0cf236,$f008080c,$06800000,$000ce309
	dc.l	$6a0cf236,$f004080c,$06800000,$000ce309
	dc.l	$6a0cf236,$f002080c,$06800000,$000ce309
	dc.l	$6a06f236,$f001080c,$222f0004,$202f0008
	dc.l	$2c6f000c,$2e5f0817,$000767ff,$ffffec04
	dc.l	$60ffffff,$ecf061ff,$00009bda,$f22ed0c0
	dc.l	$ffdcf22e,$9c00ff60,$4cee0303,$ff9c082e
	dc.l	$00070004,$660e2d6e,$ff440006,$4e5e60ff
	dc.l	$ffffebd0,$2c563f6f,$00c400c0,$2f6f00c6
	dc.l	$00c82f6f,$000400c2,$3f7c2024,$00c6dffc
	dc.l	$000000c0,$60ffffff,$ec9c201f,$4e56ff40
	dc.l	$48ee0303,$ff9c2d6e,$0006ff44,$206eff44
	dc.l	$58aeff44,$61ffffff,$ed002d40,$ff404a40
	dc.l	$6b047010,$60260800,$000e6610,$e9c014c3
	dc.l	$700c0c01,$00076614,$58806010,$428061ff
	dc.l	$0000967c,$202eff44,$90ae0006,$3d40000a
	dc.l	$4cee0303,$ff9c4e5e,$518f2f00,$3f6f000c
	dc.l	$00042f6f,$000e0006,$4280302f,$00122f6f
	dc.l	$00060010,$d1af0006,$3f7c402c,$000a201f
	dc.l	$60ffffff,$ebe44e7a,$08080800,$0001660c
	dc.l	$f22e9c00,$ff60f22e,$d0c0ffdc,$4cee0303
	dc.l	$ff9c4e5e,$514f2eaf,$00083f6f,$000c0004
	dc.l	$3f7c4008,$00062f6f,$00020008,$2f7c0942
	dc.l	$8001000c,$08170005,$670608ef,$0002000d
	dc.l	$60ffffff,$ebd64fee,$ff404e7a,$18080801
	dc.l	$0001660c,$f22ed0c0,$ffdcf22f,$9c000020
	dc.l	$2c562f6f,$00c400bc,$3f6f00c8,$00c03f7c
	dc.l	$400800c2,$2f4800c4,$3f4000c8,$3f7c0001
	dc.l	$00ca4cef,$0303005c,$defc00bc,$60a64e56
	dc.l	$ff40f32e,$ff6c48ee,$0303ff9c,$f22ebc00
	dc.l	$ff60f22e,$f0c0ffdc,$2d6eff68,$ff44206e
	dc.l	$ff4458ae,$ff4461ff,$ffffebce,$2d40ff40
	dc.l	$0800000d,$662841ee,$ff6c61ff,$fffff1ea
	dc.l	$f22ed0c0,$ffdcf22e,$9c00ff60,$4cee0303
	dc.l	$ff9cf36e,$ff6c4e5e,$60ffffff,$ea94322e
	dc.l	$ff6c0241,$7fff0c41,$7fff661a,$4aaeff74
	dc.l	$660c222e,$ff700281,$7fffffff,$67082d6e
	dc.l	$ff70ff54,$6012223c,$7fffffff,$4a2eff6c
	dc.l	$6a025281,$2d41ff54,$e9c004c3,$122eff41
	dc.l	$307b0206,$4efb8802,$006c0000,$0000ff98
	dc.l	$003e0000,$00100000,$102eff54,$0c010007
	dc.l	$6f16206e,$000c61ff,$ffffeb86,$4a8166ff
	dc.l	$0000bca8,$6000ff6a,$02410007,$61ff0000
	dc.l	$a8046000,$ff5c302e,$ff540c01,$00076f16
	dc.l	$206e000c,$61ffffff,$eb6e4a81,$66ff0000
	dc.l	$bc886000,$ff3c0241,$000761ff,$0000a79a
	dc.l	$6000ff2e,$202eff54,$0c010007,$6f16206e
	dc.l	$000c61ff,$ffffeb56,$4a8166ff,$0000bc68
	dc.l	$6000ff0e,$02410007,$61ff0000,$a7306000
	dc.l	$ff004e56,$ff40f32e,$ff6c48ee,$0303ff9c
	dc.l	$f22ebc00,$ff60f22e,$f0c0ffdc,$2d6eff68
	dc.l	$ff44206e,$ff4458ae,$ff4461ff,$ffffea8a
	dc.l	$2d40ff40,$0800000d,$6600002a,$41eeff6c
	dc.l	$61ffffff,$f0a4f22e,$d0c0ffdc,$f22e9c00
	dc.l	$ff604cee,$0303ff9c,$f36eff6c,$4e5e60ff
	dc.l	$ffffe964,$e9c004c3,$122eff41,$307b0206
	dc.l	$4efb8802,$007400a6,$015a0000,$00420104
	dc.l	$00100000,$102eff70,$08c00006,$0c010007
	dc.l	$6f16206e,$000c61ff,$ffffea76,$4a8166ff
	dc.l	$0000bb98,$6000ffa0,$02410007,$61ff0000
	dc.l	$a6f46000,$ff92302e,$ff7008c0,$000e0c01
	dc.l	$00076f16,$206e000c,$61ffffff,$ea5a4a81
	dc.l	$66ff0000,$bb746000,$ff6e0241,$000761ff
	dc.l	$0000a686,$6000ff60,$202eff70,$08c0001e
	dc.l	$0c010007,$6f16206e,$000c61ff,$ffffea3e
	dc.l	$4a8166ff,$0000bb50,$6000ff3c,$02410007
	dc.l	$61ff0000,$a6186000,$ff2e0c01,$00076f2e
	dc.l	$202eff6c,$02808000,$00000080,$7fc00000
	dc.l	$222eff70,$e0898081,$206e000c,$61ffffff
	dc.l	$e9fc4a81,$66ff0000,$bb0e6000,$fefa202e
	dc.l	$ff6c0280,$80000000,$00807fc0,$00002f01
	dc.l	$222eff70,$e0898081,$221f0241,$000761ff
	dc.l	$0000a5ba,$6000fed0,$202eff6c,$02808000
	dc.l	$00000080,$7ff80000,$222eff70,$2d40ff84
	dc.l	$700be0a9,$83aeff84,$222eff70,$02810000
	dc.l	$07ffe0b9,$2d41ff88,$222eff74,$e0a983ae
	dc.l	$ff8841ee,$ff84226e,$000c7008,$61ffffff
	dc.l	$e8cc4a81,$66ff0000,$ba9c6000,$fe7a422e
	dc.l	$ff4a3d6e,$ff6cff84,$426eff86,$202eff70
	dc.l	$08c0001e,$2d40ff88,$2d6eff74,$ff8c082e
	dc.l	$00050004,$66384e68,$2d48ffd8,$2d56ffd4
	dc.l	$61ff0000,$98922248,$2d48000c,$206effd8
	dc.l	$4e602cae,$ffd441ee,$ff84700c,$61ffffff
	dc.l	$e86c4a81,$66ff0000,$ba4a6000,$fe1a2d56
	dc.l	$ffd461ff,$00009860,$22482d48,$000c2cae
	dc.l	$ffd40c2e,$0008ff4a,$66ccf22e,$d0c0ffdc
	dc.l	$f22e9c00,$ff604cee,$0303ff9c,$f36eff6c
	dc.l	$2c6effd4,$2f6f00c4,$00b82f6f,$00c800bc
	dc.l	$2f6f00cc,$00c02f6f,$004400c4,$2f6f0048
	dc.l	$00c82f6f,$004c00cc,$dffc0000,$00b860ff
	dc.l	$ffffe734,$4e56ff40,$f32eff6c,$48ee0303
	dc.l	$ff9cf22e,$bc00ff60,$f22ef0c0,$ffdc2d6e
	dc.l	$ff68ff44,$206eff44,$58aeff44,$61ffffff
	dc.l	$e7f82d40,$ff400800,$000d6600,$0106e9c0
	dc.l	$04c36622,$0c6e401e,$ff6c661a,$f23c9000
	dc.l	$00000000,$f22e4000,$ff70f22e,$6800ff6c
	dc.l	$3d7ce001,$ff6e41ee,$ff6c61ff,$ffffedea
	dc.l	$02ae00ff,$01ffff64,$f23c9000,$00000000
	dc.l	$f23c8800,$00000000,$e9ee1006,$ff420c01
	dc.l	$00176700,$009641ee,$ff6c61ff,$0000aa84
	dc.l	$1d40ff4e,$082e0005,$ff43672e,$082e0004
	dc.l	$ff436626,$e9ee0183,$ff4261ff,$0000a5c2
	dc.l	$41eeff78,$61ff0000,$aa5a0c00,$00066606
	dc.l	$61ff0000,$a9be1d40,$ff4f4280,$102eff63
	dc.l	$122eff43,$0241007f,$41eeff6c,$43eeff78
	dc.l	$223b1530,$000059ca,$4ebb1930,$000059c2
	dc.l	$e9ee0183,$ff4261ff,$0000a606,$f22ed0c0
	dc.l	$ffdcf22e,$9c00ff60,$4cee0303,$ff9cf36e
	dc.l	$ff6c4e5e,$60ffffff,$e5cc4280,$102eff63
	dc.l	$122eff43,$02810000,$007f61ff,$000043ce
	dc.l	$60be1d7c,$0000ff4e,$4280102e,$ff6302ae
	dc.l	$ffff00ff,$ff6441ee,$ff6c61ff,$00009be4
	dc.l	$60aa4e56,$ff40f32e,$ff6c48ee,$0303ff9c
	dc.l	$f22ebc00,$ff60f22e,$f0c0ffdc,$2d6eff68
	dc.l	$ff44206e,$ff4458ae,$ff4461ff,$ffffe69a
	dc.l	$2d40ff40,$41eeff6c,$61ffffff,$ecbcf22e
	dc.l	$d0c0ffdc,$f22e9c00,$ff604cee,$0303ff9c
	dc.l	$f36eff6c,$4e5e60ff,$ffffe592,$0c6f202c
	dc.l	$000667ff,$000000aa,$0c6f402c,$000667ff
	dc.l	$ffffe5a6,$4e56ff40,$48ee0303,$ff9c2d6e
	dc.l	$0006ff44,$206eff44,$58aeff44,$61ffffff
	dc.l	$e638e9c0,$100a0c41,$03c86664,$e9c01406
	dc.l	$0c010017,$665a4e7a,$08080800,$0001672a
	dc.l	$4cee0303,$ff9c4e5e,$518f3eaf,$00082f6f
	dc.l	$000a0002,$3f7c402c,$00062f6f,$0002000c
	dc.l	$58af0002,$60ffffff,$e5404cee,$0303ff9c
	dc.l	$4e5ef22f,$84000002,$58af0002,$2f172f6f
	dc.l	$00080004,$1f7c0020,$000660ff,$00000012
	dc.l	$4cee0303,$ff9c4e5e,$60ffffff,$e4f64e56
	dc.l	$ff4048ee,$0303ff9c,$f22ebc00,$ff60f22e
	dc.l	$f0c0ffdc,$082e0005,$00046608,$4e682d48
	dc.l	$ffd8600c,$41ee0010,$2d48ffd8,$2d48ffd4
	dc.l	$2d6eff68,$ff44206e,$ff4458ae,$ff4461ff
	dc.l	$ffffe576,$2d40ff40,$f23c9000,$00000000
	dc.l	$f23c8800,$00000000,$422eff4a,$08000016
	dc.l	$66000182,$422eff53,$02ae00ff,$00ffff64
	dc.l	$e9c01406,$0c010017,$670000be,$61ff0000
	dc.l	$95fc4280,$102eff63,$122eff43,$0241003f
	dc.l	$e749822e,$ff4e43ee,$ff7841ee,$ff6c323b
	dc.l	$132002b2,$4ebb1120,$02ac102e,$ff626600
	dc.l	$00a2e9ee,$0183ff42,$61ff0000,$a3e4f22e
	dc.l	$d0c0ffdc,$f22e9c00,$ff604cee,$0303ff9c
	dc.l	$0c2e0004,$ff4a672a,$0c2e0008,$ff4a6722
	dc.l	$4e5e0817,$000767ff,$ffffe358,$f327f22f
	dc.l	$a4000014,$f35f3f7c,$20240006,$60ffffff
	dc.l	$e434082e,$00050004,$660c2f08,$206effd8
	dc.l	$4e60205f,$60ca2f00,$202effd8,$90aeffd4
	dc.l	$2dae0008,$08082dae,$00040804,$3d400004
	dc.l	$201f4e5e,$ded760aa,$4280102e,$ff63122e
	dc.l	$ff430281,$0000007f,$61ff0000,$41506000
	dc.l	$ff5ac02e,$ff66edc0,$06086616,$082e0004
	dc.l	$ff666700,$ff4e082e,$0001ff62,$6700ff44
	dc.l	$603e0480,$00000018,$0c000006,$6610082e
	dc.l	$0004ff66,$662a082e,$0003ff66,$66302f00
	dc.l	$61ffffff,$f1ee201f,$3d7b0206,$ff6e602a
	dc.l	$e002e006,$e004e005,$e003e002,$e001e001
	dc.l	$61ffffff,$f1ce3d7c,$e005ff6e,$600c61ff
	dc.l	$fffff1c0,$3d7ce003,$ff6ef22e,$d0c0ffdc
	dc.l	$f22e9c00,$ff604cee,$0303ff9c,$f36eff6c
	dc.l	$6000feee,$e9c01283,$0c010001,$67000056
	dc.l	$0c010007,$66000078,$e9c01343,$0c010002
	dc.l	$6d00006c,$61ff0000,$82780c2e,$0002ff4a
	dc.l	$670000d2,$0c2e0001,$ff4a6600,$01002d6e
	dc.l	$ff68000c,$3d7c201c,$000af22e,$d0c0ffdc
	dc.l	$f22e9c00,$ff604cee,$0303ff9c,$4e5e60ff
	dc.l	$ffffe2dc,$206eff44,$54aeff44,$61ffffff
	dc.l	$e3524a81,$6600047c,$48c061ff,$00007e60
	dc.l	$0c2e0002,$ff4a6700,$007c6000,$00b061ff
	dc.l	$00008562,$0c2e0002,$ff4a6700,$0068082e
	dc.l	$00050004,$660a206e,$ffd84e60,$6000008e
	dc.l	$0c2e0008,$ff4a6600,$0084f22e,$d0c0ffdc
	dc.l	$f22e9c00,$ff604cee,$0303ff9c,$4e5e0817
	dc.l	$00076612,$558f2eaf,$00022f6f,$00060004
	dc.l	$60ffffff,$e17e558f,$2eaf0002,$3f6f0006
	dc.l	$00043f7c,$20240006,$f22fa400,$000860ff
	dc.l	$ffffe252,$3d7c00c0,$000e2d6e,$ff68000a
	dc.l	$3d6e0004,$00083d7c,$e000ff6e,$f22ed0c0
	dc.l	$ffdcf22e,$9c00ff60,$4cee0303,$ff9cf36e
	dc.l	$ff6c4e5e,$588f60ff,$ffffe180,$f22ed0c0
	dc.l	$ffdcf22e,$9c00ff60,$4cee0303,$ff9c4e5e
	dc.l	$08170007,$660660ff,$ffffe108,$f22fa400
	dc.l	$00081f7c,$00240007,$60ffffff,$e1e84afc
	dc.l	$01c00000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$000028a4,$4b1e4b4c,$4f4c2982,$4f3c0000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$000035c6,$4b1e4b82,$4f4c371a,$4f3c0000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$000024b0,$4b1e4b8c,$4f4c2766,$4f3c0000
	dc.l	$00002988,$4b1e4b94,$4f4c2af0,$4f3c0000
	dc.l	$00001ab8,$4b1e4bd0,$4f4c1cf6,$4f3c0000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00001cfc,$4b1e4744,$4f4c1daa,$4f3c0000
	dc.l	$00003720,$4b1e4744,$4f4c37a2,$4f3c0000
	dc.l	$00000468,$4b1e4744,$4f4c064c,$4f3c0000
	dc.l	$00000f2a,$4b1e4744,$4f4c108e,$4f3c0000
	dc.l	$000022e0,$4b9a4b7a,$4f4c248c,$4f3c0000
	dc.l	$00003d02,$4b9a4b7a,$4f4c3ddc,$4f3c0000
	dc.l	$00003dfa,$4b9a4b7a,$4f4c3f2a,$4f3c0000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00003386,$47324b82,$4f4c3538,$4f3c0000
	dc.l	$000037c8,$47324b82,$4f4c37f8,$4f3c0000
	dc.l	$00003818,$47324b82,$4f4c3872,$4f3c0000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$000027e6,$4b9a4b52,$4f4c288a,$4f3c0000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00001db0,$4bd64744,$4f4c1e40,$4f3c0000
	dc.l	$00000472,$4b9a4744,$4f4c0652,$4f3c0000
	dc.l	$0000276c,$4b1e4744,$4f4c2788,$4f3c0000
	dc.l	$000027a0,$4b1e4744,$4f4c27ce,$4f3c0000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00004ca4,$4cda4d12,$4ee24ca4,$4ef40000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00004dac,$4de24e1a,$4ee24dac,$4ef40000
	dc.l	$00004e4e,$4e864ebe,$4ee24e4e,$4ef40000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000660,$4bf24c20,$4c3008f6,$4c400000
	dc.l	$00000660,$4bf24c20,$4c3008f6,$4c400000
	dc.l	$00000660,$4bf24c20,$4c3008f6,$4c400000
	dc.l	$00000660,$4bf24c20,$4c3008f6,$4c400000
	dc.l	$00000660,$4bf24c20,$4c3008f6,$4c400000
	dc.l	$00000660,$4bf24c20,$4c3008f6,$4c400000
	dc.l	$00000660,$4bf24c20,$4c3008f6,$4c400000
	dc.l	$00000660,$4bf24c20,$4c3008f6,$4c400000
	dc.l	$00004cee,$0303ff9c,$f22e9c00,$ff60f22e
	dc.l	$d0c0ffdc,$2d6eff68,$00064e5e,$2f173f6f
	dc.l	$00080004,$3f7c4008,$00062f6f,$00020008
	dc.l	$2f7c0942,$8001000c,$08170005,$670608ef
	dc.l	$0002000d,$60ffffff,$de32bd6a,$aa77ccc9
	dc.l	$94f53de6,$12097aae,$8da1be5a,$e6452a11
	dc.l	$8ae43ec7,$1de3a534,$1531bf2a,$01a01a01
	dc.l	$8b590000,$00000000,$00003ff8,$00008888
	dc.l	$88888888,$59af0000,$0000bffc,$0000aaaa
	dc.l	$aaaaaaaa,$aa990000,$00003d2a,$c4d0d601
	dc.l	$1ee3bda9,$396f9f45,$ac193e21,$eed90612
	dc.l	$c972be92,$7e4fb79d,$9fcf3efa,$01a01a01
	dc.l	$d4230000,$00000000,$0000bff5,$0000b60b
	dc.l	$60b60b61,$d4380000,$00003ffa,$0000aaaa
	dc.l	$aaaaaaaa,$ab5ebf00,$00002d7c,$00000000
	dc.l	$ff5c6008,$2d7c0000,$0001ff5c,$f2104800
	dc.l	$f22e6800,$ff842210,$32280004,$02817fff
	dc.l	$ffff0c81,$3fd78000,$6c046000,$01780c81
	dc.l	$4004bc7e,$6d046000,$0468f200,$0080f23a
	dc.l	$54a3de7e,$43fb0170,$00000866,$f22e6080
	dc.l	$ff58222e,$ff58e981,$d3c1f219,$4828f211
	dc.l	$4428222e,$ff58d2ae,$ff5ce299,$0c810000
	dc.l	$00006d00,$0088f227,$e00cf22e,$6800ff84
	dc.l	$f2000023,$f23a5580,$fed2f23a,$5500fed4
	dc.l	$f2000080,$f20004a3,$e2990281,$80000000
	dc.l	$b3aeff84,$f20005a3,$f2000523,$f23a55a2
	dc.l	$febaf23a,$5522febc,$f20005a3,$f2000523
	dc.l	$f23a55a2,$feb6f23a,$4922fec0,$f2000ca3
	dc.l	$f2000123,$f23a48a2,$fec2f22e,$4823ff84
	dc.l	$f20008a2,$f2000423,$f21fd030,$f2009000
	dc.l	$f22e4822,$ff8460ff,$00004364,$f227e00c
	dc.l	$f2000023,$f23a5500,$fea2f23a,$5580fea4
	dc.l	$f2000080,$f20004a3,$f22e6800,$ff84e299
	dc.l	$02818000,$0000f200,$0523b3ae,$ff840281
	dc.l	$80000000,$f20005a3,$00813f80,$00002d41
	dc.l	$ff54f23a,$5522fe74,$f23a55a2,$fe76f200
	dc.l	$0523f200,$05a3f23a,$5522fe70,$f23a49a2
	dc.l	$fe7af200,$0523f200,$0ca3f23a,$4922fe7c
	dc.l	$f23a44a2,$fe82f200,$0823f200,$0422f22e
	dc.l	$4823ff84,$f21fd030,$f2009000,$f22e4422
	dc.l	$ff5460ff,$000042c8,$0c813fff,$80006eff
	dc.l	$00000300,$222eff5c,$0c810000,$00006e14
	dc.l	$f2009000,$123c0003,$f22e4800,$ff8460ff
	dc.l	$0000428e,$f23c4400,$3f800000,$f2009000
	dc.l	$f23c4422,$80800000,$60ff0000,$428a60ff
	dc.l	$00004110,$f23c4400,$3f800000,$60ff0000
	dc.l	$42762d7c,$00000004,$ff5cf210,$4800f22e
	dc.l	$6800ff84,$22103228,$00040281,$7fffffff
	dc.l	$0c813fd7,$80006c04,$60000240,$0c814004
	dc.l	$bc7e6d04,$6000027a,$f2000080,$f23a54a3
	dc.l	$dc9043fb,$01700000,$0678f22e,$6080ff58
	dc.l	$222eff58,$e981d3c1,$f2194828,$f2114428
	dc.l	$222eff58,$e2990c81,$00000000,$6c000106
	dc.l	$f227e004,$f22e6800,$ff84f200,$0023f23a
	dc.l	$5480fce8,$f23a5500,$fd32f200,$00a3f200
	dc.l	$01232f02,$2401e29a,$02828000,$0000b382
	dc.l	$02828000,$0000f23a,$54a2fcc8,$f23a5522
	dc.l	$fd12f200,$00a3b5ae,$ff84241f,$f2000123
	dc.l	$e2990281,$80000000,$2d7c3f80,$0000ff54
	dc.l	$b3aeff54,$f23a54a2,$fca2f23a,$5522fcec
	dc.l	$f20000a3,$f2000123,$f22e6800,$ff90f23a
	dc.l	$54a2fc90,$b3aeff90,$f23a5522,$fcd6f200
	dc.l	$00a3f200,$0123f23a,$54a2fc80,$f23a5522
	dc.l	$fccaf200,$00a3f200,$0123f23a,$48a2fc7c
	dc.l	$f23a4922,$fcc6f200,$00a3f200,$0123f23a
	dc.l	$48a2fc78,$f23a4922,$fcc2f200,$00a3f200
	dc.l	$0823f22e,$48a3ff84,$f23a4422,$fcbaf22e
	dc.l	$4823ff90,$f21fd020,$f2009000,$f22e48a2
	dc.l	$ff8461ff,$0000448e,$f22e4422,$ff5460ff
	dc.l	$000040fc,$f227e004,$f22e6800,$ff84f200
	dc.l	$0023f23a,$5480fc34,$f23a5500,$fbdef200
	dc.l	$00a3f22e,$6800ff90,$f2000123,$e2990281
	dc.l	$80000000,$f23a54a2,$fc1af23a,$5522fbc4
	dc.l	$b3aeff84,$b3aeff90,$f20000a3,$00813f80
	dc.l	$00002d41,$ff54f200,$0123f23a,$54a2fbfc
	dc.l	$f23a5522,$fba6f200,$00a3f200,$0123f23a
	dc.l	$54a2fbf0,$f23a5522,$fb9af200,$00a3f200
	dc.l	$0123f23a,$54a2fbe4,$f23a5522,$fb8ef200
	dc.l	$00a3f200,$0123f23a,$48a2fbe0,$f23a4922
	dc.l	$fb8af200,$00a3f200,$0123f23a,$48a2fbdc
	dc.l	$f23a4922,$fb86f200,$00a3f200,$0823f23a
	dc.l	$44a2fbd4,$f22e4823,$ff84f22e,$48a3ff90
	dc.l	$f21fd020,$f2009000,$f22e44a2,$ff5461ff
	dc.l	$000043a2,$f22e4822,$ff8460ff,$00004010
	dc.l	$0c813fff,$80006e00,$0048f23c,$44803f80
	dc.l	$0000f200,$9000f23c,$44a80080,$000061ff
	dc.l	$00004372,$f200b000,$123c0003,$f22e4800
	dc.l	$ff8460ff,$00003fca,$2f00f23c,$44803f80
	dc.l	$000061ff,$0000434e,$201f60ff,$00003e54
	dc.l	$f227e03c,$2f02f23c,$44800000,$00000c81
	dc.l	$7ffeffff,$66523d7c,$7ffeff84,$2d7cc90f
	dc.l	$daa2ff88,$42aeff8c,$3d7c7fdc,$ff902d7c
	dc.l	$85a308d3,$ff9442ae,$ff98f200,$003af294
	dc.l	$000e002e,$0080ff84,$002e0080,$ff90f22e
	dc.l	$4822ff84,$f2000080,$f22e4822,$ff90f200
	dc.l	$00a8f22e,$48a2ff90,$f22e6800,$ff84322e
	dc.l	$ff842241,$02810000,$7fff0481,$00003fff
	dc.l	$0c810000,$001c6f0e,$04810000,$001b1d7c
	dc.l	$0000ff58,$60084281,$1d7c0001,$ff58243c
	dc.l	$00003ffe,$94812d7c,$a2f9836e,$ff882d7c
	dc.l	$4e44152a,$ff8c3d42,$ff84f200,$0100f22e
	dc.l	$4923ff84,$24094842,$02828000,$00000082
	dc.l	$5f000000,$2d42ff54,$f22e4522,$ff54f22e
	dc.l	$4528ff54,$24010682,$00003fff,$3d42ff84
	dc.l	$2d7cc90f,$daa2ff88,$42aeff8c,$06810000
	dc.l	$3fdd3d41,$ff902d7c,$85a308d3,$ff9442ae
	dc.l	$ff98122e,$ff58f200,$0a00f22e,$4a23ff84
	dc.l	$f2000a80,$f22e4aa3,$ff90f200,$1180f200
	dc.l	$15a2f200,$0e28f200,$0c28f200,$1622f200
	dc.l	$0180f200,$10a8f200,$04220c01,$00006e00
	dc.l	$000ef200,$01a8f200,$0ca26000,$ff0cf22e
	dc.l	$6100ff58,$241ff21f,$d03c222e,$ff5c0c81
	dc.l	$00000004,$6d00fa4c,$6000fc36,$3ea0b759
	dc.l	$f50f8688,$bef2baa5,$a8924f04,$bf346f59
	dc.l	$b39ba65f,$00000000,$00000000,$3ff60000
	dc.l	$e073d3fc,$199c4a00,$00000000,$3ff90000
	dc.l	$d23cd684,$15d95fa1,$00000000,$bffc0000
	dc.l	$8895a6c5,$fb423bca,$00000000,$bffd0000
	dc.l	$eef57e0d,$a84bc8ce,$00000000,$3ffc0000
	dc.l	$a2f9836e,$4e44152a,$00000000,$40010000
	dc.l	$c90fdaa2,$00000000,$00000000,$3fdf0000
	dc.l	$85a308d4,$00000000,$00000000,$c0040000
	dc.l	$c90fdaa2,$2168c235,$21800000,$c0040000
	dc.l	$c2c75bcd,$105d7c23,$a0d00000,$c0040000
	dc.l	$bc7edcf7,$ff523611,$a1e80000,$c0040000
	dc.l	$b6365e22,$ee46f000,$21480000,$c0040000
	dc.l	$afeddf4d,$dd3ba9ee,$a1200000,$c0040000
	dc.l	$a9a56078,$cc3063dd,$21fc0000,$c0040000
	dc.l	$a35ce1a3,$bb251dcb,$21100000,$c0040000
	dc.l	$9d1462ce,$aa19d7b9,$a1580000,$c0040000
	dc.l	$96cbe3f9,$990e91a8,$21e00000,$c0040000
	dc.l	$90836524,$88034b96,$20b00000,$c0040000
	dc.l	$8a3ae64f,$76f80584,$a1880000,$c0040000
	dc.l	$83f2677a,$65ecbf73,$21c40000,$c0030000
	dc.l	$fb53d14a,$a9c2f2c2,$20000000,$c0030000
	dc.l	$eec2d3a0,$87ac669f,$21380000,$c0030000
	dc.l	$e231d5f6,$6595da7b,$a1300000,$c0030000
	dc.l	$d5a0d84c,$437f4e58,$9fc00000,$c0030000
	dc.l	$c90fdaa2,$2168c235,$21000000,$c0030000
	dc.l	$bc7edcf7,$ff523611,$a1680000,$c0030000
	dc.l	$afeddf4d,$dd3ba9ee,$a0a00000,$c0030000
	dc.l	$a35ce1a3,$bb251dcb,$20900000,$c0030000
	dc.l	$96cbe3f9,$990e91a8,$21600000,$c0030000
	dc.l	$8a3ae64f,$76f80584,$a1080000,$c0020000
	dc.l	$fb53d14a,$a9c2f2c2,$1f800000,$c0020000
	dc.l	$e231d5f6,$6595da7b,$a0b00000,$c0020000
	dc.l	$c90fdaa2,$2168c235,$20800000,$c0020000
	dc.l	$afeddf4d,$dd3ba9ee,$a0200000,$c0020000
	dc.l	$96cbe3f9,$990e91a8,$20e00000,$c0010000
	dc.l	$fb53d14a,$a9c2f2c2,$1f000000,$c0010000
	dc.l	$c90fdaa2,$2168c235,$20000000,$c0010000
	dc.l	$96cbe3f9,$990e91a8,$20600000,$c0000000
	dc.l	$c90fdaa2,$2168c235,$1f800000,$bfff0000
	dc.l	$c90fdaa2,$2168c235,$1f000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$3fff0000
	dc.l	$c90fdaa2,$2168c235,$9f000000,$40000000
	dc.l	$c90fdaa2,$2168c235,$9f800000,$40010000
	dc.l	$96cbe3f9,$990e91a8,$a0600000,$40010000
	dc.l	$c90fdaa2,$2168c235,$a0000000,$40010000
	dc.l	$fb53d14a,$a9c2f2c2,$9f000000,$40020000
	dc.l	$96cbe3f9,$990e91a8,$a0e00000,$40020000
	dc.l	$afeddf4d,$dd3ba9ee,$20200000,$40020000
	dc.l	$c90fdaa2,$2168c235,$a0800000,$40020000
	dc.l	$e231d5f6,$6595da7b,$20b00000,$40020000
	dc.l	$fb53d14a,$a9c2f2c2,$9f800000,$40030000
	dc.l	$8a3ae64f,$76f80584,$21080000,$40030000
	dc.l	$96cbe3f9,$990e91a8,$a1600000,$40030000
	dc.l	$a35ce1a3,$bb251dcb,$a0900000,$40030000
	dc.l	$afeddf4d,$dd3ba9ee,$20a00000,$40030000
	dc.l	$bc7edcf7,$ff523611,$21680000,$40030000
	dc.l	$c90fdaa2,$2168c235,$a1000000,$40030000
	dc.l	$d5a0d84c,$437f4e58,$1fc00000,$40030000
	dc.l	$e231d5f6,$6595da7b,$21300000,$40030000
	dc.l	$eec2d3a0,$87ac669f,$a1380000,$40030000
	dc.l	$fb53d14a,$a9c2f2c2,$a0000000,$40040000
	dc.l	$83f2677a,$65ecbf73,$a1c40000,$40040000
	dc.l	$8a3ae64f,$76f80584,$21880000,$40040000
	dc.l	$90836524,$88034b96,$a0b00000,$40040000
	dc.l	$96cbe3f9,$990e91a8,$a1e00000,$40040000
	dc.l	$9d1462ce,$aa19d7b9,$21580000,$40040000
	dc.l	$a35ce1a3,$bb251dcb,$a1100000,$40040000
	dc.l	$a9a56078,$cc3063dd,$a1fc0000,$40040000
	dc.l	$afeddf4d,$dd3ba9ee,$21200000,$40040000
	dc.l	$b6365e22,$ee46f000,$a1480000,$40040000
	dc.l	$bc7edcf7,$ff523611,$21e80000,$40040000
	dc.l	$c2c75bcd,$105d7c23,$20d00000,$40040000
	dc.l	$c90fdaa2,$2168c235,$a1800000,$f2104800
	dc.l	$22103228,$00040281,$7fffffff,$0c813fd7
	dc.l	$80006c04,$60000134,$0c814004,$bc7e6d04
	dc.l	$60000144,$f2000080,$f23a54a3,$d3d443fa
	dc.l	$fdbcf201,$6080e981,$d3c1f219,$4828f211
	dc.l	$4428ea99,$02818000,$0000f227,$e00c0c81
	dc.l	$00000000,$6d000072,$f2000080,$f20004a3
	dc.l	$f23a5580,$faf8f23a,$5500fafa,$f20005a3
	dc.l	$f2000523,$f23a55a2,$faf4f23a,$4922fafe
	dc.l	$f20005a3,$f2000523,$f23a49a2,$fb00f23a
	dc.l	$4922fb0a,$f20005a3,$f2000523,$f23a49a2
	dc.l	$fb0cf200,$0123f200,$0ca3f200,$0822f23c
	dc.l	$44a23f80,$0000f21f,$d030f200,$9000f200
	dc.l	$042060ff,$000038d8,$f2000080,$f2000023
	dc.l	$f23a5580,$fa88f23a,$5500fa8a,$f20001a3
	dc.l	$f2000123,$f23a55a2,$fa84f23a,$4922fa8e
	dc.l	$f20001a3,$f2000123,$f23a49a2,$fa90f23a
	dc.l	$4922fa9a,$f20001a3,$f2000123,$f23a49a2
	dc.l	$fa9cf200,$0523f200,$0c23f200,$08a2f23c
	dc.l	$44223f80,$0000f21f,$d030f227,$68800a97
	dc.l	$80000000,$f2009000,$f21f4820,$60ff0000
	dc.l	$385e0c81,$3fff8000,$6e1cf227,$6800f200
	dc.l	$9000123c,$0003f21f,$480060ff,$00003832
	dc.l	$60ff0000,$36cef227,$e03c2f02,$f23c4480
	dc.l	$00000000,$0c817ffe,$ffff6652,$3d7c7ffe
	dc.l	$ff842d7c,$c90fdaa2,$ff8842ae,$ff8c3d7c
	dc.l	$7fdcff90,$2d7c85a3,$08d3ff94,$42aeff98
	dc.l	$f200003a,$f294000e,$002e0080,$ff84002e
	dc.l	$0080ff90,$f22e4822,$ff84f200,$0080f22e
	dc.l	$4822ff90,$f20000a8,$f22e48a2,$ff90f22e
	dc.l	$6800ff84,$322eff84,$22410281,$00007fff
	dc.l	$04810000,$3fff0c81,$0000001c,$6f0e0481
	dc.l	$0000001b,$1d7c0000,$ff586008,$42811d7c
	dc.l	$0001ff58,$243c0000,$3ffe9481,$2d7ca2f9
	dc.l	$836eff88,$2d7c4e44,$152aff8c,$3d42ff84
	dc.l	$f2000100,$f22e4923,$ff842409,$48420282
	dc.l	$80000000,$00825f00,$00002d42,$ff54f22e
	dc.l	$4522ff54,$f22e4528,$ff542401,$06820000
	dc.l	$3fff3d42,$ff842d7c,$c90fdaa2,$ff8842ae
	dc.l	$ff8c0681,$00003fdd,$3d41ff90,$2d7c85a3
	dc.l	$08d3ff94,$42aeff98,$122eff58,$f2000a00
	dc.l	$f22e4a23,$ff84f200,$0a80f22e,$4aa3ff90
	dc.l	$f2001180,$f20015a2,$f2000e28,$f2000c28
	dc.l	$f2001622,$f2000180,$f20010a8,$f2000422
	dc.l	$0c010000,$6e00000e,$f20001a8,$f2000ca2
	dc.l	$6000ff0c,$f22e6100,$ff54241f,$f21fd03c
	dc.l	$222eff54,$e2996000,$fd72bff6,$687e3149
	dc.l	$87d84002,$ac6934a2,$6db3bfc2,$476f4e1d
	dc.l	$a28e3fb3,$44447f87,$6989bfb7,$44ee7faf
	dc.l	$45db3fbc,$71c64694,$0220bfc2,$49249218
	dc.l	$72f93fc9,$99999999,$8fa9bfd5,$55555555
	dc.l	$5555bfb7,$0bf39853,$9e6a3fbc,$7187962d
	dc.l	$1d7dbfc2,$49248271,$07b83fc9,$99999996
	dc.l	$263ebfd5,$55555555,$55363fff,$0000c90f
	dc.l	$daa22168,$c2350000,$0000bfff,$0000c90f
	dc.l	$daa22168,$c2350000,$00000001,$00008000
	dc.l	$00000000,$00000000,$00008001,$00008000
	dc.l	$00000000,$00000000,$00003ffb,$000083d1
	dc.l	$52c5060b,$7a510000,$00003ffb,$00008bc8
	dc.l	$54456549,$8b8b0000,$00003ffb,$000093be
	dc.l	$40601762,$6b0d0000,$00003ffb,$00009bb3
	dc.l	$078d35ae,$c2020000,$00003ffb,$0000a3a6
	dc.l	$9a525ddc,$e7de0000,$00003ffb,$0000ab98
	dc.l	$e9436276,$56190000,$00003ffb,$0000b389
	dc.l	$e502f9c5,$98620000,$00003ffb,$0000bb79
	dc.l	$7e436b09,$e6fb0000,$00003ffb,$0000c367
	dc.l	$a5c739e5,$f4460000,$00003ffb,$0000cb54
	dc.l	$4c61cff7,$d5c60000,$00003ffb,$0000d33f
	dc.l	$62f82488,$533e0000,$00003ffb,$0000db28
	dc.l	$da816240,$4c770000,$00003ffb,$0000e310
	dc.l	$a4078ad3,$4f180000,$00003ffb,$0000eaf6
	dc.l	$b0a8188e,$e1eb0000,$00003ffb,$0000f2da
	dc.l	$f1949dbe,$79d50000,$00003ffb,$0000fabd
	dc.l	$581361d4,$7e3e0000,$00003ffc,$00008346
	dc.l	$ac210959,$ecc40000,$00003ffc,$00008b23
	dc.l	$2a083042,$82d80000,$00003ffc,$000092fb
	dc.l	$70b8d29a,$e2f90000,$00003ffc,$00009acf
	dc.l	$476f5ccd,$1cb40000,$00003ffc,$0000a29e
	dc.l	$76304954,$f23f0000,$00003ffc,$0000aa68
	dc.l	$c5d08ab8,$52300000,$00003ffc,$0000b22d
	dc.l	$fffd9d53,$9f830000,$00003ffc,$0000b9ed
	dc.l	$ef453e90,$0ea50000,$00003ffc,$0000c1a8
	dc.l	$5f1cc75e,$3ea50000,$00003ffc,$0000c95d
	dc.l	$1be82813,$8de60000,$00003ffc,$0000d10b
	dc.l	$f300840d,$2de40000,$00003ffc,$0000d8b4
	dc.l	$b2ba6bc0,$5e7a0000,$00003ffc,$0000e057
	dc.l	$2a6bb423,$35f60000,$00003ffc,$0000e7f3
	dc.l	$2a70ea9c,$aa8f0000,$00003ffc,$0000ef88
	dc.l	$843264ec,$efaa0000,$00003ffc,$0000f717
	dc.l	$0a28ecc0,$66660000,$00003ffd,$0000812f
	dc.l	$d288332d,$ad320000,$00003ffd,$000088a8
	dc.l	$d1b1218e,$4d640000,$00003ffd,$00009012
	dc.l	$ab3f23e4,$aee80000,$00003ffd,$0000976c
	dc.l	$c3d411e7,$f1b90000,$00003ffd,$00009eb6
	dc.l	$89493889,$a2270000,$00003ffd,$0000a5ef
	dc.l	$72c34487,$361b0000,$00003ffd,$0000ad17
	dc.l	$00baf07a,$72270000,$00003ffd,$0000b42c
	dc.l	$bcfafd37,$efb70000,$00003ffd,$0000bb30
	dc.l	$3a940ba8,$0f890000,$00003ffd,$0000c221
	dc.l	$15c6fcae,$bbaf0000,$00003ffd,$0000c8fe
	dc.l	$f3e68633,$12210000,$00003ffd,$0000cfc9
	dc.l	$8330b400,$0c700000,$00003ffd,$0000d680
	dc.l	$7aa1102c,$5bf90000,$00003ffd,$0000dd23
	dc.l	$99bc3125,$2aa30000,$00003ffd,$0000e3b2
	dc.l	$a8556b8f,$c5170000,$00003ffd,$0000ea2d
	dc.l	$764f6431,$59890000,$00003ffd,$0000f3bf
	dc.l	$5bf8bad1,$a21d0000,$00003ffe,$0000801c
	dc.l	$e39e0d20,$5c9a0000,$00003ffe,$00008630
	dc.l	$a2dada1e,$d0660000,$00003ffe,$00008c1a
	dc.l	$d445f3e0,$9b8c0000,$00003ffe,$000091db
	dc.l	$8f1664f3,$50e20000,$00003ffe,$00009773
	dc.l	$1420365e,$538c0000,$00003ffe,$00009ce1
	dc.l	$c8e6a0b8,$cdba0000,$00003ffe,$0000a228
	dc.l	$32dbcada,$ae090000,$00003ffe,$0000a746
	dc.l	$f2ddb760,$22940000,$00003ffe,$0000ac3e
	dc.l	$c0fb997d,$d6a20000,$00003ffe,$0000b110
	dc.l	$688aebdc,$6f6a0000,$00003ffe,$0000b5bc
	dc.l	$c49059ec,$c4b00000,$00003ffe,$0000ba44
	dc.l	$bc7dd470,$782f0000,$00003ffe,$0000bea9
	dc.l	$4144fd04,$9aac0000,$00003ffe,$0000c2eb
	dc.l	$4abb6616,$28b60000,$00003ffe,$0000c70b
	dc.l	$d54ce602,$ee140000,$00003ffe,$0000cd00
	dc.l	$0549adec,$71590000,$00003ffe,$0000d484
	dc.l	$57d2d8ea,$4ea30000,$00003ffe,$0000db94
	dc.l	$8da712de,$ce3b0000,$00003ffe,$0000e238
	dc.l	$55f969e8,$096a0000,$00003ffe,$0000e877
	dc.l	$1129c435,$32590000,$00003ffe,$0000ee57
	dc.l	$c16e0d37,$9c0d0000,$00003ffe,$0000f3e1
	dc.l	$0211a87c,$37790000,$00003ffe,$0000f919
	dc.l	$039d758b,$8d410000,$00003ffe,$0000fe05
	dc.l	$8b8f6493,$5fb30000,$00003fff,$00008155
	dc.l	$fb497b68,$5d040000,$00003fff,$00008388
	dc.l	$9e3549d1,$08e10000,$00003fff,$0000859c
	dc.l	$fa76511d,$724b0000,$00003fff,$00008795
	dc.l	$2ecfff81,$31e70000,$00003fff,$00008973
	dc.l	$2fd19557,$641b0000,$00003fff,$00008b38
	dc.l	$cad10193,$2a350000,$00003fff,$00008ce7
	dc.l	$a8d8301e,$e6b50000,$00003fff,$00008f46
	dc.l	$a39e2eae,$52810000,$00003fff,$0000922d
	dc.l	$a7d79188,$84870000,$00003fff,$000094d1
	dc.l	$9fcbdedf,$52410000,$00003fff,$0000973a
	dc.l	$b94419d2,$a08b0000,$00003fff,$0000996f
	dc.l	$f00e08e1,$0b960000,$00003fff,$00009b77
	dc.l	$3f951232,$1da70000,$00003fff,$00009d55
	dc.l	$cc320f93,$56240000,$00003fff,$00009f10
	dc.l	$0575006c,$c5710000,$00003fff,$0000a0a9
	dc.l	$c290d97c,$c06c0000,$00003fff,$0000a226
	dc.l	$59ebebc0,$630a0000,$00003fff,$0000a388
	dc.l	$b4aff6ef,$0ec90000,$00003fff,$0000a4d3
	dc.l	$5f1061d2,$92c40000,$00003fff,$0000a608
	dc.l	$95dcfbe3,$187e0000,$00003fff,$0000a72a
	dc.l	$51dc7367,$beac0000,$00003fff,$0000a83a
	dc.l	$51530956,$168f0000,$00003fff,$0000a93a
	dc.l	$20077539,$546e0000,$00003fff,$0000aa9e
	dc.l	$7245023b,$26050000,$00003fff,$0000ac4c
	dc.l	$84ba6fe4,$d58f0000,$00003fff,$0000adce
	dc.l	$4a4a606b,$97120000,$00003fff,$0000af2a
	dc.l	$2dcd8d26,$3c9c0000,$00003fff,$0000b065
	dc.l	$6f81f222,$65c70000,$00003fff,$0000b184
	dc.l	$65150f71,$496a0000,$00003fff,$0000b28a
	dc.l	$aa156f9a,$da350000,$00003fff,$0000b37b
	dc.l	$44ff3766,$b8950000,$00003fff,$0000b458
	dc.l	$c3dce963,$04330000,$00003fff,$0000b525
	dc.l	$529d5622,$46bd0000,$00003fff,$0000b5e2
	dc.l	$cca95f9d,$88cc0000,$00003fff,$0000b692
	dc.l	$cada7aca,$1ada0000,$00003fff,$0000b736
	dc.l	$aea7a692,$58380000,$00003fff,$0000b7cf
	dc.l	$ab287e9f,$7b360000,$00003fff,$0000b85e
	dc.l	$cc66cb21,$98350000,$00003fff,$0000b8e4
	dc.l	$fd5a20a5,$93da0000,$00003fff,$0000b99f
	dc.l	$41f64aff,$9bb50000,$00003fff,$0000ba7f
	dc.l	$1e17842b,$be7b0000,$00003fff,$0000bb47
	dc.l	$12857637,$e17d0000,$00003fff,$0000bbfa
	dc.l	$be8a4788,$df6f0000,$00003fff,$0000bc9d
	dc.l	$0fad2b68,$9d790000,$00003fff,$0000bd30
	dc.l	$6a39471e,$cd860000,$00003fff,$0000bdb6
	dc.l	$c731856a,$f18a0000,$00003fff,$0000be31
	dc.l	$cac502e8,$0d700000,$00003fff,$0000bea2
	dc.l	$d55ce331,$94e20000,$00003fff,$0000bf0b
	dc.l	$10b7c031,$28f00000,$00003fff,$0000bf6b
	dc.l	$7a18dacb,$778d0000,$00003fff,$0000bfc4
	dc.l	$ea4663fa,$18f60000,$00003fff,$0000c018
	dc.l	$1bde8b89,$a4540000,$00003fff,$0000c065
	dc.l	$b066cfbf,$64390000,$00003fff,$0000c0ae
	dc.l	$345f5634,$0ae60000,$00003fff,$0000c0f2
	dc.l	$22919cb9,$e6a70000,$0000f210,$48002210
	dc.l	$32280004,$f22e6800,$ff840281,$7fffffff
	dc.l	$0c813ffb,$80006c04,$600000d0,$0c814002
	dc.l	$ffff6f04,$6000014c,$02aef800,$0000ff88
	dc.l	$00ae0400,$0000ff88,$2d7c0000,$0000ff8c
	dc.l	$f2000080,$f22e48a3,$ff84f22e,$4828ff84
	dc.l	$f23c44a2,$3f800000,$f2000420,$2f022401
	dc.l	$02810000,$78000282,$7fff0000,$04823ffb
	dc.l	$0000e282,$d282ee81,$43faf780,$d3c12d59
	dc.l	$ff902d59,$ff942d59,$ff98222e,$ff840281
	dc.l	$80000000,$83aeff90,$241ff227,$e004f200
	dc.l	$0080f200,$04a3f23a,$5500f6a0,$f2000522
	dc.l	$f2000523,$f20000a3,$f23a5522,$f696f23a
	dc.l	$54a3f698,$f20008a3,$f2000422,$f21fd020
	dc.l	$f2009000,$f22e4822,$ff9060ff,$00002d30
	dc.l	$0c813fff,$80006e00,$008a0c81,$3fd78000
	dc.l	$6d00006c,$f227e00c,$f2000023,$f2000080
	dc.l	$f20004a3,$f23a5500,$f65af23a,$5580f65c
	dc.l	$f2000523,$f20005a3,$f23a5522,$f656f23a
	dc.l	$55a2f658,$f2000523,$f2000ca3,$f23a5522
	dc.l	$f652f23a,$54a2f654,$f2000123,$f22e4823
	dc.l	$ff84f200,$08a2f200,$0423f21f,$d030f200
	dc.l	$9000f22e,$4822ff84,$60ff0000,$2cb2f200
	dc.l	$9000123c,$0003f22e,$4800ff84,$60ff0000
	dc.l	$2c900c81,$40638000,$6e00008e,$f227e00c
	dc.l	$f23c4480,$bf800000,$f20000a0,$f2000400
	dc.l	$f2000023,$f22e6880,$ff84f200,$0080f200
	dc.l	$04a3f23a,$5580f5ec,$f23a5500,$f5eef200
	dc.l	$05a3f200,$0523f23a,$55a2f5e8,$f23a5522
	dc.l	$f5eaf200,$0ca3f200,$0123f23a,$54a2f5e4
	dc.l	$f22e4823,$ff84f200,$08a2f200,$0423f22e
	dc.l	$4822ff84,$f21fd030,$f2009000,$4a106a0c
	dc.l	$f23a4822,$f5d660ff,$00002c24,$f23a4822
	dc.l	$f5ba60ff,$00002c10,$4a106a16,$f23a4800
	dc.l	$f5baf200,$9000f23a,$4822f5c0,$60ff0000
	dc.l	$2bfef23a,$4800f594,$f2009000,$f23a4822
	dc.l	$f5ba60ff,$00002be0,$60ff0000,$2a66f210
	dc.l	$48002210,$32280004,$02817fff,$ffff0c81
	dc.l	$3fff8000,$6c4e0c81,$3fd78000,$6d00007c
	dc.l	$f23c4480,$3f800000,$f20000a8,$f227e004
	dc.l	$f23c4500,$3f800000,$f2000122,$f20008a3
	dc.l	$f21fd020,$f2000484,$f2000420,$f227e001
	dc.l	$41d761ff,$fffffd66,$dffc0000,$000c60ff
	dc.l	$00002b6c,$f2000018,$f23c4438,$3f800000
	dc.l	$f2d20000,$29d4f23a,$4800c5a6,$22100281
	dc.l	$80000000,$00813f80,$00002f01,$f2009000
	dc.l	$f21f4423,$60ff0000,$2b36f200,$9000123c
	dc.l	$0003f210,$480060ff,$00002b16,$60ff0000
	dc.l	$29b2f210,$48002210,$32280004,$02817fff
	dc.l	$ffff0c81,$3fff8000,$6c44f23c,$44803f80
	dc.l	$0000f200,$00a2f200,$001af23c,$44223f80
	dc.l	$0000f200,$0420f200,$00042f00,$4280f227
	dc.l	$e00141d7,$61ffffff,$fcc4dffc,$0000000c
	dc.l	$f21f9000,$f2000022,$60ff0000,$2acaf200
	dc.l	$0018f23c,$44383f80,$0000f2d2,$0000292a
	dc.l	$4a106a18,$f23a4800,$c4e8f200,$9000f23c
	dc.l	$44220080,$000060ff,$00002a9c,$60ff0000
	dc.l	$2ce8f200,$9000f23a,$4800c4d6,$60ff0000
	dc.l	$2a863fdc,$000082e3,$08654361,$c4c60000
	dc.l	$00003fa5,$55555555,$4cc13fc5,$55555555
	dc.l	$4a543f81,$11111117,$43853fa5,$55555555
	dc.l	$4f5a3fc5,$55555555,$55550000,$00000000
	dc.l	$00003ec7,$1de3a577,$46823efa,$01a019d7
	dc.l	$cb683f2a,$01a01a01,$9df33f56,$c16c16c1
	dc.l	$70e23f81,$11111111,$11113fa5,$55555555
	dc.l	$55553ffc,$0000aaaa,$aaaaaaaa,$aaab0000
	dc.l	$000048b0,$00000000,$00003730,$00000000
	dc.l	$00003fff,$00008000,$00000000,$00000000
	dc.l	$00003fff,$00008164,$d1f3bc03,$07749f84
	dc.l	$1a9b3fff,$000082cd,$8698ac2b,$a1d89fc1
	dc.l	$d5b93fff,$0000843a,$28c3acde,$4048a072
	dc.l	$83693fff,$000085aa,$c367cc48,$7b141fc5
	dc.l	$c95c3fff,$0000871f,$61969e8d,$10101ee8
	dc.l	$5c9f3fff,$00008898,$0e8092da,$85289fa2
	dc.l	$07293fff,$00008a14,$d575496e,$fd9ca07b
	dc.l	$f9af3fff,$00008b95,$c1e3ea8b,$d6e8a002
	dc.l	$0dcf3fff,$00008d1a,$df5b7e5b,$a9e4205a
	dc.l	$63da3fff,$00008ea4,$398b45cd,$53c01eb7
	dc.l	$00513fff,$00009031,$dc431466,$b1dc1f6e
	dc.l	$b0293fff,$000091c3,$d373ab11,$c338a078
	dc.l	$14943fff,$0000935a,$2b2f13e6,$e92c9eb3
	dc.l	$19b03fff,$000094f4,$efa8fef7,$09602017
	dc.l	$457d3fff,$00009694,$2d372018,$5a001f11
	dc.l	$d5373fff,$00009837,$f0518db8,$a9709fb9
	dc.l	$52dd3fff,$000099e0,$459320b7,$fa641fe4
	dc.l	$30873fff,$00009b8d,$39b9d54e,$55381fa2
	dc.l	$a8183fff,$00009d3e,$d9a72cff,$b7501fde
	dc.l	$494d3fff,$00009ef5,$326091a1,$11ac2050
	dc.l	$48903fff,$0000a0b0,$510fb971,$4fc4a073
	dc.l	$691c3fff,$0000a270,$43030c49,$68181f9b
	dc.l	$7a053fff,$0000a435,$15ae09e6,$80a0a079
	dc.l	$71263fff,$0000a5fe,$d6a9b151,$38eca071
	dc.l	$a1403fff,$0000a7cd,$93b4e965,$3568204f
	dc.l	$62da3fff,$0000a9a1,$5ab4ea7c,$0ef81f28
	dc.l	$3c4a3fff,$0000ab7a,$39b5a93e,$d3389f9a
	dc.l	$7fdc3fff,$0000ad58,$3eea42a1,$4ac8a05b
	dc.l	$3fac3fff,$0000af3b,$78ad690a,$43741fdf
	dc.l	$26103fff,$0000b123,$f581d2ac,$25909f70
	dc.l	$5f903fff,$0000b311,$c412a911,$2488201f
	dc.l	$678a3fff,$0000b504,$f333f9de,$64841f32
	dc.l	$fb133fff,$0000b6fd,$91e328d1,$77902003
	dc.l	$8b303fff,$0000b8fb,$af4762fb,$9ee8200d
	dc.l	$c3cc3fff,$0000baff,$5ab2133e,$45fc9f8b
	dc.l	$2ae63fff,$0000bd08,$a39f580c,$36c0a02b
	dc.l	$bf703fff,$0000bf17,$99b67a73,$1084a00b
	dc.l	$f5183fff,$0000c12c,$4cca6670,$9458a041
	dc.l	$dd413fff,$0000c346,$ccda2497,$64089fdf
	dc.l	$137b3fff,$0000c567,$2a115506,$dadc201f
	dc.l	$15683fff,$0000c78d,$74c8abb9,$b15c1fc1
	dc.l	$3a2e3fff,$0000c9b9,$bd866e2f,$27a4a03f
	dc.l	$8f033fff,$0000cbec,$14fef272,$7c5c1ff4
	dc.l	$907d3fff,$0000ce24,$8c151f84,$80e49e6e
	dc.l	$53e43fff,$0000d063,$33daef2b,$25941fd6
	dc.l	$d45c3fff,$0000d2a8,$1d91f12a,$e45ca076
	dc.l	$edb93fff,$0000d4f3,$5aabcfed,$fa209fa6
	dc.l	$de213fff,$0000d744,$fccad69d,$6af41ee6
	dc.l	$9a2f3fff,$0000d99d,$15c278af,$d7b4207f
	dc.l	$439f3fff,$0000dbfb,$b797daf2,$3754201e
	dc.l	$c2073fff,$0000de60,$f4825e0e,$91249e8b
	dc.l	$e1753fff,$0000e0cc,$deec2a94,$e1102003
	dc.l	$2c4b3fff,$0000e33f,$8972be8a,$5a502004
	dc.l	$dff53fff,$0000e5b9,$06e77c83,$48a81e72
	dc.l	$f47a3fff,$0000e839,$6a503c4b,$dc681f72
	dc.l	$2f223fff,$0000eac0,$c6e7dd24,$3930a017
	dc.l	$e9453fff,$0000ed4f,$301ed994,$2b841f40
	dc.l	$1a5b3fff,$0000efe4,$b99bdcda,$f5cc9fb9
	dc.l	$a9e33fff,$0000f281,$773c59ff,$b1382074
	dc.l	$4c053fff,$0000f525,$7d152486,$cc2c1f77
	dc.l	$3a193fff,$0000f7d0,$df730ad1,$3bb81ffe
	dc.l	$90d53fff,$0000fa83,$b2db722a,$033ca041
	dc.l	$ed223fff,$0000fd3e,$0c0cf486,$c1741f85
	dc.l	$3f3a2210,$02817fff,$00000c81,$3fbe0000
	dc.l	$6c0660ff,$00000108,$32280004,$0c81400c
	dc.l	$b1676d06,$60ff0000,$010cf210,$4800f200
	dc.l	$0080f23c,$442342b8,$aa3bf227,$e00c2d7c
	dc.l	$00000000,$ff58f201,$600043fa,$fbb6f201
	dc.l	$40002d41,$ff540281,$0000003f,$e989d3c1
	dc.l	$222eff54,$ec810641,$3fff3d7a,$fb06ff54
	dc.l	$f2000100,$f23c4423,$bc317218,$f23a4923
	dc.l	$faf2f200,$0422f200,$0822f200,$0080f200
	dc.l	$04a3f23c,$45003ab6,$0b70f200,$0523f200
	dc.l	$0580f23c,$45a33c08,$8895f23a,$5522fad4
	dc.l	$f23a55a2,$fad6f200,$05233d41,$ff842d7c
	dc.l	$80000000,$ff8842ae,$ff8cf200,$05a3f23c
	dc.l	$45223f00,$0000f200,$01a3f200,$0523f200
	dc.l	$0c22f219,$4880f200,$0822f200,$0423f21f
	dc.l	$d030f211,$4422f200,$0422222e,$ff584a81
	dc.l	$6706f22e,$4823ff90,$f2009000,$123c0000
	dc.l	$f22e4823,$ff8460ff,$000024c6,$f210d080
	dc.l	$f2009000,$f23c4422,$3f800000,$60ff0000
	dc.l	$24c60c81,$400cb27c,$6e66f210,$4800f200
	dc.l	$0080f23c,$442342b8,$aa3bf227,$e00c2d7c
	dc.l	$00000001,$ff58f201,$600043fa,$faa6f201
	dc.l	$40002d41,$ff540281,$0000003f,$e989d3c1
	dc.l	$222eff54,$ec812d41,$ff54e281,$93aeff54
	dc.l	$06413fff,$3d41ff90,$2d7c8000,$0000ff94
	dc.l	$42aeff98,$222eff54,$06413fff,$6000fed2
	dc.l	$4a106bff,$00002370,$60ff0000,$24122f10
	dc.l	$02978000,$00000097,$00800000,$f23c4400
	dc.l	$3f800000,$f2009000,$f21f4422,$60ff0000
	dc.l	$24262210,$02817fff,$00000c81,$3ffd0000
	dc.l	$6c0660ff,$0000015e,$32280004,$0c814004
	dc.l	$c2156f06,$60ff0000,$026cf210,$4800f200
	dc.l	$0080f23c,$442342b8,$aa3bf227,$e00cf201
	dc.l	$600043fa,$f9eef201,$40002d41,$ff540281
	dc.l	$0000003f,$e989d3c1,$222eff54,$ec812d41
	dc.l	$ff54f200,$0100f23c,$4423bc31,$7218f23a
	dc.l	$4923f930,$f2000422,$f2000822,$06413fff
	dc.l	$f2000080,$f20004a3,$f23c4500,$3950097b
	dc.l	$f2000523,$f2000580,$f23c45a3,$3ab60b6a
	dc.l	$f23a5522,$f91ef23a,$55a2f920,$3d41ff84
	dc.l	$2d7c8000,$0000ff88,$42aeff8c,$f2000523
	dc.l	$222eff54,$4441f200,$05a30641,$3ffff23a
	dc.l	$5522f900,$f23c45a2,$3f000000,$f2000523
	dc.l	$00418000,$3d41ff90,$2d7c8000,$0000ff94
	dc.l	$42aeff98,$f2000ca3,$f2000123,$f2000422
	dc.l	$f2000822,$f21fd030,$f2114823,$222eff54
	dc.l	$0c810000,$003f6f1a,$f2294480,$000cf22e
	dc.l	$48a2ff90,$f2000422,$f2114822,$60ff0000
	dc.l	$00340c81,$fffffffd,$6c16f229,$4422000c
	dc.l	$f2114822,$f22e4822,$ff9060ff,$00000016
	dc.l	$f2194880,$f2114422,$f22e48a2,$ff90f200
	dc.l	$0422f200,$9000f22e,$4823ff84,$60ff0000
	dc.l	$22ae0c81,$3fbe0000,$6c6c0c81,$00330000
	dc.l	$6d2c2d7c,$80010000,$ff842d7c,$80000000
	dc.l	$ff8842ae,$ff8cf210,$4800f200,$9000123c
	dc.l	$0002f22e,$4822ff84,$60ff0000,$2264f210
	dc.l	$4800f23a,$5423f86c,$2d7c8001,$0000ff84
	dc.l	$2d7c8000,$0000ff88,$42aeff8c,$f22e4822
	dc.l	$ff84f200,$9000123c,$0000f23a,$5423f84c
	dc.l	$60ff0000,$222cf210,$4800f200,$0023f227
	dc.l	$e00cf23c,$44802f30,$caa8f200,$00a3f23c
	dc.l	$4500310f,$8290f23c,$44a232d7,$3220f200
	dc.l	$0123f200,$00a3f23c,$45223493,$f281f23a
	dc.l	$54a2f7c0,$f2000123,$f20000a3,$f23a5522
	dc.l	$f7baf23a,$54a2f7bc,$f2000123,$f20000a3
	dc.l	$f23a5522,$f7b6f23a,$54a2f7b8,$f2000123
	dc.l	$f20000a3,$f23a5522,$f7b2f23a,$48a2f7b4
	dc.l	$f2000123,$f20000a3,$f2000123,$f21048a3
	dc.l	$f23c4423,$3f000000,$f20008a2,$f21fd030
	dc.l	$f2000422,$f2009000,$f2104822,$60ff0000
	dc.l	$218e2210,$0c810000,$00006e00,$fbacf23c
	dc.l	$4400bf80,$0000f200,$9000f23c,$44220080
	dc.l	$000060ff,$00002178,$60ff0000,$1ff63028
	dc.l	$00000880,$000f0440,$3ffff200,$50006d02
	dc.l	$4e751d7c,$0008ff64,$4e7561ff,$00007cfc
	dc.l	$44400440,$3ffff200,$50001d7c,$0008ff64
	dc.l	$4e753028,$00000040,$7fff0880,$000e2d68
	dc.l	$0004ff88,$2d680008,$ff8c3d40,$ff84f22e
	dc.l	$4800ff84,$6b024e75,$1d7c0008,$ff644e75
	dc.l	$61ff0000,$7cb660ca,$7ffb0000,$80000000
	dc.l	$00000000,$00000000,$f2104800,$22103228
	dc.l	$00040281,$7fffffff,$0c81400c,$b1676e42
	dc.l	$f2000018,$2f004280,$f227e001,$41d761ff
	dc.l	$fffffad2,$dffc0000,$000cf23c,$44233f00
	dc.l	$0000201f,$f23c4480,$3e800000,$f20000a0
	dc.l	$f2009000,$123c0002,$f2000422,$60ff0000
	dc.l	$20800c81,$400cb2b3,$6e3cf200,$0018f23a
	dc.l	$5428baae,$f23a5428,$bab02f00,$4280f227
	dc.l	$e00141d7,$61ffffff,$fa7cdffc,$0000000c
	dc.l	$201ff200,$9000123c,$0000f23a,$4823ff5a
	dc.l	$60ff0000,$203c60ff,$00002014,$f23c4400
	dc.l	$3f800000,$f2009000,$f23c4422,$00800000
	dc.l	$60ff0000,$2032f210,$48002210,$32280004
	dc.l	$22410281,$7fffffff,$0c81400c,$b1676e62
	dc.l	$f2000018,$48e78040,$f227e001,$41d74280
	dc.l	$61ffffff,$fbe0dffc,$0000000c,$f23c9000
	dc.l	$00000000,$4cdf0201,$f2000080,$f23c44a2
	dc.l	$3f800000,$f2276800,$f2000420,$22090281
	dc.l	$80000000,$00813f00,$0000f21f,$48222f01
	dc.l	$f2009000,$123c0000,$f21f4423,$60ff0000
	dc.l	$1fa00c81,$400cb2b3,$6eff0000,$1f4cf200
	dc.l	$0018f23a,$5428b9ca,$2f3c0000,$00002f3c
	dc.l	$80000000,$22090281,$80000000,$00817ffb
	dc.l	$00002f01,$f23a5428,$b9b02f00,$4280f227
	dc.l	$e00141d7,$61ffffff,$f97cdffc,$0000000c
	dc.l	$201ff200,$9000123c,$0000f21f,$482360ff
	dc.l	$00001f3e,$60ff0000,$1ddaf210,$4800f22e
	dc.l	$6800ff84,$22103228,$00042d41,$ff840281
	dc.l	$7fffffff,$0c813fd7,$80006d00,$00740c81
	dc.l	$3fffddce,$6e00006a,$222eff84,$2d41ff5c
	dc.l	$02817fff,$00000681,$00010000,$2d41ff84
	dc.l	$02ae8000,$0000ff5c,$f22e4800,$ff842f00
	dc.l	$4280f227,$e00141d7,$61ffffff,$fac8dffc
	dc.l	$0000000c,$201ff200,$0080f23c,$44a24000
	dc.l	$0000222e,$ff5cf22e,$6880ff84,$b3aeff84
	dc.l	$f2009000,$f22e4820,$ff8460ff,$00001eb0
	dc.l	$0c813fff,$80006d00,$00880c81,$40048aa1
	dc.l	$6e000092,$222eff84,$2d41ff5c,$02817fff
	dc.l	$00000681,$00010000,$2d41ff84,$02ae8000
	dc.l	$0000ff5c,$222eff5c,$f22e4800,$ff842f00
	dc.l	$4280f227,$e00141d7,$61ffffff,$f878dffc
	dc.l	$0000000c,$201f222e,$ff5cf23c,$44223f80
	dc.l	$00000a81,$c0000000,$f2014480,$f20000a0
	dc.l	$222eff5c,$00813f80,$0000f201,$4400f200
	dc.l	$9000123c,$0002f200,$042260ff,$00001e20
	dc.l	$f2009000,$123c0003,$f22e4800,$ff8460ff
	dc.l	$00001dfe,$222eff84,$02818000,$00000081
	dc.l	$3f800000,$f2014400,$02818000,$00000a81
	dc.l	$80800000,$f2009000,$f2014422,$60ff0000
	dc.l	$1dde60ff,$00001c6c,$3ffe0000,$b17217f7
	dc.l	$d1cf79ac,$00000000,$3f800000,$00000000
	dc.l	$7f800000,$bf800000,$3fc2499a,$b5e4040b
	dc.l	$bfc555b5,$848cb7db,$3fc99999,$987d8730
	dc.l	$bfcfffff,$ff6f7e97,$3fd55555,$555555a4
	dc.l	$bfe00000,$00000008,$3f175496,$add7dad6
	dc.l	$3f3c71c2,$fe80c7e0,$3f624924,$928bccff
	dc.l	$3f899999,$999995ec,$3fb55555,$55555555
	dc.l	$40000000,$00000000,$3f990000,$80000000
	dc.l	$00000000,$00000000,$3ffe0000,$fe03f80f
	dc.l	$e03f80fe,$00000000,$3ff70000,$ff015358
	dc.l	$833c47e2,$00000000,$3ffe0000,$fa232cf2
	dc.l	$52138ac0,$00000000,$3ff90000,$bdc8d83e
	dc.l	$ad88d549,$00000000,$3ffe0000,$f6603d98
	dc.l	$0f6603da,$00000000,$3ffa0000,$9cf43dcf
	dc.l	$f5eafd48,$00000000,$3ffe0000,$f2b9d648
	dc.l	$0f2b9d65,$00000000,$3ffa0000,$da16eb88
	dc.l	$cb8df614,$00000000,$3ffe0000,$ef2eb71f
	dc.l	$c4345238,$00000000,$3ffb0000,$8b29b775
	dc.l	$1bd70743,$00000000,$3ffe0000,$ebbdb2a5
	dc.l	$c1619c8c,$00000000,$3ffb0000,$a8d839f8
	dc.l	$30c1fb49,$00000000,$3ffe0000,$e865ac7b
	dc.l	$7603a197,$00000000,$3ffb0000,$c61a2eb1
	dc.l	$8cd907ad,$00000000,$3ffe0000,$e525982a
	dc.l	$f70c880e,$00000000,$3ffb0000,$e2f2a47a
	dc.l	$de3a18af,$00000000,$3ffe0000,$e1fc780e
	dc.l	$1fc780e2,$00000000,$3ffb0000,$ff64898e
	dc.l	$df55d551,$00000000,$3ffe0000,$dee95c4c
	dc.l	$a037ba57,$00000000,$3ffc0000,$8db956a9
	dc.l	$7b3d0148,$00000000,$3ffe0000,$dbeb61ee
	dc.l	$d19c5958,$00000000,$3ffc0000,$9b8fe100
	dc.l	$f47ba1de,$00000000,$3ffe0000,$d901b203
	dc.l	$6406c80e,$00000000,$3ffc0000,$a9372f1d
	dc.l	$0da1bd17,$00000000,$3ffe0000,$d62b80d6
	dc.l	$2b80d62c,$00000000,$3ffc0000,$b6b07f38
	dc.l	$ce90e46b,$00000000,$3ffe0000,$d3680d36
	dc.l	$80d3680d,$00000000,$3ffc0000,$c3fd0329
	dc.l	$06488481,$00000000,$3ffe0000,$d0b69fcb
	dc.l	$d2580d0b,$00000000,$3ffc0000,$d11de0ff
	dc.l	$15ab18ca,$00000000,$3ffe0000,$ce168a77
	dc.l	$25080ce1,$00000000,$3ffc0000,$de1433a1
	dc.l	$6c66b150,$00000000,$3ffe0000,$cb8727c0
	dc.l	$65c393e0,$00000000,$3ffc0000,$eae10b5a
	dc.l	$7ddc8add,$00000000,$3ffe0000,$c907da4e
	dc.l	$871146ad,$00000000,$3ffc0000,$f7856e5e
	dc.l	$e2c9b291,$00000000,$3ffe0000,$c6980c69
	dc.l	$80c6980c,$00000000,$3ffd0000,$82012ca5
	dc.l	$a68206d7,$00000000,$3ffe0000,$c4372f85
	dc.l	$5d824ca6,$00000000,$3ffd0000,$882c5fcd
	dc.l	$7256a8c5,$00000000,$3ffe0000,$c1e4bbd5
	dc.l	$95f6e947,$00000000,$3ffd0000,$8e44c60b
	dc.l	$4ccfd7de,$00000000,$3ffe0000,$bfa02fe8
	dc.l	$0bfa02ff,$00000000,$3ffd0000,$944ad09e
	dc.l	$f4351af6,$00000000,$3ffe0000,$bd691047
	dc.l	$07661aa3,$00000000,$3ffd0000,$9a3eecd4
	dc.l	$c3eaa6b2,$00000000,$3ffe0000,$bb3ee721
	dc.l	$a54d880c,$00000000,$3ffd0000,$a0218434
	dc.l	$353f1de8,$00000000,$3ffe0000,$b92143fa
	dc.l	$36f5e02e,$00000000,$3ffd0000,$a5f2fcab
	dc.l	$bbc506da,$00000000,$3ffe0000,$b70fbb5a
	dc.l	$19be3659,$00000000,$3ffd0000,$abb3b8ba
	dc.l	$2ad362a5,$00000000,$3ffe0000,$b509e68a
	dc.l	$9b94821f,$00000000,$3ffd0000,$b1641795
	dc.l	$ce3ca97b,$00000000,$3ffe0000,$b30f6352
	dc.l	$8917c80b,$00000000,$3ffd0000,$b7047551
	dc.l	$5d0f1c61,$00000000,$3ffe0000,$b11fd3b8
	dc.l	$0b11fd3c,$00000000,$3ffd0000,$bc952afe
	dc.l	$ea3d13e1,$00000000,$3ffe0000,$af3addc6
	dc.l	$80af3ade,$00000000,$3ffd0000,$c2168ed0
	dc.l	$f458ba4a,$00000000,$3ffe0000,$ad602b58
	dc.l	$0ad602b6,$00000000,$3ffd0000,$c788f439
	dc.l	$b3163bf1,$00000000,$3ffe0000,$ab8f69e2
	dc.l	$8359cd11,$00000000,$3ffd0000,$ccecac08
	dc.l	$bf04565d,$00000000,$3ffe0000,$a9c84a47
	dc.l	$a07f5638,$00000000,$3ffd0000,$d2420487
	dc.l	$2dd85160,$00000000,$3ffe0000,$a80a80a8
	dc.l	$0a80a80b,$00000000,$3ffd0000,$d7894992
	dc.l	$3bc3588a,$00000000,$3ffe0000,$a655c439
	dc.l	$2d7b73a8,$00000000,$3ffd0000,$dcc2c4b4
	dc.l	$9887dacc,$00000000,$3ffe0000,$a4a9cf1d
	dc.l	$96833751,$00000000,$3ffd0000,$e1eebd3e
	dc.l	$6d6a6b9e,$00000000,$3ffe0000,$a3065e3f
	dc.l	$ae7cd0e0,$00000000,$3ffd0000,$e70d785c
	dc.l	$2f9f5bdc,$00000000,$3ffe0000,$a16b312e
	dc.l	$a8fc377d,$00000000,$3ffd0000,$ec1f392c
	dc.l	$5179f283,$00000000,$3ffe0000,$9fd809fd
	dc.l	$809fd80a,$00000000,$3ffd0000,$f12440d3
	dc.l	$e36130e6,$00000000,$3ffe0000,$9e4cad23
	dc.l	$dd5f3a20,$00000000,$3ffd0000,$f61cce92
	dc.l	$346600bb,$00000000,$3ffe0000,$9cc8e160
	dc.l	$c3fb19b9,$00000000,$3ffd0000,$fb091fd3
	dc.l	$8145630a,$00000000,$3ffe0000,$9b4c6f9e
	dc.l	$f03a3caa,$00000000,$3ffd0000,$ffe97042
	dc.l	$bfa4c2ad,$00000000,$3ffe0000,$99d722da
	dc.l	$bde58f06,$00000000,$3ffe0000,$825efced
	dc.l	$49369330,$00000000,$3ffe0000,$9868c809
	dc.l	$868c8098,$00000000,$3ffe0000,$84c37a7a
	dc.l	$b9a905c9,$00000000,$3ffe0000,$97012e02
	dc.l	$5c04b809,$00000000,$3ffe0000,$87224c2e
	dc.l	$8e645fb7,$00000000,$3ffe0000,$95a02568
	dc.l	$095a0257,$00000000,$3ffe0000,$897b8cac
	dc.l	$9f7de298,$00000000,$3ffe0000,$94458094
	dc.l	$45809446,$00000000,$3ffe0000,$8bcf55de
	dc.l	$c4cd05fe,$00000000,$3ffe0000,$92f11384
	dc.l	$0497889c,$00000000,$3ffe0000,$8e1dc0fb
	dc.l	$89e125e5,$00000000,$3ffe0000,$91a2b3c4
	dc.l	$d5e6f809,$00000000,$3ffe0000,$9066e68c
	dc.l	$955b6c9b,$00000000,$3ffe0000,$905a3863
	dc.l	$3e06c43b,$00000000,$3ffe0000,$92aade74
	dc.l	$c7be59e0,$00000000,$3ffe0000,$8f1779d9
	dc.l	$fdc3a219,$00000000,$3ffe0000,$94e9bff6
	dc.l	$15845643,$00000000,$3ffe0000,$8dda5202
	dc.l	$37694809,$00000000,$3ffe0000,$9723a1b7
	dc.l	$20134203,$00000000,$3ffe0000,$8ca29c04
	dc.l	$6514e023,$00000000,$3ffe0000,$995899c8
	dc.l	$90eb8990,$00000000,$3ffe0000,$8b70344a
	dc.l	$139bc75a,$00000000,$3ffe0000,$9b88bdaa
	dc.l	$3a3dae2f,$00000000,$3ffe0000,$8a42f870
	dc.l	$5669db46,$00000000,$3ffe0000,$9db4224f
	dc.l	$ffe1157c,$00000000,$3ffe0000,$891ac73a
	dc.l	$e9819b50,$00000000,$3ffe0000,$9fdadc26
	dc.l	$8b7a12da,$00000000,$3ffe0000,$87f78087
	dc.l	$f78087f8,$00000000,$3ffe0000,$a1fcff17
	dc.l	$ce733bd4,$00000000,$3ffe0000,$86d90544
	dc.l	$7a34acc6,$00000000,$3ffe0000,$a41a9e8f
	dc.l	$5446fb9f,$00000000,$3ffe0000,$85bf3761
	dc.l	$2cee3c9b,$00000000,$3ffe0000,$a633cd7e
	dc.l	$6771cd8b,$00000000,$3ffe0000,$84a9f9c8
	dc.l	$084a9f9d,$00000000,$3ffe0000,$a8489e60
	dc.l	$0b435a5e,$00000000,$3ffe0000,$83993052
	dc.l	$3fbe3368,$00000000,$3ffe0000,$aa59233c
	dc.l	$cca4bd49,$00000000,$3ffe0000,$828cbfbe
	dc.l	$b9a020a3,$00000000,$3ffe0000,$ac656dae
	dc.l	$6bcc4985,$00000000,$3ffe0000,$81848da8
	dc.l	$faf0d277,$00000000,$3ffe0000,$ae6d8ee3
	dc.l	$60bb2468,$00000000,$3ffe0000,$80808080
	dc.l	$80808081,$00000000,$3ffe0000,$b07197a2
	dc.l	$3c46c654,$00000000,$f2104800,$2d7c0000
	dc.l	$0000ff54,$22103228,$00042d50,$ff842d68
	dc.l	$0004ff88,$2d680008,$ff8c0c81,$00000000
	dc.l	$6d000182,$0c813ffe,$f07d6d0a,$0c813fff
	dc.l	$88416f00,$00e2e081,$e0810481,$00003fff
	dc.l	$d2aeff54,$41faf7b2,$f2014080,$2d7c3fff
	dc.l	$0000ff84,$2d6eff88,$ff9402ae,$fe000000
	dc.l	$ff9400ae,$01000000,$ff94222e,$ff940281
	dc.l	$7e000000,$e081e081,$e881d1c1,$f22e4800
	dc.l	$ff842d7c,$3fff0000,$ff9042ae,$ff98f22e
	dc.l	$4828ff90,$f227e00c,$f2104823,$f23a48a3
	dc.l	$f6c8f200,$0100f200,$0923f22e,$6880ff84
	dc.l	$f2000980,$f2000880,$f23a54a3,$f6ccf23a
	dc.l	$5523f6ce,$f23a54a2,$f6d0f23a,$5522f6d2
	dc.l	$f2000ca3,$f2000d23,$f23a54a2,$f6ccf23a
	dc.l	$5522f6ce,$f2000ca3,$d1fc0000,$0010f200
	dc.l	$0d23f200,$00a3f200,$0822f210,$48a2f21f
	dc.l	$d030f200,$0422f200,$9000f22e,$4822ff84
	dc.l	$60ff0000,$142af23c,$58380001,$f2c10000
	dc.l	$1678f200,$0080f23a,$44a8f64e,$f23a4422
	dc.l	$f648f200,$04a2f200,$00a0f227,$e00cf200
	dc.l	$0400f200,$0023f22e,$6880ff84,$f2000080
	dc.l	$f20004a3,$f23a5580,$f660f23a,$5500f662
	dc.l	$f20005a3,$f2000523,$f23a55a2,$f65cf23a
	dc.l	$5522f65e,$f2000ca3,$f2000123,$f23a54a2
	dc.l	$f658f22e,$4823ff84,$f20008a2,$f21fd030
	dc.l	$f2000423,$f2009000,$f22e4822,$ff8460ff
	dc.l	$0000139c,$60ff0000,$12102d7c,$ffffff9c
	dc.l	$ff5448e7,$3f002610,$28280004,$2a280008
	dc.l	$42824a84,$66342805,$42857420,$4286edc4
	dc.l	$6000edac,$d4862d43,$ff842d44,$ff882d45
	dc.l	$ff8c4482,$2d42ff54,$f22e4800,$ff844cdf
	dc.l	$00fc41ee,$ff846000,$fe0c4286,$edc46000
	dc.l	$2406edac,$2e05edad,$44860686,$00000020
	dc.l	$ecaf8887,$2d43ff84,$2d44ff88,$2d45ff8c
	dc.l	$44822d42,$ff54f22e,$4800ff84,$4cdf00fc
	dc.l	$41eeff84,$6000fdce,$f2104800,$f2000018
	dc.l	$f23a4838,$f5a4f292,$0014f200,$9000123c
	dc.l	$0003f210,$480060ff,$000012d6,$f2104800
	dc.l	$2d7c0000,$0000ff54,$f2000080,$f23a4422
	dc.l	$f508f22e,$6800ff84,$3d6eff88,$ff86222e
	dc.l	$ff840c81,$00000000,$6f0000da,$0c813ffe
	dc.l	$80006d00,$fda20c81,$3fffc000,$6e00fd98
	dc.l	$0c813ffe,$f07d6d00,$001a0c81,$3fff8841
	dc.l	$6e000010,$f20004a2,$f23a4422,$f4bc6000
	dc.l	$fe762d6e,$ff88ff94,$02aefe00,$0000ff94
	dc.l	$00ae0100,$0000ff94,$0c813fff,$80006c44
	dc.l	$f23a4400,$f4fc2d7c,$3fff0000,$ff9042ae
	dc.l	$ff98f22e,$4828ff90,$222eff94,$02817e00
	dc.l	$0000e081,$e081e881,$f20004a2,$f227e00c
	dc.l	$f2000422,$41faf4e2,$d1c1f23a,$4480f466
	dc.l	$6000fd76,$f23a4400,$f4502d7c,$3fff0000
	dc.l	$ff9042ae,$ff98f22e,$4828ff90,$222eff94
	dc.l	$02817e00,$0000e081,$e081e881,$f2000422
	dc.l	$f227e00c,$41faf4a2,$d1c1f23a,$4480f41e
	dc.l	$6000fd36,$0c810000,$00006d10,$f23a4400
	dc.l	$f414f200,$900060ff,$00001014,$f23a4400
	dc.l	$f3fcf200,$900060ff,$0000102e,$60ff0000
	dc.l	$10422210,$32280004,$02817fff,$ffff0c81
	dc.l	$3fff8000,$6c56f210,$4818f200,$0080f200
	dc.l	$049af200,$0022f23c,$44a23f80,$0000f200
	dc.l	$04202210,$02818000,$00000081,$3f000000
	dc.l	$2f012f00,$4280f227,$e00141d7,$61ffffff
	dc.l	$fe5adffc,$0000000c,$201ff200,$9000123c
	dc.l	$0000f21f,$442360ff,$00001136,$f2104818
	dc.l	$f23c4438,$3f800000,$f2d20000,$0fac60ff
	dc.l	$00000f7c,$60ff0000,$0fba3ffd,$0000de5b
	dc.l	$d8a93728,$71950000,$00003fff,$0000b8aa
	dc.l	$3b295c17,$f0bc0000,$0000f23c,$58000001
	dc.l	$f2104838,$f2c10000,$13502210,$6d000090
	dc.l	$2f004280,$61ffffff,$fba2f21f,$9000f23a
	dc.l	$4823ffb8,$60ff0000,$10d62210,$6d000070
	dc.l	$2f004280,$61ffffff,$fd34f21f,$9000f23a
	dc.l	$4823ff98,$60ff0000,$10c62210,$6d000050
	dc.l	$22280008,$662e2228,$00040281,$7fffffff
	dc.l	$66223210,$02810000,$7fff0481,$00003fff
	dc.l	$67ff0000,$12e4f200,$9000f201,$400060ff
	dc.l	$0000107c,$2f004280,$61ffffff,$fb2ef21f
	dc.l	$9000f23a,$4823ff54,$60ff0000,$106260ff
	dc.l	$00000ed6,$22106d00,$fff62f00,$428061ff
	dc.l	$fffffcba,$f21f9000,$f23a4823,$ff2e60ff
	dc.l	$0000104c,$406a934f,$0979a371,$3f734413
	dc.l	$509f8000,$bfcd0000,$c0219dc1,$da994fd2
	dc.l	$00000000,$40000000,$935d8ddd,$aaa8ac17
	dc.l	$00000000,$3ffe0000,$b17217f7,$d1cf79ac
	dc.l	$00000000,$3f56c16d,$6f7bd0b2,$3f811112
	dc.l	$302c712c,$3fa55555,$55554cc1,$3fc55555
	dc.l	$55554a54,$3fe00000,$00000000,$00000000
	dc.l	$00000000,$3fff0000,$80000000,$00000000
	dc.l	$3f738000,$3fff0000,$8164d1f3,$bc030773
	dc.l	$3fbef7ca,$3fff0000,$82cd8698,$ac2ba1d7
	dc.l	$3fbdf8a9,$3fff0000,$843a28c3,$acde4046
	dc.l	$3fbcd7c9,$3fff0000,$85aac367,$cc487b15
	dc.l	$bfbde8da,$3fff0000,$871f6196,$9e8d1010
	dc.l	$3fbde85c,$3fff0000,$88980e80,$92da8527
	dc.l	$3fbebbf1,$3fff0000,$8a14d575,$496efd9a
	dc.l	$3fbb80ca,$3fff0000,$8b95c1e3,$ea8bd6e7
	dc.l	$bfba8373,$3fff0000,$8d1adf5b,$7e5ba9e6
	dc.l	$bfbe9670,$3fff0000,$8ea4398b,$45cd53c0
	dc.l	$3fbdb700,$3fff0000,$9031dc43,$1466b1dc
	dc.l	$3fbeeeb0,$3fff0000,$91c3d373,$ab11c336
	dc.l	$3fbbfd6d,$3fff0000,$935a2b2f,$13e6e92c
	dc.l	$bfbdb319,$3fff0000,$94f4efa8,$fef70961
	dc.l	$3fbdba2b,$3fff0000,$96942d37,$20185a00
	dc.l	$3fbe91d5,$3fff0000,$9837f051,$8db8a96f
	dc.l	$3fbe8d5a,$3fff0000,$99e04593,$20b7fa65
	dc.l	$bfbcde7b,$3fff0000,$9b8d39b9,$d54e5539
	dc.l	$bfbebaaf,$3fff0000,$9d3ed9a7,$2cffb751
	dc.l	$bfbd86da,$3fff0000,$9ef53260,$91a111ae
	dc.l	$bfbebedd,$3fff0000,$a0b0510f,$b9714fc2
	dc.l	$3fbcc96e,$3fff0000,$a2704303,$0c496819
	dc.l	$bfbec90b,$3fff0000,$a43515ae,$09e6809e
	dc.l	$3fbbd1db,$3fff0000,$a5fed6a9,$b15138ea
	dc.l	$3fbce5eb,$3fff0000,$a7cd93b4,$e965356a
	dc.l	$bfbec274,$3fff0000,$a9a15ab4,$ea7c0ef8
	dc.l	$3fbea83c,$3fff0000,$ab7a39b5,$a93ed337
	dc.l	$3fbecb00,$3fff0000,$ad583eea,$42a14ac6
	dc.l	$3fbe9301,$3fff0000,$af3b78ad,$690a4375
	dc.l	$bfbd8367,$3fff0000,$b123f581,$d2ac2590
	dc.l	$bfbef05f,$3fff0000,$b311c412,$a9112489
	dc.l	$3fbdfb3c,$3fff0000,$b504f333,$f9de6484
	dc.l	$3fbeb2fb,$3fff0000,$b6fd91e3,$28d17791
	dc.l	$3fbae2cb,$3fff0000,$b8fbaf47,$62fb9ee9
	dc.l	$3fbcdc3c,$3fff0000,$baff5ab2,$133e45fb
	dc.l	$3fbee9aa,$3fff0000,$bd08a39f,$580c36bf
	dc.l	$bfbeaefd,$3fff0000,$bf1799b6,$7a731083
	dc.l	$bfbcbf51,$3fff0000,$c12c4cca,$66709456
	dc.l	$3fbef88a,$3fff0000,$c346ccda,$24976407
	dc.l	$3fbd83b2,$3fff0000,$c5672a11,$5506dadd
	dc.l	$3fbdf8ab,$3fff0000,$c78d74c8,$abb9b15d
	dc.l	$bfbdfb17,$3fff0000,$c9b9bd86,$6e2f27a3
	dc.l	$bfbefe3c,$3fff0000,$cbec14fe,$f2727c5d
	dc.l	$bfbbb6f8,$3fff0000,$ce248c15,$1f8480e4
	dc.l	$bfbcee53,$3fff0000,$d06333da,$ef2b2595
	dc.l	$bfbda4ae,$3fff0000,$d2a81d91,$f12ae45a
	dc.l	$3fbc9124,$3fff0000,$d4f35aab,$cfedfa1f
	dc.l	$3fbeb243,$3fff0000,$d744fcca,$d69d6af4
	dc.l	$3fbde69a,$3fff0000,$d99d15c2,$78afd7b6
	dc.l	$bfb8bc61,$3fff0000,$dbfbb797,$daf23755
	dc.l	$3fbdf610,$3fff0000,$de60f482,$5e0e9124
	dc.l	$bfbd8be1,$3fff0000,$e0ccdeec,$2a94e111
	dc.l	$3fbacb12,$3fff0000,$e33f8972,$be8a5a51
	dc.l	$3fbb9bfe,$3fff0000,$e5b906e7,$7c8348a8
	dc.l	$3fbcf2f4,$3fff0000,$e8396a50,$3c4bdc68
	dc.l	$3fbef22f,$3fff0000,$eac0c6e7,$dd24392f
	dc.l	$bfbdbf4a,$3fff0000,$ed4f301e,$d9942b84
	dc.l	$3fbec01a,$3fff0000,$efe4b99b,$dcdaf5cb
	dc.l	$3fbe8cac,$3fff0000,$f281773c,$59ffb13a
	dc.l	$bfbcbb3f,$3fff0000,$f5257d15,$2486cc2c
	dc.l	$3fbef73a,$3fff0000,$f7d0df73,$0ad13bb9
	dc.l	$bfb8b795,$3fff0000,$fa83b2db,$722a033a
	dc.l	$3fbef84b,$3fff0000,$fd3e0c0c,$f486c175
	dc.l	$bfbef581,$f210d080,$22103228,$0004f22e
	dc.l	$6800ff84,$02817fff,$ffff0c81,$3fb98000
	dc.l	$6c046000,$00880c81,$400d80c0,$6f046000
	dc.l	$007cf200,$0080f23c,$44a34280,$0000f22e
	dc.l	$6080ff54,$2f0243fa,$fbbcf22e,$4080ff54
	dc.l	$222eff54,$24010281,$0000003f,$e981d3c1
	dc.l	$ec822202,$e2819481,$06820000,$3ffff227
	dc.l	$e00cf23c,$44a33c80,$00002d59,$ff842d59
	dc.l	$ff882d59,$ff8c3d59,$ff90f200,$04283d59
	dc.l	$ff94426e,$ff9642ae,$ff98d36e,$ff84f23a
	dc.l	$4823fb22,$d36eff90,$60000100,$0c813fff
	dc.l	$80006e12,$f2009000,$f23c4422,$3f800000
	dc.l	$60ff0000,$0b12222e,$ff840c81,$00000000
	dc.l	$6d0660ff,$00000ac8,$60ff0000,$0a1af200
	dc.l	$9000f23c,$44003f80,$00002210,$00810080
	dc.l	$0001f201,$442260ff,$00000adc,$f210d080
	dc.l	$22103228,$0004f22e,$6800ff84,$02817fff
	dc.l	$ffff0c81,$3fb98000,$6c046000,$ff900c81
	dc.l	$400b9b07,$6f046000,$ff84f200,$0080f23a
	dc.l	$54a3fa62,$f22e6080,$ff542f02,$43fafac6
	dc.l	$f22e4080,$ff54222e,$ff542401,$02810000
	dc.l	$003fe981,$d3c1ec82,$2202e281,$94810682
	dc.l	$00003fff,$f227e00c,$f2000500,$f23a54a3
	dc.l	$fa2c2d59,$ff84f23a,$4923fa2a,$2d59ff88
	dc.l	$2d59ff8c,$f2000428,$3d59ff90,$f2000828
	dc.l	$3d59ff94,$426eff96,$42aeff98,$f23a4823
	dc.l	$fa14d36e,$ff84d36e,$ff90f200,$0080f200
	dc.l	$04a3f23a,$5500fa1e,$f23a5580,$fa20f200
	dc.l	$0523f200,$05a3f23a,$5522fa1a,$f23a55a2
	dc.l	$fa1cf200,$0523f200,$05a3f23a,$5522fa16
	dc.l	$f20001a3,$f2000523,$f2000c22,$f2000822
	dc.l	$f21fd030,$f22e4823,$ff84f22e,$4822ff90
	dc.l	$f22e4822,$ff84f200,$90003d42,$ff84241f
	dc.l	$2d7c8000,$0000ff88,$42aeff8c,$123c0000
	dc.l	$f22e4823,$ff8460ff,$00000996,$f2009000
	dc.l	$f23c4400,$3f800000,$22100081,$00800001
	dc.l	$f2014422,$60ff0000,$098e2f01,$e8082200
	dc.l	$02410003,$0240000c,$48403001,$221f4a01
	dc.l	$671e0c01,$000a6f12,$0c01000e,$6f3c0c01
	dc.l	$002f6f06,$0c01003f,$6f6260ff,$00000baa
	dc.l	$4a00660c,$41fb0170,$000000d6,$60000086
	dc.l	$0c000003,$670a41fb,$01700000,$00d06074
	dc.l	$41fb0170,$000000d2,$606a0401,$000b4a00
	dc.l	$661041fb,$01700000,$00cc0c01,$00026f54
	dc.l	$605a0c00,$0003670a,$41fb0170,$000000f2
	dc.l	$60e841fb,$01700000,$012460de,$04010030
	dc.l	$4a006616,$41fb0170,$0000014e,$0c010001
	dc.l	$6f220c01,$00076f24,$601a0c00,$0003670a
	dc.l	$41fb0170,$000001f2,$60e241fb,$01700000
	dc.l	$02a860d8,$00ae0000,$0208ff64,$c2fc000c
	dc.l	$48404a00,$6608f230,$d0801000,$4e754840
	dc.l	$3d701000,$ff902d70,$1004ff94,$2d701008
	dc.l	$ff982200,$428041ee,$ff904268,$000261ff
	dc.l	$000062c6,$f210d080,$4e7551fc,$40000000
	dc.l	$c90fdaa2,$2168c235,$40000000,$c90fdaa2
	dc.l	$2168c234,$40000000,$c90fdaa2,$2168c235
	dc.l	$3ffd0000,$9a209a84,$fbcff798,$40000000
	dc.l	$adf85458,$a2bb4a9a,$3fff0000,$b8aa3b29
	dc.l	$5c17f0bc,$3ffd0000,$de5bd8a9,$37287195
	dc.l	$00000000,$00000000,$00000000,$3ffd0000
	dc.l	$9a209a84,$fbcff798,$40000000,$adf85458
	dc.l	$a2bb4a9a,$3fff0000,$b8aa3b29,$5c17f0bb
	dc.l	$3ffd0000,$de5bd8a9,$37287195,$00000000
	dc.l	$00000000,$00000000,$3ffd0000,$9a209a84
	dc.l	$fbcff799,$40000000,$adf85458,$a2bb4a9b
	dc.l	$3fff0000,$b8aa3b29,$5c17f0bc,$3ffd0000
	dc.l	$de5bd8a9,$37287195,$00000000,$00000000
	dc.l	$00000000,$3ffe0000,$b17217f7,$d1cf79ac
	dc.l	$40000000,$935d8ddd,$aaa8ac17,$3fff0000
	dc.l	$80000000,$00000000,$40020000,$a0000000
	dc.l	$00000000,$40050000,$c8000000,$00000000
	dc.l	$400c0000,$9c400000,$00000000,$40190000
	dc.l	$bebc2000,$00000000,$40340000,$8e1bc9bf
	dc.l	$04000000,$40690000,$9dc5ada8,$2b70b59e
	dc.l	$40d30000,$c2781f49,$ffcfa6d5,$41a80000
	dc.l	$93ba47c9,$80e98ce0,$43510000,$aa7eebfb
	dc.l	$9df9de8e,$46a30000,$e319a0ae,$a60e91c7
	dc.l	$4d480000,$c9767586,$81750c17,$5a920000
	dc.l	$9e8b3b5d,$c53d5de5,$75250000,$c4605202
	dc.l	$8a20979b,$3ffe0000,$b17217f7,$d1cf79ab
	dc.l	$40000000,$935d8ddd,$aaa8ac16,$3fff0000
	dc.l	$80000000,$00000000,$40020000,$a0000000
	dc.l	$00000000,$40050000,$c8000000,$00000000
	dc.l	$400c0000,$9c400000,$00000000,$40190000
	dc.l	$bebc2000,$00000000,$40340000,$8e1bc9bf
	dc.l	$04000000,$40690000,$9dc5ada8,$2b70b59d
	dc.l	$40d30000,$c2781f49,$ffcfa6d5,$41a80000
	dc.l	$93ba47c9,$80e98cdf,$43510000,$aa7eebfb
	dc.l	$9df9de8d,$46a30000,$e319a0ae,$a60e91c6
	dc.l	$4d480000,$c9767586,$81750c17,$5a920000
	dc.l	$9e8b3b5d,$c53d5de4,$75250000,$c4605202
	dc.l	$8a20979a,$3ffe0000,$b17217f7,$d1cf79ac
	dc.l	$40000000,$935d8ddd,$aaa8ac17,$3fff0000
	dc.l	$80000000,$00000000,$40020000,$a0000000
	dc.l	$00000000,$40050000,$c8000000,$00000000
	dc.l	$400c0000,$9c400000,$00000000,$40190000
	dc.l	$bebc2000,$00000000,$40340000,$8e1bc9bf
	dc.l	$04000000,$40690000,$9dc5ada8,$2b70b59e
	dc.l	$40d30000,$c2781f49,$ffcfa6d6,$41a80000
	dc.l	$93ba47c9,$80e98ce0,$43510000,$aa7eebfb
	dc.l	$9df9de8e,$46a30000,$e319a0ae,$a60e91c7
	dc.l	$4d480000,$c9767586,$81750c18,$5a920000
	dc.l	$9e8b3b5d,$c53d5de5,$75250000,$c4605202
	dc.l	$8a20979b,$2f003229,$00005bee,$ff540281
	dc.l	$00007fff,$30280000,$02407fff,$0c403fff
	dc.l	$6d0000c0,$0c40400c,$6e0000a4,$f2284803
	dc.l	$0000f200,$6000f23c,$88000000,$00004a29
	dc.l	$00046b5e,$2f003d69,$0000ff84,$2d690004
	dc.l	$ff882d69,$0008ff8c,$41eeff84,$61ff0000
	dc.l	$60ba4480,$d09ff22e,$d080ff84,$0c40c001
	dc.l	$6c36f21f,$9000223c,$80000000,$0480ffff
	dc.l	$c0014480,$0c000020,$6c0ae0a9,$42a72f01
	dc.l	$42a76028,$04000020,$e0a92f01,$42a742a7
	dc.l	$601af229,$d0800000,$f21f9000,$06403fff
	dc.l	$484042a7,$2f3c8000,$00002f00,$f200b000
	dc.l	$123c0000,$f21f4823,$60ff0000,$04ce201f
	dc.l	$c1494a29,$00006bff,$0000038c,$60ff0000
	dc.l	$03c44a29,$00046a16,$201ff200,$9000123c
	dc.l	$0003f229,$48000000,$60ff0000,$049e201f
	dc.l	$204960ff,$000002e2,$00010000,$80000000
	dc.l	$00000000,$00000000,$422eff65,$2f00422e
	dc.l	$ff5c600c,$422eff65,$2f001d7c,$0001ff5c
	dc.l	$48e73f00,$36280000,$3d43ff58,$02830000
	dc.l	$7fff2828,$00042a28,$00084a83,$663c263c
	dc.l	$00003ffe,$4a846616,$28054285,$04830000
	dc.l	$00204286,$edc46000,$edac9686,$60224286
	dc.l	$edc46000,$9686edac,$2e05edad,$44860686
	dc.l	$00000020,$ecaf8887,$60060683,$00003ffe
	dc.l	$30290000,$3d40ff5a,$322eff58,$b1810281
	dc.l	$00008000,$3d41ff5e,$02800000,$7fff2229
	dc.l	$00042429,$00084a80,$663c203c,$00003ffe
	dc.l	$4a816616,$22024282,$04800000,$00204286
	dc.l	$edc16000,$eda99086,$60224286,$edc16000
	dc.l	$9086eda9,$2e02edaa,$44860686,$00000020
	dc.l	$ecaf8287,$60060680,$00003ffe,$2d43ff54
	dc.l	$2f009083,$42864283,$227c0000,$00004a80
	dc.l	$6c06201f,$6000006a,$588f4a86,$6e0eb284
	dc.l	$6608b485,$66046000,$01366508,$94859384
	dc.l	$42865283,$4a80670e,$d683d482,$e39155c6
	dc.l	$52895380,$60d4202e,$ff544a81,$66162202
	dc.l	$42820480,$00000020,$4286edc1,$6000eda9
	dc.l	$9086601c,$4286edc1,$60006b14,$9086eda9
	dc.l	$2e02edaa,$44860686,$00000020,$ecaf8287
	dc.l	$0c800000,$41fe6c2a,$3d40ff90,$2d41ff94
	dc.l	$2d42ff98,$2c2eff54,$3d46ff84,$2d44ff88
	dc.l	$2d45ff8c,$f22e4800,$ff901d7c,$0001ff5d
	dc.l	$60362d41,$ff942d42,$ff980480,$00003ffe
	dc.l	$3d40ff90,$2c2eff54,$04860000,$3ffe2d46
	dc.l	$ff54f22e,$4800ff90,$3d46ff84,$2d44ff88
	dc.l	$2d45ff8c,$422eff5d,$4a2eff5c,$67222c2e
	dc.l	$ff545386,$b0866d18,$6e0eb284,$6608b485
	dc.l	$66046000,$007a6508,$f22e4828,$ff845283
	dc.l	$3c2eff5a,$6c04f200,$001a4286,$3c2eff5e
	dc.l	$7e08eeae,$02830000,$007f8686,$1d43ff65
	dc.l	$4cdf00fc,$201ff200,$90004a2e,$ff5d6710
	dc.l	$123c0000,$f23a4823,$fdc060ff,$0000024c
	dc.l	$123c0003,$f2000000,$60ff0000,$023e5283
	dc.l	$0c800000,$00086c04,$e1ab6002,$4283f23c
	dc.l	$44000000,$0000422e,$ff5d6000,$ff942c03
	dc.l	$02860000,$00014a86,$6700ff86,$52833c2e
	dc.l	$ff5a0a86,$00008000,$3d46ff5a,$6000ff72
	dc.l	$7fff0000,$ffffffff,$ffffffff,$4a280000
	dc.l	$6b12f23c,$44007f80,$000000ae,$02000410
	dc.l	$ff644e75,$f23c4400,$ff800000,$00ae0a00
	dc.l	$0410ff64,$4e7500ae,$01002080,$ff64f23a
	dc.l	$d080ffbe,$4e7500ae,$00000800,$ff646008
	dc.l	$00ae0000,$0a28ff64,$22482200,$020100c0
	dc.l	$660e4a28,$00006a18,$08ee0003,$ff646010
	dc.l	$2f094a28,$00005bc1,$61ff0000,$0196225f
	dc.l	$f210d080,$102eff62,$0200000a,$66024e75
	dc.l	$3d690000,$ff842d69,$0004ff88,$2d690008
	dc.l	$ff8c41ee,$ff8461ff,$00005cd0,$06800000
	dc.l	$6000026e,$8000ff84,$816eff84,$f22ed040
	dc.l	$ff844e75,$00ae0000,$0a28ff64,$4a105bc1
	dc.l	$61ff0000,$013ef210,$d080f23c,$44800000
	dc.l	$00004e75,$00ae0000,$0a28ff64,$51c161ff
	dc.l	$00000120,$f210d080,$f23c4480,$00000000
	dc.l	$4e7500ae,$00001048,$ff641200,$020100c0
	dc.l	$675c4a28,$00046b24,$3d680000,$ff842d68
	dc.l	$0004ff88,$2d680008,$ff8c41ee,$ff8448e7
	dc.l	$c08061ff,$00005c44,$4cdf0103,$0c010040
	dc.l	$660e4aa8,$00086614,$4a280007,$660e601e
	dc.l	$22280008,$02810000,$07ff6712,$00ae0000
	dc.l	$0200ff64,$600800ae,$00001248,$ff644a28
	dc.l	$00005bc1,$61ff0000,$5f261d40,$ff64f210
	dc.l	$d080f23c,$44800000,$00004e75,$00ae0000
	dc.l	$1248ff64,$51c161ff,$00005f04,$1d40ff64
	dc.l	$f210d080,$f23c4480,$00000000,$4e75f327
	dc.l	$4a2f0002,$6b2edffc,$0000000c,$f294000e
	dc.l	$f2810014,$006e0208,$ff664e75,$00ae0800
	dc.l	$0208ff64,$4e751d7c,$0004ff64,$006e0208
	dc.l	$ff664e75,$006e0208,$ff6661ff,$00000bae
	dc.l	$dffc0000,$000c4e75,$f3274a2f,$00026bea
	dc.l	$dffc0000,$000cf200,$a80081ae,$ff644e75
	dc.l	$00ae0000,$0a28ff64,$02410010,$e8080200
	dc.l	$000f8001,$2200e309,$1d7b000a,$ff6441fb
	dc.l	$16204e75,$04040400,$04040400,$04040400
	dc.l	$00000000,$0c0c080c,$0c0c080c,$0c0c080c
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000001,$00000000
	dc.l	$3f810000,$00000000,$00000000,$00000000
	dc.l	$3f810000,$00000000,$00000000,$00000000
	dc.l	$3f810000,$00000000,$00000000,$00000000
	dc.l	$3f810000,$00000100,$00000000,$00000000
	dc.l	$3c010000,$00000000,$00000000,$00000000
	dc.l	$3c010000,$00000000,$00000000,$00000000
	dc.l	$3c010000,$00000000,$00000000,$00000000
	dc.l	$3c010000,$00000000,$00000800,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$80000000,$00000000,$00000000,$00000000
	dc.l	$80000000,$00000000,$00000000,$00000000
	dc.l	$80000000,$00000000,$00000001,$00000000
	dc.l	$80000000,$00000000,$00000000,$00000000
	dc.l	$bf810000,$00000000,$00000000,$00000000
	dc.l	$bf810000,$00000000,$00000000,$00000000
	dc.l	$bf810000,$00000100,$00000000,$00000000
	dc.l	$bf810000,$00000000,$00000000,$00000000
	dc.l	$bc010000,$00000000,$00000000,$00000000
	dc.l	$bc010000,$00000000,$00000000,$00000000
	dc.l	$bc010000,$00000000,$00000800,$00000000
	dc.l	$bc010000,$00000000,$00000000,$00000000
	dc.l	$4a280000,$6b10f23c,$44000000,$00001d7c
	dc.l	$0004ff64,$4e75f23c,$44008000,$00001d7c
	dc.l	$000cff64,$4e754a29,$00006bea,$60d84a28
	dc.l	$00006b10,$f23c4400,$7f800000,$1d7c0002
	dc.l	$ff644e75,$f23c4400,$ff800000,$1d7c000a
	dc.l	$ff644e75,$4a290000,$6bea60d8,$4a280000
	dc.l	$6ba460d0,$4a280000,$6b00fbbc,$60c64a28
	dc.l	$00006b16,$60be4a28,$00006b0e,$f23c4400
	dc.l	$3f800000,$422eff64,$4e75f23c,$4400bf80
	dc.l	$00001d7c,$0008ff64,$4e753fff,$0000c90f
	dc.l	$daa22168,$c235bfff,$0000c90f,$daa22168
	dc.l	$c2354a28,$00006b0e,$f2009000,$f23a4800
	dc.l	$ffda6000,$fcf0f200,$9000f23a,$4800ffd8
	dc.l	$6000fcea,$f23c4480,$3f800000,$4a280000
	dc.l	$6a10f23c,$44008000,$00001d7c,$000cff64
	dc.l	$6040f23c,$44000000,$00001d7c,$0004ff64
	dc.l	$6030f23a,$4880faea,$61ff0000,$00286000
	dc.l	$fb16f228,$48800000,$61ff0000,$00186000
	dc.l	$030ef228,$48800000,$61ff0000,$00086000
	dc.l	$02ee102e,$ff430240,$0007303b,$02064efb
	dc.l	$00020010,$00180020,$0026002c,$00320038
	dc.l	$003ef22e,$f040ffdc,$4e75f22e,$f040ffe8
	dc.l	$4e75f200,$05004e75,$f2000580,$4e75f200
	dc.l	$06004e75,$f2000680,$4e75f200,$07004e75
	dc.l	$f2000780,$4e75122e,$ff4f67ff,$fffff7dc
	dc.l	$0c010001,$67000096,$0c010002,$67ffffff
	dc.l	$fa880c01,$000467ff,$fffff7c0,$0c010005
	dc.l	$67ff0000,$024060ff,$0000024a,$122eff4f
	dc.l	$67ffffff,$fa640c01,$000167ff,$fffffa5a
	dc.l	$0c010002,$67ffffff,$fa500c01,$000467ff
	dc.l	$fffffa46,$0c010003,$67ff0000,$021860ff
	dc.l	$00000202,$122eff4f,$67ff0000,$004e0c01
	dc.l	$000167ff,$00000028,$0c010002,$67ffffff
	dc.l	$fa180c01,$000467ff,$00000030,$0c010003
	dc.l	$67ff0000,$01e060ff,$000001ca,$12280000
	dc.l	$10290000,$b1010201,$00801d41,$ff654a00
	dc.l	$6a00fdc4,$6000fdd0,$422eff65,$2f001228
	dc.l	$00001029,$0000b101,$02010080,$1d41ff65
	dc.l	$0c2e0004,$ff4f660c,$41e90000,$201f60ff
	dc.l	$fffff9c6,$f21f9000,$f2294800,$00004a29
	dc.l	$00006b02,$4e751d7c,$0008ff64,$4e75122e
	dc.l	$ff4f67ff,$fffff6e0,$0c010001,$6700ff8e
	dc.l	$0c010002,$67ffffff,$f9800c01,$000467ff
	dc.l	$fffff6c4,$0c010003,$67ff0000,$014860ff
	dc.l	$00000132,$122eff4f,$67ffffff,$f95c0c01
	dc.l	$000167ff,$fffff952,$0c010002,$67ffffff
	dc.l	$f9480c01,$000467ff,$fffff93e,$0c010003
	dc.l	$67ff0000,$011060ff,$000000fa,$122eff4f
	dc.l	$6700ff46,$0c010001,$6700ff22,$0c010002
	dc.l	$67ffffff,$f9140c01,$000467ff,$ffffff2c
	dc.l	$0c010003,$67ff0000,$00dc60ff,$000000c6
	dc.l	$122eff4f,$67ffffff,$f51e0c01,$000167ff
	dc.l	$fffffce6,$0c010002,$67ffffff,$fd0a0c01
	dc.l	$000467ff,$fffff500,$0c010003,$67ff0000
	dc.l	$00a460ff,$0000008e,$122eff4f,$67ffffff
	dc.l	$f4e60c01,$000167ff,$fffffcae,$0c010002
	dc.l	$67ffffff,$fcd20c01,$000467ff,$fffff4c8
	dc.l	$0c010003,$67ff0000,$006c60ff,$00000056
	dc.l	$122eff4f,$67ffffff,$f8800c01,$000367ff
	dc.l	$00000052,$0c010005,$67ff0000,$003860ff
	dc.l	$fffff866,$122eff4f,$0c010003,$67340c01
	dc.l	$0005671e,$6058122e,$ff4f0c01,$00036708
	dc.l	$0c010005,$670c6036,$00ae0100,$4080ff64
	dc.l	$6010f229,$48000000,$f200a800,$81aeff64
	dc.l	$4e75f229,$48000000,$4a290000,$6b081d7c
	dc.l	$0001ff64,$4e751d7c,$0009ff64,$4e75f228
	dc.l	$48000000,$f200a800,$81aeff64,$4e75f228
	dc.l	$48000000,$4a280000,$6bdc1d7c,$0001ff64
	dc.l	$4e751d7c,$0009ff64,$4e75122e,$ff4e67ff
	dc.l	$ffffd936,$0c010001,$67ffffff,$fba60c01
	dc.l	$000267ff,$fffffbca,$0c010004,$67ffffff
	dc.l	$d9f60c01,$000367ff,$ffffffb6,$60ffffff
	dc.l	$ffa0122e,$ff4e67ff,$ffffe620,$0c010001
	dc.l	$67ffffff,$fb6e0c01,$000267ff,$fffffbc8
	dc.l	$0c010004,$67ffffff,$e7560c01,$000367ff
	dc.l	$ffffff7e,$60ffffff,$ff68122e,$ff4e67ff
	dc.l	$ffffd4d2,$0c010001,$67ffffff,$fb360c01
	dc.l	$000267ff,$fffffb9a,$0c010004,$67ffffff
	dc.l	$d76a0c01,$000367ff,$ffffff46,$60ffffff
	dc.l	$ff30122e,$ff4e67ff,$ffffd972,$0c010001
	dc.l	$67ffffff,$fafe0c01,$000267ff,$fffffb6a
	dc.l	$0c010004,$67ffffff,$dabc0c01,$000367ff
	dc.l	$ffffff0e,$60ffffff,$fef8122e,$ff4e67ff
	dc.l	$ffffca6a,$0c010001,$67ffffff,$fac60c01
	dc.l	$000267ff,$fffffb6e,$0c010004,$67ffffff
	dc.l	$cc8a0c01,$000367ff,$fffffed6,$60ffffff
	dc.l	$fec0122e,$ff4e67ff,$ffffcc76,$0c010001
	dc.l	$67ffffff,$fa8e0c01,$000267ff,$fffff6aa
	dc.l	$0c010004,$67ffffff,$cd060c01,$000367ff
	dc.l	$fffffe9e,$60ffffff,$fe88122e,$ff4e67ff
	dc.l	$ffffe662,$0c010001,$67ffffff,$fa560c01
	dc.l	$000267ff,$fffff672,$0c010004,$67ffffff
	dc.l	$e6c60c01,$000367ff,$fffffe66,$60ffffff
	dc.l	$fe50122e,$ff4e67ff,$ffffb372,$0c010001
	dc.l	$67ffffff,$fa1e0c01,$000267ff,$fffff63a
	dc.l	$0c010004,$67ffffff,$b5380c01,$000367ff
	dc.l	$fffffe2e,$60ffffff,$fe18122e,$ff4e67ff
	dc.l	$ffffbdfc,$0c010001,$67ffffff,$f9e60c01
	dc.l	$000267ff,$fffff602,$0c010004,$67ffffff
	dc.l	$bf420c01,$000367ff,$fffffdf6,$60ffffff
	dc.l	$fde0122e,$ff4e67ff,$ffffd17a,$0c010001
	dc.l	$67ffffff,$fa2a0c01,$000267ff,$fffffa00
	dc.l	$0c010004,$67ffffff,$d3080c01,$000367ff
	dc.l	$fffffdbe,$60ffffff,$fda8122e,$ff4e67ff
	dc.l	$ffffeb64,$0c010001,$67ffffff,$f9f20c01
	dc.l	$000267ff,$fffff9c8,$0c010004,$67ffffff
	dc.l	$ec200c01,$000367ff,$fffffd86,$60ffffff
	dc.l	$fd70122e,$ff4e67ff,$ffffec24,$0c010001
	dc.l	$67ffffff,$f9ba0c01,$000267ff,$fffff990
	dc.l	$0c010004,$67ffffff,$ed360c01,$000367ff
	dc.l	$fffffd4e,$60ffffff,$fd38122e,$ff4e67ff
	dc.l	$ffffe178,$0c010001,$67ffffff,$f51a0c01
	dc.l	$000267ff,$fffff960,$0c010004,$67ffffff
	dc.l	$e30c0c01,$000367ff,$fffffd16,$60ffffff
	dc.l	$fd00122e,$ff4e67ff,$ffffe582,$0c010001
	dc.l	$67ffffff,$f4e20c01,$000267ff,$fffff928
	dc.l	$0c010004,$67ffffff,$e5940c01,$000367ff
	dc.l	$fffffcde,$60ffffff,$fcc8122e,$ff4e67ff
	dc.l	$ffffe59a,$0c010001,$67ffffff,$f4aa0c01
	dc.l	$000267ff,$fffff8f0,$0c010004,$67ffffff
	dc.l	$e5d60c01,$000367ff,$fffffca6,$60ffffff
	dc.l	$fc90122e,$ff4e67ff,$ffffd530,$0c010001
	dc.l	$67ffffff,$f8da0c01,$000267ff,$fffff888
	dc.l	$0c010004,$67ffffff,$d5b60c01,$000367ff
	dc.l	$fffffc6e,$60ffffff,$fc58122e,$ff4e67ff
	dc.l	$ffffcac2,$0c010001,$67ffffff,$f8de0c01
	dc.l	$000267ff,$fffff442,$0c010004,$67ffffff
	dc.l	$cb340c01,$000367ff,$fffffc36,$60ffffff
	dc.l	$fc20122e,$ff4e67ff,$ffffb14c,$0c010001
	dc.l	$67ffffff,$f86a0c01,$000267ff,$fffff40a
	dc.l	$0c010004,$67ffffff,$b30e0c01,$000367ff
	dc.l	$fffffbfe,$60ffffff,$fbe8122e,$ff4e67ff
	dc.l	$ffffd40e,$0c010001,$67ffffff,$f7b60c01
	dc.l	$000267ff,$fffff3d2,$0c010004,$67ffffff
	dc.l	$d40c0c01,$000367ff,$fffffbc6,$60ffffff
	dc.l	$fbb0122e,$ff4e67ff,$ffffd40a,$0c010001
	dc.l	$67ffffff,$f77e0c01,$000267ff,$fffff39a
	dc.l	$0c010004,$67ffffff,$d41a0c01,$000367ff
	dc.l	$fffffb8e,$60ffffff,$fb78122e,$ff4e67ff
	dc.l	$ffffb292,$0c010001,$67ffffff,$f81a0c01
	dc.l	$000267ff,$fffff83e,$0c010004,$67ffffff
	dc.l	$b50a0c01,$000367ff,$fffff83a,$60ffffff
	dc.l	$f844122e,$ff4e67ff,$fffff89e,$0c010001
	dc.l	$67ffffff,$f8ca0c01,$000267ff,$fffff8f8
	dc.l	$0c010004,$67ffffff,$f8800c01,$000367ff
	dc.l	$fffffab4,$60ffffff,$fac0122e,$ff4e67ff
	dc.l	$fffff96e,$0c010001,$67ffffff,$f99a0c01
	dc.l	$000267ff,$fffff9c8,$0c010004,$67ffffff
	dc.l	$f9500c01,$000367ff,$fffffa7c,$60ffffff
	dc.l	$fa88122e,$ff4e67ff,$fffff9d8,$0c010001
	dc.l	$67ffffff,$fa060c01,$000267ff,$fffffa34
	dc.l	$0c010004,$67ffffff,$f9ba0c01,$000367ff
	dc.l	$fffffa44,$60ffffff,$fa500c2f,$00070003
	dc.l	$673e1d7c,$0000ff4e,$1d7c0000,$ff4ff22e
	dc.l	$f080ff78,$41ef0004,$43eeff78,$0c010003
	dc.l	$67160c01,$00026708,$61ff0000,$02004e75
	dc.l	$61ff0000,$1b9e4e75,$61ff0000,$05e44e75
	dc.l	$1d7c0004,$ff4e60c0,$4afc006d,$000005d2
	dc.l	$00000fc8,$fffffa6e,$0000106c,$00002314
	dc.l	$00000000,$fffffaa6,$00000000,$fffffade
	dc.l	$fffffb16,$fffffb4e,$00000000,$fffffb86
	dc.l	$fffffbbe,$fffffbf6,$fffffc2e,$fffffc66
	dc.l	$fffffc9e,$fffffcd6,$00000000,$fffffd0e
	dc.l	$fffffd46,$fffffd7e,$00000000,$00001112
	dc.l	$fffffdb6,$00000ca8,$00000000,$fffffdee
	dc.l	$fffffe26,$fffffe5e,$fffffe96,$0000089e
	dc.l	$ffffff06,$00001b84,$000001de,$00001854
	dc.l	$ffffff3e,$ffffff76,$00001512,$00001f4c
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$fffffece
	dc.l	$fffffece,$fffffece,$fffffece,$fffffece
	dc.l	$fffffece,$fffffece,$fffffece,$000013b0
	dc.l	$00000000,$00000f56,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$000005c0
	dc.l	$00002302,$00000000,$00000000,$000005ca
	dc.l	$0000230c,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00001100
	dc.l	$00000000,$00000c96,$00000000,$0000110a
	dc.l	$00000000,$00000ca0,$00000000,$0000088c
	dc.l	$00000000,$00001b72,$000001cc,$00000896
	dc.l	$00000000,$00001b7c,$000001d6,$00001f3a
	dc.l	$00000000,$00000000,$00000000,$00001f44
	dc.l	$ffffc001,$ffffff81,$fffffc01,$00004000
	dc.l	$0000007f,$000003ff,$02000030,$00000040
	dc.l	$60080200,$00300000,$00802d40,$ff5c4241
	dc.l	$122eff4f,$e709822e,$ff4e6600,$02e43d69
	dc.l	$0000ff90,$2d690004,$ff942d69,$0008ff98
	dc.l	$3d680000,$ff842d68,$0004ff88,$2d680008
	dc.l	$ff8c61ff,$000024ce,$2f0061ff,$00002572
	dc.l	$d197322e,$ff5eec09,$201fb0bb,$14846700
	dc.l	$011e6d00,$0062b0bb,$14846700,$021a6e00
	dc.l	$014af22e,$d080ff90,$f22e9000,$ff5cf23c
	dc.l	$88000000,$0000f22e,$4823ff84,$f201a800
	dc.l	$f23c9000,$00000000,$83aeff64,$f22ef080
	dc.l	$ff842f02,$322eff84,$24010281,$00007fff
	dc.l	$02428000,$92808242,$3d41ff84,$241ff22e
	dc.l	$d080ff84,$4e75f22e,$d080ff90,$f22e9000
	dc.l	$ff5cf23c,$88000000,$0000f22e,$4823ff84
	dc.l	$f201a800,$f23c9000,$00000000,$83aeff64
	dc.l	$00ae0000,$1048ff64,$122eff62,$02010013
	dc.l	$661c082e,$0003ff64,$56c1202e,$ff5c61ff
	dc.l	$00004fcc,$812eff64,$f210d080,$4e75222e
	dc.l	$ff5c0201,$00c06634,$f22ef080,$ff842f02
	dc.l	$322eff84,$34010281,$00007fff,$92800481
	dc.l	$00006000,$02417fff,$02428000,$82423d41
	dc.l	$ff84241f,$f22ed040,$ff8460a6,$f22ed080
	dc.l	$ff90222e,$ff5c0201,$0030f201,$9000f22e
	dc.l	$4823ff84,$f23c9000,$00000000,$60aaf22e
	dc.l	$d080ff90,$f22e9000,$ff5cf23c,$88000000
	dc.l	$0000f22e,$4823ff84,$f201a800,$f23c9000
	dc.l	$00000000,$83aeff64,$f2000098,$f23c58b8
	dc.l	$0002f293,$ff3c6000,$fee408ee,$0003ff66
	dc.l	$f22ed080,$ff90f23c,$90000000,$0010f23c
	dc.l	$88000000,$0000f22e,$4823ff84,$f201a800
	dc.l	$f23c9000,$00000000,$83aeff64,$122eff62
	dc.l	$0201000b,$6620f22e,$f080ff84,$41eeff84
	dc.l	$222eff5c,$61ff0000,$4dd8812e,$ff64f22e
	dc.l	$d080ff84,$4e75f22e,$d040ff90,$222eff5c
	dc.l	$020100c0,$6652f22e,$9000ff5c,$f23c8800
	dc.l	$00000000,$f22e48a3,$ff84f23c,$90000000
	dc.l	$0000f22e,$f040ff84,$2f02322e,$ff842401
	dc.l	$02810000,$7fff0242,$80009280,$06810000
	dc.l	$60000241,$7fff8242,$3d41ff84,$241ff22e
	dc.l	$d040ff84,$6000ff80,$222eff5c,$02010030
	dc.l	$f2019000,$60a6f22e,$d080ff90,$f22e9000
	dc.l	$ff5cf23c,$88000000,$0000f22e,$4823ff84
	dc.l	$f201a800,$f23c9000,$00000000,$83aeff64
	dc.l	$f2000098,$f23c58b8,$0002f292,$fde0f294
	dc.l	$fefaf22e,$d040ff90,$222eff5c,$020100c0
	dc.l	$00010010,$f2019000,$f23c8800,$00000000
	dc.l	$f22e48a3,$ff84f23c,$90000000,$0000f200
	dc.l	$0498f23c,$58b80002,$f293fda2,$6000febc
	dc.l	$323b120a,$4efb1006,$4afc0030,$fd120072
	dc.l	$00cc006c,$fd120066,$00000000,$00720072
	dc.l	$0060006c,$00720066,$00000000,$009e0060
	dc.l	$009e006c,$009e0066,$00000000,$006c006c
	dc.l	$006c006c,$006c0066,$00000000,$fd120072
	dc.l	$00cc006c,$fd120066,$00000000,$00660066
	dc.l	$00660066,$00660066,$00000000,$60ff0000
	dc.l	$230e60ff,$00002284,$60ff0000,$227e1028
	dc.l	$00001229,$0000b101,$6a10f23c,$44008000
	dc.l	$00001d7c,$000cff64,$4e75f23c,$44000000
	dc.l	$00001d7c,$0004ff64,$4e75f229,$d0800000
	dc.l	$10280000,$12290000,$b1016a10,$f2000018
	dc.l	$f200001a,$1d7c000a,$ff644e75,$f2000018
	dc.l	$1d7c0002,$ff644e75,$f228d080,$00001028
	dc.l	$00001229,$0000b101,$6ae260d0,$02000030
	dc.l	$00000040,$60080200,$00300000,$00802d40
	dc.l	$ff5c122e,$ff4e6600,$02620200,$00c06600
	dc.l	$007c4a28,$00006a06,$08ee0003,$ff64f228
	dc.l	$d0800000,$4e750200,$00c06600,$006008ee
	dc.l	$0003ff66,$4a280000,$6a0608ee,$0003ff64
	dc.l	$f228d080,$0000082e,$0003ff62,$66024e75
	dc.l	$3d680000,$ff842d68,$0004ff88,$2d680008
	dc.l	$ff8c41ee,$ff8461ff,$00004950,$44400640
	dc.l	$6000322e,$ff840241,$80000240,$7fff8041
	dc.l	$3d40ff84,$f22ed040,$ff844e75,$0c000040
	dc.l	$667e3d68,$0000ff84,$2d680004,$ff882d68
	dc.l	$0008ff8c,$61ff0000,$206c0c80,$0000007f
	dc.l	$6c000092,$0c80ffff,$ff816700,$01786d00
	dc.l	$00f4f23c,$88000000,$0000f22e,$9000ff5c
	dc.l	$f22e4800,$ff84f201,$a800f23c,$90000000
	dc.l	$000083ae,$ff642f02,$f22ef080,$ff84322e
	dc.l	$ff843401,$02810000,$7fff9280,$02428000
	dc.l	$84413d42,$ff84241f,$f22ed080,$ff844e75
	dc.l	$3d680000,$ff842d68,$0004ff88,$2d680008
	dc.l	$ff8c61ff,$00001fee,$0c800000,$03ff6c00
	dc.l	$00140c80,$fffffc01,$670000fa,$6d000076
	dc.l	$6000ff80,$08ee0003,$ff664a2e,$ff846a06
	dc.l	$08ee0003,$ff64122e,$ff620201,$000b661a
	dc.l	$41eeff84,$222eff5c,$61ff0000,$4a74812e
	dc.l	$ff64f22e,$d080ff84,$4e752d6e,$ff88ff94
	dc.l	$2d6eff8c,$ff98322e,$ff842f02,$34010281
	dc.l	$00007fff,$92800242,$80000681,$00006000
	dc.l	$02417fff,$84413d42,$ff90f22e,$d040ff90
	dc.l	$241f60ac,$f23c8800,$00000000,$f22e9000
	dc.l	$ff5cf22e,$4800ff84,$f23c9000,$00000000
	dc.l	$f201a800,$83aeff64,$00ae0000,$1048ff64
	dc.l	$122eff62,$02010013,$661c082e,$0003ff64
	dc.l	$56c1202e,$ff5c61ff,$00004ae4,$812eff64
	dc.l	$f210d080,$4e752f02,$322eff84,$24010281
	dc.l	$00007fff,$02428000,$92800481,$00006000
	dc.l	$02417fff,$82423d41,$ff84241f,$f22ed040
	dc.l	$ff8460b6,$f23c8800,$00000000,$f22e9000
	dc.l	$ff5cf22e,$4800ff84,$f201a800,$f23c9000
	dc.l	$00000000,$83aeff64,$f2000098,$f23c58b8
	dc.l	$0002f293,$ff746000,$fe7e0c01,$00046700
	dc.l	$fdb60c01,$000567ff,$00001f98,$0c010003
	dc.l	$67ff0000,$1fa2f228,$48000000,$f200a800
	dc.l	$e1981d40,$ff644e75,$51fc51fc,$51fc51fc
	dc.l	$00003fff,$0000007e,$000003fe,$ffffc001
	dc.l	$ffffff81,$fffffc01,$02000030,$00000040
	dc.l	$60080200,$00300000,$00802d40,$ff5c4241
	dc.l	$122eff4f,$e709822e,$ff4e6600,$02d63d69
	dc.l	$0000ff90,$2d690004,$ff942d69,$0008ff98
	dc.l	$3d680000,$ff842d68,$0004ff88,$2d680008
	dc.l	$ff8c61ff,$00001e0e,$2f0061ff,$00001eb2
	dc.l	$4497d197,$322eff5e,$ec09201f,$b0bb148e
	dc.l	$6f000074,$b0bb1520,$ff7a6700,$020c6e00
	dc.l	$013cf22e,$d080ff90,$f22e9000,$ff5cf23c
	dc.l	$88000000,$0000f22e,$4820ff84,$f201a800
	dc.l	$f23c9000,$00000000,$83aeff64,$f22ef080
	dc.l	$ff842f02,$322eff84,$24010281,$00007fff
	dc.l	$02428000,$92808242,$3d41ff84,$241ff22e
	dc.l	$d080ff84,$4e750000,$7fff0000,$407f0000
	dc.l	$43ff201f,$60c62f00,$f22ed080,$ff90f22e
	dc.l	$9000ff5c,$f23c8800,$00000000,$f22e4820
	dc.l	$ff84f200,$a800f23c,$90000000,$000081ae
	dc.l	$ff64f227,$e0013017,$dffc0000,$000c0280
	dc.l	$00007fff,$9097b0bb,$14ae6db6,$201f00ae
	dc.l	$00001048,$ff64122e,$ff620201,$0013661c
	dc.l	$082e0003,$ff6456c1,$202eff5c,$61ff0000
	dc.l	$48de812e,$ff64f210,$d0804e75,$222eff5c
	dc.l	$020100c0,$6634f22e,$f080ff84,$2f02322e
	dc.l	$ff843401,$02810000,$7fff9280,$04810000
	dc.l	$60000241,$7fff0242,$80008242,$3d41ff84
	dc.l	$241ff22e,$d040ff84,$60a6f22e,$d080ff90
	dc.l	$222eff5c,$02010030,$f2019000,$f22e4820
	dc.l	$ff84f23c,$90000000,$000060aa,$08ee0003
	dc.l	$ff66f22e,$d080ff90,$f23c9000,$00000010
	dc.l	$f23c8800,$00000000,$f22e4820,$ff84f201
	dc.l	$a800f23c,$90000000,$000083ae,$ff64122e
	dc.l	$ff620201,$000b6620,$f22ef080,$ff8441ee
	dc.l	$ff84222e,$ff5c61ff,$00004726,$812eff64
	dc.l	$f22ed080,$ff844e75,$f22ed040,$ff90222e
	dc.l	$ff5c0201,$00c06652,$f22e9000,$ff5cf23c
	dc.l	$88000000,$0000f22e,$48a0ff84,$f23c9000
	dc.l	$00000000,$f22ef040,$ff842f02,$322eff84
	dc.l	$24010281,$00007fff,$02428000,$92800681
	dc.l	$00006000,$02417fff,$82423d41,$ff84241f
	dc.l	$f22ed040,$ff846000,$ff80222e,$ff5c0201
	dc.l	$0030f201,$900060a6,$f22ed080,$ff90f22e
	dc.l	$9000ff5c,$f23c8800,$00000000,$f22e4820
	dc.l	$ff84f201,$a800f23c,$90000000,$000083ae
	dc.l	$ff64f200,$0098f23c,$58b80001,$f292fdee
	dc.l	$f294fefa,$f22ed040,$ff90222e,$ff5c0201
	dc.l	$00c00001,$0010f201,$9000f23c,$88000000
	dc.l	$0000f22e,$48a0ff84,$f23c9000,$00000000
	dc.l	$f2000498,$f23c58b8,$0001f293,$fdb06000
	dc.l	$febc323b,$120a4efb,$10064afc,$0030fd20
	dc.l	$009e0072,$0060fd20,$00660000,$00000072
	dc.l	$006c0072,$00600072,$00660000,$000000d0
	dc.l	$00d0006c,$006000d0,$00660000,$00000060
	dc.l	$00600060,$00600060,$00660000,$0000fd20
	dc.l	$009e0072,$0060fd20,$00660000,$00000066
	dc.l	$00660066,$00660066,$00660000,$000060ff
	dc.l	$00001bd8,$60ff0000,$1bd260ff,$00001c50
	dc.l	$10280000,$12290000,$b1016a10,$f23c4400
	dc.l	$80000000,$1d7c000c,$ff644e75,$f23c4400
	dc.l	$00000000,$1d7c0004,$ff644e75,$006e0410
	dc.l	$ff661028,$00001229,$0000b101,$6a10f23c
	dc.l	$4400ff80,$00001d7c,$000aff64,$4e75f23c
	dc.l	$44007f80,$00001d7c,$0002ff64,$4e751029
	dc.l	$00001228,$0000b101,$6a16f229,$d0800000
	dc.l	$f2000018,$f200001a,$1d7c000a,$ff644e75
	dc.l	$f229d080,$0000f200,$00181d7c,$0002ff64
	dc.l	$4e750200,$00300000,$00406008,$02000030
	dc.l	$00000080,$2d40ff5c,$122eff4e,$66000276
	dc.l	$020000c0,$66000090,$2d680004,$ff882d68
	dc.l	$0008ff8c,$30280000,$0a408000,$6a061d7c
	dc.l	$0008ff64,$3d40ff84,$f22ed080,$ff844e75
	dc.l	$020000c0,$666008ee,$0003ff66,$2d680004
	dc.l	$ff882d68,$0008ff8c,$30280000,$0a408000
	dc.l	$6a061d7c,$0008ff64,$3d40ff84,$f22ed080
	dc.l	$ff84082e,$0003ff62,$66024e75,$41eeff84
	dc.l	$61ff0000,$42664440,$06406000,$322eff84
	dc.l	$02418000,$02407fff,$80413d40,$ff84f22e
	dc.l	$d040ff84,$4e750c00,$0040667e,$3d680000
	dc.l	$ff842d68,$0004ff88,$2d680008,$ff8c61ff
	dc.l	$00001982,$0c800000,$007f6c00,$00900c80
	dc.l	$ffffff81,$67000178,$6d0000f4,$f23c8800
	dc.l	$00000000,$f22e9000,$ff5cf22e,$481aff84
	dc.l	$f201a800,$f23c9000,$00000000,$83aeff64
	dc.l	$2f02f22e,$f080ff84,$322eff84,$34010281
	dc.l	$00007fff,$92800242,$80008441,$3d42ff84
	dc.l	$241ff22e,$d080ff84,$4e753d68,$0000ff84
	dc.l	$2d680004,$ff882d68,$0008ff8c,$61ff0000
	dc.l	$19040c80,$000003ff,$6c120c80,$fffffc01
	dc.l	$670000fc,$6d000078,$6000ff82,$08ee0003
	dc.l	$ff660a2e,$0080ff84,$6a0608ee,$0003ff64
	dc.l	$122eff62,$0201000b,$661a41ee,$ff84222e
	dc.l	$ff5c61ff,$0000438a,$812eff64,$f22ed080
	dc.l	$ff844e75,$2d6eff88,$ff942d6e,$ff8cff98
	dc.l	$322eff84,$2f022401,$02810000,$7fff0242
	dc.l	$80009280,$06810000,$60000241,$7fff8242
	dc.l	$3d41ff90,$f22ed040,$ff90241f,$60acf23c
	dc.l	$88000000,$0000f22e,$9000ff5c,$f22e481a
	dc.l	$ff84f23c,$90000000,$0000f201,$a80083ae
	dc.l	$ff6400ae,$00001048,$ff64122e,$ff620201
	dc.l	$0013661c,$082e0003,$ff6456c1,$202eff5c
	dc.l	$61ff0000,$43fa812e,$ff64f210,$d0804e75
	dc.l	$2f02322e,$ff842401,$02810000,$7fff0242
	dc.l	$80009280,$04810000,$60000241,$7fff8242
	dc.l	$3d41ff84,$f22ed040,$ff84241f,$60b6f23c
	dc.l	$88000000,$0000f22e,$9000ff5c,$f22e481a
	dc.l	$ff84f201,$a800f23c,$90000000,$000083ae
	dc.l	$ff64f200,$0098f23c,$58b80002,$f293ff74
	dc.l	$6000fe7e,$0c010004,$6700fdb6,$0c010005
	dc.l	$67ff0000,$18ae0c01,$000367ff,$000018b8
	dc.l	$f228481a,$0000f200,$a800e198,$1d40ff64
	dc.l	$4e75122e,$ff4e6610,$4a280000,$6b024e75
	dc.l	$1d7c0008,$ff644e75,$0c010001,$67400c01
	dc.l	$00026724,$0c010005,$67ff0000,$18660c01
	dc.l	$000367ff,$00001870,$4a280000,$6b024e75
	dc.l	$1d7c0008,$ff644e75,$4a280000,$6b081d7c
	dc.l	$0002ff64,$4e751d7c,$000aff64,$4e754a28
	dc.l	$00006b08,$1d7c0004,$ff644e75,$1d7c000c
	dc.l	$ff644e75,$122eff4e,$66280200,$0030f200
	dc.l	$9000f23c,$88000000,$0000f228,$48010000
	dc.l	$f23c9000,$00000000,$f200a800,$81aeff64
	dc.l	$4e750c01,$0001672e,$0c010002,$674e0c01
	dc.l	$00046710,$0c010005,$67ff0000,$17d660ff
	dc.l	$000017e4,$3d680000,$ff841d7c,$0080ff88
	dc.l	$41eeff84,$60a44a28,$00006b10,$f23c4400
	dc.l	$00000000,$1d7c0004,$ff644e75,$f23c4400
	dc.l	$80000000,$1d7c000c,$ff644e75,$f228d080
	dc.l	$00004a28,$00006b08,$1d7c0002,$ff644e75
	dc.l	$1d7c000a,$ff644e75,$122eff4e,$6618f23c
	dc.l	$88000000,$0000f228,$48030000,$f200a800
	dc.l	$81aeff64,$4e750c01,$0001672e,$0c010002
	dc.l	$674e0c01,$00046710,$0c010005,$67ff0000
	dc.l	$174260ff,$00001750,$3d680000,$ff841d7c
	dc.l	$0080ff88,$41eeff84,$60b44a28,$00006b10
	dc.l	$f23c4400,$00000000,$1d7c0004,$ff644e75
	dc.l	$f23c4400,$80000000,$1d7c000c,$ff644e75
	dc.l	$f228d080,$00004a28,$00006b08,$1d7c0002
	dc.l	$ff644e75,$1d7c000a,$ff644e75,$02000030
	dc.l	$00000040,$60080200,$00300000,$00802d40
	dc.l	$ff5c122e,$ff4e6600,$025c0200,$00c0667e
	dc.l	$2d680004,$ff882d68,$0008ff8c,$32280000
	dc.l	$0881000f,$3d41ff84,$f22ed080,$ff844e75
	dc.l	$020000c0,$665808ee,$0003ff66,$2d680004
	dc.l	$ff882d68,$0008ff8c,$30280000,$0880000f
	dc.l	$3d40ff84,$f22ed080,$ff84082e,$0003ff62
	dc.l	$66024e75,$41eeff84,$61ff0000,$3e0e4440
	dc.l	$06406000,$322eff84,$02418000,$02407fff
	dc.l	$80413d40,$ff84f22e,$d040ff84,$4e750c00
	dc.l	$0040667e,$3d680000,$ff842d68,$0004ff88
	dc.l	$2d680008,$ff8c61ff,$0000152a,$0c800000
	dc.l	$007f6c00,$00900c80,$ffffff81,$67000170
	dc.l	$6d0000ec,$f23c8800,$00000000,$f22e9000
	dc.l	$ff5cf22e,$4818ff84,$f201a800,$f23c9000
	dc.l	$00000000,$83aeff64,$2f02f22e,$f080ff84
	dc.l	$322eff84,$24010281,$00007fff,$92800242
	dc.l	$80008441,$3d42ff84,$241ff22e,$d080ff84
	dc.l	$4e753d68,$0000ff84,$2d680004,$ff882d68
	dc.l	$0008ff8c,$61ff0000,$14ac0c80,$000003ff
	dc.l	$6c120c80,$fffffc01,$670000f4,$6d000070
	dc.l	$6000ff82,$08ee0003,$ff6608ae,$0007ff84
	dc.l	$122eff62,$0201000b,$661a41ee,$ff84222e
	dc.l	$ff5c61ff,$00003f3a,$812eff64,$f22ed080
	dc.l	$ff844e75,$2d6eff88,$ff942d6e,$ff8cff98
	dc.l	$322eff84,$2f022401,$02810000,$7fff0242
	dc.l	$80009280,$06810000,$60000241,$7fff8242
	dc.l	$3d41ff90,$f22ed040,$ff90241f,$60acf23c
	dc.l	$88000000,$0000f22e,$9000ff5c,$f22e4818
	dc.l	$ff84f23c,$90000000,$0000f201,$a80083ae
	dc.l	$ff6400ae,$00001048,$ff64122e,$ff620201
	dc.l	$0013661c,$082e0003,$ff6456c1,$202eff5c
	dc.l	$61ff0000,$3faa812e,$ff64f210,$d0804e75
	dc.l	$2f02322e,$ff842401,$02810000,$7fff0242
	dc.l	$80009280,$04810000,$60000241,$7fff8242
	dc.l	$3d41ff84,$f22ed040,$ff84241f,$60b6f23c
	dc.l	$88000000,$0000f22e,$9000ff5c,$f22e4818
	dc.l	$ff84f201,$a800f23c,$90000000,$000083ae
	dc.l	$ff64f200,$0098f23c,$58b80002,$f293ff74
	dc.l	$6000fe86,$0c010004,$6700fdc6,$0c010005
	dc.l	$67ff0000,$145e0c01,$000367ff,$00001468
	dc.l	$f2284818,$00000c01,$00026708,$1d7c0004
	dc.l	$ff644e75,$1d7c0002,$ff644e75,$4241122e
	dc.l	$ff4fe709,$822eff4e,$6618f229,$d0800000
	dc.l	$f2284838,$0000f200,$a800e198,$1d40ff64
	dc.l	$4e75323b,$120a4efb,$10064afc,$0030ffdc
	dc.l	$ffdcffdc,$006000f8,$006e0000,$0000ffdc
	dc.l	$ffdcffdc,$0060007c,$006e0000,$0000ffdc
	dc.l	$ffdcffdc,$0060007c,$006e0000,$00000060
	dc.l	$00600060,$00600060,$006e0000,$00000114
	dc.l	$009c009c,$006000bc,$006e0000,$0000006e
	dc.l	$006e006e,$006e006e,$006e0000,$000061ff
	dc.l	$00001388,$022e00f7,$ff644e75,$61ff0000
	dc.l	$137a022e,$00f7ff64,$4e753d68,$0000ff84
	dc.l	$20280004,$08c0001f,$2d40ff88,$2d680008
	dc.l	$ff8c41ee,$ff846000,$ff422d69,$0000ff84
	dc.l	$20290004,$08c0001f,$2d40ff88,$2d690008
	dc.l	$ff8c43ee,$ff846000,$ff223d69,$0000ff90
	dc.l	$3d680000,$ff842029,$000408c0,$001f2d40
	dc.l	$ff942028,$000408c0,$001f2d40,$ff882d69
	dc.l	$0008ff98,$2d680008,$ff8c43ee,$ff9041ee
	dc.l	$ff846000,$fee61028,$00001229,$0000b101
	dc.l	$6b00ff78,$4a006b02,$4e751d7c,$0008ff64
	dc.l	$4e751028,$00001229,$0000b101,$6b00ff7c
	dc.l	$4a006a02,$4e751d7c,$0008ff64,$4e752d40
	dc.l	$ff5c4241,$122eff4f,$e709822e,$ff4e6600
	dc.l	$02a03d69,$0000ff90,$2d690004,$ff942d69
	dc.l	$0008ff98,$3d680000,$ff842d68,$0004ff88
	dc.l	$2d680008,$ff8c61ff,$0000119a,$2f0061ff
	dc.l	$0000123e,$d09f0c80,$ffffc001,$670000f8
	dc.l	$6d000064,$0c800000,$40006700,$01da6e00
	dc.l	$0122f22e,$d080ff90,$f22e9000,$ff5cf23c
	dc.l	$88000000,$0000f22e,$4827ff84,$f201a800
	dc.l	$f23c9000,$00000000,$83aeff64,$f22ef080
	dc.l	$ff842f02,$322eff84,$24010281,$00007fff
	dc.l	$02428000,$92808242,$3d41ff84,$241ff22e
	dc.l	$d080ff84,$4e75f22e,$d080ff90,$f22e9000
	dc.l	$ff5cf23c,$88000000,$0000f22e,$4827ff84
	dc.l	$f201a800,$f23c9000,$00000000,$83aeff64
	dc.l	$00ae0000,$1048ff64,$122eff62,$02010013
	dc.l	$6620082e,$0003ff64,$56c1202e,$ff5c0200
	dc.l	$003061ff,$00003c98,$812eff64,$f210d080
	dc.l	$4e75f22e,$f080ff84,$2f02322e,$ff842401
	dc.l	$02810000,$7fff9280,$04810000,$60000241
	dc.l	$7fff0242,$80008242,$3d41ff84,$241ff22e
	dc.l	$d040ff84,$60acf22e,$d080ff90,$f22e9000
	dc.l	$ff5cf23c,$88000000,$0000f22e,$4827ff84
	dc.l	$f201a800,$f23c9000,$00000000,$83aeff64
	dc.l	$f2000098,$f23c58b8,$0002f293,$ff646000
	dc.l	$ff0c08ee,$0003ff66,$f22ed080,$ff90f23c
	dc.l	$90000000,$0010f23c,$88000000,$0000f22e
	dc.l	$4827ff84,$f201a800,$f23c9000,$00000000
	dc.l	$83aeff64,$122eff62,$0201000b,$6620f22e
	dc.l	$f080ff84,$41eeff84,$222eff5c,$61ff0000
	dc.l	$3b56812e,$ff64f22e,$d080ff84,$4e75f22e
	dc.l	$d040ff90,$f22e9000,$ff5cf23c,$88000000
	dc.l	$0000f22e,$48a7ff84,$f23c9000,$00000000
	dc.l	$f22ef040,$ff842f02,$322eff84,$24010281
	dc.l	$00007fff,$02428000,$92800681,$00006000
	dc.l	$02417fff,$82423d41,$ff84241f,$f22ed040
	dc.l	$ff846000,$ff8af22e,$d080ff90,$f22e9000
	dc.l	$ff5cf23c,$88000000,$0000f22e,$4827ff84
	dc.l	$f201a800,$f23c9000,$00000000,$83aeff64
	dc.l	$f2000098,$f23c58b8,$0002f292,$fe20f294
	dc.l	$ff12f22e,$d040ff90,$222eff5c,$020100c0
	dc.l	$00010010,$f2019000,$f23c8800,$00000000
	dc.l	$f22e48a7,$ff84f23c,$90000000,$0000f200
	dc.l	$0498f23c,$58b80002,$f293fde2,$6000fed4
	dc.l	$323b120a,$4efb1006,$4afc0030,$fd560072
	dc.l	$0078006c,$fd560066,$00000000,$00720072
	dc.l	$0060006c,$00720066,$00000000,$007e0060
	dc.l	$007e006c,$007e0066,$00000000,$006c006c
	dc.l	$006c006c,$006c0066,$00000000,$fd560072
	dc.l	$0078006c,$fd560066,$00000000,$00660066
	dc.l	$00660066,$00660066,$00000000,$60ff0000
	dc.l	$101e60ff,$00000f94,$60ff0000,$0f8e60ff
	dc.l	$ffffed0e,$60ffffff,$ed6260ff,$ffffed2e
	dc.l	$2d40ff5c,$4241122e,$ff4fe709,$822eff4e
	dc.l	$6600027c,$3d690000,$ff902d69,$0004ff94
	dc.l	$2d690008,$ff983d68,$0000ff84,$2d680004
	dc.l	$ff882d68,$0008ff8c,$61ff0000,$0e582f00
	dc.l	$61ff0000,$0efc4497,$d197322e,$ff5eec09
	dc.l	$201f0c80,$ffffc001,$6f000064,$0c800000
	dc.l	$3fff6700,$01b66e00,$0100f22e,$d080ff90
	dc.l	$f22e9000,$ff5cf23c,$88000000,$0000f22e
	dc.l	$4824ff84,$f201a800,$f23c9000,$00000000
	dc.l	$83aeff64,$f22ef080,$ff842f02,$322eff84
	dc.l	$24010281,$00007fff,$02428000,$92808242
	dc.l	$3d41ff84,$241ff22e,$d080ff84,$4e75f22e
	dc.l	$d080ff90,$f22e9000,$ff5cf23c,$88000000
	dc.l	$0000f22e,$4824ff84,$f201a800,$f23c9000
	dc.l	$00000000,$83aeff64,$f227e001,$3217dffc
	dc.l	$0000000c,$02810000,$7fff9280,$0c810000
	dc.l	$7fff6d90,$006e1048,$ff66122e,$ff620201
	dc.l	$00136620,$082e0003,$ff6456c1,$202eff5c
	dc.l	$02000030,$61ff0000,$3936812e,$ff64f210
	dc.l	$d0804e75,$f22ef080,$ff842f02,$322eff84
	dc.l	$24010281,$00007fff,$02428000,$92800481
	dc.l	$00006000,$02417fff,$82423d41,$ff84241f
	dc.l	$f22ed040,$ff8460ac,$08ee0003,$ff66f22e
	dc.l	$d080ff90,$f23c9000,$00000010,$f23c8800
	dc.l	$00000000,$f22e4824,$ff84f201,$a800f23c
	dc.l	$90000000,$000083ae,$ff64122e,$ff620201
	dc.l	$000b6620,$f22ef080,$ff8441ee,$ff84222e
	dc.l	$ff5c61ff,$00003830,$812eff64,$f22ed080
	dc.l	$ff844e75,$f22ed040,$ff90f22e,$9000ff5c
	dc.l	$f23c8800,$00000000,$f22e48a4,$ff84f23c
	dc.l	$90000000,$0000f22e,$f040ff84,$2f02322e
	dc.l	$ff842401,$02810000,$7fff0242,$80009280
	dc.l	$06810000,$60000241,$7fff8242,$3d41ff84
	dc.l	$241ff22e,$d040ff84,$608af22e,$d080ff90
	dc.l	$f22e9000,$ff5cf23c,$88000000,$0000f22e
	dc.l	$4824ff84,$f201a800,$f23c9000,$00000000
	dc.l	$83aeff64,$f2000098,$f23c58b8,$0001f292
	dc.l	$fe44f294,$ff14f22e,$d040ff90,$42810001
	dc.l	$0010f201,$9000f23c,$88000000,$0000f22e
	dc.l	$48a4ff84,$f23c9000,$00000000,$f2000498
	dc.l	$f23c58b8,$0001f293,$fe0c6000,$fedc323b
	dc.l	$120a4efb,$10064afc,$0030fd7a,$00720078
	dc.l	$0060fd7a,$00660000,$00000078,$006c0078
	dc.l	$00600078,$00660000,$0000007e,$007e006c
	dc.l	$0060007e,$00660000,$00000060,$00600060
	dc.l	$00600060,$00660000,$0000fd7a,$00720078
	dc.l	$0060fd7a,$00660000,$00000066,$00660066
	dc.l	$00660066,$00660000,$000060ff,$00000c7c
	dc.l	$60ff0000,$0c7660ff,$00000cf4,$60ffffff
	dc.l	$f0ce60ff,$fffff09c,$60ffffff,$f0f40200
	dc.l	$00300000,$00406008,$02000030,$00000080
	dc.l	$2d40ff5c,$4241122e,$ff4fe709,$822eff4e
	dc.l	$6600024c,$61ff0000,$0a5cf22e,$d080ff90
	dc.l	$f23c8800,$00000000,$f22e9000,$ff5cf22e
	dc.l	$4822ff84,$f23c9000,$00000000,$f201a800
	dc.l	$83aeff64,$f281003c,$2f02f227,$e001322e
	dc.l	$ff5eec09,$34170282,$00007fff,$9480b4bb
	dc.l	$14246c38,$b4bb142a,$6d0000b8,$67000184
	dc.l	$32170241,$80008242,$3e81f21f,$d080241f
	dc.l	$4e754e75,$00007fff,$0000407f,$000043ff
	dc.l	$00000000,$00003f81,$00003c01,$00ae0000
	dc.l	$1048ff64,$122eff62,$02010013,$6624dffc
	dc.l	$0000000c,$082e0003,$ff6456c1,$202eff5c
	dc.l	$61ff0000,$366a812e,$ff64f210,$d080241f
	dc.l	$4e75122e,$ff5c0201,$00c0661a,$32170241
	dc.l	$80000482,$00006000,$02427fff,$82423e81
	dc.l	$f21fd040,$60bef22e,$d080ff90,$222eff5c
	dc.l	$02010030,$f2019000,$f22e4822,$ff84f23c
	dc.l	$90000000,$0000dffc,$0000000c,$f227e001
	dc.l	$60ba08ee,$0003ff66,$dffc0000,$000cf22e
	dc.l	$d080ff90,$f23c9000,$00000010,$f23c8800
	dc.l	$00000000,$f22e4822,$ff84f23c,$90000000
	dc.l	$0000f201,$a80083ae,$ff64122e,$ff620201
	dc.l	$000b6622,$f22ef080,$ff8441ee,$ff84222e
	dc.l	$ff5c61ff,$000034ba,$812eff64,$f22ed080
	dc.l	$ff84241f,$4e75f22e,$d040ff90,$222eff5c
	dc.l	$020100c0,$664ef22e,$9000ff5c,$f23c8800
	dc.l	$00000000,$f22e48a2,$ff84f23c,$90000000
	dc.l	$0000f22e,$f040ff84,$322eff84,$24010281
	dc.l	$00007fff,$02428000,$92800681,$00006000
	dc.l	$02417fff,$82423d41,$ff84f22e,$d040ff84
	dc.l	$6000ff82,$222eff5c,$02010030,$f2019000
	dc.l	$60aa222e,$ff5c0201,$00c06700,$fe74222f
	dc.l	$00040c81,$80000000,$6600fe66,$4aaf0008
	dc.l	$6600fe5e,$082e0001,$ff666700,$fe54f22e
	dc.l	$d040ff90,$222eff5c,$020100c0,$00010010
	dc.l	$f2019000,$f23c8800,$00000000,$f22e48a2
	dc.l	$ff84f23c,$90000000,$0000f200,$0018f200
	dc.l	$0498f200,$0438f292,$feca6000,$fe14323b
	dc.l	$120a4efb,$10064afc,$0030fdaa,$00e4011c
	dc.l	$0060fdaa,$00660000,$000000bc,$006c011c
	dc.l	$006000bc,$00660000,$00000130,$0130010c
	dc.l	$00600130,$00660000,$00000060,$00600060
	dc.l	$00600060,$00660000,$0000fdaa,$00e4011c
	dc.l	$0060fdaa,$00660000,$00000066,$00660066
	dc.l	$00660066,$00660000,$000060ff,$0000097c
	dc.l	$60ff0000,$09761028,$00001229,$0000b101
	dc.l	$6b000016,$4a006b2e,$f23c4400,$00000000
	dc.l	$1d7c0004,$ff644e75,$122eff5f,$02010030
	dc.l	$0c010020,$6710f23c,$44000000,$00001d7c
	dc.l	$0004ff64,$4e75f23c,$44008000,$00001d7c
	dc.l	$000cff64,$4e753d68,$0000ff84,$2d680004
	dc.l	$ff882d68,$0008ff8c,$61ff0000,$0828426e
	dc.l	$ff9042ae,$ff9442ae,$ff986000,$fcce3d69
	dc.l	$0000ff90,$2d690004,$ff942d69,$0008ff98
	dc.l	$61ff0000,$08ac426e,$ff8442ae,$ff8842ae
	dc.l	$ff8c6000,$fca61028,$00001229,$0000b300
	dc.l	$6bff0000,$094af228,$d0800000,$4a280000
	dc.l	$6a1c1d7c,$000aff64,$4e75f229,$d0800000
	dc.l	$4a290000,$6a081d7c,$000aff64,$4e751d7c
	dc.l	$0002ff64,$4e750200,$00300000,$00406008
	dc.l	$02000030,$00000080,$2d40ff5c,$4241122e
	dc.l	$ff4fe709,$822eff4e,$6600024c,$61ff0000
	dc.l	$0694f22e,$d080ff90,$f23c8800,$00000000
	dc.l	$f22e9000,$ff5cf22e,$4828ff84,$f23c9000
	dc.l	$00000000,$f201a800,$83aeff64,$f281003c
	dc.l	$2f02f227,$e001322e,$ff5eec09,$34170282
	dc.l	$00007fff,$9480b4bb,$14246c38,$b4bb142a
	dc.l	$6d0000b8,$67000184,$32170241,$80008242
	dc.l	$3e81f21f,$d080241f,$4e754e75,$00007fff
	dc.l	$0000407f,$000043ff,$00000000,$00003f81
	dc.l	$00003c01,$00ae0000,$1048ff64,$122eff62
	dc.l	$02010013,$6624dffc,$0000000c,$082e0003
	dc.l	$ff6456c1,$202eff5c,$61ff0000,$32a2812e
	dc.l	$ff64f210,$d080241f,$4e75122e,$ff5c0201
	dc.l	$00c0661a,$32170241,$80000482,$00006000
	dc.l	$02427fff,$82423e81,$f21fd040,$60bef22e
	dc.l	$d080ff90,$222eff5c,$02010030,$f2019000
	dc.l	$f22e4828,$ff84f23c,$90000000,$0000dffc
	dc.l	$0000000c,$f227e001,$60ba08ee,$0003ff66
	dc.l	$dffc0000,$000cf22e,$d080ff90,$f23c9000
	dc.l	$00000010,$f23c8800,$00000000,$f22e4828
	dc.l	$ff84f23c,$90000000,$0000f201,$a80083ae
	dc.l	$ff64122e,$ff620201,$000b6622,$f22ef080
	dc.l	$ff8441ee,$ff84222e,$ff5c61ff,$000030f2
	dc.l	$812eff64,$f22ed080,$ff84241f,$4e75f22e
	dc.l	$d040ff90,$222eff5c,$020100c0,$664ef22e
	dc.l	$9000ff5c,$f23c8800,$00000000,$f22e48a8
	dc.l	$ff84f23c,$90000000,$0000f22e,$f040ff84
	dc.l	$322eff84,$24010281,$00007fff,$02428000
	dc.l	$92800681,$00006000,$02417fff,$82423d41
	dc.l	$ff84f22e,$d040ff84,$6000ff82,$222eff5c
	dc.l	$02010030,$f2019000,$60aa222e,$ff5c0201
	dc.l	$00c06700,$fe74222f,$00040c81,$80000000
	dc.l	$6600fe66,$4aaf0008,$6600fe5e,$082e0001
	dc.l	$ff666700,$fe54f22e,$d040ff90,$222eff5c
	dc.l	$020100c0,$00010010,$f2019000,$f23c8800
	dc.l	$00000000,$f22e48a8,$ff84f23c,$90000000
	dc.l	$0000f200,$0018f200,$0498f200,$0438f292
	dc.l	$feca6000,$fe14323b,$120a4efb,$10064afc
	dc.l	$0030fdaa,$00e2011a,$0060fdaa,$00660000
	dc.l	$000000ba,$006c011a,$006000ba,$00660000
	dc.l	$00000130,$0130010a,$00600130,$00660000
	dc.l	$00000060,$00600060,$00600060,$00660000
	dc.l	$0000fdaa,$00e2011a,$0060fdaa,$00660000
	dc.l	$00000066,$00660066,$00660066,$00660000
	dc.l	$000060ff,$000005b4,$60ff0000,$05ae1028
	dc.l	$00001229,$0000b300,$6a144a00,$6b2ef23c
	dc.l	$44000000,$00001d7c,$0004ff64,$4e75122e
	dc.l	$ff5f0201,$00300c01,$00206710,$f23c4400
	dc.l	$00000000,$1d7c0004,$ff644e75,$f23c4400
	dc.l	$80000000,$1d7c000c,$ff644e75,$3d680000
	dc.l	$ff842d68,$0004ff88,$2d680008,$ff8c61ff
	dc.l	$00000462,$426eff90,$42aeff94,$42aeff98
	dc.l	$6000fcd0,$3d690000,$ff902d69,$0004ff94
	dc.l	$2d690008,$ff9861ff,$000004e6,$426eff84
	dc.l	$42aeff88,$42aeff8c,$6000fca8,$10280000
	dc.l	$12290000,$b3006aff,$00000584,$f228d080
	dc.l	$0000f200,$001af293,$001e1d7c,$000aff64
	dc.l	$4e75f229,$d0800000,$4a290000,$6a081d7c
	dc.l	$000aff64,$4e751d7c,$0002ff64,$4e750200
	dc.l	$00300000,$00406008,$02000030,$00000080
	dc.l	$2d40ff5c,$4241122e,$ff4e6600,$02744a28
	dc.l	$00006bff,$00000528,$020000c0,$6648f22e
	dc.l	$9000ff5c,$f23c8800,$00000000,$f2104804
	dc.l	$f201a800,$83aeff64,$4e754a28,$00006bff
	dc.l	$000004fc,$020000c0,$661c3d68,$0000ff84
	dc.l	$2d680004,$ff882d68,$0008ff8c,$61ff0000
	dc.l	$03ae6000,$003e0c00,$00406600,$00843d68
	dc.l	$0000ff84,$2d680004,$ff882d68,$0008ff8c
	dc.l	$61ff0000,$038a0c80,$0000007e,$67000098
	dc.l	$6e00009e,$0c80ffff,$ff806700,$01a46d00
	dc.l	$0120f23c,$88000000,$0000f22e,$9000ff5c
	dc.l	$f22e4804,$ff84f201,$a800f23c,$90000000
	dc.l	$000083ae,$ff642f02,$f22ef080,$ff84322e
	dc.l	$ff842401,$02810000,$7fff9280,$02428000
	dc.l	$84413d42,$ff84241f,$f22ed080,$ff844e75
	dc.l	$3d680000,$ff842d68,$0004ff88,$2d680008
	dc.l	$ff8c61ff,$00000308,$0c800000,$03fe6700
	dc.l	$00166e1c,$0c80ffff,$fc006700,$01246d00
	dc.l	$00a06000,$ff7e082e,$0000ff85,$6600ff74
	dc.l	$08ee0003,$ff66f23c,$90000000,$0010f23c
	dc.l	$88000000,$0000f22e,$4804ff84,$f201a800
	dc.l	$f23c9000,$00000000,$83aeff64,$122eff62
	dc.l	$0201000b,$6620f22e,$f080ff84,$41eeff84
	dc.l	$222eff5c,$61ff0000,$2d28812e,$ff64f22e
	dc.l	$d080ff84,$4e752d6e,$ff88ff94,$2d6eff8c
	dc.l	$ff98322e,$ff842f02,$24010281,$00007fff
	dc.l	$02428000,$92800681,$00006000,$02417fff
	dc.l	$82423d41,$ff90f22e,$d040ff90,$241f60a6
	dc.l	$f23c8800,$00000000,$f22e9000,$ff5cf22e
	dc.l	$4804ff84,$f23c9000,$00000000,$f201a800
	dc.l	$83aeff64,$00ae0000,$1048ff64,$122eff62
	dc.l	$02010013,$661c082e,$0003ff64,$56c1202e
	dc.l	$ff5c61ff,$00002d98,$812eff64,$f210d080
	dc.l	$4e752f02,$322eff84,$24010281,$00007fff
	dc.l	$02428000,$92800481,$00006000,$02417fff
	dc.l	$82423d41,$ff84f22e,$d040ff84,$241f60b6
	dc.l	$082e0000,$ff856600,$ff78f23c,$88000000
	dc.l	$0000f22e,$9000ff5c,$f22e4804,$ff84f201
	dc.l	$a800f23c,$90000000,$000083ae,$ff64f200
	dc.l	$0080f23c,$58b80001,$f293ff6a,$6000fe48
	dc.l	$0c010004,$6700fdb4,$0c010001,$67160c01
	dc.l	$00026736,$0c010005,$67ff0000,$023660ff
	dc.l	$00000244,$4a280000,$6b10f23c,$44000000
	dc.l	$00001d7c,$0004ff64,$4e75f23c,$44008000
	dc.l	$00001d7c,$000cff64,$4e754a28,$00006bff
	dc.l	$0000026c,$f228d080,$00001d7c,$0002ff64
	dc.l	$4e752d68,$0004ff88,$2d690004,$ff942d68
	dc.l	$0008ff8c,$2d690008,$ff983028,$00003229
	dc.l	$00003d40,$ff843d41,$ff900240,$7fff0241
	dc.l	$7fff3d40,$ff543d41,$ff56b041,$6cff0000
	dc.l	$005c61ff,$0000015a,$2f000c2e,$0004ff4e
	dc.l	$661041ee,$ff8461ff,$00002940,$44403d40
	dc.l	$ff54302e,$ff560440,$0042b06e,$ff546c1a
	dc.l	$302eff54,$d06f0002,$322eff84,$02418000
	dc.l	$80413d40,$ff84201f,$4e75026e,$8000ff84
	dc.l	$08ee0000,$ff85201f,$4e7561ff,$00000056
	dc.l	$2f000c2e,$0004ff4f,$661041ee,$ff9061ff
	dc.l	$000028e8,$44403d40,$ff56302e,$ff540440
	dc.l	$0042b06e,$ff566c1a,$302eff56,$d06f0002
	dc.l	$322eff90,$02418000,$80413d40,$ff90201f
	dc.l	$4e75026e,$8000ff90,$08ee0000,$ff91201f
	dc.l	$4e75322e,$ff843001,$02810000,$7fff0240
	dc.l	$80000040,$3fff3d40,$ff840c2e,$0004ff4e
	dc.l	$670a203c,$00003fff,$90814e75,$41eeff84
	dc.l	$61ff0000,$28764480,$220060e6,$0c2e0004
	dc.l	$ff4e673a,$322eff84,$02810000,$7fff026e
	dc.l	$8000ff84,$08010000,$6712006e,$3fffff84
	dc.l	$203c0000,$3fff9081,$e2804e75,$006e3ffe
	dc.l	$ff84203c,$00003ffe,$9081e280,$4e7541ee
	dc.l	$ff8461ff,$00002824,$08000000,$6710006e
	dc.l	$3fffff84,$06800000,$3fffe280,$4e75006e
	dc.l	$3ffeff84,$06800000,$3ffee280,$4e75322e
	dc.l	$ff903001,$02810000,$7fff0240,$80000040
	dc.l	$3fff3d40,$ff900c2e,$0004ff4f,$670a203c
	dc.l	$00003fff,$90814e75,$41eeff90,$61ff0000
	dc.l	$27ca4480,$220060e6,$0c2e0005,$ff4f6732
	dc.l	$0c2e0003,$ff4f673e,$0c2e0003,$ff4e6714
	dc.l	$08ee0006,$ff7000ae,$01004080,$ff6441ee
	dc.l	$ff6c6042,$00ae0100,$0000ff64,$41eeff6c
	dc.l	$603400ae,$01004080,$ff6408ee,$0006ff7c
	dc.l	$41eeff78,$602041ee,$ff780c2e,$0005ff4e
	dc.l	$66ff0000,$000c00ae,$00004080,$ff6400ae
	dc.l	$01000000,$ff640828,$00070000,$670800ae
	dc.l	$08000000,$ff64f210,$d0804e75,$00ae0100
	dc.l	$2080ff64,$f23bd080,$01700000,$00084e75
	dc.l	$7fff0000,$ffffffff,$ffffffff,$2d40ff54
	dc.l	$302eff42,$4281122e,$ff64e099,$f2018800
	dc.l	$323b0206,$4efb1002,$02340040,$02f8030c
	dc.l	$03200334,$0348035c,$03660352,$033e032a
	dc.l	$03160302,$004a0238,$023a0276,$0054009e
	dc.l	$0102014c,$01b201fc,$021801d8,$018c0128
	dc.l	$00de007a,$02b6025a,$f2810006,$6000032a
	dc.l	$4e75f28e,$00066000,$03204e75,$f2920022
	dc.l	$082e0000,$ff646700,$031000ae,$00008080
	dc.l	$ff64082e,$0007ff62,$6600032c,$600002fa
	dc.l	$4e75f29d,$00066000,$02f0082e,$0000ff64
	dc.l	$671200ae,$00008080,$ff64082e,$0007ff62
	dc.l	$66000304,$4e75f293,$0022082e,$0000ff64
	dc.l	$670002c6,$00ae0000,$8080ff64,$082e0007
	dc.l	$ff626600,$02e26000,$02b0082e,$0000ff64
	dc.l	$671200ae,$00008080,$ff64082e,$0007ff62
	dc.l	$660002c4,$4e75f29c,$00066000,$028c082e
	dc.l	$0000ff64,$671200ae,$00008080,$ff64082e
	dc.l	$0007ff62,$660002a0,$4e75f294,$0022082e
	dc.l	$0000ff64,$67000262,$00ae0000,$8080ff64
	dc.l	$082e0007,$ff626600,$027e6000,$024c4e75
	dc.l	$f29b0006,$60000242,$082e0000,$ff646712
	dc.l	$00ae0000,$8080ff64,$082e0007,$ff626600
	dc.l	$02564e75,$f2950022,$082e0000,$ff646700
	dc.l	$021800ae,$00008080,$ff64082e,$0007ff62
	dc.l	$66000234,$60000202,$082e0000,$ff646712
	dc.l	$00ae0000,$8080ff64,$082e0007,$ff626600
	dc.l	$02164e75,$f29a0006,$600001de,$082e0000
	dc.l	$ff646700,$001400ae,$00008080,$ff64082e
	dc.l	$0007ff62,$660001f0,$4e75f296,$0022082e
	dc.l	$0000ff64,$670001b2,$00ae0000,$8080ff64
	dc.l	$082e0007,$ff626600,$01ce6000,$019c4e75
	dc.l	$f2990006,$60000192,$082e0000,$ff646712
	dc.l	$00ae0000,$8080ff64,$082e0007,$ff626600
	dc.l	$01a64e75,$f2970018,$00ae0000,$8080ff64
	dc.l	$082e0007,$ff626600,$018e6000,$015c4e75
	dc.l	$f2980006,$60000152,$00ae0000,$8080ff64
	dc.l	$082e0007,$ff626600,$016e4e75,$6000013a
	dc.l	$4e75082e,$0000ff64,$6700012e,$00ae0000
	dc.l	$8080ff64,$082e0007,$ff626600,$014a6000
	dc.l	$0118082e,$0000ff64,$671200ae,$00008080
	dc.l	$ff64082e,$0007ff62,$6600012c,$4e75f291
	dc.l	$0022082e,$0000ff64,$670000ee,$00ae0000
	dc.l	$8080ff64,$082e0007,$ff626600,$010a6000
	dc.l	$00d8082e,$0000ff64,$671200ae,$00008080
	dc.l	$ff64082e,$0007ff62,$660000ec,$4e75f29e
	dc.l	$0022082e,$0000ff64,$670000ae,$00ae0000
	dc.l	$8080ff64,$082e0007,$ff626600,$00ca6000
	dc.l	$0098082e,$0000ff64,$67000014,$00ae0000
	dc.l	$8080ff64,$082e0007,$ff626600,$00aa4e75
	dc.l	$f2820006,$60000072,$4e75f28d,$00066000
	dc.l	$00684e75,$f2830006,$6000005e,$4e75f28c
	dc.l	$00066000,$00544e75,$f2840006,$6000004a
	dc.l	$4e75f28b,$00066000,$00404e75,$f2850006
	dc.l	$60000036,$4e75f28a,$00066000,$002c4e75
	dc.l	$f2860006,$60000022,$4e75f289,$00066000
	dc.l	$00184e75,$f2870006,$6000000e,$4e75f288
	dc.l	$00066000,$00044e75,$122eff41,$02410007
	dc.l	$61ff0000,$1d665340,$61ff0000,$1dd00c40
	dc.l	$ffff6602,$4e75202e,$ff54d0ae,$ff685880
	dc.l	$2d400006,$4e751d7c,$0002ff4a,$4e75302e
	dc.l	$ff424281,$122eff64,$e099f201,$8800323b
	dc.l	$02064efb,$1002021e,$004002e4,$02f002fc
	dc.l	$03080314,$03200326,$031a030e,$030202f6
	dc.l	$02ea0046,$02200224,$0260004c,$009200f8
	dc.l	$013e01a4,$01ea0202,$01c4017e,$011800d2
	dc.l	$006c02a2,$0240f281,$02ea4e75,$f28e02e4
	dc.l	$4e75f292,$02de082e,$0000ff64,$671200ae
	dc.l	$00008080,$ff64082e,$0007ff62,$660002cc
	dc.l	$4e75f29d,$00044e75,$082e0000,$ff646700
	dc.l	$02b200ae,$00008080,$ff64082e,$0007ff62
	dc.l	$660002a8,$6000029c,$f293001e,$082e0000
	dc.l	$ff646712,$00ae0000,$8080ff64,$082e0007
	dc.l	$ff626600,$02864e75,$082e0000,$ff646700
	dc.l	$027200ae,$00008080,$ff64082e,$0007ff62
	dc.l	$66000268,$6000025c,$f29c0004,$4e75082e
	dc.l	$0000ff64,$6700024c,$00ae0000,$8080ff64
	dc.l	$082e0007,$ff626600,$02426000,$0236f294
	dc.l	$0232082e,$0000ff64,$671200ae,$00008080
	dc.l	$ff64082e,$0007ff62,$66000220,$4e75f29b
	dc.l	$00044e75,$082e0000,$ff646700,$020600ae
	dc.l	$00008080,$ff64082e,$0007ff62,$660001fc
	dc.l	$600001f0,$f295001e,$082e0000,$ff646712
	dc.l	$00ae0000,$8080ff64,$082e0007,$ff626600
	dc.l	$01da4e75,$082e0000,$ff646700,$01c600ae
	dc.l	$00008080,$ff64082e,$0007ff62,$660001bc
	dc.l	$600001b0,$f29a0004,$4e75082e,$0000ff64
	dc.l	$670001a0,$00ae0000,$8080ff64,$082e0007
	dc.l	$ff626600,$01966000,$018af296,$0186082e
	dc.l	$0000ff64,$671200ae,$00008080,$ff64082e
	dc.l	$0007ff62,$66000174,$4e75f299,$00044e75
	dc.l	$082e0000,$ff646700,$015a00ae,$00008080
	dc.l	$ff64082e,$0007ff62,$66000150,$60000144
	dc.l	$f2970140,$00ae0000,$8080ff64,$082e0007
	dc.l	$ff626600,$01364e75,$f2980004,$4e7500ae
	dc.l	$00008080,$ff64082e,$0007ff62,$6600011c
	dc.l	$60000110,$4e756000,$010a082e,$0000ff64
	dc.l	$671200ae,$00008080,$ff64082e,$0007ff62
	dc.l	$660000f8,$4e75082e,$0000ff64,$670000e4
	dc.l	$00ae0000,$8080ff64,$082e0007,$ff626600
	dc.l	$00da6000,$00cef291,$0020082e,$0000ff64
	dc.l	$67000014,$00ae0000,$8080ff64,$082e0007
	dc.l	$ff626600,$00b64e75,$082e0000,$ff646700
	dc.l	$00a200ae,$00008080,$ff64082e,$0007ff62
	dc.l	$66000098,$6000008c,$f29e0020,$082e0000
	dc.l	$ff646700,$001400ae,$00008080,$ff64082e
	dc.l	$0007ff62,$66000074,$4e75082e,$0000ff64
	dc.l	$67000060,$00ae0000,$8080ff64,$082e0007
	dc.l	$ff626600,$00566000,$004af282,$00464e75
	dc.l	$f28d0040,$4e75f283,$003a4e75,$f28c0034
	dc.l	$4e75f284,$002e4e75,$f28b0028,$4e75f285
	dc.l	$00224e75,$f28a001c,$4e75f286,$00164e75
	dc.l	$f2890010,$4e75f287,$000a4e75,$f2880004
	dc.l	$4e751d7c,$0001ff4a,$4e751d7c,$0002ff4a
	dc.l	$4e75302e,$ff424281,$122eff64,$e099f201
	dc.l	$8800323b,$02064efb,$10020208,$004002ac
	dc.l	$02cc02ec,$030c032c,$034c035c,$033c031c
	dc.l	$02fc02dc,$02bc0050,$020e0214,$02440060
	dc.l	$00a400fa,$013e0194,$01d801f0,$01b60172
	dc.l	$011c00d8,$00820278,$022cf281,$00084200
	dc.l	$6000032e,$50c06000,$0328f28e,$00084200
	dc.l	$6000031e,$50c06000,$0318f292,$001a4200
	dc.l	$082e0000,$ff646700,$030800ae,$00008080
	dc.l	$ff646000,$02f250c0,$600002f6,$f29d0008
	dc.l	$42006000,$02ec50c0,$082e0000,$ff646700
	dc.l	$02e000ae,$00008080,$ff646000,$02caf293
	dc.l	$001a4200,$082e0000,$ff646700,$02c400ae
	dc.l	$00008080,$ff646000,$02ae50c0,$082e0000
	dc.l	$ff646700,$02ac00ae,$00008080,$ff646000
	dc.l	$0296f29c,$00084200,$60000296,$50c0082e
	dc.l	$0000ff64,$6700028a,$00ae0000,$8080ff64
	dc.l	$60000274,$f294001a,$4200082e,$0000ff64
	dc.l	$6700026e,$00ae0000,$8080ff64,$60000258
	dc.l	$50c06000,$025cf29b,$00084200,$60000252
	dc.l	$50c0082e,$0000ff64,$67000246,$00ae0000
	dc.l	$8080ff64,$60000230,$f295001a,$4200082e
	dc.l	$0000ff64,$6700022a,$00ae0000,$8080ff64
	dc.l	$60000214,$50c0082e,$0000ff64,$67000212
	dc.l	$00ae0000,$8080ff64,$600001fc,$f29a0008
	dc.l	$42006000,$01fc50c0,$082e0000,$ff646700
	dc.l	$01f000ae,$00008080,$ff646000,$01daf296
	dc.l	$001a4200,$082e0000,$ff646700,$01d400ae
	dc.l	$00008080,$ff646000,$01be50c0,$600001c2
	dc.l	$f2990008,$42006000,$01b850c0,$082e0000
	dc.l	$ff646700,$01ac00ae,$00008080,$ff646000
	dc.l	$0196f297,$00104200,$00ae0000,$8080ff64
	dc.l	$60000184,$50c06000,$0188f298,$00084200
	dc.l	$6000017e,$50c000ae,$00008080,$ff646000
	dc.l	$01664200,$6000016a,$50c06000,$01644200
	dc.l	$082e0000,$ff646700,$015800ae,$00008080
	dc.l	$ff646000,$014250c0,$082e0000,$ff646700
	dc.l	$014000ae,$00008080,$ff646000,$012af291
	dc.l	$001a4200,$082e0000,$ff646700,$012400ae
	dc.l	$00008080,$ff646000,$010e50c0,$082e0000
	dc.l	$ff646700,$010c00ae,$00008080,$ff646000
	dc.l	$00f6f29e,$001a4200,$082e0000,$ff646700
	dc.l	$00f000ae,$00008080,$ff646000,$00da50c0
	dc.l	$082e0000,$ff646700,$00d800ae,$00008080
	dc.l	$ff646000,$00c2f282,$00084200,$600000c2
	dc.l	$50c06000,$00bcf28d,$00084200,$600000b2
	dc.l	$50c06000,$00acf283,$00084200,$600000a2
	dc.l	$50c06000,$009cf28c,$00084200,$60000092
	dc.l	$50c06000,$008cf284,$00084200,$60000082
	dc.l	$50c06000,$007cf28b,$00084200,$60000072
	dc.l	$50c06000,$006cf285,$00084200,$60000062
	dc.l	$50c06000,$005cf28a,$00084200,$60000052
	dc.l	$50c06000,$004cf286,$00084200,$60000042
	dc.l	$50c06000,$003cf289,$00084200,$60000032
	dc.l	$50c06000,$002cf287,$00084200,$60000022
	dc.l	$50c06000,$001cf288,$00084200,$60000012
	dc.l	$50c06000,$000c082e,$0007ff62,$66000088
	dc.l	$2040122e,$ff412001,$02010038,$66102200
	dc.l	$02410007,$200861ff,$0000172a,$4e750c01
	dc.l	$0018671a,$0c010020,$67382008,$206e000c
	dc.l	$61ffffff,$5a7c4a81,$66000054,$4e752008
	dc.l	$206e000c,$61ffffff,$5a684a81,$66000040
	dc.l	$122eff41,$02410007,$700161ff,$00001722
	dc.l	$4e752008,$206e000c,$61ffffff,$5a444a81
	dc.l	$6600001c,$122eff41,$02410007,$700161ff
	dc.l	$0000174e,$4e751d7c,$0002ff4a,$4e753d7c
	dc.l	$00a1000a,$60ff0000,$2b86122e,$ff430241
	dc.l	$0070e809,$61ff0000,$15b20280,$000000ff
	dc.l	$2f00103b,$09200148,$2f0061ff,$00000340
	dc.l	$201f221f,$67000134,$082e0005,$ff426700
	dc.l	$00b8082e,$0004ff42,$6600001a,$123b1120
	dc.l	$021e082e,$00050004,$670a0c2e,$0008ff4a
	dc.l	$66024e75,$22489fc0,$41d74a01,$6a0c20ee
	dc.l	$ffdc20ee,$ffe020ee,$ffe4e309,$6a0c20ee
	dc.l	$ffe820ee,$ffec20ee,$fff0e309,$6a0af210
	dc.l	$f020d1fc,$0000000c,$e3096a0a,$f210f010
	dc.l	$d1fc0000,$000ce309,$6a0af210,$f008d1fc
	dc.l	$0000000c,$e3096a0a,$f210f004,$d1fc0000
	dc.l	$000ce309,$6a0af210,$f002d1fc,$0000000c
	dc.l	$e3096a0a,$f210f001,$d1fc0000,$000c2d49
	dc.l	$ff5441d7,$2f0061ff,$ffff58b2,$201fdfc0
	dc.l	$4a816600,$071e4e75,$2d48ff54,$9fc043d7
	dc.l	$2f012f00,$61ffffff,$587e201f,$4a816600
	dc.l	$070e221f,$41d74a01,$6a0c2d58,$ffdc2d58
	dc.l	$ffe02d58,$ffe4e309,$6a0c2d58,$ffe82d58
	dc.l	$ffec2d58,$fff0e309,$6a04f218,$d020e309
	dc.l	$6a04f218,$d010e309,$6a04f218,$d008e309
	dc.l	$6a04f218,$d004e309,$6a04f218,$d002e309
	dc.l	$6a04f218,$d001dfc0,$4e754e75,$000c0c18
	dc.l	$0c181824,$0c181824,$18242430,$0c181824
	dc.l	$18242430,$18242430,$2430303c,$0c181824
	dc.l	$18242430,$18242430,$2430303c,$18242430
	dc.l	$2430303c,$2430303c,$303c3c48,$0c181824
	dc.l	$18242430,$18242430,$2430303c,$18242430
	dc.l	$2430303c,$2430303c,$303c3c48,$18242430
	dc.l	$2430303c,$2430303c,$303c3c48,$2430303c
	dc.l	$303c3c48,$303c3c48,$3c484854,$0c181824
	dc.l	$18242430,$18242430,$2430303c,$18242430
	dc.l	$2430303c,$2430303c,$303c3c48,$18242430
	dc.l	$2430303c,$2430303c,$303c3c48,$2430303c
	dc.l	$303c3c48,$303c3c48,$3c484854,$18242430
	dc.l	$2430303c,$2430303c,$303c3c48,$2430303c
	dc.l	$303c3c48,$303c3c48,$3c484854,$2430303c
	dc.l	$303c3c48,$303c3c48,$3c484854,$303c3c48
	dc.l	$3c484854,$3c484854,$48545460,$008040c0
	dc.l	$20a060e0,$109050d0,$30b070f0,$088848c8
	dc.l	$28a868e8,$189858d8,$38b878f8,$048444c4
	dc.l	$24a464e4,$149454d4,$34b474f4,$0c8c4ccc
	dc.l	$2cac6cec,$1c9c5cdc,$3cbc7cfc,$028242c2
	dc.l	$22a262e2,$129252d2,$32b272f2,$0a8a4aca
	dc.l	$2aaa6aea,$1a9a5ada,$3aba7afa,$068646c6
	dc.l	$26a666e6,$169656d6,$36b676f6,$0e8e4ece
	dc.l	$2eae6eee,$1e9e5ede,$3ebe7efe,$018141c1
	dc.l	$21a161e1,$119151d1,$31b171f1,$098949c9
	dc.l	$29a969e9,$199959d9,$39b979f9,$058545c5
	dc.l	$25a565e5,$159555d5,$35b575f5,$0d8d4dcd
	dc.l	$2dad6ded,$1d9d5ddd,$3dbd7dfd,$038343c3
	dc.l	$23a363e3,$139353d3,$33b373f3,$0b8b4bcb
	dc.l	$2bab6beb,$1b9b5bdb,$3bbb7bfb,$078747c7
	dc.l	$27a767e7,$179757d7,$37b777f7,$0f8f4fcf
	dc.l	$2faf6fef,$1f9f5fdf,$3fbf7fff,$2040302e
	dc.l	$ff403200,$0240003f,$02810000,$0007303b
	dc.l	$020a4efb,$00064afc,$00400000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000080,$0086008c
	dc.l	$00900094,$0098009c,$00a000a6,$00b600c6
	dc.l	$00d200de,$00ea00f6,$01020118,$01260134
	dc.l	$013e0148,$0152015c,$0166017a,$019801b6
	dc.l	$01d201ee,$020a0226,$02420260,$02600260
	dc.l	$02600260,$02600260,$026002c0,$02da02f4
	dc.l	$03140000,$00000000,$0000206e,$ffa44e75
	dc.l	$206effa8,$4e75204a,$4e75204b,$4e75204c
	dc.l	$4e75204d,$4e752056,$4e75206e,$ffd84e75
	dc.l	$202effa4,$2200d288,$2d41ffa4,$20404e75
	dc.l	$202effa8,$2200d288,$2d41ffa8,$20404e75
	dc.l	$200a2200,$d2882441,$20404e75,$200b2200
	dc.l	$d2882641,$20404e75,$200c2200,$d2882841
	dc.l	$20404e75,$200d2200,$d2882a41,$20404e75
	dc.l	$20162200,$d2882c81,$20404e75,$1d7c0004
	dc.l	$ff4a202e,$ffd82200,$d2882d41,$ffd82040
	dc.l	$4e75202e,$ffa49088,$2d40ffa4,$20404e75
	dc.l	$202effa8,$90882d40,$ffa82040,$4e75200a
	dc.l	$90882440,$20404e75,$200b9088,$26402040
	dc.l	$4e75200c,$90882840,$20404e75,$200d9088
	dc.l	$2a402040,$4e752016,$90882c80,$20404e75
	dc.l	$1d7c0008,$ff4a202e,$ffd89088,$2d40ffd8
	dc.l	$20404e75,$206eff44,$54aeff44,$61ffffff
	dc.l	$54a24a81,$66ffffff,$68203040,$d1eeffa4
	dc.l	$4e75206e,$ff4454ae,$ff4461ff,$ffff5484
	dc.l	$4a8166ff,$ffff6802,$3040d1ee,$ffa84e75
	dc.l	$206eff44,$54aeff44,$61ffffff,$54664a81
	dc.l	$66ffffff,$67e43040,$d1ca4e75,$206eff44
	dc.l	$54aeff44,$61ffffff,$544a4a81,$66ffffff
	dc.l	$67c83040,$d1cb4e75,$206eff44,$54aeff44
	dc.l	$61ffffff,$542e4a81,$66ffffff,$67ac3040
	dc.l	$d1cc4e75,$206eff44,$54aeff44,$61ffffff
	dc.l	$54124a81,$66ffffff,$67903040,$d1cd4e75
	dc.l	$206eff44,$54aeff44,$61ffffff,$53f64a81
	dc.l	$66ffffff,$67743040,$d1d64e75,$206eff44
	dc.l	$54aeff44,$61ffffff,$53da4a81,$66ffffff
	dc.l	$67583040,$d1eeffd8,$4e755081,$61ff0000
	dc.l	$0fda2f00,$206eff44,$54aeff44,$61ffffff
	dc.l	$53b24a81,$66ffffff,$6730205f,$08000008
	dc.l	$660000e6,$2d40ff54,$2200e959,$0241000f
	dc.l	$61ff0000,$0fa62f02,$242eff54,$0802000b
	dc.l	$660248c0,$2202ef59,$02810000,$0003e3a8
	dc.l	$49c2d082,$d1c0241f,$4e75206e,$ff4454ae
	dc.l	$ff4461ff,$ffff535c,$4a8166ff,$ffff66da
	dc.l	$30404e75,$206eff44,$58aeff44,$61ffffff
	dc.l	$53584a81,$66ffffff,$66c02040,$4e75206e
	dc.l	$ff4454ae,$ff4461ff,$ffff5328,$4a8166ff
	dc.l	$ffff66a6,$3040d1ee,$ff445588,$4e75206e
	dc.l	$ff4454ae,$ff4461ff,$ffff5308,$4a8166ff
	dc.l	$ffff6686,$206eff44,$55880800,$00086600
	dc.l	$00382d40,$ff542200,$e9590241,$000f61ff
	dc.l	$00000ef8,$2f02242e,$ff540802,$000b6602
	dc.l	$48c02202,$ef590281,$00000003,$e3a849c2
	dc.l	$d082d1c0,$241f4e75,$08000006,$670c48e7
	dc.l	$3c002a00,$26084282,$60282d40,$ff54e9c0
	dc.l	$140461ff,$00000eb4,$48e73c00,$24002a2e
	dc.l	$ff542608,$0805000b,$660248c2,$e9c50542
	dc.l	$e1aa0805,$00076702,$4283e9c5,$06820c00
	dc.l	$00026d34,$6718206e,$ff4458ae,$ff4461ff
	dc.l	$ffff5276,$4a8166ff,$000000b0,$6018206e
	dc.l	$ff4454ae,$ff4461ff,$ffff5248,$4a8166ff
	dc.l	$00000098,$48c0d680,$e9c50782,$6700006e
	dc.l	$0c000002,$6d346718,$206eff44,$58aeff44
	dc.l	$61ffffff,$52344a81,$66ff0000,$006e601c
	dc.l	$206eff44,$54aeff44,$61ffffff,$52064a81
	dc.l	$66ff0000,$005648c0,$60024280,$28000805
	dc.l	$00026714,$204361ff,$ffff5240,$4a816600
	dc.l	$0028d082,$d0846018,$d6822043,$61ffffff
	dc.l	$522a4a81,$66000012,$d0846004,$d6822003
	dc.l	$20404cdf,$003c4e75,$20434cdf,$003c303c
	dc.l	$010160ff,$ffff6582,$4cdf003c,$60ffffff
	dc.l	$652861ff,$000023c6,$303c00e1,$600a61ff
	dc.l	$000023ba,$303c0161,$206eff54,$60ffffff
	dc.l	$6558102e,$ff420c00,$009c6700,$00b20c00
	dc.l	$00986700,$00740c00,$00946736,$206eff44
	dc.l	$58aeff44,$61ffffff,$51704a81,$66ffffff
	dc.l	$64d82d40,$ff64206e,$ff4458ae,$ff4461ff
	dc.l	$ffff5156,$4a8166ff,$ffff64be,$2d40ff68
	dc.l	$4e75206e,$ff4458ae,$ff4461ff,$ffff513a
	dc.l	$4a8166ff,$ffff64a2,$2d40ff60,$206eff44
	dc.l	$58aeff44,$61ffffff,$51204a81,$66ffffff
	dc.l	$64882d40,$ff684e75,$206eff44,$58aeff44
	dc.l	$61ffffff,$51044a81,$66ffffff,$646c2d40
	dc.l	$ff60206e,$ff4458ae,$ff4461ff,$ffff50ea
	dc.l	$4a8166ff,$ffff6452,$2d40ff64,$4e75206e
	dc.l	$ff4458ae,$ff4461ff,$ffff50ce,$4a8166ff
	dc.l	$ffff6436,$2d40ff60,$206eff44,$58aeff44
	dc.l	$61ffffff,$50b44a81,$66ffffff,$641c2d40
	dc.l	$ff64206e,$ff4458ae,$ff4461ff,$ffff509a
	dc.l	$4a8166ff,$ffff6402,$2d40ff68,$4e752040
	dc.l	$102eff41,$22000240,$00380281,$00000007
	dc.l	$0c000018,$67240c00,$0020672c,$80410c00
	dc.l	$003c6706,$206e000c,$4e751d7c,$0080ff4a
	dc.l	$41f60162,$ff680004,$4e752008,$61ff0000
	dc.l	$0d70206e,$000c4e75,$200861ff,$00000db2
	dc.l	$206e000c,$0c00000c,$67024e75,$51882d48
	dc.l	$000c4e75,$102eff41,$22000240,$00380281
	dc.l	$00000007,$0c000018,$670e0c00,$00206700
	dc.l	$0076206e,$000c4e75,$323b120e,$206e000c
	dc.l	$4efb1006,$4afc0008,$0010001a,$0024002c
	dc.l	$0034003c,$0044004e,$06ae0000,$000cffa4
	dc.l	$4e7506ae,$0000000c,$ffa84e75,$d5fc0000
	dc.l	$000c4e75,$d7fc0000,$000c4e75,$d9fc0000
	dc.l	$000c4e75,$dbfc0000,$000c4e75,$06ae0000
	dc.l	$000cffd4,$4e751d7c,$0004ff4a,$06ae0000
	dc.l	$000cffd8,$4e75323b,$1214206e,$000c5188
	dc.l	$51ae000c,$4efb1006,$4afc0008,$00100016
	dc.l	$001c0020,$00240028,$002c0032,$2d48ffa4
	dc.l	$4e752d48,$ffa84e75,$24484e75,$26484e75
	dc.l	$28484e75,$2a484e75,$2d48ffd4,$4e752d48
	dc.l	$ffd81d7c,$0008ff4a,$4e75082e,$0006ff42
	dc.l	$6664102e,$ff430800,$0005672c,$08000004
	dc.l	$670a0240,$007f0c40,$0038661c,$e9ee0183
	dc.l	$ff4261ff,$00000d6a,$61ff0000,$12060c00
	dc.l	$00066722,$1d40ff4f,$e9ee00c3,$ff4261ff
	dc.l	$00000cbe,$61ff0000,$11ea0c00,$0006670e
	dc.l	$1d40ff4e,$4e7561ff,$00001148,$60d661ff
	dc.l	$00001140,$60ea302e,$ff420800,$0005672c
	dc.l	$08000004,$670a0240,$007f0c40,$0038661c
	dc.l	$e9ee0183,$ff4261ff,$00000d06,$61ff0000
	dc.l	$11a20c00,$00066726,$1d40ff4f,$e9ee00c3
	dc.l	$ff42e9ee,$1283ff40,$660000be,$422eff4e
	dc.l	$e9ee1343,$ff40303b,$02124efb,$000e61ff
	dc.l	$000010e0,$60d24afc,$00080010,$006a0000
	dc.l	$0000002e,$0000004c,$000061ff,$00000a5c
	dc.l	$f2004000,$f22ef080,$ff6cf281,$00044e75
	dc.l	$1d7c0001,$ff4e4e75,$61ff0000,$0a3ef200
	dc.l	$5000f22e,$f080ff6c,$f2810004,$4e751d7c
	dc.l	$0001ff4e,$4e7561ff,$00000a20,$f2005800
	dc.l	$f22ef080,$ff6cf281,$00044e75,$1d7c0001
	dc.l	$ff4e4e75,$61ff0000,$0a022d40,$ff5441ee
	dc.l	$ff5461ff,$000011de,$1d40ff4e,$0c000005
	dc.l	$670001a4,$0c000004,$6700015e,$f2104400
	dc.l	$f22ef080,$ff6c4e75,$422eff4e,$303b020a
	dc.l	$4efb0006,$4afc0008,$001000e2,$027202b0
	dc.l	$005601a0,$009c0000,$700461ff,$fffffd22
	dc.l	$0c2e0080,$ff4a6726,$61ffffff,$4dde4a81
	dc.l	$66ff0000,$1eecf200,$4000f22e,$f080ff6c
	dc.l	$f2810004,$4e751d7c,$0001ff4e,$4e7561ff
	dc.l	$ffff4d76,$4a8166ff,$ffff6e8a,$60d87002
	dc.l	$61ffffff,$fcdc0c2e,$0080ff4a,$672661ff
	dc.l	$ffff4d82,$4a8166ff,$00001e98,$f2005000
	dc.l	$f22ef080,$ff6cf281,$00044e75,$1d7c0001
	dc.l	$ff4e4e75,$61ffffff,$4d1a4a81,$66ffffff
	dc.l	$6e4460d8,$700161ff,$fffffc96,$0c2e0080
	dc.l	$ff4a6726,$61ffffff,$4d264a81,$66ff0000
	dc.l	$1e42f200,$5800f22e,$f080ff6c,$f2810004
	dc.l	$4e751d7c,$0001ff4e,$4e7561ff,$ffff4cd4
	dc.l	$4a8166ff,$ffff6dfe,$60d87004,$61ffffff
	dc.l	$fc500c2e,$0080ff4a,$673e61ff,$ffff4d0c
	dc.l	$2d40ff54,$4a8166ff,$00001e16,$41eeff54
	dc.l	$61ff0000,$10a01d40,$ff4e0c00,$00046700
	dc.l	$00280c00,$00056700,$005ef22e,$4400ff54
	dc.l	$f22ef080,$ff6c4e75,$61ffffff,$4c8c4a81
	dc.l	$66ffffff,$6da060c4,$426eff6c,$e9d00257
	dc.l	$e1882d40,$ff7042ae,$ff74426e,$ff6c0810
	dc.l	$00076706,$08ee0007,$ff6c41ee,$ff6c61ff
	dc.l	$00000e78,$323c3f81,$9240836e,$ff6c1d7c
	dc.l	$0000ff4e,$4e753d7c,$7fffff6c,$e9d00257
	dc.l	$e1882d40,$ff7042ae,$ff740810,$00076706
	dc.l	$08ee0007,$ff6c4e75,$700861ff,$fffffb92
	dc.l	$0c2e0080,$ff4a6740,$43eeff54,$700861ff
	dc.l	$ffff4bc4,$4a8166ff,$00001d64,$41eeff54
	dc.l	$61ff0000,$0f701d40,$ff4e0c00,$00046700
	dc.l	$002e0c00,$00056700,$0068f22e,$5400ff54
	dc.l	$f22ef080,$ff6c4e75,$43eeff54,$700861ff
	dc.l	$ffff4b6e,$4a8166ff,$ffff6cda,$60be426e
	dc.l	$ff6ce9d0,$031f2d40,$ff70e9e8,$02d50004
	dc.l	$720be3a8,$2d40ff74,$08100007,$670608ee
	dc.l	$0007ff6c,$41eeff6c,$61ff0000,$0dae323c
	dc.l	$3c019240,$836eff6c,$1d7c0000,$ff4e4e75
	dc.l	$3d7c7fff,$ff6ce9d0,$031f2d40,$ff70e9e8
	dc.l	$02d50004,$720be3a8,$2d40ff74,$08100007
	dc.l	$670608ee,$0007ff6c,$4e75700c,$61ffffff
	dc.l	$fac043ee,$ff6c700c,$61ffffff,$4afa4a81
	dc.l	$66ff0000,$1ca841ee,$ff6c61ff,$00000e24
	dc.l	$0c000006,$67061d40,$ff4e4e75,$61ff0000
	dc.l	$0d821d40,$ff4e4e75,$61ff0000,$125441ee
	dc.l	$ff6c61ff,$00000dfc,$0c000006,$67061d40
	dc.l	$ff4e4e75,$61ff0000,$0d5a1d40,$ff4e4e75
	dc.l	$e9ee10c3,$ff42327b,$120a4efb,$98064afc
	dc.l	$000800e0,$01e00148,$06200078,$041a0010
	dc.l	$06204a2e,$ff4e664c,$f228d080,$0000f200
	dc.l	$9000f200,$7800f23c,$90000000,$0000f201
	dc.l	$a800836e,$ff66122e,$ff410201,$00386714
	dc.l	$206e000c,$61ffffff,$4ae84a81,$66ff0000
	dc.l	$1c0a4e75,$122eff41,$02410007,$61ff0000
	dc.l	$07644e75,$22280000,$02818000,$00000081
	dc.l	$00800000,$f2014400,$60a44a2e,$ff4e664c
	dc.l	$f228d080,$0000f200,$9000f200,$7000f23c
	dc.l	$90000000,$0000f201,$a800836e,$ff66122e
	dc.l	$ff410201,$00386714,$206e000c,$61ffffff
	dc.l	$4a964a81,$66ff0000,$1bb04e75,$122eff41
	dc.l	$02410007,$61ff0000,$06c04e75,$22280000
	dc.l	$02818000,$00000081,$00800000,$f2014400
	dc.l	$60a44a2e,$ff4e664c,$f228d080,$0000f200
	dc.l	$9000f200,$6000f23c,$90000000,$0000f201
	dc.l	$a800836e,$ff66122e,$ff410201,$00386714
	dc.l	$206e000c,$61ffffff,$4a444a81,$66ff0000
	dc.l	$1b564e75,$122eff41,$02410007,$61ff0000
	dc.l	$061c4e75,$22280000,$02818000,$00000081
	dc.l	$00800000,$f2014400,$60a43d68,$0000ff84
	dc.l	$426eff86,$2d680004,$ff882d68,$0008ff8c
	dc.l	$f228d080,$000061ff,$fffff94c,$224841ee
	dc.l	$ff84700c,$0c2e0008,$ff4a6726,$61ffffff
	dc.l	$492c4a81,$66000052,$4a2eff4e,$66024e75
	dc.l	$08ee0003,$ff66102e,$ff620200,$000a6616
	dc.l	$4e7561ff,$ffff5788,$4a816600,$002c4a2e
	dc.l	$ff4e66dc,$4e7541ee,$ff8461ff,$00000b3c
	dc.l	$44400240,$7fff026e,$8000ff84,$816eff84
	dc.l	$f22ed040,$ff844e75,$2caeffd4,$60ff0000
	dc.l	$1ab20200,$00300000,$00402d40,$ff5c3028
	dc.l	$00000240,$7fff0c40,$407e6e00,$00e66700
	dc.l	$01520c40,$3f816d00,$0058f228,$d0800000
	dc.l	$f22e9000,$ff5cf23c,$88000000,$0000f200
	dc.l	$6400f23c,$90000000,$0000f201,$a800836e
	dc.l	$ff66122e,$ff410201,$00386714,$206e000c
	dc.l	$61ffffff,$49184a81,$66ff0000,$1a2a4e75
	dc.l	$122eff41,$02410007,$61ff0000,$04f04e75
	dc.l	$08ee0003,$ff663d68,$0000ff84,$2d680004
	dc.l	$ff882d68,$0008ff8c,$2f084280,$0c2e0004
	dc.l	$ff4e660a,$41eeff84,$61ff0000,$0a6e41ee
	dc.l	$ff84222e,$ff5c61ff,$00000c86,$41eeff84
	dc.l	$61ff0000,$034c122e,$ff410201,$00386714
	dc.l	$206e000c,$61ffffff,$48a44a81,$66ff0000
	dc.l	$19b6600e,$122eff41,$02410007,$61ff0000
	dc.l	$047c122e,$ff620201,$000a6600,$00b8588f
	dc.l	$4e754a28,$0007660e,$4aa80008,$6608006e
	dc.l	$1048ff66,$6006006e,$1248ff66,$2f084a28
	dc.l	$00005bc1,$202eff5c,$61ff0000,$0d12f210
	dc.l	$d080f200,$6400122e,$ff410201,$00386714
	dc.l	$206e000c,$61ffffff,$48344a81,$66ff0000
	dc.l	$1946600e,$122eff41,$02410007,$61ff0000
	dc.l	$040c122e,$ff620201,$000a6600,$007c588f
	dc.l	$4e753228,$00000241,$80000041,$3fff3d41
	dc.l	$ff842d68,$0004ff88,$2d680008,$ff8cf22e
	dc.l	$9000ff5c,$f22e4800,$ff84f23c,$90000000
	dc.l	$0000f200,$0018f23c,$58380002,$f294fe7c
	dc.l	$6000ff50,$205f3d68,$0000ff84,$2d680004
	dc.l	$ff882d68,$0008ff8c,$0c2e0004,$ff4e662c
	dc.l	$41eeff84,$61ff0000,$09424480,$02407fff
	dc.l	$efee004f,$ff846014,$205f3d68,$0000ff84
	dc.l	$2d680004,$ff882d68,$0008ff8c,$08ae0007
	dc.l	$ff8456ee,$ff8641ee,$ff84122e,$ff5fe809
	dc.l	$0241000c,$4841122e,$ff5fe809,$02410003
	dc.l	$428061ff,$00000782,$4a2eff86,$670608ee
	dc.l	$0007ff84,$f22ed040,$ff844e75,$02000030
	dc.l	$00000080,$2d40ff5c,$30280000,$02407fff
	dc.l	$0c4043fe,$6e0000c8,$67000120,$0c403c01
	dc.l	$6d000046,$f228d080,$0000f22e,$9000ff5c
	dc.l	$f23c8800,$00000000,$f22e7400,$ff54f23c
	dc.l	$90000000,$0000f200,$a800816e,$ff66226e
	dc.l	$000c41ee,$ff547008,$61ffffff,$46304a81
	dc.l	$66ff0000,$18004e75,$08ee0003,$ff663d68
	dc.l	$0000ff84,$2d680004,$ff882d68,$0008ff8c
	dc.l	$2f084280,$0c2e0004,$ff4e660a,$41eeff84
	dc.l	$61ff0000,$084641ee,$ff84222e,$ff5c61ff
	dc.l	$00000a5e,$41eeff84,$61ff0000,$00d22d40
	dc.l	$ff542d41,$ff58226e,$000c41ee,$ff547008
	dc.l	$61ffffff,$45c84a81,$66ff0000,$1798122e
	dc.l	$ff620201,$000a6600,$fe9c588f,$4e753028
	dc.l	$000a0240,$07ff6608,$006e1048,$ff666006
	dc.l	$006e1248,$ff662f08,$4a280000,$5bc1202e
	dc.l	$ff5c61ff,$00000af8,$f210d080,$f22e7400
	dc.l	$ff54226e,$000c41ee,$ff547008,$61ffffff
	dc.l	$456c4a81,$66ff0000,$173c122e,$ff620201
	dc.l	$000a6600,$fe74588f,$4e753228,$00000241
	dc.l	$80000041,$3fff3d41,$ff842d68,$0004ff88
	dc.l	$2d680008,$ff8cf22e,$9000ff5c,$f22e4800
	dc.l	$ff84f23c,$90000000,$0000f200,$0018f23c
	dc.l	$58380002,$f294feae,$6000ff64,$42803028
	dc.l	$00000440,$3fff0640,$03ff4a28,$00046b02
	dc.l	$53404840,$e9884a28,$00006a04,$08c0001f
	dc.l	$22280004,$e9c11054,$80812d40,$ff542228
	dc.l	$00047015,$e1a92d41,$ff582228,$0008e9c1
	dc.l	$0015222e,$ff588280,$202eff54,$4e754280
	dc.l	$30280000,$04403fff,$0640007f,$4a280004
	dc.l	$6b025340,$4840ef88,$4a280000,$6a0408c0
	dc.l	$001f2228,$00040281,$7fffff00,$e0898081
	dc.l	$4e7561ff,$fffff490,$2f08102e,$ff4e6600
	dc.l	$0082082e,$0004ff42,$6712122e,$ff43e809
	dc.l	$02410007,$61ff0000,$00926004,$102eff43
	dc.l	$ebc00647,$2f0041ee,$ff6c61ff,$00000ed0
	dc.l	$02aecfff,$f00fff84,$201f4a2e,$ff876616
	dc.l	$4aaeff88,$66104aae,$ff8c660a,$4a806606
	dc.l	$026ef000,$ff8441ee,$ff84225f,$700c0c2e
	dc.l	$0008ff4a,$670e61ff,$ffff4412,$4a816600
	dc.l	$fb384e75,$61ffffff,$52864a81,$6600fb2a
	dc.l	$4e750c00,$00046700,$ff7a41ee,$ff6c426e
	dc.l	$ff6e0c00,$00056702,$60c0006e,$4080ff66
	dc.l	$08ee0006,$ff7060b2,$303b1206,$4efb0002
	dc.l	$00200026,$002c0030,$00340038,$003c0040
	dc.l	$0044004a,$00500054,$0058005c,$00600064
	dc.l	$202eff9c,$4e75202e,$ffa04e75,$20024e75
	dc.l	$20034e75,$20044e75,$20054e75,$20064e75
	dc.l	$20074e75,$202effa4,$4e75202e,$ffa84e75
	dc.l	$200a4e75,$200b4e75,$200c4e75,$200d4e75
	dc.l	$20164e75,$202effd8,$4e75323b,$12064efb
	dc.l	$10020010,$0016001c,$00200024,$0028002c
	dc.l	$00302d40,$ff9c4e75,$2d40ffa0,$4e752400
	dc.l	$4e752600,$4e752800,$4e752a00,$4e752c00
	dc.l	$4e752e00,$4e75323b,$12064efb,$10020010
	dc.l	$0016001c,$00200024,$0028002c,$00303d40
	dc.l	$ff9e4e75,$3d40ffa2,$4e753400,$4e753600
	dc.l	$4e753800,$4e753a00,$4e753c00,$4e753e00
	dc.l	$4e75323b,$12064efb,$10020010,$0016001c
	dc.l	$00200024,$0028002c,$00301d40,$ff9f4e75
	dc.l	$1d40ffa3,$4e751400,$4e751600,$4e751800
	dc.l	$4e751a00,$4e751c00,$4e751e00,$4e75323b
	dc.l	$12064efb,$10020010,$0016001c,$00200024
	dc.l	$0028002c,$0030d1ae,$ffa44e75,$d1aeffa8
	dc.l	$4e75d5c0,$4e75d7c0,$4e75d9c0,$4e75dbc0
	dc.l	$4e75d196,$4e751d7c,$0004ff4a,$0c000001
	dc.l	$6706d1ae,$ffd84e75,$54aeffd8,$4e75323b
	dc.l	$12064efb,$10020010,$0016001c,$00200024
	dc.l	$0028002c,$003091ae,$ffa44e75,$91aeffa8
	dc.l	$4e7595c0,$4e7597c0,$4e7599c0,$4e759bc0
	dc.l	$4e759196,$4e751d7c,$0008ff4a,$0c000001
	dc.l	$670691ae,$ffd84e75,$55aeffd8,$4e75303b
	dc.l	$02064efb,$00020010,$00280040,$004c0058
	dc.l	$00640070,$007c2d6e,$ffdcff6c,$2d6effe0
	dc.l	$ff702d6e,$ffe4ff74,$41eeff6c,$4e752d6e
	dc.l	$ffe8ff6c,$2d6effec,$ff702d6e,$fff0ff74
	dc.l	$41eeff6c,$4e75f22e,$f020ff6c,$41eeff6c
	dc.l	$4e75f22e,$f010ff6c,$41eeff6c,$4e75f22e
	dc.l	$f008ff6c,$41eeff6c,$4e75f22e,$f004ff6c
	dc.l	$41eeff6c,$4e75f22e,$f002ff6c,$41eeff6c
	dc.l	$4e75f22e,$f001ff6c,$41eeff6c,$4e75303b
	dc.l	$02064efb,$00020010,$00280040,$004c0058
	dc.l	$00640070,$007c2d6e,$ffdcff78,$2d6effe0
	dc.l	$ff7c2d6e,$ffe4ff80,$41eeff78,$4e752d6e
	dc.l	$ffe8ff78,$2d6effec,$ff7c2d6e,$fff0ff80
	dc.l	$41eeff78,$4e75f22e,$f020ff78,$41eeff78
	dc.l	$4e75f22e,$f010ff78,$41eeff78,$4e75f22e
	dc.l	$f008ff78,$41eeff78,$4e75f22e,$f004ff78
	dc.l	$41eeff78,$4e75f22e,$f002ff78,$41eeff78
	dc.l	$4e75f22e,$f001ff78,$41eeff78,$4e75303b
	dc.l	$02064efb,$00020010,$00180020,$002a0034
	dc.l	$003e0048,$0052f22e,$f080ffdc,$4e75f22e
	dc.l	$f080ffe8,$4e75f227,$e001f21f,$d0204e75
	dc.l	$f227e001,$f21fd010,$4e75f227,$e001f21f
	dc.l	$d0084e75,$f227e001,$f21fd004,$4e75f227
	dc.l	$e001f21f,$d0024e75,$f227e001,$f21fd001
	dc.l	$4e750000,$3f813c01,$e408323b,$02f63001
	dc.l	$90680000,$0c400042,$6a164280,$082e0001
	dc.l	$ff666704,$08c0001d,$61ff0000,$001a4e75
	dc.l	$203c2000,$00003141,$000042a8,$000442a8
	dc.l	$00084e75,$2d680008,$ff542d40,$ff582001
	dc.l	$92680000,$6f100c41,$00206d10,$0c410040
	dc.l	$6d506000,$009a202e,$ff584e75,$2f023140
	dc.l	$00007020,$90410c41,$001d6d08,$142eff58
	dc.l	$852eff57,$e9e82020,$0004e9e8,$18000004
	dc.l	$e9ee0800,$ff542142,$00042141,$0008e8c0
	dc.l	$009e6704,$08c0001d,$0280e000,$0000241f
	dc.l	$4e752f02,$31400000,$04410020,$70209041
	dc.l	$142eff58,$852eff57,$e9e82020,$0004e9e8
	dc.l	$18000004,$e8c1009e,$660ce8ee,$081fff54
	dc.l	$66042001,$60062001,$08c0001d,$42a80004
	dc.l	$21420008,$0280e000,$0000241f,$4e753140
	dc.l	$00000c41,$00416d12,$672442a8,$000442a8
	dc.l	$0008203c,$20000000,$4e752028,$00042200
	dc.l	$0280c000,$00000281,$3fffffff,$60122028
	dc.l	$00040280,$80000000,$e2880281,$7fffffff
	dc.l	$66164aa8,$00086610,$4a2eff58,$660a42a8
	dc.l	$000442a8,$00084e75,$08c0001d,$42a80004
	dc.l	$42a80008,$4e7561ff,$00000110,$4a806700
	dc.l	$00fa006e,$0208ff66,$327b1206,$4efb9802
	dc.l	$004000ea,$00240008,$4a280002,$6b0000dc
	dc.l	$70ff4841,$0c010004,$6700003e,$6e000094
	dc.l	$60000064,$4a280002,$6a0000c0,$70ff4841
	dc.l	$0c010004,$67000022,$6e000078,$60000048
	dc.l	$e3806400,$00a64841,$0c010004,$6700000a
	dc.l	$6e000060,$60000030,$06a80000,$01000004
	dc.l	$640ce4e8,$0004e4e8,$00065268,$00004a80
	dc.l	$66060268,$fe000006,$02a8ffff,$ff000004
	dc.l	$42a80008,$4e7552a8,$0008641a,$52a80004
	dc.l	$6414e4e8,$0004e4e8,$0006e4e8,$0008e4e8
	dc.l	$000a5268,$00004a80,$66060228,$00fe000b
	dc.l	$4e7506a8,$00000800,$0008641a,$52a80004
	dc.l	$6414e4e8,$0004e4e8,$0006e4e8,$0008e4e8
	dc.l	$000a5268,$00004a80,$66060268,$f000000a
	dc.l	$02a8ffff,$f8000008,$4e754841,$0c010004
	dc.l	$6700ff86,$6eea4e75,$48414a01,$66044841
	dc.l	$4e7548e7,$30000c01,$00046622,$e9e83602
	dc.l	$0004741e,$e5ab2428,$00040282,$0000003f
	dc.l	$66284aa8,$00086622,$4a80661e,$6020e9e8
	dc.l	$35420008,$741ee5ab,$24280008,$02820000
	dc.l	$01ff6606,$4a806602,$600408c3,$001d2003
	dc.l	$4cdf000c,$48414e75,$2f022f03,$20280004
	dc.l	$22280008,$edc02000,$671ae5a8,$e9c13022
	dc.l	$8083e5a9,$21400004,$21410008,$2002261f
	dc.l	$241f4e75,$edc12000,$e5a90682,$00000020
	dc.l	$21410004,$42a80008,$2002261f,$241f4e75
	dc.l	$ede80000,$0004660e,$ede80000,$00086700
	dc.l	$00740640,$00204281,$32280000,$02417fff
	dc.l	$b0416e1c,$92403028,$00000240,$80008240
	dc.l	$31410000,$61ffffff,$ff82103c,$00004e75
	dc.l	$0c010020,$6e20e9e8,$08400004,$21400004
	dc.l	$20280008,$e3a82140,$00080268,$80000000
	dc.l	$103c0004,$4e750441,$00202028,$0008e3a8
	dc.l	$21400004,$42a80008,$02688000,$0000103c
	dc.l	$00044e75,$02688000,$0000103c,$00014e75
	dc.l	$30280000,$02407fff,$0c407fff,$67480828
	dc.l	$00070004,$6706103c,$00004e75,$4a406618
	dc.l	$4aa80004,$660c4aa8,$00086606,$103c0001
	dc.l	$4e75103c,$00044e75,$4aa80004,$66124aa8
	dc.l	$0008660c,$02688000,$0000103c,$00014e75
	dc.l	$103c0006,$4e754aa8,$00086612,$20280004
	dc.l	$02807fff,$ffff6606,$103c0002,$4e750828
	dc.l	$00060004,$6706103c,$00034e75,$103c0005
	dc.l	$4e752028,$00002200,$02807ff0,$0000670e
	dc.l	$0c807ff0,$00006728,$103c0000,$4e750281
	dc.l	$000fffff,$66ff0000,$00144aa8,$000466ff
	dc.l	$0000000a,$103c0001,$4e75103c,$00044e75
	dc.l	$0281000f,$ffff66ff,$00000014,$4aa80004
	dc.l	$66ff0000,$000a103c,$00024e75,$08010013
	dc.l	$66ff0000,$000a103c,$00054e75,$103c0003
	dc.l	$4e752028,$00002200,$02807f80,$0000670e
	dc.l	$0c807f80,$0000671e,$103c0000,$4e750281
	dc.l	$007fffff,$66ff0000,$000a103c,$00014e75
	dc.l	$103c0004,$4e750281,$007fffff,$66ff0000
	dc.l	$000a103c,$00024e75,$08010016,$66ff0000
	dc.l	$000a103c,$00054e75,$103c0003,$4e752f01
	dc.l	$08280007,$000056e8,$00023228,$00000241
	dc.l	$7fff9240,$31410000,$2f08202f,$00040240
	dc.l	$00c0e848,$61ffffff,$fae22057,$322f0006
	dc.l	$024100c0,$e8494841,$322f0006,$02410030
	dc.l	$e84961ff,$fffffc22,$205f08a8,$00070000
	dc.l	$4a280002,$670a08e8,$00070000,$42280002
	dc.l	$42804aa8,$0004660a,$4aa80008,$660408c0
	dc.l	$0002082e,$0001ff66,$670608ee,$0005ff67
	dc.l	$588f4e75,$2f010828,$00070000,$56e80002
	dc.l	$32280000,$02417fff,$92403141,$00002f08
	dc.l	$428061ff,$fffffa64,$2057323c,$00044841
	dc.l	$322f0006,$02410030,$e84961ff,$fffffbaa
	dc.l	$205f08a8,$00070000,$4a280002,$670a08e8
	dc.l	$00070000,$42280002,$42804aa8,$0004660a
	dc.l	$4aa80008,$660408c0,$0002082e,$0001ff66
	dc.l	$670608ee,$0005ff67,$588f4e75,$02410010
	dc.l	$e8088200,$3001e309,$600e0241,$00108200
	dc.l	$48408200,$3001e309,$103b0008,$41fb1620
	dc.l	$4e750200,$00020200,$00020200,$00020000
	dc.l	$00000a08,$0a080a08,$0a080a08,$0a087fff
	dc.l	$00000000,$00000000,$00000000,$00007ffe
	dc.l	$0000ffff,$ffffffff,$ffff0000,$00007ffe
	dc.l	$0000ffff,$ffffffff,$ffff0000,$00007fff
	dc.l	$00000000,$00000000,$00000000,$00007fff
	dc.l	$00000000,$00000000,$00000000,$0000407e
	dc.l	$0000ffff,$ff000000,$00000000,$0000407e
	dc.l	$0000ffff,$ff000000,$00000000,$00007fff
	dc.l	$00000000,$00000000,$00000000,$00007fff
	dc.l	$00000000,$00000000,$00000000,$000043fe
	dc.l	$0000ffff,$ffffffff,$f8000000,$000043fe
	dc.l	$0000ffff,$ffffffff,$f8000000,$00007fff
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$0000ffff
	dc.l	$00000000,$00000000,$00000000,$0000fffe
	dc.l	$0000ffff,$ffffffff,$ffff0000,$0000ffff
	dc.l	$00000000,$00000000,$00000000,$0000fffe
	dc.l	$0000ffff,$ffffffff,$ffff0000,$0000ffff
	dc.l	$00000000,$00000000,$00000000,$0000c07e
	dc.l	$0000ffff,$ff000000,$00000000,$0000ffff
	dc.l	$00000000,$00000000,$00000000,$0000c07e
	dc.l	$0000ffff,$ff000000,$00000000,$0000ffff
	dc.l	$00000000,$00000000,$00000000,$0000c3fe
	dc.l	$0000ffff,$ffffffff,$f8000000,$0000ffff
	dc.l	$00000000,$00000000,$00000000,$0000c3fe
	dc.l	$0000ffff,$ffffffff,$f8000000,$0000700c
	dc.l	$61ffffff,$e82c43ee,$ff6c700c,$61ffffff
	dc.l	$38664a81,$66ff0000,$0a14e9ee,$004fff6c
	dc.l	$0c407fff,$66024e75,$102eff6f,$0200000f
	dc.l	$660e4aae,$ff706608,$4aaeff74,$66024e75
	dc.l	$41eeff6c,$61ff0000,$001cf22e,$f080ff6c
	dc.l	$4e750000,$00000203,$02030203,$03020302
	dc.l	$02032d68,$0000ff84,$2d680004,$ff882d68
	dc.l	$0008ff8c,$41eeff84,$48e73c00,$f227e001
	dc.l	$74027604,$28104281,$4c3c1001,$0000000a
	dc.l	$e9c408c4,$d2805803,$51caffee,$0804001e
	dc.l	$67024481,$04810000,$00106c0e,$44810084
	dc.l	$40000000,$00904000,$00002f01,$7201f23c
	dc.l	$44000000,$0000e9d0,$0704f200,$58222830
	dc.l	$1c007600,$7407f23c,$44234120,$0000e9c4
	dc.l	$08c4f200,$58225803,$51caffec,$52810c81
	dc.l	$00000002,$6fd80810,$001f6704,$f200001a
	dc.l	$22170c81,$0000001b,$6f0000e4,$0810001e
	dc.l	$66744281,$2810e9c4,$07046624,$52817a01
	dc.l	$28305c00,$66085081,$52852830,$5c004283
	dc.l	$7407e9c4,$08c46608,$58835281,$51cafff4
	dc.l	$20012217,$92806c10,$44812810,$00844000
	dc.l	$00000090,$40000000,$43fb0170,$00000666
	dc.l	$4283f23c,$44803f80,$00007403,$e2806406
	dc.l	$f23148a3,$38000683,$0000000c,$4a8066ec
	dc.l	$f2000423,$60684281,$7a022830,$5c006608
	dc.l	$53855081,$28305c00,$761c7407,$e9c408c4
	dc.l	$66085983,$528151ca,$fff42001,$22179280
	dc.l	$6e104481,$28100284,$bfffffff,$0290bfff
	dc.l	$ffff43fb,$01700000,$05fc4283,$f23c4480
	dc.l	$3f800000,$7403e280,$6406f231,$48a33800
	dc.l	$06830000,$000c4a80,$66ecf200,$0420262e
	dc.l	$ff60e9c3,$26822810,$e582e9c4,$0002d480
	dc.l	$43fafe50,$10312800,$4283efc3,$0682f203
	dc.l	$9000e280,$640a43fb,$01700000,$06446016
	dc.l	$e280640a,$43fb0170,$000006d2,$600843fb
	dc.l	$01700000,$05902001,$6a084480,$00904000
	dc.l	$00004283,$f23c4480,$3f800000,$e2806406
	dc.l	$f23148a3,$38000683,$0000000c,$4a8066ec
	dc.l	$0810001e,$6706f200,$04206004,$f2000423
	dc.l	$f200a800,$08800009,$6706006e,$0108ff66
	dc.l	$588ff21f,$d0404cdf,$003cf23c,$90000000
	dc.l	$0000f23c,$88000000,$00004e75,$3ffd0000
	dc.l	$9a209a84,$fbcff798,$00000000,$3ffd0000
	dc.l	$9a209a84,$fbcff799,$00000000,$3f800000
	dc.l	$00000000,$00000000,$00000000,$40000000
	dc.l	$00000000,$00000000,$00000000,$41200000
	dc.l	$00000000,$00000000,$00000000,$459a2800
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$03030202,$03020203,$02030302,$48e73f20
	dc.l	$f227e007,$f23c9000,$00000020,$2d50ff58
	dc.l	$2e00422e,$ff500c2e,$0004ff4e,$66000030
	dc.l	$30100240,$7fff2228,$00042428,$00085340
	dc.l	$e38ae391,$4a816cf6,$4a406e04,$50eeff50
	dc.l	$02407fff,$30802141,$00042142,$00082d50
	dc.l	$ff902d68,$0004ff94,$2d680008,$ff9802ae
	dc.l	$7fffffff,$ff904a2e,$ff506708,$2c3cffff
	dc.l	$ecbb6038,$302eff90,$3d7c3fff,$ff90f22e
	dc.l	$4800ff90,$04403fff,$f2005022,$f23a4428
	dc.l	$ff1cf293,$000ef23a,$4823ff02,$f2066000
	dc.l	$600af23a,$4823fee6,$f2066000,$f23c8800
	dc.l	$00000000,$42454a87,$6f042807,$60062806
	dc.l	$98875284,$4a846f18,$0c840000,$00116f12
	dc.l	$78114a87,$6f0c00ae,$00002080,$ff646002
	dc.l	$78014a87,$6e06be86,$6d022c07,$20065280
	dc.l	$90844845,$42454242,$4a806c14,$52450c80
	dc.l	$ffffecd4,$6e080680,$00000018,$74184480
	dc.l	$f23a4480,$fe98e9ee,$1682ff60,$e349d245
	dc.l	$e3494aae,$ff586c02,$528145fa,$fec01632
	dc.l	$1800e98b,$f2039000,$e88b4a03,$660a43fb
	dc.l	$01700000,$03706016,$e20b640a,$43fb0170
	dc.l	$000003fe,$600843fb,$01700000,$04904283
	dc.l	$e2886406,$f23148a3,$38000683,$0000000c
	dc.l	$4a8066ec,$f23c8800,$00000000,$f23c9000
	dc.l	$00000010,$f2104800,$f2000018,$4a456608
	dc.l	$f2000420,$6000008e,$4a2eff50,$67000072
	dc.l	$f227e002,$36170243,$7fff0050,$8000d650
	dc.l	$04433fff,$d6690024,$04433fff,$d6690030
	dc.l	$04433fff,$6b000048,$02578000,$87570250
	dc.l	$7fff2f28,$00082f28,$00042f3c,$3fff0000
	dc.l	$f21fd080,$f21f4823,$2f29002c,$2f290028
	dc.l	$2f3c3fff,$00002f29,$00382f29,$00342f3c
	dc.l	$3fff0000,$f21f4823,$f21f4823,$601660fe
	dc.l	$4a42670c,$f2294823,$0024f229,$48230030
	dc.l	$f2000423,$f200a800,$f22e6800,$ff9045ee
	dc.l	$ff900800,$0009670e,$00aa0000,$00010008
	dc.l	$f22e4800,$ff902d6e,$ff60ff54,$02ae0000
	dc.l	$0030ff60,$48e7c0c0,$2f2eff54,$2f2eff58
	dc.l	$41eeff90,$f2106800,$4aaeff58,$6c060090
	dc.l	$80000000,$2f2eff64,$f22e9000,$ff60f23c
	dc.l	$88000000,$0000f22e,$4801ff90,$f200a800
	dc.l	$816eff66,$1d57ff64,$588f2d5f,$ff582d5f
	dc.l	$ff544cdf,$03032d6e,$ff58ff90,$2d6eff54
	dc.l	$ff604845,$4a4566ff,$00000086,$f23a4500
	dc.l	$fcec2004,$53804283,$e2886406,$f2314923
	dc.l	$38000683,$0000000c,$4a8066ec,$4a2eff50
	dc.l	$670af200,$001860ff,$00000028,$f2000018
	dc.l	$f2000838,$f293001a,$53863a3c,$0001f23c
	dc.l	$90000000,$0020f23a,$4523fcc2,$6000fda8
	dc.l	$f23a4523,$fcb8f200,$0838f294,$005cf292
	dc.l	$000cf23a,$4420fca6,$5286604c,$52863a3c
	dc.l	$0001f23c,$90000000,$00206000,$fd7af23a
	dc.l	$4500fc6a,$20044283,$e2886406,$f2314923
	dc.l	$38000683,$0000000c,$4a8066ec,$f2000018
	dc.l	$f2000838,$f28e0012,$f23a4420,$fc605286
	dc.l	$5284f23a,$4523fc56,$f23c9000,$00000010
	dc.l	$f2000820,$41eeff84,$f2106800,$24280004
	dc.l	$26280008,$42a80004,$42a80008,$20104840
	dc.l	$67140480,$00003ffd,$4a806e0a,$4480e28a
	dc.l	$e29351c8,$fffa4a82,$66044a83,$67104281
	dc.l	$06830000,$0080d581,$0283ffff,$ff802004
	dc.l	$568861ff,$000002b0,$4a2eff50,$6728f200
	dc.l	$003af281,$000cf206,$4000f200,$0018602e
	dc.l	$4a876d08,$f23a4400,$fbe46022,$f2064000
	dc.l	$f2000018,$6018f200,$003af28e,$000af23a
	dc.l	$4400fb9a,$6008f206,$4000f200,$0018f229
	dc.l	$48200018,$f22e6800,$ff90242a,$0004262a
	dc.l	$00083012,$670e0440,$3ffd4440,$e28ae293
	dc.l	$51c8fffa,$42810683,$00000080,$d5810283
	dc.l	$ffffff80,$700441ee,$ff5461ff,$00000228
	dc.l	$202eff54,$720ce2a8,$efee010c,$ff84e2a8
	dc.l	$efee0404,$ff844a00,$670800ae,$00002080
	dc.l	$ff644280,$022e000f,$ff844aae,$ff586c02
	dc.l	$70024a86,$6c025280,$efee0002,$ff84f23c
	dc.l	$88000000,$0000f21f,$d0e04cdf,$04fc4e75
	dc.l	$40020000,$a0000000,$00000000,$40050000
	dc.l	$c8000000,$00000000,$400c0000,$9c400000
	dc.l	$00000000,$40190000,$bebc2000,$00000000
	dc.l	$40340000,$8e1bc9bf,$04000000,$40690000
	dc.l	$9dc5ada8,$2b70b59e,$40d30000,$c2781f49
	dc.l	$ffcfa6d5,$41a80000,$93ba47c9,$80e98ce0
	dc.l	$43510000,$aa7eebfb,$9df9de8e,$46a30000
	dc.l	$e319a0ae,$a60e91c7,$4d480000,$c9767586
	dc.l	$81750c17,$5a920000,$9e8b3b5d,$c53d5de5
	dc.l	$75250000,$c4605202,$8a20979b,$40020000
	dc.l	$a0000000,$00000000,$40050000,$c8000000
	dc.l	$00000000,$400c0000,$9c400000,$00000000
	dc.l	$40190000,$bebc2000,$00000000,$40340000
	dc.l	$8e1bc9bf,$04000000,$40690000,$9dc5ada8
	dc.l	$2b70b59e,$40d30000,$c2781f49,$ffcfa6d6
	dc.l	$41a80000,$93ba47c9,$80e98ce0,$43510000
	dc.l	$aa7eebfb,$9df9de8e,$46a30000,$e319a0ae
	dc.l	$a60e91c7,$4d480000,$c9767586,$81750c18
	dc.l	$5a920000,$9e8b3b5d,$c53d5de5,$75250000
	dc.l	$c4605202,$8a20979b,$40020000,$a0000000
	dc.l	$00000000,$40050000,$c8000000,$00000000
	dc.l	$400c0000,$9c400000,$00000000,$40190000
	dc.l	$bebc2000,$00000000,$40340000,$8e1bc9bf
	dc.l	$04000000,$40690000,$9dc5ada8,$2b70b59d
	dc.l	$40d30000,$c2781f49,$ffcfa6d5,$41a80000
	dc.l	$93ba47c9,$80e98cdf,$43510000,$aa7eebfb
	dc.l	$9df9de8d,$46a30000,$e319a0ae,$a60e91c6
	dc.l	$4d480000,$c9767586,$81750c17,$5a920000
	dc.l	$9e8b3b5d,$c53d5de4,$75250000,$c4605202
	dc.l	$8a20979a,$48e7ff00,$7e015380,$28022a03
	dc.l	$e9c21003,$e782e9c3,$6003e783,$8486e385
	dc.l	$e3944846,$d346d685,$4e71d584,$4e71d346
	dc.l	$48464a47,$67124847,$e947de41,$10c74847
	dc.l	$424751c8,$ffc86012,$48473e01,$48475247
	dc.l	$51c8ffba,$4847e94f,$10c74cdf,$00ff4e75
	dc.l	$70016100,$00d63d7c,$0121000a,$6000007e
	dc.l	$70026100,$00c63d7c,$0141000a,$606e7004
	dc.l	$610000b8,$3d7c0101,$000a6060,$70086100
	dc.l	$00aa3d7c,$0161000a,$6052700c,$6100009c
	dc.l	$3d7c0161,$000a6044,$70016100,$008e3d7c
	dc.l	$00a1000a,$60367002,$61000080,$3d7c00c1
	dc.l	$000a6028,$70046100,$00723d7c,$0081000a
	dc.l	$601a7008,$61000064,$3d7c00e1,$000a600c
	dc.l	$700c6100,$00563d7c,$00e1000a,$2d6eff68
	dc.l	$0006f22e,$d0c0ffdc,$f22e9c00,$ff604cee
	dc.l	$0303ff9c,$4e5e2f17,$2f6f0008,$00042f6f
	dc.l	$000c0008,$2f7c0000,$0001000c,$3f6f0006
	dc.l	$000c3f7c,$40080006,$08170005,$670608ef
	dc.l	$0002000d,$60ffffff,$2d82122e,$ff410201
	dc.l	$00380c01,$00186700,$000c0c01,$00206700
	dc.l	$00604e75,$122eff41,$02410007,$323b1206
	dc.l	$4efb1002,$00100016,$001c0020,$00240028
	dc.l	$002c0030,$91aeffa4,$4e7591ae,$ffa84e75
	dc.l	$95c04e75,$97c04e75,$99c04e75,$9bc04e75
	dc.l	$91964e75,$0c2e0030,$000a6612,$082e0005
	dc.l	$0004660a,$4e7a8800,$91c04e7b,$88004e75
	dc.l	$448060a0,$00000000,$00000000,$00000000

;*********************************************************************************************                
; .22 
;neue exception routine fÅr mehr Information
exception:	move.l	2(SP),proc_pc.w ;pc merken
		movem.l D0-D7/A0-A7,proc_regs.w ;die Register merken
		move	USP,A0
		move.l	A0,proc_usp.w	;den USP merken
		move.l	SP,A1
		moveq	#0,D1
		move.w	6(SP),D1	;formatword holen
		and.w	#$0FFF,D1	;format weg=offset
		asr.w	#2,D1		;/4 ergibt vector
exception4:	lea	startup_stk.w,SP ;den Stack initialisieren
		moveq	#15,D0
		lea	proc_stk.w,A0
exception2:	move.w	(A1)+,(A0)+	;16 Worte vom SSP merken
		dbra	D0,exception2
		move.l	#$12345678,proc_lives.w ;Daten fÅr gÅltig erklÑren

bombs:		lea	tb1(PC),A0	;zeiger auf starttext
		bsr	string_out	;ausgeben
		cmp.w	#56,D1		;vector =56?
		blt	bomb_fa4	;nein kleiner->
		lea	tbuv(PC),A0	;zeiger auf text
		bsr	string_out	;text ausgeben
		move.w	D1,D2		;vector nummer nach d2
		ror.l	#8,D2		;an richtige stelle bringen
		moveq	#1,D0		;2 Stellen
		bsr	reg_aus1	;ausgeben
		bra	bomb_fa5
bomb_fa4:	lea	tbev(PC),A0	;zeiger auf exception text
		subq.w	#1,D1		;mit bus error beginnen
bomb_fa1:	subq.w	#1,D1		;
		beq	bomb_fa2	;ok->weg
bomb_fa3:	move.b	(A0)+,D6	;nÑchstes zeichen
		beq	bomb_fa1	;ende zeichenkette->
		bra	bomb_fa3	;nein next
bomb_fa2:	bsr	string_out	;text ausgeben
bomb_fa5:	lea	tb2(PC),A0	;zeiger auf text
		bsr	string_out	;text ausgeben PC=
		move.l	proc_pc.w,D2	;pc wert hohlen
		bsr	reg_aus 	;ausgeben
		bsr	string_out	;sr=
		move.w	proc_stk.w,D2	;sr hohlen
		swap	D2		;an richtige position bringen
		moveq	#3,D0		;nur 4 stellen
		bsr	reg_aus1	;ausgeben
		bsr	string_out	;usp=
		move.l	proc_usp.w,D2	;usp wert hohlen
		bsr	reg_aus 	;und ausgeben
		bsr	string_out	;formatword=
		move.w	proc_stk+6.w,D2 ;formatword hohlen
		swap	D2		;an richtige position bringen
		moveq	#3,D0		;nur 4 stellen
		bsr	reg_aus1	;und ausgeben
		bsr	string_out	;(PC-4)=
		move.l	8.w,a4		;buserrorvektor sichern
		move.l	#bomb_fa6,8.w	;buserrorvektor setzen
		move.l	sp,a5		;stack sichern
		move.l	proc_pc.w,a6	;pc laden
		move.l	-4(a6),d2	;werte vor pc stand
		bsr	reg_aus
		move.l	(a6),d2 	;werte bei pc stand
		bsr	reg_aus
bomb_fa6:	move.l	a4,8.w		;alter buserrorvektor
		move.l	a5,sp		;alter stack
		lea	tb3(PC),A0	;zeiger auf text
		lea	proc_regs.w,A1	;zeiger auf registerwerte
		moveq	#2,D4		;daten,adressregister und stack
bomb_fa8:	bsr	string_out	;text ausgeben
		moveq	#7,D3		;8 register
bomb_fa7:	move.l	(A1)+,D2	;wert hohlen
		bsr	reg_aus 	;und ausgeben
		dbra	D3,bomb_fa7	;
		subq.l	#1,D4		;-1
		bgt	bomb_fa8	;>0 wiederhohlen
		lea	proc_stk.w,A1	;zeiger auf stackwert
		beq	bomb_fa8	;=0->wiederhohlen
		lea	tb4(PC),A0	;zeiger auf text
		bsr	string_out	;text ausgeben
		move	#$2100,SR	;Interrupts erlauben
		move.w	#2,-(SP)	;tastatur
		move.w	#2,-(SP)
		trap	#13		;auf tastendruck warten
		addq.l	#4,SP		;stack korrigieren
exitcrash:	move.l	#$093A,$04A2.w	;BIOS-Stackpointer zurÅcksetzen
		move.l	#$4CFFFF,-(SP)	;
		trap	#1		;Pterm(-1) versuchen
		jmp	kaltstart	;RESET, wenn miûlungen

reg_aus:	moveq	#7,D0
reg_aus1:	rol.l	#4,D2		;next hex zahl
		move.b	D2,D6
		and.b	#$0F,D6 	;nur 4 bits werden gebraucht
		add.b	#'0',D6 	;+ ascii 0
		cmp.b	#'9',D6 	;<=9?
		ble	reg_aus2	;ja,ok->
		add.b	#'A'-'9'-1,D6	;sonst differenz zuaddieren
reg_aus2:	bsr	zei_out 	;ausgeben
		dbra	D0,reg_aus1	;wiederhohlen bis fertig
		moveq	#32,D6
		bra	zei_out 	;ein leerschlag

string_out:	move.b	(A0)+,D6	;zeichen holen
		bne	str_out1	;fertig? nein->
		rts			;zurÅck
str_out1:	bsr	zei_out 	;zeichen out
		bra	string_out	;und von vorn

zei_out:	movem.l D0-D4/A0-A1,-(SP) ;register sichern
		and.w	#$FF,D6 	;nur bytwert
		move.w	D6,-(SP)	;zeichen
		move.w	#2,-(SP)	;bildschirm
		move.w	#3,-(SP)
		trap	#13		;zeichen ausgeben
		addq.l	#6,SP
		movem.l (SP)+,D0-D4/A0-A1 ;register zurÅck
		rts

; .24 .28
; ... und die Texte des Handlers auch gleich noch ein wenig aufgeraeumt ...
; .29
; ausserdem sind auch noch die 68060 exeptions dabei.


tb1:		DC.B 27,'H',10,10,10,10,10,10,27,'p',27,'KException ausgelîst durch: ',0
tb2:		DC.B 10,13,27,'K',10,13,27,'KPC=',0,' SR=',0,' USP=',0,' Formatword=',0,' (PC-4)=',0
tb3:		DC.B 10,13,27,'KD0-D7=',0,10,13,27,'KA0-A7=',0,10,13,27,'KStack=',0
tb4:		DC.B 10,13,27,'K',10,13,27,'K < weiter mit beliebiger Taste >',27,'q',0
tbuv:		DC.B 'Vector nummer $',0
tbev:		DC.B 'Access fault (Bus Error) !',0
		DC.B 'Adress error !',0
		DC.B 'Illegal instruction !',0
		DC.B 'Integer divide by zero !',0
		DC.B 'CHK, CHK2 instruction !',0
		DC.B 'FTRAPcc, TRAPcc, TRAPV instruction !',0
		DC.B 'Privileg violation !',0
		DC.B 'Trace !',0
		DC.B 'Line A Emulator !',0
		DC.B 'Line F Emulator !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Coprocessor protocol violation !',0
		DC.B 'Format error !',0
		DC.B 'Uninitialized interrupt !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Spurious interrupt !',0
		DC.B 'Level 1 interrupt autovektor !',0
		DC.B 'Level 2 interrupt autovektor !',0
		DC.B 'Level 3 interrupt autovektor !',0
		DC.B 'Level 4 interrupt autovektor !',0
		DC.B 'Level 5 interrupt autovektor !',0
		DC.B 'Level 6 interrupt autovektor !',0
		DC.B 'Level 7 interrupt autovektor !',0
		DC.B 'Trap #0 instruction vector !',0
		DC.B 'Trap #1 instruction vector !',0
		DC.B 'Trap #2 instruction vector !',0
		DC.B 'Trap #3 instruction vector !',0
		DC.B 'Trap #4 instruction vector !',0
		DC.B 'Trap #5 instruction vector !',0
		DC.B 'Trap #6 instruction vector !',0
		DC.B 'Trap #7 instruction vector !',0
		DC.B 'Trap #8 instruction vector !',0
		DC.B 'Trap #9 instruction vector !',0
		DC.B 'Trap #10 instruction vector !',0
		DC.B 'Trap #11 instruction vector !',0
		DC.B 'Trap #12 instruction vector !',0
		DC.B 'Trap #13 instruction vector !',0
		DC.B 'Trap #14 instruction vector !',0
		DC.B 'Trap #15 instruction vector !',0
		DC.B 'FPCP Branch or Set on unordered condition !',0
		DC.B 'FPCP inexact result !',0
		DC.B 'FPCP divide by zero !',0
		DC.B 'FPCP underflow !',0
		DC.B 'FPCP operand error !',0
		DC.B 'FPCP overflow !',0
		DC.B 'FPCP signaling NAN !',0
		DC.B 'FPCP unimplemented data type !',0
		DC.B '68030/68851 PMMU configuration error !',0
		DC.B 'Unassigned, reserved for 68851 !',0
		DC.B 'Unassigned, reserved for 68851 !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Addressing mode unimplemented in 68060 !',0
		DC.B 'Integer instruction unimplemented in 68060 !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0

		even

;grafik karte initialisieren
screen_init:	lea	pci_conf1,a3
		cmp.b   #$32,3(a3)
		beq	config
		lea	pci_conf2,a3
		cmp.b	#$32,3(a3)
		beq	config
		lea	pci_conf3,a3
		cmp.b	#$32,3(a3)
		beq	config
		lea	pci_conf4,a3
		cmp.b	#$32,3(a3)
		beq	config

pcim64t:	cmp.w	#$5847,pci_conf1+2
		beq	m64init
		cmp.w	#$5847,pci_conf2+2
		beq	m64init
		cmp.w	#$5847,pci_conf3+2
		beq	m64init
		cmp.w	#$5847,pci_conf4+2
		bne	isainit

m64init:        lea	$7fe70000,a0           ;source emulator.bin mach64 pci
m64init2:	lea	$300000,a1             ;dest (Åbersetzt mit org $300000)
		move.l	a1,a2
		move.w	#430,d0                ;lÑnge(6824)/16
m64copy:	move.l	(a0)+,(a1)+            ;copieren
		move.l	(a0)+,(a1)+
		move.l  (a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbf	d0,m64copy             ;wiedeholen bis fertig
		jmp	(a2)                   ;einsprung
		
;pci et4000 grafikkarte initialisieren
config:	        move.b	#3,4(a3)		;io und mem on
		lea	pci_vga_reg,a2
		cmp.b	#8,2(a3)                ;et6000?
		bne	no_et6000		;nein->
		move.b	#3,$40(a3)              ;et6000 init
		move.b	#$15,$44(a3)		;et6000 init
no_et6000:	move.b	#$27,$03C2(A2)		;misc
		move.b	#1,$03C3(A2)		;videosub
		move.b	#$17,$03D4(A2)	    
		clr.b	$03D5(A2)		;color
		move.b	#$11,$03D4(A2)		;color
		clr.b	$03D5(A2)
		move.b  #$ff,$3c6(a2)           ;pel mask
		clr.b	$03C4(A2)		;ts
		clr.b	$03C5(A2)
		move.b	#3,$03BF(A2) 
		move.b	#$A0,$03D8(A2)

		lea	$03C4(A2),A0
		lea	ts+1,A1
		cmp.b	#8,2(a3)		;et6000?
		bne     iset1                   ;nein->
		lea	ts6+1,a1
iset1:		moveq	#1,D1
		moveq	#8,D0
;ts registersatz transferieren
loop_ts:	move.b	D1,(A0)
		move.b	(A1)+,1(A0)
		addq.w	#1,D1
		cmp.w	D1,D0
		bne.s	loop_ts
		clr.b	(A0)
		move.b	ts,1(A0)		;fa_8.11.94:
		
		lea     $03c6(a2),a0            ;pel mask
		move.b  (a0),d0
		move.b  (a0),d0
		move.b  (a0),d0
		move.b  (a0),d0
		moveq	#0,d0
		cmp.b	#8,2(a3)		;et6000?
		bne	iset2                   ;nein->
		moveq	#-1,d0
iset2:          move.b	d0,(a0)                 ;pel mask
                
		lea	$03D4(A2),A0
		lea	crtc,A1
		moveq	#0,D1
		moveq	#$3e,D0  		
;crtc registersatz transferieren
loop_crtc:	move.b	D1,(A0)
		move.b	(A1)+,1(A0)
		addq.w	#1,D1
		cmp.w	D1,D0
		bne.s	loop_crtc
		lea	$03CE(A2),A0
		lea	gdc,A1
		moveq	#0,D1
		moveq	#9,D0
;gdc registersatz transferieren
loop_gdc:	move.b	D1,(A0)
		move.b	(A1)+,1(A0)
		addq.w	#1,D1
		cmp.w	D1,D0
		bne.s	loop_gdc
		move.b	$03DA(A2),D0
		lea	$03C0(A2),A0
		lea	atc,A1
		moveq	#0,D1
		moveq	#$18,D0
;atc registersatz transferieren
loop_atc:	move.b	D1,(A0)
		move.b	(A1)+,(A0)
		addq.w	#1,D1
		cmp.w	D1,D0
		bne.s	loop_atc
		move.b	#$20,(A0)
		lea	$03C8(A2),A0
		moveq	#0,D1
		move.w	#$0100,D0
		move.b	D1,(A0)
		move.b	#$FF,1(A0)
		move.b	#$FF,1(A0)
		move.b	#$FF,1(A0)
		addq.w	#1,D1
;farbregister auf monochrom
loop_dac:	move.b	D1,(A0)
		clr.b	1(A0)
		clr.b	1(A0)
		clr.b	1(A0)
		addq.w	#1,D1
		cmp.w	D0,D1
		bne.s	loop_dac
		lea	pci_vga_base,a0
		rts

atc:		DC.B $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
		DC.B $01,$00,$0F,$00,$00,$00,$00,$00
crtc:		DC.B $60,$4F,$4F,$84,$56,$86,$c1,$1F,$00,$40,$00,$00,$00,$00,$07,$30
		DC.B $98,$00,$8F,$28,$40,$8F,$C2,$a3,$FF,$00,$00,$00,$00,$00,$00,$00
		DC.B $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		DC.B $00,$80,$28,$00,$00,$00,$13,$09,$00,$00,$00,$00,$00,$00,$00,$00
gdc:		DC.B $00,$00,$00,$00,$00,$00,$01,$0F,$FF
ts:		DC.B $03,$01,$0F,$00,$06,$00,$00,$B4
ts6:		DC.B $03,$05,$0F,$00,$06,$00,$00,$B4
		even

;isa et4000 grafikkarte initialisieren
isainit:	lea	$7fe72000,a0		;source emulator.bin mach64 isa
		cmp.b   #$ff,$fff103c0          ;mach64?
		beq	m64init2                ;ja->
		lea	isa_vga_reg,A2
		move.b	#7,$03C2(A2)		;misc
		move.b	#1,$03C3(A2)		;videosub
		move.b	#$17,$03B4(A2)		;crtc mode control
		clr.b	$03B5(A2)		;mono
		move.b	#$17,$03D4(A2)	    
		clr.b	$03D5(A2)		;color
		move.b	#$11,$03B4(A2)		;vertical start
		clr.b	$03B5(A2)
		move.b	#$11,$03D4(A2)		;color
		clr.b	$03D5(A2)
		move.b	#$FF,$03C6(A2)		;pel mask
		clr.b	$03C4(A2)		;ts
		clr.b	$03C5(A2)
		move.b	#3,$03BF(A2) 
		move.b	#$A0,$03D8(A2)
		lea	$03C4(A2),A0
		lea	isats+1,A1
		moveq	#1,D1
		moveq	#$07,D0
;ts registersatz transferieren
isaloop_ts:	move.b	D1,(A0)
		move.b	(A1)+,1(A0)
		addq.w	#1,D1
		cmp.w	D1,D0
		bne.s	isaloop_ts
		clr.b	(A0)
		move.b	isats,1(A0)		 ;fa_8.11.94:
		
		lea     $03c6(a2),a0             ;pel mask
		move.b  (a0),d0
		move.b  (a0),d0
		move.b  (a0),d0
		move.b  (a0),d0
		move.b  #0,(a0)
		
		lea	$03D4(A2),A0
		lea	isacrtc,A1
		moveq	#0,D1
		moveq	#$38,D0
;crtc registersatz transferieren
isaloop_crtc:	move.b	D1,(A0)
		move.b	(A1)+,1(A0)
		addq.w	#1,D1
		cmp.w	D1,D0
		bne.s	isaloop_crtc
		lea	$03CE(A2),A0
		lea	isagdc,A1
		moveq	#0,D1
		moveq	#10,D0
;gdc registersatz transferieren
isaloop_gdc:	move.b	D1,(A0)
		move.b	(A1)+,1(A0)
		addq.w	#1,D1
		cmp.w	D1,D0
		bne.s	isaloop_gdc
		move.b	$03DA(A2),D0
		lea	$03C0(A2),A0
		lea	isaatc,A1
		moveq	#0,D1
		moveq	#$18,D0
;atc registersatz transferieren
isaloop_atc:	move.b	D1,(A0)
		move.b	(A1)+,(A0)
		addq.w	#1,D1
		cmp.w	D1,D0
		bne.s	isaloop_atc
		move.b	#$20,(A0)
		lea	$03C8(A2),A0
		moveq	#0,D1
		move.w	#$0100,D0
		move.b	D1,(A0)
		move.b	#$FF,1(A0)
		move.b	#$FF,1(A0)
		move.b	#$FF,1(A0)
		addq.w	#1,D1
;farbregister auf monochrom
isaloop_dac:	move.b	D1,(A0)
		clr.b	1(A0)
		clr.b	1(A0)
		clr.b	1(A0)
		addq.w	#1,D1
		cmp.w	D0,D1
		bne.s	isaloop_dac
		lea	isa_vga_base,a0
		rts

isaatc:		DC.B $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
		DC.B $01,$FF,$0F,$00,$00,$00,$00,$00
isacrtc:	DC.B $6A,$4F,$4F,$8E,$59,$87,$BF,$1F,$00,$40,$00,$00,$00,$00,$00,$00
		DC.B $9A,$04,$8F,$28,$00,$8F,$C0,$C3,$FF,$00,$00,$00,$00,$00,$00,$00
		DC.B $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		DC.B $00,$00,$00,$00,$00,$10,$70,$0F
isagdc:		DC.B $00,$00,$00,$00,$00,$00,$01,$0F,$FF,0
isats:		DC.B $03,$09,$0F,$00,$06,$00,$00,$A4
		even

logo:		
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$7C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$0F,$F8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$FF,$F0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1F 
      DC.B      $FF,$F0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$FF,$FF 
      DC.B      $E0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$FF,$FF,$C0 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1F,$FF,$FF,$FF,$80,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$01,$FF,$FF,$FF,$FF,$02,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$3F,$FF,$FF,$FF,$FE,$07,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$07,$FF,$FF,$FF,$FF,$FC,$0F,$80,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$0F,$FF,$FF,$FF,$FF,$F8,$1F,$C0,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$1F,$FF,$FF,$FF,$FF,$F8,$1F,$E0,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$7F,$FF,$FF,$FF,$FF,$F0,$3F,$E0,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$FF,$FF,$FF,$FF,$FF,$E0,$7F,$F0,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01 
      DC.B      $FF,$FF,$FF,$FF,$FF,$C0,$FF,$F8,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$FF 
      DC.B      $FF,$FF,$FF,$FF,$81,$FF,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$FF,$FF 
      DC.B      $FF,$FF,$FF,$03,$FF,$FE,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1F,$FF,$FF,$FF 
      DC.B      $FF,$FE,$07,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3F,$FF,$FF,$FF,$FF 
      DC.B      $FC,$07,$FF,$FF,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$FF,$FF,$FF,$FF,$FC 
      DC.B      $0F,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$01,$FF,$FF,$FF,$FF,$FF,$F8,$1F 
      DC.B      $FF,$FF,$E0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$03,$FF,$FF,$FF,$FF,$FF,$F0,$3F,$FF 
      DC.B      $FF,$F8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$07,$FF,$FF,$FF,$FF,$FF,$E0,$7F,$FF,$FF 
      DC.B      $F8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$0F,$FF,$FF,$FF,$FF,$FF,$C0,$FF,$FF,$FF,$FC 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$3F,$FF,$FF,$FF,$FF,$FF,$81,$FF,$FF,$FF,$FE,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$7F,$FF,$FF,$FF,$FF,$FF,$01,$FF,$FF,$FF,$FF,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$FF,$FF,$7F,$FF,$FF,$FF,$03,$FF,$FF,$FF,$FF,$80,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $01,$FF,$FF,$3F,$FF,$FF,$FE,$07,$FF,$FF,$FF,$FF,$C0,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07 
      DC.B      $FF,$FE,$3F,$FF,$FF,$FC,$0F,$FF,$FF,$FF,$FF,$E0,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$FF 
      DC.B      $FC,$3F,$FF,$FF,$F8,$1F,$FF,$FF,$FF,$FF,$F0,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1F,$FF,$FC 
      DC.B      $3F,$FF,$FF,$F0,$3F,$FF,$FF,$FF,$FF,$F8,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3F,$FF,$F8,$3F 
      DC.B      $FF,$FF,$E0,$7F,$FF,$FF,$FF,$FF,$F8,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$FF,$F8,$3F,$FF 
      DC.B      $FF,$C0,$7F,$FF,$FF,$FF,$FF,$FC,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$FF,$FF,$F0,$1F,$FF,$FF 
      DC.B      $80,$FF,$FF,$FF,$FF,$FF,$FE,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$07,$FF,$FF,$E0,$1F,$FF,$FF,$81 
      DC.B      $FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$0F,$FF,$FF,$E0,$1F,$FF,$FF,$03,$FF 
      DC.B      $FF,$FF,$FF,$FF,$FF,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$1F,$FF,$FF,$C0,$1F,$FF,$FE,$07,$FF,$FF 
      DC.B      $FF,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$7F,$FF,$FF,$C0,$1F,$FF,$FC,$0F,$FF,$FF,$FF 
      DC.B      $FF,$FF,$FF,$E0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$FF,$FF,$FF,$80,$1F,$FF,$F0,$1F,$FF,$FF,$FF,$FF 
      DC.B      $FF,$FF,$F0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$01,$FF,$FF,$FF,$80,$0F,$FF,$E0,$1F,$FF,$FF,$FF,$FF,$FF 
      DC.B      $FF,$F8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$03,$FF,$FF,$FF,$00,$0F,$FF,$C0,$3F,$FF,$FF,$FF,$FF,$FF,$FF 
      DC.B      $F8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $0F,$FF,$FF,$FE,$00,$0F,$FF,$80,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FC 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1F 
      DC.B      $FF,$FF,$FE,$00,$0F,$FF,$80,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3F,$FF 
      DC.B      $FF,$FC,$00,$0F,$FF,$01,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$FF,$FF 
      DC.B      $FC,$00,$0F,$FE,$03,$FF,$FF,$FF,$FD,$FF,$FF,$FF,$FF,$80,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$FF,$FF,$FF,$F8 
      DC.B      $00,$07,$FC,$0F,$FF,$FF,$FF,$F8,$FF,$FF,$FF,$FF,$C0,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$FF,$FF,$FF,$F0,$00 
      DC.B      $07,$F8,$0F,$FF,$FF,$FF,$F0,$3F,$FF,$FF,$FF,$E0,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$FF,$FF,$FF,$F0,$00,$07 
      DC.B      $F0,$1F,$FF,$FF,$FF,$C0,$1F,$FF,$FF,$FF,$F0,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$0F,$FF,$FF,$FF,$E0,$00,$07,$E0 
      DC.B      $3F,$FF,$FF,$FF,$80,$0F,$FF,$FF,$FF,$F8,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$3F,$FF,$FF,$FF,$E0,$00,$07,$C0,$7F 
      DC.B      $FF,$FF,$FF,$00,$03,$FF,$FF,$FF,$FC,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$7F,$FF,$FF,$FF,$C0,$00,$07,$C0,$FF,$FF 
      DC.B      $FF,$FE,$00,$01,$FF,$FF,$FF,$FC,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$80,$00,$03,$81,$FF,$FF,$FF 
      DC.B      $F8,$00,$00,$FF,$FF,$FF,$FE,$00,$00,$00,$00,$00,$00,$00,$00,$18 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$01,$FF,$FF,$FF,$FF,$80,$00,$03,$01,$FF,$FF,$FF,$F0 
      DC.B      $00,$00,$7F,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$68,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$03,$FF,$FF,$FF,$FF,$00,$00,$02,$03,$FF,$FF,$FF,$E0,$00 
      DC.B      $00,$1F,$FF,$FF,$FF,$80,$00,$00,$00,$00,$00,$00,$00,$68,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$0F,$FF,$FF,$FF,$FF,$00,$00,$00,$07,$FF,$FF,$FF,$C0,$00,$00 
      DC.B      $07,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$68,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $1F,$FF,$FF,$FF,$FE,$00,$00,$00,$0F,$FF,$FF,$FF,$00,$00,$00,$03 
      DC.B      $FF,$FF,$FF,$E0,$00,$00,$00,$00,$00,$00,$00,$68,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3F 
      DC.B      $FF,$FF,$FF,$FC,$00,$00,$00,$1F,$FF,$FF,$FE,$00,$00,$00,$00,$FF 
      DC.B      $FF,$FF,$F0,$00,$00,$00,$00,$00,$00,$00,$88,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$FF 
      DC.B      $FF,$FF,$FC,$00,$00,$40,$3F,$FF,$FF,$FC,$00,$00,$00,$00,$7F,$FF 
      DC.B      $FF,$F8,$00,$00,$00,$00,$00,$00,$00,$E8,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$FF,$FF,$FF 
      DC.B      $FF,$F8,$3F,$FF,$80,$7F,$FF,$FF,$F8,$00,$00,$00,$00,$3F,$FF,$FF 
      DC.B      $FC,$00,$00,$00,$00,$00,$00,$00,$88,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$FF,$FF,$FF,$FF 
      DC.B      $F8,$18,$8B,$00,$7F,$FF,$FF,$E0,$00,$00,$00,$00,$0F,$FF,$FF,$FC 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$88,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$FF,$FF,$FF,$FF,$F0 
      DC.B      $10,$04,$00,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$07,$FF,$FF,$FE,$00 
      DC.B      $00,$00,$00,$00,$00,$01,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$FF,$FF,$FF,$FF,$E0,$32 
      DC.B      $2C,$01,$FF,$FF,$FF,$80,$00,$00,$00,$00,$03,$FF,$FF,$FF,$00,$00 
      DC.B      $00,$00,$00,$00,$01,$68,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$3F,$FF,$FF,$FF,$FF,$E0,$10,$03 
      DC.B      $03,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$80,$00,$00 
      DC.B      $00,$00,$00,$01,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$7F,$FF,$FF,$FF,$FF,$C0,$18,$88,$C7 
      DC.B      $FF,$FF,$FC,$00,$00,$00,$00,$00,$00,$7F,$FF,$FF,$C0,$00,$00,$00 
      DC.B      $00,$00,$03,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$C0,$10,$80,$2F,$FF 
      DC.B      $FF,$F8,$00,$00,$00,$00,$00,$00,$3F,$FF,$FF,$E0,$00,$00,$00,$00 
      DC.B      $00,$02,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$01,$FF,$FF,$FF,$FF,$FF,$80,$13,$62,$3F,$FF,$FF 
      DC.B      $F0,$00,$00,$00,$00,$00,$00,$0F,$FF,$FF,$F0,$00,$00,$00,$00,$00 
      DC.B      $02,$68,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$07,$FF,$FF,$FF,$FF,$FF,$00,$16,$10,$07,$FF,$FF,$E0 
      DC.B      $80,$00,$00,$30,$00,$00,$07,$FF,$FF,$F8,$00,$00,$00,$00,$00,$02 
      DC.B      $08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$0F,$FF,$FF,$FF,$FF,$FF,$00,$18,$0C,$89,$FF,$FF,$81,$60 
      DC.B      $00,$00,$48,$00,$00,$03,$FF,$FF,$FC,$00,$00,$00,$00,$00,$0D,$08 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$1F,$FF,$FF,$FF,$FF,$FE,$00,$10,$03,$00,$7F,$FF,$06,$10,$00 
      DC.B      $01,$86,$00,$00,$11,$FF,$FF,$FE,$00,$00,$00,$00,$00,$10,$08,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $3F,$FF,$FF,$FF,$FF,$FE,$00,$00,$00,$A2,$3F,$FE,$09,$1C,$00,$03 
      DC.B      $11,$80,$00,$6C,$7F,$FF,$FE,$00,$00,$00,$00,$00,$64,$68,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF 
      DC.B      $FF,$FF,$FF,$FF,$F8,$00,$00,$01,$E0,$07,$FC,$30,$02,$00,$0C,$00 
      DC.B      $60,$00,$82,$3F,$FF,$FF,$03,$FF,$FF,$FF,$80,$83,$04,$00,$00,$18 
      DC.B      $00,$00,$00,$01,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$03,$FF,$FF 
      DC.B      $FF,$FF,$FF,$F8,$00,$00,$03,$F8,$8B,$E0,$44,$45,$80,$14,$44,$58 
      DC.B      $03,$23,$1F,$FF,$FF,$81,$11,$11,$13,$03,$15,$0A,$00,$00,$2E,$00 
      DC.B      $00,$38,$1F,$45,$C0,$00,$00,$00,$00,$00,$00,$00,$07,$FF,$FF,$FF 
      DC.B      $FF,$FF,$F0,$00,$00,$07,$FC,$00,$C0,$80,$00,$40,$60,$20,$06,$0C 
      DC.B      $00,$C7,$FF,$FF,$C0,$8F,$FF,$8C,$04,$19,$02,$00,$00,$41,$80,$3F 
      DC.B      $F0,$20,$00,$30,$00,$00,$00,$00,$00,$00,$00,$0F,$FF,$FF,$FF,$FF 
      DC.B      $FF,$E0,$00,$00,$07,$FF,$22,$33,$11,$91,$30,$91,$D9,$19,$98,$88 
      DC.B      $A3,$FF,$FF,$F0,$44,$03,$70,$1C,$61,$63,$00,$00,$A2,$7F,$FE,$00 
      DC.B      $D3,$FD,$10,$00,$00,$00,$00,$00,$00,$00,$3F,$FF,$FF,$FF,$FF,$FF 
      DC.B      $E0,$00,$00,$0F,$FF,$80,$0C,$03,$60,$0B,$01,$04,$00,$60,$00,$11 
      DC.B      $FF,$FF,$F8,$22,$0C,$C0,$61,$81,$08,$80,$01,$08,$01,$C0,$01,$04 
      DC.B      $06,$10,$00,$00,$00,$00,$00,$00,$00,$7F,$FF,$FF,$FF,$FF,$FF,$C0 
      DC.B      $00,$00,$1F,$FF,$E8,$8C,$44,$14,$44,$46,$03,$42,$22,$32,$2C,$7F 
      DC.B      $FF,$FF,$F1,$31,$00,$93,$01,$0C,$C0,$02,$96,$8B,$80,$02,$48,$02 
      DC.B      $50,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$C0,$00 
      DC.B      $00,$3F,$FF,$F8,$00,$08,$0C,$00,$08,$00,$80,$00,$4C,$02,$60,$00 
      DC.B      $00,$00,$C6,$03,$0C,$01,$0A,$20,$02,$21,$80,$80,$0C,$10,$06,$10 
      DC.B      $00,$00,$00,$00,$00,$00,$01,$FF,$FF,$FF,$FF,$FF,$FF,$80,$00,$00 
      DC.B      $7F,$FF,$F6,$21,$30,$03,$11,$30,$00,$78,$89,$82,$89,$88,$88,$84 
      DC.B      $44,$5C,$04,$5E,$01,$6A,$30,$06,$40,$62,$60,$11,$20,$FD,$10,$00 
      DC.B      $00,$00,$00,$00,$00,$03,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF 
      DC.B      $FF,$E3,$00,$40,$00,$80,$40,$00,$18,$06,$01,$80,$03,$FF,$FF,$FC 
      DC.B      $20,$18,$01,$E1,$09,$10,$08,$80,$18,$10,$20,$41,$00,$10,$00,$00 
      DC.B      $00,$00,$00,$00,$0F,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$01,$FF,$FF 
      DC.B      $80,$CD,$80,$00,$65,$80,$00,$06,$28,$00,$62,$2F,$FF,$FF,$83,$10 
      DC.B      $33,$11,$1F,$08,$88,$19,$00,$04,$8D,$C4,$82,$7F,$50,$00,$00,$00 
      DC.B      $00,$00,$00,$1F,$FF,$FF,$FF,$FF,$FF,$FE,$00,$00,$01,$FF,$FF,$00 
      DC.B      $22,$00,$00,$12,$00,$00,$01,$30,$00,$30,$11,$FF,$FF,$C1,$10,$C4 
      DC.B      $F0,$01,$08,$44,$22,$00,$03,$02,$01,$04,$81,$10,$00,$00,$00,$00 
      DC.B      $00,$00,$3F,$FF,$FF,$FF,$FF,$FF,$FE,$00,$00,$03,$FF,$FE,$00,$1C 
      DC.B      $00,$00,$0C,$00,$00,$00,$C0,$00,$08,$E0,$7F,$FF,$E0,$C9,$58,$0F 
      DC.B      $44,$68,$23,$E4,$00,$00,$E2,$12,$05,$81,$10,$00,$00,$00,$00,$00 
      DC.B      $00,$7F,$FF,$FF,$FF,$FF,$FF,$FC,$00,$00,$07,$FF,$FC,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$06,$80,$3F,$FF,$F0,$46,$20,$00,$F0 
      DC.B      $08,$20,$08,$00,$00,$30,$04,$09,$FF,$10,$00,$00,$00,$00,$00,$01 
      DC.B      $FF,$FF,$FF,$FF,$FF,$FF,$F8,$00,$00,$0F,$FF,$F0,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$01,$00,$1F,$FF,$F8,$51,$C0,$00,$0F,$08 
      DC.B      $18,$90,$00,$3F,$E8,$C8,$14,$44,$50,$00,$00,$00,$00,$00,$03,$FF 
      DC.B      $FF,$FF,$FF,$FF,$FF,$F8,$00,$00,$1F,$FF,$E0,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$0F,$FF,$FC,$21,$00,$00,$00,$F8,$0F 
      DC.B      $E0,$3F,$FF,$FF,$F0,$3F,$FF,$10,$00,$00,$00,$00,$00,$07,$FF,$FF 
      DC.B      $FF,$FF,$FF,$FF,$F0,$00,$00,$3F,$FF,$C0,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$03,$FF,$FE,$16,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$01,$F0,$00,$00,$00,$00,$00,$0F,$FF,$FF,$FF 
      DC.B      $FF,$FF,$FF,$F0,$00,$00,$7F,$FF,$80,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$01,$FF,$FF,$08,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3F,$FF,$FF,$FF,$FF 
      DC.B      $FF,$FF,$E0,$00,$00,$7F,$FE,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$FF,$FF,$80,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$FF,$FF,$FF,$FF,$FF 
      DC.B      $FF,$C0,$00,$00,$FF,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$3F,$FF,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$E0 
      DC.B      $00,$00,$01,$FF,$F8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$0F,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$01,$FF,$FF,$FF,$FF,$FF,$F8,$00,$00 
      DC.B      $00,$03,$FF,$F0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$07,$FF,$E0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$07,$FF,$FF,$FF,$FF,$FC,$00,$00,$00,$00 
      DC.B      $07,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$01,$FF,$F0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$0F,$FF,$FF,$FF,$FE,$00,$00,$00,$00,$00,$0F 
      DC.B      $FF,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$FF,$F8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$1F,$FF,$FF,$FF,$80,$00,$00,$00,$00,$00,$1F,$FF 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $7F,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$3F,$FF,$FF,$80,$00,$00,$00,$00,$00,$00,$1F,$FE,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1F 
      DC.B      $FE,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$3F,$F8,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$FF 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $01,$FF,$E0,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$F0,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$FF,$80 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03 
      DC.B      $F8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$E0,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$FF,$80,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$3F,$C0,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$C0,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7F,$E0,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3F,$F0,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$F8,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$07,$FC,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$01,$FE,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$FF,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$7F,$80,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$1F,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$0F,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$07,$E0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$01,$F0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$F8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$7C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $1E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$80 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$C0,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$C0,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$60,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$30,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 

hadeslogo:
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01 
      DC.B      $C0,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$03,$C0,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $1E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$E0,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$3F,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$80,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $01,$80,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$01,$80,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$80 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$0C,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$01,$80,$00,$00,$00,$00,$00,$00,$00,$00,$0C 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$80,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$0C,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$01,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$0C,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$C0,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$0C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$01,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$0C,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$01,$40,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$0C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01 
      DC.B      $C0,$00,$00,$00,$00,$00,$00,$00,$00,$0C,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$01,$C0,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $0C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$A0,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$1C,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$01,$60,$00,$00,$00,$00,$00,$00,$00,$00,$14,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$A0,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$1A,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$01,$E0,$00,$00,$00,$00,$00,$00,$00,$00,$3E,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$A0,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$2A,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $01,$70,$00,$00,$00,$00,$00,$00,$00,$00,$36,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$01,$B0,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$6A,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$F0 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$01,$B8,$00,$00,$00,$00,$00,$00,$00,$00,$AA 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$78,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$F6,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$03,$A8,$00,$00,$00,$00,$00,$00,$00,$01,$AA,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$FC,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$03,$FE,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$02,$AC,$00,$00,$00,$00,$00,$00,$00,$02,$AA,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$03,$74,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$07,$77,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02 
      DC.B      $AE,$00,$00,$00,$00,$00,$00,$00,$0A,$AB,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$07,$FE,$00,$00,$00,$00,$00,$00,$00,$1F 
      DC.B      $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$AA,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$1A,$AB,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$07,$77,$00,$00,$00,$00,$00,$00,$00,$37,$77,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$AB,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$6A,$AB,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$0F,$FF,$80,$00,$00,$FC,$00,$00,$00,$FF,$FF,$FF,$FF,$FF 
      DC.B      $C0,$00,$00,$C0,$00,$00,$00,$00,$00,$0A,$AA,$80,$00,$03,$AF,$00 
      DC.B      $00,$07,$AA,$AA,$AA,$AA,$AA,$C0,$00,$07,$80,$00,$00,$00,$00,$00 
      DC.B      $0F,$77,$60,$00,$07,$77,$C0,$00,$3F,$77,$77,$77,$77,$77,$80,$00 
      DC.B      $3F,$00,$00,$00,$00,$00,$00,$0A,$AA,$B8,$00,$0A,$AA,$E0,$00,$EA 
      DC.B      $AA,$AA,$AA,$AA,$AB,$00,$00,$EB,$00,$00,$00,$00,$00,$00,$1F,$FF 
      DC.B      $FF,$00,$1F,$FF,$F0,$03,$FF,$FF,$FF,$FF,$FF,$FE,$00,$03,$FE,$00 
      DC.B      $00,$00,$00,$00,$00,$1A,$AA,$AB,$80,$2A,$AA,$B8,$06,$AA,$AA,$AA 
      DC.B      $AA,$AA,$AE,$00,$06,$AC,$00,$00,$00,$00,$00,$00,$17,$77,$77,$40 
      DC.B      $77,$77,$7C,$0F,$77,$7F,$F7,$77,$77,$7C,$00,$0F,$7C,$00,$00,$00 
      DC.B      $00,$00,$00,$1A,$AA,$AA,$A0,$AA,$FE,$AC,$1A,$AA,$F0,$6A,$BF,$FA 
      DC.B      $A8,$00,$1A,$A8,$00,$00,$00,$00,$00,$00,$1F,$FF,$FF,$F1,$FF,$C7 
      DC.B      $FE,$3F,$FF,$80,$1F,$F8,$3F,$F0,$00,$3F,$F8,$00,$00,$00,$00,$00 
      DC.B      $00,$2A,$AA,$AA,$BB,$AB,$81,$AA,$6A,$AE,$00,$0E,$AC,$2A,$B0,$00 
      DC.B      $EA,$B0,$00,$00,$00,$00,$00,$00,$37,$77,$77,$7F,$77,$01,$F7,$77 
      DC.B      $78,$00,$03,$76,$77,$60,$01,$F7,$70,$00,$00,$00,$00,$00,$00,$2A 
      DC.B      $BA,$AA,$AE,$AE,$00,$AB,$AA,$E0,$00,$01,$AB,$6A,$C0,$03,$AA,$A0 
      DC.B      $00,$00,$00,$00,$00,$00,$3F,$EF,$FF,$FF,$FC,$00,$FF,$FF,$80,$00 
      DC.B      $00,$FF,$FF,$C0,$03,$FF,$E0,$00,$00,$00,$00,$00,$00,$2A,$C0,$1A 
      DC.B      $AA,$B8,$00,$AA,$AB,$00,$00,$00,$EA,$AA,$80,$06,$AA,$C0,$00,$00 
      DC.B      $00,$00,$00,$00,$37,$40,$07,$77,$70,$00,$F7,$76,$00,$00,$00,$77 
      DC.B      $77,$00,$0F,$77,$40,$00,$00,$00,$00,$00,$00,$2A,$C0,$06,$AA,$B0 
      DC.B      $00,$AA,$AC,$00,$00,$00,$6A,$AA,$00,$0A,$AA,$C0,$00,$00,$00,$00 
      DC.B      $00,$00,$3F,$C0,$03,$FF,$E0,$00,$FF,$FC,$00,$00,$00,$3F,$FE,$00 
      DC.B      $1F,$FF,$80,$00,$00,$00,$00,$00,$00,$2A,$80,$02,$AA,$C0,$01,$AA 
      DC.B      $AC,$00,$00,$00,$2A,$AC,$00,$3A,$AA,$80,$00,$00,$00,$00,$00,$00 
      DC.B      $37,$80,$03,$77,$C0,$01,$77,$76,$00,$00,$00,$37,$76,$00,$37,$77 
      DC.B      $60,$00,$00,$00,$00,$00,$00,$2B,$80,$01,$AB,$80,$01,$AA,$AA,$00 
      DC.B      $00,$00,$2A,$AB,$00,$6A,$AA,$B0,$00,$00,$00,$00,$00,$00,$3F,$80 
      DC.B      $01,$FF,$00,$03,$FF,$FF,$00,$00,$00,$3F,$FF,$80,$FF,$FF,$F8,$00 
      DC.B      $00,$00,$00,$00,$00,$2B,$00,$01,$AB,$00,$02,$AA,$AB,$80,$00,$00 
      DC.B      $2A,$AA,$C0,$AA,$AA,$AC,$00,$00,$00,$00,$00,$00,$37,$00,$01,$77 
      DC.B      $00,$03,$77,$77,$80,$00,$00,$37,$77,$41,$F7,$77,$77,$00,$00,$00 
      DC.B      $00,$00,$00,$2A,$00,$01,$AB,$00,$06,$AB,$AA,$C0,$00,$00,$6A,$AA 
      DC.B      $A1,$AA,$AA,$AB,$80,$00,$00,$00,$00,$00,$3F,$00,$01,$FF,$00,$07 
      DC.B      $FF,$FF,$E0,$00,$00,$7F,$FF,$F3,$F7,$FF,$FF,$E0,$00,$00,$00,$00 
      DC.B      $00,$2E,$00,$03,$AB,$80,$0E,$AB,$EA,$B8,$00,$00,$6A,$AA,$AE,$B3 
      DC.B      $AA,$AA,$B0,$00,$00,$00,$00,$00,$36,$00,$03,$77,$80,$0F,$77,$F7 
      DC.B      $76,$00,$00,$F7,$F7,$77,$60,$F7,$77,$7C,$00,$00,$00,$00,$00,$2E 
      DC.B      $00,$02,$AA,$C0,$1A,$AA,$AA,$AB,$80,$01,$AB,$2A,$AA,$E0,$6A,$AA 
      DC.B      $AE,$00,$00,$00,$00,$00,$7E,$00,$07,$FF,$F0,$3F,$FF,$9F,$FF,$F0 
      DC.B      $1F,$FF,$1F,$FF,$C0,$3F,$FF,$FC,$00,$00,$00,$00,$00,$68,$00,$06 
      DC.B      $AA,$B8,$6A,$AA,$CE,$AA,$BF,$FA,$AA,$0A,$AA,$80,$0E,$AA,$AC,$00 
      DC.B      $00,$00,$00,$00,$7C,$00,$0F,$77,$77,$F7,$77,$43,$77,$77,$77,$76 
      DC.B      $07,$77,$80,$07,$77,$78,$00,$00,$00,$00,$00,$68,$00,$1A,$AE,$AA 
      DC.B      $AA,$AA,$C1,$AA,$AA,$AA,$AC,$03,$AB,$00,$01,$AA,$B8,$00,$00,$00 
      DC.B      $00,$00,$78,$00,$3F,$FF,$FF,$FF,$FF,$C0,$7F,$FF,$FF,$FC,$01,$FF 
      DC.B      $00,$01,$FF,$F0,$00,$00,$00,$00,$00,$78,$00,$6A,$A9,$AA,$AB,$AA 
      DC.B      $A0,$3A,$AA,$AA,$A8,$00,$EA,$00,$02,$AA,$A0,$00,$00,$00,$00,$00 
      DC.B      $70,$01,$F7,$70,$F7,$7E,$F7,$60,$0F,$77,$77,$78,$00,$74,$00,$03 
      DC.B      $77,$60,$00,$00,$00,$00,$00,$78,$03,$FB,$E0,$7A,$F8,$7F,$E0,$00 
      DC.B      $EA,$AF,$80,$00,$3C,$00,$02,$AA,$C0,$00,$00,$00,$00,$00,$70,$00 
      DC.B      $0C,$00,$07,$80,$00,$00,$00,$1F,$F8,$00,$00,$08,$00,$07,$FF,$80 
      DC.B      $00,$00,$00,$00,$00,$70,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$0E,$AB,$00,$00,$00,$00,$00,$00,$70,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$74,$00,$00,$00 
      DC.B      $00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$1A,$B8,$00,$00,$00,$00,$00,$00,$60,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$1F,$F0,$00,$00,$00,$00,$00 
      DC.B      $00,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $3A,$E0,$00,$00,$00,$00,$00,$00,$60,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$37,$80,$00,$00,$00,$00,$00,$00,$60 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$6E,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$78,$00,$00,$00,$00,$00,$00,$01,$F8,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$E0,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$F0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$80,$00,$00,$00,$00,$00,$00,$00,$60,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
