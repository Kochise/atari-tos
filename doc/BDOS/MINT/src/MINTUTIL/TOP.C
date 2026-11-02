/*

  ps.c: a program to print MiNT process statuses

  
  Coded: 3/24/1991 by Tony Reynolds, cctony@sgisci1.ocis.olemiss.edu
  For use with: MiNT release 0.7
  Updated: 3/29/1991 by Eric Smith for MiNT version 0.8

  Updated and completely revised from 'ps' into 'top' by AKP 8/91.
  Link with -lcurses and -ltermcap.  Beware!  Bammi's GNU curses
  makefile actually links the termcap object files into curses.olb,
  so changing them and recompiling only termcap.olb will have no effect!

  Updated some more 11/91 by Allan Pratt for MiNT version 0.9
*/

#include <stdio.h>
#include <stdlib.h>
#include <osbind.h>
#include <errno.h>
#include <basepage.h>
#include <ioctl.h>
#include <time.h>
#include <curses.h>
#include <signal.h>
#include <mintbind.h>
#include <ctype.h>
#include <string.h>
#include <unistd.h>

#ifndef PCTXTSIZE
#define PCTXTSIZE (('P'<<8)|3)
#endif

#define MINWIDTH 36	/* this is the width of everything before the command */
#define DEF_PTABSIZ 99	/* this is how many process' worth of table to have */

struct status {	    /* defines values for internal->external process states */
  int mint;	    /* what MiNT knows */
  char desc[6];	    /* a textual description for above */
} proc_stat[] = {
  0,    "Run  ",	/* really "run" but "top" is always running! */
  0x01, "Run  ",
  0x20, "Wait ",
  0x21, "Sleep",
  0x22, "Exit ",
  0x02, "TSR  ",
  0x24, "Stop ",
  -1,	"?????"
};

typedef struct _context {
	long	regs[15];	/* registers d0-d7, a0-a6 */
	long	usp;		/* user stack pointer (a7) */
	short	sr;		/* status register */
	long	pc;		/* program counter */
	long	ssp;		/* supervisor stack pointer */
	long	term_vec;	/* GEMDOS terminate vector (0x102) */

/* these fields were added in MiNT 0.9 -- ERS */
	char	fstate[216];	/* FPU internal state */
	char	fregs[12*8];	/* registers fp0-fp7 */
	long	fctrl[3];		/* FPCR/FPSR/FPIAR */
	short	sfmt;			/* stack frame format identifier */
	long	iar;			/* instruction address */
	short	internal[4];	/* four words of internal info */
} CONTEXT;

struct pinfo {
	long	magic;
	char	*base;
	short	pid, ppid, pgrp;
	short	ruid, rgid;
	short	euid, egid;
	short	flags;
	short	pri;
	short	wait_q;
	long	wait_cond;
	unsigned long systime, usrtime, chldstime, chldutime;
	unsigned long maxmem, maxdata, maxcore, maxcpu;
	short	domain;
	short	curpri;
};

/* open the process named "name" */
int
open_proc(name)
char *name;
{
  static char pname[32] = "u:\\proc\\";

  strcpy(pname+8, name);
  return open(pname, 0);
}

struct ptab {
    short pid;
    short used;
    long lasttime;
    char line[2];	/* make sure sizeof(struct ptab) is even */
} *ptab;		/* an array of these gets malloc'ed */

#define INCPTAB(p) ((struct ptab *)(((char *)p) + sizeof(struct ptab) + width))

int garbage = 0;	/* when set, screen needs total update */

void
quit(sig)
long sig;
{
    /* move to bottom of screen */
    mvcur(0, COLS - 1, LINES - 1, 0);
    endwin();
    exit(0);
}

void
usage()
{
    puts("Usage: top [-s sleeptime] [-w width] [-n nlines] [-r]");
    puts("-r sorts procs in decreasing PID order; usually increasing PID.");
    puts("TOP ONLY RUNS UNDER MiNT.  Use '?' to get help.");
    exit(1);
}

void
dokill(s)
char *s;
{
    int signum = SIGTERM;
    int pid;
    char *p;
    char hold;

    while (isspace(*s)) s++;
    if (*s == '-') {
	p = ++s;
	while (*p && !isspace(*p)) p++;
	hold = *p;
	*p = '\0';
	if (p != s) signum = atoi(s);
	*p = hold;
	if (!signum) signum = SIGTERM;
	s = p;
    }
    while (isspace(*s)) s++;

    while (*s) {
	p = s;
	while (*p && !isspace(*p)) p++;
	hold = *p;
	*p = '\0';
	pid = atoi(s);
	*p = hold;
	s = p;
	if (pid) (void)Pkill(pid,signum);
	while (isspace(*s)) s++;
    }
}

void
dorenice(s)
char *s;
{
    int niceval;
    int pid;
    char *p;
    char hold;

    while (isspace(*s)) s++;
    p = s;
    while (*p && !isspace(*p)) p++;
    hold = *p;
    *p = '\0';
    niceval = atoi(s);
    *p = hold;
    s = p;

    while (isspace(*s)) s++;

    while (*s) {
	p = s;
	while (*p && !isspace(*p)) p++;
	hold = *p;
	*p = '\0';
	pid = atoi(s);
	*p = hold;
	s = p;
	if (pid) (void)Prenice(pid,niceval);
	while (isspace(*s)) s++;
    }
}

int
cmp_incr_pid(void *p1, void *p2)
{
    struct ptab *pt1 = p1, *pt2 = p2;
    int pid1 = pt1->pid, pid2 = pt2->pid;
    if (pid1 == -1 && pid2 == -1) return 0;
    if (pid1 == -1) return 1;	/* send invalid procs to bottom */
    if (pid2 == -1) return -1;
    return pid1 - pid2;
}

int
cmp_decr_pid(void *p1, void *p2)
{
    struct ptab *pt1 = p1, *pt2 = p2;
    int pid1 = pt1->pid, pid2 = pt2->pid;
    if (pid1 == -1 && pid2 == -1) return 0;
    if (pid1 == -1) return 1;	/* send invalid procs to bottom */
    if (pid2 == -1) return -1;
    return pid2 - pid1;
}

char helpstr[] = 
  "    s[leeptime] w[idth] n[lines] k[ill] r[enice] h[elp] p[riority] q[uit]\r";

void
main(argc, argv)
int argc;
char **argv;
{
    int repeat_time = 0;
    _DTA mydta;
    int fd;
    int fserror=0;
    long place, procaddr;
    int pid, ppid;
    char *cmdline;
    struct status *statp;
    char bpage[sizeof(BASEPAGE)];
    struct pinfo proc;
    int thispid;
    struct ptab *pt;
    char *c;
    unsigned long ptime, hour, min, sec, frac;
    long realtime;
    long lastclock = clock();
    long thisclock;
    int i;
    long deltime;
    long ctxtsize;
    int nprocs, nrunning;
    long cummemory, idletime;
    int width = 0;
    long readfds;
    char ibuf[80];
    int ichar;
    int taillen, cmdlen;
    int tailstart;
    int nlines = 0;
    int helpline = 0;
    int ptabsiz = DEF_PTABSIZ;
    int len;
    int (*cmpfunc)();
    extern int __mint;
    int ppid_mode = 1;

    cmpfunc = cmp_incr_pid;

    if (!__mint) usage();
    --argc, ++argv;
    while (argc) {
	if (**argv != '-') usage();
	switch(argv[0][1]) {
	    case 'r': cmpfunc = cmp_decr_pid;
		      break;
	    case 's': if (argc == 0) usage();
		      if ((repeat_time = atoi(argv[1])) == 0) usage();
		      ++argv, --argc;
		      break;
	    case 'w': if (argc == 0) usage();
		      if ((width = atoi(argv[1])) <= 0) usage();
		      if (width < MINWIDTH) width = MINWIDTH;
		      ++argv, --argc;
		      break;
	    case 'n': if (argc == 0) usage();
		      if ((nlines = atoi(argv[1])) <= 0) usage();
		      ++argv, --argc;
		      break;

	    default: usage();
	}
	--argc, ++argv;
    }

    Fsetdta(&mydta);          /* give the OS my new DTA */

    initscr();

    if (!width) width = COLS-1;	/* default if it's unset */
    width &= ~1;		/* make sure width is even, too */

    if (!repeat_time) repeat_time = 5;
    if (LINES < 4) {
	puts("top: can't run on a screen with < 4 lines");
	exit(1);
    }
    if (nlines == 0 || nlines > (LINES-3)) nlines = LINES-3;

    /* struct ptab ends with char line[2] so there's already padding for '\0' */
    if ((ptab = malloc((sizeof(struct ptab) + width) * ptabsiz)) == NULL) {
	puts("top: can't get memory for process structures");
	exit(1);
    }

    cbreak();
    noecho();

    signal(SIGINT,quit);
    signal(SIGQUIT,quit);
    signal(SIGHUP,quit);
    signal(SIGTERM,quit);

    for (i = ptabsiz, pt = ptab; i; i--, pt = INCPTAB(pt)) {
	pt->pid = -1;
	pt->used = 0;
    }

    while (1) {
	fserror=Fsfirst("u:\\proc\\*.*", -1);
	if (fserror < 0) {
	    fprintf(stderr, "top: cannot list processes ?!");
	    exit(1);
	}

	erase();

	/* top line is printed later */

	if (ppid_mode) {
	    printw("\n\nPID PPID STATUS   SIZE   TIME     %% COMMAND\n");
	}
	else {
	    printw("\n\nPID PRI CUR STATUS   SIZE   TIME     %% COMMAND\n");
	}

	nprocs = 0;
	nrunning = 0;
	idletime = 0;
	cummemory = 0;

	thisclock = clock();
	realtime = (thisclock - lastclock) * (1000/CLOCKS_PER_SEC);
	lastclock = thisclock;

	/* okay, now run the Fsnext bit through the wringer */

	fserror = E_OK;       /* set up for the loop */

	while (fserror == E_OK ) {
	    fd = open_proc(mydta.dta_name);
	    if (fd < 0) goto getnext;

	    /* cut name off at '.' */
	    for (cmdline = mydta.dta_name;
		*cmdline && *cmdline != '.';
		cmdline++)
		    /* do nothing */ ;
	    *cmdline = 0;

	    ioctl(fd, PPROCADDR, &procaddr);
	    if (ioctl(fd, PCTXTSIZE, &ctxtsize) < 0)
		lseek(fd, procaddr+4+2*sizeof(CONTEXT), 0);
	    else
		lseek(fd, procaddr, 0);
	    read(fd, &proc, sizeof(proc));
	    pid = proc.pid;
	    ppid = proc.ppid;
	    ioctl(fd, PBASEADDR, &place);
	    lseek(fd, place, 0);
	    read(fd, bpage, sizeof(bpage));
	    close(fd);
	    cmdline = bpage+128;
	    if (*cmdline) *cmdline = ' ';

	    /* span cmdline turning control chars into question marks */
	    for (c = cmdline; *c; c++) if (*c < ' ') *c = '?';

	    taillen = c - cmdline;

	    thispid = proc.pid;
	    if (ppid < 0) ppid = 0;

	    statp = proc_stat;      /* hunt down string referring to
				    process status */
	    while (statp->mint != mydta.dta_attribute &&
		statp->mint >= 0) statp++;

	    ptime = proc.systime + proc.usrtime;

	    /* set deltime to the time used since last time we checked */
	    for (i = ptabsiz, pt = ptab; i; i--, pt = INCPTAB(pt)) {
		if (pt->pid == thispid) {
		    pt->used = 1;
		    deltime = ptime - pt->lasttime;
		    pt->lasttime = ptime;
		    goto found;
		}
	    }

	    /* fell out: didn't find the process */
	    for (i = ptabsiz, pt = ptab; i; i--, pt = INCPTAB(pt)) {
		if (pt->pid == -1) {
		    /* use this slot */
		    pt->used = 1;
		    pt->pid = thispid;
		    pt->lasttime = ptime;
		    deltime = (ptime > realtime ? realtime : ptime);
		    goto found;
		}
	    }
	    /* fell out again - can't keep track of this process (sorry!) */
	    deltime = 0;
	    pt = NULL;

found:

	    if (thispid == 0) {
		/* idle time is charged to process zero */
		idletime = deltime;
		strcpy(mydta.dta_name,"(idle)");
	    }

	    hour = (ptime/1000/60/60);
	    min = (ptime/1000/60)%60;
	    sec = (ptime/1000)%60;
	    frac = (ptime%1000) / 10;	/* (never anything in .001 digit) */

	    if (ppid_mode) {
		len = sprintf(pt->line,"%03d %03d %-5s %8ld ",
		    pid, ppid, statp->desc, mydta.dta_size);
	    }
	    else {
		len = sprintf(pt->line,"%03d %3d %3d %-5s %8ld ",
		    pid, proc.pri, proc.curpri, statp->desc, mydta.dta_size);
	    }

	    if (hour)
		len += sprintf(pt->line + len,"%2ld:%02ld:%02ld",hour,min,sec);
	    else
		len += sprintf(pt->line + len,"%2ld:%02ld.%02ld",min,sec,frac);

	    len += sprintf(pt->line + len," %3ld ",(deltime * 100) / realtime);

	    /* if the line's too long, cut off the tail so the total is width */
	    cmdlen = strlen(mydta.dta_name);
	    tailstart = len+cmdlen;
	    if (width < tailstart) cmdline[0] = 0;
	    else if (tailstart+taillen > width) {
		cmdline[width-tailstart] = '\0';
	    }
	    sprintf(pt->line + len,"%s%s",mydta.dta_name,cmdline);

	    nprocs++;

	    cummemory += mydta.dta_size;
	    if (deltime) nrunning++;

getnext:
	    fserror = Fsnext();
	}

	/*
	* Now zero out those slots which weren't used in the last pass, and zero
	* all "used" fields
	*/
	for (i = nlines, pt = ptab; i; i--, pt = INCPTAB(pt)) {
	    if (!pt->used) pt->pid = -1;
	    else pt->used = 0;
	}

	/*
	* Now all processes are in the ptab array, their lines stored. Sort them
	* into printing order and print nlines of them.
	*/

	qsort(ptab,nlines,sizeof(struct ptab) + width,cmpfunc);
	if (nprocs < nlines) i = nprocs;
	else i = nlines;
	for (pt = ptab; i; i--, pt = INCPTAB(pt)) {
	    printw("%s\n",pt->line);
	}

	/* compute idle percentage into idletime */
	idletime = (idletime * 100) / realtime;

	move(0,0);
	printw("Sample time: %5ld; %3ld%% idle; %3d processes, %3d running"
	    "; %ld bytes used\n",
	    realtime,idletime,nprocs,nrunning,cummemory);

	if (helpline) printw(helpstr);

	if (garbage) wrefresh(curscr);
	else refresh();
	garbage = 0;

	/* Fall asleep for repeat_time seconds or until a key comes in. */
	/* We want zero to mean "no time" not "forever" so add one. */
	readfds = 1;
	if (Fselect(repeat_time * 1000 + 1,&readfds,0L,0L)) {
	    /* input waiting */
	    if (helpline) {
		clrtoeol();
		refresh();
		helpline = 0;
	    }
	    ichar = getch();
	    switch(ichar) {
		case 'L'-'@': 
		    garbage = 1;
		    break;
		case 's':
		    printw("sleep time: ");
		    refresh();
		    echo();
		    getstr(ibuf);
		    noecho();
		    if (*ibuf) repeat_time = atoi(ibuf);
		    if (repeat_time < 0) repeat_time = 0;
		    break;
		case 'w':
		    printw("width: ");
		    refresh();
		    echo();
		    getstr(ibuf);
		    noecho();
		    if (*ibuf) width = atoi(ibuf);
		    if (width < MINWIDTH) width = MINWIDTH;
		    width &= ~1;	/* make sure width is even */
		    break;
		case 'n':
		    printw("nlines: ");
		    refresh();
		    echo();
		    getstr(ibuf);
		    noecho();
		    if (*ibuf) nlines = atoi(ibuf);
		    if (nlines == 0 || nlines > (LINES-3)) nlines = (LINES-3);
		    break;
		case 'k':
		    printw("kill ");
		    refresh();
		    echo();
		    getstr(ibuf);
		    noecho();
		    if (*ibuf) dokill(ibuf);
		    break;
		case 'r':
		    printw("renice ");
		    refresh();
		    echo();
		    getstr(ibuf);
		    noecho();
		    if (*ibuf) dorenice(ibuf);
		    break;
		case 'p':
		    /* toggle ppid_mode */
		    ppid_mode ^= 1;
		    break;
		case 'h':
		case '?':
		    helpline = 1;
		    break;
		case 'q': quit();
		default: ;
	    }
	}
    }
}


