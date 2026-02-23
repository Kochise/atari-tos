vblslot:        equ     $4d2
line_f:         equ     $2c
b_evnt:         equ     $f2c8
b_dta:          equ     $bbae
b_starter:      equ     $fe2698

start:          move    #-1,-(a7)
                move    #11,-(a7)
                trap    #13
                addq.l  #4,sp
                btst    #3,d0
                bne     dannich
                pea     init
                move    #38,-(a7)
                trap    #14
                addq.l  #6,sp
                move    #0,-(sp)
                move.l  #[ende-start+$100],-(sp)
                move    #$31,-(sp)
                trap    #1
                
dannich:        move    #0,-(sp)
                trap    #1
                
init:           tst.b   $fc0003
                beq     normtos
                lea     m_evnt(pc),a0
                move    #b_evnt,2(a0)
                lea     dta(pc),a0
                move.l  #b_dta,2(a0)
                lea     starter(pc),a0
                move.l  #b_starter,2(a0)
                
normtos:        move.l  #$0BFFFFFF,d0
                move.l  d0,line_f
                move.l  #neuvbl,vblslot
                rts
                
neuvbl:         move.l  line_f,d0
                cmp.l   #$0BFFFFFF,d0
                beq.s   nixda
                clr.l   vblslot
                move.l  line_f,a0
                move.l  a0,savelf
                move.l  #neulf,line_f
                
nixda:          rts
neulf:          move.l  2(a7),a0
m_evnt:         cmp.w   #$f08c,(a0)
                bne     altlf
                move.l  savelf,line_f
dta:            move.l  #$933a,a0
                move.l  #startfile,a1
loop:           move.b  (a1)+,(a0)+
                bne     loop
starter:        move.l  #$fe1de2,a0
jump:           jmp     (a0)
altlf:          move.l  savelf,a0
                jmp     (a0)
savelf:         dc.l    0
startfile:      dc.b    'AUTOGEM\*.*',0
                even
ende:           equ     *
