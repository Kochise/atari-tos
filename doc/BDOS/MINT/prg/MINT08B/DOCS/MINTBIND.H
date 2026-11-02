#ifndef _MINTBIND_H
#define _MINTBIND_H

#ifndef _OSBIND_H
#include <osbind.h>
#endif

#ifdef __GNUC__
#define trap_1_wwlw(n, a, b, c)						\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	short  _c = (short) (c);					\
	    								\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		addw    #10,sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})

#define trap_1_wwl(n, a, b)						\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		addw    #8,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)		/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})

#else

#define trap_1_w(n)		gemdos(n)
#define trap_1_wl(n,a)		gemdos(n, (long)(a))
#define trap_1_ww(n,a)		gemdos(n, a)
#define trap_1_www(n,a,b)	gemdos(n, a, b)
#define trap_1_wwlw(n,a,b,c)	gemdos(n, a, (long)b, c)
#define trap_1_wwl(n, a, b)	gemdos(n, a, (long)b)
#define trap_13_w(n)		bios(n)
#define trap_14_w(n)		xbios(n)

#endif

#define	Syield()						\
		trap_1_w(0xff)
#define Fpipe(ptr)						\
		trap_1_wl(0x100, (long)(ptr))
#define Fcntl(f, arg, cmd)					\
		trap_1_wwlw(0x104, (short)(f), (long)(arg), (short)(cmd))
#define Finstat(f)						\
		trap_1_ww(0x105, (short)(f))
#define Foutstat(f)						\
		trap_1_ww(0x106, (short)(f))
#define Fgetchar(f, mode)					\
		trap_1_www(0x107, (short)(f), (short)(mode))
#define Fputchar(f, ch, mode)					\
		trap_1_wwlw(0x108, (short)(f), (long)(ch), (short)(mode))

#define Pwait()							\
		trap_1_w(0x109)
#define Snice(delta)						\
		trap_1_ww(0x10a, (short)(delta))
#define Pgetpid()						\
		trap_1_w(0x10b)
#define Pgetppid()						\
		trap_1_w(0x10c)
#define Pgetpgrp()						\
		trap_1_w(0x10d)
#define Psetpgrp(pid, grp)					\
		trap_1_www(0x10e, (short)(pid), (short)(grp))
#define Pgetuid()						\
		trap_1_w(0x10f)
#define Psetuid(id)						\
		trap_1_ww(0x110, (short)(id))
#define Pkill(pid, sig)						\
		trap_1_www(0x111, (short)(pid), (short)(sig))
#define Psignal(sig, handler)					\
		trap_1_wwl(0x112, (short)(sig), (long)(handler))
#define Pvfork()						\
		trap_1_w(0x113)
#define Pgetgid()						\
		trap_1_w(0x114)
#define Psetgid(id)						\
		trap_1_ww(0x115, (short)(id))
#define Psigblock(mask)						\
		trap_1_wl(0x116, (unsigned long)(mask))
#define Psigsetmask(mask)					\
		trap_1_wl(0x117, (unsigned long)(mask))
#define Pusrval(arg)						\
		trap_1_wl(0x118, (long)(arg))
#define Pdomain(arg)						\
		trap_1_ww(0x119, (short)(arg))
#define Psigreturn()						\
		trap_1_w(0x11a)
#define Pfork()							\
		trap_1_w(0x11b)
#define Pwait3(flag, rusage)					\
		trap_1_wwl(0x11c, (short)(flag), (long)(rusage))
#define Fselect(time, rfd, wfd, xfd)				\
		trap_1_wwlll(0x11d, (unsigned short)(time), (long)(rfd), \
				(long)(wfd), (long)(xfd))
#define Prusage(rsp)						\
		trap_1_wl(0x11e, (long)(rsp))
#define Psetlimit(i, val)					\
		trap_1_wwl(0x11f, (short)(i), (long)(val))

#define Talarm(sec)						\
		trap_1_wl(0x120, (long)(sec))
#define Pause()							\
		trap_1_w(0x121);
#define Sysconf(n)						\
		trap_1_ww(0x122, (short)(n))
#define Psigpending()						\
		trap_1_w(0x123)
#define Dpathconf(name, which)					\
		trap_1_wlw(0x124, (long)(name), (short)(which))

#define Dos_tab()						\
		trap_1_w(-1)
#define Bios_tab()						\
		trap_13_w(-1)
#define Xbios_tab()						\
		trap_14_w(-1)

#endif /* _MINTBIND_H */
