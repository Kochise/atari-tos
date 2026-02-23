/*****************************************************************************
**
** put10w.c - put unsigned word decimal for MINI Run Time Library
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

Put10W(w)
unsigned int w;
{
	unsigned int q;

	if (q = w/10)
		Put10W(q);

	PutNibble(w%10);
}
