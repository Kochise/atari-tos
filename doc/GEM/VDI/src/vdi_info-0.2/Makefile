#############################################################################
#
#	Makefile for vdi_info
#
#	by Patrice Mandin
#
#############################################################################
#############################################################################

###############	Choose the configuration to compile this program for :
#
#	Configurations allowed are:
#
#	SYSTEM	CPU		CROSS
#
#	sdl		x86		n
#	linux	x86		n
#	atari	m68k	n
#	atari	m68k	y	(cross compilation on a different machine)

SYSTEM=		atari
CPU=		m68k
CROSS=		y

#SYSTEM=		linux
#CPU=		x86
#CROSS=		n

#SYSTEM=		sdl
#CPU=		x86
#CROSS=		n

###############	Different initializations values

CPU_IS_m68k=	-m68000
#CPU_IS_m68k=	-m68000 -m68881
#CPU_IS_m68k=	-m68030 
#CPU_IS_m68k=	-m68020-60 -m68881
CPU_IS_x86=		-mpentium

SYS_IS_linux=
SYS_IS_sdl=		`sdl-config --cflags`
SYS_IS_atari=	-D_GNU_SOURCE

VIDLIB_IS_atari=	-lgem

SYSTEMLIBS=

#CROSSBINDIR_IS_y=	m68k-atari-mint-
CROSSBINDIR_IS_y=	/home/patrice/local/bin/m68k-atari-mint-
CROSSBINDIR_IS_n=

###############	Parse configuration now

SYSTEMFLAGS=	$(SYS_IS_$(SYSTEM))
VIDEOLIBS=	$(VIDLIB_IS_$(SYSTEM))
CPUFLAGS=	$(CPU_IS_$(CPU))
SYSTEMOBJS=	$(OBJ_IS_$(SYSTEM))
CROSSBINDIR=	$(CROSSBINDIR_IS_$(CROSS))

###############	Common variables

CC=		$(CROSSBINDIR)gcc
LD=		$(CROSSBINDIR)gcc
AS=		$(CROSSBINDIR)as
STRIP=		$(CROSSBINDIR)strip
STACK=		$(CROSSBINDIR)stack

STACKSIZE=	131072

INCDIR=		.
SRCDIR=		.
OBJDIR=		obj.$(SYSTEM)

INCLUDES=	-I$(INCDIR)
CFLAGS=		-Wall -O2 -fomit-frame-pointer
#LDFLAGS=	-g

###############	Program name

PROGRAM=	vdi_info.ttp

###############	System specific objects files

OBJ_IS_linux=

OBJ_IS_atari=

###############	Common objects files

OBJS=	vdi.o vdi_eddi.o

###############	Rules to build program

all:	 $(PROGRAM) make-strip $(SYSTEM)

clean:
	rm -rf $(OBJDIR)/*.o
	rm -rf *.o
	rm -f $(PROGRAM)

make-strip:
	$(STRIP) $(PROGRAM)

srcdist:
	cd .. ; tar cvzf $(SRCDISTNAME).tar.gz $(SRCDISTFILES) ; cd $(SRCDISTNAME)

$(PROGRAM):	$(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) $(VIDEOLIBS) $(SYSTEMLIBS) -o $(PROGRAM)

$(OBJDIR)/%.o:	$(SRCDIR)/%.c
	@if [ ! -d $(OBJDIR) ]; then mkdir $(OBJDIR); fi
	$(CC) $(INCLUDES) $(CFLAGS) $(SYSTEMFLAGS) $(CPUFLAGS) -c $< -o $@

$(OBJDIR)/%.o:	$(SRCDIR)/%.S
	@if [ ! -d $(OBJDIR) ]; then mkdir $(OBJDIR); fi
	$(CC) $(INCLUDES) $(CFLAGS) $(SYSTEMFLAGS) $(CPUFLAGS) -c $< -o $@ 

###############	System dependent rules

linux:

atari:
	$(STACK) -S $(STACKSIZE) $(PROGRAM)
