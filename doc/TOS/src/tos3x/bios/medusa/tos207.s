;Korrekturen zum TOS 2.06
;Lade Orginal TOS 2.06 auf Adresse $100000-$140000

;Sprachkorrektur
lang_dif:       equ 0              ;   0 = german
                                   ; $2C = swiss german
                                   ;-$5A = englisch
stram_start:    equ $7f000000      ;orginal st ram startadresse
proc_lives:     equ $380           ;ab hier werden die
proc_regs:      equ $384           ;bei einer exception 
proc_pc:        equ $3c4           ;abgelegt
proc_usp:       equ $3c8
proc_stk:       equ $3cc
startup_stk:    equ $3de8
longframe:      equ $59e           ;stackformat 0=68000 <>0=68010 oder hîher
ste_hardware:   equ $a03           ;0=ste 1 =st           
movec:          equ $4e7b          ;d0->control reg
movecd:         equ $4e7a          ;control reg -> d0
cinva:          equ $f4d8          ;invalidet all cache lines
cpusha:         equ $f4f8          ;push und invalidet all cache lines
pflusha:        equ $f518          ;ATC invalid
cpushala0:      equ $f4e8          ;push und invalidet d+i cache line by a0

;neuer ramtest
                org  $e000de
                load $1000de
                beq nomemchk
                moveq #0,d6
                move.b #$a,$ffff8001.w          ;config auf 4 MB
                lea stram_start+8,a0            ;beginn bank 1
                moveq #$20,d3
                swap d3                         ;d3=$200000
                moveq #0,d0
                move.w #$ff,d1                  ;$100 umlÑufe
L000B:          move.w d0,(a0)+                 ;bank 1
                move.w d0,-2(a0,d3.l)           ;bank 2
                add.w #$fa54,d0
                dbf d1,L000B                    ;next
                blt L000B
                lea $ffff820d.w,a0              ;low byt screen bei STe
                moveq #$5a,d1                   ;test byt
                move.b d1,(a0)                  ;byt einschreiben
                nop
                moveq  #$20,d7                  ;d7 fÅr normal ST vorbesetzen
                lsl.l #4,d7                     ;d7 = $200
                cmp.b (a0),d1                   ;noch da?
                bne L000C                       ;nein->kein STe
                clr.b (a0)
                nop
                tst.b (a0)                      ;noch 0?
                bne L000C                       ;nein->kein STe
                moveq #4,d7                     ;STe anderer d7 wert
                swap d7                         ;=$40000
L000C:          move.l #stram_start+$200000,d1  ;beginn test Bank 2
                move.l #stram_start/$10000+4,d5  ;ende "ST Ram" default (7f040000(7f000000+2*128k default))/10000
                moveq #1,d4                     ;2 umlÑufe
L000E:          lsr.w #2,d6
                move.l d7,a0
                addq.l #8,a0                    ;$208
                lea L000F(pc),a4                ;rÅcksprungadresse
                bra $e00b9c                     ;testen
L000F:          beq L0013                       ;ok -> 128 KB
                move.l d7,a0
                add.l d7,a0
                addq.l #8,a0                    ;$408
                lea L0010(pc),a4                ;rÅcksprungadresse
                addq.w #6,d5                    ;+512-128kb/10000
                bra $e00b9c                     ;testen
L0010:          beq L0012                       ;ok -> 512 KB
                lea 8.w,a0                      ;$8
                lea L0011(pc),a4                ;rÅcksprungadresse
                subq.w #8,d5                    ;-512kb/10000
                bra $e00b9c                     ;testen
L0011:          bne L0013                       ;-> nichts in dieser Bank
                add.w  #$20,d5                  ;+2mb/10000
                addq.w #4,d6
L0012:          addq.w #4,d6
L0013:          sub.l d3,d1
                dbf d4,L000E                    ;next
                swap d5                         ;*$10000
                move.b d6,$ffff8001.w
                lea $6000.w,a7                  ;stack init
                move.l #L0017,8.w               ;neuer buserrorvektor
                move.w #$fb55,d3                ;bitmuster
                moveq #2,d7                     ;startadresse und schrittweite
                swap d7                         ;=$20000
                move.l d7,a0                    ;startadresse setzen
L0014:          move.l a0,a1
                move.w d0,d2                    ;0->d2
                moveq #$2a,d1                   ;schleifenindex
L0015:          move.w d2,-(a1)                 ;bitmuster einschreiben
                add.w d3,d2                     ;bitmuster verÑndern
                dbf d1,L0015                    ;next
                move.l a0,a1
                moveq #$2a,d1                   ;schleifenindex
L0016:          cmp.w -(a1),d0                  ;bitmuster vergleichen
                bne L0017                       ;ungleich -> weg + fertig
                add.w d3,d0
                dbf d1,L0016
                add.l d7,a0                     ;nÑchster 128 KB
                cmp.l #$A20000,a0               ;nicht mehr als 10 MB +128 KB(wird wieder subtrahiert)
                blt L0014
L0017:          sub.l d7,a0                     ;endadresse speicher fast ram 1
                move.l a0,d4
                lea $400,a0                     ;beginn lîschen
                moveq #0,d0
L0018:          move.l d0,(a0)+                 ;speicher lîschen
                move.l d0,(a0)+
                move.l d0,(a0)+
                move.l d0,(a0)+
                move.l d0,(a0)+
                move.l d0,(a0)+
                move.l d0,(a0)+
                move.l d0,(a0)+
                cmp.l d4,a0                     ;schon fertig
                blt L0018                       ;nein -> wiederhohlen
                move.b d6,$424.w                ;config sichern
                move.l d5,$49e.w                ;st ram top
                move.l d4,$42e.w                ;memtop sichern
                clr.l $5a4.w                    ;kein TT Ram
                move.l #$752019f3,$420.w        ;memvalidwerte
                move.l #$237698aa,$43a.w
                move.l #$5555aaaa,$51a.w
                move.l #$1357bd13,$5a8.w

nomemchk:       lea $3de8.w,a7                  ;stack startup
                lea $a02.w,a2
                clr.b (a2)+
                move.l a7,a6                    ;stack sichern
                move.l #kein_sod,8.w            ;buserrorvektor setzen
                clr.w $ffff8900.w               ;dma sound?
                st -1(a2)                       ;ja setzen
                lea L001A(pc),a0                ;wertetabelle
                move.w (a0)+,$ffff8924.w
                bra L001D
L001A:          dc.w $0ffe,$09d1,$0aa9,$0a29,$090d,$088d,$0803,$0000
L001B:          move.w d0,$ffff8922.w
L001C:          tst.w $ffff8922.w
                bne L001C
L001D:          move.w (a0)+,d0                 ;nÑchster wert
                bne L001B                       ;wiederhohlen bis null
kein_sod:       move.l a6,a7                    ;stack restaurieren
                lea $ffff820d.w,a6              ;adresse low byt screen
                moveq #$5a,d0                   ;test byt
                move.b d0,(a6)                  ;low byt screen setzen
                nop
                cmp.b (a6),d0                   ;noch gleich?
                bne L001E                       ;nein ->
                clr.b (a6)                      ;low byt lîschen
                nop
                tst.b (a6)                      ;noch 0?
L001E:          sne (a2)+                       ;STE mode byt setzen (STE -> =0)
                move.w #$c2a,d1                 ;(a04-ccb4-1)//$10 lîschen
                moveq #0,d0
L001F:          move.l d0,(a2)+                 ;tos bereich lîschen
                move.l d0,(a2)+
                move.l d0,(a2)+
                move.l d0,(a2)+
                dbf d1,L001F
                move.w #$7ff,d1
                move.l $49e.w,a0                ;st top
                lea -$8000(a0),a0               ;-screen lÑnge
                move.l a0,$44e.w                ;screen adr setzen
                move.b $44f.w,$ffff8201.w       ;screen setzen
                move.b $450.w,$ffff8203.w
L0020:          move.l d0,(a0)+                 ;screen lîschen
                move.l d0,(a0)+
                move.l d0,(a0)+
                move.l d0,(a0)+
                dbf d1,L0020
                bra $e002b2                      ;ende e002b2
                blk.b $e002b2-*,$ff
                
;memtop kommt woanders her
                org  $e00320
                load $100320
                move.l $42e.w,$436.w
                
;Prozessortest abÑndern,cache und transparent translation setzen
                org  $e0038a
                load $10038a
                moveq #40,d1                    ;prozessor = 68040
                moveq #0,d0
                dc.w movec,2                    ;cache aus
                dc.w movec,3                    ;translation aus
                dc.w movec,5                    ;itt1 aus
                dc.w movec,7                    ;dtt1 aus
                dc.w cinva,pflusha              ;caches  invalid
                move.l #$ffc040,d0              ;no cache serialized
                dc.w movec,6                    ;itt0 setzen
                dc.w movec,4                    ;dtt0 setzen
                moveq #0,d0                     ;beide cache aus
                move.l d0,$e4.w                 ;cacr save setzen
                dc.w movec,2                    ;cacr setzen
                bra $e003c2

;FPU Test Fehler korrigieren und bit fÅr 68040 setzen
                org  $e0049c
                load $10049c
                dc.w $4000
                move.l #$80000,(a0)+

;cache clear
                org  $e00620
                load $100620
cache_clear:    dc.w cpusha
                rts                

;bevor modifizierter code angesprungen wird cache push
                org  $e006d2
                load $1006d2
                bsr.l mod_cod_jsr
                
                org  $e006f6
                load $1006f6
                bsr.l mod_cod_jsr
                
                org  $e00710
                load $100710
                bsr.l mod_cod_jsr

;nach privileg violation neue exception adresse setzen

                org  $e00722
                load $100722
                jmp exception


;kein crc test
                org  $e007f6
                load $1007f6
                bra.l $e00894

;indirekte Sprungadresse bei (X)Bios anders bestimmer
                org  $e00d7e
                load $100d7e
                bmi.l jmp_ind
old_bios:

;neues physbase
                org  $e01014
		load $101014
                move.l $ffff8200.w,d0
                lsl.w #8,d0
                and.l #stram_start+$ffff00,d0
                nop

;floppy korrekturen*************************
;nur ein restore ausfÅhren um zu testen ob floppy angeschlossen
                org  $e0380A+lang_dif
                load $10380A+lang_dif
                dc.b $60                 ;branch allways

;high byt resp. word setzen

                org  $e0185c
                load $10185c
                move.w 0(a7),$ffff8608.w

                org  $e03b62+lang_dif
                load $103b62+lang_dif
                move.w $15d4.w,$ffff8608.w

                org  $e03c4e+lang_dif
                load $103c4e+lang_dif
                move.w $15d4.w,$ffff8608.w

                org  $e04006+lang_dif
                load $104006+lang_dif
                move.w $15d4.w,$ffff8608.w

;irgend so ein idiot hat doch tatsÑchlich 3 unterprogramme eingebaut um
;um die maximale dma-adresse bei floppyoperationen auf adressen unter
;$400000 (4MB!) zu beschrÑnken

                org  $e03826+lang_dif
                load $103826+lang_dif
                nop
                nop

                org  $e03922+lang_dif
                load $103922+lang_dif
                nop
                nop

                org  $e03a16+lang_dif
                load $103a16+lang_dif
                nop
                nop

                org  $e03c04+lang_dif
                load $103c04+lang_dif
                nop
                nop

;neuer kaltstart
                org  $e03466+lang_dif
                load $103466+lang_dif
kalt_erw:       bsr.l kaltstart

;cache push bei programmstart
                org  $e0fc0a+lang_dif
                load $10fc0a+lang_dif
                tst.w longframe.w
                beq.s $e0fc14+lang_dif
                dc.w cpusha

;Platz fÅr neue Programmteile an altem exceptionhandler
                org  $e010e2
                load $1010e2
jmp_ind:        add.l #$80000000,a0
                move.l (a0),a0
                bra old_bios

kaltstart:      move.w #$2700,sr
                moveq #0,d0
                dc.w movec,2    ;cache aus
                dc.w pflusha    ;cache invalid
                dc.w movec,3    ;mmu aus
                dc.w cinva      ;mmu invalid
                dc.w movec,4    ;transparent translation aus
                dc.w movec,5
                dc.w movec,6
                dc.w movec,7
                rts

mod_cod_jsr:    dc.w cpusha
                jmp $a04.w

                blk.b $e011ba-*,$ff

;neue Exectionroutine
                org  $e004e0
                load $1004e0
                lea exception,a1        ;neuer vektor
                lea 8.w,a0              ;beginn mit bus error
                move.w #$3d,d0
L002A:          move.l a1,(a0)+         ;vektoren setzen
                dbf d0,L002A
                bra $e004fe

                org  $e3e000
                load $13e000
exception:      move.l  2(SP),proc_pc.w ;pc merken
                movem.l D0-D7/A0-A7,proc_regs.w ;die Register merken
                move    USP,A0
                move.l  A0,proc_usp.w   ;den USP merken
                move.l  SP,A1
                moveq   #0,D1
                move.w  6(SP),D1        ;formatword hohlen
                and.w   #$0FFF,D1       ;format weg=offset
                asr.w   #2,D1           ;/4 ergibt vector
exception4:     lea     startup_stk.w,SP ;den Stack initialisieren
                tst.b   ste_hardware.w  ;STE vorhanden?
                bne.s   exception3      ;Nein! =>
                clr.b   $FFFF820D.w     ;low-Byte setzen (STE)
                clr.w   $FFFF820E.w     ;Offset to next line lîschen
                clr.w   $FFFF8264.w     ;Horizontal Bit-wize Scroll lîschen
                clr.w   $FFFF8900.w     ;Digi-Sound stoppen
exception3:     moveq   #15,D0
                lea     proc_stk.w,A0
exception2:     move.w  (A1)+,(A0)+     ;16 Worte vom SSP merken
                dbra    D0,exception2
                move.l  #$12345678,proc_lives.w ;Daten fÅr gÅltig erklÑren

bombs:          lea     tb1(PC),A0      ;zeiger auf starttext
                bsr     string_out      ;ausgeben
                cmp.w   #56,D1          ;vector =56?
                blt     bomb_fa4        ;nein kleiner->
                lea     tbuv(PC),A0     ;zeiger auf text
                bsr     string_out      ;text ausgeben
                move.w  D1,D2           ;vector nummer nach d2
                ror.l   #8,D2           ;an richtige stelle bringen
                moveq   #1,D0           ;2 Stellen
                bsr     reg_aus1        ;ausgeben
                bra     bomb_fa5
bomb_fa4:       lea     tbev(PC),A0     ;zeiger auf exception text
                subq.w  #1,D1           ;mit bus error beginnen
bomb_fa1:       subq.w  #1,D1           ;
                beq     bomb_fa2        ;ok->weg
bomb_fa3:       move.b  (A0)+,D6        ;nÑchstes zeichen
                beq     bomb_fa1        ;ende zeichenkette->
                bra     bomb_fa3        ;nein next
bomb_fa2:       bsr     string_out      ;text ausgeben
bomb_fa5:       lea     tb2(PC),A0      ;zeiger auf text
                bsr     string_out      ;text ausgeben PC=
                move.l  proc_pc.w,D2    ;pc wert hohlen
                bsr     reg_aus         ;ausgeben
                bsr     string_out      ;sr=
                move.w  proc_stk.w,D2   ;sr hohlen
                swap    D2              ;an richtige position bringen
                moveq   #3,D0           ;nur 4 stellen
                bsr     reg_aus1        ;ausgeben
                bsr     string_out      ;usp=
                move.l  proc_usp.w,D2   ;usp wert hohlen
                bsr     reg_aus         ;und ausgeben
                bsr     string_out      ;formatword=
                move.w  proc_stk+6.w,D2 ;formatword hohlen
                swap    D2              ;an richtige position bringen
                moveq   #3,D0           ;nur 4 stellen
                bsr     reg_aus1        ;und ausgeben
                bsr     string_out      ;(PC-4)=
                move.l  8.w,a4          ;buserrorvektor sichern
                move.l  #bomb_fa6,8.w   ;buserrorvektor setzen
                move.l  sp,a5           ;stack sichern
                move.l  proc_pc.w,a6    ;pc laden
                move.l  -4(a6),d2       ;werte vor pc stand
                bsr     reg_aus
                move.l  (a6),d2         ;werte bei pc stand
                bsr     reg_aus
bomb_fa6:       move.l  a4,8.w          ;alter buserrorvektor
                move.l  a5,sp           ;alter stack
                lea     tb3(PC),A0      ;zeiger auf text
                lea     proc_regs.w,A1  ;zeiger auf registerwerte
                moveq   #2,D4           ;daten,adressregister und stack
bomb_fa8:       bsr     string_out      ;text ausgeben
                moveq   #7,D3           ;8 register
bomb_fa7:       move.l  (A1)+,D2        ;wert hohlen
                bsr     reg_aus         ;und ausgeben
                dbra    D3,bomb_fa7     ;
                subq.l  #1,D4           ;-1
                bgt     bomb_fa8        ;>0 wiederhohlen
                lea     proc_stk.w,A1   ;zeiger auf stackwert
                beq     bomb_fa8        ;=0->wiederhohlen
                lea     tb4(PC),A0      ;zeiger auf text
                bsr     string_out      ;text ausgeben
                move    #$2300,SR       ;Interrupts erlauben
                move.w  #2,-(SP)        ;tastatur
                move.w  #2,-(SP)
                trap    #13             ;auf tastendruck warten
                addq.l  #4,SP           ;stack korrigieren
exitcrash:      move.l  #$093A,$04A2.w  ;BIOS-Stackpointer zurÅcksetzen
                move.l  #$4CFFFF,-(SP)  ;
                trap    #1              ;Pterm(-1) versuchen
                jmp     kalt_erw        ;RESET, wenn miûlungen

reg_aus:        moveq   #7,D0
reg_aus1:       rol.l   #4,D2           ;next hex zahl
                move.b  D2,D6
                and.b   #$0F,D6         ;nur 4 bits werden gebraucht
                add.b   #'0',D6         ;+ ascii 0
                cmp.b   #'9',D6         ;<=9?
                ble     reg_aus2        ;ja,ok->
                add.b   #'A'-'9'-1,D6   ;sonst differenz zuaddieren
reg_aus2:       bsr     zei_out         ;ausgeben
                dbra    D0,reg_aus1     ;wiederhohlen bis fertig
                moveq   #32,D6
                bra     zei_out         ;ein leerschlag

string_out:     move.b  (A0)+,D6        ;zeichen hohlen
                bne     str_out1        ;fertig? nein->
                rts                     ;zurÅck
str_out1:       bsr     zei_out         ;zeichen out
                bra     string_out      ;und von vorn

zei_out:        movem.l D0-D4/A0-A1,-(SP) ;register sichern
                and.w   #$FF,D6         ;nur bytwert
                move.w  D6,-(SP)        ;zeichen
                move.w  #2,-(SP)        ;bildschirm
                move.w  #3,-(SP)
                trap    #13             ;zeichen ausgeben
                addq.l  #6,SP
                movem.l (SP)+,D0-D4/A0-A1 ;register zurÅck
                rts

tb1:            DC.B 27,'H',10,10,10,10,10,10,27,'p',27,'KException ausgelîst durch: ',0
tb2:            DC.B 10,13,27,'K',10,13,27,'KPC=',0,' SR=',0,' USP=',0,' Formatword=',0,' (PC-4)=',0
tb3:            DC.B 10,13,27,'KD0-D7=',0,10,13,27,'KA0-A7=',0,10,13,27,'KStack=',0
tb4:            DC.B 10,13,27,'K',10,13,27,'K**--> DrÅcke Taste!',27,'q',0
tbuv:           DC.B 'Vector Nummer $',0
tbev:           DC.B 'Acess Fault!',0
                DC.B 'Adress Error!',0
                DC.B 'Illegal Instruction!',0
                DC.B 'Integer Divide by Zero!',0
                DC.B 'CHK, CHK2 Instruction!',0
                DC.B 'FTRAPcc, TRAPcc, TRAPV Instruction!',0
                DC.B 'Privileg Violation!',0
                DC.B 'Trace!',0
                DC.B 'Line A!',0
                DC.B 'Line F!',0
                DC.B 'Unassigned!',0
                DC.B 'Coprocessor Protocol Violation!',0
                DC.B 'Format Error!',0
                DC.B 'Uninitialized Interrupt!',0
                DC.B 'Unassigned, Reserved!',0
                DC.B 'Unassigned, Reserved!',0
                DC.B 'Unassigned, Reserved!',0
                DC.B 'Unassigned, Reserved!',0
                DC.B 'Unassigned, Reserved!',0
                DC.B 'Unassigned, Reserved!',0
                DC.B 'Unassigned, Reserved!',0
                DC.B 'Unassigned, Reserved!',0
                DC.B 'Spurious Interrupt!',0
                DC.B 'Level 1 Interrupt Autovektor!',0
                DC.B 'Level 2 Interrupt Autovektor!',0
                DC.B 'Level 3 Interrupt Autovektor!',0
                DC.B 'Level 4 Interrupt Autovektor!',0
                DC.B 'Level 5 Interrupt Autovektor!',0
                DC.B 'Level 6 Interrupt Autovektor!',0
                DC.B 'Level 7 Interrupt Autovektor!',0
                DC.B 'Trap #0 Instruction Vector!',0
                DC.B 'Trap #1 Instruction Vector!',0
                DC.B 'Trap #2 Instruction Vector!',0
                DC.B 'Trap #3 Instruction Vector!',0
                DC.B 'Trap #4 Instruction Vector!',0
                DC.B 'Trap #5 Instruction Vector!',0
                DC.B 'Trap #6 Instruction Vector!',0
                DC.B 'Trap #7 Instruction Vector!',0
                DC.B 'Trap #8 Instruction Vector!',0
                DC.B 'Trap #9 Instruction Vector!',0
                DC.B 'Trap #10 Instruction Vector!',0
                DC.B 'Trap #11 Instruction Vector!',0
                DC.B 'Trap #12 Instruction Vector!',0
                DC.B 'Trap #13 Instruction Vector!',0
                DC.B 'Trap #14 Instruction Vector!',0
                DC.B 'Trap #15 Instruction Vector!',0
                DC.B 'FP Branch or Set on Unordered Condition!',0
                DC.B 'FP Inexact Result!',0
                DC.B 'FP Divide by Zero!',0
                DC.B 'FP Underflow!',0
                DC.B 'FP Operand Error!',0
                DC.B 'FP Overflow!',0
                DC.B 'FP Signaling NAN!',0
                DC.B 'FP Unimplemented Data Typ!',0
                end
