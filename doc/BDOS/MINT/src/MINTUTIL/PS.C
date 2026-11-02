/*

  ps.c: a program to print MiNT process statuses

  
  Coded: 3/24/1991 by Tony Reynolds, cctony@sgisci1.ocis.olemiss.edu
  For use with: MiNT release 0.7
  Updated: 3/29/1991 by Eric Smith for MiNT version 0.8
  Updated again 8/9/1991 by ERS for MiNT 0.9.
  Updated some more 11/91 by AKP (shows process time in fractions of a sec).
*/

#include <stdio.h>
#include <osbind.h>
#include <errno.h>
#include <basepage.h>
#include <ioctl.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#ifndef PCTXTSIZE
#define PCTXTSIZE (('P'<<8) | 3)
#endif

#define ulong unsigned long

struct status {   /* defines values for internal->external process states */
  int mint;       /* what MiNT knows */
  char desc[10];  /* a textual description for above */
} proc_stat[] = {
  0,    "Ready",
  0x01, "Ready",
  0x20, "Wait ",
  0x21, "Sleep",
  0x22, "Exit ",
  0x02, "TSR  ",
  0x24, "Stop ",
  -1,	"Unkn "
 };   /* initialized from data in procfs.c */

extern int __mint;

typedef struct _context {
	long	regs[15];	/* registers d0-d7, a0-a6 */
	long	usp;		/* user stack pointer (a7) */
	short	sr;		/* status register */
	long	pc;		/* program counter */
	long	ssp;		/* supervisor stack pointer */
	long	term_vec;	/* GEMDOS terminate vector (0x102) */

/* these fields were added in MiNT 0.9 */
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
	short	memflags;
	short	pri;
	short	wait_q;
	long	wait_cond;
	/* (all times are in milliseconds) */
	ulong	systime;		/* time spent in kernel		*/
	ulong	usrtime;		/* time spent out of kernel	*/
	ulong	chldstime;		/* children's kernel time 	*/
	ulong	chldutime;		/* children's user time		*/

	ulong	maxmem;			/* max. amount of memory to use */
	ulong	maxdata;		/* max. data region for process */
	ulong	maxcore;		/* max. core memory for process */
	ulong	maxcpu;			/* max. cpu time to use 	*/

	short	domain;			/* process domain (TOS or MiNT)	*/
	short	curpri;			/* current priority (nice)	*/
};

/* open the process named "name" */
int
open_proc(name)
  char *name;
{
  static char pname[] = "u:\\proc\\xxxxxxxx.xxx";

  strcpy(pname+8, name);
  return open(pname, 0);
}

void
main(argc, argv)
  int argc;
  char **argv;
{

  _DTA mydta;
  int fd;
  int fserror=0;
  long place;
  short pid, ppid, pri, curpri;
  char *cmdline;
  struct status *statp;
  long ctxtsize;
  BASEPAGE bpage;		/* process basepage read in here if possible */
  struct pinfo proc;		/* process info read in here */
  long ptime;
  long hour, min, sec, frac;

  Fsetdta(&mydta);          /* give the OS my new DTA */

  fserror=Fsfirst("u:\\proc\\*.*", 0x27);
  if (fserror < 0) {
    fprintf(stderr, "ps: cannot list processes, MiNT may not be running\n");
    exit(1);
  }

  printf("PID  PPID PRI CURPRI STATUS   SIZE    TIME    COMMAND\n");

  /* okay, now run the Fsnext bit through the wringer */

  fserror = E_OK;       /* set up for the loop */

  while (fserror == E_OK ) {
    fd = open_proc(mydta.dta_name);

    for (cmdline = mydta.dta_name; *cmdline && *cmdline != '.'; cmdline++) ;
    *cmdline = 0;

    if (fd < 0) goto next;

    ioctl(fd, PPROCADDR, &place);
    if (ioctl(fd, PCTXTSIZE, &ctxtsize) < 0) {
	lseek(fd, place+4+2*sizeof(CONTEXT), 0);
    } else
	    lseek(fd, place, 0);
    read(fd, &proc, sizeof(proc));
    if ((pid = proc.pid) < 0) pid = 0;
    if ((ppid = proc.ppid) < 0) ppid = 0;
    pri = proc.pri;
    curpri = proc.curpri;
    ptime = proc.systime + proc.usrtime;
    hour = (ptime/1000/60/60);
    min = (ptime/1000/60)%60;
    sec = (ptime/1000)%60;
    frac = (ptime%1000) / 10;	/* (never anything in .001 digit) */

    ioctl(fd, PBASEADDR, &place);
    lseek(fd, place, 0);
    read(fd, &bpage, sizeof(bpage));
    cmdline = bpage.p_cmdlin;
    if (*cmdline) *cmdline = ' ';
    close(fd);

    statp = proc_stat;      /* hunt down string referring to
			       process status */
    while (statp->mint != mydta.dta_attribute &&
	   statp->mint >= 0) statp++;

/*		PID  PPID PRI CURPRI STATUS   SIZE     TIME   COMMAND */
    if (hour) {
	printf("%03d  %03d %3d   %3d  %s  %8ld %02ld:%02ld:%02ld  %s%s\n",
	    pid, ppid, pri, curpri, statp->desc,
	    mydta.dta_size,
	    hour,
	    min,
	    sec,
	    mydta.dta_name,
	    cmdline);
    }
    else {
	printf("%03d  %03d %3d   %3d  %s  %8ld %02ld:%02ld.%02ld  %s%s\n",
	    pid, ppid, pri, curpri, statp->desc,
	    mydta.dta_size,
	    min,
	    sec,
	    frac,
	    mydta.dta_name,
	    cmdline);
    }
next:
    fserror = Fsnext();
  }
  exit(0);
}
