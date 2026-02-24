/*
 *	On peut aussi recompiler le noyau
 *	pour y ajouter ses propres fonctions
 */

#include  <string.h>

#define FUNCTION(f) int (f)(char**)

FUNCTION(print);
FUNCTION(println);
FUNCTION(listvar);
FUNCTION(incr);
FUNCTION(decr);
FUNCTION(reserv);
FUNCTION(unset);
FUNCTION(argv);
/* Fonctions WinDom */
FUNCTION(alert);
FUNCTION(eventdo);
FUNCTION(eventattach);
FUNCTION(windopen);
FUNCTION(windkill);
FUNCTION(menuset);
FUNCTION(rscload);
FUNCTION(rscfree);

/* Prototypez ici vos fonctions */
FUNCTION(cookie);
/* Fin prototype */




struct _function {
		char name[64];
		FUNCTION(*fnc);
	} function[] = {
		"alert",	alert,
		"eventattach", eventattach,
		"eventdo", 	eventdo,
		"print", 	print,
		"println", 	println,		
		"windopen", windopen,
		"windkill", windkill,
		"menuset", 	menuset,
		"rscload", 	rscload,
		"rscfree", 	rscfree,
		"listvar", 	listvar,
		"incr", 	incr,
		"decr", 	decr,
		"reserv", 	reserv,
		"unset",  	unset,
		"argv", 	argv,
/* Ajoutez ici vos propres fonctions */
		"cookie",	cookie,
/* Fin de la liste */
		"", 0L };


int get_function( char *name) {
	int i;
	
	for( i=0; function[i].fnc; i ++) {
		if( !strcmp( function[i].name, name) )
			return i;
	}
	return -1;
}

int exec_function ( int index, char **arg) {
	return (*function[index].fnc)( arg);
}
