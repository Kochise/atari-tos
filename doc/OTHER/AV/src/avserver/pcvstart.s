*      PCSTART.S
*
*      Pure C Startup Code
*
*      Copyright (c) Borland International 1988/89/90
*      All Rights Reserved.


*>>>>>> Export references <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .EXPORT exit, __exit

        .EXPORT _BasPag
        .EXPORT _app
        .EXPORT errno
        .EXPORT _AtExitVec, _FilSysVec
        .EXPORT _RedirTab
        .EXPORT _StkLim
        .EXPORT _PgmSize

        .EXPORT __text, __data, __bss

*>>>>>> Import references <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .IMPORT main
        .IMPORT _fpuinit
        .IMPORT _StkSize
        .IMPORT _FreeAll
		.IMPORT _fpumode



*>>>>>> Data structures <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


* Base page structure

        .OFFSET 0

TpaStart:
        .DS.L   1
TpaEnd:
        .DS.L   1
TextSegStart:
        .DS.L   1
TextSegSize:
        .DS.L   1
DataSegStart:
        .DS.L   1
DataSegSize:
        .DS.L   1
BssSegStart:
        .DS.L   1
BssSegSize:
        .DS.L   1
DtaPtr:
        .DS.L   1
PntPrcPtr:
        .DS.L   1
Reserved0:
        .DS.L   1
EnvStrPtr:
        .DS.L   1
Reserved1:
        .DS.B   7
CurDrv:
        .DS.B   1
Reserved2:
        .DS.L   18
CmdLine:
        .DS.B   128
BasePageSize:
        .DS     0



*>>>>>>> Data segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .BSS
__bss:

* Pointer to base page

_BasPag:
        .DS.L   1


* Applikation flag

_app:
        .DS.W   1


* Stack limit

_StkLim:
        .DS.L   1

* Program size

_PgmSize:
        .DS.L   1

* Redirection address table

_RedirTab:
        .DS.L   6

*>>>>>>> Initialized data segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .BSS
__data:

* Global error variable

errno:
        .DS.W   1


* Vector for atexit

_AtExitVec:
        .DS.L   1


* Vector for file system deinitialization

_FilSysVec:
        .DS.L   1


*>>>>>>> Code segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .CODE
__text:


******** PcStart ********************************************************

Start:
        BRA.B   Start0



******* Configuration data


* Redirection array pointer

        .DC.L   _RedirTab


* Stack size entry

        .DC.L   _StkSize



******* Pc library copyright note

        .ALIGN  16

        .DC.B   'Pure C'

        .ALIGN  16

******** Pc startup code

* Setup pointer to base page

Start0:
		move.l  a0,d0
        BNE     ACC

        MOVE.L  4(A7), A3   ; BasePagePointer from Stack
        MOVEQ.L #1, D0      ; Program is Application
        BRA     APP
ACC:
		movea.l    a0,a3
        CLR.W   D0          ; Program is DeskAccessory

APP:

        MOVE.L  A3, _BasPag

* Setup applikation flag

        MOVE.W  D0,_app


* Compute size of required memory
* := text segment size + data segment size + bss segment size
*  + stack size + base page size
* (base page size includes stack size)

        MOVE.L  TextSegSize(A3),d1
        ADD.L   DataSegSize(A3),d1
        ADD.L   BssSegSize(A3),d1
        ADD.L   #BasePageSize,d1
        MOVE.L  d1,_PgmSize

* Setup longword aligned application stack

        move.l  d1,d2
        add.l   a3,d2
        AND.B   #$FC,D2
        MOVE.L  D2,A7

* check application flag

        TST.W   d0
        BEQ     Start9  * No environment and no arguments

* Free not required memory

		move.l     d1,-(a7)
        move.l  a3,-(a7)
        clr.w   -(a7)
        move.w  #74,-(a7)
        trap    #1
        lea.l   12(a7),a7

* scan environment

        move.l     a7,d0
        sub.l      #_StkSize-4,d0
        AND.B   #$FC, D0
        MOVE.L  D0, A1
        MOVE.L  A1, A4
        MOVE.L  EnvStrPtr(A3), A2
ScanEnvLoop:
        MOVE.L  A2, (A1)+
        movea.l    a2,a5
        tst.b      (a2)+
        beq.s      ScanEnvExit
Start1:
        TST.B   (A2)+
        BNE     Start1
        movep.w    0(a5),d0
        swap       d0
        movep.w    1(a5),d0
        cmpi.l     #'AGRV',d0
        bne     ScanEnvLoop
        cmpi.b     #'=',4(a5)
        bne     ScanEnvLoop
        cmpi.b     #127,CmdLine(a3)
        bne     ScanEnvLoop
        clr.b      (a5)
        clr.l      -4(a1)
        movea.l    a1,a5
        moveq.l    #0,d3
        move.l     a2,(a1)+
xArgLoop:
        tst.b      (a2)+
        bne.s      xArgLoop

        MOVE.L  A2, (A1)+
        addq.w     #1,d3
        TST.B   (A2)
        BNE     xArgLoop
		bra Start8

ScanEnvExit:
        CLR.L   -4(A1)

* scan commandline
        LEA     CmdLine(A3), A0
        MOVE.B  (A0), D1
        EXT.W   D1
        movea.l    a1,a5
        move.l     a0,(a1)+
        clr.b      (a0)+
        moveq.l    #1,d3
        move.l     a0,(a1)+
        moveq.l    #32,d4
        moveq.l    #39,d5
        moveq.l    #34,d6
        bra     Start5

Start2:
	move.b     (a0)+,d0
	cmp.b      d4,d0
	bhi.s      Start3
	tst.b      -2(a0)
	bne.s      Startv5
	addq.l     #1,-4(a1)
	bra.s      Startv6
Start3:
	cmp.b      d5,d0
	bne.s      Startv3
	move.l     -4(a1),d0
	addq.l     #1,d0
	cmpa.l     d0,a0
	bne.s      Startv3
	addq.l     #1,-4(a1)
Startv1:
	cmp.b      (a0)+,d5
	dbeq       d1,Startv1
	subq.w     #1,d1
	bmi.s      Start8
	beq.s      Startv5
	cmp.b      (a0),d5
	bne.s      Startv5
	movea.l    -(a1),a2
	movea.l    a0,a3
Startv2:
	move.b     -2(a3),-(a3)
	cmpa.l     a2,a3
	bhi.s      Startv2
	addq.l     #1,a0
	subq.w     #1,d1
	addq.l     #1,(a1)+
	bra.s      Startv1
Startv3:
	cmp.b      d6,d0
	bne.s      Start5
	addq.l     #1,-4(a1)
Startv4:
	cmp.b      (a0)+,d6
	dbeq       d1,Startv4
	subq.w     #1,d1
	bmi.s      Start8
Startv5:
	move.l     a0,(a1)+
	addq.w     #1,d3
Startv6:
	clr.b      -1(a0)
Start5:
	subq.w     #1,d1
	bpl.s      Start2
	tst.b      -1(a0)
	beq.s      Start8
	addq.w     #1,d3
	clr.b      (a0)
	addq.l     #4,a1

Start8:
	movea.l    a1,a6
	clr.l      -(a1)
Start9:
	clr.w      _fpumode
	lea.l      256(a6),a6
	move.l     a6,_StkLim
	clr.w      errno
	clr.l      _AtExitVec
	clr.l      _FilSysVec

******* Execute main program *******************************************
*
* Parameter passing:
*   <D0.W> = Command line argument count (argc)
*   <A0.L> = Pointer to command line argument pointer array (argv)
*   <A1.L> = Pointer to tos environment string (env)

        MOVE    D3, D0
        MOVE.L  A5, A0
        MOVE.L  A4, A1
        JSR     main



******** exit ***********************************************************
*
* Terminate program
*
* Entry parameters:
*   <D0.W> = Termination status : Integer
* Return parameters:
*   Never returns

exit:
        MOVE.W  D0,-(A7)

* Execute all registered atexit procedures

        MOVE.L  _AtExitVec,D0
        BEQ     __exit

        MOVE.L  D0,A0
        JSR     (A0)


* Deinitialize file system

__exit:
        MOVE.L  _FilSysVec,D0
        BEQ     Exit1

        MOVE.L  D0,A0
        JSR     (A0)


* Deallocate all heap blocks

Exit1:
        JSR     _FreeAll


* Program termination with return code

        MOVE.W  #76,-(A7)
        TRAP    #1



******* Module end *****************************************************

        .END
