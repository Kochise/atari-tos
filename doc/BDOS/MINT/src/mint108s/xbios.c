/*
Copyright 1990,1991,1992 Eric R. Smith.
Copyright 1992,1993 Atari Corporation.
All rights reserved.
*/

/*
 * XBIOS replacement routines
 */

#include "mint.h"

extern int tosvers;	/* from main.c */

#define XBIOS_MAX 0x80

Func xbios_tab[XBIOS_MAX];	/* initially all zeros */
short xbios_max = XBIOS_MAX;

/* NOTE: has_bconmap is initialized in main.c */

int has_bconmap;	/* flag: set if running under a version
			 * of TOS which supports Bconmap
			 */

/*
 * Supexec() presents a lot of problems for us: for example, the user
 * may be calling the kernel, or may be changing interrupt vectors
 * unexpectedly. So we play some dirty tricks here: the function
 * call is treated like a signal handler, and we take advantage
 * of the fact that no context switches will take place while
 * in supervisor mode. ASSUMPTION: the user will not choose to
 * switch back to user mode, or if s/he does it will be as part
 * of a longjmp().
 *
 * BUG: if the user function switches to user mode, then back to
 * supervisor mode and returns, then the returned value may be
 * inaccurate (this happens if two programs make Supexec calls
 * at the same time).
 */

long ARGS_ON_STACK (*usrcall) P_((long, long,long,long,long,long));
long usrret;
long usrarg1, usrarg2, usrarg3, usrarg4, usrarg5;

#if 0
/* moved to syscall.spp */
static void ARGS_ON_STACK do_usrcall P_((void));

static void ARGS_ON_STACK
do_usrcall()
{
	usrret = (*usrcall)((long)usrcall, usrarg1, usrarg2, usrarg3, usrarg4,
		 usrarg5);
}
#endif

long ARGS_ON_STACK
supexec(funcptr, arg1, arg2, arg3, arg4, arg5)
	Func funcptr;
	long arg1, arg2, arg3, arg4, arg5;
{
	short savesr;
	CONTEXT *syscall = &curproc->ctxt[SYSCALL];

/* set things up so that "signal 0" will be handled by calling the user's
 * function.
 */

	usrcall = funcptr;
	usrarg1 = arg1;
	usrarg2 = arg2;
	usrarg3 = arg3;
	usrarg4 = arg4;
	usrarg5 = arg5;
	curproc->sighandle[0] = (long)do_usrcall;
	savesr = syscall->sr;	/* save old super/user mode flag */
	syscall->sr |= 0x2000;	/* set supervisor mode */
	handle_sig(0);		/* actually call out to the user function */
	syscall->sr = savesr;

/* do_usrcall saves the user's return value in usrret */
	return usrret;
}


/*
 * midiws: we have to replace this, because it's possible that the process'
 * view of what the MIDI port is has been changed by Fforce or Fmidipipe
 */

long ARGS_ON_STACK
midiws(cnt, buf)
	int cnt;
	const char *buf;
{
	FILEPTR *f;
	long towrite = cnt+1;

	f = curproc->handle[-5];	/* MIDI output handle */
	if (!f) return EIHNDL;

	if (is_terminal(f)) {
		while (cnt >= 0) {
			tty_putchar(f, (long)*buf, RAW);
			buf++; cnt--;
		}
		return towrite;
	}
	return (*f->dev->write)(f, buf, towrite);
}

/*
 * Modem control things: these are replaced because we handle
 * Bconmap ourselves
 */

/* mapin: utility routine, does a Bconmap and keeps track
 * so we call the kernel only when necessary; call this
 * only if has_bconmap is "true".
 * Returns: 0 on failure, 1 on success.
 */
int curbconmap;

int
mapin(dev)
	int dev;
{
	long r;

	if (dev == curbconmap)
		return 1;
	r = Bconmap(dev);
	if (r) {
		curbconmap = dev;
		return 1;
	}
	return 0;
}
	
long ARGS_ON_STACK
uiorec(dev)
	int dev;
{
	TRACE(("Iorec(%d)", dev));
	if (dev == 0 && has_bconmap)
		mapin(curproc->bconmap);
	return (long)Iorec(dev);
}

long ARGS_ON_STACK
rsconf(baud, flow, uc, rs, ts, sc)
	int baud, flow, uc, rs, ts, sc;
{
	long rsval;
	static int oldbaud = -1;
	int ret_oldbaud = 0;
	IOREC_T *ior;

	TRACE(("Rsconf(%d,%d,%d,%d,%d,%d)", baud, flow,
		uc, rs, ts, sc));

	if (has_bconmap)
		mapin(curproc->bconmap);

#ifndef DONT_ONLY030_THIS
/* Note: the code below must be included, even on a 68030, thanks to a bug
 * in the gcc and mntlib osbind.h file.
 */

/*
  If this is an old TOS, try to rearrange things to support
  the following Rsconf() features:
	1. Rsconf(-2, ...) does not return current baud (it crashes)
		-> keep track of old speed in static variable
	2. Rsconf(b, ...) sends ASCII DEL to the modem unless b == -1
		-> make speed parameter -1 if new speed matches old speed
	3. Rsconf() discards any buffered output
		-> use Iorec() to ensure all buffered data was sent before call
*/
	else if (tosvers < 0x0104) {
		if (baud == -2) {
			ret_oldbaud = 1;
			baud = -1;
		} else if (baud == oldbaud)
			baud = -1;
		else if (baud > -1)
			oldbaud = baud;
	}
/* This part _is_ necessary on TOS 1.04 */
	if (tosvers <= 0x0104) {
		int attempts = 0;
		short old_head;
		ior = ((IOREC_T *) uiorec(0)) + 1; /* output record */
		old_head = ior->head;
		while (ior->head != ior->tail) {
			if (++attempts >= 50) { /* prevent getting stuck by flow control */
				if (old_head == ior->head)
					break;
				else {
					old_head = ior->head;
					attempts = 0;
				}
			}
			TRACE(("Rsconf() napping until transmit buf empty"));
			nap(200);
		}
	}
#endif /* ONLY030 */

	rsval = Rsconf(baud, flow, uc, rs, ts, sc);
	if (ret_oldbaud)
		rsval = (long) oldbaud;

	return rsval;
}

long ARGS_ON_STACK
bconmap(dev)
	int dev;
{
	int old = curproc->bconmap;

	TRACE(("Bconmap(%d)", dev));

	if (has_bconmap) {
		if (dev == -1) return old;
		if (dev == -2) return Bconmap(-2);
		if (dev == 0) return 0;  /* the user's just testing */
		if (mapin(dev) == 0) {
			DEBUG(("Bconmap: mapin(%d) failed", dev));
			return 0;
		}
		if (set_auxhandle(curproc, dev) == 0) {
			DEBUG(("Bconmap: Couldn't change AUX:"));
			return 0;
		}
		curproc->bconmap = dev;
		return old;
	}
	return EINVFN;	/* no Bconmap available */
}

/*
 * cursconf(): this gets converted into an ioctl() call on
 * the appropriate device
 */

long ARGS_ON_STACK
cursconf(cmd, op)
	int cmd, op;
{
	FILEPTR *f;

	f = curproc->handle[-1];
	if (!f || !is_terminal(f))
		return EINVFN;
	return
	  (*f->dev->ioctl)(f, TCURSOFF+cmd, &op);
}


long ARGS_ON_STACK
dosound(ptr)
	const char *ptr;
{
	MEMREGION *r;

	if (!no_mem_prot) {
	/* check that this process has access to the memory */
	/* (if not, the next line will cause a bus error) */
		(void)(*((volatile char *)ptr));

	/* OK, now make sure that interrupt routines will have access,
	 * too
	 */
		r = addr2region((long)ptr);
		if (r && get_prot_mode(r) == PROT_P) {
			DEBUG(("Dosound: changing protection to Super"));
			mark_region(r, PROT_S);
		}
	}

	Dosound(ptr);
	return 0;
}

void
init_xbios()
{
	curbconmap = (has_bconmap) ? (int) Bconmap(-1) : 1;

	xbios_tab[0x0c] = midiws;
	xbios_tab[0x0e] = uiorec;
	xbios_tab[0x0f] = rsconf;
	xbios_tab[0x15] = cursconf;
	xbios_tab[0x20] = dosound;
	xbios_tab[0x26] = supexec;
	xbios_tab[0x2c] = bconmap;
}
