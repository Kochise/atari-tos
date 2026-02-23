include ../Makefile.cmn
include ../Makefile.sil

PROGRAMS = test.prg apskel.prg doodle.app
LIBS = ${LIBC} ${GEMLIB}
DEPLIBS = ${DEPLIBC} ${DEPGEMLIB}

all: $(PROGRAMS)

include SRCFILES

test.prg: $(TEST_OBJS) ${MAKEFILE} $(DEPLIBS)
	$(AM_V_LD)$(LINK68) $*.68k=$(LIB)gemstart.o,$(NOFLOAT),$(TEST_OBJS),$(LIBC),$(GEMLIB)
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

apskel.prg: $(APSKEL_OBJS) ${MAKEFILE} $(DEPLIBS)
	$(AM_V_LD)$(LINK68) $*.68k=$(LIB)gemstart.o,$(NOFLOAT),$(APSKEL_OBJS),$(LIBC),$(GEMLIB)
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

doodle.app: $(DOODLE_OBJS) ${MAKEFILE} $(DEPLIBS)
	$(AM_V_LD)$(LINK68) $(LDFLAGS) $*.68k=$(LIB)gemstart.o $(NOFLOAT) $(DOODLE_OBJS) $(LIBS)
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

install: all
	@:

check::

clean:
	$(RM) *.o *.a *.s *.i *.1 *.2 *.rel *.mod *.68k $(PROGRAMS)
