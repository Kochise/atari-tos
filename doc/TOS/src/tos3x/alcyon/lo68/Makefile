include ../Makefile.cmn
include ../Makefile.sil

PROGRAMS = lo68$(EXEEXT) reloc$(EXEEXT)
LIBS = ${LIBC}
CPPFLAGS += -DGEMDOS

all: $(PROGRAMS)

include SRCFILES

lo68$(EXEEXT): $(LO68_OBJS) ${MAKEFILE}
	$(AM_V_LD)$(LINK68) $(LDFLAGS) $*.68k=$(CRT0) $(NOFLOAT) $(LO68_OBJS) $(LIBS)
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

reloc$(EXEEXT): $(RELOC_OBJS) ${MAKEFILE}
	$(AM_V_LD)$(LINK68) $(LDFLAGS) $*.68k=$(CRT0) $(NOFLOAT) $(RELOC_OBJS) $(LIBS)
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

install: all
	$(CP) $(PROGRAMS) $(BIN)

check::

clean::
	$(RM) *.o *.a *.s *.i *.1 *.2 *.rel *.mod *.68k $(PROGRAMS)
