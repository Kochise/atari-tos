/************************************************************************/
/*                                                                      */
/*   LINE_A.C  -  Grafikinterface (Andreas Schwerendt 13.9.1985)        */
/*                                                                      */
/*                Copyright 1985 by RDS-Software Raunheim               */
/*                                                                      */
/************************************************************************/
/*         LINE "A" Funktionen                                          */
/************************************************************************/
#define LA_INIT   0xA000         /* Initialisierung                     */
#define LA_PUT    0xA001         /* Pixel setzen                        */
#define LA_GET    0xA002         /* Pixel holen                         */
#define LA_LINE   0xA003         /* Gerade Zeichnen                     */
#define LA_HLN    0xA004         /* Horizontale Linie                   */
#define LA_DFR    0xA005         /* Gefuelltes Rechteck zeichnen        */
#define LA_LFP    0xA006         /* Zeilenweises Fuellen                */
#define LA_BBLT   0xA007         /* Bit Block Transfer                  */
#define LA_TBLT   0xA008         /* Textblock Transfer                  */
#define LA_SM     0xA009         /* Show Mouse                          */
#define LA_HM     0xA00A         /* Hide Mouse                          */
#define LA_TM     0xA00B         /* Tranform Mouse                      */
#define LA_US     0xA00C         /* Undraw Sprite                       */
#define LA_DS     0xA00D         /* Draw Sprite                         */
#define LA_CRST   0xA00E         /* Copy Raster                         */
/************************************************************************/
/*         LINE "A" und GSX MODI                                        */
/************************************************************************/
#define MD_REPLACE   1      /* Zeichnen                                 */
#define MD_TRANS     2      /* Transparent                              */
#define MD_XOR       3      /* Invertieren                              */
#define MD_ERASE     4      /* Loeschen                                 */
/************************************************************************/
/*      Struktur der LINE "A" Eingabevariablen                          */
/************************************************************************/
typedef struct {
   int  v_planes;
   int  v_lin_wr;
   int  *CONTRL;
   int  *INTIN;
   int  *PTSIN;
   int  *INTOUT;
   int  *PTSOUT;
   int  _FG_BP_1;
   int  _FG_BP_2;
   int  _FG_BP_3;
   int  _FG_BP_4;
   int  _LSTLIN;
   int  _LN_MASK;
   int  _WRT_MODE;
   int  _X1;
   int  _Y1;
   int  _X2;
   int  _Y2;
   char *_patptr;
   int  _patmsk;
   int  _multifill;
   int  _CLIP;
   int  _XMN_CLIP;
   int  _YMN_CLIP;
   int  _XMX_CLIP;
   int  _YMX_CLIP;
   int  _XACC_DDA;
   int  _DDA_INC;
   int  _T_SCLSTS;
   int  _MONO_STATUS;
   int  _SOURCEX;
   int  _SOURCEY;
   int  _DESTX;
   int  _DESTY;
   int  _DELX;
   int  _DELY;
   char *_FBASE;
   int  _FWIDTH;
   int  _STYLE;
   int  _LITEMASK;
   int  _SKEWMASK;
   int  _WEIGHT;
   int  _R_OFF;
   int  _L_OFF;
   int  _SCALE;
   int  _CHUP;
   int  _TEXT_FG;
   char *_scrtchp;
   int  _scrpt2;
   int  _TEXT_BG;
   int  _COPYTRAN;
} LINE_A;
/************************************************************************/
/*         Externe Referenzen fuer Linker                               */
/************************************************************************/
extern LINE_A *line_a();                /* Funktion line_a              */
                                        /*                              */
/************************************************************************/
/*         Globale Variablen                                            */
/************************************************************************/
static LINE_A *la;                      /* Zeiger auf Line "A" Struktur */
                                        /*                              */
/************************************************************************/
/*            FUNKTIONEN                                                */
/************************************************************************/
/*
 * la_init();   Muss einmalig vor der Benutzung anderer LINE "A"
 *              Funktionen aufgerufen werden, damit diese auf die
 *              internen Variablen zugreifen koennen.
 */
la_init()
{
   LINE_A *line_a();

   la = line_a(LA_INIT);
}

/*
 * la_put(x,y,color);   Setzt Pixel in Position (X/Y)
 */
la_put(x, y, color)
int    x, y, color;
{
   la->INTIN[0] = color;
   la->PTSIN[0] = x;
   la->PTSIN[1] = y;
   line_a(LA_PUT);
}

/*
 * la_get(x,y);      Holt Pixel aus Position (X/Y)
 */
la_get(x, y)
int    x, y;
{
   la->PTSIN[0] = x;
   la->PTSIN[1] = y;
   line_a(LA_GET);
}

/*
 * la_draw(x1,y1,x2,y2);  Zeichnet eine Gerade zwischen (X1/Y1) und (X2/Y2)
 */
la_draw(x1, y1, x2, y2)
int     x1, y1, x2, y2;
{
   la->_WRT_MOD = MD_REPLACE;
   la->_X1 = x1;          /* Koordinaten uebergeben  */
   la->_Y1 = y1;
   la->_X2 = x2;
   la->_Y2 = y2;
   la->_FG_BP_1 = 1;      /* Zeichenfarbe 1          */
   la->_FG_BP_2 = 0;      /*    ''                   */
   la->_FG_BP_3 = 0;      /*    ''                   */
   la->_FG_BP_4 = 0;      /*    ''                   */
   la->_LSTLIN = 0;
   la->_LN_MASK = 0xFFFF;
   line_a(LA_LINE);
}

/*
 * la_undraw(x1,y1,x2,y2)   Loescht die Gerade zwischen (X1/Y1) und (X2/Y2)
 */
la_undraw(x1, y1, x2, y2)
int       x1, y1, x2, y2;
{
   la->_WRT_MOD = MD_ERASE;
   la->_X1 = x1;          /* Koordinaten uebergeben  */
   la->_Y1 = y1;
   la->_X2 = x2;
   la->_Y2 = y2;
   la->_FG_BP_1 = 1;      /* Zeichenfarbe 1          */
   la->_FG_BP_2 = 0;      /*    ''                   */
   la->_FG_BP_3 = 0;      /*    ''                   */
   la->_FG_BP_4 = 0;      /*    ''                   */
   la->_LSTLIN = 0;
   la->_LN_MASK = 0xFFFF;
   line_a(LA_LINE);
}

/*
 * la_smouse();      Show Mouse (Macht Maus sichtbar)
 */
la_smouse()
{
   line_a(LA_SM);
}

/*
 * la_hmouse();      Hide Mouse (Macht Maus unsichtbar)
 */
la_hmouse()
{
   line_a(LA_HM);
}

