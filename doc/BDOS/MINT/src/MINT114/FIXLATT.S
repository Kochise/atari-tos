	*fixes bug when compiling with lattice
	
	XDEF	__savePC
	XDEF	__saveD2A2
	XDEF	_sync_time

		TEXT	
__savePC	rts
__saveD2A2	rts
_sync_time	rts
		END