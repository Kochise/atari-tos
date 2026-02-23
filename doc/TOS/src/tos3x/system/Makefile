top_srcdir=..
subdir=system
include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil

cache100_ASFLAGS = -n
cache100_old_ASFLAGS = -n
foldr100_ASFLAGS = -n

LIBS = ${LIBC}

PROGRAMS = cache100.prg foldr100.prg vdi_fix.prg

all:: $(PROGRAMS)

include SRCFILES

cache100.prg: $(CACHE100_OBJS) ${MAKEFILE}
	$(AM_V_LD)$(LINK68) $(LDFLAGS) $*.68k=${CACHE100_OBJS}
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

foldr100.prg: $(FOLDR100_OBJS) ${MAKEFILE}
	$(AM_V_LD)$(LINK68) ${LDFLAGS} $*.68k=${FOLDR100_OBJS}
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

cacheold.prg: $(CACHE100_OLD_OBJS) ${MAKEFILE}
	$(AM_V_LD)$(LINK68) ${LDFLAGS} '[prgflags[1]]' $*.68k=${CACHE100_OLD_OBJS}
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

vdi_fix.prg: $(VDI_FIX_OBJS) ${MAKEFILE}
	$(AM_V_LD)$(LINK68) ${LDFLAGS} $*.68k=${VDI_FIX_OBJS}
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

vdi_fix.o: vdifix11/vdi_fix.S
	$(AM_V_AS)${CPP} $< $(CPPOUT) $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i
	$(AM_V_at)${RM} $*.i

check::

clean::
	$(RM) *.o *.a *.i *.1 *.2 *.rel *.mod *.68k $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
