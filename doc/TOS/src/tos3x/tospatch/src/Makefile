top_srcdir=../..
subdir=tospatch/src

include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil

PROGRAMS = tospatch.ttp loadtos.prg romdump.tos

all:: $(PROGRAMS)

include SRCFILES

tospatch.ttp: tospatch.o ${MAKEFILE}
	$(AM_V_LD)$(LINK68) $(LDFLAGS) $*.68k=tospatch.o
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

loadtos.prg: loadtos.o ${MAKEFILE}
	$(AM_V_LD)$(LINK68) $(LDFLAGS) $*.68k=loadtos.o
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

romdump.tos: romdump.o ${MAKEFILE}
	$(AM_V_LD)$(LINK68) $(LDFLAGS) $*.68k=romdump.o
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

check::

dist::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(top_srcdir)/$(DISTDIR1)/$(subdir)
	$(CP) -a $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR2)/$(subdir)

clean::
	$(RM) *.o *.a *.i *.1 *.2 *.rel *.68k $(PROGRAMS)

distclean: clean
