include ../Makefile.cmn
include ../Makefile.sil

all::

include SRCFILES

all:: gem.a gemstart.o

gem.a: $(OBJS) ${MAKEFILE}
	$(AM_V_at)$(RM) $@
	$(AM_V_AR)$(AR) $(ARFLAGS) $@ $(OBJS)

install: all
	$(CP) gem.a gemstart.o $(LIB)

clean:
	$(RM) *.o *.a *.ndx
