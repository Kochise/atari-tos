/*
 * compiling this requires the GCC library, and/or the spawnvp found
 * in the init directory
 */

#include <stdio.h>
#include <process.h>
#include <osbind.h>
#include <mintbind.h>
#include <ctype.h>
#include <signal.h>

void
usage()
{
	fprintf(stderr,
"Usage: limit [-m maxmalloc][-M maxmem][-t maxtime][-v] program [args ... ]\n");
	exit(2);
}

/*
 * get a memory value, e.g. 100K or 1024
 */

long
getmem(s)
	char *s;
{
	char *olds = s;
	int c;
	long val = 0;

	for(;;) {
		c = *s++;
		if (!c) break;
		if (isdigit(c)) {
			val = val * 10 + (c - '0');
		}
		else
			break;
	}
	if (c == 'k' || c == 'K')
		val = 1024 * val;
	else if (c != 0) {
		fprintf(stderr, "invalid number: %s\n", olds);
		usage();
	}
	return val;
}

/*
 * get a time value, either an absolute number of seconds or in the form
 * hh:mm:ss.xxxx
 */
long
gettime(s)
	char *s;
{
	char *olds = s;
	long val = 0, subval = 0;
	int c;

	for(;;) {
		c = *s++;
		if (!c) break;
		if (isdigit(c)) {
			val = val * 10 + (c - '0');
		}
		else if (c == ':') {
			val = 60 * val;
		}
		else
			break;
	}
	val = val * 1000;
	if (c == '.') {
		c = *s++;
		subval = 100;
		while(c && isdigit(c)) {
			val += subval * (c - '0');
			subval /= 10;
			c = *s++;
		}
	}

	if (c != 0) {
		fprintf(stderr, "invalid time: %s\n", olds);
		usage();
	}
	return val;
}

void
ign_it()
{
}

int
main(argc, argv)
	int argc;
	char **argv;
{
	long r;
	long maxmem, maxalloc, maxtime;
	int c, verbose;
	char *name;

	verbose = 0;
	argv++;
	name = *argv;

	maxtime = Psetlimit(1, -1L);
	maxmem = Psetlimit(2, -1L);
	maxalloc = Psetlimit(3, -1L);

	while (name && *name == '-') {
		c = name[1];
		if (c == 'v')
			verbose = 1;
		else {
			name = *++argv;
			if (c == 0 || !name) usage();
			switch(c) {
			  case 'm': maxalloc = getmem(name); break;
			  case 'M': maxmem = getmem(name); break;
			  case 't': maxtime = gettime(name); break;
			  default: usage();
			}
		}
		name = *++argv;
	}

	Psignal(SIGXCPU, ign_it);
	if (verbose)
printf("limits:\ntime: %.3f seconds     memory: %ld total %ld allocation\n",
		  ((double)maxtime/1000), maxmem, maxalloc);
	Psetlimit(1, maxtime);
	Psetlimit(2, maxmem);
	Psetlimit(3, maxalloc);

	if (name)
		r = spawnvp(P_OVERLAY, name, argv);
	else
		r = 0;

	if (r < 0) {
		perror(name);
		exit(1);
	}
	exit(r);
}
