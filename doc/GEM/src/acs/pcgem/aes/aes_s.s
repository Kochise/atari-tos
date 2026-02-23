		; ************************************************************
		;
		;      Eine handoptimierte Bibliothek fr Pure-C und GNU-C
		;
		; Die AES-Funktionen
		;
		; (c) 1998-2008 by Martin Els„sser @ LL, Gerhard Stoll @ B
		;
		; 												Tabsize: 1 Tab = 3 Spaces
		; ************************************************************
		
		; Der GEM-Dispatcher im ROM retten alle Register (lt. Profibuch ;-),
		; aber das mu nicht immer so sein! (wer wei, was diverse
		; Erweiterungen tun ;-)
		;
		; Pure-C m”chte D3-D7 und A2-A7 gerettet bekommen,
		; wir retten einfach alle Register, die nicht fr
		; Rkgabewerte ben”tigt werden, also alles auer D0 & SP

	_rsv EQU 5*4							; Anzahl der Byte, die fr das Retten der Register
												; auf dem Stack ben”tigt werden (dies ist wichtig,
												; um die auf dem Stack bergebenen Parameter
												; wieder zu finden ;-)
		
	MACRO PCRegSave
		
		MOVEM.L D1-D2/A0-A2, -(SP)		; Register retten
		
	ENDM

		; ------------------------------------------------------------
	
	MACRO PCRegLoad
		
		MOVEM.L (SP)+, D1-D2/A0-A2		; Register reparieren
		
	ENDM

		; ************************************************************
		; void CDECL aes( INT16 *contrl, INT16 *global,
		;                 INT16 *int_in, INT16 *int_out,
		;                 void *addr_in, void *addr_out );
		; ************************************************************
		
	EXPORT aes
	MODULE aes
		
		PCRegSave									; Register fr Pure-C retten
		
		; Der Parameterblock ist durch die šbergabe als CDECL bereits
		; auf dem Stack zusammengesetzt, das ist "etwas" multitasking-
		; freundlicher ;-)
		
		; Nun ab in die AES!
		LEA (_rsv+4)(SP), A0						; Adresse des Parameterblockes auf dem Stack
		MOVE.L A0, D1								; Parameterblock in D1
		MOVE.L #$C8, D0							; Die AES bitte!
		TRAP #2										; => ab in's GEM
		
		PCRegLoad									; Register fr Pure-C reparieren
		MOVEQ #0, D0								; D0 initialiseren
		RTS											; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void _crystal( AESPB *pb );
		; ************************************************************
		
	EXPORT _crystal
	MODULE _crystal
		
		PCRegSave									; Register fr Pure-C retten
		
		; Nun ab in die AES!
		MOVE.L A0, D1								; Adresse des Parameterblockes
		MOVE.L #$C8, D0							; Die AES bitte!
		TRAP #2										; => ab in's GEM
		
		PCRegLoad									; Register fr Pure-C reparieren
		MOVEQ #0, D0								; D0 initialiseren
		RTS											; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; int16 _appl_yield( void );
		; ************************************************************
		
	EXPORT _appl_yield
	MODULE _appl_yield
		
		PCRegSave									; Register fr Pure-C retten
		
		; Nun ab in die AES!
		MOVE.L #$C9, D0							; Die AES mit _appl_yield bitte!
		TRAP #2										; => ab in's GEM
		
		PCRegLoad									; Register fr Pure-C reparieren
		RTS											; ... und zurck
		
	ENDMOD
				