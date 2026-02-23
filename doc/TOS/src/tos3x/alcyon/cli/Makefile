include ../Makefile.cmn
include ../Makefile.sil

PROGRAMS = command.tos find.ttp time.prg date.prg

LIBS = ${LIBC}

all: $(PROGRAMS)

include SRCFILES
include optimize.mak

command.tos: $(COMA_OBJS) $(LIB1OBJS) ${MAKEFILE}
	$(AM_V_LD)$(LINK68) $(LDFLAGS) $*.68k=$(COMA_OBJS) $(LIB1OBJS)
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

find.ttp: $(FIND_OBJS) ${MAKEFILE}
	$(AM_V_LD)$(LINK68) $(LDFLAGS) $*.68k=$(CRT0) $(FIND_OBJS) $(LIBS) $(LIBS)
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

time.prg: $(TIME_OBJS) ${MAKEFILE}
	$(AM_V_LD)$(LINK68) $(LDFLAGS) $*.68k=$(TIME_OBJS)
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

date.prg: $(DATE_OBJS) ${MAKEFILE}
	$(AM_V_LD)$(LINK68) $(LDFLAGS) $*.68k=$(DATE_OBJS)
	$(AM_V_at)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

lmul.o:	../libsrc/lmul.o
	$(CP) $< $@

lrem.o:	../libsrc/lrem.o
	$(CP) $< $@

ldiv.o:	../libsrc/ldiv.o
	$(CP) $< $@

uldiv.o:	../libsrc/uldiv.o
	$(CP) $< $@

ulrem.o:	../libsrc/ulrem.o
	$(CP) $< $@

bios.o:	../libsrc/bios.o
	$(CP) $< $@

gemdos.o:	../libsrc/gemdos.o
	$(CP) $< $@

check::
	cmp command.tos ${BIN}command.tos

clean:
	$(RM) *.o *.a command.s *.i *.1 *.2 *.rel *.mod *.68k $(PROGRAMS)
