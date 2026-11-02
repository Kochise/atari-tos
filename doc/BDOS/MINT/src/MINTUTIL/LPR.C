/*
 * a print program; this one interfaces with the line printer
 * daemon in lpd.c. All we do is send a request to lpd's port
 * identifying the file we want printed. lpd sends back either
 * a null string (everything's OK) or an error message.
 * The only tricky part about the whole process is that we
 * lock the port once we've opened it, so as to be sure
 * that we don't interleave messages and read the error
 * return intended for some other instantiation of lpr
 *
 * This code is provided as a sample only. No guarantee is made of
 * its correctness by either Eric R. Smith or Atari Corp.
 */

#include <osbind.h>
#ifdef __GNUC__
#include <minimal.h>
#endif
#include "mintbind.h"

#define F_SETLK	6
struct flock {
	short l_type;
#define F_RDLCK		0
#define F_WRLCK		1
#define F_UNLCK		3
	short l_whence;
	long l_start;
	long l_len;
	short l_pid;
} mylock;

#define MSGQUEUE "U:\\PIPE\\LPD.MSG"
#define MSGSIZ	128
char msgbuf[MSGSIZ];
int msgfd;

/*
 * return the full pathname of the file "foo"
 */

char *
fullpath(foo)
	char *foo;
{
	static char ans[128];
	char *s;

	s = ans;
	if (*foo && foo[1] == ':')	/* already a full path? */
		return foo;

	*s++ = Dgetdrv()+'A';		/* put in the drive letter */
	*s++ = ':';
	if (*foo == '\\') {
		strcpy(s, foo);
		return ans;
	}
	*s = 0;
	Dgetpath(s, 0);			/* put in the current directory */
	strcat(s, "\\");		/* plus a path seperator */
	strcat(s, foo);			/* and the file name */
	return ans;
}

main(argc, argv)
	int argc;
	char **argv;
{
	long r;

	if (argc != 2) {
		Cconws("Usage: lpr file\r\n");
		Pterm(2);
	}

	msgfd = Fopen(MSGQUEUE, 2);	/* read/write access needed */
	if (msgfd < 0) {
		Cconws("lpr: couldn't open lpd's message queue\r\n");
		Pterm(1);
	}

/*
 * acquire a lock on the message queue
 */
	mylock.l_type = F_WRLCK;
	mylock.l_whence = 0;
	mylock.l_start = 0;
	mylock.l_len = 0;

	do {
		r = Fcntl(msgfd, &mylock, F_SETLK);

/* old versions of MiNT return -36 (EACCDN) for lock failures.
 * newer versions of MiNT (and MultiTOS) return -58 (ELOCKED)
 */
		if (r == -36 || r == -58) {
			Cconws("lpr: waiting to acquire lock...\r\n");
			Syield();
			Syield();
		} else if (r < 0) {
			Cconws("lpr: fcntl failed??\r\n");
			Pterm(3);
		}
	} while (r < 0);

/*
 * queue the file to be printed
 */
	strcpy(msgbuf, fullpath(argv[1]));

/* write the request */
	Fwrite(msgfd, (long)MSGSIZ, msgbuf);

/* read the server's reply */
	Fread(msgfd, (long)MSGSIZ, msgbuf);

/*
 * Normally, we should release the lock on msgfs. However, we're going
 * to exit now, and the kernel will release the lock for us.
 */

/* check for errors from the server */

	if (msgbuf[0]) {
		Cconws("lpd said: ");
		Cconws(msgbuf);
		Cconws("\r\n");
		Pterm(1);
	}

	Pterm0();
}
