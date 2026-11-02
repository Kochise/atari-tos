/*
Copyright 1990,1991,1992 Eric R. Smith.
Copyright 1992,1993 Atari Corporation.
All rights reserved.
*/

/*
 * BIOS replacement routines
 */

#include "mint.h"
#include "xbra.h"

#define UNDEF 0		/* should match definition in tty.c */

/* some key definitions */
#define CTRLALT 0xc
#define DEL 0x53	/* scan code of delete key */
#define UNDO 0x61	/* scan code of undo key */

/* BIOS device definitions */
#define CONSDEV 2
#define AUXDEV 1
#define PRNDEV 0

/* BIOS devices 0..MAX_BHANDLE-1 can be redirected to GEMDOS files */
#define MAX_BHANDLE	4

/* BIOS redirection maps */
const short binput[MAX_BHANDLE] = { -3, -2, -1, -4 };
const short boutput[MAX_BHANDLE] = { -3, -2, -1, -5 };

/* tty structures for the BIOS devices -- see biosfs.c */
extern struct tty con_tty, aux_tty, midi_tty;

extern int tosvers;	/* from main.c */

char *kbshft;		/* set in main.c */

/* some BIOS vectors; note that the routines at these vectors may do nasty
 * things to registers!
 */

#define RWABS *((long *)0x476L)
#define MEDIACH *((long *)0x47eL)
#define GETBPB *((long *)0x472L)


#if 1
/* these are supposed to be tables holding the addresses of the
 * first 8 BconXXX functions, but in fact only the first 5 are
 * placed here (and device 5 only has Bconout implemented; 
 * we don't use that device (raw console) anyway).
 */

#define xconstat ((long *)0x51eL)
#define xconin 	((long *)0x53eL)
#define xcostat ((long *)0x55eL)
#define xconout	((long *)0x57eL)

#define BCOSTAT(dev) \
	((tosvers > 0x0102 && (unsigned)dev <= 4) ? \
	   (int)callout1(xcostat[dev], dev) : Bcostat(dev))
#define BCONOUT(dev, c) \
	((tosvers > 0x0102 && (unsigned)dev <= 4) ? \
	   callout2(xconout[dev], dev, c) : Bconout(dev, c))
#define BCONSTAT(dev) \
	((tosvers > 0x0102 && (unsigned)dev <= 4) ? \
	   (int)callout1(xconstat[dev], dev) : Bconstat(dev))
#define BCONIN(dev) \
	((tosvers > 0x0102 && (unsigned)dev <= 4) ? \
	   callout1(xconin[dev], dev) : Bconin(dev))
#else
#define BCOSTAT(dev) Bcostat(dev)
#define BCONOUT(dev,c) Bconout(dev,c)
#define BCONSTAT(dev) Bconstat(dev)
#define BCONIN(dev) Bconin(dev)
#endif

/* variables for monitoring the keyboard */
IOREC_T	*keyrec;		/* keyboard i/o record pointer */
short	kintr = 0;		/* keyboard interrupt pending (see intr.s) */

/* Getmpb is not allowed under MiNT */

long ARGS_ON_STACK
getmpb(ptr)
	void *ptr;
{
	UNUSED(ptr);

	DEBUG(("failed call to Getmpb"));
	return -1;
}


/*
 * Note that BIOS handles 0 - MAX_BHANDLE now reference file handles;
 * to get the physical devices, go through u:\dev\
 *
 * A note on translation: all of the bco[n]XXX functions have a "u"
 * variant that is actually what the user calls. For example,
 * ubconstat is the function that gets control after the user does
 * a Bconstat. It figures out what device or file handle is
 * appropriate. Typically, it will be a biosfs file handle; a
 * request is sent to biosfs, and biosfs in turn figures out
 * the "real" device and calls bconstat.
 */

/*
 * WARNING: syscall.spp assumes that ubconstat never blocks.
 */
long ARGS_ON_STACK
ubconstat(dev)
int dev;
{
	if (dev < MAX_BHANDLE) {
		FILEPTR *f = curproc->handle[binput[dev]];
		return file_instat(f) ? -1 : 0;
	}
	else
		return bconstat(dev);
}

long
bconstat(dev)
int dev;
{
	if (dev == CONSDEV) {
		if (checkkeys()) return 0;
		return (keyrec->head != keyrec->tail) ? -1 : 0;
	}
	if (dev == AUXDEV && has_bconmap)
		dev = curproc->bconmap;

	return BCONSTAT(dev);
}

/* bconin: input a character */
/*
 * WARNING: syscall.spp assumes that ubconin never
 * blocks if ubconstat returns non-zero.
 */
long ARGS_ON_STACK
ubconin(dev)
int dev;
{
	if (dev < MAX_BHANDLE) {
		FILEPTR *f = curproc->handle[binput[dev]];
		return file_getchar(f, RAW);
	}
	else
		return bconin(dev);
}

long
bconin(dev)
int dev;
{
	IOREC_T *k;
	long r;
	short h;

	if (dev == CONSDEV) {
		k = keyrec;
again:
		while (k->tail == k->head) {
			yield();
		}

		if (checkkeys()) goto again;

		h = k->head + 4;
		if (h >= k->buflen)
			h = 0;
		r = *((long *)(k->bufaddr + h));
		k->head = h;
		return r;
	}
	else {
		if (dev == AUXDEV && has_bconmap)
			dev = curproc->bconmap;

		if (dev > 0) {
			while (!BCONSTAT(dev)) {
				yield();
			}
		}
	}

	r = BCONIN(dev);

	return r;
}

/* bconout: output a character.
 * returns 0 for failure, nonzero for success
 */

long ARGS_ON_STACK
ubconout(dev, c)
int dev, c;
{
	FILEPTR *f;
	char outp;

	if (dev < MAX_BHANDLE) {
		f = curproc->handle[boutput[dev]];
		if (!f) return 0;
		if (is_terminal(f)) {
			return tty_putchar(f, ((long)c)&0x00ff, RAW);
		}
		outp = c;
		return (*f->dev->write)(f, &outp, 1L);
	}
	else if (dev == 5) {
		c &= 0x00ff;
		f = curproc->handle[-1];
		if (!f) return 0;
		if (is_terminal(f)) {
			if (c < ' ') {
			/* MW hack for quoted characters */
				tty_putchar(f, (long)'\033', RAW);
				tty_putchar(f, (long)'Q', RAW);
			}
			return tty_putchar(f, ((long)c)&0x00ff, RAW);
		}
	/* note: we're assuming sizeof(int) == 2 here! */
		outp = c;
		return (*f->dev->write)(f, &outp, 1L);
	} else
		return bconout(dev, c);
}

long
bconout(dev, c)
int dev,c;
{
	int statdev;
	long endtime;
#define curtime *((unsigned long *)0x4baL)

	if (dev == AUXDEV && has_bconmap) {
		dev = curproc->bconmap;
	}

/* compensate for a known BIOS bug; MIDI and IKBD are switched */
	if (dev == 3) {		/* MIDI */
		statdev = 4;
	} else if (dev == 4) {
		statdev = 3;
	} else {
		statdev = dev;
	}

/* provide a 10 second time out for the printer */
	if (!BCOSTAT(statdev)) {
		if (dev != PRNDEV) {
			do {
	/* BUG: Speedo GDOS isn't re-entrant; so printer output to the
	 * serial port could cause problems
	 */
				yield();
			} while (!BCOSTAT(statdev));
		} else {
			endtime = curtime + 10*200L;
			do {
#if 0
	/* Speedo GDOS isn't re-entrant, so we can't give up CPU
	 * time here :-(
	 */
				yield();
#endif
			} while (!BCOSTAT(statdev) && curtime < endtime);
			if ( curtime >= endtime) return 0;
		}
	}

/* special case: many text accelerators return a bad value from
 * Bconout, so we ignore the returned value for the console
 * Sigh. serptch2 and hsmodem1 also screw this up, so for now let's
 * only count on it being correct for the printer.
 */
	if (dev == PRNDEV) {
/* NOTE: if your compiler complains about the next line, then Bconout is
 * improperly declared in your osbind.h header file. it should be returning
 * a long value; some libraries incorrectly have Bconout returning void
 * (or cast the returned value to void)
 */
		return BCONOUT(dev,c);
	} else {
		(void)BCONOUT(dev, c);
		return 1;
	}
}

/* rwabs: various disk stuff */

/* BUG: Rwabs should respect Dlock */

long ARGS_ON_STACK
rwabs(rwflag, buffer, number, recno, dev, lrecno)
int rwflag, number, recno, dev;
void *buffer;
long lrecno;
{
	long r;
	extern PROC *dlockproc[];	/* in dosdir.c */

	if (dev >= 0 && dev < NUM_DRIVES && dlockproc[dev]) {
		if (dlockproc[dev] != curproc) {
			DEBUG(("Rwabs: device %c is locked", dev+'A'));
			return ELOCKED;
		}
	}

/* Note that some (most?) Rwabs device drivers don't bother saving
 * registers, whereas our compiler expects politeness. So we go
 * via callout(), which will save registers for us.
 */
	r = callout(RWABS, rwflag, buffer, number, recno, dev, lrecno);
	return r;
}

/* setexc: set exception vector */

long ARGS_ON_STACK
setexc(number, vector)
int number;
long vector;
{
	long *place;
	long old;
	extern long save_dos, save_bios, save_xbios;	/* in main.c */
	extern int no_mem_prot;				/* in main.c */

	place = (long *)(((long)number) << 2);
	if (number == 0x21)				/* trap_1 */
		old = save_dos;
	else if (number == 0x2d)			/* trap_13 */
		old = save_bios;
	else if (number == 0x2e)			/* trap_14 */
		old = save_xbios;
	else if (number == 0x101)
		old = (long)curproc->criticerr;		/* critical error vector */
	else if (number == 0x102)
		old = curproc->ctxt[SYSCALL].term_vec;	/* GEMDOS term vector */
	else
		old = *place;

	if (vector > 0) {
	/* validate vector; this will cause a bus error if mem
	 * protection is on and the current process doesn't have
	 * access to the memory
	 */
		if (*((long *)vector) == 0xDEADBEEFL)
			return old;

		if (number == 0x21)
			save_dos = vector;
		else if (number == 0x2d)
			save_bios = vector;
		else if (number == 0x2e)
			save_xbios = vector;
		else if (number == 0x102)
			curproc->ctxt[SYSCALL].term_vec = vector;
		else if (number == 0x101) {
			long mintcerr;

		/*
		 * problem: lots of TSR's look for the Setexc(0x101,...)
	 	 * that the AES does at startup time; so we have
		 * to pass it along.
		 */
			mintcerr = (long) Setexc(0x101, (void *)vector);
			curproc->criticerr = (long ARGS_ON_STACK (*) P_((long))) *place;
			*place = mintcerr;
		}
		else {
			if (!no_mem_prot) {
			/*
			 * if memory protection is on, the vector should be
			 * pointing at supervisor or global memory
			 */
			    MEMREGION *r;

			    r = addr2region(vector);
			    if (r && get_prot_mode(r) == PROT_P) {
				DEBUG(("Changing protection to Supervisor because of Setexc"));
				mark_region(r, PROT_S);
			    }
			}
		/* We would do just *place = vector except that
		 * someone else might be intercepting Setexc looking
		 * for something in particular...
		 */
			old = (long) Setexc(number, (void *)vector);
		}
	}

	TRACE(("Setexc %d, %lx -> %lx", number, vector, old));
	return old;
}

/* tickcal: return milliseconds per system clock tick */

long ARGS_ON_STACK
tickcal()
{
	return (long) (*( (unsigned *) 0x0442L ));
}

/* getbpb: get BIOS parameter block */

long ARGS_ON_STACK
getbpb(dev)
int dev;
{
	long r;

/* we can't trust the Getbpb routine to accurately save all registers,
 * so we do it ourselves
 */
	r = callout1(GETBPB, dev);
/* 
 * There is a bug in the  TOS  disk handling routines (well several actually).
 * If the directory size of Getbpb() is returned as zero then the drive 'dies'
 * and wont read any new disks even with the 'ESC' enforced disk change . This
 * is present even in TOS 1.6 (not sure about 1.62 though). This small routine
 * changes the dir size to '1' if it is zero . It may make some non-TOS disks
 * look a bit weird but that's better than killing the drive .
 */
	if (r) {
		if ( ((short *)r)[3] == 0)	/* 0 directory size? */
			((short *)r)[3] = 1;
	}
	return r;
}

/* bcostat: return output device status */

/* WARNING: syscall.spp assumes that ubcostat never
 * blocks
 */
long ARGS_ON_STACK
ubcostat(dev)
int dev;
{
	FILEPTR *f;

/* the BIOS switches MIDI (3) and IKBD (4) (a bug, but it can't be corrected) */
	if (dev == 4) {		/* really the MIDI port */
		f = curproc->handle[boutput[3]];
		return file_outstat(f) ? -1 : 0;
	}
	if (dev == 3)
		return BCOSTAT(dev);

	if (dev < MAX_BHANDLE) {
		f = curproc->handle[boutput[dev]];
		return file_outstat(f) ? -1 : 0;
	} else
		return bcostat(dev);
}

long
bcostat(dev)
int dev;
{

	if (dev == CONSDEV) {
		return -1;
	}
	else if (dev == AUXDEV && has_bconmap) {
		dev = curproc->bconmap;
	}
/* compensate here for the BIOS bug, so that the MIDI and IKBD files work
 * correctly
 */
	else if (dev == 3) dev = 4;
	else if (dev == 4) dev = 3;

	return BCOSTAT(dev);
}

/* mediach: check for media change */

long ARGS_ON_STACK
mediach(dev)
int dev;
{
	long r;

	r = callout1(MEDIACH, dev);
	return r;
}

/* drvmap: return drives connected to system */

long ARGS_ON_STACK
drvmap()
{
	return *( (long *)0x4c2L );
}

/* kbshift: return (and possibly change) keyboard shift key status */
/* WARNING: syscall.spp assumes that kbshift never blocks, and never
 * calls any underlying TOS functions
 */
long ARGS_ON_STACK
kbshift(mode)
int mode;
{
	int oldshft;

	oldshft = *((unsigned char *)kbshft);
	if (mode >= 0)
		*kbshft = mode;
	return oldshft;
}


/* special Bconout buffering code:
 * Because system call overhead is so high, programs that do output
 * with Bconout suffer in performance. To compensate for this,
 * Bconout is special-cased in syscall.s, and if possible characters
 * are placed in the 256 byte bconbuf buffer. This buffer is flushed
 * when any system call other than Bconout happens, or when a context
 * switch occurs.
 */

short bconbsiz;			/* number of characters in buffer */
unsigned char bconbuf[256];	/* buffer contents */
short bconbdev;			/* BIOS device for which the buffer is valid */
				/* (-1 means no buffering is active) */

/*
 * flush pending BIOS output. Return 0 if some bytes were not successfully
 * written, non-zero otherwise (just like bconout)
 */

long ARGS_ON_STACK
bflush()		/* flush bios output */
{
	long ret, bsiz;
	unsigned char *s;
	FILEPTR *f;
	short dev;
	short statdev;
	long lbconbuf[256];

	if ((dev = bconbdev) < 0) return 0;

/*
 * Here we lock the BIOS buffering mechanism by setting bconbdev to -1
 * This is necessary because if two or more programs try to do
 * buffered BIOS output at the same time, they can get seriously
 * mixed up. We unlock by setting bconbdev to 0.
 *
 * NOTE: some code (e.g. in sleep()) checks for bconbsiz != 0 in
 * order to see if we need to do a bflush; if one is already in
 * progress, it's pointless to do this, so we save a bit of
 * time by setting bconbsiz to 0 here.
 */
	bconbdev = -1;
	bsiz = bconbsiz;
	if (bsiz == 0) return 0;
	bconbsiz = 0;

/* BIOS handles 0..MAX_BHANDLE-1 are aliases for special GEMDOS files */
	if (dev < MAX_BHANDLE || dev == 5) {
		if (dev == 5)
			f = curproc->handle[-1];
		else
			f = curproc->handle[boutput[dev]];

		if (!f) {
			bconbdev = 0;
			return 0;
		}
		if (is_terminal(f)) {
			s = bconbuf;
			if (dev == 5) {
			    while (bsiz-- > 0) {
				if (*s < ' ') {
			/* use ESC-Q to quote control character */
					(void)tty_putchar(f, (long)'\033',
								RAW);
					(void)tty_putchar(f, (long)'Q',
								RAW);
				}
				(void) tty_putchar(f, (long)*s++, RAW);
			    }
			} else {
#if 1
			    long *where, nbytes;

/* the tty_putchar should set up terminal modes correctly */
			    (void) tty_putchar(f, (long)*s++, RAW);
			    where = lbconbuf;
			    nbytes = 0;
			    while (--bsiz > 0) {
				*where++ = *s++; nbytes+=4;
			    }
			    if (nbytes)
				(*f->dev->write)(f, (char *)lbconbuf, nbytes);
#else
			    while (bsiz-- > 0) {
				(void) tty_putchar(f, (long)*s++, RAW);
			    }
#endif
			}
			ret = -1;
		} else {
			ret = (*f->dev->write)(f, (char *)bconbuf, bsiz);
		}
		bconbdev = 0;
		return ret;
	}

/* Otherwise, we have a real BIOS device */

	if (dev == AUXDEV && has_bconmap) {
		dev = curproc->bconmap;
		statdev = dev;
	}
/* compensate for a known BIOS bug; MIDI and IKBD are switched */
	else if (dev == 3) {		/* MIDI */
		statdev = 4;
	} else if (dev == 4) {
		statdev = 3;
	} else
		statdev = dev;
		
	s = bconbuf;
	while (bsiz-- > 0) {
		while (!BCOSTAT(statdev)) yield();
		(void)BCONOUT(dev,*s);
		s++;
	}
	bconbdev = 0;
	return 1L;
}

/* initialize bios table */

#define BIOS_MAX 0x20

Func bios_tab[BIOS_MAX] = {
	getmpb,
	ubconstat,
	ubconin,
	ubconout,

	rwabs,
	setexc,
	tickcal,
	getbpb,

	ubcostat,
	mediach,
	drvmap,
	kbshift,

	0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0
};

short bios_max = BIOS_MAX;

/*
 * BIOS initialization routine: gets keyboard buffer pointers, for the
 * interrupt routine below
 */

void
init_bios()
{
	keyrec = (IOREC_T *)Iorec(1);
}

/*
 * do_bconin: try to do a bconin function quickly, without
 * blocking. If we can't do it without blocking, we return
 * 0x0123dead and the calling trap #13 code falls through
 * to the normal bconin stuff. We can't block here because
 * the trap #13 code hasn't yet saved registers or other
 * context bits, so sleep() wouldn't work properly.
 */

#define WOULDBLOCK 0x0123deadL

/* WARNING: syscall.spp assumes that do_bconin never blocks */

long ARGS_ON_STACK
do_bconin(dev)
	int dev;
{
	FILEPTR *f;
	long r;
	unsigned char c;

	if (dev < MAX_BHANDLE) {
		f = curproc->handle[binput[dev]];
		if (!f) return 0;
		r = 0;
		(void)(*f->dev->ioctl)(f, FIONREAD, &r);
		if (!r) return WOULDBLOCK;	/* data not ready */
		if (is_terminal(f))
			r = tty_getchar(f, RAW);
		else {
			r = (*f->dev->read)(f, (char *)&c, 1L);
			r = (r == 1) ? c : MiNTEOF;
		}
	} else {
		if (!bconstat(dev))
			r = WOULDBLOCK;
		else
			r = bconin(dev);
	}
	return r;
}

/*
 * routine for checking keyboard (called by sleep() on any context
 * switch where a keyboard event occured). returns 1 if a special
 * control character was eaten, 0 if not
 */

int
checkkeys()
{
	char scan, ch;
	short shift;
	int sig, ret;
	struct tty *tty = &con_tty;
	extern char mshift;		/* for mouse -- see biosfs.c */
	static short oldktail = 0;

	ret = 0;
	mshift = kbshift(-1);
	while (oldktail != keyrec->tail) {

/* BUG: we really should check the shift status _at the time the key was
 * pressed_, not now!
 */
		sig = 0;
		shift = mshift;
		oldktail += 4;
		if (oldktail >= keyrec->buflen)
			oldktail = 0;

		scan = (keyrec->bufaddr + oldktail)[1];
/* function key?? */
		if ( (scan >= 0x3b && scan <= 0x44) ||
		     (scan >= 0x54 && scan <= 0x5d) ||
		     scan == DEL || scan == UNDO) {
			if ( (shift & CTRLALT) == CTRLALT ) {
				oldktail = keyrec->head = keyrec->tail;
				do_func_key(scan);
				/* do_func_key may have read some keys */
				oldktail = keyrec->head;
				mshift = kbshift (-1);
				ret = 1;
				continue;
			}
		}

/* check for special control keys, etc. */
/* BUG: this doesn't exactly match TOS' behavior, particularly for
 * ^S/^Q
 */
		if ((tty->state & TS_COOKED) || (shift & CTRLALT) == CTRLALT) {
			ch = (keyrec->bufaddr + keyrec->tail)[3];
			if (ch == UNDEF)
				;	/* do nothing */
			else if (ch == tty->tc.t_intrc)
				sig = SIGINT;
			else if (ch == tty->tc.t_quitc)
				sig = SIGQUIT;
			else if (ch == tty->ltc.t_suspc)
				sig = SIGTSTP;
			else if (ch == tty->tc.t_stopc) {
				tty->state |= TS_HOLD;
				ret = 1;
				keyrec->head = oldktail;
				continue;
			}
			else if (ch == tty->tc.t_startc) {
				tty->state &= ~TS_HOLD;
				ret = 1;
				keyrec->head = oldktail;
				continue;
			}
			if (sig) {
				tty->state &= ~TS_HOLD;
				if (!(tty->sg.sg_flags & T_NOFLSH))
				    oldktail = keyrec->head = keyrec->tail;
				killgroup(tty->pgrp, sig);
				ret = 1;
			}
			else if (tty->state & TS_HOLD) {
				keyrec->head = oldktail;
				ret = 1;
			}
		}

	}

/* has someone done select() on the keyboard?? */
	if (tty->rsel && keyrec->head != keyrec->tail)
		wakeselect(tty->rsel);

	return ret;
}


/*
 * special vector stuff: we try to save as many vectors as possible,
 * just in case we need to restore them later
 *
 * BUG: this really should be integrated with the init_intr routine
 * in main.c
 */

#define A(x) ((long *)(long)(x))
#define L(x) (long)(x)

struct vectab {
	long *addr;
	long def_value;
} VEC[] = {
{A(0x28), 0},	/* Line A */
{A(0x2c), 0},	/* Line F */
{A(0x60), 0},	/* spurious interrupt */
{A(0x64), 0},  	/* level 1 interrupt */
{A(0x68), 0},	/* level 2 interrupt */
{A(0x6c), 0},	/* level 3 interrupt */
{A(0x70), 0},	/* level 4 interrupt */
{A(0x74), 0},	/* level 5 interrupt */
{A(0x78), 0},	/* level 6 interrupt */
{A(0x7c), 0},	/* level 7 interrupt */
{A(0x100), 0},	/* various MFP interrupts */
{A(0x104), 0},
{A(0x108), 0},
{A(0x10c), 0},
{A(0x110), 0},
{A(0x114), 0},
{A(0x118), 0},
{A(0x11c), 0},
{A(0x120), 0},
{A(0x124), 0},
{A(0x128), 0},
{A(0x12c), 0},
{A(0x130), 0},
{A(0x134), 0},
{A(0x138), 0},
{A(0x13c), 0},
{A(0x400), 0},	/* etv_timer */
{A(0x4f6), 0},  /* shell_p */

{A(0), 0}	/* special tag indicating end of list */
};

void
init_vectors() 
{
	struct vectab *v;

	for (v = VEC; v->addr; v++) {
		v->def_value = *(v->addr);
	} 
}

#if 0	/* bad code */

/* unhook a vector; if possible, do this with XBRA, but
 * if that isn't possible force the vector to have the
 * same value it had when MiNT started
 */

static void
unhook(v, where)
	struct vectab *v;
	long where;
{
	xbra_vec *xbra;
	long newval;
	int cookie;

/* to check for XBRA, we need access to the memory where the
 * vector is
 */
	cookie = prot_temp(where - 12, 16L, -1);

	if (cookie == 0)
		newval = v->def_value;
	else {
		xbra = (xbra_vec *)(where - 12);
		if (xbra->xbra_magic == XBRA_MAGIC) {
			newval = (long)xbra->next;
		} else {
			newval = v->def_value;
		}
	}
	*(v->addr) = newval;

	(void)prot_temp(where - 12, 16L, cookie);
}
#endif

/*
 * unlink_vectors(start, end): any of the "normal" system vectors
 * pointing into a freed memory region must be reset to their
 * default values, or else we'll get a memory protection violation
 * next time the vector gets called
 */

void
unlink_vectors(start, end)
	long start, end;
{
#if 0	/* this code is hosed somewhere */

	struct vectab *v;
	long where, *p;
	int i;

/* first, unhook any VBL handlers */
	i = *((short *)0x454L);	/* i = nvbls */
	p = *((long **)0x456L);	/* p = _vblqueue */
	while (i-- > 0) {
		where = *p;
		if (where >= start && where < end)
			*p = 0;
		p++;
	}

/* next, unhook various random vectors */
	for (v = VEC; v->addr; v++) {
		where = *(v->addr);
		if (where >= start && where < end) {
			unhook(v, where);
		}
	}
#else
	UNUSED(start); UNUSED(end);
#endif
}

