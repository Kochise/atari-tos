#include <stdio.h>
#include <process.h>
#include <osbind.h>
#include "mintbind.h"

void
usage()
{
	fprintf(stderr, "Usage: nice [-#] program [args ... ]\n");
	exit(-1);
}

int
main(argc, argv)
	int argc;
	char **argv;
{
	long r;
	int delta = 10;

	char *name;

	if (!argv[1]) {
		usage();
	}

	argv++;
	name = *argv;
	if (*name == '-') {
		delta = atoi(name+1);
		name = *++argv;
	}

	Pnice(delta);
	r = spawnvp(P_OVERLAY, name, argv);

	if (r < 0) {
		perror(argv[1]);
		exit(-1);
	}
	exit(r);
}
