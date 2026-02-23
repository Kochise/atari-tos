#include "config.h"
#include "asmdefs.h"
#include "tosvars.inc"

#if HADES /* whole file */

#include "hades.inc"

/*
 * origin where this routines are actually executed
 * This must be a RAM address.
 */
#ifndef mach64_org
#define mach64_org $300000
#endif
#ifndef MACH64_PCI
#define MACH64_PCI 1
#endif

/*
 * rename symbols according to flavour (PCI/ISA)
 */
#if MACH64_PCI
#define vga_base           pci_vga_base
#define vga_reg            pci_vga_reg
#define mach64_init        mach64_pci_init
#else
#define vga_base           isa_vga_base
#define vga_reg            isa_vga_reg+$10000
#define mach64_init        mach64_isa_init
#endif

#undef mach64_off
#define mach64_off mach64_org-mach64_init

/*
 * Actually 0x4758, but we read it as little-endian value
 */
#ifndef PCI_MACH64_GX_ID
/* mach64GX (ATI888GX00) */
#define PCI_MACH64_GX_ID	$5847
#endif

/*
 * Note: functions use a base address of vga_reg+$8000,
 * hence the -$8000 here
 */
CRTC_I          equ $03D4-$8000      /* CRT Controller index port */
CRTC_D          equ $03D5-$8000      /* CRT Controller data port */
ATC_IW          equ $03C0-$8000      /* ATTRX: Attribute controller: index and data write */
DAC_PEL         equ $03C6-$8000      /* VGA_DAC_MASK: RAMDAC pixel mask */
DAC_IR          equ $03C7-$8000      /* VGA_DAC_READ: RAMDAC read index */
DAC_IW          equ $03C8-$8000      /* VGA_DAC_WRITE: RAMDAC write index */
DAC_D           equ $03C9-$8000      /* VGA_DAC_DATA: RAMDAC palette data */
GDC_SEG         equ $03CD-$8000      /* GDC segment select, index and data ports */
GDC_I           equ $03CE-$8000      /* GRAX: Graphics Index register */
GDC_D           equ $03CF-$8000      /* GRAD: Graphics Data register */
TS_I            equ $03C4-$8000      /* SEQX: Sequencer Index register */
TS_D            equ $03C5-$8000      /* SEQD: Sequencer Data register */
MISC_W          equ $03C2-$8000      /* GENMO: Misc Output Write Register */
VIDSUB          equ $03C3-$8000      /* Video Subsystem register */
IS1_RC          equ $03DA-$8000      /* Input Status Register 1: color emulation */
R_GENMO         equ $03CC-$8000      /* Misc Output Read Register */

/* ATI VGA Extended Registers */
SETUP_CONTROL   equ $0102-$8000
ATI_I           equ $01ce-$8000      /* ATI index register */
ATI_D           equ $01cf-$8000      /* ATI index register */
HORZ_OVERSCAN   equ $62EE-$8000
ROM_PAGE_SEL    equ $46E8-$8000
ATI_DAC_R2      equ $02EA-$8000
ATI_DAC_R3      equ $02EB-$8000
ATI_DAC_R0      equ $02EC-$8000
ATI_DAC_R1      equ $02ED-$8000
CONFIG_STATUS_1 equ $12EE-$8000
CONFIG_STATUS_2 equ $16EE-$8000
MISC_OPTIONS    equ $36EE-$8000
SUBSYS_CNTL     equ $42E8-$8000
ADVFUNC_CNTL    equ $4AE8-$8000
CLOCK_SEL       equ $4AEE-$8000
MEM_BNDRY       equ $42EE-$8000
ROM_ADDR_1      equ $52EE-$8000
SCRATCH_PAD_1   equ $56EE-$8000
MEM_CFG         equ $5EEE-$8000
MAX_WAITSTATES  equ $6AEE-$8000
EXT_GE_CONFIG   equ $7AEE-$8000
MISC_CNTL       equ $7EEE-$8000
R_MISC_CNTL     equ $92EE-$8000


/* Mach64 only */
M64_CONFIG_CTRL     equ $6AEC-$8000
M64_CONFIG_CHIP_ID  equ $6EEC-$8000
M64_SCRATCH_REG_1   equ $46EC-$8000
M64_MEM_CNTL        equ $52EC-$8000
M64_DAC_W_INDEX     equ $5EEC-$8000		/* same as DAC_IW */
M64_DAC_DATA        equ $5EED-$8000		/* same as DAC_D */
M64_DAC_MASK        equ $5EEE-$8000		/* same as DAC_PEL */
M64_DAC_R_INDEX     equ $5EEF-$8000		/* same as DAC_IR */
M64_CRTC_GEN_CNTL   equ $1EEC-$8000
M64_CLOCK_CNTL      equ $4AEC-$8000
M64_CRTC_INT_CNTL   equ $1AEC-$8000
M64_BUS_CNTL        equ $4EEC-$8000
M64_GEN_TEST_CNTL   equ $66EC-$8000
M64_SCRATCH_REG0    equ $42EC-$8000
M64_DAC_CNTL        equ $62EC-$8000


ATI_DAC_ATI68830    equ 0
ATI_DAC_SC11483     equ 1
ATI_DAC_ATI68875    equ 2
ATI_DAC_BT476       equ 3
ATI_DAC_BT481       equ 4
ATI_DAC_ATI68860    equ 5
ATI_DAC_STG1700     equ 6
ATI_DAC_STG1702     equ 7

ACIA_IKBD_BASE equ $fffffc00

/*
 * Yes, we assemble to the data segment here, so that the code ends up at the end of the ROM image
 */
	data

	xdef mach64_init
mach64_init:
		suba.l     a0,a0
		bsr        init_main
		lea.l      vga_palette+mach64_off,a0
		clr.w      d0
		bsr.w      setcolor
		lea.l      vga_palette+3+mach64_off,a0
		moveq.l    #1,d0
		bsr.w      setcolor
		/* return framebuffer address */
		lea.l      vga_base+$A0000,a0
		rts

setcolor:
		move.b     d0,vga_reg+M64_DAC_W_INDEX+$8000
		/* short delay */
		clr.w      d0
		bra.s      setcolor_1
setcolor_2:
		addq.w     #1,d0
setcolor_1:
		cmp.w      #1,d0
		blt.s      setcolor_2
		move.b     (a0)+,vga_reg+M64_DAC_DATA+$8000
		/* short delay */
		clr.w      d0
		bra.s      setcolor_3
setcolor_4:
		addq.w     #1,d0
setcolor_3:
		cmp.w      #1,d0
		blt.s      setcolor_4
		move.b     (a0)+,vga_reg+M64_DAC_DATA+$8000
		/* short delay */
		clr.w      d0
		bra.s      setcolor_5
setcolor_6:
		addq.w     #1,d0
setcolor_5:
		cmp.w      #1,d0
		blt.s      setcolor_6
		move.b     (a0)+,vga_reg+M64_DAC_DATA+$8000
		rts

/*
 * Input:  d0.w = register offset
 *         d1.w = starting register index
 *         d2.w = number of values to write
 *         a1.l = table with values
 *         a0.l = register base
 */
write_idx_reg:
		movem.l    d3-d6,-(a7)
		move.b     d1,d3
		bra.s      write_idx_reg2
write_idx_reg1:
		move.b     d3,0(a0,d0.w)
		move.b     (a1)+,GDC_D-GDC_I(a0,d0.w)
		addq.b     #1,d3
write_idx_reg2:
		move.b     d3,d4
		ext.w      d4
		move.b     d1,d5
		ext.w      d5
		move.b     d2,d6
		ext.w      d6
		add.w      d6,d5
		cmp.w      d5,d4
		blt.s      write_idx_reg1
		movem.l    (a7)+,d3-d6
		rts

reset_sequencer:
		clr.b      TS_I(a0)			/* select reset register */
		move.b     #1,TS_D(a0)		/* stop sequencer */
		clr.b      TS_I(a0)			/* select reset register */
		move.b     #3,TS_D(a0)		/* restart sequencer */
		rts

/*
 * Write a word to memory-mapped register
 *
 * Input:  d0.w = register offset
 *         d1.w = value
 * Output: -
 * Clobbers: a0,d0,d1
 */
write_vga_word:
		move.l     d4,-(a7)
		move.w     d0,d4
		move.w     d1,d0
		moveq.l    #8,d1
		rol.w      d1,d0
		movea.l    vga_reg_ptr+mach64_off,a0
		move.w     d0,0(a0,d4.w)
		move.l     (a7)+,d4
		rts

/*
 * Read a word from memory-mapped register
 *
 * Input:  d0.w = register offset
 * Output: d0.w = value
 * Clobbers: a0,d1
 */
read_vga_word:
		moveq.l    #8,d1
		movea.l    vga_reg_ptr+mach64_off,a0
		move.w     0(a0,d0.w),d0
		rol.w      d1,d0
		rts

/*
 * Write a byte to memory-mapped register
 *
 * Input:  d0.w = register offset
 *         d1.b = value
 * Output: -
 * Clobbers: a0
 */
write_vga_byte:
		movea.l    vga_reg_ptr+mach64_off,a0
		move.b     d1,0(a0,d0.w)
		rts

/*
 * Read a byte from memory-mapped register
 *
 * Input:  d0.w = register offset
 * Output: d0.b = value
 * Clobbers: a0
 */
read_vga_byte:
		movea.l    vga_reg_ptr+mach64_off,a0
		move.b     0(a0,d0.w),d0
		rts

get_dactype:
		move.w     #M64_DAC_CNTL+2,d0
		bsr.w      read_vga_byte
		and.b      #7,d0
		rts

init_main:
		move.l     a2,-(a7)
		move.l     a3,-(a7)
		movea.l    a0,a3
		move.w     x118ae+mach64_off,d0
		beq.w      init_main_1
		suba.l     a0,a0
#if MACH64_PCI
/*
 * Note: logic here will find *last* card,
 * while logic in pcm64t finds *first* card.
 */
 		movea.l    a0,a1
		movea.l    #pci_conf1+2,a2
		cmpi.w     #PCI_MACH64_GX_ID,(a2)
		bne.s      test_pci_2
		movea.l    #pci_conf1+4,a0
		movea.l    #pci_conf1+16,a1
test_pci_2:
		movea.l    #pci_conf2+2,a2
		cmpi.w     #PCI_MACH64_GX_ID,(a2)
		bne.s      test_pci_3
		movea.l    #pci_conf2+4,a0
		movea.l    #pci_conf2+16,a1
test_pci_3:
		movea.l    #pci_conf3+2,a2
		cmpi.w     #PCI_MACH64_GX_ID,(a2)
		bne.s      test_pci_4
		movea.l    #pci_conf3+4,a0
		movea.l    #pci_conf3+16,a1
test_pci_4:
		movea.l    #pci_conf4+2,a2
		cmpi.w     #PCI_MACH64_GX_ID,(a2)
		bne.s      test_pci_5
		movea.l    #pci_conf4+4,a0
		movea.l    #pci_conf4+16,a1
test_pci_5:
		/* THO: BUG: a0/a1 are zero if no card found */
		move.b     #3,(a0) /* allow I/O space and memory space */
		clr.l      (a1) /* set memory base to 0 */
#endif
		move.l     #vga_reg+$8000,vga_reg_ptr+mach64_off
		bsr        x10b2e
		clr.b      d0
		bsr        x11224
		clr.w      x118ae+mach64_off
init_main_1:
		move.l     a3,d0
		bne.s      init_main_2
		lea.l      x117ce+mach64_off,a3
init_main_2:
		movea.l    vga_reg_ptr+mach64_off,a1
		movea.l    a3,a0
		bsr        x11244
		bsr        x10a02
		movea.l    a3,a0
		movea.l    (a7)+,a3
		movea.l    (a7)+,a2
		rts

/*
 * THO: does nothing. Maybe originally some ifdefd debug code here.
 */
dummy:
		rts

x10142:
		move.l     d3,-(a7)
		move.l     a2,-(a7)
		move.b     #$F1,d1
		move.w     #M64_BUS_CNTL,d0
		bsr        write_vga_byte
		moveq.l    #$20,d1
		move.w     #M64_BUS_CNTL+1,d0
		bsr        write_vga_byte
		clr.w      d3
		lea.l      x118b0+mach64_off,a2
		bra.s      x10142_1
x10142_2:
		dc.w $3232,$3202		/* get value */      /* move.w     2(a2,d3.w*2),d1 68020+ only */
		dc.w $3032,$3200		/* get register # */ /* move.w     0(a2,d3.w*2),d0 68020+ only */
		bsr        write_vga_word
		addq.w     #2,d3
x10142_1:
		dc.w $3032,$3200		/* move.w     0(a2,d3.w*2),d0 68020+ only */
		bne.s      x10142_2     /* loop until end of table */
		clr.b      d1
		move.w     #M64_CRTC_GEN_CNTL+3,d0
		bsr        write_vga_byte /* reset CRTC and enable VGA mode */
		movea.l    (a7)+,a2
		move.l     (a7)+,d3
		rts

m64_read_daci:
		move.w     #M64_DAC_W_INDEX,d0
		bsr        read_vga_byte
		rts

display_vga:
		move.l     d3,-(a7)
		move.w     #M64_CRTC_GEN_CNTL+3,d0
		bsr        read_vga_byte	/* read current mode */
		move.b     d0,d3		/* save for return value */
		moveq.l    #1,d1
		or.b       d0,d1		/* enable VGA display mode */
		move.w     #M64_CRTC_GEN_CNTL+3,d0
		bsr        write_vga_byte
		move.b     d3,d0		/* return previous display mode */
		move.l     (a7)+,d3
		rts

x101b2:
		move.l     d3,-(a7)
		move.b     d0,d3
		bsr.w      m64_read_daci
		move.b     d3,d1
		move.w     #M64_CRTC_GEN_CNTL+3,d0
		bsr        write_vga_byte
		move.l     (a7)+,d3
		rts

x101c8:
		movem.l    d3-d5,-(a7)
		move.b     d0,d5
		move.w     d1,d3
		move.w     d1,d0
		bsr.w      x10238
		move.w     d0,d3
		clr.b      d1
		move.w     #M64_CLOCK_CNTL,d0
		bsr        write_vga_byte
		bsr        x10304
		moveq.l    #1,d1
		move.w     #M64_CLOCK_CNTL,d0
		bsr        write_vga_byte
		bsr        x10304
		moveq.l    #1,d0
		bsr        x10320
		clr.b      d0
		bsr        x10320
		clr.b      d0
		bsr        x10320
		clr.w      d4
		bra.s      x101c8_1
x101c8_2:
		moveq.l    #1,d0
		and.b      d5,d0
		bsr        x10320
		asr.b      #1,d5
		addq.w     #1,d4
x101c8_1:
		cmp.w      #5,d4
		bcs.s      x101c8_2
		clr.w      d4
		bra.s      x101c8_3
x101c8_4:
		moveq.l    #1,d0
		and.b      d3,d0
		bsr        x10320
		lsr.w      #1,d3
		addq.w     #1,d4
x101c8_3:
		cmp.w      #$000D,d4
		bcs.s      x101c8_4
		movem.l    (a7)+,d3-d5
		rts

x10238:
		move.l     d3,-(a7)
		lea.l      x119fe+mach64_off,a0
		cmp.w      (a0),d0
		bcc.s      x10238_1
		move.w     (a0),d0
x10238_1:
		cmp.w      x11a00-x119fe(a0),d0
		bls.s      x10238_2
		move.w     x11a00-x119fe(a0),d0
x10238_2:
		moveq.l    #3,d1
		bra.s      x10238_3
x10238_4:
		add.w      d0,d0
		subq.w     #1,d1
x10238_3:
		move.w     (a0),d2
		lsl.w      #3,d2
		cmp.w      d2,d0
		bcs.s      x10238_4
		cmp.w      x11a00-x119fe(a0),d0
		bls.s      x10238_5
		move.w     x11a00-x119fe(a0),d0
x10238_5:
		moveq.l    #0,d2
		move.w     d0,d2
		move.l     d2,d0
		move.l     d0,d2
		move.w     x11a02-x119fe(a0),d3
		ext.l      d3
		dc.w $4c03,$2002		/* mulu.l     d3,d2 68020+ only */
		move.l     d2,d0
		move.w     x118a2+mach64_off,d2
		asr.w      #1,d2
		ext.l      d2
		add.l      d2,d0
		move.l     d0,d3
		move.w     x118a2+mach64_off,d2
		ext.l      d2
		dc.w $4c42,$3003		/* divul.l    d2,d3:d3 68020+ only */
		move.l     d3,d0
		cmp.w      x11a04-x119fe(a0),d0
		bls.s      x10238_6
		sub.w      x11a04-x119fe(a0),d0
		bra.s      x10238_7
x10238_6:
		clr.w      d0
x10238_7:
		and.w      #$00FF,d0
		move.w     d1,d2
		moveq.l    #9,d3
		lsl.w      d3,d2
		or.w       d2,d0
		or.w       #$1800,d0
		move.l     (a7)+,d3
		rts

x102bc:
		move.l     d3,-(a7)
		move.b     d0,d3
		move.w     #M64_CLOCK_CNTL,d0
		bsr        read_vga_byte
		move.b     d0,d1
		and.b      #$FB,d1
		move.b     d3,d0
		lsl.b      #2,d0
		or.b       d0,d1
		move.w     #M64_CLOCK_CNTL,d0
		bsr        write_vga_byte
		move.l     (a7)+,d3
		rts

x102e0:
		move.l     d3,-(a7)
		move.b     d0,d3
		move.w     #M64_CLOCK_CNTL,d0
		bsr        read_vga_byte
		move.b     d0,d1
		and.b      #$F7,d1
		move.b     d3,d0
		lsl.b      #3,d0
		or.b       d0,d1
		move.w     #M64_CLOCK_CNTL,d0
		bsr        write_vga_byte
		move.l     (a7)+,d3
		rts

x10304:
		bsr.w      nodelay
		move.w     #M64_CLOCK_CNTL,d0
		bsr        read_vga_byte
		move.b     d0,d1
		or.b       #$40,d1
		move.w     #M64_CLOCK_CNTL,d0
		bsr        write_vga_byte
		rts

x10320:
		bsr.w      x102bc
		clr.b      d0
		bsr.w      x102e0
		bsr.w      x10304
		moveq.l    #1,d0
		bsr.w      x102e0
		bsr.w      x10304
		rts

x1033a:
		move.l     d3,-(a7)
		move.w     #M64_CLOCK_CNTL,d0
		bsr        read_vga_byte
		move.b     d0,d3
		clr.b      d1
		move.w     #M64_CLOCK_CNTL,d0
		bsr        write_vga_byte
		move.b     d3,d0
		move.l     (a7)+,d3
		rts

x10356:
		moveq.l    #64,d1
		or.b       d0,d1
		move.w     #M64_CLOCK_CNTL,d0
		bsr        write_vga_byte
		rts

/*
 * Input:  d0.w = delay loop counter
 * Output: -
 * Clobbers: d0
 */
delay:
		tst.w      d0
		beq.s      delay_1
		mulu.w     #2000,d0
delay_2:
		tst.b      ACIA_IKBD_BASE
		subq.l     #1,d0
		bgt.s      delay_2
delay_1:
		rts

nodelay:
		clr.w      d0
		bsr.w      delay
		rts

short_delay:
		moveq.l    #1,d0
		bsr.w      delay
		rts

med_delay:
		moveq.l    #15,d0
		bsr.w      delay
		rts

x10390:
		movem.l    d3-d7/a2,-(a7)
		move.b     d0,d6
		move.w     d1,d5
		cmpi.w     #1,x11a0a+mach64_off
		bne.s      x10390_1
		bsr.w      x1033a
		move.b     d0,d3
		bsr        display_vga
		move.b     d0,d4
		bsr.w      med_delay
		move.w     d5,d1
		move.b     d6,d0
		bsr        x101c8
		bsr.w      short_delay
		bra        x10390_2
x10390_1:
		cmpi.w     #3,x11a0a+mach64_off
		bne        x10390_3
		bsr        x1033a
		move.b     d0,d3
		bsr        display_vga
		move.b     d0,d4
		moveq.l    #0,d1
		move.w     d5,d1
		divu.w     #$0064,d1
		move.w     d1,d5
		clr.w      d7
		lea.l      x118e8+mach64_off,a2
		bra.s      x10390_4
x10390_5:
		addq.w     #2,d7
x10390_4:
		dc.w $ba72,$7200			/* cmp.w      0(a2,d7.w*2),d5 68020+ only */
		bhi.s      x10390_5
		dc.w $3032,$7200			/* move.w     0(a2,d7.w*2),d0 68020+ only */
		sub.w      d5,d0
		move.w     d5,d1
		dc.w $9272,$72fc			/* sub.w      -4(a2,d7.w*2),d1 68020+ only */
		cmp.w      d1,d0
		bls.s      x10390_6
		subq.w     #2,d7
x10390_6:
		cmp.b      #$10,d6
		ble.s      x10390_7
		moveq.l    #16,d6
x10390_7:
		moveq.l    #1,d1
		move.w     #M64_DAC_CNTL,d0
		bsr        write_vga_byte
		move.b     d6,d1
		move.w     #M64_DAC_W_INDEX,d0
		bsr        write_vga_byte
		dc.w $1232,$7203			/* move.b     3(a2,d7.w*2),d1 68020+ only */
		move.w     #M64_DAC_DATA,d0
		bsr        write_vga_byte
		dc.w $3232,$7202			/* move.w     2(a2,d7.w*2),d1 68020+ only */
		lsr.w      #8,d1
		move.w     #M64_DAC_DATA,d0
		bsr        write_vga_byte
		cmp.b      #$10,d6
		bge.s      x10390_8
		move.w     #MEM_CFG,d0
		bsr        read_vga_byte
		move.w     #M64_DAC_W_INDEX,d0
		bsr        read_vga_byte
		move.w     #M64_DAC_W_INDEX,d0
		bsr        read_vga_byte
		move.w     #M64_DAC_W_INDEX,d0
		bsr        read_vga_byte
		move.w     #M64_DAC_W_INDEX,d0
		bsr        read_vga_byte
		move.b     #$80,d1
		or.b       d6,d1
		move.w     #M64_DAC_W_INDEX,d0
		bsr        write_vga_byte
x10390_8:
		clr.b      d1
		move.w     #M64_DAC_CNTL,d0
		bsr        write_vga_byte
x10390_2:
		move.b     d4,d0
		bsr        x101b2
		move.b     d3,d0
		bsr        x10356
x10390_3:
		movem.l    (a7)+,d3-d7/a2
		rts

x10496:
		movem.l    d3-d5,-(a7)
		move.b     d0,d5
		bsr        x1033a
		move.b     d0,d3
		bsr        display_vga
		move.b     d0,d4
		moveq.l    #1,d1
		move.w     #M64_DAC_CNTL,d0
		bsr        write_vga_byte
		move.w     #MEM_CFG,d0
		bsr        read_vga_byte
		move.w     #M64_DAC_W_INDEX,d0
		bsr        read_vga_byte
		move.w     #M64_DAC_W_INDEX,d0
		bsr        read_vga_byte
		move.w     #M64_DAC_W_INDEX,d0
		bsr        read_vga_byte
		move.w     #M64_DAC_W_INDEX,d0
		bsr        read_vga_byte
		move.b     d5,d1
		move.w     #M64_DAC_W_INDEX,d0
		bsr        write_vga_byte
		clr.b      d1
		move.w     #M64_DAC_CNTL,d0
		bsr        write_vga_byte
		move.b     d4,d0
		bsr        x101b2
		move.b     d3,d0
		bsr        x10356
		movem.l    (a7)+,d3-d5
		rts

x10500:
		movem.l    d3-d5/a2,-(a7)
		lea.l      x11a06+mach64_off,a2
		move.w     #$0433,x119fe-x11a06(a2)
		move.w     #$4268,x11a00-x11a06(a2)
		move.w     #$0598,x118a2+mach64_off
		move.w     #$002E,x11a02-x11a06(a2)
		move.w     #$0101,x11a04-x11a06(a2)
		move.l     #x1197c+mach64_off,(a2)
		bsr        x1033a
		move.b     d0,d3
		bsr        display_vga
		move.b     d0,d4
		bsr        med_delay
		clr.w      d5
		bra.s      x10500_1
x10500_2:
		movea.l    (a2),a0
		dc.w $3230,$5200		/* move.w     0(a0,d5.w*2),d1 68020+ only */
		move.b     d5,d0
		bsr        x101c8
		addq.w     #1,d5
x10500_1:
		cmp.w      #$0010,d5
		blt.s      x10500_2
		movea.l    (a2),a0
		move.w     36(a0),d1
		moveq.l    #18,d0
		bsr        x101c8
		cmpi.b     #ATI_DAC_ATI68860,dactype-x11a06(a2)
		bne.s      x10500_3
		move.w     #$1568,d1
		moveq.l    #19,d0
		bsr        x10390
		bra.s      x10500_4
x10500_3:
		move.w     #$125C,d1
		moveq.l    #19,d0
		bsr        x10390
x10500_4:
		move.b     d4,d0
		bsr        x101b2
		move.b     d3,d0
		bsr        x10356
		movem.l    (a7)+,d3-d5/a2
		rts

x10594:
		move.w     #$F2EC,d0
		bsr        read_vga_byte
		clr.w      d1
		move.b     d0,d1
		move.w     d1,d0
		asr.w      #3,d0
		and.w      #3,d0
		cmp.w      #3,d0
		beq.s      x10594_1
		cmp.w      #1,d0
		bne.s      x10594_2
x10594_1:
		moveq.l    #1,d0
		rts
x10594_2:
		clr.w      d0
		rts

/*
 * Input:  d0.w = value for video memory size
 *         d1.w = value for M64_SCRATCH_REG0+2 register
 * Output: d0.w = 0: error, 1: ok
 */
try_vidmemsize:
		movem.l    d3-d5,-(a7)
		move.w     d0,d4
		move.w     d1,d3
		move.w     #M64_MEM_CNTL,d0
		bsr        read_vga_byte
		move.b     d0,d1
		and.b      #$F8,d1					/* mask bits we dont set */
		moveq.l    #7,d0
		and.b      d4,d0					/* mask value for memsize */
		or.b       d0,d1					/* or it in */
		move.w     #M64_MEM_CNTL,d0
		bsr        write_vga_byte		/* write memory size back */
		clr.w      d1
		move.w     #M64_SCRATCH_REG0,d0
		bsr        write_vga_word
		move.w     d3,d1
		move.w     #M64_SCRATCH_REG0+2,d0
		bsr        write_vga_word
		move.w     #$1234,d4				/* test pattern */
		move.w     d4,d1
		move.w     #M64_SCRATCH_REG_1,d0
		bsr        write_vga_word
		move.w     #M64_GEN_TEST_CNTL+2,d0
		bsr        read_vga_word
		move.w     d0,d5
		and.w      #$FC8F,d5
		or.w       #$0310,d5
		move.w     d5,d1
		move.w     #M64_GEN_TEST_CNTL+2,d0
		bsr        write_vga_word
		clr.w      d1
		move.w     #M64_SCRATCH_REG0,d0
		bsr        write_vga_word
		move.w     d3,d1
		move.w     #M64_SCRATCH_REG0+2,d0
		bsr        write_vga_word
		move.w     #M64_GEN_TEST_CNTL+2,d0
		bsr        read_vga_word
		move.w     d0,d5
		and.w      #$FC8F,d5
		or.w       #$0210,d5
		move.w     d5,d1
		move.w     #M64_GEN_TEST_CNTL+2,d0
		bsr        write_vga_word
		move.w     #M64_SCRATCH_REG_1,d0
		bsr        read_vga_word
		cmp.w      d0,d4
		beq.s      try_vidmemsize_1
		clr.w      d0
		bra.s      try_vidmemsize_2
try_vidmemsize_1:
		moveq.l    #1,d0
try_vidmemsize_2:
		movem.l    (a7)+,d3-d5
		rts

x10666:
		clr.w      d0
		movea.l    #vga_base+$400000,a0
		bra.s      x10666_1
x10666_2:
		move.b     #$55,(a0)+
		addq.w     #1,d0
x10666_1:
		cmp.w      #10,d0
		blt.s      x10666_2
		clr.w      d0
		movea.l    #vga_base+$400000,a0
		bra.s      x10666_3
x10666_5:
		cmpi.b     #$55,(a0)+
		bne.s      x10666_4
		addq.w     #1,d0
x10666_3:
		cmp.w      #10,d0
		blt.s      x10666_5
		clr.w      d0
		movea.l    #vga_base+$400000,a0
		bra.s      x10666_6
x10666_7:
		move.b     #$AA,(a0)+
		addq.w     #1,d0
x10666_6:
		cmp.w      #10,d0
		blt.s      x10666_7
		clr.w      d0
		movea.l    #vga_base+$400000,a0
		bra.s      x10666_8
x10666_10:
		cmpi.b     #$AA,(a0)+
		beq.s      x10666_9
x10666_4:
		clr.w      d0
		rts
x10666_9:
		addq.w     #1,d0
x10666_8:
		cmp.w      #10,d0
		blt.s      x10666_10
		moveq.l    #1,d0
		rts

memtest:
		clr.w      d0
		movea.l    #vga_base+$600000,a0
		bra.s      memtest_1
memtest_2:
		move.b     #$55,(a0)+
		addq.w     #1,d0
memtest_1:
		cmp.w      #10,d0
		blt.s      memtest_2
		clr.w      d0
		movea.l    #vga_base+$600000,a0
		bra.s      memtest_3
memtest_5:
		cmpi.b     #$55,(a0)+
		bne.s      memtest_err
		addq.w     #1,d0
memtest_3:
		cmp.w      #10,d0
		blt.s      memtest_5
		clr.w      d0
		movea.l    #vga_base+$600000,a0
		bra.s      memtest_6
memtest_7:
		move.b     #$AA,(a0)+
		addq.w     #1,d0
memtest_6:
		cmp.w      #10,d0
		blt.s      memtest_7
		clr.w      d0
		movea.l    #vga_base+$600000,a0
		bra.s      memtest_8
memtest_10:
		cmpi.b     #$AA,(a0)+
		beq.s      memtest_9
memtest_err:
		clr.w      d0
		rts
memtest_9:
		addq.w     #1,d0
memtest_8:
		cmp.w      #10,d0
		blt.s      memtest_10
		moveq.l    #1,d0
		rts

x1072e:
		move.l     d3,-(a7)
		move.l     a2,-(a7)
		clr.w      d3
		moveq.l    #8,d1				/* VGA can write 2MB */
		moveq.l    #5,d0				/* 8MB */
		bsr        try_vidmemsize
		move.w     d0,d3
		tst.w      d3
		bne.s      x1072e_1
		moveq.l    #6,d1				/* VGA can write 1.5MB */
		moveq.l    #4,d0				/* 6MB */
		bsr        try_vidmemsize
		move.w     d0,d3
x1072e_1:
		tst.w      d3
		bne.s      x1072e_2
		bsr        x10594
		tst.w      d0
		bne.s      x1072e_2
		moveq.l    #4,d1				/* VGA can write 1MB */
		moveq.l    #3,d0				/* 4MB */
		bsr        try_vidmemsize
		move.w     d0,d3
x1072e_2:
		tst.w      d3
		bne.s      x1072e_3
		moveq.l    #2,d1				/* VGA can write 0.5MB */
		moveq.l    #2,d0				/* 2MB */
		bsr        try_vidmemsize
		move.w     d0,d3
x1072e_3:
		tst.w      d3
		bne.s      x1072e_4
		moveq.l    #1,d1				/* VGA can write 256K */
		moveq.l    #1,d0				/* 1MB */
		bsr        try_vidmemsize
		move.w     d0,d3
x1072e_4:
		move.w     #M64_GEN_TEST_CNTL+2,d0
		bsr        read_vga_word
		move.w     d0,d3
		and.w      #$FC8F,d3
		lea.l      x119fa+mach64_off,a2
		cmpi.b     #ATI_DAC_ATI68860,dactype-x119fa(a2)
		bne.s      x1072e_5
		move.w     #M64_MEM_CNTL,d0
		bsr        read_vga_byte
		move.b     d0,d1
		and.b      #$F8,d1
		or.b       #3,d1
		move.w     #M64_MEM_CNTL,d0
		bsr        write_vga_byte
		move.l     #$00400000,(a2)
		bsr        memtest
		tst.w      d0
		bne.s      x1072e_6
		move.w     #M64_MEM_CNTL,d0
		bsr        read_vga_byte
		move.b     d0,d1
		and.b      #$F8,d1
		or.b       #2,d1
		move.w     #M64_MEM_CNTL,d0
		bsr        write_vga_byte
		move.l     #$00200000,(a2)
		bra.s      x1072e_6
x1072e_5:
		move.w     #M64_MEM_CNTL,d0
		bsr        read_vga_byte
		move.b     d0,d1
		and.b      #$F8,d1
		or.b       #2,d1
		move.w     #M64_MEM_CNTL,d0
		bsr        write_vga_byte
		move.l     #$00200000,(a2)
		tst.w      d0
		bne.s      x1072e_7
		move.w     #M64_MEM_CNTL,d0
		bsr        read_vga_byte
		move.b     d0,d1
		and.b      #$F8,d1
		or.b       #1,d1
		move.w     #M64_MEM_CNTL,d0
		bsr        write_vga_byte
		move.l     #$00100000,(a2)
x1072e_7:
		ori.b      #3,x11a11-x119fa(a2)
x1072e_6:
		move.w     d3,d1
		move.w     #M64_GEN_TEST_CNTL+2,d0
		bsr        write_vga_word
		clr.w      d1
		move.w     #M64_SCRATCH_REG0,d0
		bsr        write_vga_word
		clr.w      d1
		move.w     #M64_SCRATCH_REG0+2,d0
		bsr        write_vga_word
		clr.w      d1
		move.w     #M64_SCRATCH_REG_1,d0
		bsr        write_vga_word
		clr.w      d1
		move.w     #M64_SCRATCH_REG_1+2,d0
		bsr        write_vga_word
		movea.l    (a7)+,a2
		move.l     (a7)+,d3
		rts

enable_vga:
		moveq.l    #$16,d1
		move.w     #ROM_PAGE_SEL,d0
		bsr        write_vga_byte	/* VGA setup mode */
		moveq.l    #1,d1
		move.w     #SETUP_CONTROL,d0
		bsr        write_vga_byte	/* Enable card */
		moveq.l    #$0e,d1
		move.w     #ROM_PAGE_SEL,d0
		bsr        write_vga_byte	/* Enable VGA */
		rts

set_iobase:
		moveq.l    #$50,d1
		move.w     #GDC_I,d0
		bsr        write_vga_byte	/* select ATI extended register base I/O address lobyte */
		move.b     #$CE,d1
		move.w     #GDC_D,d0
		bsr        write_vga_byte	/* write lobyte */
		moveq.l    #$51,d1
		move.w     #GDC_I,d0
		bsr        write_vga_byte	/* select ATI extended register base I/O address hibyte */
		move.b     #$81,d1
		move.w     #GDC_D,d0
		bsr        write_vga_byte	/* write hibyte; select range $80-$BF */
		rts

disable_screen:
		moveq.l    #1,d1
		move.w     #TS_I,d0
		bsr        write_vga_byte	/* select Clocking Mode Register */
		moveq.l    #$20,d1
		move.w     #TS_D,d0
		bsr        write_vga_byte	/* disable screen output */
		rts

x108ca:
		moveq.l    #4,d1
		move.w     #MISC_W,d0
		bsr        write_vga_byte
		move.w     #IS1_RC,d0			/* set ATC_IW to index */
		bsr        read_vga_byte
		move.w     #$83BA,d0
		bsr        read_vga_byte
		clr.b      d1
		move.w     #ATC_IW,d0
		bsr        write_vga_byte
		bsr.w      disable_screen
		move.b     #$A0,d1
		move.w     #ATI_I,d0
		bsr        write_vga_byte
		moveq.l    #$48,d1
		move.w     #ATI_D,d0
		bsr        write_vga_byte
		moveq.l    #$1d,d1
		move.w     #DAC_PEL,d0
		bsr        write_vga_byte
		clr.b      d1
		move.w     #DAC_IR,d0
		bsr        write_vga_byte
		moveq.l    #2,d1
		move.w     #DAC_IW,d0
		bsr        write_vga_byte
		move.b     #$A0,d1
		move.w     #ATI_I,d0
		bsr        write_vga_byte
		moveq.l    #$68,d1
		move.w     #ATI_D,d0
		bsr        write_vga_byte
		moveq.l    #97,d1
		move.w     #DAC_IW,d0
		bsr        write_vga_byte
		move.b     #$A0,d1
		move.w     #ATI_I,d0
		bsr        write_vga_byte
		moveq.l    #8,d1
		move.w     #ATI_D,d0
		bsr        write_vga_byte
		moveq.l    #1,d1
		move.w     #M64_CRTC_GEN_CNTL+3,d0
		bsr        write_vga_byte
		moveq.l    #$03,d1
		move.w     #M64_DAC_CNTL,d0
		bsr        write_vga_byte
		moveq.l    #$61,d1
		move.w     #M64_DAC_W_INDEX,d0
		bsr        write_vga_byte
		moveq.l    #2,d1
		move.w     #M64_DAC_CNTL,d0
		bsr        write_vga_byte
		moveq.l    #29,d1
		move.w     #MEM_CFG,d0
		bsr        write_vga_byte
		move.b     #$80,d1
		move.w     #M64_DAC_R_INDEX,d0
		bsr        write_vga_byte
		moveq.l    #2,d1
		move.w     #M64_DAC_W_INDEX,d0
		bsr        write_vga_byte
		moveq.l    #3,d1
		move.w     #M64_DAC_CNTL,d0
		bsr        write_vga_byte
		moveq.l    #101,d1
		move.w     #M64_DAC_W_INDEX,d0
		bsr        write_vga_byte
		clr.b      d1
		move.w     #M64_DAC_CNTL,d0
		bsr        write_vga_byte
		moveq.l    #$20,d1
		move.w     #M64_DAC_CNTL+1,d0
		bsr        write_vga_byte
		clr.b      d1
		move.w     #M64_CRTC_GEN_CNTL+3,d0
		bsr        write_vga_byte
		moveq.l    #77,d1
		move.w     #M64_CLOCK_CNTL,d0
		bsr        write_vga_byte
		move.b     #$FF,d1
		move.w     #DAC_PEL,d0
		bsr        write_vga_byte
		clr.b      d1
		move.w     #DAC_IW,d0
		bsr        write_vga_byte
		clr.b      d1
		move.w     #$83C9,d0
		bsr        write_vga_byte
		rts

x10a02:
		move.l     a2,-(a7)
		movea.l    #vga_base+$BFC00,a2
		move.w     #M64_BUS_CNTL,d0
		bsr        read_vga_word
		move.w     d0,d1
		or.w       #$00A0,d1
		move.w     #M64_BUS_CNTL,d0
		bsr        write_vga_word
		clr.b      d1
		move.w     #M64_GEN_TEST_CNTL+1,d0
		bsr        write_vga_byte
		moveq.l    #1,d1
		move.w     #M64_GEN_TEST_CNTL+1,d0
		bsr        write_vga_byte
		move.l     #-1,712(a2)
		clr.l      776(a2)
		movea.l    (a7)+,a2
		rts

x10a44:
		movem.l    d3-d4/a2,-(a7)
		lea.l      dactype+mach64_off,a2
		bsr        get_dactype
		move.b     d0,(a2)
		subq.b     #ATI_DAC_STG1702,d0
		bne.s      x10a44_1
		bsr        x1033a
		move.b     d0,d3
		bsr        display_vga
		move.b     d0,d4
		move.w     #MEM_CFG,d0
		bsr        read_vga_byte
		move.w     #MEM_CFG,d0
		bsr        read_vga_byte
		move.w     #MEM_CFG,d0
		bsr        read_vga_byte
		move.w     #MEM_CFG,d0
		bsr        read_vga_byte
		cmp.b      #$C0,d0
		bne.s      x10a44_2
		clr.b      (a2)
x10a44_2:
		move.b     d4,d0
		bsr        x101b2
		move.b     d3,d0
		bsr        x10356
x10a44_1:
		cmpi.b     #5,(a2)
		bne        x10a44_3
		bsr        display_vga
		move.b     d0,d4
		moveq.l    #1,d0
		bsr        x10ba2
		clr.b      d1
		move.w     #M64_DAC_W_INDEX,d0
		bsr        write_vga_byte
		clr.b      d1
		move.w     #M64_DAC_DATA,d0
		bsr        write_vga_byte
		clr.b      d1
		move.w     #M64_DAC_DATA,d0
		bsr        write_vga_byte
		clr.b      d1
		move.w     #M64_DAC_DATA,d0
		bsr        write_vga_byte
		move.b     #$FF,d1
		move.w     #M64_DAC_DATA,d0
		bsr        write_vga_byte
		move.b     #$FF,d1
		move.w     #M64_DAC_DATA,d0
		bsr        write_vga_byte
		move.b     #$FF,d1
		move.w     #M64_DAC_DATA,d0
		bsr        write_vga_byte
		moveq.l    #2,d0
		bsr        x10ba2
		move.b     #$80,d1
		move.w     #M64_DAC_DATA,d0
		bsr        write_vga_byte
		moveq.l    #2,d0
		bsr        x10ba2
		move.b     #$EC,d1
		move.w     #M64_DAC_W_INDEX,d0
		bsr        write_vga_byte
		clr.b      d0
		bsr        x10ba2
		move.b     d4,d0
		bsr        x101b2
x10a44_3:
		movem.l    (a7)+,d3-d4/a2
		rts

x10b2e:
		bsr        enable_vga
		bsr        x10142
		bsr        x10a44
		bsr        set_iobase
		move.b     #$B9,d1
		move.w     #ATI_I,d0
		bsr        write_vga_byte
		moveq.l    #64,d1
		move.w     #ATI_D,d0
		bsr        write_vga_byte
		clr.b      d1
		move.w     #ADVFUNC_CNTL,d0
		bsr        write_vga_byte		    /* Go to 8514 mode */
		bsr        enable_vga
		bsr        x108ca
		move.w     #1,x11a0a+mach64_off
		bsr        x10500
		bsr        x1072e
		bsr        dummy
		cmpi.b     #ATI_DAC_STG1702,dactype+mach64_off
		bne.s      x10b2e_1
		bsr        x11564
		move.b     d0,x11a12+mach64_off
		rts
x10b2e_1:
		move.b     dactype+mach64_off,d0
		bne.s      x10b2e_2
		move.w     #3,x11a0a+mach64_off
x10b2e_2:
		rts

x10ba2:
		move.l     d3,-(a7)
		move.b     d0,d3
		move.w     #M64_DAC_CNTL,d0
		bsr        read_vga_byte
		move.b     d0,d1
		and.b      #$FC,d1
		or.b       d3,d1
		move.w     #M64_DAC_CNTL,d0
		bsr        write_vga_byte
		move.l     (a7)+,d3
		rts

get_vidmemsize:
		move.w     #M64_MEM_CNTL,d0
		bsr        read_vga_byte
		and.b      #7,d0
		rts

x10bd0:
		movem.l    d3-d4/a2,-(a7)
		move.b     d1,d3
		lea.l      x119a4+mach64_off,a0
		clr.w      d1
		move.b     d0,d1
		dc.w $45f0,$1200			/* lea.l      0(a0,d1.w*2),a2 68020+ only */
		move.b     #$80,d0
		and.b      d3,d0
		beq.s      x10bd0_1
		lea.l      x119b2-x119a4(a0),a2
x10bd0_1:
		moveq.l    #3,d0
		bsr.w      x10ba2
		move.w     #M64_DAC_W_INDEX,d0
		bsr        read_vga_byte
		move.b     d0,d1
		and.b      #$FD,d1
		move.w     #M64_DAC_W_INDEX,d0
		bsr        write_vga_byte
		moveq.l    #2,d0
		bsr.w      x10ba2
		moveq.l    #29,d1
		move.w     #MEM_CFG,d0
		bsr        write_vga_byte
		move.b     (a2),d4
		moveq.l    #96,d0
		and.b      d4,d0
		beq.s      x10bd0_2
		moveq.l    #16,d1
		and.b      d3,d1
		beq.s      x10bd0_2
		or.b       #$10,d4
x10bd0_2:
		move.b     d4,d1
		move.w     #M64_DAC_R_INDEX,d0
		bsr        write_vga_byte
		moveq.l    #2,d1
		move.w     #M64_DAC_W_INDEX,d0
		bsr        write_vga_byte
		moveq.l    #3,d0
		bsr        x10ba2
		bsr        get_vidmemsize
		clr.w      d1
		move.b     d0,d1
		move.w     d1,d0
		cmp.w      #1,d0          /* >= 1MB? */
		bge.s      x10bd0_3
		moveq.l    #4,d1
		bra.s      x10bd0_4
x10bd0_3:
		cmp.w      #1,d0
		bne.s      x10bd0_5
		moveq.l    #8,d1
		bra.s      x10bd0_4
x10bd0_5:
		moveq.l    #12,d1
x10bd0_4:
		move.b     1(a2),d4
		moveq.l    #16,d0
		and.b      d3,d0
		beq.s      x10bd0_6
		and.b      #$FE,d4
x10bd0_6:
		move.w     #M64_DAC_W_INDEX,d0
		bsr        read_vga_byte
		move.b     #$EC,d1
		move.w     #M64_DAC_W_INDEX,d0
		bsr        write_vga_byte
		clr.b      d0
		bsr        x10ba2
		movem.l    (a7)+,d3-d4/a2
		rts

x10c96:
		move.w     #M64_DAC_W_INDEX,d0
		bsr        read_vga_byte
		move.w     #MEM_CFG,d0
		bsr        read_vga_byte
		move.w     #MEM_CFG,d0
		bsr        read_vga_byte
		move.w     #MEM_CFG,d0
		bsr        read_vga_byte
		move.w     #MEM_CFG,d0
		bsr        read_vga_byte
		rts

x10cc0:
		movem.l    d3/a2-a3,-(a7)
		move.b     d1,d3
		movea.l    a0,a2
		moveq.l    #0,d2
		move.b     d0,d2
		lea.l      0(a2,d2.l),a3
		cmpi.b     #$FF,(a3)
		bne.s      x10cc0_1
		bsr.w      x10c96
		moveq.l    #25,d1
		move.w     #MEM_CFG,d0
		bsr        write_vga_byte
		bra        x10cc0_2
x10cc0_1:
		moveq.l    #32,d0
		and.b      d3,d0
		beq.s      x10cc0_3
		lea.l      7(a2),a3
x10cc0_3:
		bsr.w      x10c96
		moveq.l    #16,d0
		and.b      d3,d0
		beq.s      x10cc0_4
		moveq.l    #26,d1
		move.w     #MEM_CFG,d0
		bsr        write_vga_byte
		bra.s      x10cc0_5
x10cc0_4:
		moveq.l    #24,d1
		move.w     #MEM_CFG,d0
		bsr        write_vga_byte
x10cc0_5:
		bsr.w      x10c96
		move.w     #MEM_CFG,d0
		bsr        read_vga_byte
		moveq.l    #3,d1
		move.w     #MEM_CFG,d0
		bsr        write_vga_byte
		clr.b      d1
		move.w     #MEM_CFG,d0
		bsr        write_vga_byte
		move.b     (a3),d1
		move.w     #MEM_CFG,d0
		bsr        write_vga_byte
		move.b     (a3),d1
		move.w     #MEM_CFG,d0
		bsr        write_vga_byte
		cmpi.b     #$05,(a3)
		bne.s      x10cc0_6
		moveq.l    #2,d1
		move.w     #MEM_CFG,d0
		bsr        write_vga_byte
		bra.s      x10cc0_2
x10cc0_6:
		cmpi.b     #$09,(a3)
		bne.s      x10cc0_2
		moveq.l    #1,d3
		cmpi.w     #$0C80,x11a0c+mach64_off
		blt.s      x10cc0_7
		add.w      d3,d3
		cmpi.w     #$1900,x11a0c+mach64_off
		blt.s      x10cc0_7
		addq.w     #1,d3
x10cc0_7:
		move.b     d3,d1
		move.w     #MEM_CFG,d0
		bsr        write_vga_byte
x10cc0_2:
		movem.l    (a7)+,d3/a2-a3
		rts

x10d88:
		movem.l    d3-d4/a2,-(a7)
		move.b     d1,d3
		moveq.l    #0,d2
		move.b     d0,d2
		lea.l      0(a0,d2.l),a2
		moveq.l    #32,d0
		and.b      d1,d0
		beq.s      x10d88_1
		lea.l      7(a0),a2
x10d88_1:
		bsr        x10c96
		move.b     (a2),d4
		moveq.l    #16,d0
		and.b      d3,d0
		beq.s      x10d88_2
		or.b       #2,d4
x10d88_2:
		move.b     d4,d1
		move.w     #MEM_CFG,d0
		bsr        write_vga_byte
		movem.l    (a7)+,d3-d4/a2
		rts

x10dc0:
		movem.l    d3-d4/a2,-(a7)
		move.b     d0,d3
		move.b     d1,d4
		subq.b     #6,d0
		bne.s      x10dc0_1
		moveq.l    #5,d3
x10dc0_1:
		lea.l      x119c4+mach64_off,a2
		cmpi.b     #ATI_DAC_STG1702,dactype+mach64_off
		beq.s      x10dc0_2
		movea.l    a2,a0
		move.b     d4,d1
		move.b     d3,d0
		bsr.w      x10d88
		bra.s      x10dc0_3
x10dc0_2:
		cmpi.b     #2,x11a12+mach64_off
		bne.s      x10dc0_4
		lea.l      x119bc-x119c4(a2),a0
		move.b     d4,d1
		move.b     d3,d0
		bsr.w      x10d88
		bra.s      x10dc0_3
x10dc0_4:
		lea.l      x119b4-x119c4(a2),a0
		move.b     d4,d1
		move.b     d3,d0
		bsr        x10cc0
x10dc0_3:
		movem.l    (a7)+,d3-d4/a2
		rts

x10e14:
		movem.l    d3-d6,-(a7)
		move.b     d0,d6
		move.b     d1,d3
		moveq.l    #1,d2
		and.b      d1,d2
		beq.s      x10e14_1
		move.w     #M64_CRTC_GEN_CNTL,d0
		bsr        read_vga_byte
		move.b     d0,d4
		and.b      #$DF,d4
		move.b     d4,d1
		move.w     #M64_CRTC_GEN_CNTL,d0
		bsr        write_vga_byte
		moveq.l    #3,d1
		move.w     #M64_CRTC_GEN_CNTL+3,d0
		bsr        write_vga_byte
		bra.s      x10e14_2
x10e14_1:
		clr.b      d1
		move.w     #M64_CRTC_GEN_CNTL+3,d0
		bsr        write_vga_byte
x10e14_2:
		bsr        display_vga
		move.b     d0,d5
		cmpi.b     #ATI_DAC_ATI68860,dactype+mach64_off
		bne.s      x10e14_3
		move.b     d3,d1
		move.b     d6,d0
		bsr        x10bd0
		bra.s      x10e14_4
x10e14_3:
		move.b     d3,d1
		move.b     d6,d0
		bsr        x10dc0
x10e14_4:
		move.b     d5,d0
		bsr        x101b2
		moveq.l    #1,d0
		and.b      d3,d0
		beq.s      x10e14_5
		move.w     #M64_CRTC_GEN_CNTL,d0
		bsr        read_vga_byte
		move.b     d0,d4
		and.b      #$9F,d4
		moveq.l    #32,d0
		and.b      d3,d0
		beq.s      x10e14_6
		or.b       #$20,d4
x10e14_6:
		move.b     d4,d1
		move.w     #M64_CRTC_GEN_CNTL,d0
		bsr        write_vga_byte
x10e14_5:
		movem.l    (a7)+,d3-d6
		rts

x10ea6:
		movem.l    d3/a2-a3,-(a7)
		movea.l    a0,a2
		movea.l    a1,a3
		move.w     52(a2),d0
		bsr        x11746
		move.w     d0,20(a3)
		clr.w      22(a3)
		moveq.l    #64,d0
		and.b      56(a2),d0
		bne.s      x10ea6_1
		ori.w      #1,22(a3)
x10ea6_1:
		move.b     #$80,d0
		and.b      56(a2),d0
		bne.s      x10ea6_2
		ori.w      #2,22(a3)
x10ea6_2:
		move.b     #$80,d0
		and.b      84(a2),d0
		beq.s      x10ea6_3
		ori.w      #4,22(a3)
x10ea6_3:
		move.b     #$80,d0
		and.b      66(a2),d0
		beq.s      x10ea6_4
		ori.w      #8,22(a3)
x10ea6_4:
		move.b     35(a2),d0
		ext.w      d0
		move.w     d0,18(a3)
		move.w     38(a2),16(a3)
		subq.w     #2,a7
		clr.b      -(a7)
		clr.b      d2
		moveq.l    #8,d1
		clr.w      d0
		move.b     57(a2),d0
		bsr        x11444
		addq.w     #4,a7
		move.b     55(a2),d1
		ext.w      d1
		and.w      #4,d1
		lsl.w      #6,d1
		add.w      d1,d0
		addq.w     #5,d0
		move.w     d0,(a3)
		moveq.l    #1,d1
		and.b      34(a2),d1
		beq.s      x10ea6_5
		addi.w     #$0200,(a3)
x10ea6_5:
		subq.w     #2,a7
		clr.b      -(a7)
		clr.b      d2
		moveq.l    #8,d1
		clr.w      d0
		move.b     58(a2),d0
		bsr        x11444
		addq.w     #4,a7
		move.b     55(a2),d1
		ext.w      d1
		and.w      #8,d1
		lsl.w      #5,d1
		add.w      d1,d0
		addq.w     #1,d0
		move.w     d0,2(a3)
		moveq.l    #2,d1
		and.b      34(a2),d1
		beq.s      x10ea6_6
		addi.w     #$0200,2(a3)
x10ea6_6:
		subq.w     #2,a7
		clr.b      -(a7)
		clr.b      d2
		moveq.l    #8,d1
		clr.w      d0
		move.b     61(a2),d0
		bsr        x11444
		addq.w     #4,a7
		move.b     55(a2),d1
		ext.w      d1
		and.w      #$0020,d1
		lsl.w      #3,d1
		add.w      d1,d0
		move.w     d0,4(a3)
		moveq.l    #4,d1
		and.b      34(a2),d1
		beq.s      x10ea6_7
		addi.w     #$0200,4(a3)
x10ea6_7:
		move.w     4(a3),d0
		move.w     2(a3),d1
		ext.l      d1
		divs.w     #2,d1
		cmp.w      d1,d0
		bge.s      x10ea6_8
		addi.w     #$0100,4(a3)
x10ea6_8:
		subq.w     #2,a7
		clr.b      -(a7)
		clr.b      d2
		moveq.l    #5,d1
		clr.w      d0
		move.b     62(a2),d0
		bsr        x11444
		addq.w     #4,a7
		move.w     d0,d1
		moveq.l    #63,d2
		and.w      4(a3),d2
		sub.w      d2,d1
		move.w     d1,6(a3)
		tst.w      d1
		bpl.s      x10ea6_9
		addi.w     #$0040,6(a3)
x10ea6_9:
		subq.w     #2,a7
		clr.b      -(a7)
		clr.b      d2
		moveq.l    #8,d1
		clr.w      d0
		move.b     63(a2),d0
		bsr        x11444
		addq.w     #4,a7
		move.w     d0,-(a7)
		moveq.l    #8,d0
		move.b     d0,-(a7)
		clr.b      d2
		moveq.l    #1,d1
		clr.w      d0
		move.b     64(a2),d0
		bsr        x11444
		addq.w     #2,a7
		or.w       (a7)+,d0
		move.w     d0,-(a7)
		moveq.l    #9,d0
		move.b     d0,-(a7)
		moveq.l    #5,d2
		moveq.l    #1,d1
		clr.w      d0
		move.b     64(a2),d0
		bsr        x11444
		addq.w     #2,a7
		or.w       (a7)+,d0
		move.w     d0,-(a7)
		moveq.l    #10,d0
		move.b     d0,-(a7)
		moveq.l    #1,d2
		moveq.l    #1,d1
		clr.w      d0
		move.b     84(a2),d0
		bsr        x11444
		addq.w     #2,a7
		or.w       (a7)+,d0
		addq.w     #2,d0
		move.w     d0,8(a3)
		subq.w     #2,a7
		clr.b      -(a7)
		clr.b      d2
		moveq.l    #8,d1
		clr.w      d0
		move.b     75(a2),d0
		bsr        x11444
		addq.w     #4,a7
		move.w     d0,-(a7)
		moveq.l    #8,d0
		move.b     d0,-(a7)
		moveq.l    #1,d2
		moveq.l    #1,d1
		clr.w      d0
		move.b     64(a2),d0
		bsr        x11444
		addq.w     #2,a7
		or.w       (a7)+,d0
		move.w     d0,-(a7)
		moveq.l    #9,d0
		move.b     d0,-(a7)
		moveq.l    #6,d2
		moveq.l    #1,d1
		clr.w      d0
		move.b     64(a2),d0
		bsr        x11444
		addq.w     #2,a7
		or.w       (a7)+,d0
		move.w     d0,-(a7)
		moveq.l    #10,d0
		move.b     d0,-(a7)
		moveq.l    #2,d2
		moveq.l    #1,d1
		clr.w      d0
		move.b     84(a2),d0
		bsr        x11444
		addq.w     #2,a7
		or.w       (a7)+,d0
		addq.w     #1,d0
		move.w     d0,10(a3)
		subq.w     #2,a7
		clr.b      -(a7)
		clr.b      d2
		moveq.l    #8,d1
		clr.w      d0
		move.b     73(a2),d0
		bsr        x11444
		addq.w     #4,a7
		move.w     d0,-(a7)
		moveq.l    #8,d0
		move.b     d0,-(a7)
		moveq.l    #2,d2
		moveq.l    #1,d1
		clr.w      d0
		move.b     64(a2),d0
		bsr        x11444
		addq.w     #2,a7
		or.w       (a7)+,d0
		move.w     d0,-(a7)
		moveq.l    #9,d0
		move.b     d0,-(a7)
		moveq.l    #7,d2
		moveq.l    #1,d1
		clr.w      d0
		move.b     64(a2),d0
		bsr        x11444
		addq.w     #2,a7
		or.w       (a7)+,d0
		move.w     d0,-(a7)
		moveq.l    #10,d0
		move.b     d0,-(a7)
		moveq.l    #3,d2
		moveq.l    #1,d1
		clr.w      d0
		move.b     84(a2),d0
		bsr        x11444
		addq.w     #2,a7
		or.w       (a7)+,d0
		move.w     d0,12(a3)
		subq.w     #2,a7
		clr.b      -(a7)
		clr.b      d2
		moveq.l    #4,d1
		clr.w      d0
		move.b     74(a2),d0
		bsr        x11444
		addq.w     #4,a7
		cmpi.w     #4,38(a2)
		bgt.s      x10ea6_10
		moveq.l    #1,d2
		add.w      44(a2),d2
		asr.w      #3,d2
		move.w     d2,36(a2)
		asr.w      #1,d2
		move.b     d2,76(a2)
		bra        x10ea6_11
x10ea6_10:
		move.w     38(a2),d1
		ext.l      d1
		divs.w     #8,d1
		cmpi.w     #32,38(a2)
		bge.s      x10ea6_12
		move.w     (a3),d2
		ext.l      d2
		divs.w     d1,d2
		move.w     d2,(a3)
		move.w     2(a3),d2
		ext.l      d2
		divs.w     d1,d2
		move.w     d2,2(a3)
		move.w     4(a3),d2
		ext.l      d2
		divs.w     d1,d2
		move.w     d2,4(a3)
		move.w     6(a3),d2
		ext.l      d2
		divs.w     d1,d2
		move.w     d2,6(a3)
x10ea6_12:
		cmpi.w     #$0018,38(a2)
		bgt.s      x10ea6_13
		move.w     #$0080,d2
		add.w      44(a2),d2
		asr.w      #3,d2
		and.w      #$FFF0,d2
		move.w     d2,24(a3)
		mulu.w     38(a2),d2
		move.w     d2,36(a2)
		ext.l      d2
		moveq.l    #1,d3
		add.w      46(a2),d3
		ext.l      d3
		dc.w $4c03,$2802		/* muls.l     d3,d2 68020+ only */
		cmp.l      x119fa+mach64_off,d2
		bls.s      x10ea6_11
x10ea6_13:
		moveq.l    #1,d2
		add.w      44(a2),d2
		muls.w     d1,d2
		move.w     d2,36(a2)
		moveq.l    #1,d3
		add.w      44(a2),d3
		asr.w      #3,d3
		move.w     d3,24(a3)
x10ea6_11:
		moveq.l    #8,d2
		and.w      22(a3),d2
		beq.s      x10ea6_14
		asr.w      8(a3)
		asr.w      10(a3)
		asr.w      12(a3)
		asr.w      #1,d0
x10ea6_14:
		moveq.l    #15,d1
		and.w      12(a3),d1
		sub.w      d1,d0
		tst.w      d0
		bpl.s      x10ea6_15
		add.w      #$0010,d0
x10ea6_15:
		move.w     d0,14(a3)
		subq.w     #1,(a3)
		subq.w     #1,2(a3)
		subq.w     #1,4(a3)
		subq.w     #1,8(a3)
		subq.w     #1,10(a3)
		subq.w     #1,12(a3)
		cmpi.w     #$001F,6(a3)
		ble.s      x10ea6_16
		move.w     #$001F,6(a3)
x10ea6_16:
		movem.l    (a7)+,d3/a2-a3
		rts

x11224:
		lea.l      vga_reg_ptr+mach64_off,a0
		movea.l    (a0),a1
		clr.b      M64_DAC_W_INDEX(a1)
		clr.w      d1
		bra.s      x11224_1
x11224_2:
		movea.l    (a0),a1
		move.b     d0,M64_DAC_DATA(a1)
		addq.w     #1,d1
x11224_1:
		cmp.w      #$0300,d1
		blt.s      x11224_2
		rts

/*
 * Input:  a1.l = register base
 */
x11244:
		movem.l    a2-a4,-(a7)
		lea.l      -28(a7),a7
		movea.l    a0,a2
		movea.l    a1,a3
		lea.l      (a7),a1
		bsr        x10ea6
		cmpi.b     #ATI_DAC_ATI68860,dactype+mach64_off
		bne.s      x11244_1
		move.w     #$1518,d1
		moveq.l    #19,d0
		bsr        x10390
		bra.s      x11244_2
x11244_1:
		move.w     #$125C,d1
		moveq.l    #19,d0
		bsr        x10390
x11244_2:
		moveq.l    #17,d1
		move.w     #M64_CONFIG_CTRL,d0
		bsr        write_vga_word
		moveq.l    #1,d1
		moveq.l    #2,d0
		bsr        x10e14
		move.w     52(a2),d1
		move.w     d1,d0
		add.w      d0,d0
		add.w      d1,d0
		lsl.w      #3,d0
		add.w      d1,d0
		lsl.w      #2,d0
		move.w     d0,x11a0c+mach64_off
		moveq.l    #5,d0
		move.w     x11a0c+mach64_off,d1
		bsr        x10390
		move.w     #5,20(a7)
		moveq.l    #2,d1
		move.w     #M64_CRTC_GEN_CNTL+3,d0
		bsr        write_vga_byte
		bsr        enable_vga
		/* Enable VGA mode */
		move.b     #1,VIDSUB(a3)
		bsr        set_iobase
		clr.b      70(a2)
		clr.b      69(a2)
		lea.l      x11824+mach64_off,a4
		cmpi.w     #1,38(a2)
		bne.s      x11244_3
		move.b     #1,x11825-x11824(a4)
		move.b     #1,atc_data+18-x11824(a4)  /* value for Color Plane Enable Register */
		bra.s      x11244_4
x11244_3:
		move.b     #$0F,x11825-x11824(a4)
		move.b     #$0F,atc_data+18-x11824(a4)  /* value for Color Plane Enable Register */
x11244_4:
		andi.b     #$F7,x11827-x11824(a4)
		andi.b     #$BF,x1182f-x11824(a4)
		andi.b     #$F7,(a4)
		moveq.l    #1,d0
		and.b      55(a2),d0
		beq.s      x11244_5
		ori.b      #$08,(a4)
x11244_5:
		andi.b     #$4F,x11849-x11824(a4)
		andi.b     #$BE,x11829-x11824(a4)
		move.b     #$FF,atc_data+17-x11824(a4) /* value for Overscan Color Register */
		movea.l    a3,a0
		bsr        reset_sequencer
		moveq.l    #4,d2
		moveq.l    #1,d1
		movea.l    a4,a1
		move.w     #TS_I,d0
		movea.l    a3,a0
		bsr        write_idx_reg
		move.b     56(a2),MISC_W(a3)
		move.b     #$11,CRTC_I(a3)		/* Select Vertical Retrace End Register */
		andi.b     #$7F,CRTC_D(a3)		/* unprotect timing registers */
		ori.b      #$10,64(a2)
		/* write all timing registers */
		moveq.l    #25,d2
		clr.b      d1
		lea.l      57(a2),a1
		move.w     #CRTC_I,d0
		movea.l    a3,a0
		bsr        write_idx_reg
		move.b     #$86,ATI_I(a3)
		move.b     #$7A,ATI_D(a3)
		move.b     #$A3,ATI_I(a3)
		clr.b      ATI_D(a3)
		move.b     #$AD,ATI_I(a3)
		clr.b      ATI_D(a3)
		move.b     #$AE,ATI_I(a3)
		clr.b      ATI_D(a3)
		move.b     #$B0,ATI_I(a3)
		move.b     #$08,ATI_D(a3)
		move.b     #$B1,d0
		bra.s      x11244_6
x11244_7:
		move.b     d0,ATI_I(a3)
		clr.b      ATI_D(a3)
		addq.b     #1,d0
x11244_6:
		cmp.b      #$B5,d0
		bls.s      x11244_7
		move.b     #$B6,ATI_I(a3)
		move.b     #1,ATI_D(a3)
		move.b     #$B8,ATI_I(a3)
		clr.b      ATI_D(a3)
		move.b     #$BD,ATI_I(a3)
		move.b     #$04,ATI_D(a3)
		move.b     #$BE,ATI_I(a3)
		moveq.l    #4,d0
		and.w      22(a7),d0
		beq.s      x11244_8
		move.b     #$0A,ATI_D(a3)
		bra.s      x11244_9
x11244_8:
		move.b     #$08,ATI_D(a3)
x11244_9:
		move.b     #$BF,ATI_I(a3)
		move.b     #1,ATI_D(a3)
		moveq.l    #9,d2
		clr.b      d1
		lea.l      x1182a-x11824(a4),a1
		move.w     #GDC_I,d0
		movea.l    a3,a0
		bsr        write_idx_reg
		movea.l    a3,a0
		bsr.w      write_atcregs
		move.b     #$FF,MEM_CFG(a3)
		clr.w      d1
		move.b     85(a2),d1
		and.w      #$0080,d1
		move.w     20(a7),d0
		bsr.w      selectclock
		move.b     dactype+mach64_off,d0
		bne.s      x11244_10
		moveq.l    #5,d0
		bsr        x10496
x11244_10:
		lea.l      28(a7),a7
		movem.l    (a7)+,a2-a4
		rts

x11444:
		move.l     d3,-(a7)
		move.l     d4,-(a7)
		move.b     12(a7),d3
		cmp.b      d2,d3
		blt.s      x11444_1
		move.b     d3,d4
		sub.b      d2,d4
		lsl.w      d4,d0
		bra.s      x11444_2
x11444_1:
		move.b     d2,d4
		sub.b      d3,d4
		lsr.w      d4,d0
x11444_2:
		clr.w      d2
		dc.w $1430,$11b0		/* move.b     (x118a4+mach64_off,d1.w),d2 68020+ only */
		dc.l x118a4+mach64_off
		lsl.w      d3,d2
		and.w      d2,d0
		move.l     (a7)+,d4
		move.l     (a7)+,d3
		rts

/*
 * Write multiple ATC registers.
 * 
 * Input:  a0.l = register base
 *         values to be written in atc_data
 * Output: -
 * Clobbers: a1,d0
 */
write_atcregs:
		lea.l      atc_data+mach64_off,a1
		move.b     IS1_RC(a0),d0			/* set ATC_IW to index */
		clr.b      d0
		bra.s      write_atcregs_1
write_atcregs_2:
		move.b     d0,ATC_IW(a0)
		move.b     (a1)+,ATC_IW(a0)         /* ATC uses same port for data */
		addq.b     #1,d0
write_atcregs_1:
		cmp.b      #20,d0
		ble.s      write_atcregs_2
		move.b     #$20,ATC_IW(a0)          /* enable screen output */
		rts

/* 
 * Input:  d0.w = frequency index
 *         d1.w = interlace
 * Output: -
 * Clobbers: d0,d1,d2,d4,a0,a1,a2
 */
selectclock:
		move.l     a2,-(a7)
		move.w     d0,d2
		add.w      d2,d2
		add.w      d0,d2
		addq.w     #2,d2
		move.w     d2,d0
		lea.l      vga_reg_ptr+mach64_off,a0
		movea.l    (a0),a1
		clr.b      TS_I(a1)			/* select reset register */
		movea.l    (a0),a1
		move.b     #1,TS_D(a1)		/* stop sequencer */

		movea.l    (a0),a1
		move.b     #$B9,ATI_I(a1)	/* select ATI register $39 */
		lea.l      clocktab+mach64_off,a1
		moveq.l    #$04,d2
		dc.w $c471,$0200			/* and.w      0(a1,d0.w*2),d2 68020+ only */
		asr.w      #1,d2
		or.b       #$40,d2			/* set 16bit I/O */
		movea.l    (a0),a2
		move.b     d2,ATI_D(a2)		/* write bit #3 of clock select */

		movea.l    (a0),a2
		move.b     #$B8,ATI_I(a2)	/* select Clock Select register */
		moveq.l    #$10,d2
		dc.w $c431,$0201			/* and.b      1(a1,d0.w*2),d2 68020+ only */
		lsl.b      #2,d2
		movea.l    (a0),a2
		move.b     d2,ATI_D(a2)		/* write clock divider */

		movea.l    (a0),a2
		move.b     #$BE,ATI_I(a2)
		moveq.l    #$08,d2
		dc.w $c431,$0201 			/* and.b      1(a1,d0.w*2),d2 68020+ only */
		add.b      d2,d2
		move.b     d2,-(a7)
		tst.w      d1
		beq.s      selectclock_1
		moveq.l    #1,d2
		bra.s      selectclock_2
selectclock_1:
		clr.w      d2
selectclock_2:
		add.b      d2,d2
		or.b       (a7)+,d2
		movea.l    (a0),a2
		move.b     d2,ATI_D(a2)		/* write bit #2 of clock select */

		movea.l    (a0),a2
		move.b     R_GENMO(a2),d1
		and.b      #$F3,d1
		moveq.l    #3,d2
		dc.w $c431,$0201			/* and.b      1(a1,d0.w*2),d2 68020+ only */
		lsl.b      #2,d2
		or.b       d2,d1
		move.b     d1,MISC_W(a2)	/* write bit #0-1 of clock select */
		movea.l    (a0),a1
		clr.b      TS_I(a1)			/* select reset register */
		movea.l    (a0),a1
		move.b     #3,TS_D(a1)		/* enable sequencer again */
		movea.l    (a7)+,a2
		rts

m64_get_daci:
		move.b     M64_DAC_W_INDEX(a0),d0
		rts

x11544:
		clr.b      d0
		bra.s      x11544_1
x11544_4:
		clr.w      d1
		bra.s      x11544_2
x11544_3:
		addq.w     #1,d1
x11544_2:
		cmp.w      #1000,d1
		blt.s      x11544_3
		move.b     MEM_CFG(a0),d2
		addq.b     #1,d0
x11544_1:
		cmp.b      #4,d0
		bcs.s      x11544_4
		move.b     d2,d0
		rts

x11564:
		movem.l    d3-d7/a2,-(a7)
		subq.w     #4,a7
		clr.w      (a7)
		movea.l    #vga_reg+$8000,a2
		movea.l    a2,a0
		bsr        x116bc
		move.b     d0,d4
		move.b     MEM_CFG(a2),d5
		move.b     d4,d6
		not.b      d6
		move.b     d6,MEM_CFG(a2)
		movea.l    a2,a0
		bsr        x116aa
		move.b     MEM_CFG(a2),d7
		clr.b      d3
		cmp.b      d7,d6
		bne.s      x11564_1
		movea.l    a2,a0
		bsr.w      m64_get_daci
		bra        x11564_2
x11564_1:
		move.b     #$E0,d0
		movea.l    a2,a0
		bsr        x116d8
		movea.l    a2,a0
		bsr        x116aa
		move.b     MEM_CFG(a2),d7
		and.b      #$E0,d7
		moveq.l    #1,d3
		cmp.b      #$E0,d7
		bne        x11564_3
		moveq.l    #96,d0
		movea.l    a2,a0
		bsr        x116d8
		movea.l    a2,a0
		bsr        x116aa
		move.b     MEM_CFG(a2),d7
		and.b      #$E0,d7
		moveq.l    #3,d3
		move.b     d4,d0
		movea.l    a2,a0
		bsr        x116d8
		tst.b      d7
		beq        x11564_2
		movea.l    a2,a0
		bsr        x116aa
		move.b     MEM_CFG(a2),d7
		move.b     MEM_CFG(a2),d7
		cmp.b      d7,d6
		bne.s      x11564_4
		move.b     #$FF,d0
		movea.l    a2,a0
		bsr        x116d8
		movea.l    a2,a0
		bsr        x116aa
		move.b     MEM_CFG(a2),d7
		moveq.l    #4,d3
		move.b     d7,d0
		and.b      #$F0,d0
		beq.s      x11564_5
		moveq.l    #3,d3
x11564_5:
		move.b     d7,d0
		movea.l    a2,a0
		bsr        x116d8
		bra.s      x11564_2
x11564_4:
		movea.l    a2,a0
		bsr        x11544
		move.b     d0,d7
		moveq.l    #6,d3
		cmp.b      d0,d6
		beq.s      x11564_3
		movea.l    a2,a0
		bsr        m64_get_daci
		move.b     #$FF,MEM_CFG(a2)
		movea.l    a2,a0
		bsr        x11544
		move.b     d0,d7
		moveq.l    #7,d3
		cmp.b      #$8E,d0
		beq.s      x11564_3
		moveq.l    #8,d3
		cmp.b      #$82,d0
		beq.s      x11564_3
		cmp.b      #$44,d0
		beq.s      x11564_3
		move.b     d4,d2
		move.b     d5,d1
		movea.l    a2,a0
		move.b     #$EF,d0
		bsr        x116f4
		move.w     d0,d7
		moveq.l    #5,d3
		tst.b      d7
		bne.s      x11564_3
		move.b     d4,d2
		move.b     d5,d1
		move.b     #$FB,d0
		movea.l    a2,a0
		bsr.w      x116f4
		move.w     d0,d7
		moveq.l    #9,d3
		tst.b      d7
		bne.s      x11564_3
		moveq.l    #2,d3
x11564_3:
		move.b     d4,d0
		movea.l    a2,a0
		bsr.w      x116d8
x11564_2:
		move.b     d7,MEM_CFG(a2)
		clr.w      d0
		move.b     d3,d0
		move.w     d0,(a7)
		move.b     #$FF,MEM_CFG(a2)
		addq.w     #4,a7
		movem.l    (a7)+,d3-d7/a2
		rts

x116aa:
		move.l     a2,-(a7)
		movea.l    a0,a2
		bsr        m64_get_daci
		movea.l    a2,a0
		bsr        x11544
		movea.l    (a7)+,a2
		rts

x116bc:
		move.l     d3,-(a7)
		move.l     a2,-(a7)
		movea.l    a0,a2
		bsr.w      x116aa
		move.b     MEM_CFG(a2),d3
		movea.l    a2,a0
		bsr        m64_get_daci
		move.b     d3,d0
		movea.l    (a7)+,a2
		move.l     (a7)+,d3
		rts

x116d8:
		move.l     d3,-(a7)
		move.l     a2,-(a7)
		movea.l    a0,a2
		move.b     d0,d3
		bsr.w      x116aa
		move.b     d3,MEM_CFG(a2)
		movea.l    a2,a0
		bsr        m64_get_daci
		movea.l    (a7)+,a2
		move.l     (a7)+,d3
		rts

x116f4:
		movem.l    d3-d5/a2,-(a7)
		movea.l    a0,a2
		move.b     d0,d4
		move.b     d1,d3
		move.b     d2,d5
		bsr        m64_get_daci
		move.b     d4,d0
		and.b      d3,d0
		move.b     d0,MEM_CFG(a2)
		movea.l    a2,a0
		bsr.w      x116aa
		move.b     d4,d0
		not.b      d0
		or.b       d5,d0
		move.b     d0,MEM_CFG(a2)
		move.b     d0,d0
		move.b     d4,d1
		and.b      d0,d1
		move.b     d1,MEM_CFG(a2)
		tst.b      d4
		bne.s      x116f4_1
		moveq.l    #1,d2
		bra.s      x116f4_2
x116f4_1:
		clr.w      d2
x116f4_2:
		clr.w      d1
		move.b     d0,d1
		and.w      d1,d2
		beq.s      x116f4_3
		moveq.l    #1,d3
		bra.s      x116f4_4
x116f4_3:
		clr.w      d3
x116f4_4:
		move.w     d3,d0
		movem.l    (a7)+,d3-d5/a2
		rts

x11746:
		move.l     d3,-(a7)
		move.l     d4,-(a7)
		move.w     #$270F,d1
		clr.w      d2
		lea.l      clocktab+mach64_off,a0
		bra.s      x11746_1
x11746_7:
		move.w     d2,d4
		add.w      d4,d4
		add.w      d2,d4
		add.w      d4,d4			/* d4 = d2 * 6 */
		move.w     0(a0,d4.w),d4
		sub.w      d0,d4
		bpl.s      x11746_2
		move.w     d2,d4
		add.w      d4,d4
		add.w      d2,d4
		add.w      d4,d4			/* d4 = d2 * 6 */
		move.w     0(a0,d4.w),d4
		neg.w      d4
		sub.w      d0,d4
		bra.s      x11746_3
x11746_2:
		move.w     d2,d4
		add.w      d4,d4
		add.w      d2,d4
		add.w      d4,d4			/* d4 = d2 * 6 */
		move.w     0(a0,d4.w),d4
		sub.w      d0,d4
x11746_3:
		cmp.w      d4,d1
		ble.s      x11746_4
		move.w     d2,d1
		add.w      d1,d1
		add.w      d2,d1
		add.w      d1,d1			/* d1 = d2 * 6 */
		move.w     0(a0,d1.w),d4
		sub.w      d0,d4
		bpl.s      x11746_5
		move.w     0(a0,d1.w),d1
		neg.w      d1
		sub.w      d0,d1
		bra.s      x11746_6
x11746_5:
		move.w     d2,d4
		add.w      d4,d4
		add.w      d2,d4
		add.w      d4,d4			/* d4 = d2 * 6 */
		move.w     0(a0,d4.w),d1
		sub.w      d0,d1
x11746_6:
		move.w     d2,d3
x11746_4:
		addq.w     #1,d2
x11746_1:
		cmp.w      #14,d2
		blt.s      x11746_7
		move.w     d3,d0
		move.l     (a7)+,d4
		move.l     (a7)+,d3
		rts

/* .data */

vga_palette:
		dc.b $ff,$ff,$ff
		dc.b $00,$00,$00
/* unused */
		dc.b $ff,$ff

x117ce:
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0000
		dc.w $0001
		dc.w $0050
		dc.w $0001
		dc.w $0002
		dc.w $0001
		dc.w $027f
		dc.w $018f
		dc.w $027f
		dc.w $018f
		dc.w $0019
		dc.w $8000
		dc.w $635f
		dc.w $4f50
		dc.w $8254
		dc.w $80bf
		dc.w $1f00
		dc.w $4000
		dc.w $0000
		dc.w $0000
		dc.w $009c
		dc.w $0e8f
		dc.w $2800
		dc.w $e704
		dc.w $c3ff
		dc.w $0000
		dc.w $0000

x11824: dc.b $01
x11825: dc.b $0f
x11826: dc.b $00
x11827: dc.b $06
        dc.b $00
x11829: dc.b $b4
x1182a: dc.b $00,$00
		dc.b $00,$00
		dc.b 0
x1182f: dc.b 0
        dc.b $01,$0f
        dc.b $ff

atc_data:
		dc.b $00  /* internal palette index #0 */
        dc.b $01  /* internal palette index #1 */
        dc.b $02  /* internal palette index #2 */
		dc.b $03  /* internal palette index #3 */
        dc.b $04  /* internal palette index #4 */
		dc.b $05  /* internal palette index #5 */
		dc.b $06  /* internal palette index #6 */
		dc.b $07  /* internal palette index #7 */
		dc.b $08  /* internal palette index #8 */
		dc.b $09  /* internal palette index #9 */
		dc.b $0a  /* internal palette index #10 */
		dc.b $0b  /* internal palette index #11 */
		dc.b $0c  /* internal palette index #12 */
		dc.b $0d  /* internal palette index #13 */
		dc.b $0e  /* internal palette index #14 */
		dc.b $0f  /* internal palette index #15 */
		dc.b $01  /* Attribute Mode Control Register */
        dc.b $ff  /* Overscan Color Register */
		dc.b $0f  /* Color Plane Enable Register */
		dc.b $10  /* Horizontal Pixel Panning Register */
		dc.b $00  /* Color Select Register */
		dc.b $05  /* unused */

x11849:	dc.b $00
		dc.b $ff,$ff
		dc.b $ff,$00

		even
clocktab:
			dc.w $0019,$0000,$0010
			dc.w $001c,$0000,$0011
			dc.w $0020,$0000,$0012
			dc.w $0024,$0000,$0013
			dc.w $0028,$0000,$0004
			dc.w $002d,$0000,$0005
			dc.w $0032,$0000,$0007
			dc.w $0039,$0000,$0001
			dc.w $0041,$0000,$000f
			dc.w $004b,$0000,$000e
			dc.w $0050,$0000,$000d
			dc.w $006e,$0000,$000a
			dc.w $007e,$0000,$000a
			dc.w $0087,$0000,$000b

x118a2: 	dc.w $0598
x118a4:		dc.w $0001
			dc.w $0307
			dc.w $0f1f
			dc.w $3f7f
			dc.w $ff00
x118ae: 	dc.w $0001

x118b0: 	dc.w M64_BUS_CNTL+2,$890e
			dc.w M64_CRTC_INT_CNTL,$0000
			dc.w M64_CRTC_GEN_CNTL,$0200
			dc.w M64_GEN_TEST_CNTL,$0000
			dc.w M64_GEN_TEST_CNTL+2,$0000
			dc.w M64_MEM_CNTL,$01f0
			dc.w ROM_ADDR_1,$0000
			dc.w M64_SCRATCH_REG0,$0000
			dc.w M64_SCRATCH_REG0+2,$0000
			dc.w M64_SCRATCH_REG_1,$0000
			dc.w M64_SCRATCH_REG_1+2,$0000
			dc.w M64_DAC_CNTL,$0000
			dc.w M64_CONFIG_CTRL,$0011
			dc.w 0,0           /* end of table */

x118e8:		dc.w $000e,$c848
			dc.w $0019,$831b
			dc.w $001b,$873d
			dc.w $001c,$8847
			dc.w $001e,$8322
			dc.w $0020,$8850
			dc.w $0022,$853a
			dc.w $0024,$4311
			dc.w $0026,$4622
			dc.w $0028,$4830
			dc.w $002c,$4523
			dc.w $002f,$462c
			dc.w $0030,$4319
			dc.w $0032,$431b
			dc.w $0034,$4632
			dc.w $0037,$473d
			dc.w $0039,$4847
			dc.w $003c,$4322
			dc.w $003f,$4850
			dc.w $0041,$4853
			dc.w $0044,$453a
			dc.w $0048,$0311
			dc.w $004b,$0622
			dc.w $004d,$0623
			dc.w $0050,$0830
			dc.w $0058,$0523
			dc.w $005a,$062a
			dc.w $005f,$0319
			dc.w $0064,$0422
			dc.w $0069,$073a
			dc.w $006c,$073c
			dc.w $006e,$073d
			dc.w $0076,$0219
			dc.w $0078,$0322
			dc.w $0083,$0538
			dc.w $0087,$0526
			dc.w $03e7,$0000

x1197c:		dc.w $13ab
			dc.w $1620
			dc.w $189c
			dc.w $1c20
			dc.w $0fa0
			dc.w $118a
			dc.w $1356
			dc.w $1388
			dc.w $0000
			dc.w $2af8
			dc.w $3138
			dc.w $34bc
			dc.w $0000
			dc.w $1f40
			dc.w $1d4c
			dc.w $1964
			dc.w $157c
			dc.w $157c
			dc.w $157c
			dc.w $157c

x119a4:		dc.w $0163
			dc.w $8261
			dc.w $8361
			dc.w $b060
			dc.w $b160
			dc.w $d060
			dc.w $f360

x119b2:		dc.w $8061
x119b4:		dc.w $ff00
			dc.w $0002
			dc.w $0309
			dc.w $0005
x119bc:		dc.w $0c04
			dc.w $0416
			dc.w $36e6
			dc.w $e624
x119c4:		dc.w $0c04
			dc.w $0416
			dc.w $36b6
			dc.w $b624
			dc.w $0006
			dc.w $0006
			dc.w $000c
			dc.w $000c
			dc.w $000c
			dc.w $000c
			dc.w $000c
			dc.w $000c
			dc.w $020c
			dc.w $0206
			dc.w $020e
			dc.w $020e
			dc.w $020e
			dc.w $020e
			dc.w $020e
			dc.w $020e
			dc.w $020e
			dc.w $020e
			dc.w $020e
			dc.w $020e
			dc.w $020e
			dc.w $020e
			dc.w $020e

/* .bss */

x119fa:      ds.l 1
x119fe:      ds.w 1
x11a00:      ds.w 1
x11a02:      ds.w 1
x11a04:      ds.w 1
x11a06:      ds.l 1
x11a0a:      ds.w 1
x11a0c:      ds.w 1
dactype:     ds.b 1
        even
x11a10:      ds.b 1 /* unused? */
x11a11:      ds.b 1
x11a12:      ds.b 1
        even
vga_reg_ptr: ds.l 1
x11a18:      ds.b 28 /* unused? */

#if BINEXACT
	/* fill up space between here and start of isa emulation */
	dcb.b mach64_init+$2000-*,-1
#endif

#endif
