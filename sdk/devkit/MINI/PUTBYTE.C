/*****************************************************************************
**
** putbyte.c - put byte for MINI Run Time Library
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

PutByte(b)
char b;
{
	PutNibble( b>>4 );
	PutNibble( b );
}
