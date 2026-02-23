top_srcdir=..
include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil

PROGRAMS = hello.tos

all::	$(PROGRAMS)

hello.tos: hello.o
	$(LINK68) hello.68k=$(CRT0),hello.o,$(LIB)gem.a,$(LIB)libc.a,$(LIB)libc.a,$(LIB)libf.a
	$(RELMOD) hello.68k $@
	$(RM) hello.68k

check::

clean:
	$(RM) *.o *.a *.i *.1 *.2 *.rel *.mod $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
