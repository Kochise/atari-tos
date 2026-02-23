top_srcdir=..
subdir=glue

include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil

all:: $(IMG)

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

HADES_0_IMG = tos$(TOSVERSION)$(COUNTRY).img
HADES_1_IMG = hades$(COUNTRY).img
IMG = $(HADES_$(HADES)_IMG)

include SRCFILES

STARTUP = startup.o

LIBS = ../bios/bios.a ../vdi/vdi.a ../bdos/bdos.a ../aes/aes.a ../desk/desk.a ../bios/hadxbios.o ../bios/m64_pci.o ../bios/m64_isa.o ../bios/medxbios.o
LIBSNDX = ../bios/bios.ndx ../vdi/vdi.ndx ../bdos/bdos.ndx ../aes/aes.ndx ../desk/desk.ndx
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

$(IMG): tos$(HADES).img $(MKROM)
	$(MKROM) pad $(ROMSIZE) $< $@

tos0.img: $(STARTUP) $(LIBS) tosimg.tmp tosrsc$(COUNTRY).o vars.o
	$(AM_V_LD)$(LINK68) '[abs,symbols,locals,text[$(rombase)],bss[0]]' $@=$(STARTUP),vars.o,../bios/bios.a[all],../vdi/vdi.a[all],../bdos/bdos.a[all],../aes/aes.a[all],../desk/desk.a[all],tosrsc$(COUNTRY).o,../bios/hadxbios.o,../bios/m64_pci.o,../bios/m64_isa.o,../bios/medxbios.o

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
tos1.img: $(STARTUP) $(LIBS) tosimg.tmp tosrsc$(COUNTRY).o vars.o
	$(AM_V_LD)$(LINK68) '[abs,symbols,locals,text[$(rombase)],bss[0]]' $@=$(STARTUP),vars.o,../bios/bios.a[all],../vdi/vdi.a[all],../bdos/bdos.a[all],../aes/aes.a[all],../desk/desk.a[all],tosrsc$(COUNTRY).o,../bios/hadxbios.o,../bios/m64_pci.o,../bios/m64_isa.o,../bios/medxbios.o
	$(AM_V_at)$(BIN)cnm $@ > rscend.1
	$(AM_V_at)$(GREP) end_of_resource rscend.1 > rscend.2
	$(AM_V_at)$(SED) -e 's/ .*$$//' -e 's/^00//' rscend.2 > rscend.1
	$(AM_V_at)$(TR) abcdef ABCDEF < rscend.1 > rscend.2
	$(AM_V_at)echo "16 i $(rombase) $(HADES_XBIOS) +" > rscend.1; cat rscend.2 >> rscend.1; echo "- 2 - p" >> rscend.1
	$(AM_V_at)$(TR) -d '\015' < rscend.1 > rscend.2
	$(AM_V_at)$(DC) < rscend.2 > rscend.1
	$(AM_V_at)$(SED) -e 's/\(.*\)/  data\n  dcb.b \1,-1'/ rscend.1 > hadestmp.S
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} hadestmp.S $@
	$(AM_V_LD)$(LINK68) '[abs,symbols,locals,text[$(rombase)],bss[0]]' $@=$(STARTUP),vars.o,../bios/bios.a[all],../vdi/vdi.a[all],../bdos/bdos.a[all],../aes/aes.a[all],../desk/desk.a[all],tosrsc$(COUNTRY).o,hadestmp.o,../bios/hadxbios.o,../bios/m64_pci.o,../bios/m64_isa.o,../bios/medxbios.o
	$(RM) hadestmp.S hadestmp.o rscend.1 rscend.2

tosimg.tmp: $(STARTUP) $(LIBS) rscend.o vars.o
	$(LINK68) '[abs,symbols,text[$(rombase)],bss[0]]' $@=$(STARTUP),vars.o,../bios/bios.a[all],../vdi/vdi.a[all],../bdos/bdos.a[all],../aes/aes.a[all],../desk/desk.a[all],rscend.o,../bios/hadxbios.o,../bios/m64_pci.o,../bios/m64_isa.o,../bios/medxbios.o

# For the PAK/BootJmp option, we need to know the start of the resource area first
rscend.h: tosimg.tmp
	$(AM_V_GEN)$(BIN)cnm $< > rscend.1
	$(AM_V_at)$(GREP) tosrsc rscend.1 > rscend.2
	$(AM_V_at)$(SED) -e 's/ .*$$//' -e 's/^00//' rscend.2 > rscend.1
	$(AM_V_at)$(TR) abcdef ABCDEF < rscend.1 > rscend.2
	$(AM_V_at)echo "16 i $(rombase) 40030 +" > rscend.1; cat rscend.2 >> rscend.1; echo "- p" >> rscend.1
	$(AM_V_at)$(TR) -d '\015' < rscend.1 > rscend.2
	$(AM_V_at)$(DC) < rscend.2 > rscend.1
	$(AM_V_at)$(SED) -e 's/^/#define RSCGAP /' rscend.1 > $@
	$(AM_V_at)$(RM) rscend.1 rscend.2

cartridge_ASFLAGS=-n

cartridg.img: cartridg.o
	$(LINK68) '[abs,text[$(CARTBASE)],bss[0]]' cartridg.tmp=cartridg.o
	dd bs=1 skip=36 < cartridg.tmp > $@
	$(RM) cartridg.tmp

../bios/bios.ndx: ../bios/bios.a
	$(RANLIB) $<

../vdi/vdi.ndx: ../vdi/vdi.a
	$(RANLIB) $<

../bdos/bdos.ndx: ../bdos/bdos.a
	$(RANLIB) $<

../aes/aes.ndx: ../aes/aes.a
	$(RANLIB) $<

../desk/desk.ndx: ../desk/desk.a
	$(RANLIB) $<

startup.o: startup.S
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i
	
vdivar.o: ../vdi/vdivar.S
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i
	
vars.o: ../common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

cartridg.o: cartridg.S
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} -n ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i
	
include gluer.mak

# compare only 256k for STBook, since it only has the ROM, not the cartridge extension
CMPSIZE_208 = --bytes=262144
check: $(IMG)
	$(CMP) $(CMPL) -x --ignore-initial=0x0:0x0 --offsets=0x$(rombase):0 $(CMPSIZE_$(TOSVERSION)) $(top_srcdir)/roms/$(IMG) $(IMG)

clean:
	$(RM) *.o *.a *.i $(IMG) tos.img tos0.img tos1.img tosimg.tmp cartridg.tmp cartridg.img $(PROGRAMS) tosrsc*.c glue.* rscend.h tosrel.tmp tos.rel hadestmp.S $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak *.img
