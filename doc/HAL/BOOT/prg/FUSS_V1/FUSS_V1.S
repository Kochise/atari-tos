
;	F030 universal screensaver 
;	version 1
;	T.AL 93


	output .ttp
	text


	move.l 4(sp),a3		base page pointer
	move.l $c(a3),d0	p_tlen
	add.l $14(a3),d0	+p_dlen
	add.l $1c(a3),d0	+p_blen
	add.l #256,d0
	move.l d0,d3		sauve taille prog

	pea prompt
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	clr.l -(sp)		super
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,-(sp)		sauve oldstack


;-----------------------------------------------
;teste la presence d'une option sur la ligne de commande
 
	move.b $80(a3),d0
	beq.s nocmdline
	
;recupere le path sur la ligne de commande et le termine par un nul

	lea $81(a3),a3
	clr.b (a3,d0.w)		nul … la fin du path
	move.l a3,FileName

;teste si FUSS est deja installe

	move.l $502.w,a0
	lea sign-dump(a0),a1	a1.l adresse de la signature
	cmp.l #'FUSS',(a1)
	bne.s install

;deja installe, on donne le path … la version deja installee et on quitte	

	lea defaultfile-dump(a0),a1
filencpy	move.b (a3)+,(a1)+
	bne.s filencpy
	
;affiche la situation

	pea newfname
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	
	move.l FileName,-(sp)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	
	bra pterm
	
	
;-----------------------------------------------
;pas de ligne de commande

nocmdline	lea defaultfile,a0
	move.l a0,FileName
	
;teste si FUSS est deja installe

	move.l $502.w,a0
	lea sign-dump(a0),a1	a1.l adresse de la signature
	cmp.l #'FUSS',(a1)
	bne.s install

;si oui on restaure l'ancien vecteur et on quitte

	move.l olddump-dump(a0),$502.w	restaure ancien vecteur dump
	
;affiche la situation

	pea wipe
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	
	bra pterm


;-----------------------------------------------
;on installe FUSS
				
install	pea waiting
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp 

	move.l FileName,-(sp)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	pea cr
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	move.l $502.w,olddump

	lea dump,a0		dump vector
	move.l a0,$502.w

	move.w #$20,-(sp)	user
	trap #1
	addq.l #6,sp

	move.w #1,-(sp)
	trap #1
	addq.l #2,sp

	clr.w -(sp)		keep process
	move.l d3,-(sp)
	move.w #$31,-(sp)
	trap #1


;-----------------------------------------------
pterm	pea cr
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	move.w #1,-(sp)
	trap #1
	addq.l #2,sp

	move.w #$20,-(sp)	user
	trap #1
	addq.l #6,sp
	
	clr.w -(sp)
	trap #1


;-----------------------------------------------
dump	bsr screensave
	rts
	
;-----------------------------------------------
screensave	movem.l d0-a6,-(sp)

;recupere l'adresse, le mode et la taille de l'ecran

	move.w #2,-(sp)		Physbase
	trap #14
	addq.l #2,sp
	move.l d0,a3		a3.l screenbase

	move.w #-1,-(sp)
	move.w #88,-(sp)	VsetMode(-1)
	trap #14
	addq.l #4,sp
	move.w d0,d3		d3.w screenmode

	move.w d0,-(sp)		mode courant
	move.w #91,-(sp)	Vgetsize
	trap #14
	addq.l #4,sp
	move.l d0,d4		d4.l screensize

;sauve la DTA du programme interrompu

	move.w #$2f,-(sp)
	trap #1
	addq.l #2,sp
	
	move.l d0,savDTA
	
;sauve le lecteur et le path courant

	move.w #$19,-(sp)
	trap #1
	addq.l #2,sp
	
	move.b d0,savPath
	move.b #':',savPath+1
	
	clr.w -(sp)
	pea savPath+2
	move.w #$47,-(sp)
	trap #1
	addq.l #8,sp
	
;installe DTA pour la sauvegarde

	pea DTA
	move.w #$1a,-(sp)
	trap #1
	addq.l #6,sp
	
;ouvre le fichier F30 et sauve le handle

	clr.w -(sp)
	move.l FileName,-(sp)
	move.w #$3c,-(sp)
	trap #1
	addq.l #8,sp

	move.w d0,d5		d5.w handle

;determine la structure du fichier, truecolor ou bitmap
; screenmode.bit2 on -> truecolor mode, off -> bitmap mode

	btst #2,d3
	bne.s savescrmode

;mode bitmap, determine l'adresse et la taille de la palette
; screenmode.bit7 on -> ST comptatible mode (palette $8240.w)
;                 off -> Falcon mode (palette $9800.w)

	btst #7,d3	
	beq.s F30pal
	
	lea $ffff8240.w,a0	adresse palette
	move.w #32,d0		taille
	bra.s savepalette	
	
F30pal	lea $ffff9800.w,a0
	move.w #256*4,d0

;copie screenmode et la palette dans un buffer

savepalette	lea savbuf,a1
	moveq.l #0,d1
	move.w d0,d1		bytecount pour la sauvegarde
	addq.w #2,d1
	
	lsr.w #2,d0
	subq.w #1,d0
	
	move.w d3,(a1)+		sauve screenmode

palcpy	move.l (a0)+,(a1)+	sauve la palette
	dbf d0,palcpy
	bra.s savebuf
	
;sauve le screenmode en truecolor

savescrmode	move.w d3,savbuf
	moveq.l #2,d1
	
;sauve le buffer sur disque

savebuf	pea savbuf
	move.l d1,-(sp)
	move.w d5,-(sp)
	move.w #$40,-(sp)
	trap #1
	add.l #12,sp

;sauve l'ecran sur disque

saverawdata	pea (a3)
	move.l d4,-(sp)
	move.w d5,-(sp)
	move.w #$40,-(sp)
	trap #1
	add.l #12,sp
	
;ferme le fichier

	move.w d5,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp

;restaure DTA et path

	move.l savDTA,-(sp)
	move.w #$1a,-(sp)
	trap #1
	addq.l #6,sp
	
	pea savPath
	move.w #$3b,-(sp)
	trap #1
	addq.l #6,sp

	pea prompt
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	pea work
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	 	
	movem.l (sp)+,d0-a6
	rts

;-----------------------------------------------
	even
	data

sign	dc.b 'FUSS',0

prompt	dc.b $1b,'E'
	dc.b 'FUSS v1.0:',$a,$d,$a,$d
	dc.b 'Falcon030 Universal Screen Saver',$a,$d
	dc.b 'by T.AL 93',$a,$d,$a,$d
	dc.b 0

waiting	dc.b 'Installed',$a,$d

newfname	dc.b 'Save image as: ',0

wipe	dc.b 'Removed from memory',0

defaultfile	dc.b '\SAVER.F30',0	nom par defaut
	ds.b 200	un peu de place pour un autre fichier
	
cr	dc.b $a,$d,0

work	dc.b 'FUSS is working for you ?!',0

;-----------------------------------------------
	even
	bss

	ds.b 256
	
DTA	ds.b 44

FileName	ds.l 1
	
olddump	ds.l 1

savDTA	ds.l 1
savPath	ds.b 256

savbuf	ds.b 2048


;-----------------------------------------------
	end

