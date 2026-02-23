#
# $Id: sox.mak,v 1.2 2003/02/28 20:46:41 a_bercegeay Exp $
#

# makefile for gemlib 
# sozobon version

# note:
# CC_SOX must point to your cc.ttp program
# AR_SOX must point to your ar.ttp program

CC     = $(CC_SOX)
AS     = $(AS_SOX)
AR     = $(AR_SOX)

CFLAGS = -O

include files.mak

.SUFFIXES:
.SUFFIXES: .c .s .o

.c.o:
	$(CC) $(CFLAGS) -c $*.c -o $*.o

.s.o:
	$(CC) $(CFLAGS) -c $*.s -o $*.o

TARGET = $(LIB_SOZOBON)

all: $(TARGET)

$(TARGET): $(OBJ) $(SX_OBJ)
	$(RM) $@
	$(AR) -r $@ $^
