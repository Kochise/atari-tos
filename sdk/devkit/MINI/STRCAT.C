/*****************************************************************************
**
** strcat.c - string concatenate for MINI Run Time Library
**
** CREATED
** 15 Nov 85 scc
**
** NAMES
**	scc	Steven C. Cavender
**
******************************************************************************
*/

char *strcat(d, s)
register char	*d, *s;
{
	register char	*p;

	p = d;
	while (*p)
		p++;
	while (*p++ = *s++)
		;
	return(d);
}
