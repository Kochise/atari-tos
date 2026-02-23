/*	DOSBIND.C	11/12/84 - 10/09/85	Lowell Webster		*/

#include "portab.h"   /* PROCESSOR SPECIFIC DEFINITIONS */
#include "machine.h"  /* PROCESSOR SPECIFIC DEFINITIONS */
#include "dosbind.h"  /* INCLUDE MODULE FOR DOSBIND.C	*/

EXTERN LONG	__DOS();  	/* in DOSASM.S	 	*/

GLOBAL UWORD	DOS_AX;		/* really a "DOS_RET"	*/
GLOBAL UWORD	DOS_ERR;

BYTE	*str_copy();		/* also in tcrtl.c	*/


#define X_TABOUT 0x02
#define X_PRTOUT 0x05
#define X_RAWCON 0x06
#define X_SETDRV 0x0E
#define X_GETDRV 0x19
#define X_SETDTA 0x1A
#define X_GETFREE 0x36
#define X_MKDIR 0x39
#define X_RMDIR 0x3A
#define X_CHDIR 0x3B
#define X_CREAT 0x3C
#define X_OPEN 0x3D
#define X_CLOSE 0x3E
#define X_READ 0x3F
#define X_WRITE 0x40
#define X_UNLINK 0x41
#define X_LSEEK 0x42
#define X_CHMOD 0x43
#define X_GETDIR 0x47
#define X_MALLOC 0x48
#define X_MFREE 0x49
#define X_SETBLOCK 0x4A
#define X_EXEC 0x4B
#define X_SFIRST 0x4E
#define X_SNEXT 0x4F
#define X_RENAME 0x56
#define X_GSDTOF 0x57

	VOID
dos_func(function, parm)
	UWORD		function;
	LONG		parm;
{
	return( __DOS(function, parm) );
}

	LONG
dos_chdir(pdrvpath)	 		/* change the current directory	*/
	LONG		pdrvpath;
{
	return(__DOS(X_CHDIR, pdrvpath));
}

	WORD
dos_gdir(drive, pdrvpath)		/* get current directory	*/
	WORD		drive;		/* 0=default drive, 1=A:, etc	*/
	REG BYTE *	pdrvpath;
{
	REG WORD ret;

	ret = __DOS(X_GETDIR, pdrvpath, drive);
	if (pdrvpath[0] == '\\')
	  str_copy(&pdrvpath[1], pdrvpath);	/* remove leading '\'	*/
	return(ret);
}

	WORD
dos_gdrv()				/* get current drive		*/
{
	return( __DOS(X_GETDRV) );
}

	WORD
dos_sdrv(newdrv)	/* select new drive, new drive becomes default */
	WORD		newdrv;
{
	return( __DOS(X_SETDRV, newdrv) );
}

	VOID
dos_sdta(ldta)		/* set the Disk Transfer Address ( DTA ) */
	LONG		ldta;
{
	return(__DOS(X_SETDTA, ldta));
}

	WORD
dos_sfirst(pspec, attr)	/* search for first matching file 	*/
	LONG		pspec;
	WORD		attr;	/* file attributes */
{
	return(!__DOS(X_SFIRST, pspec, attr));
}

	WORD
dos_snext()	/* search for next matching file  		  */
		/* dos_sfirst() must be used just before this one */
{
	return(!__DOS(X_SNEXT));
}

	WORD
dos_open(pname, access)	/* open file		*/
	BYTE		*pname;	/* filename	*/
	WORD		access;	/* 0 = read, 1 = write, 2 = both	*/
{
	LONG		ret;

	ret = __DOS(X_OPEN, pname, access);
	if (DOS_ERR)
	  return(FALSE);
	else
	  return((UWORD)ret);	/* returns file handle			*/
}

	WORD
dos_close(handle)		/* close file		*/
	WORD		handle;
{
	return( __DOS(X_CLOSE, handle) );
}

/* for programs ported from 8086		*/
	UWORD			
read_piece(handle, cnt, pbuffer)	/* read file */
	WORD		handle;
	UWORD		cnt;		/* number of bytes to read */
	LONG		pbuffer;	/* buffer to read into 	   */
{
	return((UWORD)__DOS(X_READ, handle, (ULONG)cnt, pbuffer));
}

	ULONG
dos_read(handle, cnt, pbuffer)		/* read file			*/
	WORD		handle;
	LONG		cnt;		/* number of bytes to read	*/
	LONG		pbuffer;	/* buffer to read into		*/
{
	return(__DOS(X_READ, handle, cnt, pbuffer));
}

	LONG
dos_lseek(handle, smode, sofst)	/* move file read / write pointer	*/
	WORD		handle;
	WORD		smode;	/* 0 = from beginning, 1 from current	*/
				/* 2 = EOF plus offset			*/
	LONG		sofst;	/* offset in bytes			*/
{
	return( __DOS(X_LSEEK, sofst, handle, smode) );
}

	WORD
dos_wait()	/* get return code of a sub-process */
{
}

	LONG
dos_alloc(nbytes)			/* allocate memory	*/
	LONG		nbytes;
{
	REG LONG ret;

	ret = __DOS(X_MALLOC, nbytes);
	if (ret == 0)
	  DOS_ERR = TRUE;		/* gemdos() sets it to FALSE	*/
	return(ret);
}

	LONG
dos_avail()		/* Returns the amount of memory available in bytes	*/
{
	return( __DOS( X_MALLOC, -1L) );
}

	WORD
dos_free(maddr)		/* free memory that was allocated via dos_alloc() */
	LONG		maddr;
{
	return( __DOS(X_MFREE, maddr) );
}

	WORD
dos_space(drv, ptotal, pavail)	/* get disk free space     */
	WORD	drv;		/* 0 = default, 1 = A: etc */
	LONG	*ptotal, *pavail;
{
	LONG	buf[4];
	LONG	mult;

	__DOS(X_GETFREE, buf, drv);
	mult = buf[3] * buf[2];
	*ptotal = mult * buf[1];
	*pavail = mult * buf[0];
	return(TRUE);
}

	WORD
dos_rmdir(path)		/* remove directory entry	*/
	BYTE	*path;
{
	return ( __DOS(X_RMDIR, path) );
}

	LONG
dos_create(name, attr)
	BYTE	*name;
	WORD	attr;
{
	return(__DOS(X_CREAT, name, attr));
}

	WORD
dos_mkdir(path)		/* create a sub_directory	*/
	BYTE	*path;
{
	__DOS(X_MKDIR, path);
	return( !DOS_ERR );
}

	WORD
dos_delete(name)		/* delete file	*/
	BYTE	*name;
{
	return (__DOS(X_UNLINK, name) );
}

	WORD
dos_rename(p1, p2)		/* rename file	*/
	BYTE	*p1;
	BYTE	*p2;
{
	return(__DOS(X_RENAME, 0x0, p1, p2) );
}

	UWORD
write_piece(handle, cnt, pbuffer)	/*  write to a file	*/
	WORD		handle;
	UWORD		cnt;
	LONG		pbuffer;
{
	return((UWORD)__DOS(X_WRITE, handle, (ULONG)cnt, pbuffer));
}

	ULONG
dos_write(handle, cnt, pbuffer)		/* write to a file	*/
	WORD		handle;
	LONG		cnt;
	LONG		pbuffer;
{
	return(__DOS(X_WRITE, handle, cnt, pbuffer));
}

	WORD
dos_chmod(pname, func, attr)		/* change file mode	*/
	BYTE		*pname;
	WORD		func;
	WORD		attr;

{
	return( __DOS(X_CHMOD, pname, func, attr) );
}

	WORD
dos_setdt(h, time, date)		/* set a file's date and time	*/
	UWORD	h, time, date;
{
	UWORD	buf[2];

	buf[0] = time;
	buf[1] = date;
	return( __DOS(X_GSDTOF, &buf[0], h, TRUE) );
}

	BYTE
*str_copy(ps, pd)
	REG BYTE	*ps, *pd;
{
	while(*pd++ = *ps++)
	  ;
	return(pd);
}

