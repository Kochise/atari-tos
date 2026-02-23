*	ACCSTART.S		10/09/85			Lowell Webster
* Desk accessory startup program
*
	.text
	.globl	_main
	.globl	_GEMAIN

_main:
	jsr	_GEMAIN		* go to program
	rts			* return to tcs

	.end
