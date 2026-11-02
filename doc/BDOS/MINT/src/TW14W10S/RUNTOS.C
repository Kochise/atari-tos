/*
 * runtos: a small program that will launch a TOS or TTP program
 * in a TOSWIN window.
 * To compile:
 *     gcc -O -mshort -o runtos.prg runtos.c -lgem16
 * To run:
 *     runtos someprog.tos arg1 arg2 arg3
 * OR
 *     Using the desktop, do an "Install Application" on runtos.prg.
 *     For "document type", use .TOS. Now, double clicking on a TOS
 *     program will automatically start it up in a TOSWIN window.
 *     (unfortunately, it will also cause all TOSWIN windows to be
 *     hidden -- you'll have to select "TOS programs" from the DESK
 *     menu to get them back again).
 * BUGS
 *     See above. Also, it would be nice to have a "runttp.prg"
 *     that would prompt for .TTP arguments. This is left as an
 *     exercise for the interested reader.
 *
 * "runtos" was written by Eric R. Smith and is hereby placed in
 * the public domain.
 */

#include <minimal.h>

long _stksize = 2*1024;

int
main(int argc, char **argv)
{
/* BUG: shouldn't have a fixed size buffer */
	static char buf[1024];
#ifdef WWA_GEM_RUN
	static char prg[128];
#endif
	char *where = buf;
	int i, fd;
	long r;

	if (!argv[1]) return 2;

#ifdef WWA_GEM_RUN
	if (0==strcmp(argv[1],"-g")) {
		*where++ = '\01';
		argv++;
	}
#endif

/* first, put the path */
	*where++ = Dgetdrv() + 'A';
	*where++ = ':';
	Dgetpath(where, 0);
	if (!*where) *where = '\\';
	strcat(where, " ");

/* WWA - previously, no conversion was done.  However, TOSWIN assumes DOS */
/* next, put the program (in TOS format) */
	if (unx2dos(argv[1],prg)) {
		strcat(where, argv[1]);
	} else {
		strcat(where, prg);
	}

/* finally, put the arguments */
	for (i = 2; argv[i]; i++) {
		strcat(where, " ");
		strcat(where, argv[i]);
	}

	fd = Fopen("U:\\PIPE\\TOSRUN", 2);
	if (fd < 0) return 1;

	r = strlen(buf) + 1;

	if (Fwrite(fd, r, buf) != r)
		return 1;

	return 0;
}
