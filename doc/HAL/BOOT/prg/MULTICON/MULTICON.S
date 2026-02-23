; d‚marrage TOS

DEBUG = 0

XBIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #14
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

BIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #13
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEMDOS MACRO    ; fn,pile
   move #\1,-(sp)
   trap #1
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEM_AES macro
	lea aespb(pc),a0
	move.l #\1,(a0)
	move.l a0,d1
	move #$c8,d0
	trap #2
	ENDM

GEM_AES2 MACRO
   move.l #\1,d1
   move.l #$c8,d0
   trap #2
   ENDM
   
GEM_VDI MACRO
   move.l #\1,a0
   move.l a0,d1
   move.l (a0),a0
   move i_handle(pc),12(a0)
   moveq #$73,d0
   trap #2
   ENDM

	text
	
	move.l 4(sp),a0
	move.l a0,a3		; ma base page
	move.l a3,basepage
	move.l $18(a0),a1
	add.l $1c(a0),a1
	add.l #$200,a1
	move.l a1,sp
	sub.l a0,a1
	move.l a1,-(sp)
	move.l a0,-(sp)
	clr.w -(sp)
	GEMDOS $4a,12
	
	GEM_AES appl_init
	tst global+2		; nombre d'appli
	bpl exit				; si >0, pas de multitos
	dc.w $a000			; line a
	cmp #16,(a0)		; 16 or more planes?
	bmi exit				; no!	quit
	
	if DEBUG=1
		move.l a3,d7
		bsr affiche
	endif

	pea message
	GEMDOS 9,6

	bsr play_intro
		
	moveq #-1,d0		; allow direct screen 
	bsr ScreenEncoding
	tst.l d0
	bmi _exit				; unknown screen
	and.w #$7FFF,d0	
	move d0,subtype

	bsr set_graphic_params

	pea mess1
	GEMDOS 9,6
	
	bsr find_icons
	seq icon_flag
	bne.s .background			; icons not found	(-1 if error)
	
	pea messok
	GEMDOS 9,6

	pea mess2
	GEMDOS 9,6
	
	tst.b flag
	bne .truecolor
	bsr adapt_16bits_icons
	bra.s .background
.truecolor:
	bsr adapt_tc_icons
	move.l a6,prog_end
	
.background:
	pea mess3
	GEMDOS 9,6
	
	bsr load_background
	seq bg_flag

	sf res_flag
	tst.b bg_flag				; a background loaded?
	bne.s _stay					; yes ! so stay resident
	tst.b flag					; 16 bits?
	beq.s _exit					; in 16 bits, no routine for icons
	tst.b icon_flag			; in 24/32, routine for icons required
	beq.s _exit					; nothing was found no icons no background...
	
_stay:
	st res_flag
	pea installe
	XBIOS 38,6		
		
_exit:
	if DEBUG=1
		move.l #$20002,-(sp)
		trap #13
		addq.l #4,sp	
	endif
	move #3,intin				; mode 3=libere
	GEM_AES form_dial			; libŠre l'‚cran	
	move #255,intin
	GEM_AES graf_mouse		; remet la souris
	
exit:	
	clr intin
	GEM_AES graf_mouse		; forme de fleche
	GEM_AES appl_exit

	tst.b res_flag
	beq.s just_quit
	
	clr.w -(sp)					; stay in memory
	move.l prog_end,a6		; either for TC icon management
	sub.l basepage,a6			; of for background management (or both)
	move.l a6,-(sp)
	move #49,-(sp)
	trap #1						; ciao !
	
just_quit:
error:
	clr -(sp)					; here nothing resident, example:
	trap #1						; only icons in 16 bits (no background)
									; or errors...
	
	; charge un fond d'‚cran selon la r‚solution
	; renvoit 0 si OK
	; renvoit -1 si erreur
	
load_background:
	lea blocksource+4,a0
	move (a0)+,d4
	move d4,d3
	move (a0),d5
	muls d5,d3				; w*h
	add.l d3,d3				; size of data (uncompressed 16 bits)
	
	lea fichier+12,a3
	clr.b (a3)
	move.l #'.TGA',-(a3)
	move d5,d0
	bsr .four_digits
	move d4,d0
	bsr .four_digits
	
	GEM_AES2 shel_find	; full path for xxxxyyyy.tga
	tst.w dum
	beq .error	
	
	move.l prog_end,a6
	clr -(sp)
	pea (a3)
	GEMDOS 61,8				; ouvre path\xxxxyyyy.TGA
	move d0,d7
	bmi .error
		
	clr -(sp)				; from start
	move d7,-(sp)			; handle
	move.l #18,-(sp)		; offset
	GEMDOS 66,10			; fseek

	move.l a6,a5			; file start
	move.l a6,blocksource

	tst.b flag
	beq.s	.16b
	add.l d3,a5				; 24/32 bits, d‚caler le fichier avant conversion
.16b:
	move.l a5,-(sp)		; zone m‚moire ou placer le fichier
	move.l d3,-(sp)		; tout !
	move d7,-(sp)
	GEMDOS 63,12			; lire
	cmp.l d3,d0
	bne .error

	move d7,-(sp)			; fermer
	GEMDOS 62,4	
	
	pea messok
	GEMDOS 9,6
	
	pea mess2
	GEMDOS 9,6

	tst.b flag
	bne.s .autre
	
	bsr.s adapt_bg_16
	bra.s .common
	
.autre:
	bsr.s adapt_bg_tc

.common:
	move.l a6,prog_end
	moveq #0,d0				; ok
	rts
.error:
	moveq #-1,d0			; error
	rts
.four_digits:
	moveq #3,d1
.lb0:
	ext.l d0
	divs.w #10,d0
	swap d0
	add #'0',d0
	move.b d0,-(a3)
	swap d0
	dbf d1,.lb0
	rts

	; adapt TGA 16 bits to the current screen
	; TGA 16 is the same as mode 3 
adapt_bg_16:
	move subtype,d0
	beq.s .loop0
	subq #1,d0
	beq.s .loop1
	subq #1,d0
	beq.s .loop2
.fin:					; mode 3, nothing to do
	add.l d3,a6
	rts				
.loop2:
	move (a6),d0
	ror #8,d0		; mode 2 = mode 3 + rotation
	move d0,(a6)+
	subq.l #2,d3
	bne.s .loop2
	rts
.loop0:
	move (a6),d0
	ror #5,d0
	lsr.b #1,d0
	roxr #2,d0
	move d0,(a6)+
	subq.l #2,d3
	bne.s .loop0
	rts
.loop1:
	move (a6),d0
	ror #5,d0
	lsr.b #1,d0
	roxr #2,d0
	ror #8,d0
	move d0,(a6)+
	subq.l #2,d3
	bne.s .loop1
	rts
	
adapt_bg_tc:
	move subtype,d0
	move #$F8,d4		; mask for 5 bits to byte
	moveq #0,d5			; no offset if 24 bits
	tst.b flag
	bmi.s .24b
	moveq #1,d5			; offset for 32 bits
	cmp #2,d0
	bpl.s .24b
	addq.l #1,a6		; offset at start for xRVB/xBVR
.24b:
	tst d0
	beq.s .rvb
	cmp #3,d0
	beq.s .rvb
.bvr:
	move (a5)+,d0		; 16 bits
	move d0,d1
	ror #5,d1
	and.b d4,d1
	move.b d1,(a6)+	; blue
	move d0,d1
	rol #6,d1
	and.b d4,d1
	move.b d1,(a6)+	; green
	lsl.b #1,d0
	and.b d4,d0
	move.b d0,(a6)+	; red
	add.l d5,a6		; offset if 32 bits
	subq.l #2,d3
	bne.s .bvr
.exit:
	move.l a6,d0
	and.b #$FE,d0		; even
	move.l d0,a6
	rts
.rvb:
	move (a5)+,d0
	move d0,d1
	lsl.b #1,d1
	and.b d4,d1
	move.b d1,(a6)+	; red
	move d0,d1
	rol #6,d1
	and.b d4,d1
	move.b d1,(a6)+	; green
	ror #5,d0
	and.b d4,d0
	move.b d0,(a6)+	; blue
	add.l d5,a6		; offset
	subq.l #2,d3
	bne.s .rvb
	bra.s .exit	

	; remplit certaines zones avec les coordonn‚es graphiques courantes
set_graphic_params:
	GEM_AES2 wind_get2
	dc.w $a000			; linea
	move -2(a0),bytes_per_line
	lea window0+4,a1
	lea blocksource+4,a2
	move -12(a0),d0	; width
	move d0,(a2)+
	move d0,d1
	swap d1
	move -4(a0),d2		; height
	move d2,d1
	move d2,(a2)+
	sub.l #$10001,d1
	move.l d1,(a1)		; max-x, max-y
	add.w #15,d0
	lsr.w #4,d0			; width in 16 pix
	move d0,(a2)+
	clr (a2)+
	move (a0),(a2)+	; planes
	clr.l (a2)+
	clr (a2)+
	clr.l (a2)			; adresse de l'image dest=0 (‚cran)
	rts
		
	; ici, modifie sur place les icones 16 bits Falcon
	; selon le mode d‚tect‚ par ScreenEncoding
	
adapt_16bits_icons:	
	sub.l a4,d1						; nombre d'octets
	asr.l #1,d1						; nombre de pixels
	move.l a4,a0		
	move subtype,d0
	beq .exit						; if 0 = Falcon encoding, nothing to do!
	cmp #1,d0
	beq.s .loop1
	cmp #2,d0
	beq.s .loop2
	cmp #3,d0
	beq.s .loop3
	bne .exit						; impossible...
.loop1:
	move (a0),d0					; mode 1: swap bytes, 16 bits intel
	ror #8,d0
	move d0,(a0)+
	subq.l #1,d1
	bne.s .loop1
	bra.s .exit
.loop2:
	move (a0),d0					; mode 2 15 bits motorola
	ror.l #5,d0
	lsr #1,d0
	rol.l #5,d0
	move d0,(a0)+
	subq.l #1,d1
	bne.s .loop2
	bra.s .exit
.loop3:
	move (a0),d0					; mode 3 15 bits intel
	ror.l #5,d0
	lsr #1,d0
	rol.l #5,d0
	ror #8,d0
	move d0,(a0)+
	subq.l #1,d1
	bne.s .loop3
.exit:
	rts


	; cherche SSSSTTTTAAAA puis EEEENNNNDDDD en m‚moire pour rep‚rer
	; les adresses des icones

	; renvoit 0 si OK
	; -1 si erreur
		
find_icons:
	move planes,d0
	move.l #2048,d6	; one icon in 16 bits
	sf flag
	cmp #16,d0			; nombre de plans
	beq.s .go_on
	move.l #3072,d6	; in 24 bits
	st flag
	cmp #24,d0
	beq.s .go_on
	neg.b flag
	move.l #4096,d6	; in 32 bits
	cmp #32,d0
	beq.s .go_on
.exit:
	moveq #-1,d0		; erreur !
	rts
.go_on:
	move #256,intin
	GEM_AES graf_mouse	; vire la souris!	
	lea intin(pc),a0
	moveq #4,d0
	move.l d0,(a0)		; handle 0=bureau + mode 4 = espace travail
	GEM_AES wind_get	; taille ecran
	lea intin(pc),a0
	lea intout+2(pc),a1
	moveq #0,d0
	move d0,(a0)+		; mode 0=reserve
	move.l d0,(a0)+
	move.l d0,(a0)+	; x1 y1 l1 h1 inutiles
	move.l (a1)+,(a0)+
	move.l (a1),(a0)	; x2 y2 l2 h2
	GEM_AES form_dial	; reserve ecran
	move.l #$1000000,a0
	moveq #0,d0
	move.l #'SSSS',d1
.debut:
	swap d0
	move (a0)+,d0
	cmp.l a3,a0
	bpl .exit
	cmp.l d0,d1
	bne.s .debut
	cmp.l #'TTTT',(a0)
	bne.s .debut
	cmp.l #'AAAA',4(a0)
	bne.s .debut
	move.l 10(a0),a4			; d‚but des donn‚es
	move.l 14(a0),start_mask	; d‚but des masques
	moveq #0,d0
	move.l #'EEEE',d1
.fin:
	swap d0
	move (a0)+,d0
	cmp.l a3,a0
	bpl .exit
	cmp.l d0,d1
	bne.s .fin
	cmp.l #'NNNN',(a0)
	bne.s .fin
	cmp.l #'DDDD',4(a0)
	bne.s .fin
	move.l 22(a0),d0
	move.l 18(a0),d1				; selected present?
	bne.s .ok
	move.l 10(a0),d1
	move.l 14(a0),d0
.ok:
	add.l #128,d0					; dernier masque
	move.l d0,end_mask
	add.l d6,d1					; plus la derniere icone
	moveq #0,d0
	rts							; ok, found!

play_intro:
	lea fichier+12(pc),a4
	clr.b (a4)
	move.l #'.SND',-(a4)
	move.l #'ICON',-(a4)
	move.l #'MULT',-(a4)
	GEM_AES2 shel_find
	tst.w dum
	beq .out
	clr -(sp)
	pea (a4)
	GEMDOS 61,8				; ouvre MULTICON.SND (12,5 Khz, 8 bits mono)
	move d0,d4
	bmi .out					; n'existe pas!
	move #2,-(sp)			; a partir de la fin
	move d4,-(sp)
	clr.l -(sp)
	GEMDOS 66,10
	move.l d0,d3			; taille fichier
	bmi .out
	and.b #$FE,d3			; even size
	clr -(sp)				; a partir du debut
	move d4,-(sp)
	clr.l -(sp)
	GEMDOS 66,10
	pea .get_top(pc)
	XBIOS 38,6
	move.l dum,a4			; top ST RAM
	move.l a4,a2
	sub.l d3,a4				; d‚but pour le fichier son
	pea (a4)					; zone m‚moire ou placer le fichier
	move.l d3,-(sp)
	move d4,-(sp)
	GEMDOS 63,12			; lire
	move d4,-(sp)			; fermer
	GEMDOS 62,4
	clr.l -(sp)
	GEMDOS 32,6				; supervisor
	lea $ff8900,a0			; DMAsound
	move.l a4,-(sp)
	move.b 1(sp),3(a0)
	move.b 2(sp),5(a0)
	move.b 3(sp),7(a0)	; start address
	move.l a2,(sp)
	move.b 1(sp),15(a0)
	move.b 2(sp),17(a0)
	move.b 3(sp),19(a0)	; end address
	move.b #$81,33(a0)	; mono, 12,5 KHz
	move.b #$01,1(a0)		; start sound !!
	move.l d0,(sp)
	GEMDOS 32,6				; user
.out:
	rts
.get_top:
	move.l $436.w,dum
	rts
	
prog_end: dc.l masques

	dc.l $23031966
; ces donn‚es sont r‚cup‚r‚es des fonctions:
; 23 (interior), 24 (style), 25 (color) et 129 (clip)
; afin de valider l'‚criture d'un FOND d'‚cran

fond_data:	dc.w -1,-1,-1	; interior(2) , style (1-6) , color(0)
	dc.w 0,0,0,0				; clip rectangle


mon_vdi:
	cmp.l #$73,d0
	bne.s .fin
	move.l d1,a0
	move.l (a0),a0		; control
	cmp #6,12(a0)		; handle 1 (AES)
	bpl.s .fin
	move (a0),d0
	tst.b flag
	beq.s .no_icon		; 16 bits, icons are correct 
	tst.b icon_flag
	beq.s .no_icon		; 24/32 bits but no icons found
	cmp #109,d0
	beq.s .ok
	cmp #121,d0
	beq.s .ok2
.no_icon:
	tst.b bg_flag
	beq.s .fin2			; no background loaded
	cmp #114,d0
	beq .rectangle
	cmp #129,d0			; vs_clip?
	beq.s .vs_clip
	sub #23,d0			; vsf_interior/vsf_style/vsf_color
	bmi.s .fin2
	cmp #3,d0
	bpl.s .fin2
	lea fond_data(pc),a1
	move.l d1,a0
	move.l 4(a0),a0	;intin
	move (a0),0(a1,d0.w*2)	; conserve le paramŠtre de la fonction	
.fin2:
	moveq.l #$73,d0
.fin:
	move.l old_vdi(pc),-(sp)
	rts
.ok:
	move.l 14(a0),a0	; MFDB source
	cmp.l #$200020,4(a0)	; 32x32 ??
	bne.s .fin2
	move.l start_data(pc),d0
	cmp.l (a0),d0
	bgt.s .fin2
	move.l end_data(pc),d0
	cmp.l (a0),d0
	bmi.s .fin2
	bsr maskicon		; replace unused pixels with background color
	move.l d1,a0
	move.l 4(a0),a0	; intin
	move #3,(a0)		; mode REPLACE
	bra.s .fin2		
.ok2:
	move.l 14(a0),a0	; MFDB source
	cmp.l #$200020,4(a0)	; 32x32 ??
	bne.s .fin2
	move.l start_mask(pc),d0
	cmp.l (a0),d0
	bgt.s .fin2
	move.l end_mask(pc),d0
	cmp.l (a0),d0
	bmi.s .fin2
	rte					; else skip call
.vs_clip:
	move.l d1,a0
	move.l 4(a0),a1			; intin
	cmp #1,(a1)					; clip ON ?
	beq.s .clip_on
	lea fond_data+6(pc),a0
	move.l window0,(a0)+		; x0,y0 fenetre 0 (avant $e230)
	move.l window0+4,(a0)	; taille fenetre
	bra.s .fin2
.clip_on:
	move.l 8(a0),a1			; ptsin
	lea fond_data+6(pc),a0
	move.l (a1)+,(a0)+		; sauve le rectangle de clipping
	move.l (a1),(a0)
	bra .fin2
.rectangle:
	move.l d1,a1
	move.l 8(a1),a1		; ptsin
	tst.l (a1)+				; coordonn‚es 0,0 ??
	beq.s .sr1
	move.l window0,d0
	cmp.l -4(a1),d0		; x0,y0 de la fenetre 0?
	bne .fin2
.sr1:
	move.l window0+4,d0
	cmp.l (a1),d0			; x1,y1 de la fenetre 0?
	beq.s .sr3				; ok !
	addq.l #1,d0
	and.b #$F0,d0
	subq.l #1,d0			; same test but with Y1 rounded to 16
	cmp.l (a1),d0			; for example height of 600 is rounded to 592
	bne .fin2
.sr3:
	lea fond_data(pc),a1
	cmp #2,(a1)+			; interior = pattern?
	bne .fin2
	move (a1)+,d0			; style
	tst (a1)+				; color = 0?
	bne .fin2
	cmp #1,d0				; style >=1?
	bmi .fin2
	cmp #7,d0				; style <=6?
	bpl .fin2
	move.l d1,a0			; tout est OK, on remplace vr_recfl par vro_cpyfm
	move.l (a0)+,a1			; control
	move.l #blocksource,14(a1)
	move.l #blockdest,18(a1)
	move #1,6(a1)
	move #109,(a1)+
	move #4,(a1)
	move.l (a0)+,a1		; intin
	move #3,(a1)			; mode REPLACE
	move.l (a0),a1			; ptsin
	lea 8(a1),a0
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+	; xyx'y' identiques pour les deux blocks
	bra .fin2

maskicon:
	tst.b flag
	bmi maskicon24
	movem.l d1-d4/a1-a2,-(sp)
	move.l d1,a1
	move.l 8(a1),a1	; ptsin
	move 8(a1),d0		; dest x
	muls #4,d0			; in bytes
	move 10(a1),d3		; dest y
	moveq #0,d4
	move bytes_per_line(pc),d4
	muls d4,d3			; in bytes
	add.l d0,d3			; screen offset
	move.l $44e.w,a1	; physbase
	add.l d3,a1			; upper left pixel on screen
	sub #128,d4			; one line-32 pixels
	move.l (a0),a0		; source data
	move.l a0,d0
	sub.l start_data(pc),d0	; offset
	lsr.l #5,d0					; same offset in masks
	lea masques(pc),a2
	add.l d0,a2					; mask address !
	moveq #31,d0				; 32 longs
.lb0:
	move.l (a2)+,d1
	moveq #31,d2				; pour 32 bits
.lb1:
	tst.l d1
	bmi.s .skip
	move.l (a1),(a0)			; one background pixel
.skip:
	addq.l #4,a0
	addq.l #4,a1
	asl.l #1,d1
	dbf d2,.lb1
	add.l d4,a1					; next line on screen
	dbf d0,.lb0
	movem.l (sp)+,d1-d4/a1-a2
	rts

maskicon24:
	movem.l d1-d3/a1-a2,-(sp)
	move.l d1,a1
	move.l 8(a1),a1	; ptsin
	move 8(a1),d0		; dest x
	muls #3,d0			; in bytes
	move 10(a1),d1		; dest y
	moveq #0,d3 
	move bytes_per_line(pc),d3
	muls d3,d1			; in bytes
	sub #96,d3			; one line - 32 pixels
	add.l d0,d1			; screen offset
	move.l $44e.w,a1	; physbase
	add.l d1,a1			; upper left pixel
	move.l (a0),a0		; source data
	move.l a0,d0
	sub.l start_data(pc),d0	; offset
	divu.l #24,d0				; same offset in masks
	lea masques(pc),a2
	add.l d0,a2					; mask address !
	moveq #31,d0				; 32 longs
.lb0:
	move.l (a2)+,d1
	moveq #31,d2				; pour 32 bits
.lb1:
	tst.l d1
	bmi.s .skip
	move.b (a1)+,(a0)+
	move.b (a1)+,(a0)+
	move.b (a1)+,(a0)+
	bra.s .skip2
.skip:
	addq.l #3,a0
	addq.l #3,a1
.skip2:
	asl.l #1,d1
	dbf d2,.lb1
	add.l d3,a1
	dbf d0,.lb0
	movem.l (sp)+,d1-d3/a1-a2
	rts


installe:
	move.l $88.w,old_vdi
	move.l #mon_vdi,$88.w
	rts

	; mode 24 et 32 bits
	; recharge le fichier DESKCICN.RSC et remplit … nouveau
	; la zone de donn‚es icones … partir de la palette standard
	; selon le mode d‚tect‚ par ScreenEncoding
		
adapt_tc_icons:	
	move.l a4,start_data
	move.l d1,end_data
	bsr adapte_palette 	; selon le mode d‚tect‚
	clr -(sp)
	pea nom
	GEMDOS 61,8				; ouvre C:\DESKCICN.RSC
	move d0,d7

	pea fichier				; zone m‚moire ou placer le fichier
	move.l #200*1024,-(sp)	; 200 Ko semblent suffisants
	move d7,-(sp)
	GEMDOS 63,12			; lire

	move d7,-(sp)			; fermer
	GEMDOS 62,4

;	lea zone,a0				; les masques
	lea fichier,a2			; le RSC
	move 20(a2),d7			; nombre d'objets
	subq #1,d7				; nombre d'icones (moins le BOX)
;	move d7,d6
;	muls #128,d6			; fois le nombre de masques
;	lea 0(a0,d6.l),a1		; pointe sur les donn‚es
;	move.l a1,data_ptr
	add.w 34(a2),a2		; vers l'extension
	lea ([4,a2],d7.w*4,fichier+4),a2	; d‚but des structures
	subq #1,d7				; pour la boucle
	lea masques,a6

.icone:
	lea 306(a2),a2			; saute l'icone monochrome
.lb2:
	move (a2),d6
	cmp #4,d6				; 4 plans pour l'icone?
	bne.s .lb0				; non...
	bsr copie_icone
.lb0:
	addq #1,d6				; plus le plan masque
	muls #128,d6			; chaque plan fait 128 octets
	cmp.l #1,10(a2)		; flag pour selected?
	bne.s .lb1				; pas 1, une icone
	add.l d6,d6				; double la mise, avec l'icone selected
.lb1:
	move 18(a2),d0			; flag pour autre r‚solution
	lea 22(a2,d6.l),a2	; saute l'icone
	tst d0
	bne.s .lb2				; flag=1 autre r‚solution
	cmp.l end_data,a4
	bpl.s .exit				; zone pleine
	dbf d7,.icone			; autre icone!
.exit:
	rts	

copie_icone:
	lea 22(a2),a3			; donn‚es de l'icone
	bsr.s convertcolors
	cmp.l #1,10(a2)		; flag pour selected?
	bne.s .lb1				; non, pas de sonconde icone
	bsr.s convertcolors
.lb1:
	rts

convertcolors:
	lea table32b(pc),a5			; conversions en 32 bits RVBx
	moveq #31,d4			; pour les 32 lignes de l'icone
	move.l a3,a1
	lea 512(a3),a3			; to  the mask
	moveq #-1,d5			; d5.l<0 24 bits
	tst.b flag
	bmi.s .lb0
	moveq #0,d5				; d5.l>0 32 bits
.lb0:
	swap d4					; l'autre mot de d4 est utilis‚ ici
	move.l (a1),d0			; d0-d3 contienent les 4 bits de 32 points
	move.l 128(a1),d1
	move.l 256(a1),d2
	move.l 384(a1),d3
	move #31,d5			; pour les 32 points par ligne
.lb1:
	clr d4
	roxl.l d3
	roxl.b d4
	roxl.l d2
	roxl.b d4
	roxl.l d1
	roxl.b d4
	roxl.l d0
	roxl.b d4
	tst.l d5
	bpl.s .bit32
	lea 1(a5,d4.w*4),a0
	move.b (a0)+,(a4)+
	move.b (a0)+,(a4)+
	move.b (a0),(a4)+	
	bra.s .lb2
.bit32:
	move.l 0(a5,d4.w*4),(a4)+
.lb2:
	dbf d5,.lb1				; autre point sur la mˆme ligne
	swap d4
	addq.l #4,a1			; ligne suivante
	move.l (a3)+,(a6)+	; copie un bout du masque
	dbf d4,.lb0
	rts
				; table en RVBx
table32b:  dc.l $FFFFFF00,$FF000000,$00FF0000,$FFFF0000,$0000FF00,$FF00FF00
				dc.l $00FFFF00,$BFBFBF00
				dc.l $80808000,$FF808000,$80FF8000,$FFFF8000,$8080FF00,$FF80FF00
				dc.l $80FFFF00,$00000000

adapte_palette:
	lea table32b(pc),a0	; original palette RVBx
	moveq #15,d0			; 16 colors
	move subtype,d1
	beq.s .loop0				; mode RVB24 ou xRVB32
	subq #1,d1
	beq.s .loop1				; mode BVR24 ou xBVR32
	subq #1,d1
	beq.s .loop2				; mode BVRx32
.loop3:							; mode RVBx32
	rts							; valeurs par d‚faut!
	
.loop0:
	move.l (a0),d1				; RVBx to xRVB
	lsr.l #8,d1
	move.l d1,(a0)+
	dbf d0,.loop0
	rts	

.loop1:
	move.l (a0),d1				; RVBx to xBVR
	ror #8,d1
	swap d1
	ror #8,d1
	move.l d1,(a0)+
	dbf d0,.loop1
	rts	

.loop2:
	move.l (a0),d1				; RVBx to BVRx
	lsr.l #8,d1
	ror #8,d1
	swap d1
	ror #8,d1
	move.l d1,(a0)+
	dbf d0,.loop2
	rts	
	
		
	if DEBUG=1
	
affiche:
	movem.l d0-d2/d7/a0-a2,-(sp)
	moveq #7,d0
	lea .digits(pc),a0
	lea .zone(pc),a1
.encore:	
	move.b d7,d1
	and #$000F,d1
	move.b 0(a0,d1.w),-(a1)
	lsr.l #4,d7
	dbf d0,.encore
	pea -2(a1)
	GEMDOS 9,6
	movem.l (sp)+,d0-d2/d7/a0-a2
	rts
	
.digits: dc.b "0123456789ABCDEF"
	dc.b 13,10,"----++++"
.zone: dc.b 0
	even
	
	endif



;	LONG ScreenEncoding(pointeur global, int flag);
;	Renvoit un LONG:
; HighWord = bits/pixel, low word = encoding
; UNKNOWN if bit 31 set, then high word = bits/pixel, low word undefined
; MONO: 00010000
; 4 colors: 0002 + 0000 (mode Atari plans entrelac‚s)
;					  + 0001 (mode PC plans s‚par‚s)
;					  + 0002 (mode ancien 2 bits par pixel, 4 pixels par byte)
; 16 couleurs: 0004 + 0000 (mode Atari plans entrelac‚s)
;						  + 0001 (mode PC plans s‚par‚s)
;						  + 0002 (mode ancien 4 bits/pixel, 2 pixels/octet)
; 256 couleurs: 0008 + 0000 (mode Atari, plans entrelac‚s)
;							+ 0001 (mode PC, plans s‚par‚s)
;							+ 0002 (un octet par pixel)
;							+ 0003 (idem pour Matrix)
; High Color	0010  + 0000 (mode Atari rrrrrvvv vvvbbbbb)
;							+ 0001 (mode PC vvvbbbbb rrrrrvvv)
;							+ 0002 (mode PC xrrrrrvv vvvbbbbb)
;							+ 0003 (mode PC vvvbbbbb xrrrrrvv)
; here if bit15 set in low word = VDI error but direct access ok
; TC 24			0018  + 0000 (RVB, 3 octets)
;							+ 0001 (BVR, 3 octets)
; TC 32			0020  + 0000 (xRVB, 4 octets)
;							+ 0001 (xBVR, 4 octets)
;							+ 0002 (BVRx, 4 octets)
;							+ 0003 (RVBx, 4 octets)

ScreenEncoding:
	movem.l a2-a6/d2-d7,-(sp)
	lea once(pc),a0
	tst.l d0
	sne (a0)+					; if flag<>0 then direct access allowed
	sne (a0)
	lea intout(pc),a3
	lea i_handle(pc),a5
	lea ow_int(pc),a6
	GEM_AES2 graf_handle
	XBIOS 4,2				
	addq #2,d0
	move d0,(a6)
	move (a3),(a5)		; graf handle	to i_handle
	GEM_VDI open_work
	lea ow_cont(pc),a6
	move 12(a6),(a5)	; VDI handle
	beq.s .error_open

	GEM_VDI vq_extnd
	move 8(a3),d7		; nombre de bits/pixel
	lea dest(pc),a0
	move d7,12(a0)		; pour le bloc
	lea bits(pc),a0
	lea table(pc),a1
	move d7,-2(a1)
.cherche:
	cmp (a0)+,d7
	beq.s .ok
	addq.l #4,a1	
	bra.s .cherche
.ok:
	move.l (a1),a0
	jsr (a0)	
	move.l d0,d7
	GEM_VDI close_work
	move.l d7,d0
.out:
	movem.l (sp)+,a2-a6/d2-d7
	rts
.error_open:			; can't open workstation !
	moveq.l #0,d0
	bset #31,d0
	bra.s .out

bits: dc.w 1,2,4,8,16,24,32
fatal: dc.w 0
table: dc.l mono,coul4,coul16,coul256,highcol,truecol24,truecol32,gloups

mono:
	lea palmono(pc),a6
	bsr dessin
	move.l #$00010000,d0
	move.l (a0),d1
	cmp.l #$11111111,d1
	beq.s .ok
	bset #31,d0		; unknown
.ok:
	rts
		
coul4:
	lea pal4(pc),a6
	bsr dessin
	movem.l (a0),d1-d2
	move.l #$00020000,d0		; interlaced planes, 2 bits/pixel
	cmp.l #$66665555,d1
	bne.s .autre
	cmp.l d2,d1
	beq.s .ok
.autre:
	addq.l #1,d0				; non interlaced
	cmp.l #$66666666,d1
	bne.s .gloups
	cmp.l #$55555555,d2
	beq.s .ok
.gloups:
	bset #31,d0					; unknown
.ok:
	rts

coul16:
	lea pal16(pc),a6
	bsr dessin
	movem.l (a0),d1-d4
	move.l #$00040000,d0		; interlaced, 4 bits/pixel
	cmp.l #$DDDD4444,d1
	bne.s .autre
	cmp.l #$CCCC3333,d2
	bne.s .autre
	cmp.l d4,d2
	bne.s .autre
	cmp.l d1,d3
	beq.s .ok
.autre:
	addq.l #1,d0				; non interlaced
	cmp.l #$DDDDDDDD,d1
	bne.s .dernier
	cmp.l #$44444444,d2
	bne.s .dernier
	cmp.l #$CCCCCCCC,d3
	bne.s .dernier
	cmp.l #$33333333,d4
	beq.s .ok
.dernier:
	addq.l #1,d0				; packed 2 pixels = 1 byte
	cmp.l #$57895789,d1
	bne.s .gloups
	cmp.l d4,d1
	bne.s .gloups
	cmp.l d4,d2
	bne.s .gloups
	cmp.l d4,d3
	beq.s .ok
.gloups:
	bset #31,d0		; unknown
.ok:
	rts	

coul256:
	lea pal256(pc),a6
	bsr dessin
	move.l a0,a1
	moveq #7,d1
	move.l a1,a2
	move.l #$00080002,d0		; 1byte = 1pixel
.lb0:
	cmp.l #$10111213,(a2)+
	bne.s .autre
	dbf d1,.lb0
	bra.s .ok
.autre:
	move.l a0,a1
	addq.l #1,d0				; 1byte=1pixel matrix
	moveq #7,d1
	move.l a1,a2
.lb1:
	cmp.l #$0F101112,(a2)+
	bne.s .lb2
	dbf d1,.lb1
	bra.s .ok
.lb2:
	moveq #1,d1
	subq.l #3,d0				; interlaced
.verif:
	cmp.l #$55553333,(a1)+
	bne.s .gloups
	tst.l (a1)+
	bne.s .gloups
	cmp.l #$ffff0000,(a1)+
	bne.s .gloups
	tst.l (a1)+
	bne.s .gloups
	dbf d1,.verif
	bra.s .ok
.gloups:
	bset #31,d0		; unknown
.ok:
	rts	

highcol:
	lea palplus(pc),a6
	bsr dessin
	movem.l (a0),d1-d2	; 4 premiers pixels
	move.l a0,a1
	move.l #$00100000,d0	; rrrrrvvv vvvbbbbb
	bset #21,d2
	bset #21,d1
	cmp.l #$FFFFF800,d1
	bne.s .autre
	cmp.l #$07E0001F,d2
	beq.s .ok
.autre:
	movem.l (a1),d1-d2
	addq.l #1,d0			; vvvbbbbb rrrrrvvv
	bset #29,d1
	bset #29,d2
	cmp.l #$FFFF00F8,d1
	bne.s .zotr
	cmp.l #$E0071F00,d2
	beq.s .ok
.zotr:
	addq.l #1,d0			; xrrrrrvv vvvbbbbb
	movem.l (a1),d1-d2
	and.l #$7FFF7FFF,d1
	and.l #$7FFF7FFF,d2
	cmp.l #$7FFF7C00,d1
	bne.s .dernier
	cmp.l #$03E0001F,d2
	beq.s .ok	
.dernier:
	addq.l #1,d0			; vvvbbbbb xrrrrrvv
	movem.l (a1),d1-d2
	and.l #$FF7FFF7F,d1
	and.l #$FF7FFF7F,d2
	cmp.l #$FF7F007C,d1
	bne.s .gloups
	cmp.l #$E0031F00,d2
	beq.s .ok
.gloups:
	bset #31,d0				; unknown
.ok:
	rts

truecol24:
	lea palplus(pc),a6
	bsr dessin
.retour:
	movem.l (a0),d1-d3	; 4 premiers pixels
	move.l #$00180000,d0	; RVB
	cmp.l #-1,d1
	bne.s .autre
	cmp.l #255,d2
	bne.s .autre
	cmp.l #255,d3
	beq.s .ok
.autre:
	addq.l #1,d0			; BVR
	cmp.l #$FFFFFF00,d1
	bne.s .gloups
	cmp.l #$00FF00FF,d2
	bne.s .gloups
	cmp.l #$00FF0000,d3
	beq.s .ok
.gloups:
	tst.b once
	beq.s .fini
	bsr direct
	bra.s .retour
.fini:
	bset #31,d0			; unknown
	rts	
.ok:
	lea once(pc),a0
	tst.b (a0)+			; first pass?
	bne.s .ok2			; yes !
	tst.b (a0)
	beq.s .ok2			; yes too
	bset #15,d0			; else set bit for direct access required
.ok2:
	rts

truecol32:	
	lea palplus(pc),a6
	bsr dessin
.retour:	
	movem.l (a0),d1-d4
	move.l #$00FFFFFF,d5
	move.l #$00200000,d0	; xRVB
	and.l d5,d1
	and.l d5,d2
	and.l d5,d3
	and.l d5,d4
	cmp.l d5,d1
	bne.s .autre
	cmp.l #$FF0000,d2
	bne.s .autre_sens
	cmp.l #$FF00,d3
	bne.s .autre_sens
	cmp.l #255,d4
	beq .ok
.autre_sens:
	cmp.l #$ff,d2
	bne.s .autre
	cmp.l #$ff00,d3
	bne.s .autre
	cmp.l #$ff0000,d4
	bne.s .autre
	bra.s .ok
	addq.l #1,d0		; xBVR
.autre:
	lea bloc(pc),a0
	movem.l (a0),d1-d4
	lsl.l #8,d5
	addq.l #2,d0		; BVRx
	and.l d5,d1
	and.l d5,d2
	and.l d5,d3
	and.l d5,d4
	cmp.l d5,d1
	bne.s .gloups
	cmp.l #$FF00,d2
	bne.s .autre_sens2
	cmp.l #$FF0000,d3
	bne.s .autre_sens2
	cmp.l #$FF000000,d4
	beq.s .ok
.autre_sens2:
	addq.l #1,d0			; RVBx
	cmp.l #$FF000000,d2
	bne.s .gloups
	cmp.l #$ff0000,d3
	bne.s .gloups
	cmp.l #$ff00,d4
	beq.s .ok
.gloups:
	tst.b once
	beq.s .fini
	bsr direct
	bra .retour
.fini:
	bset #31,d0			; unknown
	rts	
.ok:
	lea once(pc),a0
	tst.b (a0)+			; first pass?
	bne.s .ok2			; yes !
	tst.b (a0)
	beq.s .ok2			; yes too
	bset #15,d0			; else set bit for direct access required
.ok2:
	rts
	
gloups:
	moveq #0,d0
	move d7,d0			; unknow number of bits/pixel
	bset #15,d0			; unknown
	swap d0			   ; in high word
	rts	

; a6=palette

dessin:
	GEM_VDI hide_mouse
	GEM_AES2 wind_create
	GEM_AES2 form_dial2
	GEM_AES2 wind_open
	lea vc_int(pc),a5
	move (a6)+,(a5)
	move (a6)+,d4		; nombre
	bra.s .fin_coul
.coul:
	move (a6)+,2(a5)
	move (a6)+,4(a5)
	move (a6)+,6(a5)
	GEM_VDI vs_color
	addq #1,(a5)
.fin_coul:
	dbf d4,.coul	
	moveq #3,d6
	lea vm_int(pc),a5
.points:
	move (a6)+,(a5)		; couleur!
	GEM_VDI vsm_color
	GEM_VDI v_pmarker
	lea vp_int(pc),a0
	moveq #7,d0
.trans:
	addq #1,(a0)
	addq.l #4,a0
	dbf d0,.trans
	dbf d6,.points	
	GEM_VDI vro_cpyfm		; remplit le bloc!!!	
	GEM_AES2 wind_close
	GEM_AES2 wind_delete
	move #3,fd_int
	GEM_AES2 form_dial2
	GEM_VDI show_mouse
	lea bloc(pc),a0		; le bloc!!!
	rts

direct:
	XBIOS 3,2				; physbase
	move.l d0,a1
	lea bloc(pc),a2
	move.l a2,a0
	move table-2(pc),d0	; 24 octets ou 32 a lire
	subq #1,d0
.copy:
	move.b (a1)+,(a2)+
	dbf d0,.copy
	sf once
	rts

open_work: dc.l ow_cont,ow_int,dum,work_out,ptsout
ow_cont: dc.w 100,0,0,11,0,0,0,0,0,0,0,0
ow_int: dc.w 2,1,1,1,1,1,1,0,1,0,2

close_work: dc.l cw_cont,dum,dum,dum,dum
cw_cont: dc.w 101,0,0,0,0,0,0,0,0,0,0,0

graf_handle: dc.l gh_cont,global,dum,intout,dum,dum
gh_cont: dc.w 77,0,5,0,0	

wind_get2: dc.l wg_cont,global,wg_int,window0-2,dum,dum
wg_cont: dc.w 104,2,5,0,0
wg_int: dc.w 0,4

vq_extnd: dc.l ve_cont,ve_int,dum,intout,ptsout
ve_cont: dc.w 102,0,0,1,0,0,0,0,0,0,0,0
ve_int: dc.w 1

vsm_color: dc.l vm_cont,vm_int,dum,dum,dum
vm_cont: dc.w 20,0,0,1,0,0,0,0,0,0,0,0
vm_int: dc.w 0

v_pmarker: dc.l vp_cont,dum,vp_int,dum,dum
vp_cont: dc.w 7,8,0,0,0,0,0,0,0,0,0,0
;vp_cont: dc.w 7,1,0,0,0,0,0,0,0,0,0,0
vp_int: dc.w 0,0,4,0,8,0,12,0,0,1,4,1,8,1,12,1

hide_mouse: dc.l vh_cont,dum,dum,dum,dum
vh_cont: dc.w 123,0,0,0,0,0,0,0,0,0,0,0

show_mouse: dc.l sm_cont,sm_int,dum,dum,dum
sm_cont: dc.w 122,0,0,1,0,0,0,0,0,0,0,0
sm_int: dc.w 1

wind_create: dc.l wc_cont,global,wc_int,whand,dum,dum
wc_cont: dc.w 100,5,1,0,0
whand:
wc_int: dc.w 0,0,0,16,2

wind_open: dc.l wo_cont,global,wc_int,dum,dum,dum
wo_cont: dc.w 101,5,1,0,0

wind_close: dc.l wcl_cont,global,wc_int,dum,dum,dum
wcl_cont: dc.w 102,1,1,0,0

wind_delete: dc.l wd_cont,global,wc_int,dum,dum,dum
wd_cont: dc.w 103,1,1,0,0

shel_find: dc.l sf_cont,global,dum,dum,sf_adr,dum
sf_cont: dc.w 124,0,1,1,0
sf_adr: dc.l fichier

form_dial2: dc.l fd_cont,global,fd_int,dum,dum,dum
fd_cont: dc.w 51,9,1,0,0
fd_int: dc.w 0,0,0,16,2,0,0,16,2

vs_color: dc.l vc_cont,vc_int,dum,dum,dum
vc_cont: dc.w 14,0,0,4,0,0,0,0,0,0,0,0
vc_int: dc.w 0,0,0,0

vro_cpyfm: dc.l cp_cont,cp_int,cp_ptsin,dum,dum
cp_cont: dc.w 109,4,0,1,0,0,0
	dc.l source,dest
cp_int: dc.w 3
cp_ptsin: dc.w 0,0,15,1,0,0,15,1
source: dc.l 0,0,0,0,0
dest: dc.l bloc
		dc.w 16,2,1,0,0,0,0,0

palplus: dc.w 16,4
	dc.w 1000,1000,1000,1000,0,0,0,1000,0,0,0,1000
	dc.w 16,17,18,19
	
pal256: dc.w 0,0
	dc.w 16,17,18,19
	
pal16: dc.w 0,0
	dc.w 7,8,9,10

pal4: dc.w 0,0
	dc.w 0,1,2,3

palmono: dc.w 0,0
	dc.w 0,0,0,1	
	
once: dc.w 0

dum: dc.l 0,0,0,0
work_out:
ptsout: dcb.w 128,0
i_handle: dc.w 0
bloc: dcb.l 32,0		; au pire pour un bloc 16x2 en 32 bits

	
	data

aespb: dc.l 0,global,intin,intout,addrin,addrout

appl_init: dc.w 10,0,1,0,0
appl_exit: dc.w 19,0,1,0,0
form_dial: dc.w 51,9,1,0,0
wind_get: dc.w 104,2,5,0,0
graf_mouse: dc.w 78,1,1,1,0


message: dc.b 13,10,10,10,"MultiTOS Icons & Background",0
mess1: dc.b 13,10,"Localizing icons  ...",0
mess2: dc.b 13,10,"Correcting colors ...",0
mess3: dc.b 13,10,"Loading background...",0
messok: dc.b " Ok! ",0
messarg dc.b " Not found ",0
nom: dc.b "C:\DESKCICN.RSC",0
	even
	
	bss

flag: ds.b 1		; 1 = 32 bits, -1 = 24 bits, 0 = 16 bits
icon_flag: ds.b 1		; 0 no icons found, FF found
bg_flag: ds.b 1		; 0 no background loaded, FF yes
res_flag: ds.b 1		; FF to stay resident
	even

	ds.w 0
window0: ds.w 4			; ex: 0,19,799,599
bytes_per_line: ds.w 1
	; ne pas s‚parer
blocksource: ds.l 1		;  image adr
	ds.w 4					; w h w/16 0
planes:	ds.w 1
	ds.w 3
blockdest:  ds.l 1
	ds.w 8
	; jusqu'ici
subtype: ds.w 1
old_vdi:	ds.l 1
start_data: ds.l 1
end_data: ds.l 1
start_mask: ds.l 1
end_mask: ds.l 0
basepage: ds.l 1	
global: ds.w 15
intin: ds.w 15
intout: ds.w 128
addrin: ds.l 1
addrout: ds.l 1
masques: ds.b 128*200		; pour 200 icones
fichier: ds.b 200*1024		; pour le fichier RSC (24/32 bits)
image: ds.b 1024*768*4		; image 1024*768 en true color

	end
	