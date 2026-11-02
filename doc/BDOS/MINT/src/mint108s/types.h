/*
Copyright 1990,1991,1992 Eric R. Smith. All rights reserved.
*/

#ifndef _types_h
#define _types_h

#ifndef dLibs
typedef unsigned long 	ulong;
typedef unsigned short	ushort;
typedef unsigned char	uchar;
#endif

typedef long ARGS_ON_STACK (*Func)();

/* structure used to hold i/o buffers */
typedef struct io_rec {
	char *bufaddr;
	short buflen, head, tail, low_water, hi_water;
} IOREC_T;


#endif
