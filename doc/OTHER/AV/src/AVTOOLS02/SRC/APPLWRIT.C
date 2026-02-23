/*
 * compilation : gcc applwrite -o applwrite -lmgem -O2
 * VA_START          0x4711 18193
 * AV_STARTPROG      0x4722 18210
 * AV_OPENWIND       0x4720 18208
 */

#include <stdio.h>
#include <string.h>
#include <mgem.h>

int is_number( char *str) {	
	if( *str == '-' || *str == '+')
		str ++;
	while ( *str && *str >= '0' && *str <= '9')
		str ++;
	return *str?0:1;
}

int main( int argc, char **argv) {
	char appname[9] = "        ";
	short buf[8];
	int argr = 1;  // arguments lus

	if( argc > 2) {
		int apid = appl_init();
		int toid = -1, i;

		argr += 2;
		if( is_number( argv[1]))
			toid = atoi( argv[1]);
		else {
			for( i=0; i<8 && argv[1][i] != '\0'; i++)
				appname[i] = argv[1][i];
			strupr( appname);
			toid = appl_find( appname);
		}
		if( toid >=  0) {
			buf[0] = atoi( argv[2]);
			buf[1] = apid;
			buf[2] = 0;
			i = 3;

			while( argc > argr && i < 8) {
				if( is_number(argv[argr])) {
					buf[i] = atoi(argv[argr]);
					i++; argr++;
				} else {
					* (char **) &buf[i] = argv[argr];
					i += 2;
					argr ++;
				}
			}

			appl_write( toid, 16, buf);
			evnt_timer( 300); 
		} else {
			fprintf( stderr, "Application '%s' not in memory.\r\n", appname);
		}
		appl_exit();
	} else 
		fprintf( stderr, "Usage is : applwrite <GEMAPP> <MSG> [ARGS...]\r\n");

	return 0;
}
