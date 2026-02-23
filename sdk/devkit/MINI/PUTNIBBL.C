/*****************************************************************************
**
** putnibbl.c - put nibble for MINI Run Time Library
**
** MODIFICATIONS
** 18 sep 85 scc	Converted for library format RTL.
**
** NAMES
**	scc	Steven C. Cavender
**
******************************************************************************
*/

#include <mini.h>

PutNibble(n)
char n;
{
	n &= 0xF;
	n += '0';
	if (n > '9')
		n += 7;
	C_ConOut(n);
}
