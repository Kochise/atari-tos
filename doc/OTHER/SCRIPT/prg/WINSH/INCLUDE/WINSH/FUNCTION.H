/*
	Fonctions et d‚finitions n‚ccessaire pour
	cr‚er une fonction interpr‚t‚e par WinSh
 */

#include "global.h"

/* Proto fonctions */

char *next_arg( char *p);
char *expand_all( char *buf, int dup);
void expand( char *p);
struct var *get_arg( char **buf);
void free_arg( struct var *v);
struct var *set_var( char *name, char *val);		/* var.h */
int del_var( char *name);
struct var *get_var( char *name);
void set_var_var( struct var *r, struct var *l);

/* Variables globales */

extern EVAL eval[];
extern int val_proc;

/* Macros utiles */

#define IS_INT(x)	(x) && ((x)->type == INTEGER)
#define IS_STR(x)	(x) && ((x)->type == STRING)
#define IS_PTR(x)	(x) && ((x)->type == PTR)
#define IS_FLT(x)	(x) && ((x)->type == REAL)
#define IS_VAR(x)	(x) && ((x)->name != NULL)

#define V_INT(x) ((x)->val.integer)
#define V_STR(x) ((x)->val.string)
#define V_PTR(x) ((x)->val.ptr)
#define V_FLT(x) ((x)->val.real)

#define R_INT 	 eval[val_proc].value.val.integer
#define R_STR 	 eval[val_proc].value.val.string
#define R_PTR 	 eval[val_proc].value.val.ptr
#define R_FLT 	 eval[val_proc].value.val.real
#define R_TYPE   eval[val_proc].value.type

