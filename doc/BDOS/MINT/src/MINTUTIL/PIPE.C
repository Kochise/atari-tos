#include "mintbind.h"
#include <process.h>
#include <ctype.h>

extern int errno;

void
usage()
{
	Cconws("Usage: pipe cmd1 cmd2\r\n");
	Pterm(2);
}

main(argc, argv)
	int argc;
	char **argv;
{
	char *cmd1, *cmd2;
	short pipe[2];
	int oldin, oldout;
	long r;

#define pipein ((int)pipe[0])
#define pipeout ((int)pipe[1])

	if (!(cmd1 = argv[1]) || !(cmd2 = argv[2]))
		usage();

	oldin = Fdup(0);
	oldout = Fdup(1);

	r = Fpipe(pipe);
	if (r < 0) {
		errno = -r;
		perror("pipe");
		Pterm(2);
	}

/* run first part of pipeline */
	Fforce(1, pipeout);
	Fclose(pipeout);
	run(P_NOWAIT, cmd1);
	Fforce(1, oldout);

/* run last part of pipeline */
	Fforce(0, pipein);
	Fclose(pipein);
	_exit(run(P_OVERLAY, cmd2));
}

#define MAX_ARGS 64

int
run(mode, cmd)
	int mode;
	char *cmd;
{
	char *argv[MAX_ARGS];
	int argc = 0;
	char *s;
	long r;

	for (s = cmd; *s;) {
		while(*s && isspace(*s)) s++;
		if (!*s) break;
		argv[argc++] = s;
		while(*s && !isspace(*s)) s++;
		if (*s) *s++ = 0;
	}

	if (argc == 0) {
		usage();
	}

	argv[argc] = 0;

	r = spawnvp(mode, argv[0], argv);
	if (r < 0) {
		perror(argv[0]);
		exit(1);
	}
}
