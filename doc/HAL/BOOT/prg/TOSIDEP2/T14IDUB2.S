; TOS 1.04 IDE Boot ROM addition
; There is some 1KB space at ROM end...

* Driver first stage (bootsector) must load normal IDE driver 
* when jumped into at pos 0 or 32.
* must load twisted IDE driver when jumped
* into at pos 34 .
* ROM TOS needs to do byte-swap of bootsector
* when twisted is used
* Short timeouts by drive detect ensure fast boot
 

*Dual boot - first try regular IDE, then if no load twisted one...

*IDE port Adress area: $f00000-$f0003d

datar equ $fff00000
param equ $fff00005
seccn equ $fff00009
stars equ $fff0000d
zylow equ $fff00011
zyhig equ $fff00015
headn equ $fff00019
comst equ $fff0001d

stat2 equ $fff00039
akadr equ $fff0003d



*Twisted !!!!
twdatar equ $f00000
twparam equ $f00004
twseccn equ $f00008
twstars equ $f0000C
twzylow equ $f00010
twzyhig equ $f00014
twheadn equ $f00018
twcomst equ $f0001C

twstat2 equ $f00038
twakadr equ $f0003C




flock equ $43e
gpip equ $fffffa01
drivbits equ $4c2
diskbuf equ $4c6

frcw equ $466+2  *counter of frames (?), but lower word only
h200l equ $4ba  *200Hz counter long
hz200 equ $4bc  *word only






  org $FEFD00

* This is for TOS 1.04

* + needs change (link) at ROM relative pos $462:
* JMP $FEFD00


* Execute 2 overwritten calls:
  jsr $FC0530
  jsr $FC054C


*Check is IDE port present:
ideppres	movea.l	8.w,a0
	movea.l	a7,a1
	move.l	#berrh,8.w
	tst.b	stat2
*here continues if IDE port present:
	movea.l	a1,a7
	move.l	a0,8.w

*Load bootsector with some time-out...


 
* Detect is regular drive present, ready :

  move.b #$00,headn  *master
  clr.b stat2  *IRQ mode set...
 

  *Timeout about half sec
  move.l #100,d3
  add.l h200l.w,d3

tim1  move.b comst,d0
  and.b #$C9,d0
  cmp.b #$40,d0
  beq.s idere1

  cmp.l h200l.w,d3
  bne.s tim1



* Try with twisted if regular failed
regfail 

  move.b #$00,twheadn  *master
  clr.b twstat2  *IRQ mode set...

 *Timeout about half sec
  move.l #100,d3
  add.l h200l.w,d3

twtim1  move.b twcomst,d0
  and.b #$C9,d0
  cmp.b #$40,d0
  beq  twidere1

  cmp.l h200l.w,d3
  bne.s twtim1


ideexit *timeout or no IDE port or error or not exec.
  tst.b gpip.w
  jmp $FC046A  *back to regular TOS
*8 bytes after link here !

idere1  
   lea  comst,a3
   bsr  loadboo

   bne  regfail
   moveq #32,d3   *jumpbase for normal

tochecks   * tst.b gpip.w

*Checksum test:

  move.l diskbuf.w,a0
  move.l a0,a1
  clr.l d0
  move.w #255,d1
chstl add.w (a1)+,d0
  dbf d1,chstl
  
  tst.b gpip.w
*  sub.l a4,a4  *maybe expects 0 here...

  cmp.w #$1234,d0
  bne ideexit
  add.l  d3,a0  *makes branch in loader for normal or twisted 2-ond stage load
  jsr (a0)
  bra ideexit


twidere1  
  lea  twcomst,a3
  bsr  loadboo

  bne ideexit

 * Need to do byte-swap  !!
twbsw 
  move.l diskbuf.w,a0
  move.w #255,d1
tbswl move.w (a0),d2
  rol.w #8,d2  *the swap
  move.w d2,(a0)+
  dbf d1,tbswl

  moveq #34,d3   *jump 34 bytes over begin if twisted !!
  bra  tochecks



berrh	movea.l	a1,a7
	move.l	a0,8.w
	bra	ideexit
*It is bus error sit.- no IDE port in machine

loadboo   
  move.b  #1,-16(a3)  *Start sector,  CHS mode
  clr.b -12(a3)   *zylow
  clr.b  -8(a3)       *zyhig
  move.b #1,-20(a3)        *seccn
  
  lea datar,a1
  move.l diskbuf.w,a0

  move.b #$20,(a3)  *read command  

wrdy  move.w #400,d3  *about 2 sec time-out
  add.w hz200.w,d3

wrdyr1  
   cmp.w hz200.w,d3
   beq.s  timo

   btst #3,(a3)  *data request active ?
   beq.s wrdyr1

* Read sector
  moveq #63,d2
 
readl move.w (a1),(a0)+  
   move.w (a1),(a0)+  
   move.w (a1),(a0)+
   move.w (a1),(a0)+ *8 bytes in one loop part
   dbf d2,readl
 
   nop
   nop

  move.b (a3),d0  *error test
  btst #0,d0
  rts

timo  moveq #3,d0  *just reset Z flag
   rts


  dc.b "P. Putnik"
  even


