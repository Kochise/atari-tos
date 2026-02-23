top_srcdir=..
subdir=glue

# 
# cross compiling
#
EVAL_CROSS := case `uname -s` in *MiNT*|*TOS*) echo no;; *) echo yes; esac
CROSS := $(shell $(EVAL_CROSS))

include $(top_srcdir)/GNUmakefile.cmn
include $(top_srcdir)/Makefile.sil

LIBS =

CPPFLAGS = -I$(top_srcdir)/common -I$(INC)
CFLAGS = $(OPTS) $(WARN)

all::

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

ifeq ($(HADES),1)
IMG = hades$(COUNTRY).img
else
ifeq ($(MEDUSA),1)
IMG = medusa$(TOSVERSION)$(COUNTRY).img
else
IMG = tos$(TOSVERSION)$(COUNTRY).img
endif
endif

all:: $(IMG)

include SRCFILES

STARTUP = startup.o

LIBS = ../bios/bios.a ../vdi/vdi.a ../bdos/bdos.a ../aes/aes.a ../desk/desk.a ../bios/hadxbios.o ../bios/m64_pci.o ../bios/m64_isa.o ../bios/medxbios.o
OBJS = $(STARTUP) $(BIOS_OBJS) $(VDI_OBJS) $(BDOS_OBJS) $(AES_OBJS) $(DESK_OBJS)

ROMSIZE_206 = 256k
# use 257 for ST-book, since mkrom can't distinguish it from 2.06
ROMSIZE_208 = 257k
ROMSIZE_306 = 512k

ROMSIZE = $(ROMSIZE_$(TOSVERSION))

#
# Base of the internal cartridge ROM of St-Book TOS
#
CARTBASE = E40000

#
# For hades, linking is done in two steps
#
# - first, link a ROM
# - get the address of the end of the resource data
# - calculate the size of the area between that address,
#   and the start of the bios extension functions
# - generate a temporary object that fills this area with -1
# - link the ROM again. This will now have the functions at their
#   expected address
#
ifeq ($(USE_CROSS_ALCYON),1)
tos.img: $(STARTUP) $(LIBS) tosimg.tmp tosrsc$(COUNTRY).o vars.o tosvars.o GNUmakefile
ifeq ($(HADES),1)
	$(LINK68) '[abs,symbols,locals,text[$(rombase)],bss[0]]' $@=$(STARTUP),vars.o,tosvars.o,../bios/bios.a[all],../vdi/vdi.a[all],../bdos/bdos.a[all],../aes/aes.a[all],../desk/desk.a[all],tosrsc$(COUNTRY).o,../bios/hadxbios.o,../bios/m64_pci.o,../bios/m64_isa.o,../bios/medxbios.o
	end_of_resource=`$(BIN)cnm $@ | $(GREP) end_of_resource | $(SED) -e 's/ .*$$//' -e 's/^00//' | $(TR) abcdef ABCDEF`; \
	fill=`echo "16 i $(rombase) $(HADES_XBIOS) + $$end_of_resource - 2 - p" | $(DC)`; \
	if test $$fill -lt 0; then echo "TOS.IMG is too large" >&2; exit 1; fi; \
	echo "  data" > hadestmp.S; \
	echo "  dcb.b $$fill,-1" >> hadestmp.S
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -o hadestmp.o hadestmp.S
	$(LINK68) '[abs,symbols,locals,text[$(rombase)],bss[0]]' $@=$(STARTUP),vars.o,tosvars.o,../bios/bios.a[all],../vdi/vdi.a[all],../bdos/bdos.a[all],../aes/aes.a[all],../desk/desk.a[all],tosrsc$(COUNTRY).o,hadestmp.o,../bios/hadxbios.o,../bios/m64_pci.o,../bios/m64_isa.o,../bios/medxbios.o
	$(RM) hadestmp.S hadestmp.o
else
	$(AM_V_LD)$(LINK68) '[abs,symbols,locals,text[$(rombase)],bss[0]]' $@=$(STARTUP),vars.o,tosvars.o,../bios/bios.a[all],../vdi/vdi.a[all],../bdos/bdos.a[all],../aes/aes.a[all],../desk/desk.a[all],tosrsc$(COUNTRY).o,../bios/medxbios.o
endif

# For the PAK/BootJmp option, we need to know the start of the resource area first
tosimg.tmp: $(STARTUP) $(LIBS) rscend.o vars.o tosvars.o
	$(AM_V_LD)$(LINK68) '[abs,symbols,text[$(rombase)],bss[0]]' $@=$(STARTUP),vars.o,tosvars.o,../bios/bios.a[all],../vdi/vdi.a[all],../bdos/bdos.a[all],../aes/aes.a[all],../desk/desk.a[all],rscend.o,../bios/hadxbios.o,../bios/m64_pci.o,../bios/m64_isa.o,../bios/medxbios.o

rscend.h: tosimg.tmp
	$(AM_V_GEN)tosrsc=`$(BIN)cnm $< | $(GREP) tosrsc | $(SED) -e 's/ .*$$//' -e 's/^00//' | $(TR) abcdef ABCDEF`; \
	fill=`echo "16 i $(rombase) 40030 + $$tosrsc - p" | $(DC)`; \
	echo "#define RSCGAP $$fill" > $@

tos.rel: $(STARTUP) $(LIBS) tosrsc$(COUNTRY).o vars.o tosvars.o ../vdi/vdivar.o ../aes/gembase.o sbss.o ebss.o
	$(AM_V_at)$(CP) ../vdi/cbssdefs.o .
	$(AM_V_at)$(CP) ../aes/gembase.o .
	$(AM_V_LD)$(LINK68) '[abs,relocs=td,text[$(rombase)],bss[0]]' tosrel.tmp=$(STARTUP),vars.o,tosvars.o,../bios/bios.a[all],../vdi/vdi.a[all],../bdos/bdos.a[all],../aes/aes.a[all],../desk/desk.a[all],tosrsc$(COUNTRY).o > $@
	$(AM_V_at)$(RM) tosrel.tmp

else

CCLIBS := `$(CC) -print-file-name=libgcc.a`
LDFLAGS := -nostdlib -nostartfiles -Wl,--script=../common/rom.ld,--entry=_os_entry,-Ttext=0x$(rombase),-Tbss=0

tos.img: $(STARTUP) $(LIBS) tosimg.tmp tosrsc$(COUNTRY).o vars.o tosvars.o ebss.o
	$(AM_V_LD)$(LD) $(LDFLAGS) -o $@ $(STARTUP) vars.o tosvars.o ../bios/bios.a ../vdi/vdi.a ../bdos/bdos.a ../vdi/vdi.a ../aes/aes.a ../desk/desk.a tosrsc$(COUNTRY).o $(CCLIBS)

# For the PAK/BootJmp option, we need to know the start of the resource area first
tosimg.tmp: $(STARTUP) $(LIBS) rscend.o vars.o tosvars.o ebss.o
	$(AM_V_LD)$(LD) $(LDFLAGS),-Map,tostmp.map -o $@ $(STARTUP) vars.o tosvars.o ../bios/bios.a ../vdi/vdi.a ../bdos/bdos.a ../vdi/vdi.a ../aes/aes.a ../desk/desk.a rscend.o $(CCLIBS)

rscend.h: tosimg.tmp
	$(AM_V_GEN)tosrsc=`$(GREP) tosrsc tostmp.map | $(SED) -e 's/.*0x\([0-9a-fA-F]*\).*/\1/' -e 's/^00//' | $(TR) abcdef ABCDEF`; \
	fill=`echo "16 i $(rombase) 40030 + $$tosrsc - p" | $(DC)`; \
	echo "#define RSCGAP $$fill" > $@

endif

ifeq ($(USE_CROSS_ALCYON),1)
NO_BRANCH_OPT = -n
endif

cartridg.img: cartridg.o
ifeq ($(USE_CROSS_ALCYON),1)
	$(LINK68) '[abs,text[$(CARTBASE)],bss[0]]' cartridg.tmp=cartridg.o
	dd bs=1 skip=36 < cartridg.tmp > $@
	$(RM) cartridg.tmp
else
	$(LD) -nostartfiles -nostdlib -o $@ -Wl,--script=../common/rom.ld,-Ttext=0x$(CARTBASE),-Tbss=0 cartridg.o
endif

cartridg.o: cartridg.S
	$(AM_V_AS)$(AS) $(ASFLAGS) $(NO_BRANCH_OPT) $(CPPFLAGS) -c -o $@ $<

$(IMG): tos.img $(MKROM)
	$(MKROM) pad $(ROMSIZE) $< $@

vdivar.o: ../vdi/vdivar.S
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

vars.o: ../common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

tosvars.o: ../common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

include gluer.mak

# compare only 256k for STBook, since it only has the ROM, not the cartridge extension
CMPSIZE_208 = --bytes=262144
check:: $(IMG)
	$(CMP) $(CMPL) -x --ignore-initial=0x0:0x0 --offsets=0x$(rombase):0 $(CMPSIZE_$(TOSVERSION)) $(top_srcdir)/roms/$(IMG) $(IMG)

dist::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR1)/$(subdir)
	$(CP) -a $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR2)/$(subdir)

dosdir::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(DOSDIR)/$(subdir)

clean:
	$(RM) *.o *.a *.i $(IMG) tos.img tosimg.tmp cartridg.tmp cartridg.img tostmp.map $(PROGRAMS) tosrsc*.c glue.* rscend.h tosrel.tmp tos.rel hadestmp.S $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak *.img
