/*
 * version 1.10, on formate correctement l'entree pour appl_find
 */

#include <stdio.h>
#include <string.h>
#include <mgem.h>

char *AESformat( char *src) {
	char *p, *q;
	int i;
	
	/* on retire chemin et extension */
	p = strrchr( src, '\\');
	if( p) p ++;
	else	p = src;
	q = strrchr( p, '.');
	if( q) *q = '\0';
	/* Format AES */
	p[8] = '\0';
	strupr( p);
	for( i=strlen(p); i<8; i++)
		p[i] = ' ';
	return p;
}

int main( int argc, char **argv) {
	if( argc > 1) {
		int toid;
		char *s, *p;
	 
		appl_init();
		s = strdup( argv[1]);
		p = AESformat( s);
		toid = appl_find( p);
		fprintf( stdout, "%d\r\n", toid);
		appl_exit();
		free( s);
	} else 
		fprintf( stderr, "applfind 1.10 - returns the AES identifier of a GEM application.\r\n"
						 "Usage is : applfind <GEMAPP>\r\n");

	return 0;
}
