/*
 * This file belongs to FreeMiNT.  It's not in the original MiNT 1.12
 * distribution.  See the file Changes.MH for a detailed log of changes.
 */

/* uk: this is the system update daemon, its only purpose is to call
 *     Sync() in regular intervals, so file systems get their sync()
 *     function called.
 */

#ifdef SYSUPDATE_DAEMON

#ifndef __TURBOC__
#	include <mintbind.h>
#endif

#include "mint.h"

#ifndef Sync    /* temporary hack */
#	ifdef __GNUC__
#		define Sync() (void)(trap_1_w(0x150))
#	endif
#	ifdef __TURBOC__
#		define Sync()	gemdos(0x150)
#	endif
#endif

long update_stksize = 1024;
long sync_time = 5;


void do_sync(long);
void update(long);


void
do_sync(long sig)
{
	UNUSED (sig);

	Sync();
}

void
update(long bp)
{
#if 0
	setstack(bp+256+update_stksize-32);
#endif
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
		long tsync = sync_time;

		while (tsync > 32)
		{
			Fselect(32000, 0L, 0L, 0L);
			tsync -= 32;
		}
		if (tsync > 0) Fselect ((int)tsync*1000, 0L, 0L, 0L);

		do_sync(0);
	}
}


/* start a new asynchronous process */
void
start_sysupdate()
{
	BASEPAGE *b;

	b = (BASEPAGE*)p_exec(5, 0L, "", 0L);  /* create basepage */
	m_shrink(0, (virtaddr)b, 256+update_stksize);
	b->p_tbase = (long)update;
	b->p_hitpa = (long)b +256+update_stksize;
	p_exec(104, "sysupdate", b, 0L);
}
#endif
