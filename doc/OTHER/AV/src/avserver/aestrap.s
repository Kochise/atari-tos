	.globl install_aes_trap
	.globl sp_offset

	.xref gl_apid
	.xref ap_dragdrop_id

install_aes_trap:
	move.l     (0x00000088).w,aes_trap-4
	move.l     #aes_trap,(0x00000088).w
	clr.l      d0
	rts

CRYSTAL = 200
COOKIE_ID = 0x41565356 /* 'AVSV' */

	.dc.l 0x58425241 /* 'XBRA' */
	.dc.l COOKIE_ID
	.dc.l 0
aes_trap:
	cmpi.b     #CRYSTAL,d0 /* was it AES call? BUG: should be .w */
	bne.s      aes_trap2
	move.l     a0,save_a0
	movea.l    d1,a0
	movea.l    (a0),a0   /* get control array */
	cmpi.w     #12,(a0)  /* was it appl_write? */
	beq.s      aes_trap1 /* yes. go on */
	bra.s      aes_trap2 /* no, get out */
aes_trap1:
	movea.l    d1,a0
	movea.l    4(a0),a0  /* get global array */
	tst.w      4(a0)     /* was call from desktop? */
	bne.s      aes_trap2 /* no, get out */
	movea.l    d1,a0
	movea.l    16(a0),a0 /* get addrin array */
	movea.l    (a0),a0   /* get message buffer */
	cmpi.w     #63,(a0)  /* was it AP_DRAGDROP? */
	bne.s      aes_trap2 /* no, get out */
	movea.l    d1,a0
	movea.l    8(a0),a0  /* get intin array */
	move.w     (a0),ap_dragdrop_id /* save destination appl id */
	move.w     gl_apid,(a0) /* redirect to us */
aes_trap2:
	movea.l    save_a0,a0
	movea.l    aes_trap-4,a0
	jmp        (a0)

	.bss
sp_offset: .ds.l 1 /* FIXME: unused; BUG: accessed as short */
save_a0:   .ds.l 1

