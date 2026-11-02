/*
 * This file has been modified as part of the MH-MiNT project. See
 * the file Changes.MH for details and dates.
 */

/* header file for dealing with the cookie jar */

#ifndef _COOKIE_H
#define _COOKIE_H

struct cookie {
	long tag;
	long value;
};

typedef struct cookie COOKIE;

#define CJAR	   ((COOKIE **) 0x5a0)


/* Scookie uses the following Action values */

#define  C_BAKE    0x0001
#define  C_GRAB    0x0002
#define  C_MORE    0x0004
#define  C_READ    0x0008
#define  C_SIZE    0x0010
#define  C_EAT     0x0020


/* "Special" tag for the first cookie */

#define  C_FIRST    -1L

/* Last cookie, or the "null" cookie  */

#define  C_NULL      0L

 
/* List of currently available tag values */

#define  COOKIE__CPU 	0x5f435055L
#define  COOKIE__VDO 	0x5f56444fL
#define  COOKIE__FPU 	0x5f465055L
#define  COOKIE__FDC 	0x5f464443L
#define  COOKIE__SND 	0x5f534e44L
#define  COOKIE__MCH 	0x5f4d4348L
#define  COOKIE__SWI 	0x5f535749L
#define  COOKIE__FRB 	0x5f465242L
#define  COOKIE__FLK 	0x5f464c4bL
#define  COOKIE__NET 	0x5f4e4554L
#define  COOKIE__IDT 	0x5f494454L
#define  COOKIE__AKP 	0x5f414b50L
#define  COOKIE_FSMC 	0x46534d43L
#define  COOKIE_MiNT 	0x4d694e54L
#define  COOKIE_PMMU 	0x504d4d55L
#define  COOKIE_NVDI 	0x4e564449L
#define	 COOKIE_RSVF	0x52535646L

/* List of pseudo-cookie values for C_READ */

#define  COOKIE_V200 	0x2a323030L

#endif /* _COOKIE_H */
