/*
	Copyright 1983
	Alcyon Corporation
	8716 Production Ave.
	San Diego, Ca. 92121
*/


#include "../common/linux/libcwrap.h"
#include "../include/compiler.h"
#include <stdio.h>
#include <stdlib.h>

#include <cout.h>
#include <sendc68.h>
#include "../include/option.h"
#include "util.h"

/**
 * this program reads a c.out format binary file and converts
 * it to the absolute ASCII load format acceptable by MACSBUG
 * and then sends it down the standard output file
**/

#define RBLEN	32						/* number of bytes per S1 record */
#define DELAY	012000
#define SDEFAULT 0x400
#define EDEFAULT 0x1000
#define USAGE "[-r] [-d delay] [-s start] [-e end] [-] objectfile [outputfile]"

static struct hdr2 couthd;
static const char *ifilname;

static char cksum;
static const char *ofn;

static long loctr;
static long delay;

static FILE *fout;
static FILE *ibuf;
static int noclear;
static int debug;

static int bcnt = RBLEN;

static long nlstart = SDEFAULT;

static long nlend = EDEFAULT;

static int regulus = 0;

static char calledby[] = "sendc68";
char version[] = "@(#) sendc68 - Sep 1, 1983";



static VOID dodelay(NOTHING)
{
	register long i;
	register long j;

	j = 0;
	for (i = 0; i != delay; i++)
		j++;
}


static VOID outhex(P(int) x)
PP(register int x;)
{
	if (x >= 10 && x <= 15)
		putc(x - 10 + 'A', fout);
	else
		putc(x + '0', fout);
}


static VOID hexby(P(int) c)
PP(register int c;)
{
	c &= 0xff;
	cksum += c;
	outhex((c >> 4) & 0x0f);
	outhex(c & 0x0f);
}


static VOID hexwd(P(int) i)
PP(register int i;)
{
	hexby(i >> 8);
	hexby(i);
}


static VOID outword(P(int) i)
PP(register int i;)
{
	if (loctr >= nlstart && loctr < nlend)	/* MACSBUG RAM--dont load */
		return;

	if (bcnt == RBLEN)
	{									/* beginning of record */
		cksum = 0;
		if (loctr >= 0x10000L)
		{
			fprintf(fout, "S2");
			hexby((int) (RBLEN + 4));
			hexby((int) (loctr >> 16));
		} else
		{
			fprintf(fout, "S1");
			hexby((int) (RBLEN + 3));	/* byte count */
		}
		hexwd((int) loctr);
	}
	hexwd((int) i);
	bcnt -= 2;
	if (bcnt == 0)
	{
		hexby((int) (-cksum - 1));
		if (!regulus)
			putc('\r', fout);			/* carriage return */
		putc('\n', fout);
		bcnt = RBLEN;
		fflush(fout);
		dodelay();						/* give 68000 time to load */
	}
}



#define BADMAGIC(magic) (magic<EX_MAGIC || magic>EX_4KSTXT)
static VOID readhdr(NOTHING)
{
	if (getchd(ibuf, &couthd) == -1)
	{
		fprintf(stderr, "read error on: %s\n", ifilname);
		exit(EXIT_FAILURE);
	}
	if (debug)
	{
		fprintf(stderr, "magic = %x\n", couthd.ch_magic);
		fprintf(stderr, "tsize = %ld\n", (long)couthd.ch_tsize);
		fprintf(stderr, "dsize = %ld\n", (long)couthd.ch_dsize);
		fprintf(stderr, "bsize = %ld\n", (long)couthd.ch_bsize);
		fprintf(stderr, "ssize = %ld\n", (long)couthd.ch_ssize);
		fprintf(stderr, "stksize = %ld\n", (long)couthd.ch_stksize);
		fprintf(stderr, "entry = %ld\n", (long)couthd.ch_entry);
		if (couthd.ch_magic == EX_ABMAGIC)
		{
			fprintf(stderr, "dstart = %ld\n", (long)couthd.ch_dstart);
			fprintf(stderr, "bstart = %ld\n", (long)couthd.ch_bstart);
		}
	}
	if (BADMAGIC(couthd.ch_magic))
	{
		fprintf(stderr, "file format error: %s %x\n", ifilname, couthd.ch_magic);
		exit(EXIT_FAILURE);
	}
}


static VOID openfile(P(char *) ap)
PP(char *ap;)
{
	register char *p;

	if (debug)
		fprintf(stderr, "%s input file : [%s]\n", calledby, ap);
	p = ap;
	if ((ibuf = fopen(p, "rb")) == NULL)
	{
		fprintf(stderr, "%s: unable to open %s\n", calledby, p);
		exit(EXIT_FAILURE);
	}
	ifilname = p;						/* point to current file name for error msgs */
	readhdr();							/* read file header */
}


static VOID usage(NOTHING)
{
	fprintf(stderr, "Usage: %s: %s\n", calledby, USAGE);
}


int main(P(int) argc, P(char **) argv)
PP(int argc;)
PP(char **argv;)
{
	register long l;
	register long l1;
	unsigned short word;

#ifdef __ALCYON__
	/* symbols etoa and ftoa are unresolved */
	asm("xdef _etoa");
	asm("_etoa equ 0");
	asm("xdef _ftoa");
	asm("_ftoa equ 0");
#endif

	argv++;
	if (argc-- < 2)
	{
		usage();
		return EXIT_FAILURE;
	}
	while (**argv == '-')
	{
		switch (*++*argv)
		{
		case '\0':						/* '-' only */
			noclear = 1;
			break;
		case 'r':						/* don't put out cr-lf only lf */
			regulus = 1;
			break;
		case 'd':
			argv++;
			argc--;
			if ((delay = atol(*argv)) <= 0)
				delay = DELAY;
			break;
		case 's':
			argv++;
			argc--;
			if ((nlstart = atol(*argv)) < 0)
				nlstart = SDEFAULT;
			break;
		case 'e':
			argv++;
			argc--;
			if ((nlend = atol(*argv)) < 0)
				nlend = EDEFAULT;
			break;
		case 'D':
			debug = 1;
			break;
		default:
			usage();
			return EXIT_FAILURE;
		}
		argc--;
		argv++;
	}

	if (!argc)
	{
		usage();
		return EXIT_FAILURE;
	}
	openfile(*argv++);
	if (--argc > 0)
	{
		ofn = *argv;					/* tty device name */
		if ((fout = fopen(ofn, "w")) == NULL)
		{
			fprintf(stderr, "%s: unable to create [%s]\n", calledby, ofn);
			return EXIT_FAILURE;
		}
	} else
	{
		fout = stdout;					/* standard output file */
	}

	l1 = couthd.ch_tsize;
	loctr = couthd.ch_entry;

	/* Main Loop */
	for (l = 0; l < l1; l += 2)
	{
		lgetw(&word, ibuf);
		outword(word);
		loctr += 2;
	}
	if (couthd.ch_magic == EX_ABMAGIC)
	{
		while (bcnt != RBLEN)			/* fill out the last S1 buffer */
			outword(0);
		loctr = couthd.ch_dstart;
	}
	l1 = couthd.ch_dsize;
	for (l = 0; l < l1; l += 2)
	{
		lgetw(&word, ibuf);
		outword(word);
		loctr += 2;
	}
	if (noclear == 0)
	{
		if (couthd.ch_magic == EX_ABMAGIC)
		{
			while (bcnt != RBLEN)		/* fill out the last S1 buffer */
				outword(0);
			loctr = couthd.ch_bstart;
		}
		l1 = couthd.ch_bsize;			/* size of bss */
		while (l1 > 0)
		{
			outword(0);					/* clear the bss */
			l1 -= 2;
			loctr += 2;
		}
	}
	while (bcnt != RBLEN)				/* fill out the last S1 buffer */
		outword(0);
	fprintf(fout, "S9030000FC");
	if (!regulus)
		putc('\r', fout);					/* carriage return */
	putc('\n', fout);
	fflush(fout);
	return EXIT_SUCCESS;
}
