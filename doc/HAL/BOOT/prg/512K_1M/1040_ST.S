
* Set 4 or 2.5 Meg ST(E) to 1024K RAM machine 
* Purpose: software test, for some games not liking
* more RAM.
* 1MB only with 2 banks possible - because of MMU


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
  	move.b 	#5,$424.w      * Copy of $FF8001
  	move.l 	#$100000,$42E.w   * Phystop
  	move.b 	#5,$FFFF8001.w   * Memory controller

   	move.l 	4.w,a1
   	jmp 	(a1)      *Reset



text 	dc.b 13,10,"Press space to reduce Your 4MB ST(E)",13,10
  	dc.b "in 1040 machine, or other key",13,10
  	dc.b "for do nothing.",0
  end
