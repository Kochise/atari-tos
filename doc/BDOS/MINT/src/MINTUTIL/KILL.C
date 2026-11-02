#include <osbind.h>
#include "mintbind.h"

#ifdef __GNUC__
#include <minimal.h>
#endif

int
main(argc, argv)
	int argc;
	char **argv;
{
	int i, sig, pid;
	long r;

	sig = 15;	/* SIGTERM */

	if (argc < 2) {
		Cconws("Usage: kill [-n] pid [...]\r\n");
		return 2;
	}
	for (i = 1; i < argc; i++) {
		pid = atoi(argv[i]);
		if (pid < 0)
			sig = -pid;
		else {
			r = Pkill(pid, sig);
			if (r < 0) {
				Cconws("kill: couldn't send signal\r\n");
				return 1;
			}
		}
	}
}
