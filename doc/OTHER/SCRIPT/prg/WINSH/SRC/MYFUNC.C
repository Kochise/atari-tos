/*
 *	Un exemple de fonction ajout‚ au noyau
 */


#include <winsh\function.h>
#include <winsh\error.h>

int get_cookie( long, long *);		/* d‚finie dans WINDOM.LIB */

int cookie(char **arg) {
	VAR v = get_arg( arg);
	long Cook;
	
	if( IS_STR(v)) return ERROR_PAR;
	Cook = ((long)V_STR(v)[0] << 24) +
		   ((long)V_STR(v)[1] << 16) +
		   ((long)V_STR(v)[2] << 8)  +
		   (long)V_STR(v)[3];
	R_INT = get_cookie( Cook, NULL);
	R_TYPE = INTEGER;	
	return 0;
}