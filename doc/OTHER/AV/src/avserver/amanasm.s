
MAX_WIND = 65
MAX_APP  = 64

COOKIE_ID = 0x416D414E /* 'AmAN' */

	.globl aman
	.globl old_xbios_trap
	.globl xbios_trap

pb_control = 0
pb_global = 4
pb_intin = 8
pb_intout = 12
pb_addrin = 16

CRYSTAL = 200

WIND_OPEN = 0
WIND_ICONIFY = 1

	.xref sp_offset

	.text

aman:
	.dc.l 0x14160495 /* version & date */
	.dc.l dcolor_a
	.dc.l dcolor_b
	.dc.l currxywh
	.dc.l kind
	.dc.l owner
	.dc.l name
	.dc.l info
	.dc.l menu_id
	.dc.l menu_tree
	.dc.l flags

valid_kind:
	.dc.w -1
	.dc.l 0


	.dc.l 0x58425241 /* 'XBRA' */
	.dc.l COOKIE_ID /* 'AmAN' */
old_xbios_trap:
	.dc.l 0
xbios_trap:
	btst       #5,(a7)			/* Called from supervisor? */
	beq.s      xbios_trap_1		/* no, get out */
	move.l     a0,save_a0
	movea.l    a7,a0
	adda.l     sp_offset,a0
	cmpi.w     #5,(a0)			/* was it Setexc call? */
	bne.s      xbios_trap_2		/* no, get out */
	cmpi.w     #0x0101,2(a0)	/* does it set the critical error handler? */
	bne.s      xbios_trap_2		/* no, get out */
	/* are we already in the XBRA chain? */
	movea.l    (0x00000088).w,a0
xbios_trap_4:
	cmpi.l     #0x58425241,-12(a0)
	bne.s      xbios_trap_3
	cmpi.l     #COOKIE_ID,-8(a0)
	beq.s      xbios_trap_2
	movea.l    -4(a0),a0
	bra.s      xbios_trap_4
xbios_trap_3:
	move.l     (0x00000088).w,aes_trap-4
	move.l     #aes_trap,(0x00000088).w
xbios_trap_2:
	movea.l    save_a0,a0
xbios_trap_1:
	move.l     old_xbios_trap,-(a7)
	rts

save_a0: .ds.l 1


	.dc.l 0x58425241 /* 'XBRA' */
	.dc.l COOKIE_ID /* 'AmAN' */
	.dc.l 0
aes_trap:
	cmpi.b     #CRYSTAL,d0 /* was it AES call? BUG: should be .w */
	bne        aes_exit
	movea.l    d1,a0
	movea.l    pb_control(a0),a0	/* get control array */
	/* check for functions to replace */
	cmpi.w     #35,(a0)
	beq        new_menu_register
	cmpi.w     #30,(a0)
	beq.s      new_menu_bar
	cmpi.w     #10,(a0)
	beq        new_appl_init
	cmpi.w     #100,(a0)
	beq        new_wind_create
	cmpi.w     #103,(a0)
	beq        new_wind_delete
	cmpi.w     #101,(a0)
	beq        new_wind_open
	cmpi.w     #102,(a0)
	beq        new_wind_close
	cmpi.w     #105,(a0)
	beq        new_wind_set
	cmpi.w     #104,(a0)
	beq        new_wind_get
	cmpi.w     #108,(a0)
	beq        new_wind_calc
	bra        aes_exit

new_menu_bar:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	cmpi.w     #-2,(a0)    /* call to get hi word? */
	beq.s      new_menu_bar1
	cmpi.w     #-3,(a0)    /* call to get lo word? */
	bne.s      new_menu_bar2
	movea.l    d1,a0
	movea.l    pb_addrin(a0),a0
	move.l     (a0),d0 /* get appl id */
	lsl.w      #2,d0
	movea.l    d1,a0
	movea.l    pb_intout(a0),a0
	move.l     a1,save_a1
	lea.l      menu_tree,a1
	move.w     2(a1,d0.w),(a0) /* return lo word of tree */
	movea.l    save_a1,a1
	move.l     #CRYSTAL,d0
	rte
new_menu_bar1:
	movea.l    d1,a0
	movea.l    pb_addrin(a0),a0
	move.l     (a0),d0
	lsl.w      #2,d0
	movea.l    d1,a0
	movea.l    pb_intout(a0),a0
	move.l     a1,save_a1
	lea.l      menu_tree,a1
	move.w     0(a1,d0.w),(a0) /* return hi word of tree */
	movea.l    save_a1,a1
	move.l     #CRYSTAL,d0
	rte
new_menu_bar2:
	tst.w      (a0)            /* remove bar? */
	beq.s      new_menu_bar3
	cmpi.w     #1,(a0)         /* install bar? */
	bne        go_old_aes
	movea.l    d1,a0
	movea.l    pb_global(a0),a0
	move.w     4(a0),d0        /* get appl id */
	lsl.w      #2,d0
	movea.l    d1,a0
	movea.l    pb_addrin(a0),a0
	move.l     a1,save_a1
	lea.l      menu_tree,a1
	move.l     (a0),0(a1,d0.w) /* save new menu tree */
	movea.l    save_a1,a1
	move.l     #CRYSTAL,d0
	bra        go_old_aes
new_menu_bar3:
	movea.l    d1,a0
	movea.l    pb_global(a0),a0
	move.w     4(a0),d0        /* get appl id */
	lsl.w      #2,d0
	lea.l      menu_tree,a0
	move.l     #0,0(a0,d0.w)   /* clear menu tree */
	move.l     #CRYSTAL,d0
	bra        go_old_aes



new_appl_init:
	lea.l      appl_data,a0
/* search for empty slot in table */
	clr.w      d0
appl_init1:
	tst.l      0(a0,d0.w)
	beq.s      appl_init2
	addq.w     #8,d0
	bra.s      appl_init1
appl_init2:
	move.l     d1,0(a0,d0.w)     /* store AESPB */
	move.l     2(a7),4(a0,d0.w)  /* store return pc */
	move.l     #appl_init_ret,2(a7) /* AES should return below */
	bra        go_old_aes
appl_init_ret:
	movea.l    d1,a0
	movea.l    pb_intout(a0),a0
	tst.w      (a0)
	bmi.s      appl_init3
	move.w     (a0),d0           /* get appl id */
	lsl.w      #2,d0
	lea.l      menu_tree,a0      /* clear menu tree for this app */
	move.l     #0,0(a0,d0.w)
appl_init3:
	lea.l      appl_data,a0
/* search for AESPB in table */
	clr.w      d0
appl_init4:
	cmp.l      0(a0,d0.w),d1
	beq.s      appl_init5
	addq.w     #8,d0
	bra.s      appl_init4
appl_init5:
	move.l     #0,0(a0,d0.w)     /* clear slot */
	movea.l    4(a0,d0.w),a0     /* get return pc */
	move.l     #CRYSTAL,d0
	jmp        (a0)              /* return to caller */



new_menu_register:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	cmpi.w     #-1,(a0)  /* is it menu_register(-1)? */
	bne.s      menu_register1
	movea.l    d1,a0
	movea.l    pb_addrin(a0),a0
	movea.l    (a0),a0
	cmpi.w     #0x3F00,(a0)   /* is it "?\0" ? */
	bne        go_old_aes
	clr.w      d0
	move.b     2(a0),d0       /* get appl id to query from string */
	lea.l      menu_id,a0
	move.b     0(a0,d0.w),d0  /* get menu id of appl */
	ext.w      d0
	movea.l    d1,a0
	movea.l    pb_intout(a0),a0
	move.w     d0,(a0)
	rte
menu_register1:
	clr.l      d0
	move.w     (a0),d0        /* get appl id */
	lsl.l      #2,d0
	lea.l      menu_register_pcs,a0
	move.l     2(a7),0(a0,d0.l) /* save return pc */
	move.l     #menu_register_ret,2(a7) /* let AES return here */
	move.l     #CRYSTAL,d0
	bra        go_old_aes



new_wind_create:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	move.w     valid_kind,d0
	and.w      d0,(a0)
	clr.l      d0
	movea.l    d1,a0
	movea.l    pb_global(a0),a0
	move.w     4(a0),d0 /* get appl id */
	lsl.w      #2,d0
	lea.l      wind_create_pcs,a0
	move.l     2(a7),0(a0,d0.l)
	move.l     #wind_create_ret,2(a7)
	bra        go_old_aes



new_wind_delete:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	move.w     (a0),d0
	lsl.w      #1,d0
	lea.l      owner,a0
	move.w     #-1,0(a0,d0.w)
	bra        go_old_aes



new_wind_close:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	move.w     (a0),d0
	lsl.w      #1,d0
	lea.l      flags,a0
	bclr       #WIND_OPEN,1(a0,d0.w)
	bra        go_old_aes



new_wind_calc:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	move.w     valid_kind,d0
	and.w      d0,2(a0)
	bra        go_old_aes




new_wind_get:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	cmpi.w     #1,2(a0) /* WF_KIND? */
	beq.s      wind_get_kind
	cmpi.w     #2,2(a0) /* WF_NAME? */
	beq.s      wind_get_name
	cmpi.w     #3,2(a0) /* WF_INFO? */
	beq        wind_get_info
	cmpi.w     #19,2(a0) /* WF_DCOLOR? */
	beq.s      wind_get_dcolor
/* FIXME: should handle WF_OWNER */
	bra        go_old_aes
wind_get_dcolor:
	clr.l      d0
	move.w     4(a0),d0
	cmpi.w     #18,d0
	bhi        wind_get_error
	lsl.l      #1,d0
	movea.l    d1,a0
	movea.l    pb_intout(a0),a1
	move.w     #1,(a1)
	lea.l      dcolor_a,a0
	move.w     0(a0,d0.w),2(a1)
	lea.l      dcolor_b,a0
	move.b     0(a0,d0.w),4(a1) /* BUG: must be move.w */
/* FIXME should set intout[3] to 3D-Flags */
	bra        wind_get_done
wind_get_kind:
	clr.l      d0
	move.w     (a0),d0
	lsl.l      #1,d0
	lea.l      owner,a0
	tst.w      0(a0,d0.w)
	bmi        wind_get_error
	movea.l    d1,a0
	movea.l    pb_intout(a0),a1
	move.w     #1,(a1)
	lea.l      kind,a0
	move.w     0(a0,d0.w),2(a1)
	bra.s      wind_get_done
wind_get_name:
	clr.l      d0
	move.w     (a0),d0
	lsl.l      #1,d0
	lea.l      owner,a0
	tst.w      0(a0,d0.w)
	bmi.s      wind_get_error
	lea.l      kind,a0
	btst       #0,1(a0,d0.w) /* does window have NAME widget? */
	beq.s      wind_get_error
	lsl.l      #1,d0
	movea.l    d1,a0
	movea.l    pb_intout(a0),a1
	move.w     #1,(a1)
	lea.l      name,a0
/* FIXME: incompatible to XaAES, which returns the string, not the address */
	move.l     0(a0,d0.w),2(a1)
	bra.s      wind_get_done
wind_get_info:
	clr.l      d0
	move.w     (a0),d0
	lsl.l      #1,d0
	lea.l      owner,a0
	tst.w      0(a0,d0.w)
	bmi.s      wind_get_error
	lea.l      kind,a0
	btst       #4,1(a0,d0.w) /* does window have INFO widget? */
	beq.s      wind_get_error
	lsl.l      #1,d0
	movea.l    d1,a0
	movea.l    pb_intout(a0),a1
	move.w     #1,(a1)
	lea.l      info,a0
/* FIXME: incompatible to XaAES, which returns the string, not the address */
	move.l     0(a0,d0.w),2(a1)
	bra.s      wind_get_done
wind_get_error:
	movea.l    d1,a0
	movea.l    pb_intout(a0),a0
	move.w     #0,(a0) /* return error */
wind_get_done:
	move.l     #CRYSTAL,d0
	rte


wind_set_name:
	move.w     (a0),d0
	bmi        go_old_aes
	lsl.l      #2,d0
	lea.l      name,a1
	move.l     4(a0),0(a1,d0.w)
	bra        go_old_aes

wind_set_info:
	move.w     (a0),d0
	bmi        go_old_aes
	lsl.l      #2,d0
	lea.l      info,a1
	move.l     4(a0),0(a1,d0.w)
	bra        go_old_aes

wind_set_dcolor:
	move.w     4(a0),d0
	cmpi.w     #18,d0
	bhi        go_old_aes
	lsl.l      #1,d0
	tst.w      6(a0)
	bmi.s      wind_set_dcolor1
	lea.l      dcolor_a,a1
	move.w     6(a0),0(a1,d0.w)
wind_set_dcolor1:
	tst.w      pb_intin(a0)
	bmi        go_old_aes
	lea.l      dcolor_b,a1
	move.w     pb_intin(a0),0(a1,d0.w)
	bra        go_old_aes

wind_set_iconify:
	clr.l      d0
	move.w     (a0),d0
	bmi        go_old_aes
	lsl.l      #1,d0
	lea.l      flags,a0
	bset       #WIND_ICONIFY,1(a0,d0.w)
	lsl.l      #1,d0
	lea.l      wind_get_pcs,a0
	move.l     2(a7),0(a0,d0.l)
	move.l     #wind_get_ret,2(a7)
	bra        go_old_aes

wind_set_uniconify:
	move.w     (a0),d0
	bmi        go_old_aes
	lsl.w      #1,d0
	lea.l      flags,a0
	bclr       #WIND_ICONIFY,1(a0,d0.w)
	lsl.l      #2,d0
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	move.l     a1,save_a1
	lea.l      currxywh,a1
	move.w     4(a0),0(a1,d0.w)
	move.w     6(a0),2(a1,d0.w)
	move.w     8(a0),4(a1,d0.w)
	move.w     10(a0),6(a1,d0.w)
	movea.l    save_a1,a1
	bra        go_old_aes

new_wind_set:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	cmpi.w     #2,2(a0) /* WF_NAME? */
	beq        wind_set_name
	cmpi.w     #3,2(a0) /* WF_INFO? */
	beq        wind_set_info
	cmpi.w     #19,2(a0) /* WF_DCOLOR? */
	beq        wind_set_dcolor
	cmpi.w     #26,2(a0) /* WF_ICONIFY? */
	beq        wind_set_iconify
	cmpi.w     #27,2(a0) /* WF_UNICONIFY? */
	beq.s      wind_set_uniconify
	cmpi.w     #5,2(a0) /* WF_CURRXYWH? */
	bne.s      go_old_aes
/* fall through to wind_open */




new_wind_open:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	clr.l      d0
	move.w     (a0),d0 /* get window handle */
	bmi.s      go_old_aes
	lsl.l      #2,d0
	lea.l      wind_open_pcs,a0
	move.l     2(a7),0(a0,d0.l) /* save return pc */
	move.l     #wind_open_ret,2(a7)
	lsl.l      #1,d0
	move.l     a1,save_a1
	movea.l    d1,a0
	movea.l    pb_control(a0),a0
	cmpi.w     #101,(a0) /* was it wind_open? */
	beq.s      wind_open1
	movea.l    d1,a0
	movea.l    pb_intin(a0),a1
	addq.l     #2,a1
	bra.s      wind_open2
wind_open1:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a1
wind_open2:
	lea.l      wind_open_coords,a0
	move.w     2(a1),0(a0,d0.w)
	move.w     4(a1),2(a0,d0.w)
	move.w     6(a1),4(a0,d0.w)
	move.w     8(a1),6(a0,d0.w)
	movea.l    save_a1,a1



go_old_aes:
	move.l     #CRYSTAL,d0
aes_exit:
	move.l     aes_trap-4,-(a7)
	rts

wind_get_ret:
	movea.l    d1,a0
	move.l     pb_global(a0),wind_get_aespb+pb_global
	movea.l    pb_intin(a0),a0
	move.w     (a0),wind_get_intin
	move.l     #wind_get_aespb,d1
	move.l     #CRYSTAL,d0
	trap       #2
	clr.l      d0
	move.w     wind_get_intin,d0
	lsl.l      #3,d0
	movea.l    d1,a0
	movea.l    pb_intout(a0),a0
	move.l     a1,-(a7)
	lea.l      currxywh,a1
	move.w     2(a0),0(a1,d0.l)
	move.w     4(a0),2(a1,d0.l)
	move.w     6(a0),4(a1,d0.l)
	move.w     8(a0),6(a1,d0.l)
	movea.l    (a7)+,a1
	clr.l      d0
	move.w     wind_get_intin,d0
	lsl.l      #2,d0
	lea.l      wind_get_pcs,a0
	move.l     0(a0,d0.l),-(a7)
	move.l     #CRYSTAL,d0
	rts

wind_get_aespb:
	.dc.l wind_get_control
	.dc.l 0
	.dc.l wind_get_intin
	.dc.l wind_get_intout
	.dc.l 0
	.dc.l 0

wind_get_control:   .dc.w 104,2,5,0,0      /* control for wind_get call */
wind_get_intin:     .dc.w 0,5
wind_get_intout:    .ds.w 8


menu_register_ret:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	clr.l      d0
	move.w     (a0),d0      /* get appl id */
	movea.l    d1,a0
	movea.l    pb_intout(a0),a1
	lea.l      menu_id,a0
	move.b     1(a1),0(a0,d0.w) /* store menu id */
	lsl.l      #2,d0
	lea.l      menu_register_pcs,a1
	move.l     0(a1,d0.l),-(a7) /* get return pc */
	move.l     #CRYSTAL,d0
	rts


wind_open_ret:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	clr.l      d0
	move.w     (a0),d0 /* get window handle */
	lsl.l      #1,d0
	movea.l    d1,a0
	movea.l    pb_intout(a0),a0
	tst.w      (a0)
	beq.s      wind_open_ret1
	movea.l    d1,a0
	movea.l    (a0),a0
	cmpi.w     #101,(a0) /* was it wind_open? */
	bne.s      wind_open_ret2
	lea.l      flags,a0
	bset       #WIND_OPEN,1(a0,d0.w)
wind_open_ret2:
	lsl.l      #2,d0
	move.l     a1,save_a1
	lea.l      wind_open_coords,a1
	lea.l      currxywh,a0
	move.w     0(a1,d0.w),0(a0,d0.w)
	move.w     2(a1,d0.w),2(a0,d0.w)
	move.w     4(a1,d0.w),4(a0,d0.w)
	move.w     6(a1,d0.w),6(a0,d0.w)
	movea.l    save_a1,a1
wind_open_ret1:
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	clr.l      d0
	move.w     (a0),d0 /* get window handle */
	lsl.l      #2,d0
	lea.l      wind_open_pcs,a0 /* get return pc */
	move.l     0(a0,d0.l),-(a7)
	move.l     #CRYSTAL,d0
	rts

wind_create_ret:
	movea.l    d1,a0
	movea.l    pb_intout(a0),a0
	move.w     (a0),d0
	bmi.s      wind_create_ret1
	movea.l    d1,a0
	movea.l    pb_intin(a0),a0
	movea.l    a0,a1
	lsl.w      #1,d0
	lea.l      kind,a0
	move.w     (a1),0(a0,d0.w) /* store window creation flags */
	lea.l      flags,a0
	move.w     #0,0(a0,d0.w)   /* clear our own flags */
	movea.l    d1,a0
	movea.l    pb_global(a0),a1
	lea.l      owner,a0
	move.w     4(a1),0(a0,d0.w) /* store window owner */
	movea.l    d1,a0
	movea.l    pb_intin(a0),a1
	lsl.w      #2,d0
	lea.l      currxywh,a0      /* store window coords */
	move.w     2(a1),0(a0,d0.w)
	move.w     4(a1),2(a0,d0.w)
	move.w     6(a1),4(a0,d0.w)
	move.w     8(a1),6(a0,d0.w)
wind_create_ret1:
	clr.l      d0
	movea.l    d1,a0
	movea.l    pb_global(a0),a1
	move.w     4(a1),d0         /* get appl id */
	lsl.w      #2,d0
	lea.l      wind_create_pcs,a0 /* get return pc */
	move.l     0(a0,d0.l),-(a7)
	move.l     #CRYSTAL,d0
	rts


	.data
owner:    .dcb.w MAX_WIND,-1

dcolor_a:
	dc.w 0x1101 /* W_BOX */
	dc.w 0x11c1 /* W_TITLE */
	dc.w 0x1101 /* W_CLOSER */
	dc.w 0x11c1 /* W_NAME */
	dc.w 0x1101 /* W_FULLER */
	dc.w 0x1101 /* W_INFO */
	dc.w 0x1101 /* W_DATA */
	dc.w 0x1101 /* W_WORK */
	dc.w 0x1101 /* W_SIZER */
	dc.w 0x1101 /* W_VBAR */
	dc.w 0x1101 /* W_UPARROW */
	dc.w 0x1101 /* W_DNARROW */
	dc.w 0x1111 /* W_VSLIDE */
	dc.w 0x1101 /* W_VELEV */
	dc.w 0x1101 /* W_HBAR */
	dc.w 0x1101 /* W_LFARROW */
	dc.w 0x1101 /* W_RTARROW */
	dc.w 0x1111 /* W_HSLIDE */
	dc.w 0x1101 /* W_HELEV */
dcolor_b:
	dc.w 0x1101 /* W_BOX */
	dc.w 0x1181 /* W_TITLE */
	dc.w 0x1101 /* W_CLOSER */
	dc.w 0x1181 /* W_NAME */
	dc.w 0x1101 /* W_FULLER */
	dc.w 0x1101 /* W_INFO */
	dc.w 0x1101 /* W_DATA */
	dc.w 0x1101 /* W_WORK */
	dc.w 0x1101 /* W_SIZER */
	dc.w 0x1101 /* W_VBAR */
	dc.w 0x1101 /* W_UPARROW */
	dc.w 0x1101 /* W_DNARROW */
	dc.w 0x1101 /* W_VSLIDE */
	dc.w 0x1101 /* W_VELEV */
	dc.w 0x1101 /* W_HBAR */
	dc.w 0x1101 /* W_LFARROW */
	dc.w 0x1101 /* W_RTARROW */
	dc.w 0x1101 /* W_HSLIDE */
	dc.w 0x1101 /* W_HELEV */

menu_id:  .dcb.b 256,-1

	.ascii "MENUADRESS"
	.even
menu_tree: .dcb.l MAX_APP+1,0
appl_data: .dcb.l MAX_APP*2,0

	.bss
	.ds.l 1
currxywh: .ds.w MAX_WIND*4
wind_open_coords: .ds.w MAX_WIND*4
kind:     .ds.w MAX_WIND
name:     .ds.l MAX_WIND
info:     .ds.l MAX_WIND
flags:    .ds.w MAX_WIND

wind_open_pcs: .ds.l 256 /* should be MAX_APP */
wind_get_pcs: .ds.l 256 /* should be MAX_APP */
wind_create_pcs: .ds.l MAX_APP
save_a1: .ds.l 1
menu_register_pcs: .ds.l 256 /* should be MAX_APP */
