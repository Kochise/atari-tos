*	PROSTART.S		10/03/85		Lowell Webster
*
	.text
	.globl	_main
	.globl	_GEMAIN
	.globl	__base		* defined in tcs.s

*  Free up memory so that AES internal memory allocations for the resource
*   and item selecter will work.
*
_main:
	move.l	__base, a5	* get basepage address
	move.l	$c(a5),d0	* get length of text
	add.l	$14(a5),d0	* add length of initialized data .data
	add.l	$1c(a5),d0	* add length of unitialized data .bss
	add.l	#$100,d0	* add length of base page
* set up for gemdos call
	move.l	d0,-(sp)	* length of retained memory
	move.l	a5,-(sp)	* beginning address is base page 
	move.w	#0,-(sp)	* reserved
	move.w	#$4a,-(sp)	* shrink memory function call
	trap	#1
	add.l	#12,sp		* restore stack

	jsr	_GEMAIN		* go to program

	rts

	.end
