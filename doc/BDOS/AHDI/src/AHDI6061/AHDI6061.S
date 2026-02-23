USEWRONG          equ 0			;use old and wrong logical LRECNO
					;calculation
                  MC68030		;use 68030 command set
                  OPT a+,b+,c+,l+,m+,p+,q+,v+,s+,t+,z+
RESET_SSP         equ $00000000 
RESET_PC          equ $00000004 
BUS_ERR           equ $00000008 
ADR_ERR           equ $0000000C 
ILLE_EXC          equ $00000010 
DIV0_EXC          equ $00000014 
CHK_EXC           equ $00000018 
TRAPV_EXC         equ $0000001C 
PRIV_EXC          equ $00000020 
TRAC_EXC          equ $00000024 
LINEA_EXC         equ $00000028 
LINEF_EXC         equ $0000002C 
NOINI_EXC         equ $0000003C 
FALSI_EXC         equ $00000060 
AUT1_EXC          equ $00000064 
AUT2_EXC          equ $00000068 
AUT3_EXC          equ $0000006C 
AUT4_EXC          equ $00000070 
AUT5_EXC          equ $00000074 
AUT6_EXC          equ $00000078 
AUT7_EXC          equ $0000007C 
TR0_EXC           equ $00000080 
TR1_EXC           equ $00000084 
TR2_EXC           equ $00000088 
TR3_EXC           equ $0000008C 
TR4_EXC           equ $00000090 
TR5_EXC           equ $00000094 
TR6_EXC           equ $00000098 
TR7_EXC           equ $0000009C 
TR8_EXC           equ $000000A0 
TR9_EXC           equ $000000A4 
TRA_EXC           equ $000000A8 
TRB_EXC           equ $000000AC 
TRC_EXC           equ $000000B0 
TRD_EXC           equ $000000B4 
TRE_EXC           equ $000000B8 
TRF_EXC           equ $000000BC 
ETV_TIMER         equ $00000400 
ETV_CRITIC        equ $00000404 
ETV_TERM          equ $00000408 
ETV_XTRA          equ $0000040C 
MEMVALID          equ $00000420 
MEMCNTLR          equ $00000424 
RESVALID          equ $00000426 
RESVECTOR         equ $0000042A 
PHYSTOP           equ $0000042E 
_MEMBOT           equ $00000432 
_MEMTOP           equ $00000436 
MEMVAL2           equ $0000043A 
FLOCK             equ $0000043E 
SEEKRATE          equ $00000440 
_TIMR_MS          equ $00000442 
_FVERIFY          equ $00000444 
_BOOTDEV          equ $00000446 
PALMODE           equ $00000448 
DEFSHIFTMD        equ $0000044A 
SSHIFTMD          equ $0000044C 
_V_BAS_AD         equ $0000044E 
VBLSEM            equ $00000452 
NVBLS             equ $00000454 
_VBLQUEUE         equ $00000456 
COLORPTR          equ $0000045A 
SCREENPT          equ $0000045E 
_VBCLOCK          equ $00000462 
_FRCLOCK          equ $00000466 
HDV_INIT          equ $0000046A 
SWV_VEC           equ $0000046E 
HDV_BPB           equ $00000472 
HDV_RW            equ $00000476 
HDV_BOOT          equ $0000047A 
HDV_MEDIACH       equ $0000047E 
_CMDLOAD          equ $00000482 
CONTERM           equ $00000484 
TRP14RET          equ $00000486 
CRITICRET         equ $0000048A 
THEMD             equ $0000048E 
_____MD           equ $0000049E 
SAVPTR            equ $000004A2 
_NFLOPS           equ $000004A6 
CON_STATE         equ $000004A8 
SAVE_ROW          equ $000004AC 
SAV_CONTEXT       equ $000004AE 
_BUFL1            equ $000004B2 
_BUFL2            equ $000004B6 
_HZ_200           equ $000004BA 
TH_ENV            equ $000004BC 
_DRVBITS          equ $000004C2 
_DSKBUFP          equ $000004C6 
_AUTOPATH         equ $000004CA 
_VBL_LIST         equ $000004CE 
_DUMPFLG          equ $000004EE 
_PRTABT           equ $000004F0 
_SYSBASE          equ $000004F2 
_SHELL_P          equ $000004F6 
END_OS            equ $000004FA 
EXEC_OS           equ $000004FE 
SCR_DUMP          equ $00000502 
PRV_LSTO          equ $00000506 
PRV_LST           equ $0000050A 
PRV_AUXO          equ $0000050E 
PRV_AUX           equ $00000512 
A_INIT            equ $0000A000 
A_PUTPIX          equ $0000A001 
A_GETPIX          equ $0000A002 
A_ABLINE          equ $0000A003 
A_HABLINE         equ $0000A004 
A_RECTFILL        equ $0000A005 
A_POLYFILL        equ $0000A006 
A_BITBLT          equ $0000A007 
A_TEXTBLT         equ $0000A008 
A_SHOWCUR         equ $0000A009 
A_HIDECUR         equ $0000A00A 
A_CHGCUR          equ $0000A00B 
A_DRSPRITE        equ $0000A00C 
A_UNSPRITE        equ $0000A00D 
A_COPYRSTR        equ $0000A00E 
A_SEEDFILL        equ $0000A00F 
MEMCONF           equ $FFFF8001 
DBASEH            equ $FFFF8201 
DBASEL            equ $FFFF8203 
VCOUNTHI          equ $FFFF8205 
VCOUNTMID         equ $FFFF8207 
VCOUNTLOW         equ $FFFF8209 
SYNCMODE          equ $FFFF820A 
COLOR0            equ $FFFF8240 
COLOR1            equ $FFFF8242 
COLOR2            equ $FFFF8244 
COLOR3            equ $FFFF8246 
COLOR4            equ $FFFF8248 
COLOR5            equ $FFFF824A 
COLOR6            equ $FFFF824C 
COLOR7            equ $FFFF824E 
COLOR8            equ $FFFF8250 
COLOR9            equ $FFFF8252 
COLOR10           equ $FFFF8254 
COLOR11           equ $FFFF8256 
COLOR12           equ $FFFF8258 
COLOR13           equ $FFFF825A 
COLOR14           equ $FFFF825C 
COLOR15           equ $FFFF825E 
SHIFTMD           equ $FFFF8260 
DISKCTL           equ $FFFF8604 
FIFO              equ $FFFF8606 
DMAHIGH           equ $FFFF8609 
DMAMID            equ $FFFF860B 
DMALOW            equ $FFFF860D 
GIREAD            equ $FFFF8800 
GIWRITE           equ $FFFF8802 
GPIP              equ $FFFFFA01 
AER               equ $FFFFFA03 
DDR               equ $FFFFFA05 
IERA              equ $FFFFFA07 
IERB              equ $FFFFFA09 
IPRA              equ $FFFFFA0B 
IPRB              equ $FFFFFA0D 
ISRA              equ $FFFFFA0D 
ISRB              equ $FFFFFA11 
IMRA              equ $FFFFFA13 
IMRB              equ $FFFFFA15 
VR                equ $FFFFFA17 
TACR              equ $FFFFFA19 
TBCR              equ $FFFFFA1B 
TCDCR             equ $FFFFFA1D 
TADR              equ $FFFFFA1F 
TBDR              equ $FFFFFA21 
TCDR              equ $FFFFFA23 
TDDR              equ $FFFFFA25 
SCR               equ $FFFFFA27 
UCR               equ $FFFFFA29 
RSR               equ $FFFFFA2B 
TSR               equ $FFFFFA2D 
UDR               equ $FFFFFA2F 
KEYCTL            equ $FFFFFC00 
KEYBD             equ $FFFFFC02 
MIDICTL           equ $FFFFFC04 
MIDI              equ $FFFFFC06 
PUN_PTR           equ $00000516 
L0000             equ Begin-$1B15B6 
Begin:            text
L0001:            bra       _START
L0002             equ       *-2 
                  bra       L0012 
                  bra       L0012 
                  dc.b      $F0,$AD,$05,$00 
L0003:            dc.b      $00,$80 
L0004:            dc.b      $02,$00,$00,$08 
L0005:            dc.b      $01,$01,$01,$01,$01,$01,$01,$01 
                  ds.w      2,0 
                  dc.b      $00,$08 
L0006:            dc.b      $01,$01,$01,$01,$01,$01,$01,$01 
L0007:            dc.b      $00,$00,'.',$E1,$00,$00,$13,$88 
                  dc.b      $00,$00,$00,'*' 
L0008:            dc.b      $00,$00,$00,$C9 
L0009:            dc.b      $00,$00,$00,'3' 
L000A:            dc.b      $00,$00,$03,'!' 
L000B:            dc.b      $00,$00 
L000C:            dc.b      $00 
L000D:            dc.b      $FF 
L000E:            dc.b      $FF 
L000F:            dc.b      $01 
PUNINF_BLIT_USE:  dc.b      $01,$00 
_START:           movea.l   4(a7),a2
                  move.b    128(a2),L004D 
                  move.l    4(a2),d0
                  sub.l     (a2),d0 
                  sub.l     #$100,d0
                  bra       _INSTALL
L0012:            st        L0025 
                  sub.l     #$1C,d0 
                  move.l    a2,L0027
                  bra       _INSTALL
                  dc.b      $D
                  dc.b      'AHDI : July 31 1992 v6.00',$D,$A 
                  dc.b      '½Atari Corp. 1985, 1986, 1987, 1988, 198'
                  dc.b      '9, 1990, 1991, 1992',$D,$A 
                  dc.b      0,$1A,0 
PUN_INFO:         dc.b      $00,$00,$FF,$FF 
L0014:            dc.w      $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 
                  dc.w      $0000,$0000,$0000 
L0015:            dc.l      $00000000,$00000000,$00000000,$00000000 
                  dc.l      $00000000,$00000000,$00000000,$00000000 
                  dc.l      $00000000,$00000000,$00000000,$00000000 
                  dc.l      $00000000,$00000000 
L0016:            dc.b      'AHDI'
L0017:            dc.l      $00000000 
                  dc.b      $06,$00 
MAX_SECTOR:       dc.b      $02,$00 
                  dc.w      $0000,$0000 
PUN_RSVD:         dc.w      $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 
                  dc.w      $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 
                  dc.w      $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 
                  dc.w      $0000,$0000,$0000,$0000,$0000,$0000 
L001A:            dc.w      $0000 
L001B:            dc.w      $0000 
L001C:            dc.b      $02,$02,$02,$02,$02,$02,$02,$02 
                  dc.b      $02,$02,$02,$02,$02,$02 
L001D:            dc.b      $01,$01,$01,$01,$01,$01,$01,$01 
                  dc.b      $01,$01,$01,$01,$01,$01 
L001E:            ds.w      2,0 
L001F:            ds.w      9,0 
L0020:            ds.w      21,0
L0021:            dc.b      $01,$01,$01,$01,$01,$01,$01,$01 
                  dc.b      $01,$01,$01,$01,$01,$01 
L0022:            ds.w      448,0 
L0023:            ds.w      14,0
L0024:            ds.w      14,0
L0025:            dc.b      $00,$00 
L0026:            ds.w      2,0 
L0027:            ds.w      2,0 
L0028:            ds.w      2,0 
L0029:            ds.w      2,0 
_CURR_DEV:        dc.b      $00 
L002B:            dc.b      $00 
L002C:            dc.b      $00,$00 
L002D:            dc.b      $00,$00 
_CURR_LRECNO:     ds.w      2,0 
_CURR_LASTRECNO:  ds.w      2,0 
_CURR_BUF:        ds.w      2,0 
L0031:            dc.b      $00,$00 
L0032:            ds.w      2,0 
L0033:            dc.b      $00,$03 
L0034:            dc.b      $00,$01 
OLD_BPB:          dc.b      $00,$00,$00,$01 
OLD_RW:           dc.b      $00,$00,$00,$01 
OLD_MEDIACH:      dc.b      $00,$00,$00,$01 
L0038:            ds.w      16,0
L0039:            ds.w      2,0 
_SEC0_BUF:        ds.w      2,0 
L003B:            dc.b      $00,$00 
L003C:            dc.b      $00,$00 
L003D:            dc.b      $00 
L003E:            dc.b      $01 
L003F:            ds.w      2,0 
_CURR_LASTOFPART: dc.b      $00,$00 
L0041:            dc.b      $00,$00 
L0042:            dc.b      $00 
L0043:            dc.b      $00 
L0044:            dc.b      $00,$00 
L0045:            ds.w      28,0
L0046:            dc.b      $00,$00,$00,$01 
FLG_CPU030:       dc.b      $00 
FLG_BLIT_USE:     dc.b      $00 
L0049:            dc.b      $00,$00 
L004A:            ds.w      2,0 
L004B:            ds.w      2,0 
L004C:            dc.b      $00,$00 
L004D:            dc.b      $00 
L004E:            dc.b      $00 
NEW_BPB:          move.w    4(a7),d0
                  clr.w     d1
                  movea.l   OLD_BPB,a0
                  lea       _DO_BPB(pc),a1
                  bra.s     _RW_CHKDEV
NEW_RW:           move.w    14(a7),d0 
                  move.w    4(a7),d1
                  movea.l   OLD_RW,a0 
                  lea       _DO_RW(pc),a1 
                  bra.s     _RW_CHKDEV
NEW_MEDIACH:      move.w    4(a7),d0
                  clr.w     d1
                  movea.l   OLD_MEDIACH,a0
                  lea       _DO_MEDIACH(pc),a1
_RW_CHKDEV:       subq.w    #2,d0 
                  bmi.s     _USE_OLD_VEC
                  btst      #3,d1 
                  beq.s     _PHYS_MODE
                  cmp.w     #7,d0 
                  bgt.s     _CHK4SCSI 
                  tst.w     L001A 
                  bne.s     _USE_NEW_VEC
_CHK4SCSI:        cmp.w     #$F,d0
                  bgt.s     _CHK4IDE
                  tst.w     L001B 
                  bne.s     _USE_NEW_VEC
_CHK4IDE:         cmp.w     #$10,d0 
                  bgt.s     _USE_OLD_VEC
                  move.w    PUN_INFO,d1 
                  sub.w     L001A,d1
                  sub.w     L001B,d1
                  tst.w     d1
                  bne.s     _USE_NEW_VEC
                  bra.s     _USE_OLD_VEC
_PHYS_MODE:       cmp.w     #$E,d0
                  bge.s     _USE_OLD_VEC
                  lea       L0014,a2
                  tst.b     0(a2,d0.w)
                  bmi.s     _USE_OLD_VEC
_USE_NEW_VEC:     movea.l   a1,a0 
_USE_OLD_VEC:     jmp       (a0)
_DO_BPB:          subq.w    #2,4(a7)
                  move.w    4(a7),d1
                  lea       L0014,a0
                  adda.w    d1,a0 
                  moveq     #0,d2 
                  move.b    (a0),d2 
                  move.w    d2,_CURR_DEV
                  lea       L001D,a1
                  tst.b     0(a1,d1.w)
                  bne.s     L0059 
                  movem.l   a0/d1,-(a7) 
                  move.w    d2,-(a7)
                  bsr       L0151 
                  addq.l    #2,a7 
                  movem.l   (a7)+,a0/d1 
                  tst.w     d0
                  beq       L0062 
                  moveq     #1,d0 
                  bsr       L00DA 
L0059:            move.l    _DSKBUFP.s,_SEC0_BUF
                  addi.l    #$200,_SEC0_BUF 
_R_SEC0:          move.l    a0,-(a7)
                  move.w    _CURR_DEV,-(a7) 
                  addq.w    #2,(a7) 
                  clr.w     -(a7) 
                  move.w    #1,-(a7)
                  move.l    _SEC0_BUF,-(a7) 
                  move.w    #$A,-(a7) 
                  bsr       _DO_RW
                  adda.w    #$C,a7
                  movea.l   (a7)+,a0
                  tst.w     d0
                  beq.s     L005B 
                  move.l    a0,-(a7)
                  move.w    8(a7),d1
                  bsr       _DO_CRIT_ERR
                  movea.l   (a7)+,a0
                  cmpi.l    #$10000,d0
                  beq.s     _R_SEC0 
                  bra       L0062 
L005B:            move.w    _CURR_DEV,d2
                  move.w    #0,L004C
L005C:            cmp.b     -(a0),d2
                  bne.s     L005D 
                  addq.w    #1,L004C
                  bra.s     L005C 
L005D:            move.w    #3,d1 
                  movea.l   _SEC0_BUF,a0
                  cmpi.w    #$55AA,510(a0)
                  bne.s     L005E 
                  bsr       L0064 
                  bra.s     L005F 
L005E:            move.w    #1,L002D
                  bsr       L0077 
L005F:            tst.w     d0
                  beq.s     L0060 
                  bpl.s     L0061 
                  bra.s     L0062 
L0060:            lea       L001D,a0
                  move.w    4(a7),d0
                  clr.b     0(a0,d0.w)
                  lea       L001C,a0
                  move.b    #2,0(a0,d0.w) 
                  bra.s     L0062 
L0061:            move.l    d1,-(a7)
                  move.w    8(a7),-(a7) 
                  bsr       _R_PHY1S
                  addq.l    #6,a7 
                  tst.l     d0
                  bpl.s     L0063 
L0062:            moveq     #0,d0 
L0063:            rts 
L0064:            adda.w    #$1BE,a0
L0065:            movem.l   a0/d1,-(a7) 
                  sf        L0049 
                  bsr       L006D 
                  tst.b     d0
                  beq.s     L006B 
                  cmpi.b    #5,d0 
                  bne.s     L0067 
                  st        L0049 
                  move.l    #0,L004B
                  move.l    d1,L004A
L0066:            bsr       L0071 
                  tst.b     d0
                  beq.s     L006B 
                  bmi.s     L0068 
                  cmpi.b    #5,d0 
                  beq.s     L0066 
L0067:            subq.w    #1,L004C
                  bpl.s     L006A 
L0068:            addq.l    #8,a7 
                  move.w    #0,L002D
                  cmpi.b    #1,d0 
                  beq.s     L0069 
                  move.w    #1,L002D
L0069:            bra.s     L006C 
L006A:            tst.b     L0049 
                  bne.s     L0066 
L006B:            movem.l   (a7)+,a0/d1 
                  adda.w    #$10,a0 
                  dbf       d1,L0065
                  moveq     #0,d0 
L006C:            rts 
L006D:            tst.l     12(a0)
                  beq.s     L006E 
                  move.b    4(a0),d0
                  beq.s     L0070 
                  cmpi.b    #4,d0 
                  beq.s     L006F 
                  cmpi.b    #1,d0 
                  beq.s     L006F 
                  cmpi.b    #5,d0 
                  beq.s     L006F 
L006E:            moveq     #0,d0 
                  bra.s     L0070 
L006F:            move.l    8(a0),d1
                  ror.w     #8,d1 
                  swap      d1
                  ror.w     #8,d1 
L0070:            rts 
L0071:            cmpi.b    #5,d0 
                  bne.s     L0072 
                  move.l    d1,-(a7)
                  move.w    _CURR_DEV,-(a7) 
                  addq.w    #2,(a7) 
                  move.w    #-1,-(a7) 
                  move.w    #1,-(a7)
                  move.l    _DSKBUFP.s,-(a7)
                  move.w    #$A,-(a7) 
                  bsr       _DO_RW
                  adda.w    #$10,a7 
                  tst.w     d0
                  bne       L0076 
                  movea.l   _DSKBUFP.s,a0 
                  cmpi.w    #$55AA,510(a0)
                  bne.s     L0076 
                  adda.w    #$1AE,a0
                  move.w    #4,d2 
L0072:            subq.w    #1,d2 
                  bmi.s     L0073 
                  adda.w    #$10,a0 
                  tst.l     12(a0)
                  beq.s     L0072 
                  move.b    4(a0),d0
                  beq.s     L0072 
                  move.l    8(a0),d1
                  beq.s     L0072 
                  ror.w     #8,d1 
                  swap      d1
                  ror.w     #8,d1 
                  cmpi.b    #4,d0 
                  beq.s     L0074 
                  cmpi.b    #1,d0 
                  beq.s     L0074 
                  cmpi.b    #5,d0 
                  bne.s     L0072 
                  move.l    d1,L004B
                  bra.s     L0075 
L0073:            moveq     #0,d0 
                  bra.s     L0076 
L0074:            add.l     L004B,d1
L0075:            add.l     L004A,d1
L0076:            rts 
L0077:            adda.w    #$1C2,a0
                  tst.l     (a0)+ 
                  beq.s     L007E 
L0078:            movem.l   a0/d1,-(a7) 
                  sf        L0049 
                  bsr       L0080 
                  tst.b     d0
                  beq.s     L007D 
                  cmpi.b    #$58,d0 
                  bne.s     L007A 
                  st        L0049 
                  move.l    #0,L004B
                  move.l    d1,L004A
L0079:            bsr       L0086 
                  tst.b     d0
                  beq.s     L007D 
                  bmi.s     L007B 
                  cmpi.b    #$58,d0 
                  beq.s     L0079 
L007A:            subq.w    #1,L004C
                  bpl.s     L007C 
L007B:            addq.l    #8,a7 
                  bra.s     L007F 
L007C:            tst.b     L0049 
                  bne.s     L0079 
L007D:            movem.l   (a7)+,a0/d1 
                  adda.w    #$C,a0
                  dbf       d1,L0078
L007E:            moveq     #0,d0 
L007F:            rts 
L0080:            tst.b     (a0)
                  beq.s     L0083 
                  tst.l     8(a0) 
                  beq.s     L0083 
                  cmpi.b    #$47,1(a0)
                  bne.s     L0081 
                  cmpi.b    #$45,2(a0)
                  bne.s     L0081 
                  cmpi.b    #$4D,3(a0)
                  beq.s     L0084 
L0081:            cmpi.b    #$42,1(a0)
                  bne.s     L0082 
                  cmpi.b    #$47,2(a0)
                  bne.s     L0082 
                  cmpi.b    #$4D,3(a0)
                  beq.s     L0084 
L0082:            cmpi.b    #$58,1(a0)
                  bne.s     L0083 
                  cmpi.b    #$47,2(a0)
                  bne.s     L0083 
                  cmpi.b    #$4D,3(a0)
                  beq.s     L0084 
L0083:            moveq     #0,d0 
                  bra.s     L0085 
L0084:            move.l    4(a0),d1
                  move.b    1(a0),d0
L0085:            rts 
L0086:            cmpi.b    #$58,d0 
                  bne.s     L0087 
                  move.l    d1,-(a7)
                  move.w    _CURR_DEV,-(a7) 
                  addq.w    #2,(a7) 
                  move.w    #-1,-(a7) 
                  move.w    #1,-(a7)
                  move.l    _DSKBUFP.s,-(a7)
                  move.w    #$A,-(a7) 
                  bsr       _DO_RW
                  adda.w    #$10,a7 
                  tst.w     d0
                  bne       L008D 
                  movea.l   _DSKBUFP.s,a0 
                  adda.w    #$1BA,a0
                  move.w    #4,d2 
L0087:            subq.w    #1,d2 
                  bmi.s     L008A 
                  adda.w    #$C,a0
                  tst.l     8(a0) 
                  beq.s     L0087 
                  tst.b     (a0)
                  beq.s     L0087 
                  move.l    4(a0),d1
                  cmpi.b    #$47,1(a0)
                  bne.s     L0088 
                  cmpi.b    #$45,2(a0)
                  bne.s     L0088 
                  cmpi.b    #$4D,3(a0)
                  beq.s     L008B 
L0088:            cmpi.b    #$42,1(a0)
                  bne.s     L0089 
                  cmpi.b    #$47,2(a0)
                  bne.s     L0089 
                  cmpi.b    #$4D,3(a0)
                  beq.s     L008B 
L0089:            cmpi.b    #$58,1(a0)
                  bne.s     L008A 
                  cmpi.b    #$47,2(a0)
                  bne.s     L008A 
                  cmpi.b    #$4D,3(a0)
                  bne.s     L0087 
                  move.l    d1,L004B
                  bra.s     L008C 
L008A:            moveq     #0,d0 
                  bra.s     L008D 
L008B:            add.l     L004B,d1
L008C:            add.l     L004A,d1
                  move.b    1(a0),d0
L008D:            rts 
_R_PHY1S:         move.l    6(a7),-(a7) 
                  move.w    _CURR_DEV,-(a7) 
                  addq.w    #2,(a7) 
                  move.w    #-1,-(a7) 
                  move.w    #1,-(a7)
                  move.l    _DSKBUFP.s,-(a7)
                  move.w    #$A,-(a7) 
                  bsr       _DO_RW
                  adda.w    #$10,a7 
                  tst.w     d0
                  beq.s     L008F 
                  move.w    4(a7),d1
                  bsr       _DO_CRIT_ERR
                  cmpi.l    #$10000,d0
                  bne       _ERREXIT
                  bra.s     _R_PHY1S
L008F:            movea.l   _DSKBUFP.s,a0 
                  movea.l   #L001F,a2 
                  move.w    #$B,d0
                  bsr       L0098 
                  cmp.w     MAX_SECTOR,d0 
                  bhi       _ERREXIT
                  move.w    d0,(a2)+
                  beq       _ERREXIT
                  move.w    d0,d1 
                  moveq     #9,d2 
                  lsr.w     d2,d0 
                  move.w    d0,L003D
                  clr.w     d0
                  move.b    13(a0),d0 
                  move.w    d0,(a2)+
                  beq       _ERREXIT
                  mulu      d1,d0 
                  move.w    d0,(a2)+
                  moveq     #$11,d0 
                  bsr       L0098 
                  tst.w     d0
                  beq       _ERREXIT
                  lsl.l     #5,d0 
                  divu      d1,d0 
                  move.l    d0,d1 
                  swap      d1
                  tst.w     d1
                  beq.s     L0090 
                  addq.w    #1,d0 
L0090:            move.w    d0,(a2)+
                  move.w    d0,d2 
                  move.w    #$16,d0 
                  bsr       L0098 
                  move.w    d0,(a2)+
                  beq       _ERREXIT
                  move.w    d0,d1 
                  move.w    d0,L003B
                  move.w    #$E,d0
                  bsr       L0098 
                  add.w     d1,d0 
                  move.w    d0,(a2)+
                  move.w    d0,L003C
                  add.w     d1,d0 
                  add.w     d2,d0 
                  move.w    d0,(a2)+
                  move.w    d0,d2 
                  move.w    #$13,d0 
                  bsr       L0098 
                  move.w    d0,L0041
                  sub.w     d2,d0 
                  beq       _ERREXIT
                  clr.l     d1
                  move.w    d0,d1 
                  clr.w     d0
                  move.b    13(a0),d0 
                  divu      d0,d1 
                  move.w    d1,(a2)+
                  move.w    L002D,(a2)
                  move.w    L003D,d2
                  lea       L0021,a1
                  move.w    4(a7),d0
                  move.b    d2,0(a1,d0.w) 
                  btst      #6,L002B
                  beq       L0095 
                  lea       L0020,a1
                  mulu      #3,d0 
                  adda.l    d0,a1 
                  move.w    #2,d1 
L0091:            move.b    8(a0,d1.w),0(a1,d1.w) 
                  dbf       d1,L0091
                  lea       L0022,a2
                  moveq     #0,d0 
                  move.w    4(a7),d0
                  lsl.l     #6,d0 
                  adda.l    d0,a2 
                  move.w    L003C,d0
                  mulu      d2,d0 
                  movea.l   6(a7),a1
                  adda.l    d0,a1 
                  move.w    L003B,d1
                  subq.l    #1,d1 
L0092:            move.w    L003D,d2
                  subq.w    #1,d2 
                  clr.l     L0042 
L0093:            movem.l   a0-a2/d1-d2,-(a7) 
                  move.l    a1,-(a7)
                  move.w    _CURR_DEV,-(a7) 
                  addq.w    #2,(a7) 
                  move.w    #-1,-(a7) 
                  move.w    #1,-(a7)
                  move.l    a0,-(a7)
                  move.w    #$A,-(a7) 
                  bsr       _DO_RW
                  adda.w    #$10,a7 
                  movem.l   (a7)+,a0-a2/d1-d2 
                  tst.w     d0
                  beq       L0094 
                  movem.l   a0-a2/d1-d2,-(a7) 
                  move.w    24(a7),d1 
                  bsr       _DO_CRIT_ERR
                  movem.l   (a7)+,a0-a2/d1-d2 
                  cmpi.l    #$10000,d0
                  beq.s     L0093 
                  bra       _ERREXIT
L0094:            bsr       L0099 
                  addq.w    #1,a1 
                  dbf       d2,L0093
                  bsr       L009B 
                  move.b    d0,(a2)+
                  dbf       d1,L0092
L0095:            move.w    4(a7),d0
                  lea       L001C,a0
                  clr.b     0(a0,d0.w)
                  lea       L001D,a0
                  move.b    #2,0(a0,d0.w) 
                  lea       L0023,a0
                  asl.w     #1,d0 
                  move.w    L003C,0(a0,d0.w)
                  lea       L0024,a0
                  move.w    L003C,d1
                  add.w     L003B,d1
                  subq.w    #1,d1 
                  move.w    d1,0(a0,d0.w) 
                  lea       L0045,a0
                  asl.w     #1,d0 
                  clr.l     d1
                  move.w    L0041,d1
                  move.l    d1,0(a0,d0.w) 
                  lea       L0015,a0
                  move.l    6(a7),0(a0,d0.w)
                  move.l    #L001F,d0 
                  bra.s     L0097 
_ERREXIT:         moveq     #-1,d0
L0097:            rts 
L0098:            move.w    d1,-(a7)
                  move.b    1(a0,d0.w),d1 
                  lsl.w     #8,d1 
                  move.b    0(a0,d0.w),d1 
                  move.w    d1,d0 
                  move.w    (a7)+,d1
                  rts 
L0099:            movem.l   a0/d1,-(a7) 
                  move.l    L0042,d0
                  move.w    #$7F,d1 
L009A:            add.l     (a0)+,d0
                  dbf       d1,L009A
                  move.l    d0,L0042
                  movem.l   (a7)+,a0/d1 
                  rts 
L009B:            move.w    L0044,d0
                  eor.w     d0,L0042
                  move.b    L0043,d0
                  eor.b     d0,L0042
                  move.b    L0042,d0
                  rts 
;+
; _DO_RW - read and write sectors to ACSI, TT-SCSI, IDE, F030-SCSI Bus
;
; input 
;          
; lrecno        20(a6)
; device number 18(a6)
; recno         16(a6)
; count         14(a6)
; buf           10(a6)
; rwflag         8(a6)
;-

_DO_RW:           link      a6,#0 
                  subq.w    #2,18(a6) 		;reduce device number by 2
                  move.w    18(a6),d0 		;real device number
                  btst      #3,9(a6)		;physical or logical mode ?
                  beq.s     L009D 		;is LOGICAL mode

                  move.w    d0,_CURR_DEV
                  bra       L00A4 

L009D:            lea       L0014,a0		;table of
                  move.b    0(a0,d0.w),L002B
                  lea       L0021,a0		;table of
                  move.b    0(a0,d0.w),L003E
                  lea       L0045,a0
                  move.w    d0,d1 		
                  add.w     d1,d1 
                  add.w     d1,d1 		;d1 = 4*d0.w (tab of longs)
                  move.l    0(a0,d1.w),_CURR_LASTOFPART 
                  lea       L0015,a0		;
                  move.l    0(a0,d1.w),L003F
                  btst      #1,9(a6)		;use mediach ?
                  bne       L00A4 		;no
                  lea       L001C,a0
                  move.b    0(a0,d0.w),d0 
                  beq       L00A4 
                  cmpi.b    #2,d0 
                  beq       L00B2 
L009E:            move.l    L003F,-(a7) 
                  move.w    _CURR_DEV,-(a7) 
                  addq.w    #2,(a7) 
                  move.w    #-1,-(a7) 
                  move.w    #1,-(a7)
                  move.l    _DSKBUFP.s,-(a7)
                  move.w    #$A,-(a7) 
                  bsr       _DO_RW
                  adda.w    #$10,a7 
                  tst.w     d0
                  beq.s     L009F 
                  move.w    18(a6),d1 
                  bsr       _DO_CRIT_ERR
                  cmpi.l    #$10000,d0
                  beq.s     L009E 
                  bra       _EXERR_DO_RW
L009F:            lea       L0020,a1
                  move.w    18(a6),d0 
                  mulu      #3,d0 
                  adda.l    d0,a1 
                  movea.l   _DSKBUFP.s,a2 
                  addq.w    #8,a2 
                  move.w    #2,d0 
L00A0:            cmpm.b    (a2)+,(a1)+ 
                  bne       L00B1 
                  dbf       d0,L00A0
                  moveq     #0,d1 
                  move.w    18(a6),d1 
                  lea       L0022,a1
                  lsl.l     #6,d1 
                  adda.l    d1,a1 
                  add.w     d0,d0 
                  lea       L0023,a2
                  move.w    0(a2,d0.w),L003C
                  lea       L0024,a2
                  move.w    0(a2,d0.w),d1 
                  sub.w     L003C,d1
                  movea.l   L003F,a2
                  move.w    L003C,d2
                  mulu      L003D,d2
                  adda.l    d2,a2 
                  movea.l   _DSKBUFP.s,a0 
L00A1:            move.w    L003D,d2
                  subq.w    #1,d2 
                  clr.l     L0042 
L00A2:            movem.l   a0-a2/d1-d2,-(a7) 
                  move.l    a2,-(a7)
                  move.w    _CURR_DEV,-(a7) 
                  addq.w    #2,(a7) 
                  move.w    #-1,-(a7) 
                  move.w    #1,-(a7)
                  move.l    a0,-(a7)
                  move.w    #$A,-(a7) 
                  bsr       _DO_RW
                  adda.w    #$10,a7 
                  movem.l   (a7)+,a0-a2/d1-d2 
                  tst.w     d0
                  beq.s     L00A3 
                  movem.l   a0-a2/d1-d2,-(a7) 
                  move.w    18(a6),d1 
                  bsr       _DO_CRIT_ERR
                  movem.l   (a7)+,a0-a2/d1-d2 
                  cmpi.l    #$10000,d0
                  beq.s     L00A2 
                  bra       _EXERR_DO_RW
L00A3:            bsr       L0099 
                  addq.w    #1,a2 
                  dbf       d2,L00A2
                  bsr       L009B 
                  cmp.b     (a1)+,d0
                  bne       L00B1 
                  dbf       d1,L00A1
                  lea       L001C,a0
                  adda.w    18(a6),a0 
                  clr.b     (a0)
L00A4:            tst.w     14(a6)
                  beq       L00B0 
                  cmpi.w    #-1,16(a6)
                  bne.s     .S_RECNO
                  movea.l   20(a6),a1 
                  bra.s     .L_RECNO
.S_RECNO:         moveq     #0,d0 
                  move.w    16(a6),d0 
                  movea.l   d0,a1 
.L_RECNO:         move.l    a1,_CURR_LRECNO 
                  move.l    a1,d1 		;d1 = _CURR_LRECNO
                  moveq     #0,d2 
                  move.w    14(a6),d2 		;d2 = count
                  adda.l    d2,a1 		;a1 = count + _CURR_LRECNO
                  subq.l    #1,a1 		;a1 = last sector to act on
                  move.l    a1,_CURR_LASTRECNO
                  move.l    10(a6),_CURR_BUF	;get buffer adress
                  btst      #3,9(a6)		;logical or physical
                  bne.s     L00A8 		;do it physical
                  cmpa.l    _CURR_LASTOFPART,a1 ;greater length of partition
                  bcs       L00A7 		;no: DO IT
                  moveq     #-6,d0		;leave with EACDN
                  bra       _EXERR_DO_RW
;-
; tries to calculate the physical lrecno from the logical number
; and this is the bug:
; mulu cannot work correctly, if d1 and d2 are already bigger than
; 65565 !!
;+

L00A7:

  IFNE USEWRONG
                  mulu      L003D,d1		;sec_per_logsec * lrecno
                  add.l     L003F,d1		;current partition start
                  mulu      L003D,d2		;sec_per_logsec * count
  ELSE
                  move.l    d3,-(a7)
                  move.w    L003D,d0		;d0 = sec_per_logsec
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
; lrecno with. This works, if you use lsl.l 
;-                 
                  lsl.l     d3,d1		;sec_per_logsec * lrecno
                  lsl.l     d3,d2               ;sec_per_logsec * count
                  add.l     L003F,d1            ;current partiton start
		  move.l    (a7)+,d3
                  bra.s     L00A8		;go for it
wrong:
		  move.l    (a7)+,d3
                  moveq.l   #-7,d0		;unknown media, EMEDIA
                  bra       _EXERR_DO_RW        ;exit with error

  ENDIF

L00A8:            move.w    18(a6),-(a7)
                  move.l    d1,-(a7)		;first physical sector
                  move.l    d2,-(a7)		;number of physical sectors
                  move.l    10(a6),-(a7)
                  move.w    8(a6),-(a7) 
                  bsr       L00B8 
                  adda.w    #$10,a7 
                  tst.l     d0

                  beq.s     L00A9 
                  cmpi.l    #-$E,d0 
                  bne       _EXERR_DO_RW
                  btst      #3,9(a6)
                  bne       _EXERR_DO_RW
                  bra       L009E 
L00A9:            move.w    8(a6),d0
                  btst      #0,d0 
                  beq       L00B0 
                  btst      #6,L002B
                  beq       L00B0 
                  btst      #3,d0 
                  bne       L00B0 
                  tst.l     _CURR_LRECNO
                  bne.s     L00AA 
                  lea       L001C,a0
                  adda.w    18(a6),a0 
                  move.b    #2,(a0) 
L00AA:            lea       L0024,a0
                  move.w    18(a6),d0 
                  add.w     d0,d0 
                  moveq     #0,d1 
                  move.w    0(a0,d0.w),d1 
                  cmp.l     _CURR_LRECNO,d1 
                  blt       L00B0 
                  lea       L0023,a0
                  moveq     #0,d2 
                  move.w    0(a0,d0.w),d2 
                  cmp.l     _CURR_LASTRECNO,d2
                  bgt       L00B0 
                  movea.l   _CURR_BUF,a0
                  lea       L0022,a1
                  moveq     #0,d0 
                  move.w    18(a6),d0 
                  lsl.l     #6,d0 
                  adda.l    d0,a1 
                  move.l    _CURR_LRECNO,d0 
                  sub.l     d2,d0 
                  beq.s     L00AC 
                  blt.s     L00AB 
                  move.l    _CURR_LRECNO,d2 
                  adda.l    d0,a1 
                  bra.s     L00AC 
L00AB:            neg.l     d0
                  asl.l     #8,d0 
                  add.l     d0,d0 
                  adda.l    d0,a0 
L00AC:            cmp.l     _CURR_LASTRECNO,d1
                  ble.s     L00AD 
                  move.l    _CURR_LASTRECNO,d1
L00AD:            sub.w     d2,d1 
L00AE:            move.w    L003D,d2
                  subq.w    #1,d2 
                  clr.l     L0042 
L00AF:            bsr       L0099 
                  adda.l    #$200,a0
                  dbf       d2,L00AF
                  bsr       L009B 
                  move.b    d0,(a1)+
                  dbf       d1,L00AE
L00B0:            clr.l     d0
                  bra.s     _EXERR_DO_RW
L00B1:            lea       L001C,a0
                  adda.w    18(a6),a0 
                  move.b    #2,(a0) 
                  lea       L001D,a0
                  adda.w    18(a6),a0 
                  move.b    #2,(a0) 
L00B2:            moveq     #-$E,d0 
_EXERR_DO_RW:     btst      #0,9(a6)
                  bne.s     .EX_DO_RW 
                  tst.b     FLG_CPU030
                  beq.s     .EX_DO_RW 
                  move.l    d0,-(a7)
                  move      sr,-(a7)
                  ori.w     #$700,sr
                  movec     cacr,d0 
                  ori.w     #$808,d0
                  movec     d0,cacr 
                  move      (a7)+,sr
                  move.l    (a7)+,d0
.EX_DO_RW:        unlk      a6
                  rts 
L00B5:            move.w    d1,-(a7)
                  neg.w     d1
                  addi.w    #9,d1 
                  asl.w     d1,d0 
                  subq.w    #1,d0 
                  move.w    (a7)+,d1
                  bne.s     L00B7 
L00B6:            move.b    (a2)+,(a1)+ 
                  dbf       d0,L00B6
                  rts 
L00B7:            move.l    (a2)+,(a1)+ 
                  dbf       d0,L00B7
                  rts 
L00B8:            link      a6,#0 
                  move.l    14(a6),d2 
                  movea.l   10(a6),a1 
                  btst      #4,L002B
                  bne       L00C3 
                  btst      #3,L002B
                  beq.s     L00B9 
                  tst.b     L004E 
                  beq       L00C1 
                  cmp.l     #$3FFF,d2 
                  bls.s     L00BA 
                  move.l    #$3FFF,d2 
                  bra.s     L00BA 
L00B9:            cmp.l     #$FE,d2 
                  bls.s     L00BA 
                  move.l    #$FE,d2 
L00BA:            btst      #0,13(a6) 
                  bne.s     L00BD 
                  cmpi.l    #$20000,L0029 
                  bne.s     L00BB 
                  cmpa.l    #$9FFFFF,a1 
                  bls       L00C6 
                  cmpa.l    #-$1000000,a1 
                  bcs.s     L00BD 
                  cmpa.l    #-$600001,a1
                  bls       L00C6 
                  bra       L00BD 
L00BB:            cmpi.l    #$30000,L0029 
                  bne.s     L00BC 
                  cmpa.l    #$DFFFFF,a1 
                  bls       L00C6 
                  cmpa.l    #-$1000000,a1 
                  bcs.s     L00BD 
                  cmpa.l    #-$200001,a1
                  bls       L00C6 
                  bra.s     L00BD 
L00BC:            cmpa.l    #$3FFFFF,a1 
                  bls       L00C6 
                  cmpa.l    #-$1000000,a1 
                  bcs.s     L00BD 
                  cmpa.l    #-$C00001,a1
                  bls       L00C6 
L00BD:            moveq     #0,d1 
                  btst      #0,13(a6) 
                  bne.s     L00BE 
                  moveq     #2,d1 
L00BE:            tst.l     L0032 
                  bne.s     L00BF 
                  move.l    d1,-(a7)
                  move.l    #L0032,-(a7)
                  move.l    #$5F465242,-(a7)
                  bsr       L015B 
                  addq.w    #8,a7 
                  move.l    (a7)+,d1
                  tst.w     d0
                  bne.s     L00BF 
                  movea.l   _DSKBUFP.s,a1 
                  cmpi.w    #2,d2 
                  bls.s     L00C0 
                  move.w    #2,d2 
                  bra.s     L00C0 
L00BF:            movea.l   L0032,a1
                  cmpi.w    #$80,d2 
                  bls.s     L00C0 
                  move.w    #$80,d2 
L00C0:            btst      #0,9(a6)
                  beq.s     L00C6 
                  move.l    a1,-(a7)
                  movea.l   10(a6),a2 
                  move.w    d2,d0 
                  bsr       L00B5 
                  movea.l   (a7)+,a1
                  bra.s     L00C6 
L00C1:            cmpi.l    #$FFFE,d2 
                  bls.s     L00C2 
                  move.l    #$FFFE,d2 
L00C2:            cmpa.l    #-$40000000,a1
                  bcs.s     L00C6 
                  cmpa.l    #-$3000001,a1 
                  bls       L00BD 
                  cmpa.l    #-$2000000,a1 
                  bcs.s     L00C6 
                  cmpa.l    #-$1000001,a1 
                  bls       L00BD 
                  bra.s     L00C6 
L00C3:            cmp.l     #$100,d2
                  bls.s     L00C4 
                  move.l    #$100,d2
L00C4:            btst      #0,13(a6) 
                  bne       L00BD 
L00C5:            movea.l   10(a6),a1 
L00C6:            move.w    L0033,L0034 
                  btst      #2,9(a6)
                  beq.s     L00C7 
                  move.w    #0,L0034
L00C7:            movem.l   a1/d1-d2,-(a7)
                  move.w    _CURR_DEV,-(a7) 
                  move.l    a1,-(a7)
                  move.w    d2,-(a7)
                  move.l    18(a6),-(a7)
                  btst      #4,L002B
                  bne.s     L00CB 
                  cmpi.l    #$FE,d2 
                  bhi.s     L00C9 
                  btst      #0,9(a6)
                  bne.s     L00C8 
                  bsr       L0154 
                  bra       L00CE 
L00C8:            bsr       L0155 
                  bra.s     L00CE 
L00C9:            btst      #0,9(a6)
                  bne.s     L00CA 
                  bsr       L0158 
                  bra.s     L00CE 
L00CA:            bsr       L0159 
                  bra.s     L00CE 
L00CB:            lea       L001E,a0
                  move.w    2(a0),-(a7) 
                  move.w    (a0),-(a7)
                  btst      #0,9(a6)
                  bne.s     L00CC 
                  bsr       L0130 
                  bra.s     L00CD 
L00CC:            bsr       L0134 
L00CD:            addq.w    #4,a7 
L00CE:            adda.w    #$C,a7
                  movem.l   (a7)+,a1/d1-d2
                  tst.l     d0
                  beq       L00D2 
                  bmi.s     L00D0 
                  movem.l   a1/d1-d2,-(a7)
                  move.w    8(a6),-(a7) 
                  bsr       L00F0 
                  addq.w    #2,a7 
                  movem.l   (a7)+,a1/d1-d2
                  cmpi.l    #-$E,d0 
                  bne.s     L00CF 
                  move.b    #1,d0 
                  bsr       L00DA 
                  btst      #1,9(a6)
                  bne       L00C7 
                  bra       L00D6 
L00CF:            cmpi.l    #-$D,d0 
                  beq.s     L00D1 
                  cmpi.l    #-2,d0
                  beq.s     L00D1 
L00D0:            subq.w    #1,L0034
                  bpl       L00C7 
L00D1:            btst      #3,9(a6)
                  bne       L00D6 
                  movem.l   a1/d1-d2,-(a7)
                  move.w    22(a6),d1 
                  bsr       _DO_CRIT_ERR
                  movem.l   (a7)+,a1/d1-d2
                  cmpi.l    #$10000,d0
                  beq       L00C7 
                  bra.s     L00D6 
L00D2:            lea       L00C5,a0
                  cmpa.l    10(a6),a1 
                  beq.s     L00D3 
                  lea       L00C0,a0
                  btst      #0,9(a6)
                  bne.s     L00D3 
                  move.l    a1,-(a7)
                  movea.l   a1,a2 
                  movea.l   10(a6),a1 
                  move.w    d2,d0 
                  bsr       L00B5 
                  movea.l   (a7)+,a1
L00D3:            sub.l     d2,14(a6) 
                  beq.s     L00D5 
                  add.l     d2,18(a6) 
                  move.l    d2,d0 
                  asl.l     #8,d0 
                  add.l     d0,d0 
                  add.l     d0,10(a6) 
                  cmp.l     14(a6),d2 
                  bls.s     L00D4 
                  move.l    14(a6),d2 
L00D4:            jmp       (a0)
L00D5:            moveq     #0,d0 
L00D6:            unlk      a6
                  rts 
_DO_MEDIACH:      subq.w    #2,4(a7)
                  move.w    4(a7),d1
                  lea       L001C,a0
                  moveq     #0,d0 
                  move.b    0(a0,d1.w),d0 
                  tst.b     d0
                  bne.s     L00D9 
                  move.l    L0039,d2
                  cmp.l     _HZ_200.s,d2
                  bcc.s     L00D9 
                  lea       L0014,a1
                  move.b    0(a1,d1.w),L002B
                  btst      #6,L002B
                  beq.s     L00D8 
                  move.w    _CURR_DEV,-(a7) 
                  bsr       L0151 
                  addq.l    #2,a7 
                  move.l    _HZ_200.s,L0039 
                  addi.l    #$C8,L0039
                  tst.w     d0
                  beq.s     L00D8 
                  moveq     #1,d0 
                  bsr       L00DA 
                  bra.s     L00D9 
L00D8:            moveq     #0,d0 
L00D9:            rts 
L00DA:            movem.l   a0-a2/d1-d2,-(a7) 
                  lea       L0014,a0
                  lea       L001C,a1
                  lea       L001D,a2
                  move.w    _CURR_DEV,d1
                  moveq     #0,d2 
L00DB:            btst      #7,0(a0,d2.w) 
                  bne.s     L00DD 
                  cmp.b     0(a0,d2.w),d1 
                  bne.s     L00DC 
                  move.b    d0,0(a1,d2.w) 
                  move.b    d0,0(a2,d2.w) 
L00DC:            addq.w    #1,d2 
                  cmp.w     #$E,d2
                  blt.s     L00DB 
L00DD:            movem.l   (a7)+,a0-a2/d1-d2 
                  rts 
L00DE:            tst.b     FLG_IDE_EXIST 
                  beq.s     L00DF 
                  cmpi.l    #$30000,L0029 
                  beq.s     L00DF 
                  move.w    L000B,PUN_RSVD
                  beq.s     L00DF 
                  move.w    L000B,-(a7) 
                  move.w    #$10,-(a7)
                  bsr       L013D 
                  addq.w    #4,a7 
L00DF:            move.l    #_INSTALL,L0028 
                  subi.l    #L0001,L0028
                  cmpi.w    #$200,MAX_SECTOR
                  bls.s     L00E3 
L00E0:            bsr       L00ED 
                  tst.l     d0
                  bpl.s     L00E2 
                  move.w    L0004,d0
                  cmp.w     MAX_SECTOR,d0 
                  bcc.s     L00E1 
                  move.w    d0,MAX_SECTOR 
                  bra.s     L00E0 
L00E1:            move.w    #$200,MAX_SECTOR
                  bra.s     L00E3 
L00E2:            move.l    d1,L0028
                  lea       _INSTALL,a0 
                  moveq     #3,d1 
                  bsr       L00EB 
                  clr.l     0(a0,d0.w)
                  move.l    a0,_BUFL1.s 
                  add.l     d0,d0 
                  adda.l    d0,a0 
                  move.l    a0,_BUFL2.s 
L00E3:            bsr       L00FC 
                  add.l     d0,L0028
                  move.l    _HZ_200.s,L0039 
                  tst.w     L0025 
                  bne.s     L00E4 
                  move.l    L0046,-(a7) 
                  move.w    #$20,-(a7) 	;SUPER
                  trap      #1
                  addq.w    #6,a7 
                  move.l    L0028,d0
                  add.l     #$100,d0
                  move.l    d0,-(a7)
                  movea.l   #L00EA,a0 
                  bsr       L022B 
                  move.l    (a7)+,d0
                  move.w    #0,-(a7)
                  move.l    d0,-(a7)
                  move.w    #$31,-(a7) 	;PTERMRES 
                  trap      #1
                  illegal 
L00E4:            move.l    L0028,d0
                  add.l     #$1C,d0 
                  move.l    d0,-(a7)
                  movea.l   #L00E9,a0 
                  bsr       L022B 
                  move.w    d4,d1 
                  bpl.s     L00E5 
                  move.b    d7,d1 
                  lsr.b     #5,d1 
L00E5:            lea       L0014,a0
                  moveq     #0,d2 
L00E6:            move.b    0(a0,d2.w),d0 
                  andi.b    #$1F,d0 
                  cmp.b     d0,d1 
                  beq.s     L00E7 
                  addq.w    #1,d2 
                  bra.s     L00E6 
L00E7:            addq.w    #2,d2 
                  move.w    d2,_BOOTDEV.s 
                  move.l    L0027,-(a7) 
                  clr.w     -(a7) 
                  move.w    #$4A,-(a7) 	;MSHRINK
                  trap      #1
                  adda.w    #$C,a7
                  move.w    _BOOTDEV.s,-(a7)
                  move.w    #$E,-(a7) 	;DSETDRV 
                  trap      #1
                  addq.w    #4,a7 
                  move.l    #L00E8,-(a7)
                  move.w    #$3B,-(a7) 	;DSETPATH 
                  trap      #1
                  addq.w    #6,a7 
                  move.b    #-$20,d7
                  rts 
L00E8:            dc.b      '\',$00 
L00E9:            dc.b      '-----------------------',$D,$A 
                  dc.b      'BOOTLOADED',$D,$A
                  dc.b      0
L00EA:            dc.b      '-----------------------',$D,$A 
                  dc.b      'NOT Bootloaded',$D,$A
                  dc.b      0 
L00EB:            move.l    a0,-(a7)
L00EC:            movea.l   a0,a1 
                  adda.l    d0,a1 
                  move.l    a1,(a0) 
                  move.w    #-1,4(a0) 
                  adda.w    #$14,a0 
                  move.l    a0,-4(a0) 
                  movea.l   a1,a0 
                  dbf       d1,L00EC
                  suba.l    d0,a0 
                  clr.l     (a0)
                  movea.l   (a7)+,a0
                  rts 
L00ED:            moveq     #$14,d0 
                  add.w     MAX_SECTOR,d0 
                  move.l    d0,d1 
                  lsl.l     #2,d1 
                  add.l     L0028,d1
                  cmp.l     L0026,d1
                  bls.s     L00EE 
                  moveq     #-1,d0
L00EE:            rts 
_DO_CRIT_ERR:     addq.w    #2,d1 
                  move.w    d1,-(a7)
                  move.w    d0,-(a7)
                  movea.l   ETV_CRITIC.s,a0 
                  jsr       (a0)
                  addq.l    #4,a7 
                  rts 
L00F0:            btst      #4,L002B
                  bne.s     L00F9 
                  moveq     #$16,d1 
                  move.w    _CURR_DEV,d0
                  btst      #3,d0 
                  bne.s     L00F1 
                  andi.w    #7,d0 
                  btst      d0,L0031
                  bne.s     L00F1 
                  moveq     #0,d1 
L00F1:            lea       L0038,a0
                  movem.l   a0/d1,-(a7) 
                  move.l    a0,-(a7)
                  move.w    d1,-(a7)
                  move.w    d0,-(a7)
                  bsr       L0152 
                  addq.l    #8,a7 
                  movem.l   (a7)+,a0/d1 
                  tst.w     d0
                  beq.s     L00F2 
                  moveq     #-1,d0
                  rts 
L00F2:            cmpi.w    #4,d1 
                  bgt.s     L00F3 
                  move.b    (a0),d1 
                  andi.b    #$7F,d1 
                  bra.s     L00F4 
L00F3:            move.b    12(a0),d1 
L00F4:            cmpi.b    #$28,d1 
                  bne.s     L00F5 
                  moveq     #-$E,d0 
                  bra.s     L00FB 
L00F5:            cmpi.b    #$27,d1 
                  bne.s     L00F6 
                  moveq     #-$D,d0 
                  bra.s     L00FB 
L00F6:            cmpi.b    #4,d1 
                  bne.s     L00F8 
L00F7:            moveq     #-2,d0
                  bra.s     L00FB 
L00F8:            btst      #0,5(a7)
                  bne.s     L00FA 
                  moveq     #-$B,d0 
                  bra.s     L00FB 
L00F9:            btst      #6,d0 
                  beq.s     L00F7 
                  btst      #5,d0 
                  bne.s     L00F8 
L00FA:            moveq     #-$A,d0 
L00FB:            rts 
L00FC:            movea.l   _SYSBASE.s,a3 
                  cmpa.l    #$800000,a3 
                  blt       L00FF 
                  lea       L0107(pc),a0
L00FD:            move.l    (a0)+,d1
                  beq       L0100 
                  movea.l   (a0)+,a2
                  cmp.l     24(a3),d1 
                  bne.s     L00FD 
                  move.w    L0003,d0
                  mulu      #$42,d0 
                  move.l    d0,d1 
                  add.l     L0028,d1
                  cmp.l     L0026,d1
                  bgt.s     L0103 
                  movea.l   #L0002,a0 
                  adda.l    L0028,a0
                  move.l    a0,-(a7)
                  move.w    L0003,d1
                  subq.w    #1,d1 
L00FE:            lea       66(a0),a1 
                  move.l    a1,(a0) 
                  move.w    #4,-2(a0) 
                  movea.l   a1,a0 
                  dbf       d1,L00FE
                  suba.w    #$42,a0 
                  move.l    16(a2),(a0) 
                  move.l    (a7)+,16(a2)
                  rts 
L00FF:            lea       L0105(pc),a0
                  bra.s     L0101 
L0100:            lea       L0106(pc),a0
L0101:            cmpi.w    #$CA1,30(a3)
                  bcc       L0103 
                  move.l    a0,-(a7)
                  move.w    #9,-(a7) 	;CCONWS 
                  trap      #1
                  addq.l    #6,a7 
                  pea       L0104(pc) 
                  move.w    #9,-(a7) 	;CCONWS 
                  trap      #1
                  addq.l    #6,a7 
L0102:            move.w    #2,-(a7)
                  move.w    #2,-(a7) 	;BCONIN 
                  trap      #$D 
                  addq.l    #4,a7 
                  cmp.w     #$D,d0
                  bne.s     L0102 
L0103:            moveq     #0,d0 
                  rts 
L0104:            dc.b      'Hard disk driver not loaded; hit RETURN',$D 
                  dc.b      $A
                  dc.b      'key to continue:',$D,$A
                  dc.b      0 
L0105:            dc.b      '*** WARNING ***',$D,$A 
                  dc.b      7,'This hard disk driver may not work with' 
                  dc.b      $D,$A 
                  dc.b      7,'a disk-based version of TOS; files on',$D,$A 
                  dc.b      7,'your hard disk may be damaged.',$D,$A
                  dc.b      7,$D,$A 
                  dc.b      7,0 
L0106:            dc.b      '*** WARNING ***',$D,$A 
                  dc.b      7,'You are using an unofficial ROM release' 
                  dc.b      $D,$A 
                  dc.b      7,'of the operating system.  This driver',$D,$A 
                  dc.b      7,'may not work correctly with it.  Files',$D,$A
                  dc.b      7,'on your hard disk may be damaged.',$D,$A 
                  dc.b      7,$D,$A 
                  dc.b      7,0 
L0107:            dc.b      $11,' ',$19,$85,$00,$00,'V',$FA 
                  dc.b      $02,$06,$19,$86,$00,$00,'V',$FA 
                  dc.b      $04,'$',$19,$86,$00,$00,'V',$FA 
                  ds.w      2,0 
L0108:            ds.w      2,0 
                  dc.b      $00 
L0109:            dc.b      $00 
L010A:            move.l    #$258,d0
                  bra.s     L010C 
L010B:            moveq     #$14,d0 
L010C:            tst.b     L0109 
                  beq.s     L010E 
                  move.l    d0,-(a7)
                  moveq     #2,d0 
                  add.l     _HZ_200.s,d0
L010D:            cmp.l     _HZ_200.s,d0
                  bge.s     L010D 
                  move.l    (a7)+,d0
L010E:            add.l     _HZ_200.s,d0
L010F:            cmp.l     _HZ_200.s,d0
                  bcs.s     L0110 
                  btst      #5,GPIP.s 
                  bne.s     L010F 
                  moveq     #0,d0 
                  rts 
L0110:            moveq     #-1,d0
                  rts 
L0111:            move.l    d0,-(a7)
                  move.l    L0108,d0
L0112:            cmp.l     _HZ_200.s,d0
                  bcc.s     L0112 
                  move.l    (a7)+,d0
                  rts 
L0113:            bsr.s     L010A 
                  bmi.s     L0115 
                  tst.b     FLG_CPU030
                  beq.s     L0114 
                  move      sr,-(a7)
                  ori.w     #$700,sr
                  movec     cacr,d0 
                  ori.w     #$800,d0
                  movec     d0,cacr 
                  move      (a7)+,sr
L0114:            move.w    d1,FIFO.s 
                  move.w    DISKCTL.s,d0
                  and.w     #$FF,d0 
L0115:            move.l    _HZ_200.s,L0108 
                  addq.l    #2,L0108
                  rts 
L0116:            move.w    #$180,FIFO.s
                  bsr       L012B 
                  move.w    #$80,FIFO.s 
                  clr.w     FLOCK.s 
                  rts 
L0117:            st        FLOCK.s 
                  bsr.s     L0111 
                  movea.l   #-$79FC,a1
                  andi.w    #7,d0 
                  moveq     #0,d1 
                  bsr       L0122 
                  bra.s     L0116 
L0118:            st        FLOCK.s 
                  move.w    d3,-(a7)
                  bsr       L0111 
                  movea.l   #-$79FC,a1
                  bsr       L0126 
                  move.w    #$190,2(a1) 
                  bsr       L012B 
                  move.w    #$90,2(a1)
                  bsr       L012B 
                  bsr       L0127 
                  andi.w    #7,d0 
                  cmpi.l    #$200,d1
                  bcs.s     L0119 
                  moveq     #0,d1 
                  bra.s     L011C 
L0119:            move.w    d1,d3 
                  cmpi.w    #$10,d1 
                  bcs.s     L011A 
                  andi.w    #$F,d1
                  beq.s     L011C 
                  moveq     #1,d1 
                  bra.s     L011C 
L011A:            moveq     #$10,d1 
                  divu      d3,d1 
                  subq.w    #1,d1 
                  swap      d1
                  tst.w     d1
                  bne.s     L011B 
                  swap      d1
                  bra.s     L011C 
L011B:            swap      d1
                  addq.w    #1,d1 
L011C:            lea       L0150,a0
L011D:            movem.l   a0/d0-d2,-(a7)
                  moveq     #0,d1 
                  bsr       L0111 
                  bsr       L0122 
                  tst.w     d0
                  bne.s     L011F 
                  movem.l   (a7)+,a0/d0-d2
                  dbf       d1,L011E
                  moveq     #0,d0 
                  bra.s     L0120 
L011E:            moveq     #-1,d0
                  move.b    d3,4(a0)
                  bra.s     L011D 
L011F:            adda.w    #$10,a7 
L0120:            move.w    (a7)+,d3
                  bra       L0116 
L0121:            st        FLOCK.s 
                  bsr       L0111 
                  movea.l   #-$79FC,a1
                  bsr       L0126 
                  move.w    #$90,2(a1)
                  bsr       L012B 
                  move.w    #$190,2(a1) 
                  bsr       L012B 
                  bsr       L0127 
                  andi.w    #7,d0 
                  move.l    #$100,d1
                  bsr       L0122 
                  bra       L0116 
L0122:            move.b    #-$78,d1
                  move.w    d1,2(a1)
                  move.b    #-$76,d1
                  lea       L0150,a2
                  tst.w     d0
                  bmi.s     L0123 
                  lsl.b     #5,d0 
                  or.b      d0,(a2) 
L0123:            subq.w    #2,d2 
L0124:            swap      d1
                  move.b    (a2)+,d1
                  swap      d1
                  move.l    d1,(a1) 
                  bsr       L010B 
                  bmi.s     L0125 
                  dbf       d2,L0124
                  move.w    d1,2(a1)
                  move.b    #0,d1 
                  swap      d1
                  move.b    (a2),d1 
                  swap      d1
                  move.l    d1,(a1) 
                  move.b    #-$76,d1
                  bsr       L0113 
L0125:            rts 
L0126:            move.l    a0,-(a7)
                  move.b    3(a7),DMALOW.s
                  move.b    2(a7),DMAMID.s
                  move.b    1(a7),DMAHIGH.s 
                  addq.l    #4,a7 
                  rts 
L0127:            cmpi.l    #$200,d1
                  bhi.s     L0128 
                  move.w    #1,(a1) 
                  bra.s     L012A 
L0128:            movem.l   d1-d2,-(a7) 
                  move.l    d1,d2 
                  lsr.l     #8,d1 
                  lsr.l     #1,d1 
                  andi.l    #$1FF,d2
                  beq.s     L0129 
                  add.w     #1,d1 
L0129:            move.w    d1,(a1) 
                  movem.l   (a7)+,d1-d2 
L012A:            rts 
L012B:            tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  rts 
L012C:            move.l    #$7D0,d0
                  add.l     _HZ_200.s,d0
L012D:            btst      #5,GPIP.s 
                  beq.s     L012E 
                  cmp.l     _HZ_200.s,d0
                  bhi.s     L012D 
                  moveq     #-1,d0
                  bra.s     L012F 
L012E:            moveq     #0,d0 
                  move.b    $FFF0001D.l,d0
                  btst      #0,d0 
                  bne.s     L012F 
                  btst      #3,d0 
                  bne.s     L012F 
                  moveq     #0,d0 
L012F:            rts 
L0130:            bsr       L0139 
                  movea.l   14(a7),a0 
                  move.b    13(a7),$FFF00009.l
                  move.w    12(a7),d1 
                  subq.w    #1,d1 
                  tst.b     FLG_BLIT_USE
                  beq.s     L0131 
                  moveq     #0,d0 
                  bsr       L0145 
L0131:            move.b    #0,$FFF00039.l
                  move.b    #$20,$FFF0001D.l
L0132:            bsr.s     L012C 
                  tst.w     d0
                  bmi.s     L0133 
                  btst      #3,d0 
                  beq.s     L0133 
                  bsr       L013E 
                  dbf       d1,L0132
                  moveq     #0,d0 
L0133:            move.b    #2,$FFF00039.l
                  rts 
L0134:            bsr       L0139 
                  movea.l   14(a7),a0 
                  move.b    13(a7),$FFF00009.l
                  move.w    12(a7),d1 
                  subq.w    #1,d1 
                  tst.b     FLG_BLIT_USE
                  beq.s     L0135 
                  moveq     #1,d0 
                  bsr       L0145 
L0135:            move.b    #0,$FFF00039.l
                  move.b    #$30,$FFF0001D.l
L0136:            btst      #3,$FFF00039.l
                  beq.s     L0136 
L0137:            bsr       L0141 
                  bsr       L012C 
                  tst.w     d0
                  bmi.s     L0138 
                  btst      #3,d0 
                  beq.s     L0138 
                  dbf       d1,L0137
                  moveq     #0,d0 
L0138:            move.b    #2,$FFF00039.l
                  rts 
L0139:            move.l    12(a7),d1 
                  move.w    8(a7),d2
                  move.w    10(a7),d0 
                  mulu      d0,d2 
                  divu      d2,d1 
                  move.b    d1,$FFF00011.l
                  lsr.l     #8,d1 
                  move.b    d1,$FFF00015.l
                  lsr.l     #8,d1 
                  divu      d0,d1 
                  move.w    22(a7),d0 
                  andi.b    #7,d0 
                  lsl.b     #4,d0 
                  or.b      d0,d1 
                  or.b      #-$60,d1
                  move.b    d1,$FFF00019.l
                  swap      d1
                  addq.w    #1,d1 
                  move.b    d1,$FFF0000D.l
                  rts 
L013A:            move.w    4(a7),d0
                  andi.b    #7,d0 
                  lsl.b     #4,d0 
                  or.b      #-$60,d0
                  move.b    d0,$FFF00019.l
                  movea.l   6(a7),a0
                  tst.b     FLG_BLIT_USE
                  beq.s     L013B 
                  moveq     #0,d0 
                  bsr       L0145 
L013B:            move.b    #0,$FFF00039.l
                  move.b    #-$14,$FFF0001D.l 
                  bsr       L012C 
                  tst.w     d0
                  bmi.s     L013C 
                  btst      #3,d0 
                  beq.s     L013C 
                  bsr       L013E 
                  moveq     #0,d0 
L013C:            move.b    #2,$FFF00039.l
                  rts 
L013D:            move.w    4(a7),d0
                  andi.b    #7,d0 
                  lsl.b     #4,d0 
                  or.b      #-$60,d0
                  move.b    d0,$FFF00019.l
                  move.b    7(a7),$FFF00009.l 
                  move.b    #-$1D,$FFF0001D.l 
                  bra       L012C 
L013E:            tst.b     FLG_BLIT_USE
                  beq.s     L013F 
                  move.w    #1,56(a1) 
                  move.b    #-$80,60(a1)
                  bsr       L0148 
                  addq.l    #2,50(a1) 
                  rts 
L013F:            moveq     #$1F,d0 
                  lea       $FFF00000.l,a1
L0140:            move.w    (a1),(a0)+
                  move.w    (a1),(a0)+
                  move.w    (a1),(a0)+
                  move.w    (a1),(a0)+
                  move.w    (a1),(a0)+
                  move.w    (a1),(a0)+
                  move.w    (a1),(a0)+
                  move.w    (a1),(a0)+
                  dbf       d0,L0140
                  rts 
L0141:            tst.b     FLG_BLIT_USE
                  beq.s     L0142 
                  move.w    #1,56(a1) 
                  move.b    #-$80,60(a1)
                  bsr       L0148 
                  addq.l    #2,36(a1) 
                  rts 
L0142:            moveq     #$1F,d0 
                  lea       $FFF00000.l,a1
L0143:            move.w    (a0)+,(a1)
                  move.w    (a0)+,(a1)
                  move.w    (a0)+,(a1)
                  move.w    (a0)+,(a1)
                  move.w    (a0)+,(a1)
                  move.w    (a0)+,(a1)
                  move.w    (a0)+,(a1)
                  move.w    (a0)+,(a1)
                  dbf       d0,L0143
                  rts 
                  move.w    #$5A5A,$FFF00000.l
                  move.w    $FFF00000.l,d0
                  cmpi.w    #$5A5A,d0 
                  bne.s     L0144 
                  moveq     #1,d0 
                  rts 
L0144:            moveq     #0,d0 
                  rts 
L0145:            lea       $FF8A00.l,a1
                  tst.b     d0
                  bne.s     L0146 
                  move.l    #-$100000,36(a1)
                  move.l    a0,50(a1) 
                  move.w    #2,46(a1) 
                  moveq     #0,d0 
                  move.w    d0,32(a1) 
                  bra.s     L0147 
L0146:            move.l    a0,36(a1) 
                  move.l    #-$100000,50(a1)
                  move.w    #2,32(a1) 
                  moveq     #0,d0 
                  move.w    d0,46(a1) 
L0147:            move.w    d0,34(a1) 
                  move.w    d0,48(a1) 
                  move.b    d0,61(a1) 
                  moveq     #-1,d0
                  move.l    d0,40(a1) 
                  move.w    d0,44(a1) 
                  move.w    #$203,58(a1)
                  move.w    #$100,54(a1)
                  rts 
L0148:            nop 
                  tas       60(a1)
                  bmi.s     L0148 
                  rts 
L0149:            movea.l   4(a7),a0
                  adda.l    #$50,a0 
                  move.l    a0,-(a7)
                  pea       L014C 
                  move.w    #6,-(a7)
                  bsr       L014D 
                  adda.w    #$A,a7
                  tst.w     d0
                  bne.s     L014A 
                  move.w    #$267,d0
                  move.w    #4,d1 
                  move.w    #$11,d2 
                  bra.s     L014B 
L014A:            movea.l   4(a7),a0
                  move.w    2(a0),d0
                  move.w    6(a0),d1
                  move.w    12(a0),d2 
L014B:            rts 
                  dc.b      'Conner',$00,$00
L014C:            dc.b      'CP2024',$00,$00
L014D:            movem.l   a0-a1/d1,-(a7)
                  move.w    16(a7),d1 
                  subq.w    #1,d1 
                  movea.l   18(a7),a0 
                  movea.l   22(a7),a1 
                  moveq     #1,d0 
L014E:            cmpm.b    (a0)+,(a1)+ 
                  bne.s     L014F 
                  dbf       d1,L014E
                  moveq     #0,d0 
L014F:            movem.l   (a7)+,a0-a1/d1
                  rts 
L0150:            ds.w      5,0 
L0151:            bsr       L015A 
                  lea       L0150,a0
                  move.b    #0,(a0) 
                  move.w    4(a7),d0
                  moveq     #6,d2 
                  bsr       L0162 
                  rts 
L0152:            bsr       L015A 
                  lea       L0150,a0
                  move.b    #3,(a0) 
                  move.b    7(a7),4(a0) 
                  moveq     #4,d1 
                  cmp.w     6(a7),d1
                  bcc.s     L0153 
                  move.w    6(a7),d1
L0153:            move.w    4(a7),d0
                  moveq     #6,d2 
                  movea.l   8(a7),a0
                  bsr       L0166 
                  rts 
L0154:            lea       L0150,a0
                  move.b    #8,(a0)+
                  move.b    5(a7),(a0)+ 
                  move.b    6(a7),(a0)+ 
                  move.b    7(a7),(a0)+ 
                  move.b    9(a7),(a0)+ 
                  clr.b     (a0)
                  move.w    14(a7),d0 
                  moveq     #0,d1 
                  move.w    8(a7),d1
                  lsl.l     #8,d1 
                  add.l     d1,d1 
                  moveq     #6,d2 
                  movea.l   10(a7),a0 
                  bsr       L0166 
                  rts 
L0155:            lea       L0150,a0
                  move.b    #$A,(a0)+ 
                  move.b    5(a7),(a0)+ 
                  move.b    6(a7),(a0)+ 
                  move.b    7(a7),(a0)+ 
                  move.b    9(a7),(a0)+ 
                  clr.b     (a0)
                  move.w    14(a7),d0 
                  moveq     #0,d1 
                  move.w    8(a7),d1
                  lsl.l     #8,d1 
                  add.l     d1,d1 
                  moveq     #6,d2 
                  movea.l   10(a7),a0 
                  bsr       L016A 
                  rts 
L0156:            bsr       L015A 
                  lea       L0150,a0
                  move.b    #$12,(a0) 
                  move.b    7(a7),4(a0) 
                  move.w    4(a7),d0
                  moveq     #0,d1 
                  move.w    6(a7),d1
                  moveq     #6,d2 
                  movea.l   8(a7),a0
                  bsr       L0166 
                  rts 
L0157:            bsr       L015A 
                  move.w    8(a7),d0
                  lsl.w     #6,d0 
                  or.b      7(a7),d0
                  lea       L0150,a0
                  move.b    #$1A,(a0) 
                  move.b    d0,2(a0)
                  move.b    11(a7),4(a0)
                  move.w    4(a7),d0
                  moveq     #0,d1 
                  move.w    10(a7),d1 
                  moveq     #6,d2 
                  movea.l   12(a7),a0 
                  bsr       L0166 
                  rts 
L0158:            lea       L0150,a0
                  move.b    #$28,(a0)+
                  clr.b     (a0)+ 
                  move.l    4(a7),(a0)+ 
                  clr.b     (a0)+ 
                  move.b    8(a7),(a0)+ 
                  move.b    9(a7),(a0)+ 
                  clr.b     (a0)
                  move.w    14(a7),d0 
                  moveq     #0,d1 
                  move.w    8(a7),d1
                  lsl.l     #8,d1 
                  add.l     d1,d1 
                  moveq     #$A,d2
                  movea.l   10(a7),a0 
                  bsr       L0166 
                  rts 
L0159:            lea       L0150,a0
                  move.b    #$2A,(a0)+
                  clr.b     (a0)+ 
                  move.l    4(a7),(a0)+ 
                  clr.b     (a0)+ 
                  move.b    8(a7),(a0)+ 
                  move.b    9(a7),(a0)+ 
                  clr.b     (a0)
                  move.w    14(a7),d0 
                  moveq     #0,d1 
                  move.w    8(a7),d1
                  lsl.l     #8,d1 
                  add.l     d1,d1 
                  moveq     #$A,d2
                  movea.l   10(a7),a0 
                  bsr       L016A 
                  rts 
L015A:            lea       L0150,a0
                  clr.l     (a0)+ 
                  clr.l     (a0)+ 
                  clr.w     (a0)
                  rts 
L015B:            move.l    d3,-(a7)
                  clr.l     L0161 
                  move.l    #1,-(a7)
                  move.w    #$20,-(a7) 	;SUPER
                  trap      #1
                  addq.w    #6,a7 
                  tst.w     d0
                  bne.s     L015C 
                  clr.l     -(a7) 
                  move.w    #$20,-(a7) 	;SUPER
                  trap      #1
                  addq.w    #6,a7 
                  move.l    d0,L0161
L015C:            moveq     #0,d3 
                  tst.l     $5A0.s
                  beq.s     L015F 
                  move.l    8(a7),d0
                  movea.l   $5A0.s,a0 
L015D:            move.l    (a0),d1 
                  beq.s     L015F 
                  cmp.l     d1,d0 
                  beq.s     L015E 
                  addq.w    #8,a0 
                  bra.s     L015D 
L015E:            moveq     #1,d3 
                  tst.l     12(a7)
                  beq.s     L015F 
                  movea.l   12(a7),a1 
                  move.l    4(a0),(a1)
L015F:            tst.l     L0161 
                  beq.s     L0160 
                  move.l    L0161,-(a7) 
                  move.w    #$20,-(a7) 	;SUPER
                  trap      #1
                  addq.w    #6,a7 
L0160:            move.l    d3,d0 
                  move.l    (a7)+,d3
                  rts 
L0161:            ds.w      2,0 
L0162:            btst      #3,d0 
                  bne.s     L0163 
                  bsr       L0117 
                  bra.s     L0165 
L0163:            tst.b     L004E 
                  beq.s     L0164 
                  bsr       L019E 
                  bra.s     L0165 
L0164:            bsr       L016E 
L0165:            rts 
L0166:            btst      #3,d0 
                  bne.s     L0167 
                  bsr       L0118 
                  bra.s     L0169 
L0167:            tst.b     L004E 
                  beq.s     L0168 
                  bsr       L01A0 
                  bra.s     L0169 
L0168:            bsr       L0170 
L0169:            rts 
L016A:            btst      #3,d0 
                  bne.s     L016B 
                  bsr       L0121 
                  bra.s     L016D 
L016B:            tst.b     L004E 
                  beq.s     L016C 
                  bsr       L01A8 
                  bra.s     L016D 
L016C:            bsr       L0175 
L016D:            rts 
L016E:            andi.w    #7,d0 
                  bsr       L0179 
                  bpl.s     L016F 
                  rts 
L016F:            bra       L018C 
L0170:            andi.w    #7,d0 
                  move.w    d2,-(a7)
                  bsr       L0179 
                  move.w    (a7)+,d2
                  tst.w     d0
                  bmi       L0174 
                  move.b    #0,-$787D.s 
                  move.b    #1,-$7879.s 
                  move.b    -$7871.s,d0 
                  move.b    #2,-$787B.s 
                  move.b    #0,-$7871.s 
                  move.w    #0,-$78EC.s 
                  move.w    #2,-$78EC.s 
                  bsr       L0199 
                  cmpi.w    #6,d2 
                  beq.s     L0171 
                  bsr       L019B 
L0171:            bsr       L0186 
                  tst.w     d0
                  bne.s     L0174 
                  bsr       L018C 
                  tst.w     d0
                  bne.s     L0174 
                  move.l    d0,-(a7)
                  move      sr,-(a7)
                  ori.w     #$700,sr
                  movec     cacr,d0 
                  ori.w     #$808,d0
                  movec     d0,cacr 
                  move      (a7)+,sr
                  move.b    -$78F9.s,d0 
                  andi.w    #3,d0 
                  beq.s     L0173 
                  movea.l   #-$78FF,a1
                  movep.l   0(a1),d0
                  move.l    d0,d1 
                  andi.w    #3,d0 
                  andi.w    #-4,d1
                  movea.l   d1,a0 
                  move.l    -$78F0.s,d1 
                  subq.w    #1,d0 
L0172:            rol.l     #8,d1 
                  move.b    d1,(a0)+
                  dbf       d0,L0172
L0173:            move.l    (a7)+,d0
L0174:            rts 
L0175:            andi.w    #7,d0 
                  move.w    d2,-(a7)
                  bsr       L0179 
                  move.w    (a7)+,d2
                  tst.w     d0
                  bpl.s     L0176 
                  rts 
L0176:            move.b    #0,-$7879.s 
                  move.b    -$7871.s,d0 
                  move.b    #2,-$787B.s 
                  move.b    #0,-$7875.s 
                  move.w    #1,-$78EC.s 
                  move.w    #3,-$78EC.s 
                  bsr       L0199 
                  cmpi.w    #6,d2 
                  beq.s     L0177 
                  bsr       L019B 
L0177:            bsr       L0186 
                  tst.w     d0
                  bne.s     L0178 
                  bsr       L018C 
L0178:            rts 
L0179:            movem.l   a0/d1-d2,-(a7)
                  move.w    d0,-(a7)
                  bsr       L017C 
                  addq.l    #2,a7 
                  movem.l   (a7)+,a0/d1-d2
                  tst.w     d0
                  bmi.s     L017B 
                  move.l    a0,d0 
                  movea.l   #-$78FF,a1
                  movep.l   d0,0(a1)
                  movea.l   #-$78F7,a1
                  movep.l   d1,0(a1)
                  move.b    #2,-$7879.s 
                  move.b    #1,-$787D.s 
                  bsr       L0199 
                  lea       L0150,a1
                  subq.w    #1,d2 
L017A:            move.b    (a1)+,d0
                  bsr       L0197 
                  tst.w     d0
                  bmi.s     L017B 
                  dbf       d2,L017A
                  moveq     #0,d0 
L017B:            rts 
L017C:            bsr       L0199 
L017D:            btst      #6,-$7877.s 
                  beq.s     L017E 
                  cmp.l     (a0),d1 
                  bhi.s     L017D 
                  bra.s     L0180 
L017E:            move.b    #0,-$7879.s 
                  move.b    #0,-$7877.s 
                  move.b    #$C,-$787D.s
                  clr.w     d0
                  move.w    4(a7),d1
                  bset      d1,d0 
                  move.b    d0,-$787F.s 
                  move.b    #$D,-$787D.s
                  andi.b    #-2,-$787B.s
                  andi.b    #-9,-$787D.s
                  nop 
                  nop 
                  bsr       L0199 
L017F:            btst      #6,-$7877.s 
                  bne.s     L0181 
                  cmp.l     (a0),d1 
                  bhi.s     L017F 
L0180:            moveq     #-1,d0
                  bra.s     L0182 
L0181:            clr.w     d0
L0182:            move.b    #0,-$787D.s 
                  rts 
L0183:            move.b    #-$80,-$787D.s
                  bsr       L0199 
L0184:            cmp.l     (a0),d1 
                  bhi.s     L0184 
                  move.b    #0,-$787D.s 
                  bsr       L019A 
L0185:            cmp.l     (a0),d1 
                  bhi.s     L0185 
                  rts 
L0186:            add.l     L000A,d1
L0187:            btst      #7,-$57F.s
                  bne.s     L018A 
                  cmp.l     (a0),d1 
                  bls.s     L0188 
                  btst      #5,-$57F.s
                  beq.s     L0189 
                  cmp.l     (a0),d1 
                  bhi.s     L0187 
L0188:            bsr.s     L0183 
                  moveq     #-1,d0
                  bra.s     L018B 
L0189:            move.w    -$78EC.s,d0 
                  andi.l    #$80,d0 
                  beq.s     L0187 
                  move.w    d0,-(a7)
                  bsr.s     L0183 
                  move.w    (a7)+,d0
                  bra.s     L018B 
L018A:            moveq     #0,d0 
                  move.b    -$7871.s,d1 
                  move.w    #0,-$78EC.s 
                  move.b    #0,-$787B.s 
                  move.b    #0,-$787D.s 
L018B:            rts 
L018C:            bsr       L0199 
                  move.b    #3,-$7879.s 
                  move.b    -$7871.s,d0 
                  bsr       L0190 
                  bmi.s     L018F 
                  moveq     #0,d0 
                  move.b    -$787F.s,d0 
                  move.l    d0,-(a7)
                  bsr       L0199 
                  bsr       L0193 
                  tst.w     d0
                  beq.s     L018E 
L018D:            addq.l    #4,a7 
                  bra.s     L018F 
L018E:            bsr       L0199 
                  bsr       L0190 
                  bmi.s     L018D 
                  move.b    -$787F.s,d0 
                  bsr       L0193 
                  tst.w     d0
                  bmi.s     L018D 
                  move.l    (a7)+,d0
L018F:            rts 
                  add.l     L000A,d1
L0190:            btst      #5,-$7877.s 
                  bne.s     L0191 
                  cmp.l     (a0),d1 
                  bhi.s     L0190 
                  moveq     #-1,d0
                  bra.s     L0192 
L0191:            moveq     #0,d0 
L0192:            rts 
L0193:            ori.b     #$11,-$787D.s 
L0194:            btst      #5,-$7877.s 
                  beq.s     L0195 
                  cmp.l     (a0),d1 
                  bhi.s     L0194 
                  moveq     #-1,d0
                  bra.s     L0196 
L0195:            moveq     #0,d0 
L0196:            andi.b    #-$11,-$787D.s
                  rts 
L0197:            move.w    d0,-(a7)
                  bsr.s     L0190 
                  bmi.s     L0198 
                  move.b    1(a7),-$787F.s
                  bsr.s     L0193 
L0198:            addq.l    #2,a7 
                  rts 
L0199:            movea.l   #$4BA,a0
                  move.l    L0009,d1
                  add.l     (a0),d1 
                  rts 
L019A:            movea.l   #$4BA,a0
                  move.l    L0008,d1
                  add.l     (a0),d1 
                  rts 
L019B:            movea.l   #$4BA,a0
                  move.l    L0007,d1
                  add.l     (a0),d1 
                  rts 
L019C:            dc.b      $00,$00 
L019D:            dc.b      $00,$00 
L019E:            st        FLOCK.s 
                  andi.w    #7,d0 
                  bsr       L01AF 
                  tst.w     d0
                  bmi.s     L019F 
                  bsr       L01C6 
L019F:            move.w    #$8F,FIFO.s 
                  move.w    DISKCTL.s,d1
                  bra       L0116 
L01A0:            st        FLOCK.s 
                  andi.w    #7,d0 
                  movem.l   a0/d1-d2,-(a7)
                  bsr       L01AF 
                  movem.l   (a7)+,a0/d1-d2
                  tst.w     d0
                  bmi       L01A7 
                  sf        L019D 
                  move.l    d1,d0 
                  andi.l    #$F,d0
                  beq.s     L01A1 
                  st        L019D 
L01A1:            move.w    #$89,FIFO.s 
                  move.w    #0,DISKCTL.s
                  move.w    #$8B,FIFO.s 
                  move.w    #1,DISKCTL.s
                  move.w    #$8F,FIFO.s 
                  move.w    DISKCTL.s,d0
                  move.w    #$8A,FIFO.s 
                  move.w    #2,DISKCTL.s
                  movea.l   #-$79FC,a1
                  bsr       L0126 
                  move.w    #$190,2(a1) 
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  move.w    #$90,2(a1)
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  bsr       L0127 
L01A2:            btst      #3,-$79F1.s 
                  bne.s     L01A2 
                  move.w    #$8F,FIFO.s 
                  move.w    #0,DISKCTL.s
                  move.w    #0,FIFO.s 
                  moveq     #0,d0 
                  cmpi.w    #6,d2 
                  beq.s     L01A3 
                  move.l    L0007,d0
L01A3:            bsr       L01C0 
                  tst.w     d0
                  bne.s     L01A7 
                  tst.b     L019D 
                  beq.s     L01A4 
                  move.w    #$20,FIFO.s 
L01A4:            tst.b     FLG_CPU030
                  beq.s     L01A6 
                  move      sr,-(a7)
                  ori.w     #$700,sr
                  movec     cacr,d0 
                  ori.w     #$808,d0
                  movec     d0,cacr 
                  move      (a7)+,sr
                  bra.s     L01A6 
                  movea.l   a0,a1 
L01A5:            bsr       L01C8 
                  bmi.s     L01A7 
                  move.w    #$8D,FIFO.s 
                  move.w    DISKCTL.s,d0
                  btst      #3,d0 
                  beq       L01A6 
                  move.w    #$88,FIFO.s 
                  move.w    DISKCTL.s,d0
                  move.b    d0,(a1)+
                  bsr       L01D0 
                  bra.s     L01A5 
L01A6:            bsr       L01C6 
L01A7:            move.w    #$8F,FIFO.s 
                  move.w    DISKCTL.s,d1
                  bra       L0116 
L01A8:            st        FLOCK.s 
                  andi.w    #7,d0 
                  movem.l   a0/d1-d2,-(a7)
                  bsr       L01AF 
                  movem.l   (a7)+,a0/d1-d2
                  tst.w     d0
                  bmi       L01AE 
                  move.w    #$8B,FIFO.s 
                  move.w    #0,DISKCTL.s
                  move.w    #$8F,FIFO.s 
                  move.w    DISKCTL.s,d0
                  cmpi.l    #$200,d1
                  bcs.s     L01AB 
                  move.w    #$8A,FIFO.s 
                  move.w    #2,DISKCTL.s
                  movea.l   #-$79FC,a1
                  bsr       L0126 
                  move.w    #$90,2(a1)
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  move.w    #$190,2(a1) 
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  bsr       L0127 
L01A9:            btst      #3,-$79F1.s 
                  bne.s     L01A9 
                  move.w    #$18D,FIFO.s
                  move.w    #0,DISKCTL.s
                  move.w    #$100,FIFO.s
                  moveq     #0,d0 
                  cmpi.w    #6,d2 
                  beq.s     L01AA 
                  move.l    L0007,d0
L01AA:            bsr       L01C0 
                  tst.w     d0
                  beq.s     L01AD 
                  bra.s     L01AE 
L01AB:            movea.l   a0,a1 
L01AC:            bsr       L01C8 
                  bmi.s     L01AE 
                  move.w    #$8D,FIFO.s 
                  move.w    DISKCTL.s,d0
                  btst      #3,d0 
                  beq.s     L01AD 
                  moveq     #0,d0 
                  move.b    (a1)+,d0
                  move.w    #$88,FIFO.s 
                  move.w    d0,DISKCTL.s
                  bsr       L01D0 
                  bra.s     L01AC 
L01AD:            bsr       L01C6 
L01AE:            move.w    #$8F,FIFO.s 
                  move.w    DISKCTL.s,d1
                  bra       L0116 
L01AF:            movem.l   a0/d1-d2,-(a7)
                  move.w    d0,-(a7)
                  bsr       L01B2 
                  addq.l    #2,a7 
                  movem.l   (a7)+,a0/d1-d2
                  tst.w     d0
                  bmi.s     L01B1 
                  move.w    #$8B,FIFO.s 
                  move.w    #2,DISKCTL.s
                  move.w    #$89,FIFO.s 
                  move.w    #1,DISKCTL.s
                  lea       L0150,a1
                  subq.w    #1,d2 
L01B0:            bsr       L01C9 
                  bmi.s     L01B1 
                  move.b    (a1)+,d0
                  move.w    #$88,FIFO.s 
                  move.w    d0,DISKCTL.s
                  bsr       L01D0 
                  dbf       d2,L01B0
                  moveq     #0,d0 
L01B1:            rts 
L01B2:            move.l    L0009,d1
                  move.w    #$8C,FIFO.s 
L01B3:            move.w    DISKCTL.s,d0
                  btst      #6,d0 
                  beq.s     L01B6 
L01B4:            cmpi.b    #$60,TCDR.s 
                  bge.s     L01B4 
L01B5:            cmpi.b    #$60,TCDR.s 
                  blt.s     L01B5 
                  dbf       d1,L01B3
                  bra       L01BA 
L01B6:            move.w    #$8B,FIFO.s 
                  move.w    #0,DISKCTL.s
                  move.w    #$8C,FIFO.s 
                  move.w    #0,DISKCTL.s
                  move.w    #$89,FIFO.s 
                  move.w    #$C,DISKCTL.s 
                  clr.w     d0
                  move.w    4(a7),d1
                  bset      d1,d0 
                  move.w    #$88,FIFO.s 
                  move.w    d0,DISKCTL.s
                  move.w    #$89,FIFO.s 
                  move.w    #5,DISKCTL.s
                  move.w    #$8A,FIFO.s 
                  move.w    DISKCTL.s,d0
                  andi.b    #-2,d0
                  move.w    d0,DISKCTL.s
                  move.w    #$89,FIFO.s 
                  move.w    DISKCTL.s,d0
                  andi.b    #-9,d0
                  move.w    d0,DISKCTL.s
                  nop 
                  nop 
                  move.l    L0009,d1
                  move.w    #$8C,FIFO.s 
L01B7:            move.w    DISKCTL.s,d0
                  btst      #6,d0 
                  bne.s     L01BB 
L01B8:            cmpi.b    #$60,TCDR.s 
                  bge.s     L01B8 
L01B9:            cmpi.b    #$60,TCDR.s 
                  blt.s     L01B9 
                  dbf       d1,L01B7
L01BA:            moveq     #-1,d0
                  bra.s     L01BC 
L01BB:            clr.w     d0
L01BC:            move.w    #$89,FIFO.s 
                  move.w    #0,DISKCTL.s
                  rts 
L01BD:            btst      #3,-$79F1.s 
                  bne.s     L01BD 
                  move.w    #$190,FIFO.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  move.w    #$90,FIFO.s 
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  tst.b     GPIP.s
                  move.w    #$89,FIFO.s 
                  move.w    #$80,DISKCTL.s
                  bsr       L0199 
L01BE:            cmp.l     (a0),d1 
                  bhi.s     L01BE 
                  move.w    #$89,FIFO.s 
                  move.w    #0,DISKCTL.s
                  bsr       L019A 
L01BF:            cmp.l     (a0),d1 
                  bhi.s     L01BF 
                  rts 
L01C0:            move.l    L000A,d1
                  add.l     d0,d1 
L01C1:            btst      #5,GPIP.s 
                  beq.s     L01C4 
L01C2:            cmpi.b    #$60,TCDR.s 
                  bge.s     L01C2 
L01C3:            cmpi.b    #$60,TCDR.s 
                  blt.s     L01C3 
                  dbf       d1,L01C1
                  bsr       L01BD 
                  moveq     #-1,d0
                  bra.s     L01C5 
L01C4:            moveq     #0,d0 
                  move.w    #$8F,FIFO.s 
                  move.w    DISKCTL.s,d1
                  move.w    #$8A,FIFO.s 
                  move.w    #0,DISKCTL.s
                  move.w    #$89,FIFO.s 
                  move.w    #0,DISKCTL.s
L01C5:            rts 
L01C6:            move.w    #$8B,FIFO.s 
                  move.w    #3,DISKCTL.s
                  move.w    #$8F,FIFO.s 
                  move.w    DISKCTL.s,d0
                  bsr       L01C9 
                  bmi.s     L01C7 
                  move.w    #$88,FIFO.s 
                  move.w    DISKCTL.s,d0
                  andi.w    #$FF,d0 
                  move.w    d0,L019C
                  bsr       L01D0 
                  bsr       L01C9 
                  bmi.s     L01C7 
                  move.w    #$88,FIFO.s 
                  move.w    DISKCTL.s,d0
                  bsr       L01D0 
                  move.w    L019C,d0
L01C7:            rts 
L01C8:            move.l    L000A,d1
                  bra.s     L01CA 
L01C9:            move.l    L0009,d1
L01CA:            move.w    #$8C,FIFO.s 
L01CB:            move.w    DISKCTL.s,d0
                  btst      #5,d0 
                  bne.s     L01CE 
L01CC:            cmpi.b    #$60,TCDR.s 
                  bge.s     L01CC 
L01CD:            cmpi.b    #$60,TCDR.s 
                  blt.s     L01CD 
                  dbf       d1,L01CB
                  moveq     #-1,d0
                  bra.s     L01CF 
L01CE:            moveq     #0,d0 
L01CF:            rts 
L01D0:            move.l    d1,-(a7)
                  move.w    #$FF,d1 
                  move.w    #$89,FIFO.s 
                  move.w    DISKCTL.s,d0
                  ori.b     #$11,d0 
                  move.w    d0,DISKCTL.s
                  move.w    #$8B,FIFO.s 
L01D1:            move.w    DISKCTL.s,d0
                  btst      #3,d0 
                  bne.s     L01D2 
                  dbf       d1,L01D1
L01D2:            move.w    #$89,FIFO.s 
                  move.w    DISKCTL.s,d0
                  andi.b    #-$11,d0
                  move.w    d0,DISKCTL.s
                  moveq     #0,d0 
                  move.l    (a7)+,d1
                  rts 
FLG_TTSCSI_FND:   dc.b      $00 
FLG_F030SCSI_FND: dc.b      $00 
L01D5:            dc.b      $00,$00 
FLG_IDE_EXIST:    dc.b      $00,$00 
_INSTALL:         move.l    d0,L0026
                  movea.l   #L022F,a0 
                  bsr       L022B 
                  tst.w     L0025 
                  bne.s     L01D8 
                  clr.l     -(a7) 
                  move.w    #$20,-(a7) 	;SUPER
                  trap      #1
                  addq.l    #6,a7 
                  move.l    d0,L0046
L01D8:            move.l    #L0029,-(a7)
                  move.l    #$5F4D4348,-(a7)
                  bsr       L015B 
                  addq.w    #8,a7 
                  sf        FLG_CPU030
                  movea.l   ILLE_EXC.s,a0 
                  move.l    #L01D9,ILLE_EXC.s 
                  movea.l   a7,a1 
                  movec     cacr,d0 
                  st        FLG_CPU030
L01D9:            move.l    a0,ILLE_EXC.s 
                  movea.l   a1,a7 
                  sf        FLG_IDE_EXIST 
                  movea.l   BUS_ERR.s,a1
                  move.l    #L01DF,BUS_ERR.s
                  movea.l   a7,a2 
                  move.b    $FFF00011.l,d0
                  move.l    #$3E8,d1
L01DA:            cmpi.b    #$50,$FFF0001D.l
                  beq.s     L01DD 
L01DB:            cmpi.b    #$60,TCDR.s 
                  bge.s     L01DB 
L01DC:            cmpi.b    #$60,TCDR.s 
                  blt.s     L01DC 
                  dbf       d1,L01DA
                  bra.s     L01DF 
L01DD:            move.b    #$5A,$FFF00009.l
                  move.b    $FFF00009.l,d0
                  cmpi.b    #$5A,d0 
                  bne.s     L01DF 
                  st        FLG_IDE_EXIST 
                  sf        FLG_BLIT_USE
                  lea       L022E(pc),a0
                  movem.l   a0-a2,-(a7) 
                  move.w    #-1,-(a7) 
                  move.w    #$40,-(a7)
                  trap      #$E 
                  addq.w    #4,a7 
                  movem.l   (a7)+,a0-a2 
                  btst      #1,d0 
                  beq.s     L01DE 
                  bsr       L0229 
                  tst.w     d0
                  bne.s     L01DE 
                  tst.b     PUNINF_BLIT_USE 
                  bne.s     L01DE 
                  st        FLG_BLIT_USE
                  lea       L022D(pc),a0
L01DE:            movem.l   a1-a2,-(a7) 
                  bsr       L022B 
                  movem.l   (a7)+,a1-a2 
L01DF:            move.l    a1,BUS_ERR.s
                  movea.l   a2,a7 
                  sf        L004E 
                  cmpi.l    #$30000,L0029 
                  bne.s     L01E0 
                  st        L004E 
                  sf        FLG_TTSCSI_FND
                  sf        FLG_F030SCSI_FND
                  bra.s     L01E3 
L01E0:            sf        FLG_TTSCSI_FND
                  movea.l   BUS_ERR.s,a0
                  move.l    #L01E1,BUS_ERR.s
                  movea.l   a7,a1 
                  move.b    -$787F.s,d0 
                  st        FLG_TTSCSI_FND
L01E1:            move.l    a0,BUS_ERR.s
                  movea.l   a1,a7 
                  sf        FLG_F030SCSI_FND
                  movea.l   BUS_ERR.s,a0
                  move.l    #L01E2,BUS_ERR.s
                  movea.l   a7,a1 
                  move.w    DISKCTL.s,d0
                  st        FLG_F030SCSI_FND
L01E2:            move.l    a0,BUS_ERR.s
                  movea.l   a1,a7 
L01E3:            move.w    #$D,d1
                  moveq     #-1,d0
                  lea       L0014,a0
L01E4:            move.b    d0,(a0)+
                  dbf       d1,L01E4
                  moveq     #0,d0 
                  move.w    d0,L0238
                  move.l    #4,L0239
                  move.w    d0,PUN_INFO 
                  move.w    d0,L001A
                  move.w    L0004,MAX_SECTOR
                  move.l    _DSKBUFP.s,_SEC0_BUF
                  addi.l    #$200,_SEC0_BUF 
                  tst.b     FLG_IDE_EXIST 
                  beq.s     L01E6 
                  tst.b     L000C 
                  beq.s     L01E5 
                  btst      #0,L000F
                  beq.s     L01E6 
L01E5:            movea.l   #L0230,a0 
                  bsr       L022B 
                  move.w    #$10,_CURR_DEV
                  bra       L01F4 
L01E6:            tst.b     L004E 
                  bne.s     L01E7 
                  tst.b     FLG_TTSCSI_FND
                  beq       L01EE 
L01E7:            move.w    #7,_CURR_DEV
                  move.b    #0,L023C
                  tst.b     L004E 
                  beq.s     L01E8 
                  bsr       L01BD 
                  bra.s     L01E9 
L01E8:            bsr       L0183 
L01E9:            tst.b     L000C 
                  beq.s     L01EA 
                  tst.b     L000E 
                  beq       L01EE 
L01EA:            movea.l   #L0231,a0 
                  bsr       L022B 
L01EB:            move.w    _CURR_DEV,d0
                  addq.w    #1,d0 
                  move.w    d0,_CURR_DEV
                  cmpi.w    #$F,d0
                  bhi       L01EE 
                  tst.b     L000C 
                  beq.s     L01ED 
                  andi.b    #7,d0 
L01EC:            btst      d0,L000E
                  bne       L01F3 
                  addq.w    #1,d0 
                  cmpi.w    #8,d0 
                  bcc       L01EE 
                  addq.w    #1,_CURR_DEV
                  bra.s     L01EC 
L01ED:            tst.b     L023C 
                  beq       L01F3 
L01EE:            tst.b     FLG_F030SCSI_FND
                  beq       L0204 
                  move.w    #-1,_CURR_DEV 
                  move.b    #0,L023C
                  tst.b     L000C 
                  beq.s     L01EF 
                  tst.b     L000D 
                  beq       L0204 
L01EF:            movea.l   #L0232,a0 
                  bsr       L022B 
L01F0:            move.w    _CURR_DEV,d0
                  addq.w    #1,d0 
                  move.w    d0,_CURR_DEV
                  cmpi.w    #7,d0 
                  bhi       L0204 
                  tst.b     L000C 
                  beq.s     L01F2 
                  andi.b    #7,d0 
L01F1:            btst      d0,L000D
                  bne       L01F3 
                  addq.w    #1,d0 
                  cmpi.w    #8,d0 
                  bcc       L0204 
                  addq.w    #1,_CURR_DEV
                  bra.s     L01F1 
L01F2:            tst.b     L023C 
                  bne       L0204 
L01F3:            moveq     #1,d3 
L01F4:            move.w    d3,-(a7)
                  move.w    _CURR_DEV,d0
                  andi.w    #7,d0 
                  add.b     #$30,d0 	;#'0'
                  move.b    d0,L0234
                  movea.l   #L0233,a0 
                  bsr       L022B 
                  move.w    (a7)+,d3
L01F5:            movea.l   _SEC0_BUF,a0
                  clr.l     (a0)
                  move.l    a0,-(a7)
                  btst      #4,L002B
                  beq       L01F6 
                  move.w    _CURR_DEV,-(a7) 
                  bsr       L013A 
                  addq.w    #6,a7 
                  tst.w     d0
                  bne       L0201 
                  movea.l   _SEC0_BUF,a0
                  move.b    #0,94(a0) 
                  adda.l    #$36,a0 
                  bsr       L022B 
                  movea.l   #L0236,a0 
                  bsr       L022B 
                  move.l    _SEC0_BUF,-(a7) 
                  bsr       L0149 
                  addq.l    #4,a7 
                  lea       L001E,a1
                  move.w    d1,(a1)+
                  move.w    d2,(a1) 
                  bra       L01FA 
L01F6:            st        L0109 
                  move.w    #$38,-(a7)
                  move.w    _CURR_DEV,-(a7) 
                  bsr       L0156 
                  addq.l    #8,a7 
                  sf        L0109 
                  tst.w     d0
                  bmi       L0201 
                  dbeq      d3,L01F5
                  tst.w     d0
                  beq.s     L01F7 
                  movea.l   #L0237,a0 
                  bsr       L022B 
                  cmp.w     #2,d0 
                  bne       L01FA 
                  bra       L0203 
L01F7:            movea.l   _SEC0_BUF,a0
                  move.b    #0,32(a0) 
                  addq.l    #8,a0 
                  bsr       L022B 
                  movea.l   #L0236,a0 
                  bsr       L022B 
                  movea.l   _SEC0_BUF,a0
                  move.b    (a0),d0 
                  cmp.b     #7,d0 
                  beq.s     L01F8 
                  tst.b     d0
                  bne       L0203 
L01F8:            btst      #3,L002B
                  bne.s     L01F9 
                  move.w    _CURR_DEV,d1
                  andi.w    #7,d1 
                  bset      d1,L0031
L01F9:            btst      #7,1(a0)
                  beq.s     L01FA 
                  bset      #6,L002B
L01FA:            btst      #6,L002B
                  bne.s     L01FB 
                  move.w    #$FFF,L01D5 
                  bra       L01FC 
L01FB:            move.w    #2,L01D5
                  st        L0109 
                  move.l    _SEC0_BUF,-(a7) 
                  move.w    #$2A,-(a7)
                  clr.w     -(a7) 
                  move.w    #$2E,-(a7)
                  move.w    _CURR_DEV,-(a7) 
                  subi.w    #$40,(a7) 
                  bsr       L0111 
                  bsr       L0111 
                  bsr       L0111 
                  bsr       L0157 
                  adda.w    #$C,a7
                  sf        L0109 
L01FC:            move.w    _CURR_DEV,-(a7) 
                  addq.w    #2,(a7) 
                  clr.w     -(a7) 
                  move.w    #1,-(a7)
                  move.l    _SEC0_BUF,-(a7) 
                  move.w    #$A,-(a7) 
                  bsr       _DO_RW
                  adda.w    #$C,a7
                  cmp.w     #-2,d0
                  bne.s     L01FD 
                  bsr       L019B 
                  subq.w    #1,L01D5
                  bne.s     L01FC 
L01FD:            move.w    d0,L023B
                  beq.s     L01FE 
                  btst      #6,L002B
                  beq.s     L0202 
L01FE:            addq.w    #1,PUN_INFO 
                  btst      #4,L002B
                  bne.s     L0200 
                  btst      #3,L002B
                  beq.s     L01FF 
                  addq.w    #1,L001B
                  bra.s     L0200 
L01FF:            addq.w    #1,L001A
L0200:            bsr       L0205 
                  tst.w     d0
                  beq.s     L0203 
                  cmpi.w    #-$E,d0 
                  beq       L01F3 
                  bra.s     L0203 
L0201:            movea.l   #L0235,a0 
                  bsr       L022B 
L0202:            move.b    #1,L023C
L0203:            andi.w    #$1F,_CURR_DEV
                  btst      #4,L002B
                  bne       L01E6 
                  btst      #3,L002B
                  bne       L01EB 
                  bra       L01F0 
L0204:            suba.l    a5,a5 
                  move.l    HDV_BPB(a5),OLD_BPB 
                  move.l    HDV_RW(a5),OLD_RW 
                  move.l    HDV_MEDIACH(a5),OLD_MEDIACH 
                  move.l    #NEW_BPB,HDV_BPB(a5)
                  move.l    #NEW_RW,HDV_RW(a5)
                  move.l    #NEW_MEDIACH,HDV_MEDIACH(a5)
                  move.l    #PUN_INFO,PUN_PTR(a5) 
                  move.l    #L0016,L0017
                  bra       L00DE 
L0205:            move.w    #0,L002C
                  btst      #6,L002B
                  beq.s     L0206 
                  tst.w     L023B 
                  bne.s     L020B 
L0206:            moveq     #3,d1 
                  movea.l   _SEC0_BUF,a0
                  cmpi.w    #$55AA,510(a0)
                  bne.s     L0207 
                  bsr       L0211 
                  bra.s     L0208 
L0207:            bsr       L0219 
L0208:            tst.w     d0
                  bne.s     L0210 
                  btst      #6,L002B
                  beq.s     L0210 
                  move.w    _CURR_DEV,d1
                  btst      #3,d1 
                  bne.s     L0209 
                  lea       L0005,a0
                  bra.s     L020A 
L0209:            lea       L0006,a0
L020A:            andi.w    #7,d1 
                  move.b    0(a0,d1.w),d1 
                  sub.w     L002C,d1
                  bls.s     L0210 
                  bra.s     L020E 
L020B:            move.w    _CURR_DEV,d1
                  btst      #3,d1 
                  bne.s     L020C 
                  lea       L0005,a0
                  bra.s     L020D 
L020C:            lea       L0006,a0
L020D:            andi.w    #7,d1 
                  move.b    0(a0,d1.w),d1 
L020E:            subq.w    #1,d1 
L020F:            move.w    d1,-(a7)
                  bsr       L0224 
                  move.w    (a7)+,d1
                  tst.w     d0
                  bmi.s     L0210 
                  dbf       d1,L020F
L0210:            rts 
L0211:            adda.w    #$1BE,a0
L0212:            movem.l   a0/d1,-(a7) 
                  sf        L0049 
                  bsr       L006D 
                  tst.b     d0
                  beq.s     L0217 
                  cmpi.b    #5,d0 
                  bne.s     L0214 
                  st        L0049 
                  move.l    #0,L004B
                  move.l    d1,L004A
L0213:            bsr       L0071 
                  tst.b     d0
                  beq.s     L0217 
                  bmi.s     L0215 
                  cmpi.b    #5,d0 
                  beq.s     L0213 
L0214:            movem.l   a0/d1-d2,-(a7)
                  bsr       L0222 
                  movem.l   (a7)+,a0/d1-d2
                  tst.w     d0
                  beq.s     L0216 
L0215:            addq.l    #8,a7 
                  bra.s     L0218 
L0216:            tst.b     L0049 
                  bne.s     L0213 
L0217:            movem.l   (a7)+,a0/d1 
                  adda.w    #$10,a0 
                  dbf       d1,L0212
                  moveq     #0,d0 
L0218:            rts 
L0219:            adda.w    #$1C2,a0
                  tst.l     (a0)+ 
                  beq.s     L0220 
L021A:            movem.l   a0/d1,-(a7) 
                  sf        L0049 
                  bsr       L0080 
                  tst.b     d0
                  beq.s     L021F 
                  cmpi.b    #$58,d0 
                  bne.s     L021C 
                  st        L0049 
                  move.l    #0,L004B
                  move.l    d1,L004A
L021B:            bsr       L0086 
                  tst.b     d0
                  beq.s     L021F 
                  bmi.s     L021D 
                  cmpi.b    #$58,d0 
                  beq.s     L021B 
L021C:            movem.l   a0/d1-d2,-(a7)
                  bsr       L0222 
                  movem.l   (a7)+,a0/d1-d2
                  tst.w     d0
                  beq.s     L021E 
L021D:            addq.l    #8,a7 
                  bra.s     L0221 
L021E:            tst.b     L0049 
                  bne.s     L021B 
L021F:            movem.l   (a7)+,a0/d1 
                  adda.w    #$C,a0
                  dbf       d1,L021A
L0220:            moveq     #0,d0 
L0221:            rts 
L0222:            cmpi.w    #$E,L0238 
                  bge       L0227 
                  move.l    d1,-(a7)
                  move.w    _CURR_DEV,-(a7) 
                  addq.w    #2,(a7) 
                  move.w    #-1,-(a7) 
                  move.w    #1,-(a7)
                  move.l    #L023A,-(a7)
                  move.w    #$A,-(a7) 
                  bsr       _DO_RW
                  adda.w    #$10,a7 
                  tst.w     d0
                  bne       L0228 
                  movea.l   #L023A,a0 
                  moveq     #$B,d0
                  bsr       L0098 
                  tst.w     d0
                  beq.s     L0225 
                  cmp.w     MAX_SECTOR,d0 
                  bls.s     L0223 
                  move.w    d0,MAX_SECTOR 
L0223:            moveq     #9,d1 
                  lsr.w     d1,d0 
                  move.w    d0,L003D
                  bra.s     L0226 
L0224:            cmpi.w    #$E,L0238 
                  bge       L0227 
L0225:            move.w    #1,L003D
L0226:            move.l    L0239,d1
                  move.l    _DRVBITS.s,d0 
                  or.l      d1,d0 
                  move.l    d0,_DRVBITS.s 
                  asl.l     #1,d1 
                  move.l    d1,L0239
                  move.w    L0238,d0
                  lea       L0014,a0
                  move.b    L002B,0(a0,d0.w)
                  lea       L0021,a0
                  move.b    L003E,0(a0,d0.w)
                  lea       L001D,a0
                  move.b    #1,0(a0,d0.w) 
                  lea       L001C,a0
                  move.b    #2,0(a0,d0.w) 
                  addq.w    #1,L0238
                  addq.w    #1,L002C
                  moveq     #0,d0 
                  bra.s     L0228 
L0227:            moveq     #-1,d0
L0228:            rts 
L0229:            moveq     #1,d0 
                  cmpi.l    #$10008,L0029 
                  beq.s     L022A 
                  moveq     #0,d0 
L022A:            rts 
L022B:            tst.b     L004D 
                  bne.s     L022C 
                  move.l    a0,-(a7)
                  move.w    #9,-(a7) 	;CCONWS 
                  trap      #1
                  addq.l    #6,a7 
L022C:            rts 
L022D:            dc.b      'Using BLiTTER for IDE I/O',$D,$A 
                  dc.b      0 
L022E:            dc.b      'Doing programmed I/O for IDE',$D,$A
                  dc.b      0,0 
L022F:            dc.b      'Loading...',$D,$A
                  dc.b      '------------------------',$D,$A
                  dc.b      'Atari ž-Hard Disk Driver',$D,$A
                  dc.b      'AHDI 6.06a July 17, 1993',$D,$A,$A
                  dc.b      'a) lrecno, mode logical ',$D,$A
                  dc.b      'b) random boot waittime ',$D,$A
                  dc.b      'should be fixed      nbk',$D,$A 
                  dc.b      '------------------------',$D,$A
                  dc.b      0,0 
L0230:            dc.b      'IDE devices:',$D,$A
                  dc.b      0,0 
L0231:            dc.b      'SCSI devices:',$D,$A 
                  dc.b      0 
L0232:            dc.b      'ACSI devices:',$D,$A 
                  dc.b      0 
L0233:            dc.b      '  Unit ' 
L0234:            dc.b      '0 - ',0
L0235:            dc.b      'Not responding'
L0236:            dc.b      $D,$A 
                  dc.b      0,0 
L0237:            dc.b      'Identification unavailable',$D,$A
                  dc.b      0,0 
                  bss 
L0238:            ds.w      1 
L0239:            ds.l      1 
L023A:            ds.b      512 
L023B:            ds.w      1 
L023C:            ds.w      1 
ZUEND:            END 
