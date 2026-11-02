/*
Copyright 1990,1991,1992 Eric R. Smith.
All rights reserved.
*/

/* dossig.c:: dos signal handling routines */

#include "mint.h"

/*
 * send a signal to another process. If pid > 0, send the signal just to
 * that process. If pid < 0, send the signal to all processes whose process
 * group is -pid. If pid == 0, send the signal to all processes with the
 * same process group id.
 *
 * note: post_sig just posts the signal to the process.
 */

long ARGS_ON_STACK
p_kill(pid, sig)
	int pid, sig;
{
	PROC *p;

	TRACE(("Pkill(%d, %d)", pid, sig));
	if (sig < 0 || sig >= NSIG) {
		DEBUG(("Pkill: signal out of range"));
		return ERANGE;
	}

	if (pid < 0)
		return killgroup(-pid, sig);
	else if (pid == 0)
		return killgroup(curproc->pgrp, sig);
	else {
		p = pid2proc(pid);
		if (p == 0 || p->wait_q == ZOMBIE_Q || p->wait_q == TSR_Q) {
			DEBUG(("Pkill: pid %d not found", pid));
			return EFILNF;
		}
		if (curproc->euid && curproc->ruid != p->ruid) {
			DEBUG(("Pkill: wrong user"));
			return EACCDN;
		}

/* if the user sends signal 0, don't deliver it -- for users, signal
 * 0 is a null signal used to test the existence of a process
 */
		if (sig != 0)
			post_sig(p, sig);
	}

	check_sigs();
	TRACE(("Pkill: returning OK"));
	return 0;
}

/*
 * set a user-specified signal handler, POSIX.1 style
 * "oact", if non-null, gets the old signal handling
 * behaviour; "act", if non-null, specifies new
 * behaviour
 */

long ARGS_ON_STACK
p_sigaction(sig, act, oact)
	int sig;
	const struct sigaction *act;
	struct sigaction *oact;
{
	TRACE(("Psigaction(%d)", sig));
	if (sig < 1 || sig >= NSIG)
		return ERANGE;
	if (act && (sig == SIGKILL || sig == SIGSTOP))
		return EACCDN;
	if (oact) {
		oact->sa_handler = curproc->sighandle[sig];
		oact->sa_mask = curproc->sigextra[sig];
		oact->sa_flags = curproc->sigflags[sig] & SAUSER;
	}
	if (act) {
		ushort flags;

		curproc->sighandle[sig] = act->sa_handler;
		curproc->sigextra[sig] = act->sa_mask & ~UNMASKABLE;

/* only the flags in SAUSER can be changed by the user */
		flags = curproc->sigflags[sig] & ~SAUSER;
		flags |= act->sa_flags & SAUSER;
		curproc->sigflags[sig] = flags;
 
/* various special things that should happen */
		if (act->sa_handler == SIG_IGN) {
			/* discard pending signals */
			curproc->sigpending &= ~(1L<<sig);
		}

/* I dunno if this is right, but bash seems to expect it */
 		curproc->sigmask &= ~(1L<<sig);
	}
	return 0;
}

/*
 * set a user-specified signal handler
 */

long ARGS_ON_STACK
p_signal(sig, handler)
	int sig;
	long handler;
{
	long oldhandle;

	TRACE(("Psignal(%d, %lx)", sig, handler));
	if (sig < 1 || sig >= NSIG)
		return ERANGE;
	if (sig == SIGKILL || sig == SIGSTOP)
		return EACCDN;
	oldhandle = curproc->sighandle[sig];
	curproc->sighandle[sig] = handler;
	curproc->sigextra[sig] = 0;
	curproc->sigflags[sig] = 0;

/* various special things that should happen */
	if (handler == SIG_IGN) {
		/* discard pending signals */
		curproc->sigpending &= ~(1L<<sig);
	}

/* I dunno if this is right, but bash seems to expect it */
	curproc->sigmask &= ~(1L<<sig);

	return oldhandle;
}

/*
 * block some signals. Returns the old signal mask.
 */

long ARGS_ON_STACK
p_sigblock(mask)
	ulong mask;
{
	ulong oldmask;

	TRACE(("Psigblock(%lx)",mask));
/* some signals (e.g. SIGKILL) can't be masked */
	mask &= ~(UNMASKABLE);
	oldmask = curproc->sigmask;
	curproc->sigmask |= mask;
	return oldmask;
}

/*
 * set the signals that we're blocking. Some signals (e.g. SIGKILL)
 * can't be masked.
 * Returns the old mask.
 */

long ARGS_ON_STACK
p_sigsetmask(mask)
	ulong mask;
{
	ulong oldmask;

	TRACE(("Psigsetmask(%lx)",mask));
	oldmask = curproc->sigmask;
	curproc->sigmask = mask & ~(UNMASKABLE);
	check_sigs();	/* maybe we unmasked something */
	return oldmask;
}

/*
 * p_sigpending: return which signals are pending delivery
 */

long ARGS_ON_STACK
p_sigpending()
{
	TRACE(("Psigpending()"));
	check_sigs();	/* clear out any that are going to be delivered soon */

/* note that signal #0 is used internally, so we don't tell the process
 * about it
 */
	return curproc->sigpending & ~1L;
}

/*
 * p_sigpause: atomically set the signals that we're blocking, then pause.
 * Some signals (e.g. SIGKILL) can't be masked.
 */

long ARGS_ON_STACK
p_sigpause(mask)
	ulong mask;
{
	ulong oldmask;

	TRACE(("Psigpause(%lx)", mask));
	oldmask = curproc->sigmask;
	curproc->sigmask = mask & ~(UNMASKABLE);
	if (curproc->sigpending & ~(curproc->sigmask))
		check_sigs();	/* a signal is immediately pending */
	else
		sleep(IO_Q, -1L);
	curproc->sigmask = oldmask;
	check_sigs();	/* maybe we unmasked something */
	TRACE(("Psigpause: returning OK"));
	return 0;
}
