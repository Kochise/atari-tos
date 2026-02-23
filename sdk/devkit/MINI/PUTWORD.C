/*****************************************************************************
**
** putword.c - put word for MINI Run Time Library
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

PutWord(w)
unsigned int w;
{
	PutByte( w>>8 );
	PutByte( w );
}
