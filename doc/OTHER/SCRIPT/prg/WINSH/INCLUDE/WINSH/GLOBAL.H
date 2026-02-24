#include <ldg.h>

#define MAXLOOP	10
#define MAXMEM	50
#define MAXLDG	50
#define MAXBUF 255
#define MAXPROC	200
#define NAMEPROC 64
#define MAXPILE	20

#define INTEGER 1
#define STRING  2
#define	PTR		3
#define REAL	4
#define LONGINT	5
#define ALIAS	20

typedef struct var {
	int type;
	char *name;
	union value {
		char *string;
		int   integer;
		void *ptr;
		float real;
		long  longint;
	} val;
	struct var *next;
} *VAR;


struct lib {
	char name[128];
	LDG *ldg;
	struct lib *next;
};


typedef struct {
		int type;	/* Vaut 0, IF, LOOP ou SET : type d'‚valuation */
		int pos;	/* Vaut LVALUE, eval_oper ou RVALUE */
		int res;	/* TRUE ou FALSE? r‚sultat de l'‚val */
		int oper;	/* operateur */
		struct var *Var, lvalue, value;
	} EVAL;


typedef struct {
		char *pos;					/* adresse dans la srcipte */
		char name[NAMEPROC];		/* nom de la proc‚dure */
		int  narg;					/* nombre d'arguments */
		int  line;					/* vrai num‚ro de ligne */
	} PROCDEF;

/* On encapsule les ttype r‚el */

typedef union real {
		long dummy;
		double value;
} Real;
