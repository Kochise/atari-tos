/*
 * compiling this requires the GCC library, and/or the spawnvp found
 * in the init directory
 */

#include <stdio.h>
#include <process.h>
#include <osbind.h>
#include <errno.h>
#include <mintbind.h>

void
usage()
{
	fprintf(stderr, "Usage: bg [-o file] program [args ... ]\n");
	exit(2);
}

int
main(argc, argv)
	int argc;
	char **argv;
{
	long r;
	int olderr;
	int oldpgrp;
	char *name;

	if (!argv[1]) {
		usage();
	}

	olderr = Fdup(2);
	argv++;
	name = *argv;
	if (!strcmp(name, "-o")) {
		name = *++argv;
		if (!name) usage();
		r = Fcreate(name, 0);
		if (r < 0) {
			errno = -r;
			perror(name);
			exit(1);
		}
		name = *++argv;
		if (!name) usage();
	/* redirect stdout, stderr, and the control terminal (-1) */
		Fforce(-1, r);
		Fforce(1, r);
		Fforce(2, r);
	}

/* put child process into a new process group */
	oldpgrp = Pgetpgrp();
	Psetpgrp((int)Pgetpid(), (int)Pgetpid());
	r = spawnvp(P_NOWAIT, name, argv);
	Psetpgrp((int)Pgetpid(), oldpgrp);

	Fforce(2, olderr);

	if (r < 0) {
		perror(name);
		exit(2);
	}
	exit(r);
}
