/*
 * Fichier header pour les plugin de WinSH
 */

#include <ldg.h>
#include <windom.h>

#define INTEGER 1
#define STRING  2
#define	PTR		3
#define REAL	4

typedef struct var {
	int type;
	char *name;
	union value {
		char *string;
		int   integer;
		void *ptr;
		float real;
	} val;
	struct var *next;
} *VAR;

/*
 * interface WinDom : pour faire des appels
 * windom depuis un plugin (principalement pour
 * manipuler des fenˆtres).
 */

struct windom {
	AESPB *aespb;
	/* M‚moire */
	void *(*realloc)( void*,size_t);
	/* Fenˆtres */
	WINvar *wglb;
	WINDOW* (*WindCreate)( int, int, int, int, int);
	int (*WindOpen)( WINDOW *, int, int, int, int);
	int (*WindClose)( WINDOW *);
	int (*WindDelete)( WINDOW *);
	WINDOW* (*WindHandle)( int);
	int (*WindSet)( WINDOW *, int, ...);
	int (*WindGet)( WINDOW *, int, ...);
	int (*WindCalc)( int, WINDOW *, int, int, int, int, int *, int *, int *, int *);
	void (*WindSlider)( WINDOW *, int);
	void (*WindClear)( WINDOW *);
	WINDOW *(*WindAttach)( int);
	/* ‚venements */
	EVNTvar *evnt;
	GRECT *clip;
	int (*EvntWindom)( int);
	/* application */
	APPvar *app;
};

#define MODULE(fnc)	 struct var * cdecl (fnc)( struct var **pile)
#define MODULE2(fnc) struct var * cdecl (fnc)( struct var **pile, struct windom *data)
#define MODULE3(fnc) struct var * cdecl (fnc)( struct var **pile, struct windom *data, long narg)

#define UNUSED( a)	((void )(a))

#define V_INT(i)	(pile[(i)]->val.integer)
#define V_STR(i)	(pile[(i)]->val.string)
#define V_PTR(i)	(pile[(i)]->val.ptr)
#define V_FLT(i)	(pile[(i)]->val.real)
#define V_TYPE(i)	(pile[(i)]->type)

#define R_INT		ret.type = INTEGER,ret.val.integer
#define R_STR		ret.type = STRING,ret.val.string
#define R_PTR		ret.type = PTR,ret.val.ptr
#define R_FLT		ret.type = REAL,ret.val.real

