#include <minimal.h>
#include <mintbind.h>

int
main(int argc, char **argv)
{
	int delta = 5, pid, err = 0;
	char *name = argv[0];

	argv++;

	if (*argv && argv[0][0] == '-') {
		delta = atoi(&argv[0][1]);
		argv++;
	}

	if (!*argv) {
		Cconws("Usage: renice [-niceness] pid\r\n");
		return 2;
	}

	do {
		pid = atoi(*argv++);
		if (Prenice(pid, delta) < 0) {
			Cconws(argv[-1]); Cconws(": not found\r\n");
			err = 1;
		}
	} while (*argv);
	return 0;
}
