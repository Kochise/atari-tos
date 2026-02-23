;+
; Testcode for lrecno logical mode bug in AHDI 6.06
; written by Normen B. Kowalewski, 17-Jul-1993
;
; LOAD RESIDENT DEBUGGER FIRST !! 
;- 
lrecno  equ  $90000
count   equ  $8000
spclust equ  4

		  illegal
		  lea	    nulls(pc),a0
                  movem.l   (a0)+,d0-d3
                  move.l    #lrecno,d1		;simulated lrecno >= 65536
                  move.l    #count,d2           ;simulated count
                  

;-
; new algorithm for multiply by 
; - finding the power of two of sec_per_cluster
; - lsr/lsl shifting instead of mulu
; - also checks for sec_per_cluster >15 Bit (EMEDIA)
;+
L00A7:
                  move.l    d3,-(a7)
                  move.w    s_per_lsec_1,d0	;d0 = sec_per_logsec
;+
; calculate power of two
;-
		  moveq.l   #0,d3		;d3 = init number of set bit
		  bra.s     branch		;into loop
add_shift:
                  addq.l    #1,d3		;increase bit number counter
                  cmp.w     #16,d3		;if more than bit 15: ERROR
                  beq       wrong
		  lsr.w     #1,d0		;move to right
branch:	          btst      #0,d0		;is bit equal zero ?
       	          beq.s     add_shift		;yes: check for next
;+
; d3 now contains the bit number (so the powerof 2) we have to multiply
; lrecno with. This now goes easily with lsl 
;-                 
                  lsl.l     d3,d1		;sec_per_logsec * lrecno
                  lsl.l     d3,d2               ;sec_per_logsec * count
                  add.l     part_start_1,d1     ;current partiton start
         	  move.l    (a7)+,d3
                  bra.s     L00A8		;go for it
wrong:
		  move.l    (a7)+,d3
                  moveq.l   #-7,d0		;unknown media, EMEDIA
                  bra.s     _EXERR_DO_RW        ;exit with error

L00A8:


                  move.l    d1,erg_1
                  move.l    d2,erg_1+4

_EXERR_DO_RW:     nop
                  illegal			;stop here with new algo

;+
; this is the same init phase for old algorithm
;-

		  lea	    nulls(pc),a0
                  movem.l   (a0)+,d0-d3
                  move.l    #lrecno,d1		;lrecno
                  move.l    #count,d2           ;count
;+
; tries to calculate the physical lrecno from the logical number
; and this is the bug:
; mulu cannot work correctly, if d1 and d2 are already bigger than
; 65565 !!
;-

oldrout:
                  mulu      s_per_lsec_2,d1	;sec_per_logsec * lrecno
                  add.l     part_start_2,d1	;current partition start
                  mulu      s_per_lsec_2,d2	;sec_per_logsec * count
                  move.l    d1,erg_2
                  move.l    d2,erg_2+4

                  
                  lea       erg_1(pc),a1
                  lea       erg_2(pc),a2
                  illegal

nulls:		  dc.l      0,0,0,0,0,0,0,0
endnulls:
		  dc.b      'new:',0,0
s_per_lsec_1:	  dc.w      spclust
part_start_1:     dc.l      $90000
erg_1:            dc.l      0,0 
                  dc.b      'old:',0,0
s_per_lsec_2:	  dc.w      spclust
part_start_2:     dc.l      $90000
erg_2:            dc.l      0,0

;                 #$11000	;lrecno
;                 #$8000        ;count
;results should be:
;                 dc.l      $11000*1+$90000 = $11000+$90000 = $A1000
;                 dc.l      count*1                         = $8000
;
;                 dc.l      $11000*4+$90000 = $44000+$90000 = $D4000
;		  dc.l      count*4 = $20000


