/*	RESOURCE FILE FOR XFORM		68K	*/
#if MC68K
ULONG beg_file;

RSHDR starthdr = 
{
	0,		/* rsh_vrsn	*/
	0,		/* rsh_object	*/
	0, 		/* rsh_tedinfo	*/
	0,		/* rsh_iconblk	*/
	0,		/* rsh_bitblk	*/
	0,		/* rsh_frstr	*/
	0,		/* rsh_string	string data		*/
	0,		/* rsh_imdata	image data		*/
	0,		/* rsh_frimg	*/
	0,		/* rsh_trindex	*/
	0,		/* rsh_nobs	*/
	0,		/* rsh_ntree	*/
	0,		/* rsh_nted	*/
	0,		/* rsh_nib	*/
	0,		/* rsh_nbb	*/
	0,		/* rsh_nstring	*/
	0,		/* rsh_nimages	*/
	0		/* rsh_rssize	*/
};
#endif

#define T0OBJ 0
#define T1OBJ 20
#define T2OBJ 24
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 26

BYTE *rs_strings[] = {
" Desk ",
" File ",
"  Options ",
"  About sketch...",
"--------------------",
"  Desk Accessory 1  ",
"  Desk Accessory 2  ",
"  Desk Accessory 3  ",
"  Desk Accessory 4  ",
"  Desk Accessory 5  ",
"  Desk Accessory 6  ",
"  Quit       ",
"  View... ",
"Transformation Demonstrator",
"  OK  ",
"Author: Chris Keith",
"View",
"Fit to full, maintain aspect ratio",
"Zoom level 1",
"Fit to full, maintain aspect ratio",
"Zoom level 2",
"Fit to full, maintain aspect ratio",
"Zoom level 3",
"Fit to window, maintain aspect ratio",
"Fit to window, ignore aspect ratio",
"  OK  ",
"[3][Can't open window][ Exit ]"};

LONG rs_frstr[] = {
26L};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
0};

OBJECT rs_object[] = {
-1, 1, 6, G_IBOX, NONE, NORMAL, 0x0L, 0,0, 90,25,
6, 2, 2, G_BOX, NONE, NORMAL, 0x1100L, 0,0, 90,513,
1, 3, 5, G_IBOX, NONE, NORMAL, 0x0L, 2,0, 22,769,
4, -1, -1, G_TITLE, NONE, NORMAL, 0x0L, 0,0, 6,769,
5, -1, -1, G_TITLE, NONE, NORMAL, 0x1L, 6,0, 6,769,
2, -1, -1, G_TITLE, NONE, NORMAL, 0x2L, 12,0, 10,769,
0, 7, 18, G_IBOX, NONE, NORMAL, 0x0L, 0,769, 90,19,
16, 8, 15, G_BOX, NONE, NORMAL, 0xFF1100L, 2,0, 20,8,
9, -1, -1, G_STRING, NONE, NORMAL, 0x3L, 0,0, 20,1,
10, -1, -1, G_STRING, NONE, DISABLED, 0x4L, 0,1, 20,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0x5L, 0,2, 20,1,
12, -1, -1, G_STRING, NONE, NORMAL, 0x6L, 0,3, 20,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 0,4, 20,1,
14, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 0,5, 20,1,
15, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 0,6, 20,1,
7, -1, -1, G_STRING, NONE, NORMAL, 0xAL, 0,7, 20,1,
18, 17, 17, G_BOX, NONE, NORMAL, 0xFF1100L, 8,0, 13,1,
16, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 0,0, 13,1,
6, 19, 19, G_BOX, NONE, NORMAL, 0xFF1100L, 14,0, 13,1,
18, -1, -1, G_STRING, LASTOB, NORMAL, 0xCL, 0,0, 13,1,
-1, 1, 3, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 40,10,
2, -1, -1, G_STRING, NONE, NORMAL, 0xDL, 7,2, 27,1,
3, -1, -1, G_BUTTON, 0x5, NORMAL, 0xEL, 28,7, 8,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0xFL, 11,4, 19,1,
-1, 1, 15, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 46,19,
2, -1, -1, G_STRING, NONE, NORMAL, 0x10L, 4,1, 4,1,
3, -1, -1, G_BOXCHAR, 0x11, NORMAL, 0xFF1100L, 4,3, 1,1,
4, -1, -1, G_STRING, NONE, NORMAL, 0x11L, 7,3, 34,1,
5, -1, -1, G_STRING, NONE, NORMAL, 0x12L, 7,4, 12,1,
6, -1, -1, G_BOXCHAR, 0x11, NORMAL, 0xFF1100L, 4,6, 1,1,
7, -1, -1, G_STRING, NONE, NORMAL, 0x13L, 7,6, 34,1,
8, -1, -1, G_STRING, NONE, NORMAL, 0x14L, 7,7, 12,1,
9, -1, -1, G_BOXCHAR, 0x11, NORMAL, 0xFF1100L, 4,9, 1,1,
10, -1, -1, G_STRING, NONE, NORMAL, 0x15L, 7,9, 34,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0x16L, 7,10, 12,1,
12, -1, -1, G_BOXCHAR, 0x11, NORMAL, 0xFF1100L, 4,12, 1,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0x17L, 7,12, 36,1,
14, -1, -1, G_BOXCHAR, 0x11, NORMAL, 0xFF1100L, 4,14, 1,1,
15, -1, -1, G_STRING, NONE, NORMAL, 0x18L, 7,14, 34,1,
0, -1, -1, G_BUTTON, 0x27, NORMAL, 0x19L, 33,17, 8,1};

LONG rs_trindex[] = {
0L,
20L,
24L};

struct foobar {
	WORD	dummy;
	UWORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 27
#define NUM_FRSTR 1
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 0
#define NUM_OBS 40
#define NUM_TREE 3

BYTE pname[] = "XFORM.RSC";
