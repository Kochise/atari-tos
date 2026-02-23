/*	TGEMBIND.C	2/15/85				Lee Lorenzen	*/
/*	Tiny GEMBIND.C	2/15/85	   for HELLO.C		Tom Rolander	*/

#include "portab.h"
#include "machine.h"
#include "treeaddr.h"
#include "obdefs.h"
#include "gembind.h"

#if I8086

GLOBAL BYTE		ctrl_cnts[] =
{
/* Application Manager		*/
	0, 1, 0, 			/* func 010		*/
	2, 1, 1, 			/* func 011		*/
	2, 1, 1, 			/* func 012		*/
	0, 1, 1, 			/* func 013		*/
	2, 1, 1, 			/* func 014		*/
	1, 1, 1, 			/* func 015		*/
	0, 0, 0, 			/* func 016		*/
	0, 0, 0, 			/* func 017		*/
	0, 0, 0, 			/* func 008		*/
	0, 1, 0, 			/* func 019		*/
/* Event Manager		*/
	0, 1, 0, 			/* func 020		*/
	3, 5, 0, 			/* func 021		*/
	5, 5, 0, 			/* func 022		*/
	0, 1, 1, 			/* func 023		*/
	2, 1, 0, 			/* func 024		*/
	16, 7, 1,	 		/* func 025		*/
	2, 1, 0, 			/* func 026		*/
	0, 0, 0, 			/* func 027		*/
	0, 0, 0, 			/* func 028		*/
	0, 0, 0, 			/* func 009		*/
/* Menu Manager			*/
	1, 1, 1, 			/* func 030		*/
	2, 1, 1, 			/* func 031		*/
	2, 1, 1, 			/* func 032		*/
	2, 1, 1, 			/* func 033		*/
	1, 1, 2, 			/* func 034		*/
	1, 1, 1, 			/* func 005		*/
	0, 0, 0, 			/* func 006		*/
	0, 0, 0, 			/* func 007		*/
	0, 0, 0, 			/* func 008		*/
	0, 0, 0, 			/* func 009		*/
/* Object Manager		*/
	2, 1, 1, 			/* func 040		*/
	1, 1, 1, 			/* func 041		*/
	6, 1, 1, 			/* func 042		*/
	4, 1, 1, 			/* func 043		*/
	1, 3, 1, 			/* func 044		*/
	2, 1, 1, 			/* func 045		*/
	4, 2, 1, 			/* func 046		*/
	8, 1, 1, 			/* func 047		*/
	0, 0, 0, 			/* func 048		*/
	0, 0, 0, 			/* func 049		*/
/* Form Manager			*/
	1, 1, 1, 			/* func 050		*/
	9, 1, 1, 			/* func 051		*/
	1, 1, 1, 			/* func 002		*/
	1, 1, 0, 			/* func 003		*/
	0, 5, 1, 			/* func 004		*/
	0, 0, 0, 			/* func 005		*/
	0, 0, 0, 			/* func 006		*/
	0, 0, 0, 			/* func 007		*/
	0, 0, 0, 			/* func 008		*/
	0, 0, 0, 			/* func 009		*/
/* Dialog Manager		*/
	0, 0, 0, 			/* func 060		*/
	0, 0, 0, 			/* func 061		*/
	0, 0, 0, 			/* func 062		*/
	0, 0, 0, 			/* func 003		*/
	0, 0, 0, 			/* func 004		*/
	0, 0, 0, 			/* func 005		*/
	0, 0, 0, 			/* func 006		*/
	0, 0, 0, 			/* func 007		*/
	0, 0, 0, 			/* func 008		*/
	0, 0, 0, 			/* func 009		*/
/* Graphics Manager	*/
	4, 3, 0, 			/* func 070		*/
	8, 3, 0, 			/* func 071		*/
	6, 1, 0, 			/* func 072		*/
	8, 1, 0, 			/* func 073		*/
	8, 1, 0, 			/* func 074		*/
	4, 1, 1, 			/* func 075		*/
	3, 1, 1, 			/* func 076		*/
	0, 5, 0, 			/* func 077		*/
	1, 1, 1, 			/* func 078		*/
	0, 5, 0, 			/* func 009		*/
/* Scrap Manager		*/
	0, 1, 1, 			/* func 080		*/
	0, 1, 1, 			/* func 081		*/
	0, 0, 0, 			/* func 082		*/
	0, 0, 0, 			/* func 083		*/
	0, 0, 0, 			/* func 084		*/
	0, 0, 0, 			/* func 005		*/
	0, 0, 0, 			/* func 006		*/
	0, 0, 0, 			/* func 007		*/
	0, 0, 0, 			/* func 008		*/
	0, 0, 0, 			/* func 009		*/
/* fseler Manager		*/
	0, 2, 2, 			/* func 090		*/
	0, 0, 0, 			/* func 091		*/
	0, 0, 0, 			/* func 092		*/
	0, 0, 0, 			/* func 003		*/
	0, 0, 0, 			/* func 004		*/
	0, 0, 0, 			/* func 005		*/
	0, 0, 0, 			/* func 006		*/
	0, 0, 0, 			/* func 007		*/
	0, 0, 0, 			/* func 008		*/
	0, 0, 0, 			/* func 009		*/
/* Window Manager		*/
	5, 1, 0, 			/* func 100		*/
	5, 1, 0, 			/* func 101		*/
	1, 1, 0, 			/* func 102		*/
	1, 1, 0, 			/* func 103		*/
	2, 5, 0, 			/* func 104		*/
	6, 1, 0, 			/* func 105		*/
	2, 1, 0, 			/* func 106		*/
	1, 1, 0, 			/* func 107		*/
	6, 5, 0, 			/* func 108		*/
	0, 0, 0, 			/* func 009		*/
/* Resource Manager		*/
	0, 1, 1, 			/* func 110		*/
	0, 1, 0, 			/* func 111		*/
	2, 1, 0, 			/* func 112		*/
	2, 1, 1, 			/* func 113		*/
	1, 1, 1, 			/* func 114		*/
	0, 0, 0, 			/* func 115		*/
	0, 0, 0, 			/* func 006		*/
	0, 0, 0, 			/* func 007		*/
	0, 0, 0, 			/* func 008		*/
	0, 0, 0, 			/* func 009		*/
/* Shell Manager		*/
	0, 1, 2, 			/* func 120		*/
	3, 1, 2, 			/* func 121		*/
	1, 1, 1, 			/* func 122		*/
	1, 1, 1, 			/* func 123		*/
	0, 1, 1, 			/* func 124		*/
	0, 1, 2 			/* func 125		*/
};
#endif
#if ALCYON
/*	Alcyon has a wonderful bug where it puts the ctrl_cnts array
	beginning on a byte boundary and sets the pointer to the next
	word boundary. This causes problems. The ctrl_cnts array is
	in gemasm.s and is always on an even boundary.
*/
EXTERN BYTE		ctrl_cnts[];
#endif

typedef struct gemblkstr
{
	LONG		gb_pcontrol;
	LONG		gb_pglobal;
	LONG		gb_pintin;
	LONG		gb_pintout;
	LONG		gb_padrin;
	LONG		gb_padrout;		
} GEMBLK;
						/* in STARTUP.A86	*/
EXTERN WORD		gem();

GLOBAL GEMBLK		gb;
GLOBAL UWORD		control[C_SIZE];
GLOBAL UWORD		global[G_SIZE];
GLOBAL UWORD		int_in[I_SIZE];
GLOBAL UWORD		int_out[O_SIZE];
GLOBAL LONG		addr_in[AI_SIZE];
GLOBAL LONG		addr_out[AO_SIZE];

GLOBAL LONG		ad_g;

	WORD
gem_if(opcode)
	WORD		opcode;
{
	WORD		i;
	BYTE		*pctrl;

	control[0] = opcode;

	pctrl = &ctrl_cnts[(opcode - 10) * 3];
	for(i=1; i<C_SIZE; i++)
	  control[i] = *pctrl++;

	gem(ad_g);
	return((WORD) RET_CODE );
}


	WORD
appl_init()
{
	gb.gb_pcontrol = ADDR((BYTE *) &control[0]); 
	gb.gb_pglobal = ADDR((BYTE *) &global[0]);
	gb.gb_pintin = ADDR((BYTE *) &int_in[0]);
	gb.gb_pintout = ADDR((BYTE *) &int_out[0]);
	gb.gb_padrin = ADDR((BYTE *) &addr_in[0]);
	gb.gb_padrout = ADDR((BYTE *) &addr_out[0]);

	ad_g = ADDR((BYTE *) &gb);
	gem_if(APPL_INIT);
	return((WORD) RET_CODE );
}


	WORD
appl_exit()
{
	gem_if(APPL_EXIT);
	return( TRUE );
}

	WORD
evnt_mesag(pbuff)
	LONG		pbuff;
{
	ME_PBUFF = pbuff;
	return( gem_if(EVNT_MESAG) );
}


	WORD
menu_register(pid, pstr)
	WORD		pid;
	LONG		pstr;
{
	MM_PID = pid;
	MM_PSTR = pstr;
	return( gem_if( MENU_REGISTER ) );
}


	WORD
form_alert(defbut, astring)
	WORD		defbut;
	LONG		astring;
{
	FM_DEFBUT = defbut;
	FM_ASTRING = astring;
	return( gem_if( FORM_ALERT ) );
}

	VOID
graf_growbox(orgx, orgy, orgw, orgh, x, y, w, h)
	WORD		orgx, orgy, orgw, orgh;
	WORD		x, y, w, h;
{
	GR_I1 = orgx;
	GR_I2 = orgy;
	GR_I3 = orgw;
	GR_I4 = orgh;
	GR_I5 = x;
	GR_I6 = y;
	GR_I7 = w;
	GR_I8 = h;
	return( gem_if( GRAF_GROWBOX ) );
}


	VOID
graf_shrinkbox(orgx, orgy, orgw, orgh, x, y, w, h)
	WORD		orgx, orgy, orgw, orgh;
	WORD		x, y, w, h;
{
	GR_I1 = orgx;
	GR_I2 = orgy;
	GR_I3 = orgw;
	GR_I4 = orgh;
	GR_I5 = x;
	GR_I6 = y;
	GR_I7 = w;
	GR_I8 = h;
	return( gem_if( GRAF_SHRINKBOX ) );
}


	WORD
graf_handle(pwchar, phchar, pwbox, phbox)
	WORD		*pwchar, *phchar;
	WORD		*pwbox, *phbox;
{
	gem_if(GRAF_HANDLE);
	*pwchar = GR_WCHAR ;
	*phchar = GR_HCHAR;
	*pwbox = GR_WBOX;
	*phbox = GR_HBOX;
	return((WORD) RET_CODE);
}

	WORD
graf_mouse(m_number, m_addr)
	WORD		m_number;
	LONG		m_addr;
{
	GR_MNUMBER = m_number;
	GR_MADDR = m_addr;
	return( gem_if( GRAF_MOUSE ) );
}



					/* Window Manager		*/
	WORD
wind_create(kind, wx, wy, ww, wh)
	UWORD		kind;
	WORD		wx, wy, ww, wh;
{
	WM_KIND = kind;
	WM_WX = wx;
	WM_WY = wy;
	WM_WW = ww;
	WM_WH = wh;
	return( gem_if( WIND_CREATE ) );
}


	WORD
wind_open(handle, wx, wy, ww, wh)
	WORD		handle;
	WORD		wx, wy, ww, wh;
{
	WM_HANDLE = handle;
	WM_WX = wx;
	WM_WY = wy;
	WM_WW = ww;
	WM_WH = wh;
	return( gem_if( WIND_OPEN ) );
}


	WORD
wind_close(handle)
	WORD		handle;
{
	WM_HANDLE = handle;
	return( gem_if( WIND_CLOSE ) );
}


	WORD
wind_delete(handle)
	WORD		handle;
{
	WM_HANDLE = handle;
	return( gem_if( WIND_DELETE ) );
}


	WORD
wind_get(w_handle, w_field, pw1, pw2, pw3, pw4)
	WORD		w_handle;
	WORD		w_field;
	WORD		*pw1, *pw2, *pw3, *pw4;
{
	WM_HANDLE = w_handle;
	WM_WFIELD = w_field;
	gem_if( WIND_GET );
	*pw1 = WM_OX;
	*pw2 = WM_OY;
	*pw3 = WM_OW;
	*pw4 = WM_OH;
	return((WORD) RET_CODE );
}


	WORD
wind_set(w_handle, w_field, w2, w3, w4, w5)
	WORD		w_handle;	
	WORD		w_field;
	WORD		w2, w3, w4, w5;
{
	WM_HANDLE = w_handle;
	WM_WFIELD = w_field;
	WM_IX = w2;
	WM_IY = w3;
	WM_IW = w4;
	WM_IH = w5;
	return( gem_if( WIND_SET ) );
}


	WORD
wind_update(beg_update)
	WORD		beg_update;
{
	WM_BEGUP = beg_update;
	return( gem_if( WIND_UPDATE ) );
}

	WORD
wind_calc(wctype, kind, x, y, w, h, px, py, pw, ph)
	WORD		wctype;
	UWORD		kind;
	WORD		x, y, w, h;
	WORD		*px, *py, *pw, *ph;
{
	WM_WCTYPE = wctype;
	WM_WCKIND = kind;
	WM_WCIX = x;
	WM_WCIY = y;
	WM_WCIW = w;
	WM_WCIH = h;
	gem_if( WIND_CALC );
	*px = WM_WCOX;
	*py = WM_WCOY;
	*pw = WM_WCOW;
	*ph = WM_WCOH;
	return((WORD) RET_CODE );
}

