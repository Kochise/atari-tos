/*
Copyright 1990,1991,1992 Eric R. Smith.
Copyright 1992 Atari Corporation.
All rights reserved.
*/

/*
 * read/write routines for TTY devices
 */

#include "mint.h"

static void _erase P_((FILEPTR *, int));
static int escseq P_((struct tty *, int));

/* setting a special character to this value disables it */
#define UNDEF 0


/* default terminal characteristics */

struct tty default_tty = {
	0,			/* process group */
	0,			/* state */
	0,			/* use_cnt */
	0,			/* reserved short */
	{
	13, 13,			/* input speed == output speed == 9600 baud */
	CTRL('H'),		/* erase */
	CTRL('U'),		/* kill */
	T_ECHO|T_CRMOD|T_TOSTOP|T_XKEY, /* flags */
	},
	{
	CTRL('C'),		/* interrupt */
	CTRL('\\'),		/* quit */
	CTRL('Q'),		/* start */
	CTRL('S'),		/* stop */
	CTRL('D'),		/* EOF */
	'\r'			/* alternate end of line */
	},
	{
	CTRL('Z'),		/* suspend */
	CTRL('Y'),		/* suspend after read */
	CTRL('R'),		/* reprint */
	UNDEF,			/* flush output */
	CTRL('W'),		/* erase word */
	CTRL('V')		/* quote next char */
	},
	{
	0, 0, 0, 0		/* window size is unknown */
	},
	0,			/* no process is selecting us for reading */
	0,			/* or for writing */
	0			/* use default XKEY map */
};

#define _put(f, c) (tty_putchar((f), (c), RAW))

static void
_erase(f, c)
	FILEPTR *f;
	int c;
{
	_put(f, '\010');
	_put(f, ' ');
	_put(f, '\010');
/* watch out for control characters -- they're printed as e.g. "^C" */
/* BUG: \t is messed up. We really need to keep track of the output
 * column
 */
	if (c >= 0 && c < ' ' && c != '\t') {
		_put(f, '\010'); _put(f, ' '); _put(f, '\010');
	}
}

#define put(f, c)   { if (mode & T_ECHO) _put(f, c); }
#define erase(f, c) { if (mode & T_ECHO) _erase(f, c); }

long
tty_read(f, buf, nbytes)
	FILEPTR *f;
	void *buf;
	long nbytes;
{
	long r;
	long bytes_read = 0;
	unsigned char ch, *ptr;
	int rdmode, mode;
	struct tty *tty;

	tty = (struct tty *)f->devinfo;
	assert(tty != 0);

	if (f->flags & O_HEAD) {	/* pty server side? */
		rdmode = RAW;		/* yes -- always raw mode */
		mode = T_RAW;
	}
	else if (curproc->domain == DOM_MINT) {	/* MiNT domain process? */
		mode = tty->sg.sg_flags;
		rdmode = COOKED|NOECHO;
		if ( mode & (T_RAW | T_CBREAK) ) {
			rdmode = (mode & T_RAW) ? RAW : COOKED;
		}
		if (mode & T_XKEY)
			rdmode |= ESCSEQ;
	}
	else {
		rdmode = COOKED|NOECHO;
		mode = T_TOS | T_ECHO;
	}

	ptr = buf;

	while (bytes_read < nbytes) {
		r = tty_getchar(f, rdmode);
		if (r < 0) {
tty_error:
			DEBUG(("tty_read: tty_getchar returned %ld", r));
			return (bytes_read) ? bytes_read : r;
		}
		else if (r == MiNTEOF)
			return bytes_read;
		ch = r & 0xff;

		if ( (mode & T_CRMOD) && (ch == '\r') )
			ch = '\n';

/* 1 character reads in TOS mode are always raw */
		if (nbytes == 1 && (mode & T_TOS)) {
			put(f, ch);
			*ptr = ch;
			return 1;
		}

/* T_CBREAK mode doesn't do erase or kill processing */
/* also note that setting a special character to UNDEF disables it */

		if (rdmode & COOKED && !(mode & T_CBREAK) && ch != UNDEF) {
			if ((char)ch == tty->sg.sg_erase) {  /* backspace */
				if (bytes_read > 0) {
					--ptr;
					erase(f, *ptr);
					bytes_read--;
				}
				continue;
			}
			else if ((mode & T_TOS) && ch == CTRL('X')) {
				while (bytes_read > 0) {
					--ptr;
					erase(f, *ptr);
					bytes_read--;
				}
				continue;
			}
			else if ((char)ch ==tty->ltc.t_rprntc || 
				 (char)ch == tty->sg.sg_kill) {
				if (mode & T_TOS)
					put(f, '#');
				put(f, '\r');
				put(f, '\n');
				ptr = buf;
				if ((char)ch == tty->sg.sg_kill) {
					bytes_read = 0;
				}
				else {
					for (r = 0; r < bytes_read; r++, ptr++)
						put(f, *ptr);
				}
				continue;
			}
			else if ((char)ch == tty->ltc.t_werasc) {
				while (bytes_read > 0 &&
				       !(ptr[-1] == ' ' || ptr[-1] == '\t')) {
					ptr--;
					erase(f, *ptr);
					bytes_read--;
				}
				continue;
			}
			else if ((char)ch == tty->ltc.t_lnextc) {
				put(f, '^');
				put(f, '\b');
				r = tty_getchar(f, RAW);
				if (r < 0)
					goto tty_error;
				else if (r == MiNTEOF)
					return bytes_read;
				ch = r & 0xff;
				goto stuff_it;
			}
			else if ((char)ch == tty->tc.t_eofc && !(mode & T_TOS))
				return bytes_read;
		}

/* both T_CBREAK and T_COOKED modes have to do signals, though */
		if ((rdmode & COOKED) && ch != UNDEF) {
			if ((char)ch == tty->tc.t_intrc
				 || (char)ch == tty->tc.t_quitc
				 || (char)ch == tty->ltc.t_dsuspc
				 || (char)ch == tty->ltc.t_suspc
				) {
/* the device driver raised the appropriate signal; if we get here, the
   signal was caught by the user (or ignored). flush buffers and continue
 */
				if (!(tty->sg.sg_flags & T_NOFLSH)) {
					DEBUG(("tty_read: flushing input"));
					bytes_read = 0;
					ptr = buf;
				}
				continue;
			}
			else if (ch == '\n' || (char)ch == tty->tc.t_brkc) {
				put(f, '\r');
				if (!(mode & T_TOS)) {
					*ptr = ch;
					put(f, '\n');
					bytes_read++;
				}
				return bytes_read;
			}

		}

/* do the following for both RAW and COOKED mode */
stuff_it:
		*ptr++ = ch;
		if (ch < ' ' && ch != '\t') {	/* ch is unsigned */
			put(f, '^'); put(f, ch+'@');
		}
		else
			put(f, ch);
		bytes_read++;

/* for RAW mode, if there are no more characters then break */
		if ( (mode & (T_RAW|T_CBREAK)) &&
		    !((rdmode & ESCSEQ) && (tty->state & TS_ESC))) {
			r = 1;
			(void)(*f->dev->ioctl)(f, FIONREAD, &r);
			if (r <= 0) break;
		}	
	}

	return bytes_read;
}

long
tty_write(f, buf, nbytes)
	FILEPTR *f;
	const void *buf;
	long nbytes;
{
	unsigned const char *ptr;
	long c;
	long bytes_written;
	int mode, rwmode;
	struct tty *tty;
	int use_putchar = 0;
	static long cr_char = '\r';
#define LBUFSIZ 128
	long lbuf[LBUFSIZ];

	tty = (struct tty *)f->devinfo;
	assert(tty != 0);

	ptr = buf;
	if (f->flags & O_HEAD) {
		use_putchar = 1;
		mode = T_RAW;
	}
	else if (curproc->domain == DOM_TOS)
/* for TOS programs, 1 byte writes are always in raw mode */
		mode = (nbytes == 1) ? T_RAW : T_TOS;
	else
		mode = tty->sg.sg_flags;

	rwmode = (mode & T_RAW) ? RAW : COOKED;

	bytes_written = 0;

/*
 * "mode" can now be reduced to just T_CRMODE or not
 */
	if ((curproc->domain == DOM_MINT) && (mode & T_CRMOD) &&
	    !(mode & T_RAW))
		mode = T_CRMOD;
	else
		mode = 0;

/*
 * we always write at least 1 byte with tty_putchar, since that takes
 * care of job control and terminal states. After that, we may be able
 * to use (*f->dev->write) directly.
 */


	if (nbytes == 0) return bytes_written;
	c = *ptr++;

	if (c == '\n' && mode) {	/* remember, "mode" now means CRMOD */
		tty_putchar(f, cr_char, rwmode);
	}
	tty_putchar(f, c, rwmode);
	nbytes--;
	bytes_written++;

	if (use_putchar) {
		while (nbytes-- > 0) {
			c = *ptr++;
			if (c == '\n' && mode)
				tty_putchar(f, cr_char, rwmode);
			tty_putchar(f, c, rwmode);
			bytes_written++;
		}
	} else {
/* write in big chunks if possible; but never more than 1 line
 * (so that ^S/^Q can happen reasonably quickly for the user)
 */
		long bytes_to_write = 0;
		long *s = lbuf;

		while (nbytes-- > 0) {
			c = *ptr++;
			if (c == '\n') {
				if (bytes_to_write) {
					(*f->dev->write)(f, (char *)lbuf,
						bytes_to_write);
					bytes_to_write = 0;
					s = lbuf;
				}
				if (mode)	/* i.e. T_CRMODE */
					tty_putchar(f, cr_char, rwmode);
				tty_putchar(f, (long)c, rwmode);
				bytes_written++;
			} else {
				*s++ = c;
				bytes_written++;
				bytes_to_write += 4;
				if (bytes_to_write >= LBUFSIZ*4) {
					(*f->dev->write)(f, (char *)lbuf,
							 bytes_to_write);
					bytes_to_write = 0;
					s = lbuf;
				}
			}
		}
		if (bytes_to_write) {
			(*f->dev->write)(f, (char *)lbuf, bytes_to_write);
		}
	}

	return bytes_written;
}

/* some notable scan codes */
#define K_INSERT	0x52
#define K_HOME		0x47
#define K_UNDO		0x61
#define K_HELP		0x62
#define CURS_UP		0x48
#define CURS_DN		0x50
#define CURS_RT		0x4d
#define CURS_LF		0x4b
#define F_1		0x3b
#define F_10		0x44
#define F_11		0x54
#define F_20		0x5d
#define ALT_1		0x78
#define ALT_0		0x81

/* Default function key table:
 * entries:	0-9 are F1-F10
 *        	10-19 are F11-F20
 *		20-23 are cursor up, down, right, and left
 *		24-27 are help, undo, insert, and home
 *		28-31 are shift+cursor up, down, right, and left
 */

static char vt52xkey[256] = {
'\033', 'P', 0, 0, 0, 0, 0, 0,
'\033', 'Q', 0, 0, 0, 0, 0, 0,
'\033', 'R', 0, 0, 0, 0, 0, 0,
'\033', 'S', 0, 0, 0, 0, 0, 0,
'\033', 'T', 0, 0, 0, 0, 0, 0,
'\033', 'U', 0, 0, 0, 0, 0, 0,
'\033', 'V', 0, 0, 0, 0, 0, 0,
'\033', 'W', 0, 0, 0, 0, 0, 0,
'\033', 'X', 0, 0, 0, 0, 0, 0,
'\033', 'Y', 0, 0, 0, 0, 0, 0,
'\033', 'p', 0, 0, 0, 0, 0, 0,
'\033', 'q', 0, 0, 0, 0, 0, 0,
'\033', 'r', 0, 0, 0, 0, 0, 0,
'\033', 's', 0, 0, 0, 0, 0, 0,
'\033', 't', 0, 0, 0, 0, 0, 0,
'\033', 'u', 0, 0, 0, 0, 0, 0,
'\033', 'v', 0, 0, 0, 0, 0, 0,
'\033', 'w', 0, 0, 0, 0, 0, 0,
'\033', 'x', 0, 0, 0, 0, 0, 0,
'\033', 'y', 0, 0, 0, 0, 0, 0,
'\033', 'A', 0, 0, 0, 0, 0, 0,
'\033', 'B', 0, 0, 0, 0, 0, 0,
'\033', 'C', 0, 0, 0, 0, 0, 0,
'\033', 'D', 0, 0, 0, 0, 0, 0,
'\033', 'H', 0, 0, 0, 0, 0, 0,
'\033', 'K', 0, 0, 0, 0, 0, 0,
'\033', 'I', 0, 0, 0, 0, 0, 0,
'\033', 'E', 0, 0, 0, 0, 0, 0,
'\033', 'a', 0, 0, 0, 0, 0, 0,
'\033', 'b', 0, 0, 0, 0, 0, 0,
'\033', 'c', 0, 0, 0, 0, 0, 0,
'\033', 'd', 0, 0, 0, 0, 0, 0,
};

static char unxbaud P_((long));

/* convert a number describing the baud rate into a Unix
 * style baud rate number. Returns the Unix baud rate,
 * or 16 (EXTA) if the rate is unknown
 */

#define EXTA 16

static long ubaud[EXTA] = {
0L, 50L, 75L, 110L, 134L, 150L, 200L, 300L,
600L, 1200L, 1800L, 2400L, 4800L, 9600L, 19200L, 38400L
};

static char
unxbaud(baud)
	long baud;
{
	int i;
	for (i = 1; i < EXTA; i++) {
		if (ubaud[i] == baud)
			break;
	}
	return i;
}

#define tosbaud(c) ( ((c) < 0 || (c) >= EXTA) ? -1L : ubaud[(unsigned)c] )

long
tty_ioctl(f, mode, arg)
	FILEPTR *f;
	int mode;
	void *arg;
{
	struct sgttyb *sg;
	struct tchars *tc;
	struct ltchars *ltc;
	struct tty *tty;
	struct winsize *sz;
	struct xkey *xk;
	char *xktab;
	int i;
	long baud;
	short flags;

	if (!is_terminal(f)) {
		DEBUG(("tty_ioctl(mode %x): file is not a tty", mode));
		return EINVFN;
	}
	tty = (struct tty *)f->devinfo;
	assert(tty != 0);

	switch(mode) {
	case TIOCGETP:
		sg = (struct sgttyb *)arg;
	/* get input and output baud rates from the terminal device */
		baud = -1L;
		(*f->dev->ioctl)(f, TIOCIBAUD, &baud);
		tty->sg.sg_ispeed = unxbaud(baud);
		baud = -1L;
		(*f->dev->ioctl)(f, TIOCOBAUD, &baud);
		tty->sg.sg_ospeed = unxbaud(baud);
	/* get terminal flags */
		flags = 0;
		if ((*f->dev->ioctl)(f, TIOCGFLAGS, &flags) == 0) {
			tty->sg.sg_flags &= ~TF_FLAGS;
			tty->sg.sg_flags |= (flags & TF_FLAGS);
		}
		*sg = tty->sg;
		return 0;
	case TIOCSETP:
		sg = (struct sgttyb *)arg;
		tty->sg = *sg;
	/* set baud rates */
		baud = tosbaud(sg->sg_ispeed);
		(*f->dev->ioctl)(f, TIOCIBAUD, &baud);
		baud = tosbaud(sg->sg_ospeed);
		(*f->dev->ioctl)(f, TIOCOBAUD, &baud);
	/* set parity, etc. */
		flags = TF_8BIT;
		if (sg->sg_flags & (T_EVENP|T_ODDP)) {
			flags = TF_7BIT;
		}
		flags |= (sg->sg_flags & TF_FLAGS);
		(*f->dev->ioctl)(f, TIOCSFLAGS, &flags);
		return 0;
	case TIOCGETC:
		tc = (struct tchars *)arg;
		*tc = tty->tc;
		return 0;
	case TIOCSETC:
		tc = (struct tchars *)arg;
		tty->tc = *tc;
		return 0;
	case TIOCGLTC:
		ltc = (struct ltchars *)arg;
		*ltc = tty->ltc;
		return 0;
	case TIOCSLTC:
		ltc = (struct ltchars *)arg;
		tty->ltc = *ltc;
		return 0;
	case TIOCGWINSZ:
		sz = (struct winsize *)arg;
		*sz = tty->wsiz;
		return 0;
	case TIOCSWINSZ:
		sz = (struct winsize *)arg;
		tty->wsiz = *sz;
		return 0;
	case TIOCGPGRP:
		*((long *)arg) = tty->pgrp;
		return 0;
	case TIOCSPGRP:
		tty->pgrp = (*((long *)arg) & 0x00007fffL);
		return 0;
	case TIOCSTART:
		tty->state &= ~TS_HOLD;
		return 0;
	case TIOCSTOP:
		tty->state |= TS_HOLD;
		return 0;
	case TIOCGXKEY:
		xk = (struct xkey *)arg;
		i = xk->xk_num;
		if (i < 0 || i > 31) return ERANGE;
		xktab = tty->xkey;
		if (!xktab) xktab = vt52xkey;
		xktab += i*8;
		for (i = 0; i < 8; i++)
			xk->xk_def[i] = *xktab++;
		return 0;
	case TIOCSXKEY:
		xk = (struct xkey *)arg;
		xktab = tty->xkey;
		if (!xktab) {
			xktab = kmalloc((long)256);
			if (!xktab) return ENSMEM;
			for (i = 0; i < 256; i++)
				xktab[i] = vt52xkey[i];
			tty->xkey = xktab;
		}
		i = xk->xk_num;
		if (i < 0 || i > 31) return ERANGE;
		xktab += i*8;
		for (i = 0; i < 7; i++)
			xktab[i] = xk->xk_def[i];
		xktab[7] = 0;
		return 0;
	default:
		DEBUG(("tty_ioctl: bad function call"));
		return EINVFN;
	}
}

/*
 * function for translating extended characters (e.g. cursor keys, or
 * ALT+key sequences) into either escape sequences or meta characters.
 * for escape sequences, we return the the first character of the
 * sequence (normally ESC) and set the tty's state so that subsequent
 * calls to tty_getchar will pick up the remaining characters.
 * Note that escape sequences are limited to 7 characters at most.
 */

static int
escseq(tty, scan)
	struct tty *tty;
	int scan;
{
	char *tab;
	int i;

	switch(scan) {
	case CURS_UP: i = 20; break;
	case CURS_DN: i = 21; break;
	case CURS_RT: i = 22; break;
	case CURS_LF: i = 23; break;
	case K_HELP:  i = 24; break;
	case K_UNDO:  i = 25; break;
	case K_INSERT:i = 26; break;
	case K_HOME:  i = 27; break;
	case CURS_UP+0x100: i = 28; break;
	case CURS_DN+0x100: i = 29; break;
	case CURS_RT+0x100: i = 30; break;
	case CURS_LF+0x100: i = 31; break;
	default:
		if (scan >= F_1 && scan <= F_10) {
			i = scan - F_1;
		} else if (scan >= F_11 && scan <= F_20) {
			i = 10 + scan - F_11;
		} else
			i = -1;
	}

	if (i >= 0) {		/* an extended escape sequence */
		tab = tty->xkey;
		if (!tab) tab = vt52xkey;
		i *= 8;
		scan = tab[i++];
		if (scan) {
			if (tab[i] == 0) i = 0;
			tty->state = (tty->state & ~TS_ESC) | i;
		}
		return scan;
	}

	if (scan >= ALT_1 && scan <= ALT_0) {
		scan -= (ALT_1-1);
		if (scan == 10) scan = 0;
		return (scan + '0') | 0x80;
	}

	tab = *( ((char **)Keytbl((void *)-1UL, (void *)-1UL, (void *)-1UL)) + 2 );	/* gratuitous (void *) for Lattice */
	scan = tab[scan];
	if (scan >= 'A' && scan <= 'Z') return scan | 0x80;
	return 0;
}

long
tty_getchar(f, mode)
	FILEPTR *f;
	int mode;
{
	struct tty *tty = (struct tty *)f->devinfo;
	char c, *tab;
	long r, ret;
	int scan;
	int master = f->flags & O_HEAD;

	assert(tty);

/* pty masters never worry about job control and always read in raw mode */
	if (master) {
		ret = (*f->dev->read)(f, (char *)&r, 4L);
		return (ret != 4L) ? MiNTEOF : r;
	}

/* job control check */

	if (tty->pgrp && tty->pgrp != curproc->pgrp) {
		TRACE(("job control: tty pgrp is %d proc pgrp is %d",
			tty->pgrp, curproc->pgrp));
		killgroup(curproc->pgrp, SIGTTIN);
	}

	if (mode & COOKED)
		tty->state |= TS_COOKED;
	else
		tty->state &= ~TS_COOKED;

	c = UNDEF+1;	/* set to UNDEF when we successfully read a character */

/* we may be in the middle of an escape sequence */
	scan = (tty->state & TS_ESC);
	if (scan != 0) {
		if (mode & ESCSEQ) {
			tab = tty->xkey ? tty->xkey : vt52xkey;
			r = (unsigned char) tab[scan++];
			if (r) {
				c = UNDEF;
				if (tab[scan] == 0) scan = 0;
			}
			else
				scan = 0;
			tty->state = (tty->state & ~TS_ESC) | scan;
		}
		else
			tty->state &= ~TS_ESC;
	}

	while (c != UNDEF) {
		ret = (*f->dev->read)(f, (char *)&r, 4L);
		if (ret != 4L) {
			DEBUG(("EOF on tty device"));
			return MiNTEOF;
		}
		c = r & 0x00ff;
		scan = (int)((r & 0x00ff0000L) >> 16);
		if ( (c == 0) && (mode & ESCSEQ) && scan) {
			c = UNDEF;
	/* translate cursor keys, etc. into escape sequences or
	 * META characters
	 */
			r = escseq(tty, scan);
		} else if ((mode & ESCSEQ) && ((scan == CURS_UP && c == '8') ||
			   (scan == CURS_DN && c == '2') ||
			   (scan == CURS_RT && c == '6') ||
			   (scan == CURS_LF && c == '4'))) {
			c = UNDEF;
			r = escseq(tty, scan+0x100);
		} else if (mode & COOKED) {
			if (c == UNDEF)
				;	/* do nothing */
			else if (c == tty->ltc.t_dsuspc)
				killgroup(curproc->pgrp, SIGTSTP);
			else if (c == tty->tc.t_intrc)
				killgroup(curproc->pgrp, SIGINT);
			else if (c == tty->tc.t_stopc)
				tty->state |= TS_HOLD;
			else if (c == tty->tc.t_startc)
				tty->state &= ~TS_HOLD;
			else
				c = UNDEF;
		}
		else
				c = UNDEF;
	}

	if (mode & ECHO)
		tty_putchar(f, r, mode);

	return r;
}

/*
 * tty_putchar: returns number of bytes successfully written
 */

long
tty_putchar(f, data, mode)
	FILEPTR *f;
	long data;
	int mode;
{
	struct tty *tty;
	int master;		/* file is pty master side */
	char ch;

	tty = (struct tty *)f->devinfo;

	master = f->flags & O_HEAD;

/* pty masters don't need to worry about job control */
	if (master) {
		ch = data & 0xff;

		if ( (tty->state & TS_COOKED) && ch != UNDEF) {
/* see if we're putting control characters into the buffer */
			if (ch == tty->tc.t_intrc) {
				tty->state &= ~TS_HOLD;
				killgroup(tty->pgrp, SIGINT);
				return 4L;
			}
			else if (ch == tty->tc.t_quitc) {
				tty->state &= ~TS_HOLD;
				killgroup(tty->pgrp, SIGQUIT);
				return 4L;
			}
			else if (ch == tty->ltc.t_suspc) {
				tty->state &= ~TS_HOLD;
				killgroup(tty->pgrp, SIGTSTP);
				return 4L;
			}
			else if (ch == tty->tc.t_stopc) {
				tty->state |= TS_HOLD;
				return 4L;
			}
			else if (ch == tty->tc.t_startc) {
				tty->state &= ~TS_HOLD;
				return 4L;
			}
			else if (tty->state & TS_HOLD) {
				return 0;
			}
		}
		goto do_putchar;
	}
/* job control checks */
/* AKP: added T_TOSTOP; don't stop BG output if T_TOSTOP is clear */
	if (tty->pgrp && tty->pgrp != curproc->pgrp &&
	         (tty->sg.sg_flags & T_TOSTOP)) {
		TRACE(("job control: tty pgrp is %d proc pgrp is %d",
			tty->pgrp, curproc->pgrp));
		killgroup(curproc->pgrp, SIGTTOU);
	}

	if (mode & COOKED) {
		tty->state |= TS_COOKED;
		while (tty->state & TS_HOLD)
			nap(60);	/* sleep for 60 milliseconds */
	}
	else
		tty->state &= ~TS_COOKED;

do_putchar:
	return (*f->dev->write)(f, (char *)&data, 4L);
}
