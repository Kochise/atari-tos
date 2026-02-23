/*****************************************************************************
**
** strlen.c - string length for MINI Run Time Library
**
** CREATED
** 15 Nov 85 SCC
**
** NAMES
**	SCC	Steven C. Cavender
**
******************************************************************************
*/

long strlen(s)
register char *s;
{
	register long i;

	for (i = 0; *s++; i++)
		;
	return (i);
}
