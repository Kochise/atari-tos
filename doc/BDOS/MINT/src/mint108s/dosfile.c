/*
Copyright 1990,1991,1992 Eric R. Smith.
Copyright 1992,1993 Atari Corporation.
All rights reserved.
*/

/* DOS file handling routines */

#include "mint.h"

static long do_dup P_((int,int));
static void unselectme P_((PROC *));

/*
 * first, some utility routines
 */

FILEPTR *
do_open(name, rwmode, attr, x)
	const char *name;	/* file name */
	int rwmode;	/* file access mode */
	int attr;	/* TOS attributes for created files (if applicable) */
	XATTR *x;	/* filled in with attributes of opened file */
{
	struct tty *tty;
	fcookie dir, fc;
	long devsp;
	FILEPTR *f;
	DEVDRV *dev;
	long r;
	XATTR xattr;
	unsigned perm;
	int creating;
	char temp1[PATH_MAX];
	extern FILESYS proc_filesys;

/* for special BIOS "fake" devices */
	extern DEVDRV fakedev;

	TRACE(("do_open(%s)", name));

/*
 * first step: get a cookie for the directory
 */

	r = path2cookie(name, temp1, &dir);
	if (r) {
		mint_errno = (int)r;
		DEBUG(("do_open(%s): error %ld", name, r));
		return NULL;
	}

/*
 * second step: try to locate the file itself
 */
	r = relpath2cookie(&dir, temp1, follow_links, &fc, 0);

/*
 * file found: this is an error if (O_CREAT|O_EXCL) are set
 */

	if ( (r == 0) && ( (rwmode & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL) ) ) {
		DEBUG(("do_open(%s): file already exists",name));
		mint_errno = EACCDN;
		release_cookie(&fc);
		release_cookie(&dir);
		return NULL;
	}
/*
 * file not found: maybe we should create it
 * note that if r != 0, the fc cookie is invalid (so we don't need to
 * release it)
 */
	if (r == EFILNF && (rwmode & O_CREAT)) {
	/* check first for write permission in the directory */
		r = (*dir.fs->getxattr)(&dir, &xattr);
		if (r == 0) {
			if (denyaccess(&xattr, S_IWOTH))
				r = EACCDN;
		}
		if (r) {
			DEBUG(("do_open(%s): couldn't get "
			      "write permission on directory",name));
			mint_errno = (int)r;
			release_cookie(&dir);
			return NULL;
		}
		r = (*dir.fs->creat)(&dir, temp1,
			(S_IFREG|DEFAULT_MODE) & (~curproc->umask), attr, &fc);
		if (r) {
			DEBUG(("do_open(%s): error %ld while creating file",
				name, r));
			mint_errno = (int)r;
			release_cookie(&dir);
			return NULL;
		}
		creating = 1;
	} else if (r) {
		DEBUG(("do_open(%s): error %ld while searching for file",
			name, r));
		mint_errno = (int)r;
		release_cookie(&dir);
		return NULL;
	} else {
		creating = 0;
	}

/*
 * check now for permission to actually access the file
 */
	r = (*fc.fs->getxattr)(&fc, &xattr);
	if (r) {
		DEBUG(("do_open(%s): couldn't get file attributes",name));
		mint_errno = (int)r;
		release_cookie(&dir);
		release_cookie(&fc);
		return NULL;
	}
/*
 * we don't do directories
 */
	if ( (xattr.mode & S_IFMT) == S_IFDIR ) {
		DEBUG(("do_open(%s): file is a directory",name));
		release_cookie(&dir);
		release_cookie(&fc);
		mint_errno = EFILNF;
		return NULL;
	}

	switch (rwmode & O_RWMODE) {
	case O_WRONLY:
		perm = S_IWOTH;
		break;
	case O_RDWR:
		perm = S_IROTH|S_IWOTH;
		break;
	case O_EXEC:
		perm = (fc.fs->fsflags & FS_NOXBIT) ? S_IROTH : S_IXOTH;
		break;
	case O_RDONLY:
		perm = S_IROTH;
		break;
	default:
		perm = 0;
		ALERT("do_open: bad file access mode: %x", rwmode);
	}
	if (!creating && denyaccess(&xattr, perm)) {
		DEBUG(("do_open(%s): access to file denied",name));
		release_cookie(&dir);
		release_cookie(&fc);
		mint_errno = EACCDN;
		return NULL;
	}

/*
 * an extra check for write access -- even the superuser shouldn't
 * write to files with the FA_RDONLY attribute bit set (unless,
 * we just created the file, or unless the file is on the proc
 * file system and hence FA_RDONLY has a different meaning)
 */
	if ( !creating && (xattr.attr & FA_RDONLY) && fc.fs != &proc_filesys) {
		if ( (rwmode & O_RWMODE) == O_RDWR ||
		     (rwmode & O_RWMODE) == O_WRONLY ) {
			DEBUG(("do_open(%s): can't write a read-only file",
				name));
			release_cookie(&dir);
			release_cookie(&fc);
			mint_errno = EACCDN;
			return NULL;
		}
	}

/*
 * if writing to a setuid or setgid file, clear those bits
 */
	if ( (perm & S_IWOTH) && (xattr.mode & (S_ISUID|S_ISGID)) ) {
		xattr.mode &= ~(S_ISUID|S_ISGID);
		(*fc.fs->chmode)(&fc, (xattr.mode & ~S_IFMT));
	}
/*
 * If the caller asked for the attributes of the opened file, copy them over.
 */
	if (x) *x = xattr;

/*
 * So far, so good. Let's get the device driver now, and try to
 * actually open the file.
 */
	dev = (*fc.fs->getdev)(&fc, &devsp);
	if (!dev) {
		mint_errno = (int)devsp;
		DEBUG(("do_open(%s): device driver not found",name));
		release_cookie(&dir);
		release_cookie(&fc);
		return NULL;
	}

	if (dev == &fakedev) {		/* fake BIOS devices */
		f = curproc->handle[devsp];
		if (!f) {
			mint_errno = EIHNDL;
			return 0;
		}
		f->links++;
		release_cookie(&dir);
		release_cookie(&fc);
		return f;
	}
	if (0 == (f = new_fileptr())) {
		release_cookie(&dir);
		release_cookie(&fc);
		mint_errno = ENSMEM;
		return NULL;
	}
	f->links = 1;
	f->flags = rwmode;
	f->pos = 0;
	f->devinfo = devsp;
	f->fc = fc;
	f->dev = dev;
	release_cookie(&dir);

	r = (*dev->open)(f);
	if (r < 0) {
		DEBUG(("do_open(%s): device open failed with error %ld",
			name, r));
		mint_errno = (int)r;
		f->links = 0;
		release_cookie(&fc);
		dispose_fileptr(f);
		return NULL;
	}

/* special code for opening a tty */
	if (is_terminal(f)) {
		extern struct tty default_tty;	/* in tty.c */

		tty = (struct tty *)f->devinfo;
		if (tty->use_cnt == 0) {     /* first open for this device? */
			*tty = default_tty;
		}
		tty->use_cnt++;
	}
	return f;
}

/*
 * helper function for do_close: this closes the indicated file pointer which
 * is assumed to be associated with process p. The extra parameter is necessary
 * because f_midipipe mucks with file pointers of other processes, so
 * sometimes p != curproc.
 *
 * Note that the function changedrv() in filesys.c can call this routine.
 * in that case, f->dev will be 0 to represent an invalid device, and
 * we cannot call the device close routine.
 */

long
do_pclose(p, f)
	PROC *p;
	FILEPTR *f;
{
	long r = 0;

	if (!f) return EIHNDL;

/* if this file is "select'd" by this process, unselect it
 * (this is just in case we were killed by a signal)
 */

/* BUG? Feature? If media change is detected while we're doing the select,
 * we'll never unselect (since f->dev is set to NULL by changedrv())
 */
	if (f->dev) {
		(*f->dev->unselect)(f, (long)p, O_RDONLY);
		(*f->dev->unselect)(f, (long)p, O_WRONLY);
	}

	f->links--;

/* TTY manipulation must be done *before* calling the device close routine,
 * since afterwards the TTY structure may no longer exist
 */
	if (is_terminal(f) && f->links <= 0) {
		struct tty *tty = (struct tty *)f->devinfo;
		tty->use_cnt--;
		if (tty->use_cnt <= 0)
			tty->pgrp = 0;
		if (tty->use_cnt <= 0 && tty->xkey) {
			kfree(tty->xkey);
			tty->xkey = 0;
		}
	}

	if (f->dev) {
		r = (*f->dev->close)(f, p->pid);
		if (r) {
			DEBUG(("close: device close failed"));
		}
	}
	if (f->links <= 0) {
		release_cookie(&f->fc);
		dispose_fileptr(f);
	}
	return  r;
}

long
do_close(f)
	FILEPTR *f;
{
	return do_pclose(curproc, f);
}

long ARGS_ON_STACK
f_open(name, mode)
	const char *name;
	int mode;
{
	int i;
	FILEPTR *f;
	PROC *proc;

	TRACE(("Fopen(%s, %x)", name, mode));
#if O_GLOBAL
	if (mode & O_GLOBAL) {
	    /* oh, boy! user wants us to open a global handle! */
	    proc = rootproc;
	}
	else
#endif
	    proc = curproc;

	for (i = MIN_OPEN; i < MAX_OPEN; i++) {
		if (!proc->handle[i])
			goto found_for_open;
	}
	DEBUG(("Fopen(%s): process out of handles",name));
	return ENHNDL;		/* no more handles */

found_for_open:
	mode &= O_USER;		/* make sure the mode is legal */

/* note: file mode 3 is reserved for the kernel; for users, transmogrify it
 * into O_RDWR (mode 2)
 */
	if ( (mode & O_RWMODE) == O_EXEC ) {
		mode = (mode & ~O_RWMODE) | O_RDWR;
	}

	f = do_open(name, mode, 0, (XATTR *)0);


	if (!f) {
		return mint_errno;
	}
	proc->handle[i] = f;
/* default is to close non-standard files on exec */
	proc->fdflags[i] = FD_CLOEXEC;

#if O_GLOBAL
	if (proc != curproc) {
	    /* we just opened a global handle */
	    i += 100;
	}
#endif

	TRACE(("Fopen: returning %d", i));
	return i;
}

long ARGS_ON_STACK
f_create(name, attrib)
	const char *name;
	int attrib;
{
	fcookie dir;
	int i;
	FILEPTR *f;
	long r;
	PROC *proc;
	int offset = 0;
	char temp1[PATH_MAX];

	TRACE(("Fcreate(%s, %x)", name, attrib));
#if O_GLOBAL
	if (attrib & O_GLOBAL) {
		proc = rootproc;
		offset = 100;
		attrib &= ~O_GLOBAL;
	}
	else
#endif
		proc = curproc;

	for (i = MIN_OPEN; i < MAX_OPEN; i++) {
		if (!proc->handle[i])
			goto found_for_create;
	}
	DEBUG(("Fcreate(%s): process out of handles",name));
	return ENHNDL;		/* no more handles */

found_for_create:
	if (attrib == FA_LABEL) {
		r = path2cookie(name, temp1, &dir);
		if (r) return r;
		r = (*dir.fs->writelabel)(&dir, temp1);
		release_cookie(&dir);
		if (r) return r;
/*
 * just in case the caller tries to do something with this handle,
 * make it point to u:\dev\null
 */
		f = do_open("u:\\dev\\null", O_RDWR|O_CREAT|O_TRUNC, 0,
			     (XATTR *)0);
		proc->handle[i] = f;
		proc->fdflags[i] = FD_CLOEXEC;
		return i+offset;
	}
	if (attrib & (FA_LABEL|FA_DIR)) {
		DEBUG(("Fcreate(%s,%x): illegal attributes",name,attrib));
		return EACCDN;
	}

	f = do_open(name, O_RDWR|O_CREAT|O_TRUNC, attrib, (XATTR *)0);

	if (!f) {
		DEBUG(("Fcreate(%s) failed, error %d", name, mint_errno));
		return mint_errno;
	}
	proc->handle[i] = f;
	proc->fdflags[i] = FD_CLOEXEC;
	i += offset;
	TRACE(("Fcreate: returning %d", i));
	return i;
}

long ARGS_ON_STACK
f_close(fh)
	int fh;
{
	FILEPTR *f;
	long r;
	PROC *proc;

	TRACE(("Fclose: %d", fh));
#if O_GLOBAL
	if (fh >= 100) {
	    fh -= 100;
	    proc = rootproc;
	}
	else
#endif
	    proc = curproc;

	if (fh < 0 || fh >= MAX_OPEN || 0 == (f = proc->handle[fh])) {
		return EIHNDL;
	}
	r = do_pclose(proc, f);

/* standard handles should be restored to default values */
/* do this for TOS domain only! */
	if (proc->domain == DOM_TOS) {
		if (fh == 0 || fh == 1)
			f = proc->handle[-1];
		else if (fh == 2 || fh == 3)
			f = proc->handle[-fh];
		else
			f = 0;
	} else
		f = 0;

	if (f) {
		f->links++;
		proc->fdflags[fh] = 0;
	}
	proc->handle[fh] = f;
	return r;
}

long ARGS_ON_STACK
f_read(fh, count, buf)
	int fh;
	long count;
	char *buf;
{
	FILEPTR *f;

	PROC *proc;

#if O_GLOBAL
	if (fh >= 100) {
	    fh -= 100;
	    proc = rootproc;
	}
	else
#endif
	    proc = curproc;

	if (fh < MIN_HANDLE || fh >= MAX_OPEN || 0 == (f = proc->handle[fh])) {
		DEBUG(("Fread: invalid handle: %d", fh));
		return EIHNDL;
	}
	if ( (f->flags & O_RWMODE) == O_WRONLY ) {
		DEBUG(("Fread: read on a write-only handle"));
		return EACCDN;
	}
	if (is_terminal(f))
		return tty_read(f, buf, count);

	TRACELOW(("Fread: %ld bytes from handle %d to %lx", count, fh, buf));
	return (*f->dev->read)(f, buf, count);
}

long ARGS_ON_STACK
f_write(fh, count, buf)
	int fh;
	long count;
	const char *buf;
{
	FILEPTR *f;
	PROC *proc;
	long r;

#if O_GLOBAL
	if (fh >= 100) {
	    fh -= 100;
	    proc = rootproc;
	}
	else
#endif
	    proc = curproc;

	if (fh < MIN_HANDLE || fh >= MAX_OPEN || 0 == (f = proc->handle[fh])) {
		DEBUG(("Fwrite: bad handle: %d", fh));
		return EIHNDL;
	}
	if ( (f->flags & O_RWMODE) == O_RDONLY ) {
		DEBUG(("Fwrite: write on a read-only handle"));
		return EACCDN;
	}
	if (is_terminal(f))
		return tty_write(f, buf, count);

	/* it would be faster to do this in the device driver, but this
	 * way the drivers are easier to write
	 */
	if (f->flags & O_APPEND) {
		r = (*f->dev->lseek)(f, 0L, SEEK_END);
		/* ignore errors from unseekable files (e.g. pipes) */
		if (r == EACCDN)
			r = 0;
	} else
		r = 0;
	if (r >= 0) {
		TRACELOW(("Fwrite: %ld bytes to handle %d", count, fh));
		r = (*f->dev->write)(f, buf, count);
	}
	if (r < 0) {
		DEBUG(("Fwrite: error %ld", r));
	}
	return r;
}

long ARGS_ON_STACK
f_seek(place, fh, how)
	long place;
	int fh;
	int how;
{
	FILEPTR *f;
	PROC *proc;

	TRACE(("Fseek(%ld, %d) on handle %d", place, how, fh));
#if O_GLOBAL
	if (fh >= 100) {
	    fh -= 100;
	    proc = rootproc;
	}
	else
#endif
	    proc = curproc;

	if (fh < MIN_HANDLE || fh >= MAX_OPEN || 0 == (f = proc->handle[fh])) {
		DEBUG(("Fseek: bad handle: %d", fh));
		return EIHNDL;
	}
	if (is_terminal(f)) {
		return 0;
	}
	return (*f->dev->lseek)(f, place, how);
}

/* duplicate file pointer fh; returns a new file pointer >= min, if
   one exists, or ENHNDL if not. called by f_dup and f_cntl
 */

static long do_dup(fh, min)
	int fh, min;
{
	FILEPTR *f;
	int i;
	PROC *proc;

	for (i = min; i < MAX_OPEN; i++) {
		if (!curproc->handle[i])
			goto found;
	}
	return ENHNDL;		/* no more handles */
found:
#if O_GLOBAL
	if (fh >= 100) {
	    fh -= 100;
	    proc = rootproc;
	} else
#endif
	    proc = curproc;

	if (fh < MIN_HANDLE || fh >= MAX_OPEN || 0 == (f = proc->handle[fh]))
		return EIHNDL;

	curproc->handle[i] = f;

/* set default file descriptor flags */
	if (i >= 0) {
		if (i >= MIN_OPEN)
			curproc->fdflags[i] = FD_CLOEXEC;
		else
			curproc->fdflags[i] = 0;
	}
	f->links++;
	return i;
}

long ARGS_ON_STACK
f_dup(fh)
	int fh;
{
	long r;
	r = do_dup(fh, MIN_OPEN);
	TRACE(("Fdup(%d) -> %ld", fh, r));
	return r;
}

long ARGS_ON_STACK
f_force(newh, oldh)
	int newh;
	int oldh;
{
	FILEPTR *f;
	PROC *proc;

	TRACE(("Fforce(%d, %d)", newh, oldh));

#if O_GLOBAL
	if (oldh >= 100) {
	    oldh -= 100;
	    proc = rootproc;
	} else
#endif
	    proc = curproc;

	if (oldh < MIN_HANDLE || oldh >= MAX_OPEN ||
	    0 == (f = proc->handle[oldh])) {
		DEBUG(("Fforce: old handle invalid"));
		return EIHNDL;
	}

	if (newh < MIN_HANDLE || newh >= MAX_OPEN) {
		DEBUG(("Fforce: new handle out of range"));
		return EIHNDL;
	}

	(void)do_close(curproc->handle[newh]);
	curproc->handle[newh] = f;
	/* set default file descriptor flags */
	if (newh >= 0)
		curproc->fdflags[newh] = (newh >= MIN_OPEN) ? FD_CLOEXEC : 0;
	f->links++;
/*
 * special: for a tty, if this is becoming a control terminal and the
 * tty doesn't have a pgrp yet, make it have the pgrp of the process
 * doing the Fforce
 */
	if (is_terminal(f) && newh == -1) {
		struct tty *tty = (struct tty *)f->devinfo;

		if (!tty->pgrp)
			tty->pgrp = curproc->pgrp;
	}
	return 0;
}

long ARGS_ON_STACK
f_datime(timeptr, fh, rwflag)
	short *timeptr;
	int fh;
	int rwflag;
{
	FILEPTR *f;
	PROC *proc;

	TRACE(("Fdatime(%d)", fh));
#if O_GLOBAL
	if (fh >= 100) {
	    fh -= 100;
	    proc = rootproc;
	}
	else
#endif
	    proc = curproc;

	if (fh < MIN_HANDLE || fh >= MAX_OPEN || 0 == (f = proc->handle[fh])) {
		DEBUG(("Fdatime: invalid handle"));
		return EIHNDL;
	}

/* some programs use Fdatime to test for TTY devices */
	if (is_terminal(f))
		return EACCDN;

	return (*f->dev->datime)(f, timeptr, rwflag);
}

long ARGS_ON_STACK
f_lock(fh, mode, start, length)
	int fh, mode;
	long start, length;
{
	FILEPTR *f;
	struct flock lock;
	PROC *proc;

#if O_GLOBAL
	if (fh >= 100) {
	    fh -= 100;
	    proc = rootproc;
	}
	else
#endif
	    proc = curproc;

	if (fh < MIN_HANDLE || fh >= MAX_OPEN || 0 == (f = proc->handle[fh])) {
		DEBUG(("Flock: invalid handle"));
		return EIHNDL;
	}
	TRACE(("Flock(%d,%d,%ld,%ld)", fh, mode, start, length));
	lock.l_whence = SEEK_SET;
	lock.l_start = start;
	lock.l_len = length;

	if (mode == 0)		/* create a lock */
		lock.l_type = F_WRLCK;
	else if (mode == 1)	/* unlock region */
		lock.l_type = F_UNLCK;
	else
		return EINVFN;

	return (*f->dev->ioctl)(f, F_SETLK, &lock);
}

/*
 * extensions to GEMDOS:
 */

/*
 * Fpipe(int *handles): opens a pipe. if successful, returns 0, and
 * sets handles[0] to a file descriptor for the read end of the pipe
 * and handles[1] to one for the write end.
 */

long ARGS_ON_STACK
f_pipe(usrh)
	short *usrh;
{
	FILEPTR *in, *out;
	static int pipeno = 0;
	int i, j;
	char pipename[32]; /* MAGIC: 32 >= strlen "u:\pipe\sys$pipe.000\0" */

	TRACE(("Fpipe"));

/* BUG: more than 999 open pipes hangs the system */
	do {
		ksprintf(pipename, "u:\\pipe\\sys$pipe.%03d", pipeno);
		pipeno++; if (pipeno > 999) pipeno = 0;
		out = do_open(pipename, O_WRONLY|O_CREAT|O_EXCL, FA_RDONLY|FA_HIDDEN|FA_CHANGED,
				 (XATTR *)0);
			/* read-only attribute means unidirectional fifo */
			/* hidden attribute means check for broken pipes */
			/* changed attribute means act like Unix fifos */
	} while (out == 0 && mint_errno == EACCDN);

	if (!out) {
		DEBUG(("Fpipe: error %d", mint_errno));
		return mint_errno;
	}

	in = do_open(pipename, O_RDONLY, 0, (XATTR *)0);
	if (!in) {
		DEBUG(("Fpipe: in side of pipe not opened (error %d)",
			mint_errno));
		(void)do_close(out);
		return mint_errno;
	}

	for (i = MIN_OPEN; i < MAX_OPEN; i++) {
		if (curproc->handle[i] == 0)
			break;
	}

	for (j = i+1; j < MAX_OPEN; j++) {
		if (curproc->handle[j] == 0)
			break;
	}

	if (j >= MAX_OPEN) {
		DEBUG(("Fpipe: not enough handles left"));
		(void) do_close(in);
		(void) do_close(out);
		return ENHNDL;
	}
	curproc->handle[i] = in; curproc->handle[j] = out;
/* leave pipes open across Pexec */
	curproc->fdflags[i] = 0;
	curproc->fdflags[j] = 0;

	usrh[0] = i;
	usrh[1] = j;
	TRACE(("Fpipe: returning 0: input %d output %d",i,j));
	return 0;
}

/*
 * f_cntl: a combination "ioctl" and "fcntl". Some functions are
 * handled here, if they apply to the file descriptors directly
 * (e.g. F_DUPFD) or if they're easily translated into file system
 * functions (e.g. FSTAT). Others are passed on to the device driver
 * via dev->ioctl.
 */

long ARGS_ON_STACK
f_cntl(fh, arg, cmd)
	int fh;
	long arg;
	int cmd;
{
	FILEPTR	*f;
	PROC *proc;
	struct flock *fl;
	long r;

	TRACE(("Fcntl(%d, cmd=0x%x)", fh, cmd));
#if O_GLOBAL
	if (fh >= 100) {
	    fh -= 100;
	    proc = rootproc;
	}
	else
#endif
	    proc = curproc;

	if (fh < MIN_HANDLE || fh >= MAX_OPEN) {
		DEBUG(("Fcntl: bad file handle"));
		return EIHNDL;
	}

	if (cmd == F_DUPFD) {
#if O_GLOBAL
		if (proc != curproc) fh += 100;
#endif
  		return do_dup(fh, (int)arg);
	}

	f = proc->handle[fh];
	if (!f) return EIHNDL;

	switch(cmd) {
	case F_GETFD:
		TRACE(("Fcntl F_GETFD"));
		if (fh < 0) return EIHNDL;
		return proc->fdflags[fh];
	case F_SETFD:
		TRACE(("Fcntl F_SETFD"));
		if (fh < 0) return EIHNDL;
		proc->fdflags[fh] = arg;
		return 0;
	case F_GETFL:
		TRACE(("Fcntl F_GETFL"));
		return f->flags & O_USER;
	case F_SETFL:
		TRACE(("Fcntl F_SETFL"));
		arg &= O_USER;		/* make sure only user bits set */
#if 0
	/* COMPATIBILITY WITH OLD VERSIONS ONLY */
	/* THIS CODE WILL GO AWAY. REALLY! */
		if (arg & 4) {
			arg |= O_NDELAY;
			arg &= ~4;
		}
#endif

	/* make sure the file access and sharing modes are not changed */
		arg &= ~(O_RWMODE|O_SHMODE);
		arg |= f->flags & (O_RWMODE|O_SHMODE);
		f->flags &= ~O_USER;	/* set user bits to arg */
		f->flags |= arg;
		return 0;
	case FSTAT:
		return (*f->fc.fs->getxattr)(&f->fc, (XATTR *)arg);
	case F_SETLK:
	case F_SETLKW:
	/* make sure that the file was opened with appropriate permissions */
		fl = (struct flock *)arg;
		if (fl->l_type == F_RDLCK) {
			if ( (f->flags & O_RWMODE) == O_WRONLY )
				return EACCDN;
		} else {
			if ( (f->flags & O_RWMODE) == O_RDONLY )
				return EACCDN;
		}
		/* fall through to device ioctl */
	default:
		TRACE(("Fcntl mode %x: calling ioctl",cmd));
		r = (*f->dev->ioctl)(f, cmd, (void *)arg);
		if (r == EINVFN && is_terminal(f)) {
			r = tty_ioctl(f, cmd, (void *)arg);
		}
		return r;
	}
}

/*
 * fselect(timeout, rfd, wfd, xfd)
 * timeout is an (unsigned) 16 bit integer giving the maximum number
 * of milliseconds to wait; rfd, wfd, and xfd are pointers to 32 bit
 * integers containing bitmasks that describe which file descriptors
 * we're interested in. These masks are changed to represent which
 * file descriptors actually have data waiting (rfd), are ready to
 * output (wfd), or have exceptional conditions (xfd -- currently
 * ignored). If timeout is 0, fselect blocks until some file descriptor
 * is ready; otherwise, it waits only "timeout" milliseconds.
 * Return value: number of file descriptors that are available for
 * reading/writing; or a negative error number.
 */

/* helper function for time outs */
static void
unselectme(p)
	PROC *p;
{
	wakeselect((long)p);
}

long ARGS_ON_STACK
f_select(timeout, rfdp, wfdp, xfdp)
	unsigned timeout;
	long *rfdp, *wfdp, *xfdp;
{
	long rfd, wfd;
	long mask, bytes;
	int i, count;
	FILEPTR *f;
	PROC *p;
	TIMEOUT *t;
	short sr;

	if (xfdp)
		*xfdp = 0;

	if (rfdp) {
		rfd = *rfdp; *rfdp = 0;
	}
	else
		rfd = 0;
	if (wfdp) {
		wfd = *wfdp; *wfdp = 0;
	}
	else
		wfd = 0;

	TRACE(("Fselect(%u, %lx, %lx)", timeout, rfd, wfd));
	p = curproc;			/* help the optimizer out */

	/* first, validate the masks */
	mask = 1L;
	for (i = 0; i < MAX_OPEN; i++) {
		if ( ((rfd & mask) || (wfd & mask)) && !(p->handle[i]) ) {
			DEBUG(("Fselect: invalid handle: %d", i));
			return EIHNDL;
		}
		mask = mask << 1L;
	}

/* now, loop through the file descriptors, setting up the select process */
/* NOTE: wakeselect will set p->wait_cond to 0 if data arrives during the
 * selection
 * Also note: because of the validation above, we may assume that the
 * file handles are valid here. However, this assumption may no longer
 * be true after we've gone to sleep, since a signal handler may have
 * closed one of the handles.
 */

	mask = 1L;
	count = 0;
	curproc->wait_cond = (long)wakeselect;		/* flag */

	for (i = 0; i < MAX_OPEN; i++) {
		if (rfd & mask) {
			f = p->handle[i];
			if ((*f->dev->select)(f, (long)p, O_RDONLY)) {
				count++;
				*rfdp |= mask;
			}
		}
		if (wfd & mask) {
			f = p->handle[i];
			if ((*f->dev->select)(f, (long)p, O_WRONLY)) {
				count++;
				*wfdp |= mask;
			}
		}
		mask = mask << 1L;
	}

	if (count == 0) {
		/* OK, now let's set a timeout */

		if (timeout) {
			t = addtimeout((long)timeout, unselectme);
		} else {
			t = 0;
		}

		sr = spl7();

	/* curproc->wait_cond changes when data arrives or the timeout happens */
		while (curproc->wait_cond == (long)wakeselect) {
			TRACE(("sleeping in Fselect"));
			sleep(SELECT_Q, (long)wakeselect);
		}
		spl(sr);

	/* we can cancel the time out now (if it hasn't already happened) */
		if (t) canceltimeout(t);

	/* OK, let's see what data arrived (if any) */
		mask = 1L;
		for (i = 0; i < MAX_OPEN; i++) {
			if (rfd & mask) {
				f = p->handle[i];
				if (f) {
				    bytes = 1L;
				    (void)(*f->dev->ioctl)(f, FIONREAD,&bytes);
				    if (bytes > 0) {
					*rfdp |= mask;
					count++;
				    }
				}
			}
			if (wfd & mask) {
				f = p->handle[i];
				if (f) {
				    bytes = 1L;
				    (void)(*f->dev->ioctl)(f, FIONWRITE,&bytes);
				    if (bytes > 0) {
					*wfdp |= mask;
					count++;
				    }
				}
			}
			mask = mask << 1L;
		}
	}

	/* at this point, we either have data or a time out */
	/* cancel all the selects */
	mask = 1L;

	for (i = 0; i < MAX_OPEN; i++) {
		if (rfd & mask) {
			f = p->handle[i];
			if (f)
				(*f->dev->unselect)(f, (long)p, O_RDONLY);
		}
		if (wfd & mask) {
			f = p->handle[i];
			if (f)
				(*f->dev->unselect)(f, (long)p, O_WRONLY);
		}
		mask = mask << 1L;
	}

	TRACE(("Fselect: returning %d", count));
	return count;
}


/*
 * GEMDOS extension: Fmidipipe
 * Fmidipipe(pid, in, out) manipultes the MIDI file handles (handles -4 and -5)
 * of process "pid" so that they now point to the files with handles "in" and
 * "out" in the calling process
 */

long ARGS_ON_STACK
f_midipipe(pid, in, out)
	int pid, in, out;
{
	PROC *p;
	FILEPTR *fin, *fout;

/* first, find the process */

	if (pid == 0)
		p = curproc;
	else {
		p = pid2proc(pid);
		if (!p)
			return EFILNF;
	}
 
/* next, validate the input and output file handles */
	if (in < MIN_HANDLE || in >= MAX_OPEN || (0==(fin = curproc->handle[in])))
		return EIHNDL;
	if ( (fin->flags & O_RWMODE) == O_WRONLY ) {
		DEBUG(("Fmidipipe: input side is write only"));
		return EACCDN;
	}
	if (out < MIN_HANDLE || out >= MAX_OPEN || (0==(fout = curproc->handle[out])))
		return EIHNDL;
	if ( (fout->flags & O_RWMODE) == O_RDONLY ) {
		DEBUG(("Fmidipipe: output side is read only"));
		return EACCDN;
	}

/* OK, duplicate the handles and put them in the new process */
	fin->links++; fout->links++;
	(void)do_pclose(p, p->midiin);
	(void)do_pclose(p, p->midiout);
	p->midiin = fin; p->midiout = fout;
	return 0;
}
