; options for easyrider assembler
; generate objectcode module
 MODUL F:\LONGMATH.O

; no 26 Byte long label names
 OPT X-

; thats what the object has to show to the world

 GLOBL _lmul,_ldiv,_sav4ldiv

;+
; long multiply routine for 68000  - taken from GEMDOS of TOS 1.04
;
; well, depending how often this is called  - the routine is quite 
; worth to be optimized...
;
;  8(a6) l_op1
; 10(a6) l_op1lo
; 12(a6) l_op2
; 14(a6) l_op2lo
;-

_lmul:    link    a6,#-4
          clr.w   d2		;clr number of negative operands
          tst.l   8(a6)		;is operand positive ?
          bge.s   .l0691	;yes: OK, lets start
          neg.l   8(a6)		;no: then turn the sign
          addq.w  #1,d2		;one negative operands

.l0691:   tst.l   12(a6)	;is operand positive ?
          bge.s   .l0692	;yes: OK, lets start	
          neg.l   12(a6)	;no: then turn the sign
          addq.w  #1,d2		;increase negative operands

.l0692:   move.w  10(a6),d0	;get lowword op1
          mulu    14(a6),d0	;* lowword op2
          move.l  d0,-4(a6)	;save the result
          move.w  8(a6),d0	;get highword op1
          mulu    14(a6),d0	;* lowword op2
          move.w  12(a6),d1     ;get highword op2
          mulu    10(a6),d1	;* lowword op2
          add.w   d1,d0		;
          add.w   -4(a6),d0
          move.w  d0,-4(a6)
          move.l  -4(a6),d0
          btst    #0,d2		;none or both were negative
          beq.s   .l0693	;yes: do nothing
          neg.l   d0		;no: d0 must be made negative
.l0693:   unlk    a6
          rts
;+
; long division routine for 68000 from GEMDOS of TOS 1.04
;-

_ldiv:    link    a6,#-2
          movem.l d2-d7,-(a7)
          clr.w   d3
          moveq   #0,d5
          move.l  8(a6),d7
          move.l  12(a6),d6
          bne.s   .l0695
          move.l  #-$80000000,_sav4ldiv
          move.l  #-$80000000,d0
          divs    #0,d0
          bra.s   .l069f
.l0695:   bge.s   .l0696
          neg.l   d6
          addq.w  #1,d3
.l0696:   tst.l   d7
          bge.s   .l0697
          neg.l   d7
          addq.w  #1,d3
.l0697:   cmp.l   d7,d6
          bgt.s   .l069d
          bne.s   .l0698
          moveq   #1,d5
          moveq   #0,d7
          bra.s   .l069d
.l0698:   cmp.l   #$10000,d7
          bge.s   .l0699
          divu    d6,d7
          move.w  d7,d5
          swap    d7
          ext.l   d7
          bra.s   .l069d
.l0699:   moveq   #1,d4
.l069a:   cmp.l   d6,d7
          bcs.s   .l069b
          asl.l   #1,d6
          asl.l   #1,d4
          bra.s   .l069a
.l069b:   tst.l   d4
          beq.s   .l069d
          cmp.l   d6,d7
          bcs.s   .l069c
          or.l    d4,d5
          sub.l   d6,d7
.l069c:   lsr.l   #1,d4
          lsr.l   #1,d6
          bra.s   .l069b
.l069d:   cmp.w   #1,d3
          bne.s   .l069e
          neg.l   d7
          move.l  d7,_sav4ldiv
          move.l  d5,d0
          neg.l   d0
          bra.s   .l069f
.l069e:   move.l  d7,_sav4ldiv
          move.l  d5,d0
.l069f:   tst.l   (a7)+
          movem.l (a7)+,d3-d7
          unlk    a6
          rts
 BSS
 EVEN
_sav4ldiv:
 ds.l     1 
 EVEN
 END MODUL
 END
