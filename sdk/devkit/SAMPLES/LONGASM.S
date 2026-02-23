*	LONGASM.S		9/26/85		Lowell Webster
*
	.text
	.globl	_LSTRLEN
	.globl	_LBCOPY
	.globl	_LWCOPY
	.globl	_LBWMOV
*
*	N B ADDR, LBGET, LBSET, LWGET, LWSET, LLGET, LLSET
*	    are all defined in machine.h.
*	    LLDS, LLCS, LLSS are undefined for 68000
*
*		WORD		return length of string
*	_LSTRLEN(pstr)
*		BYTE		*pstr;
*
_LSTRLEN:
	move.l	4(a7),a0		* Get string's address off stack.
	clr.l	d0			* Initialize counter.
lstr1:
	addq	#1,d0
	cmpi.b	#0,(a0)+		* Find first zero,
	bne	lstr1			*  loop until zero found.
	subq	#1,d0			* Adjust counter.
	rts
*
*
*	_LBCOPY(pdst, psrc, len)
*		BYTE	*pdst;		destination
*		BYTE	*psrc;		source
*		WORD	len;		number of bytes
*
_LBCOPY:
	movem.l	4(a7),a0-a1	* A0 = Destination   A1 = Source.
	clr.l	d0
	move.w	12(a7),d0	* D0 = Number of bytes to move.
	beq	lbcend		* get out if 0
	cmp.l	a0,a1		* If A1 < A0 then start from bottom of source
	blt	lbcback		*   and go backward.
lbc1:
	move.b	(a1)+,(a0)+
	subq.w	#1,d0
	bne	lbc1
	rts
*
lbcback:
	add.l	d0,a1
	add.l	d0,a0
	subq.w	#1,d0
lbc2:
	move.b	-(a1),-(a0)
	subq.w	#1,d0
	bpl	lbc2
lbcend:
	rts
*
*	_LWCOPY(pdst, psrc, len)
*		BYTE	*pdst;		destination
*		BYTE	*psrc;		source
*		WORD	len;		number of words
*
_LWCOPY:
	movem.l	4(a7),a0-a1	* A0 = Destination   A1 = Source.
	clr.l	d0
	move.w	12(a7),d0	* D0 = Number of words to move.
	beq	lwcend		* get out if 0
	cmp.l	a0,a1		* If A1 < A0 then start from bottom of source
	blt	lwcback		*   and go backward.
lwc1:
	move.w	(a1)+,(a0)+	* Copy word.
	subq.w	#1,d0
	bne	lwc1
	rts
*
lwcback:
	add.l	d0,a1		* start at end,  ( d0 in words )
	add.l	d0,a1
	add.l	d0,a0
	add.l	d0,a0
	subq.w	#1,d0
lwc2:
	move.w	-(a1),-(a0)
	subq.w	#1,d0
	bpl	lwc2
lwcend:
	rts

*
*	expand from bytes to words until a null, return
*	number of bytes moved not including the null.
*
*	len = LBWMOV(dst,src)
*		BYTE	*dst,src;
*
_LBWMOV:
	move.l	4(a7),a1	* destination
	move.l	8(a7),a0	* source
	clr.l	d0
	clr.l	d1
lbw1:
	move.b	(a0)+,d1	* get a byte
	beq	lbwend		* end if 0
	  move.w	d1,(a1)+	* store a word
	  addq.b	#1,d0
	  bra		lbw1
lbwend:
	rts

	.end
