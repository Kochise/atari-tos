/*	TCRTL.C		1/25/84 - 12/13/84	Lee Jay Lorenzen	*/
/*	Tiny  'C' Run Time Library					*/

#include "portab.h"
#include "machine.h"
#include "treeaddr.h"



WORD
strlen(p1)
BYTE		*p1;
{
	WORD		len;

	len = 0;
	while( *p1++ )
		len++;

	return(len);
}


BYTE
*strcpy(pd, ps)
BYTE		*pd, *ps;
{
	while(*pd++ = *ps++)
		;
	return(pd);
}


BYTE
*strcat(pd, ps)
BYTE		*pd, *ps;
{
	while(*pd)
		pd++;
	while(*pd++ = *ps++)
		;
	return(pd);
}
