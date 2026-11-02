/*
Copyright 1990,1991,1992 Eric R. Smith.
Copyright 1992,1993 Atari Corporation.
All rights reserved.
*/

#include "mint.h"

/*
 * We initialize proc_clock to a very large value so that we don't have
 * to worry about unexpected process switches while starting up
 */

short proc_clock = 0x7fff;

/* used by filesystems for time/date stamps; updated once per second */
short timestamp, datestamp;

extern short in_kernel;	/* in main.c */

static void unnapme P_((PROC *));

/*
 * addtimeout(long delta, void (*func)()): schedule a timeout for the current
 * process, to take place in "delta" milliseconds. "func" specifies a
 * function to be called at that time; the function is passed as a parameter
 * the process for which the timeout was specified (i.e. the value of
 * curproc at the time addtimeout() was called; note that this is probably
 * *not* the current process when the timeout occurs).
 */

TIMEOUT *tlist;

#define newtimeout() (TIMEOUT *)kmalloc(SIZEOF(TIMEOUT))
#define disposetimeout(t) kfree(t)

TIMEOUT * ARGS_ON_STACK
addtimeout(delta, func)
	long delta;
	void (*func) P_((PROC *));
{
	TIMEOUT *t, **prev, *cur;

	t = newtimeout();

/* BUG: we should have some fallback mechanism for timeouts when the
   kernel memory is exhausted
 */
	assert(t);

	t->proc = curproc;
	t->func = func;

	cur = tlist;
	prev = &tlist;
	while (cur) {
		if (cur->when >= delta) {
			cur->when -= delta;
			t->next = cur;
			t->when = delta;
			*prev = t;
			return t;
		}
		delta -= cur->when;
		prev = &cur->next;
		cur = cur->next;
	}
	assert(delta >= 0);
	t->when = delta;
	t->next = cur;
	*prev = t;
	return t;
}

/*
 * cancelalltimeouts(): cancels all pending timeouts for the current
 * process
 */

void ARGS_ON_STACK
cancelalltimeouts()
{
	TIMEOUT *cur, **prev, *old;
	long delta;

	cur = tlist;
	prev = &tlist;
	while (cur) {
		if (cur->proc == curproc) {
			delta = cur->when;
			old = cur;
			*prev = cur = cur->next;
			if (cur) cur->when += delta;
			disposetimeout(old);
		}
		else {
			prev = &cur->next;
			cur = cur->next;
		}
	}
}

/*
 * Cancel a specific timeout. If the timeout isn't on the list, or isn't
 * for this process, we do nothing; otherwise, we cancel the time out
 * and then free the memory it used. *NOTE*: it's very possible (indeed
 * likely) that "this" was already removed from the list and disposed of
 * by the timeout processing routines, so it's important that we check
 * for it's presence in the list and do absolutely nothing if we don't
 * find it there!
 */

void ARGS_ON_STACK
canceltimeout(this)
	TIMEOUT *this;
{
	TIMEOUT *cur, **prev;

	prev = &tlist;
	for (cur = tlist; cur; cur = cur->next) {
		if (cur == this && cur->proc == curproc) {
			*prev = cur->next;
			if (cur->next) {
				cur->next->when += this->when;
			}
			disposetimeout(this);
			break;
		}
		prev = &cur->next;
	}
}

/*
 * timeout: called every 20 ms or so by GEMDOS, this routine
 * is responsible for maintaining process times and such.
 * it should also decrement the "proc_clock" variable, but
 * should *not* take any action when it reaches 0 (the state of the
 * stack is too uncertain, and time is too critical). Instead,
 * a vbl routine checks periodically and if "proc_clock" is 0
 * suspends the current process
 */

volatile int our_clock = 1000;

void ARGS_ON_STACK
timeout()
{
	int ms;		/* time between ticks */

	ms = *((short *)0x442L);
	if (proc_clock > 0)
		proc_clock--;

	our_clock -= ms;
	if (tlist) {
		tlist->when -= ms;
	}
}

/*
 * sleep() calls this routine to check on alarms and other sorts
 * of time-outs on every context switch.
 */

void
checkalarms()
{
	extern long searchtime;		/* in dosdir.c */
	PROC *p;
	long delta;
	void (*evnt) P_((PROC *));
	TIMEOUT *old;

/* do the once per second things */
	while (our_clock < 0) {
		our_clock += 1000;
		timestamp = Tgettime();
		datestamp = Tgetdate();
		searchtime++;
		reset_priorities();
	}

/* see if there are outstanding timeout requests to do */
	while (tlist && ((delta = tlist->when) <= 0)) {
		p = tlist->proc;
		TRACE(("doing timeout code for pid %d", p->pid));
		evnt = tlist->func;
		old = tlist;
		tlist = tlist->next;
		disposetimeout(old);
	/* call the timeout function */
		(*evnt)(p);

/* if delta < 0, it's possible that the time has come for the next timeout
   to occur */
		if (tlist)
			tlist->when += delta;
	}
}

/*
 * nap(n): nap for n milliseconds. Used in loops where we're waiting for
 * an event. If we expect the event *very* soon, we should use yield
 * instead.
 * NOTE: we may not sleep for exactly n milliseconds; signals can wake
 * us earlier, and the vagaries of process scheduling may cause us to
 * oversleep...
 */

static void
unnapme(p)
	PROC *p;
{
	if (p->wait_q == SELECT_Q && p->wait_cond == (long)nap) {
		short sr = spl7();
		rm_q(SELECT_Q, p);
		add_q(READY_Q, p);
		spl(sr);
		p->wait_cond = 0;
	}
}

void ARGS_ON_STACK 
nap(n)
	unsigned n;
{
	TIMEOUT *t;

	t = addtimeout((long)n, unnapme);
	sleep(SELECT_Q, (long)nap);
	canceltimeout(t);
}
