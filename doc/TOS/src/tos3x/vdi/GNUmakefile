top_srcdir=..
subdir=vdi

# 
# cross compiling
#
EVAL_CROSS := case `uname -s` in *MiNT*|*TOS*) echo no;; *) echo yes; esac
CROSS := $(shell $(EVAL_CROSS))

include $(top_srcdir)/GNUmakefile.cmn
include $(top_srcdir)/Makefile.sil
include optimize.mak

LIBS =

CPPFLAGS = -I$(top_srcdir)/common -I$(INC)
CFLAGS = $(OPTS) $(WARN)

all:: $(top_srcdir)/common/config.h vdi.a vdivar.o

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

include SRCFILES

vdi.a: $(VDI_$(TOSVERSION)_OBJS) ${MAKEFILE}
	$(AR) $(ARFLAGS) $@ $(VDI_$(TOSVERSION)_OBJS)

ifeq ($(USE_CROSS_ALCYON),1)

#
# sed: optimizer seems to have missed an add.l #4,(sp) in make_header()
#
text_306_sed=$(SED) -e 's/add.l \#4,(sp)/dc.w 22679/' $*.s > $*.1; mv $*.1 $*.s

text.o: text.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(text_$(TOSVERSION)_sed)
	$(AM_V_at)$(BIN)optimize -q $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

# vs_color and vq_color are completely disabled in the hades, roms
# and in the Medusa roms for 3.06
disable_vs_color = 0
ifeq ($(HADES),1)
disable_vs_color = 1
endif
ifeq ($(MEDUSA),1)
ifeq ($(TOSVERSION),306)
disable_vs_color = 1
endif
endif
ifeq ($(disable_vs_color),1)
ttcolor.o: ttcolor.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; s/_vs_color:\nlink R14,#0/_vs_color:\ndc.w 0x4e75,0/; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; s/_vq_color:\nlink R14,#0/_vq_color:\ndc.w 0x4e75,0/; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -e 's/move $$ff8262,R/move.l #$$200,R/' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(BIN)optimize -q $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s
endif

endif

tosvars.o: $(top_srcdir)/common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

vars.o: $(top_srcdir)/common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

check::
	@:

dist::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR1)/$(subdir)
	$(CP) -a $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR2)/$(subdir)

dosdir::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(DOSDIR)/$(subdir)

clean:
	$(RM) *.o *.a *.ndx $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
