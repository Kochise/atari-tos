top_srcdir=..
subdir=tools

include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil

LIBS = $(LIBC)
INC := ..${BS}include${BS}

PROGRAMS = newglue$(BUILD_EXEEXT) mkbininc$(BUILD_EXEEXT) mkasminc$(BUILD_EXEEXT) mkrom$(BUILD_EXEEXT)
PROGRAMS += cmprom$(BUILD_EXEEXT)
# didnt bother to port these to alcyon
#PROGRAMS += findrsc$(BUILD_EXEEXT)

all:: $(PROGRAMS)

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

include SRCFILES

cmprom$(BUILD_EXEEXT): cmprom.o
	$(AM_V_LD)$(LINK68) $*.68k=$(CRT0),$<,$(LIBS),$(LIBS)
	$(AM_V_AT)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

newglue$(BUILD_EXEEXT): newglue.o
	$(AM_V_LD)$(LINK68) $*.68k=$(CRT0),$<,$(LIBS)
	$(AM_V_AT)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

findrsc$(BUILD_EXEEXT): findrsc.o
	$(AM_V_LD)$(LINK68) $*.68k=$(CRT0),$<,$(LIBS)
	$(AM_V_AT)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

mkbininc$(BUILD_EXEEXT): mkbininc.o
	$(AM_V_LD)$(LINK68) $*.68k=$(CRT0),$<,$(LIBS)
	$(AM_V_AT)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

mkasminc$(BUILD_EXEEXT): mkasminc.o
	$(AM_V_LD)$(LINK68) $*.68k=$(CRT0),$<,$(LIBS)
	$(AM_V_AT)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

mkrom$(BUILD_EXEEXT): mkrom.o
	$(AM_V_LD)$(LINK68) $*.68k=$(CRT0),$<,$(LIBS),$(LIBS)
	$(AM_V_AT)$(RELMOD) $*.68k $@
	@$(RM) $*.68k

check: $(PROGRAMS)

dist::

clean:
	$(RM) *.o *.a *.68k $(PROGRAMS)

distclean: clean
