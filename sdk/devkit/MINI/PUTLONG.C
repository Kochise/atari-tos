/*****************************************************************************
**
** putlong.c - put long for MINI Run Time Library
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

PutLong(l)
long l;
{
	PutWord( (unsigned int) (l>>16) );
	PutWord( (unsigned int) l );
}
