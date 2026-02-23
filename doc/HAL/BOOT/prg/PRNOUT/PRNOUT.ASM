        ttl     PRNOUT v1.2  : Direkte Druckerausgabe auf dem Soundchip
        llen    120
        list
*
* Programm, das sich in die BIOS-Routine Bconout einhÑngt und direkt
* den Soundchip zur Ausgabe des Zeichens programmiert.
* FÅr Christian und seinen NEC P2200; Hoffentlich nÅtzt es etwas!
* Siehe ST Computer 10'87 S.24 zum EinhÑngen in das XBIOS
* und c't 5/87 S.147 zur Ausgabe der Daten direkt auf dem Soundchip
*
* 18.2.1989 Ralf Meister
*


* Betriebssystemaufrufe
gemdos      set     1
xbios       set     14
bios        set     13

* Funktionsnummern des GEMDOS
Cconws      set     9
Pterm       set     $4c
Ptermres    set     $31

* Funktionsnummern des BIOS
Setexc      set     5
Bconout     set     3

* Exception-Vektor des BIOS
biosexc     set     45

* Adressen der Chips
s_chip      equ     $ffff8800           * Soundchip
mfp         equ     $fffffa00           * MFP 68901

* meine Kennung fÅr das XBRA-Verfahren
xbra        equ     'RMPO'

        text

* Nach Start des Programms wird sofort zur Initialisierung verzweigt, da
* dann dieser Teil des Programms freigegeben werden kann
start   jmp     init                * Initialisiere das System

* Hier wird eine 'XBRA'-Struktur im Speicher angelegt
        dc.l    'XBRA'
        dc.l    xbra            * AbkÅrzung fÅr PrnOut
old_bios
        ds.l    1               * Hier wird der alte BIOS Vektor abgelegt

* Die neue Routine, zu der bei einem BIOS Trap gesprungen wird
new_bios
        movea.l a7,a0           * ssp nach a0
        btst    #5,(a0)         * Aufruf im Supervisormodus ?
        beq.s   from_user       * nein
        addq.l  #6,a0           * Offset wegen sr und RÅcksprungadresse
        bra.s   test_prt
from_user
        move.l  usp,a0          * Daten vom User-Stackpointer holen

* Test, ob Åberhaupt unsere Routine gemeint ist
test_prt
        cmpi.w  #Bconout,(a0)   * Bconout ?
        bne.s   no_prt          * nein, kein Drucker
        tst.w   2(a0)           * auf Drucker (dev=0)?
        bne.s   no_prt          * nein, kein Drucker

* direkte Ausgabe auf dem Soundchip

        move.w  4(a0),d0        * Zeichen nach d0
        move.w  sr,-(a7)        * Interrupt Modus setzen
        move.w  #$2700,sr       * Interrupt retten
        lea     s_chip,a1
        lea     mfp+1,a0

* Setze Port A und B auf Output

        move.b  #7,(a1)         * I/O Modus in Register 7 setzen
        move.b  (a1),d1         * Hole das Register
        or.b    #%11000000,d1   * Setze Port A und B auf Output
        move.b  d1,2(a1)        * und an Soundchip weiterleiten

busy_clr
        btst    #0,(a0)         * Busy testen
        bne.s   busy_clr        * warten auf low

        move.b  #15,(a1)        * Register 15 ist Port B
        move.b  d0,2(a1)        * Daten -> Port B
        move.b  #14,(a1)        * Register 14 ist Port A
        andi.b  #%11011111,2(a1) * Strobe low
busy_set
        btst    #0,(a0)         * warten auf Busy
        beq.s   busy_set        * bis high Pegel

        ori.b   #%00100000,2(a1) * Stobe high

* Der Soundchip wird jetzt nicht wieder umprogrammiert, da es sinnlos ist,
* gleichzeitig ein- und ausgeben zu wollen

        moveq   #-1,d0
        move.w  (a7)+,sr        * Interrupt-Maske zurÅck
        rte                     * fertig


no_prt  move.l  old_bios,-(a7)  * Originaladresse des BIOS
        rts                     * und anspringen

*
* Initialisierung: Setzen der Vektoren und Meldung, evtl. schon resident
*
init    move.l  4(a7),pbase     * Adresse der Basepage
        pea     message         * Ausgeben der Meldung
        move.w  #Cconws,-(a7)
        trap    #gemdos
        addq.l  #6,a7

* Hole Adresse der BIOS Exeption und sehe, ob wir schon resident sind
        move.l  #-1,-(a7)
        move.w  #biosexc,-(a7)  * Exeption des BIOS
        move.w  #Setexc,-(a7)
        trap    #bios
        addq.l  #8,a7           * Stackkorrektur
        movea.l d0,a0           * Adresse des alten BIOS-Einsprungs
n_xbra  cmpi.l  #'XBRA',-12(a0) * Stimmt xbra Åberein
        bne.s   install         * Stimmt nicht Åberein
        cmpi.l  #xbra,-8(a0)    * Sind wir schon resident ?
        beq.s   no_inst         * Stimmt nicht Åberein
        move.l  -4(a0),a0       * Jetzt durch die Liste laufen
        bra.s   n_xbra

* Die Routine ist schon resident, mit Meldung verabschieden
no_inst pea     not_resi
        move.w  #Cconws,-(a7)
        trap    #gemdos
        addq.l  #6,a7
* Und jetzt mit Fehler aus dem Programm springen
cont    move.w  #-1,-(a7)       * Fehler -1
        move.w  #Pterm,-(a7)
        trap    #gemdos         * sollte nie zurÅckkehren
        addq.l  #4,a7
        bra.s   cont

* die Routine installieren
install pea     new_bios        * Neue Adresse des BIOS
        move.w  #biosexc,-(a7)  * Vektor des BIOS
        move.w  #Setexc,-(a7)
        trap    #bios           * Setzen
        addq.l  #8,a7
        lea     old_bios,a0
        move.l  d0,(a0)         * Alten Vektor setzen
* Und nun eine Meldung ausgeben
        pea     resi            * Meldung 'installiert'
        move.w  #Cconws,-(a7)
        trap    #gemdos
        addq.l  #6,a7
* Und nun Programm resident im Speicher halten
cont2   move.w  #0,-(a7)
        move.l  #init,d0        * Adresse der Initialisierungsroutine
        sub.l   pbase,d0        * minus Adresse der Basepage
        move.l  d0,-(a7)        * ergibt LÑnge des residenten Teils
        move.w  #Ptermres,-(a7)
        trap    #gemdos
        addq.l  #8,a7           * sollte nie wiederkommen
        bra.s   cont2

        data

pbase       ds.l    1               * Platz fÅr Adresse der Basepage
message     dc.b    'Direkte Druckerausgabe auf dem Soundchip ',0
resi        dc.b    'installiert.',$a,$d,'v1.2  Ralf Meister',$a,$d,0
not_resi    dc.b    'schon installiert.',$a,$d,'v1.2  Ralf Meister',$a,$d,0

        end

