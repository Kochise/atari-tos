/*
 * This file belongs to MH-MiNT.  It's not in the original MiNT 1.12
 * distribution.  See the file Changes.MH for a detailed log of changes.
 */

/* uk: this is the system update daemon, its only purpose is to call
 *     Sync() in regular intervals, so file systems get their sync()
 *     function called.
 */

#include <mintbind.h>

#include "mint.h"

#ifndef Sync    /* temporary hack for gnu c */
#ifdef __GNUC__
#define Sync() (void)(trap_1_w(0x150))
#endif
#endif

long update_stksize = 1024;
long sync_time = 5;


void do_sync(long);
void update(long);


void
do_sync(long sig)
{
	Sync();
}

void
update(long bp)
{
	setstack(bp+256+update_stksize-32);
	Psignal(SIGALRM, do_sync);
	Psignal(SIGTERM, do_sync);
	Psignal(SIGQUIT, do_sync);
	Psignal(SIGHUP, do_sync);
	Psignal(SIGTSTP, do_sync);
	Psignal(SIGINT, do_sync);
	Psignal(SIGABRT, do_sync);
	Psignal(SIGUSR1, do_sync);
	Psignal(SIGUSR2, do_sync);

	for (;;)
	{
		int tsync;
		tsync = sync_time;
		while (tsync > 32)
		{
			(void)Fselect(32000, 0L, 0L, 0L);
			tsync -= 32;
		}
		if (tsync > 0)
			(void)Fselect(tsync*1000L, 0L, 0L, 0L);
			do_sync(0);
	}
}


/* start a new asynchronous process */
void
start_sysupdate()
{
	BASEPAGE *b;
	int pid;

	b = (BASEPAGE*)p_exec(5, 0L, "", 0L);  /* create basepage */
	(void)m_shrink(0, (virtaddr)b, 256+update_stksize);
	b->p_tbase = (long)update;
	b->p_hitpa = (long)b +256+update_stksize;
	pid = (short)p_exec(104, "sysupdate", b, 0L);
}
