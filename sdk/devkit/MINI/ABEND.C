/*****************************************************************************
**
** abend.c - report the message for the error code passed in and terminate
**
** CREATED
** 15 oct 85 scc
**
** MODIFICATIONS
** 15 Nov 85 SCC	Minor cleanups to reduce size and improve output.
**
** NAMES
**	scc	Steven C. Cavender
**
******************************************************************************
*/

#include <mini.h>

char ns[] = "";

char *errors[] =
{
	"OK, no error",			/*   0 */
	"Basic, fundamental error",	/*  -1 */
	"Drive not ready",		/*  -2 */
	"Unknown command",		/*  -3 */
	"CRC error",			/*  -4 */
	"Bad request",			/*  -5 */
	"Seek error",			/*  -6 */
	"Unknown media",		/*  -7 */
	"Sector not found",		/*  -8 */
	"No paper",			/*  -9 */
	"Write fault",			/* -10 */
	"Read fault",			/* -11 */
	"General error",		/* -12 */
	"Write protect",		/* -13 */
	"Media change",			/* -14 */
	"Unknown device",		/* -15 */
	"Bad sectors on format",	/* -16 */
	"Insert other disk",		/* -17 */
	ns, ns, ns, ns, ns, ns, ns, ns,	/* -18..-25 */
	ns, ns, ns, ns, ns, ns,		/* -26..-31 */
	"Invalid function number",	/* -32 */
	"File not found",		/* -33 */
	"Path not found",		/* -34 */
	"No handles left",		/* -35 */
	"Access denied",		/* -36 */
	"Invalid handle",		/* -37 */
	ns,				/* -38 */
	"Insufficient memory",		/* -39 */
	"Invalid memory block address",	/* -40 */
	ns, ns, ns, ns, ns,		/* -41..-45 */
	"Invalid drive",		/* -46 */
	ns, ns,				/* -47..-48 */
	"No more files",		/* -49 */
	ns, ns, ns, ns, ns, ns, ns, ns,	/* -50..-57 */
	ns, ns, ns, ns, ns, ns,		/* -58..-63 */
	"Range error",			/* -64 */
	"Internal error",		/* -65 */
	"Invalid program load format",	/* -66 */
	"Setblock failure:  no grow"	/* -67 */
};

abend(l)
long l;
{
	int i;

	i = (int)-l;
	if (i)
		C_ConOut('-');
	Put10W(i);
	C_ConOut('\t');
	C_ConWS(errors[i]);
	P_Term(-i);
}
