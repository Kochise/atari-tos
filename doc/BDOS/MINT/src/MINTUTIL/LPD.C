/* a simple line printer daemon
 * This code is provided "as is", for informational purposes only.
 * No guarantee of correctness is made by either Eric R. Smith
 * or Atari Corp.
 */

#include <osbind.h>
#ifdef __GNUC__
#include <minimal.h>
#endif
#include "mintbind.h"

#define PRINTERFILE "U:\\DEV\\PRN"
#define MSGQUEUE "U:\\PIPE\\LPD.MSG"
#define MSGSIZ	128
char msgbuf[MSGSIZ];

#define BUFSIZ 2048

int msgfd;	/* requests to print files come here */
int printerfd;

/* make a copy of a file. the name of the copy is kept in local
 * storage, and must be of the form XXXXXXXX.LPR. Moreover, it had
 * better be unique.
 * The string "from" is overwritten with an error message if an error
 * occurs, otherwise from[0] is set to 0.
 */

void
copy_file(from)
	char *from;
{
	static char buf[BUFSIZ];
	static char topat[] = "AAAAAAA.LPR";
	char *to;
	int  infd, outfd;
	long r;

	if ((infd = Fopen(from, 0)) < 0) {
		strcpy(from, "File couldn't be opened for input.");
		return;
	}
	for(;;) {
		to = topat;
		while (*to == 'Z')
			*to++ = 'A';
		if (*to != '.')
			*to += 1;
		outfd = Fopen(topat, 1);
		if (outfd < 0) break;
		Fclose(outfd);
	}

	outfd = Fcreate(topat, 0);
	
	if (outfd < 0) {
		Fclose(infd);
		strcpy(from, "Error creating spool file.");
		return;
	}
	while ((r = Fread(infd, (long)BUFSIZ, buf)) > 0) {
		if (r != Fwrite(outfd, r, buf)) {
			strcpy(from, "Write error on spool file (disk full?)");
			break;
		}
	}

	Fclose(infd);
	Fclose(outfd);

	if (r == 0)
		from[0] = 0;
}

/*
 * get a file name to be printed, and queue it. The queueing is done
 * simply by making a copy of the file (see copyfile(), above) in the
 * current directory.
 */

void
get_request()
{
	Fread(msgfd, (long)MSGSIZ, msgbuf); /* read the request */

/* NOTE: on error, copy_file puts an error message in msgbuf */
	copy_file(msgbuf);
	Fwrite(msgfd, (long)MSGSIZ, msgbuf); /* reply to the request */
}

/*
 * print a file. periodically checks for incoming requests to print,
 * and calls get_request if there are any.
 */

void
print_file(name)
	char *name;
{
	int fd;
	long r;
	static char inbuf[80];

	fd = Fopen(name, 0);
	if (fd < 0) {
		Cconws("lpd: couldn't open a file???\r\n");
		return;
	}
	for(;;) {
		r = Fread(fd, 80L, inbuf);
		if (r <= 0)
			break;
		Fwrite(printerfd, r, inbuf);
	/* check for incoming messages */
		if (Finstat(msgfd))
			get_request();
	}
	Fclose(fd);
	Fdelete(name);
}

int
main(argc, argv)
	int argc;
	char **argv;
{
	extern char *getenv();
	char *tmpdir;
	long r;
	struct _dta p;
	char printfile[80];

/* if a TEMP environment variable exists, use that
 * as our working directory for creating the spool
 * files
 */
	if ((tmpdir = getenv("TEMP"))) {
		if (tmpdir[0] && tmpdir[1] == ':') {
			Dsetdrv(toupper(tmpdir[0])-'A');
			if (tmpdir[2])
				Dsetpath(tmpdir);
			else
				Dsetpath("\\");
		} else
			Dsetpath(tmpdir);
	}
	msgfd = Fcreate(MSGQUEUE, 0);
	if (msgfd == -36) {	/* access denied? */
		Cconws("lpd: a printer daemon already exists\r\n");
		Pterm0();
	}
	else if (msgfd < 0) {
		Cconws("lpd: unable to create message queue\r\n");
		Pterm(1);
	}

	if (argv[1])
		strcpy(printfile, argv[1]);
	else
		strcpy(printfile, PRINTERFILE);

	printerfd = Fcreate(printfile, 0);
	if (printerfd < 0) {
		Cconws("lpd: unable to open printer\r\n");
		Pterm(1);
	}

	Fsetdta(&p);

/* now just loop, printing .LPR files and servicing
 * requests
 */
	for(;;) {
		r = Fsfirst("*.LPR", 0);
		while (r >= 0) {
			print_file(p.dta_name);
			r = Fsnext();
		}
		get_request();	/* get outstanding requests */
	}
}
