        illegal
        move.l #$10001000,d0
        move.l #$20000002,d1
        bsr.s  _LMUL
        illegal

; the result should be
;          30004000*20000001
;        -------------------
;                   30004000
;        + C0002000 00000000
;        ===================
;          C0002000 30004000      
;             d0       d1                    
        
;input d0,d1: both values to multiply
;output d0,d1: 64 Bit long result

_LMUL:
        movem.l d3-d5,-(a7)
        moveq.l #0,d2
        moveq.l #0,d3
        moveq.l #0,d4
        moveq.l #0,d5        
        move.w  d1,d2           ;d2 = low1
        mulu.w  d0,d2           ;d2 = low0 * low1
        move.w  d1,d3           ;d3 = low1
        swap.w  d0
        mulu.w  d0,d3           ;d3 = hiw0 * low1
        swap.w  d1
        move.w  d1,d4           ;d4 = hiw1
        mulu.w  d0,d4           ;d4 = hiw0 * hiw1
        move.w  d1,d5           ;d5 = hiw1
        swap.w  d0
        mulu.w  d0,d5           ;d5 = low0 * hiw1 
        move.l  d2
        move.l  d4
; add hiw0 * low1 to high and low value
        moveq.l #0,d0
        moveq.l #0,d1
        move.w  d3,d1
        swap.w  d1
        swap.w  d3
        move.w  d3,d0
        add.l   d4,d0
        add.l   d2,d1
; add low0 * hiw0 to high and low value
        moveq.l #0,d2
        moveq.l #0,d4
        move.w  d5,d2
        swap.w  d2      ;add to low value
        swap.w  d5
        move.w  d5,d4
        add.l   d4,d0
        add.l   d2,d1
.lmulex:
        movem.l (a7)+,d3-d5
        rts


