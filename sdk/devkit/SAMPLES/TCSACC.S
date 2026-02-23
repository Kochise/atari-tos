*	TCSACC.S		10/10/85		Lowell Webster
*
*	MUST BE FIRST FILE IN LINK STATEMENT
*
	.text
	.globl	_main		* defined in prostart.s
	.globl	ldiv
	.globl	lmul
	.globl	lrem
*
*
* On the ATARI ST, sp will be NULL, but since we don't need the base page
*  it's ok. If the base page is needed, subtract 100H from the address
*  of the first instruction to be executed.
*
*	move.l	4(sp),a0	* get basepage address
*	move.l	a0,__base

	move.l	#stack,sp	* set local stack

	jsr	_main

	move.l	#0,-(sp)	* terminate
	move.w	#$4c,-(sp)
	trap	#1
*
*
*
*	Useful if not linking with C run time library but required by
*	ALCYON C compiler
*
* ========================================================
* ==							
* ==    long multiply routine without floating point	==
* ==  call with:					==
* ==		two long values on stack		==
* ==  returns:						==
* ==		long value in R0 and R1			==
* ==							==
* == warning:  no overflow checking or indication!!!!	==
* ==							
* ========================================================
*
*
lmul:
~~lmul:
~sign=R2
~l1=8
~l2=12
~t1=-4
~t2=R6
	link	R14,#-4
	clr	R2
	tst.l	8(R14)		//is first arg negative?
	bge	L2
	neg.l	8(R14)		//yes, negate it
	inc	R2				// increment sign flag
*
L2:
	tst.l	12(R14)		//is second arg negative?
	bge	L3
	neg.l	12(R14)		//yes, make it positive
	inc	R2				//increment sign flag
*
L3:
	move	10(R14),R0		//arg1.loword
	mulu	14(R14),R0		//arg2.loword
	move.l	R0,-4(R14)	//save in temp
	move	8(R14),R0		//arg1.hiword
	mulu	14(R14),R0		//arg2.loword
	move	12(R14),R1		//arg2.hiword
	mulu	10(R14),R1		//arg1.loword
	add	R1,R0			//form the sum of 2 lo-hi products
	add	-4(R14),R0	//add to temp hiword
	move	R0,-4(R14)	//store back in temp hiword
	move.l	-4(R14),R0	//long results
	btst	#0,R2			//test sign flag
	beq	L4
	neg.l	R0		//complement the results
*
L4:
	unlk	R14
	rts
*
*
* ========================================================
* ==							==
* ==			Long Divide			==
* ==							==
* ========================================================
*
ldiv:
*
~~ldiv:
~b=R4
~q=R5
~l1=R7
~l2=R6
~al1=8
~al2=12
~sign=R3
*
	link	R14,#-2
	movem.l	R2-R7,-(sp)
	clr	R3
	clr.l	R5
	move.l	8(R14),R7
	move.l	12(R14),R6
	bne	La2
	move.l	#$80000000,_ldivr
	move.l	#$80000000,R0
	divs	#0,R0			*<<<<< div by zero trap   whf 3/7/84
	bra	La1
*
La2:
	bge	La3
	neg.l	R6
	add	#1,R3
*
La3:
	tst.l	R7
	bge	La4
	neg.l	R7
	add	#1,R3
*
La4:
	cmp.l	R7,R6
	bgt	La6
	bne	La7
	move.l	#1,R5
	clr.l	R7
	bra	La6
*
La7:
	cmp.l	#$10000,R7
	bge	La9
	divu	R6,R7
	move	R7,R5
	swap	R7
	ext.l	R7
	bra	La6
*
La9:
	move.l	#1,R4
*
La12:
	cmp.l	R6,R7
	blo	La11
	asl.l	#1,R6
	asl.l	#1,R4
	bra	La12
*
La11:
	tst.l	R4
	beq	La6
	cmp.l	R6,R7
	blo	La15
	or.l	R4,R5
	sub.l	R6,R7
*
La15:
	lsr.l	#1,R4
	lsr.l	#1,R6
	bra	La11
*
La6:
	cmp	#1,R3
	bne	La16
	neg.l	R7
	move.l	R7,_ldivr
	move.l	R5,R0
	neg.l	R0
	bra	La1
*
La16:
	move.l	R7,_ldivr
	move.l	R5,R0
*
La1:
	tst.l	(sp)+
	movem.l	(sp)+,R3-R7
	unlk	R14
	rts
lrem:
~~lrem:
~l2=12
~al1=8
	link	R14,#-2
	move.l	12(R14),-(sp)
	move.l	8(R14),-(sp)
	jsr	ldiv
	cmpm.l	(sp)+,(sp)+
	move.l	_ldivr,R0
	unlk	R14
	rts


	.bss
	.even
	.globl	__base

__base:	.ds.l	1		* base page address
_ldivr:	.ds.l	1
	.ds.l	1024
stack:	.ds.l	1

	.end
