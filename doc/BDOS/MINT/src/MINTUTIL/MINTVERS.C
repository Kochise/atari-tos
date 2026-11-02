#include <osbind.h>

/*
 * get MiNT version number
 */

int mint;

static void
getMiNT()
{
	long *cookie;

	cookie = *((long **) 0x5a0);
	if (!cookie)
		mint = 0;
	else {
		while (*cookie) {
			if (*cookie == 0x4d694e54L) {
				mint = cookie[1];
				return;
			}
			cookie += 2;
		}
	}
	mint = 0;
}

int
main(argc, argv)
	int argc;
	char **argv;
{
	int minvers, majvers;

	Supexec(getMiNT);
	majvers = (mint&0xff00) >> 8;
	minvers = (mint&0x00ff);

	if (argc < 2) {
		if (mint != 0) {
			printf("MiNT version %d.%d\n", majvers, minvers);
		}
		else {
			printf("MiNT is not active\n");
		}
	}
	exit(mint);
}
