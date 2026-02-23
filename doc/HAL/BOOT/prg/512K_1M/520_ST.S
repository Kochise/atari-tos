
*Convert all ST to 512K RAM machine 
* Purpose: software test, for some games not liking
* more RAM.

	pea	text(pc)
  	move.w 	#9,-(sp)   * String output
  	trap 	#1
  	addq.l 	#6,sp

  	move.w 	#1,-(sp)   * Wait keypress
  	trap 	#1
  	addq.l 	#2,sp
  	cmp.b 	#32,d0
  	beq.s 	exec

  	clr.w	 -(sp)   * Exit
  	trap 	#1

exec  	pea 	srut(pc)  * Code adr.
  	move.w 	#38,-(sp)     * Exec in supervisor mode
  	trap 	#14
* No return 

srut	move.w 	#$2700,sr   * Disable interrupts
  	move.b 	#4,$424.w      * Copy of $FF8001
  	move.l 	#$80000,$42E.w   * Phystop
  	move.b 	#4,$FFFF8001.w   * Memory controller

   	move.l 	4.w,a1
   	jmp 	(a1)      *Reset



text 	dc.b 13,10,"Press space to reduce Your ST(E)",13,10
  	dc.b "in 520 machine, or other key",13,10
  	dc.b "for do nothing.",0
  end
