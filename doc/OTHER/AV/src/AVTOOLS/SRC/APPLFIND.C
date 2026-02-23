/*
 *
 */

#include <stdio.h>
#include <string.h>
#include <mgem.h>

int main( int argc, char **argv) {
	char appname[9] = "        ";

	if( argc > 1) {
		int toid, i;
	 
		appl_init();
		for( i=0; i<8 && argv[1][i] != '\0'; i++)
			appname[i] = argv[1][i];
		strupr( appname);
		toid = appl_find( appname);
		fprintf( stdout, "%d\r\n", toid);
		appl_exit();
	} else 
		fprintf( stderr, "Usage is : applfind <GEMAPP>\r\n");

	return 0;
}
