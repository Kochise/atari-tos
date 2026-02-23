/*****************************************************************************
**
** strcpy.c - string copy for MINI Run Time Library
**
** CREATED
** 15 Nov 85 scc
**
** NAMES
**	scc	Steven C. Cavender
**
******************************************************************************
*/

char *strcpy(d, s)
register char	*d, *s;
{
	register char	*p;

	p = d;
	while (*p++ = *s++)
		;
	return(d);
}
