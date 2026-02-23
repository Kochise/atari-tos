include ../Makefile.cmn
include ../Makefile.sil

all::

include SRCFILES

all:: libc.a libm.a crt0.o ${OPTIONOBJS}

libc.a: $(OBJS) ${OPTIONOBJS} ${MAKEFILE}
	$(AM_V_at)$(RM) $@
	$(AM_V_AR)$(AR) $(ARFLAGS) $@ $(COBJS1)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS2)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS3)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS4)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS5)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS6)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS7)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS8)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS9)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS10)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS11)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS12)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS13)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS14)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS15)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS16)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS17)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(COBJS18)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(AOBJS1)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(AOBJS2)

libm.a: $(MOBJS) ${MAKEFILE}
	$(AM_V_at)$(RM) $@
	$(AM_V_AR)$(AR) $(ARFLAGS) $@ $(MCOBJS1)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(MCOBJS2)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(MAOBJS1)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(MAOBJS2)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(MAOBJS3)
	$(AM_V_at)$(AR) $(ARFLAGS) $@ $(MAOBJS4)

install: all
	$(CP) libc.a libm.a crt0.o nofloat.o $(LIB)


clean:
	$(RM) *.o *.a *.ndx
