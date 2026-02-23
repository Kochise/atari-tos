/*
 * Theses constants *must* match the array sizes
 * in <aes.h>, or chaos will result
 */
AES_CTRLMAX		=		15
AES_GLOBMAX		=		15
AES_INTINMAX 	=		132
AES_INTOUTMAX	=		140
AES_ADDRINMAX	=		16
AES_ADDROUTMAX	=		16

CRYSTAL = 200

                .OFFSET 0
contrl:         .ds.w   AES_CTRLMAX
global:         .ds.w   AES_GLOBMAX
intin:          .ds.w   AES_INTINMAX
intout:         .ds.w   AES_INTOUTMAX
addrin:         .ds.l   AES_ADDRINMAX
addrout:        .ds.l   AES_ADDROUTMAX

/* offsets of AES control array */
                .OFFSET 0
a_opcode:       .ds.w   1
a_nintin:       .ds.w   1
a_nintout:      .ds.w   1
a_naddrin:      .ds.w   1
a_naddrout:     .ds.w   1

/* offsets of AES parameter block */
                .OFFSET 0
pb_control:     .ds.l   1
pb_global:      .ds.l   1
pb_intin:       .ds.l   1
pb_intout:      .ds.l   1
pb_addrin:      .ds.l   1
pb_addrout:     .ds.l   1

	.xref _GemParBlk

	.text

	.globl wdlg_create
wdlg_create:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #160,a_opcode(a2)
	move.w     #2,a_nintin(a2)
	move.w     #4,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     d0,(a2)+
	move.w     d1,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	move.l     8(a7),(a2)+
	move.l     12(a7),(a2)+
	bsr        aes
	movea.l    _GemParBlk+addrout,a0
	movea.l    (a7)+,a2
	rts

	.globl wdlg_open
wdlg_open:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #161,a_opcode(a2)
	move.w     #4,a_nintin(a2)
	move.w     #3,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     d0,(a2)+
	move.w     d1,(a2)+
	move.w     d2,(a2)+
	move.w     8(a7),(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	move.l     10(a7),(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl wdlg_close
wdlg_close:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #162,a_opcode(a2)
	clr.w      a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl wdlg_delete
wdlg_delete:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #163,a_opcode(a2)
	clr.w      a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl wdlg_get_tree
wdlg_get_tree:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #164,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #3,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	clr.w      (a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	move.l     8(a7),(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl wdlg_get_edit
wdlg_get_edit:
	move.l     a2,-(a7)
	move.l     a1,-(a7)
	move.w     #-1,_GemParBlk+intout+2
	lea.l      _GemParBlk+contrl,a2
	move.w     #164,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #1,(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	movea.l    (a7)+,a1
	lea.l      _GemParBlk+intout,a0
	move.w     (a0)+,d0
	move.w     (a0),(a1)
	movea.l    (a7)+,a2
	rts

	.globl wdlg_get_udata
wdlg_get_udata:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #164,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #2,(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	movea.l    _GemParBlk+addrout,a0
	movea.l    (a7)+,a2
	rts

	.globl wdlg_get_handle
wdlg_get_handle:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #164,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #3,(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl wdlg_set_edit
wdlg_set_edit:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #165,a_opcode(a2)
	move.w     #2,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	clr.w      (a2)+
	move.w     d0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl wdlg_set_tree
wdlg_set_tree:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #165,(a2)
	move.w     #1,a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #1,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl wdlg_set_size
wdlg_set_size:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #165,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #2,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl wdlg_event
wdlg_event:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #166,a_opcode(a2)
	clr.w      a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl wdlg_redraw
wdlg_redraw:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #167,a_opcode(a2)
	move.w     #2,a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     d0,(a2)+
	move.w     d1,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	bsr        aes
	movea.l    (a7)+,a2
	rts

	.globl lbox_create
lbox_create:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #170,a_opcode(a2)
	move.w     #8,a_nintin(a2)
	move.w     #8,a_naddrin(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	lea.l      8(a7),a0
	move.l     (a0)+,(a2)+
	move.l     (a0)+,(a2)+
	lea.l      _GemParBlk+intin,a1
	move.w     d0,(a1)+
	move.w     d1,(a1)+
	move.l     (a0)+,(a2)+
	move.l     (a0)+,(a2)+
	move.w     d2,(a1)+
	move.w     (a0)+,(a1)+
	move.l     (a0)+,(a2)+
	move.l     (a0)+,(a2)+
	move.w     (a0)+,(a1)+
	move.w     (a0)+,(a1)+
	move.w     (a0)+,(a1)+
	move.w     (a0)+,(a1)+
	bsr        aes
	movea.l    _GemParBlk+addrout,a0
	movea.l    (a7)+,a2
	rts

	.globl lbox_update
lbox_update:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #171,a_opcode(a2)
	clr.w      a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	bsr        aes
	movea.l    (a7)+,a2
	rts

	.globl lbox_do
lbox_do:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #172,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     d0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl lbox_delete
lbox_delete:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #173,a_opcode(a2)
	clr.w      a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl lbox_cnt_items
lbox_cnt_items:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	clr.w      (a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl lbox_get_tree
lbox_get_tree:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #1,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	movea.l    _GemParBlk+addrout,a0
	movea.l    (a7)+,a2
	rts

	.globl lbox_get_avis
lbox_get_avis:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #2,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl lbox_get_udata
lbox_get_udata:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #3,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	movea.l    _GemParBlk+addrout,a0
	movea.l    (a7)+,a2
	rts

	.globl lbox_get_afirst
lbox_get_afirst:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #4,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl lbox_get_slct_idx
lbox_get_slct_idx:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #5,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl lbox_get_items
lbox_get_items:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #6,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	movea.l    _GemParBlk+addrout,a0
	movea.l    (a7)+,a2
	rts

	.globl lbox_get_item
lbox_get_item:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,a_opcode(a2)
	move.w     #2,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #7,(a2)+
	move.w     d0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	movea.l    _GemParBlk+addrout,a0
	movea.l    (a7)+,a2
	rts

	.globl lbox_get_slct_item
lbox_get_slct_item:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #8,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	movea.l    _GemParBlk+addrout,a0
	movea.l    (a7)+,a2
	rts

	.globl lbox_get_idx
lbox_get_idx:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #9,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl lbox_get_bvis
lbox_get_bvis:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #10,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl lbox_get_bentries
lbox_get_bentries:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #11,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl lbox_get_bfirst
lbox_get_bfirst:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #174,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #12,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl lbox_set_asldr
lbox_set_asldr:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #175,a_opcode(a2)
	move.w     #2,a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	clr.w      (a2)+
	move.w     d0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	bsr        aes
	movea.l    (a7)+,a2
	rts

	.globl lbox_set_items
lbox_set_items:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #175,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #1,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	bsr        aes
	movea.l    (a7)+,a2
	rts

	.globl lbox_free_items
lbox_free_items:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #175,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #2,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	movea.l    (a7)+,a2
	rts

	.globl lbox_free_list
lbox_free_list:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #175,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #3,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	movea.l    (a7)+,a2
	rts

	.globl lbox_ascroll_to
lbox_ascroll_to:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #175,a_opcode(a2)
	move.w     #2,a_nintin(a2)
	move.w     #3,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #4,(a2)+
	move.w     d0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	move.l     8(a7),(a2)+
	bsr        aes
	movea.l    (a7)+,a2
	rts

	.globl lbox_set_bsldr
lbox_set_bsldr:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #175,a_opcode(a2)
	move.w     #2,a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #5,(a2)+
	move.w     d0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	bsr        aes
	movea.l    (a7)+,a2
	rts

	.globl lbox_set_bentries
lbox_set_bentries:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #175,a_opcode(a2)
	move.w     #2,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #6,(a2)+
	move.w     d0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	movea.l    (a7)+,a2
	rts

	.globl lbox_bscroll_to
lbox_bscroll_to:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #175,a_opcode(a2)
	move.w     #2,a_nintin(a2)
	move.w     #3,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #7,(a2)+
	move.w     d0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	move.l     8(a7),(a2)+
	bsr        aes
	movea.l    (a7)+,a2
	rts

	.globl fnts_create
fnts_create:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #180,a_opcode(a2)
	move.w     #4,a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     d0,(a2)+
	move.w     d1,(a2)+
	move.w     d2,(a2)+
	move.w     8(a7),(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	bsr        aes
	movea.l    _GemParBlk+addrout,a0
	movea.l    (a7)+,a2
	rts

	.globl fnts_delete
fnts_delete:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #181,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     d0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl fnts_open
fnts_open:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #182,a_opcode(a2)
	move.w     #9,a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	lea.l      _GemParBlk+intin,a2
	move.w     d0,(a2)+
	move.w     d1,(a2)+
	move.w     d2,(a2)+
	lea.l      8(a7),a0
	move.l     (a0)+,(a2)+
	move.l     (a0)+,(a2)+
	move.l     (a0)+,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl fnts_close
fnts_close:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #183,a_opcode(a2)
	move.w     #0,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl fnts_get_no_styles
fnts_get_no_styles:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #184,a_opcode(a2)
	move.w     #3,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #0,(a2)+
	move.l     d0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl fnts_get_style
fnts_get_style:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #184,a_opcode(a2)
	move.w     #4,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #1,(a2)+
	move.l     d0,(a2)+
	move.w     d1,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	move.l     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl fnts_get_name
fnts_get_name:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #184,a_opcode(a2)
	move.w     #3,a_nintin(a2)
	move.w     #4,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #2,(a2)+
	move.l     d0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	move.l     8(a7),(a2)+
	move.l     12(a7),(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl fnts_get_info
fnts_get_info:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #184,a_opcode(a2)
	move.w     #3,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #3,(a2)+
	move.l     d0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,-(a7)
	bsr        aes
	movea.l    (a7)+,a1
	movea.l    8(a7),a2
	lea.l      _GemParBlk+intout,a0
	move.w     (a0)+,d0
	move.w     (a0)+,(a1)
	move.w     (a0)+,(a2)
	movea.l    (a7)+,a2
	rts

	.globl fnts_add
fnts_add:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #185,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #0,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	bsr        aes
	move.w     _GemParBlk+intout,d0
	movea.l    (a7)+,a2
	rts

	.globl fnts_remove
fnts_remove:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #185,a_opcode(a2)
	move.w     #1,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+intin,a2
	move.w     #1,(a2)+
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	bsr        aes
	movea.l    (a7)+,a2
	rts

	.globl fnts_event
fnts_event:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #186,a_opcode(a2)
	move.w     #0,a_nintin(a2)
	move.w     #2,a_naddrin(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	move.l     a1,(a2)+
	bsr.w      aes
	lea.l      _GemParBlk+intout,a2
	move.w     (a2)+,d0
	lea.l      8(a7),a0
	movea.l    (a0)+,a1
	move.w     (a2)+,(a1)
	movea.l    (a0)+,a1
	move.w     (a2)+,(a1)
	movea.l    (a0)+,a1
	move.l     (a2)+,(a1)
	movea.l    (a0)+,a1
	move.l     (a2)+,(a1)
	movea.l    (a0)+,a1
	move.l     (a2)+,(a1)
	movea.l    (a7)+,a2
	rts

	.globl fnts_do
fnts_do:
	move.l     a2,-(a7)
	lea.l      _GemParBlk+contrl,a2
	move.w     #187,a_opcode(a2)
	move.w     #7,a_nintin(a2)
	move.w     #1,a_naddrin(a2)
	lea.l      _GemParBlk+addrin,a2
	move.l     a0,(a2)+
	lea.l      _GemParBlk+intin,a2
	move.w     d0,(a2)+
	move.l     d1,(a2)+
	move.l     d2,(a2)+
	move.l     8(a7),(a2)+
	move.l     a1,-(a7)
	bsr.w      aes
	movea.l    (a7)+,a1
	lea.l      _GemParBlk+intout,a2
	move.w     (a2)+,d0
	move.w     (a2)+,(a1)
	lea.l      12(a7),a0
	movea.l    (a0)+,a1
	move.l     (a2)+,(a1)
	movea.l    (a0)+,a1
	move.l     (a2)+,(a1)
	movea.l    (a0)+,a1
	move.l     (a2)+,(a1)
	movea.l    (a7)+,a2
	rts

aes:
	lea.l      aespb,a0
	move.l     a0,d1
	move.w     #CRYSTAL,d0
	trap       #2
	rts

	.data
aespb:
	.dc.l _GemParBlk+contrl
	.dc.l _GemParBlk+global
	.dc.l _GemParBlk+intin
	.dc.l _GemParBlk+intout
	.dc.l _GemParBlk+addrin
	.dc.l _GemParBlk+addrout

