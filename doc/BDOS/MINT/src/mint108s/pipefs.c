/*
Copyright 1991,1992 Eric R. Smith.
Copyright 1992 Atari Corporation.
All rights reserved.
 */

/* simple pipefs.c */

#include "mint.h"

static int pipetime, pipedate;	/* root directory time/date stamp */

static long	ARGS_ON_STACK pipe_root	P_((int drv, fcookie *fc));
static long	ARGS_ON_STACK pipe_lookup	P_((fcookie *dir, const char *name, fcookie *fc));
static long	ARGS_ON_STACK pipe_getxattr	P_((fcookie *file, XATTR *xattr));
static long	ARGS_ON_STACK pipe_chattr	P_((fcookie *file, int attrib));
static long	ARGS_ON_STACK pipe_chown	P_((fcookie *file, int uid, int gid));
static long	ARGS_ON_STACK pipe_chmode	P_((fcookie *file, unsigned mode));
static long	ARGS_ON_STACK pipe_rmdir	P_((fcookie *dir, const char *name));
static long	ARGS_ON_STACK pipe_remove	P_((fcookie *dir, const char *name));
static long	ARGS_ON_STACK pipe_getname	P_((fcookie *root, fcookie *dir,
						    char *pathname, int size));
static long	ARGS_ON_STACK pipe_rename	P_((fcookie *olddir, char *oldname,
				    fcookie *newdir, const char *newname));
static long	ARGS_ON_STACK pipe_opendir	P_((DIR *dirh, int flags));
static long	ARGS_ON_STACK pipe_readdir	P_((DIR *dirh, char *nm, int nmlen, fcookie *));
static long	ARGS_ON_STACK pipe_rewinddir	P_((DIR *dirh));
static long	ARGS_ON_STACK pipe_closedir	P_((DIR *dirh));
static long	ARGS_ON_STACK pipe_pathconf	P_((fcookie *dir, int which));
static long	ARGS_ON_STACK pipe_dfree	P_((fcookie *dir, long *buf));
static long	ARGS_ON_STACK pipe_creat	P_((fcookie *dir, const char *name, unsigned mode,
					int attrib, fcookie *fc));
static DEVDRV *	ARGS_ON_STACK pipe_getdev	P_((fcookie *fc, long *devsp));

static long	ARGS_ON_STACK pipe_open	P_((FILEPTR *f));
static long	ARGS_ON_STACK pipe_write	P_((FILEPTR *f, const char *buf, long bytes));
static long	ARGS_ON_STACK pipe_read	P_((FILEPTR *f, char *buf, long bytes));
static long	ARGS_ON_STACK pipe_lseek	P_((FILEPTR *f, long where, int whence));
static long	ARGS_ON_STACK pipe_ioctl	P_((FILEPTR *f, int mode, void *buf));
static long	ARGS_ON_STACK pipe_datime	P_((FILEPTR *f, short *time, int rwflag));
static long	ARGS_ON_STACK pipe_close	P_((FILEPTR *f, int pid));
static long	ARGS_ON_STACK pipe_select	P_((FILEPTR *f, long p, int mode));
static void	ARGS_ON_STACK pipe_unselect	P_((FILEPTR *f, long p, int mode));

DEVDRV pipe_device = {
	pipe_open, pipe_write, pipe_read, pipe_lseek, pipe_ioctl, pipe_datime,
	pipe_close, pipe_select, pipe_unselect
};

/* ptys and pipes can share the same driver, for now */
#define pty_device pipe_device

FILESYS pipe_filesys = {
	(FILESYS *)0,
	0,
	pipe_root,
	pipe_lookup, pipe_creat, pipe_getdev, pipe_getxattr,
	pipe_chattr, pipe_chown, pipe_chmode,
	nomkdir, pipe_rmdir, pipe_remove, pipe_getname, pipe_rename,
	pipe_opendir, pipe_readdir, pipe_rewinddir, pipe_closedir,
	pipe_pathconf, pipe_dfree,
	nowritelabel, noreadlabel, nosymlink, noreadlink,
	nohardlink, nofscntl, nodskchng
};

/* size of pipes */
#define PIPESIZ	4096		/* MUST be a multiple of 4 */

/* writes smaller than this are atomic */
#define PIPE_BUF 1024		/* should be a multiple of 4 */

/* magic flag: indicates that nobody but the creator has opened this pipe */
/* note: if this many processes open the pipe, we lose :-( */
#define VIRGIN_PIPE	0x7fff

struct pipe {
	int	readers;	/* number of readers of this pipe */
	int	writers;	/* number of writers of this pipe */
	int	head, tail;	/* pipe head, tail (head == tail for empty) */
	long	rsel;		/* process that did select() for reads */
	long	wsel;		/* process that did select() for writes */
	char	buf[PIPESIZ];	/* pipe data */
};

struct fifo {
	char	name[NAME_MAX+1]; /* FIFO's name */
	short	date, time;	/* date & time of last write */
	short	dosflags;	/* DOS flags, e.g. FA_RDONLY, FA_HIDDEN */
	ushort	mode;		/* file access mode, for XATTR */
	ushort	uid, gid;	/* file owner; uid and gid */
	short	flags;		/* various other flags (e.g. O_TTY) */
	short	lockpid;	/* pid of locking process */
	short	cursrate;	/* cursor flash rate for pseudo TTY's */
	struct tty *tty;	/* tty struct for pseudo TTY's */
	struct pipe *inp;	/* pipe for reads */
	struct pipe *outp;	/* pipe for writes (0 if unidirectional) */
	struct fifo *next;	/* link to next FIFO in list */
	FILEPTR *open;		/* open file pointers for this fifo */
} *rootlist;


static long ARGS_ON_STACK 
pipe_root(drv, fc)
	int drv;
	fcookie *fc;
{
	if (drv == PIPEDRV) {
		fc->fs = &pipe_filesys;
		fc->dev = drv;
		fc->index = 0L;
		return 0;
	}
	fc->fs = 0;
	return EINTRN;
}

static long ARGS_ON_STACK 
pipe_lookup(dir, name, fc)
	fcookie *dir;
	const char *name;
	fcookie *fc;
{
	struct fifo *b;

	TRACE(("pipe_lookup(%s)", name));

	if (dir->index != 0) {
		DEBUG(("pipe_lookup(%s): bad directory", name));
		return EPTHNF;
	}
/* special case: an empty name in a directory means that directory */
/* so does "." */
	if (!*name || (name[0] == '.' && name[1] == 0)) {
		*fc = *dir;
		return 0;
	}

/* another special case: ".." could be a mount point */
	if (!strcmp(name, "..")) {
		*fc = *dir;
		return EMOUNT;
	}

	for (b = rootlist; b; b = b->next) {
		if (!strnicmp(b->name, name, NAME_MAX)) {
			fc->fs = &pipe_filesys;
			fc->index = (long)b;
			fc->dev = dir->dev;
			return 0;
		}
	}
	DEBUG(("pipe_lookup: name `%s' not found", name));
	return EFILNF;
}

static long ARGS_ON_STACK 
pipe_getxattr(fc, xattr)
	fcookie *fc;
	XATTR *xattr;
{
	struct fifo *this;

	xattr->index = fc->index;
	xattr->dev = fc->dev;
	xattr->nlink = 1;
	xattr->blksize = 1;

	if (fc->index == 0) {		/* root directory? */
		xattr->uid = xattr->gid = 0;
		xattr->mtime = xattr->atime = xattr->ctime = pipetime;
		xattr->mdate = xattr->adate = xattr->cdate = pipedate;
		xattr->mode = S_IFDIR | DEFAULT_DIRMODE;
		xattr->attr = FA_DIR;
		xattr->size = xattr->nblocks = 0;
	} else {
		this = (struct fifo *)fc->index;
		xattr->uid = this->uid;
		xattr->gid = this->gid;
		xattr->mtime = xattr->atime = xattr->ctime = this->time;
		xattr->mdate = xattr->adate = xattr->cdate = this->date;
		xattr->mode = this->mode;
		xattr->attr = this->dosflags;
	/* note: fifo's that haven't been opened yet can be written to */
		if (this->flags & O_HEAD) {
			xattr->attr &= ~FA_RDONLY;
		}

		xattr->nblocks = PIPESIZ;
		if (this->dosflags & FA_SYSTEM) {	/* pseudo-tty */
			xattr->size = PIPESIZ/4;
		} else {
			xattr->size = PIPESIZ;
		}
	}
	return 0;
}

static long ARGS_ON_STACK 
pipe_chattr(fc, attrib)
	fcookie *fc;
	int attrib;
{
	UNUSED(fc); UNUSED(attrib);
	return EACCDN;
}

static long ARGS_ON_STACK 
pipe_chown(fc, uid, gid)
	fcookie *fc;
	int uid, gid;
{
	struct fifo *this;

	if ((this = (struct fifo *)fc->index) == 0)
		return EACCDN;

	this->uid = uid;
	this->gid = gid;
	return 0;
}

static long ARGS_ON_STACK 
pipe_chmode(fc, mode)
	fcookie *fc;
	unsigned mode;
{
	struct fifo *this;

	if ((this = (struct fifo *)fc->index) == 0)
		return EACCDN;

	this->mode = (this->mode & S_IFMT) | (mode & ~S_IFMT);
	return 0;
}

static long ARGS_ON_STACK 
pipe_rmdir(dir, name)
	fcookie *dir;
	const char *name;
{
	UNUSED(dir); UNUSED(name);

/* the kernel already checked to see if the file exists */
	return EACCDN;
}

static long ARGS_ON_STACK 
pipe_remove(dir, name)
	fcookie *dir;
	const char *name;
{
	UNUSED(dir); UNUSED(name);

/* the kernel already checked to see if the file exists */
	return EACCDN;
}

static long ARGS_ON_STACK 
pipe_getname(root, dir, pathname, size)
	fcookie *root, *dir; char *pathname;
	int size;
{
	UNUSED(root);
	UNUSED(size);	/* BUG: we should support 'size' */

	if (dir->index == 0)
		*pathname = 0;
	else
		strcpy(pathname, ((struct fifo *)dir->index)->name);
	return 0;
}

static long ARGS_ON_STACK 
pipe_rename(olddir, oldname, newdir, newname)
	fcookie *olddir;
	char *oldname;
	fcookie *newdir;
	const char *newname;
{
	UNUSED(olddir); UNUSED(oldname);
	UNUSED(newdir); UNUSED(newname);

	return EACCDN;
}

static long ARGS_ON_STACK 
pipe_opendir(dirh, flags)
	DIR *dirh;
	int flags;
{
	UNUSED(flags);

	if (dirh->fc.index != 0) {
		DEBUG(("pipe_opendir: bad directory"));
		return EPTHNF;
	}
	dirh->index = 0;
	return 0;
}

static long ARGS_ON_STACK 
pipe_readdir(dirh, name, namelen, fc)
	DIR *dirh;
	char *name;
	int namelen;
	fcookie *fc;
{
	struct fifo *this;
	int i;
	int giveindex = dirh->flags == 0;

	i = dirh->index++;
	this = rootlist;
	while (i > 0 && this) {
		--i; this = this->next;
	}
	if (!this)
		return ENMFIL;

	fc->fs = &pipe_filesys;
	fc->index = (long)this;
	fc->dev = dirh->fc.dev;
	if (giveindex) {
		namelen -= (int) sizeof(long);
		if (namelen <= 0) return ERANGE;
		*((long *)name) = (long)this;
		name += sizeof(long);
	}
	strncpy(name, this->name, namelen-1);
	if (strlen(this->name) >= namelen)
		return ENAMETOOLONG;
	return 0;
}

static long ARGS_ON_STACK 
pipe_rewinddir(dirh)
	DIR *dirh;
{
	dirh->index = 0;
	return 0;
}

static long ARGS_ON_STACK 
pipe_closedir(dirh)
	DIR *dirh;
{
	UNUSED(dirh);
	return 0;
}

static long ARGS_ON_STACK 
pipe_pathconf(dir, which)
	fcookie *dir;
	int which;
{
	UNUSED(dir);

	switch(which) {
	case -1:
		return DP_MAXREQ;
	case DP_IOPEN:
		return UNLIMITED;	/* no internal limit on open files */
	case DP_MAXLINKS:
		return 1;		/* no hard links */
	case DP_PATHMAX:
		return PATH_MAX;
	case DP_NAMEMAX:
		return NAME_MAX;
	case DP_ATOMIC:
	/* BUG: for pty's, this should actually be PIPE_BUF/4 */
		return PIPE_BUF;
	case DP_TRUNC:
		return DP_AUTOTRUNC;
	case DP_CASE:
		return DP_CASEINSENS;
	default:
		return EINVFN;
	}
}

static long ARGS_ON_STACK 
pipe_dfree(dir, buf)
	fcookie *dir;
	long *buf;
{
	int i;
	struct fifo *b;
	long freemem;

	UNUSED(dir);

/* the "sector" size is the number of bytes per pipe */
/* so we get the total number of sectors used by counting pipes */

	i = 0;
	for (b = rootlist; b; b = b->next) {
		if (b->inp) i++;
		if (b->outp) i++;
	}

	freemem = tot_rsize(core, 0) + tot_rsize(alt, 0);

/* note: the "free clusters" isn't quite accurate, since there's overhead
 * in the fifo structure; but we're not looking for 100% accuracy here
 */
	buf[0] = freemem/PIPESIZ;	/* number of free clusters */
	buf[1] = buf[0]+i;		/* total number of clusters */
	buf[2] = PIPESIZ;		/* sector size (bytes) */
	buf[3] = 1;			/* cluster size (sectors) */
	return 0;
}

/* create a new pipe.
 * this only gets called by the kernel if a lookup already failed,
 * so we know that the new pipe creation is OK
 */

static long ARGS_ON_STACK 
pipe_creat(dir, name, mode, attrib, fc)
	fcookie *dir;
	const char *name;
	unsigned mode;
	int attrib;
	fcookie *fc;
{
	struct pipe *inp, *outp;
	struct tty *tty;
	struct fifo *b;
/* selfread == 1 if we want reads to wait even if no other processes
   have currently opened the file, and writes to succeed in the same
   event. This is useful for servers who want to wait for requests.
   Pipes should always have selfread == 0.
*/
	int selfread = (attrib & FA_HIDDEN) ? 0 : 1;


	/* create the new pipe */
	if (0 == (inp = (struct pipe *)kmalloc(SIZEOF(struct pipe)))) {
		return ENSMEM;
	}
	if (attrib & FA_RDONLY) {	/* read only FIFOs are unidirectional */
		outp = 0;
	} else {
		outp = (struct pipe *)kmalloc(SIZEOF(struct pipe));
		if (!outp) {
			kfree(inp);
			return ENSMEM;
		}
	}
	b = (struct fifo *)kmalloc(SIZEOF(struct fifo));
	if (!b) {
		kfree(inp);
		if (outp) kfree(outp);
		return ENSMEM;
	}
	if (attrib & FA_SYSTEM) {	/* pseudo-tty */
		tty = (struct tty *)kmalloc(SIZEOF(struct tty));
		if (!tty) {
			kfree(inp);
			kfree(b);
			if (outp) kfree(outp);
			return ENSMEM;
		}
		tty->use_cnt = 0;
		    /* do_open does the rest of tty initialization */
	} else tty = 0;

/* set up the pipes appropriately */
	inp->head = inp->tail = 0;
	inp->readers = selfread ? 1 : VIRGIN_PIPE; inp->writers = 1;
	inp->rsel = inp->wsel = 0;
	if (outp) {
		outp->head = outp->tail = 0;
		outp->readers = 1; outp->writers = selfread ? 1 : VIRGIN_PIPE;
		outp->wsel = outp->rsel = 0;
	}
	strncpy(b->name, name, NAME_MAX);
	b->time = timestamp;
	b->date = datestamp;
	b->dosflags = attrib;
	b->mode = ((attrib & FA_SYSTEM) ? S_IFCHR : S_IFIFO) | mode;
	b->uid = curproc->ruid;
	b->gid = curproc->rgid;

/* the O_HEAD flag indicates that the file hasn't actually been opened
 * yet; the next open gets to be the pty master. pipe_open will
 * clear the flag when this happens.
 */
	b->flags = ((attrib & FA_SYSTEM) ? O_TTY : 0) | O_HEAD;
	b->inp = inp; b->outp = outp; b->tty = tty;

	b->next = rootlist;
	b->open = (FILEPTR *)0;
	rootlist = b;

/* we have to return a file cookie as well */
	fc->fs = &pipe_filesys;
	fc->index = (long)b;
	fc->dev = dir->dev;

/* update time/date stamps for u:\pipe */
	pipetime = timestamp;
	pipedate = datestamp;

	return 0;
}

static DEVDRV * ARGS_ON_STACK 
pipe_getdev(fc, devsp)
	fcookie *fc;
	long *devsp;
{
	struct fifo *b = (struct fifo *)fc->index;

	UNUSED(devsp);
	return (b->flags & O_TTY) ? &pty_device : &pipe_device;
}

/*
 * PIPE device driver
 */

static long ARGS_ON_STACK 
pipe_open(f)
	FILEPTR *f;
{
	struct fifo *p;
	int rwmode = f->flags & O_RWMODE;

	p = (struct fifo *)f->fc.index;
	f->flags |= p->flags;
/*
 * if this is the first open for this file, then the O_HEAD flag is
 * set in p->flags. If not, and someone was trying to create the file,
 * return an error
 */
	if (p->flags & O_HEAD) {
		if (!(f->flags & O_CREAT)) {
			DEBUG(("pipe_open: file hasn't been created yet"));
			return EINTRN;
		}
		p->flags &= ~O_HEAD;
	} else {
		if (f->flags & O_CREAT) {
			DEBUG(("pipe_open: fifo already exists"));
			return EACCDN;
		}
	}
/*
 * check for file sharing compatibility. note that O_COMPAT gets mutated
 * into O_DENYNONE, because any old programs that know about pipes will
 * already handle multitasking correctly
 */
	if ( (f->flags & O_SHMODE) == O_COMPAT ) {
		f->flags = (f->flags & ~O_SHMODE) | O_DENYNONE;
	}
	if (denyshare(p->open, f))
		return EACCDN;
	f->next = p->open;		/* add this open fileptr to the list */
	p->open = f;

/*
 * add readers/writers to the list
 */
	if (!(f->flags & O_HEAD)) {
		if (rwmode == O_RDONLY || rwmode == O_RDWR) {
			if (p->inp->readers == VIRGIN_PIPE)
				p->inp->readers = 1;
			else
				p->inp->readers++;
		}
		if ((rwmode == O_WRONLY || rwmode == O_RDWR) && p->outp) {
			if (p->outp->writers == VIRGIN_PIPE)
				p->outp->writers = 1;
			else
				p->outp->writers++;
		}
	}

/* TTY devices need a tty structure in f->devinfo */
	f->devinfo = (long)p->tty;

	return 0;
}

static long ARGS_ON_STACK 
pipe_write(f, buf, nbytes)
	FILEPTR *f; const char *buf; long nbytes;
{
	int ptail, phead, j;
	char *pbuf;
	struct pipe *p;
	struct fifo *this;
	long bytes_written = 0;
	long r;

	this = (struct fifo *)f->fc.index;
	p = (f->flags & O_HEAD) ? this->inp : this->outp;
	if (!p) {
		DEBUG(("pipe_write: write on wrong end of pipe"));
		return EACCDN;
	}

	if (nbytes > 0 && nbytes <= PIPE_BUF) {
check_atomicity:
		r = p->tail - p->head;
		if (r < 0) r += PIPESIZ;
		r = (PIPESIZ-1) - r; /* r is the number of bytes we can write */
		if (r < nbytes) {
	/* check for broken pipes */
			if (p->readers == 0 || p->readers == VIRGIN_PIPE) {
				check_sigs();
				DEBUG(("pipe_write: broken pipe"));
				raise(SIGPIPE);
				return EPIPE;
			}
/* wake up any readers, and wait for them to gobble some data */
			if (p->rsel) {
				wakeselect(p->rsel);
				p->rsel = 0;
			}
			wake(IO_Q, (long)p);
			sleep(IO_Q, (long)p);
			goto check_atomicity;
		}
	}

	while (nbytes > 0) {
		ptail = p->tail; phead = p->head;
		j = ptail+1;
		if (j >= PIPESIZ) j = 0;
		if (j != phead) {
			pbuf = &p->buf[ptail];
			do {
				*pbuf++ = *buf++;
				nbytes--; bytes_written++;
				if ( (ptail = j) == 0 )
					pbuf = &p->buf[0];
				j++;
				if (j >= PIPESIZ) j = 0;
			} while ( (nbytes > 0) && (j != phead) );
			p->tail = ptail;
		} else {		/* pipe full */
			if (p->readers == 0 || p->readers == VIRGIN_PIPE) {
			/* maybe some other signal is waiting for us? */
				check_sigs();
				DEBUG(("pipe_write: broken pipe"));
				raise(SIGPIPE);
				return EPIPE;
			}
			if (f->flags & O_NDELAY) {
				break;
			}
	/* is someone select()ing the other end of the pipe for reading? */
			if (p->rsel) {
				wakeselect(p->rsel);
				p->rsel = 0;
			}
			wake(IO_Q, (long)p);	/* readers may continue */
DEBUG(("pipe_write: sleep on %lx", p));
			sleep(IO_Q, (long)p);
		}
	}
	this->time = timestamp;
	this->date = datestamp;
	if (bytes_written > 0) {
		if (p->rsel) {
			wakeselect(p->rsel);
			p->rsel = 0;
		}
		wake(IO_Q, (long)p);	/* maybe someone wants this data */
	}

	return bytes_written;
}

static long ARGS_ON_STACK 
pipe_read(f, buf, nbytes)
	FILEPTR *f; char *buf; long nbytes;
{
	int phead, ptail;
	struct fifo *this;
	struct pipe *p;
	long bytes_read = 0;
	char *pbuf;

	this = (struct fifo *)f->fc.index;
	p = (f->flags & O_HEAD) ? this->outp : this->inp;
	if (!p) {
		DEBUG(("pipe_read: read on the wrong end of a pipe"));
		return EACCDN;
	}

	while (nbytes > 0) {
		phead = p->head; ptail = p->tail;
		if (ptail != phead) {
			pbuf = &p->buf[phead];
			do {
				*buf++ = *pbuf++;
				nbytes--; bytes_read++;
				phead++;
				if (phead >= PIPESIZ) {
					phead = 0;
					pbuf = &p->buf[phead];
				}
			} while ( (nbytes > 0) && (phead != ptail) );
			p->head = phead;
		}
		else if (p->writers <= 0 || p->writers == VIRGIN_PIPE) {
			TRACE(("pipe_read: no more writers"));
			break;
		}
		else if ((f->flags & O_NDELAY) ||
			   ((this->dosflags & FA_CHANGED) && bytes_read > 0) )
		{
			break;
		}
		else {
	/* is someone select()ing the other end of the pipe for writing? */
			if (p->wsel) {
				wakeselect(p->wsel);
				p->wsel = 0;
			}
			wake(IO_Q, (long)p);	/* writers may continue */
			sleep(IO_Q, (long)p);
		}
	}
	if (bytes_read > 0) {
		if (p->wsel) {
			wakeselect(p->wsel);
			p->wsel = 0;
		}
		wake(IO_Q, (long)p);	/* wake writers */
	}
	return bytes_read;
}

static long ARGS_ON_STACK 
pipe_ioctl(f, mode, buf)
	FILEPTR *f; int mode; void *buf;
{
	struct pipe *p;
	struct fifo *this;
	struct flock *lck;

	long r;

	this = (struct fifo *)f->fc.index;

	if (mode == FIONREAD) {
			p = (f->flags & O_HEAD) ? this->outp : this->inp;
			assert(p != 0);
			if (p->writers <= 0 || p->writers == VIRGIN_PIPE) {
				DEBUG(("pipe FIONREAD: no writers"));
				r = -1;
			} else {
				r = p->tail - p->head;
				if (r < 0) r += PIPESIZ;
				if (is_terminal(f))
					r = r >> 2;	/* r /= 4 */
			}
			*((long *) buf) = r;
	}
	else if (mode == FIONWRITE) {
			p = (f->flags & O_HEAD) ? this->inp : this->outp;
			assert(p != 0);
			if (p->readers <= 0) {
				r = -1;
			} else {
				r = p->tail - p->head;
				if (r < 0) r += PIPESIZ;
				r = (PIPESIZ-1) - r;
				if (is_terminal(f))
					r = r >> 2;	/* r /= 4 */
			}
			*((long *) buf) = r;
	}
	else if (mode == F_SETLK || mode == F_SETLKW) {
		lck = (struct flock *)buf;
		while (this->flags & O_LOCK) {
			if (this->lockpid != curproc->pid) {
				DEBUG(("pipe_ioctl: pipe already locked"));
				if (mode == F_SETLKW && lck->l_type != F_UNLCK) {
					sleep(IO_Q, (long)this);		/* sleep a while */
				}
				else
					return ELOCKED;
			} else
				break;
		}
		if (lck->l_type == F_UNLCK) {
			if (!(f->flags & O_LOCK)) {
				DEBUG(("pipe_ioctl: wrong file descriptor for UNLCK"));
				return ENSLOCK;
			}
			this->flags &= ~O_LOCK;
			this->lockpid = 0;
			f->flags &= ~O_LOCK;
			wake(IO_Q, (long)this);	/* wake up anyone waiting on the lock */
		}
		else {
			this->flags |= O_LOCK;
			this->lockpid = curproc->pid;
			f->flags |= O_LOCK;
		}
	}
	else if (mode == F_GETLK) {
		lck = (struct flock *)buf;
		if (this->flags & O_LOCK) {
			lck->l_type = F_WRLCK;
			lck->l_start = lck->l_len = 0;
			lck->l_pid = this->lockpid;
		}
		else
			lck->l_type = F_UNLCK;
	}
	else if (mode == TIOCFLUSH) {
		if (this->inp) {
			this->inp->head = this->inp->tail;
			wake(IO_Q, (long)this->inp);
		}
		if (this->outp) {
			this->outp->head = this->outp->tail;
			wake(IO_Q, (long)this->outp);
		}
	} else if (mode == TIOCIBAUD || mode == TIOCOBAUD) {
		*(long *)buf = -1L;
	} else if (mode == TIOCGFLAGS) {
		*((unsigned short *)buf) = 0;
	} else if (mode >= TCURSOFF && mode <= TCURSGRATE) {
	/* kludge: this assumes TOSWIN style escape sequences */
		tty_putchar(f, (long)'\033', RAW);
		switch (mode) {
		case TCURSOFF:
			tty_putchar(f, (long)'f', RAW);
			break;
		case TCURSON:
			tty_putchar(f, (long)'e', RAW);
			break;
		case TCURSSRATE:
			this->cursrate = *((int *)buf);
			/* fall through */
		case TCURSBLINK:
			tty_putchar(f, (long)'t', RAW);
			tty_putchar(f, (long)this->cursrate+32, RAW);
			break;
		case TCURSSTEADY:
			tty_putchar(f, (long)'t', RAW);
			tty_putchar(f, (long)32, RAW);
			break;
		case TCURSGRATE:
			return this->cursrate;
		}
	} else {
	/* if the file is a terminal, Fcntl will automatically
	 * call tty_ioctl for us to handle 'generic' terminal
	 * functions
	 */
		return EINVFN;
	}

	return 0;
}

static long ARGS_ON_STACK 
pipe_lseek(f, where, whence)
	FILEPTR *f; long where; int whence;
{
	UNUSED(f); UNUSED(where); UNUSED(whence);
	return EACCDN;
}

static long ARGS_ON_STACK 
pipe_datime(f, timeptr, rwflag)
	FILEPTR *f;
	short *timeptr;
	int rwflag;
{
	struct fifo *this;

	this = (struct fifo *)f->fc.index;
	if (rwflag) {
		this->time = timeptr[0];
		this->date = timeptr[1];
	}
	else {
		timeptr[0] = this->time;
		timeptr[1] = this->date;
	}
	return 0;
}

static long ARGS_ON_STACK 
pipe_close(f, pid)
	FILEPTR *f;
	int pid;
{
	struct fifo *this, *old;
	struct pipe *p;
	int rwmode;
	FILEPTR **old_x, *x;

	this = (struct fifo *)f->fc.index;

/* wake any processes waiting on this pipe */
	wake(IO_Q, (long)this->inp);
	if (this->inp->rsel)
		wakeselect(this->inp->rsel);
	if (this->inp->wsel)
		wakeselect(this->inp->wsel);

	if (this->outp) {
		wake(IO_Q, (long)this->outp);
		if (this->outp->wsel)
			wakeselect(this->outp->wsel);
		if (this->outp->rsel)
			wakeselect(this->outp->rsel);
	}

	if (f->links <= 0) {
/* remove the file pointer from the list of open file pointers 
 * of this pipe
 */
		old_x = &this->open;
		x = this->open;
		while (x && x != f) {
		        old_x = &x->next;
		        x = x->next;
		}
		assert(x);
		*old_x = f->next;
		/* f->next = 0; */

		rwmode = f->flags & O_RWMODE;
		if (rwmode == O_RDONLY || rwmode == O_RDWR) {
			p = (f->flags & O_HEAD) ? this->outp : this->inp;
/* note that this can never be a virgin pipe, since we had a handle
 * on it!
 */			if (p)
				p->readers--;
		}
		if (rwmode == O_WRONLY || rwmode == O_RDWR) {
			p = (f->flags & O_HEAD) ? this->inp : this->outp;
			if (p) p->writers--;
		}

/* correct for the "selfread" flag (see pipe_creat) */
		if ((f->flags & O_HEAD) && !(this->dosflags & 0x02))
			this->inp->readers--;

/* check for locks */
		if ((f->flags & O_LOCK) && (this->lockpid == pid)) {
			this->flags &= ~O_LOCK;
			wake(IO_Q, (long)this);	/* wake up anyone waiting on the lock */
		}
	}

/* see if we're finished with the pipe */
	if (this->inp->readers == VIRGIN_PIPE)
		this->inp->readers = 0;
	if (this->inp->writers == VIRGIN_PIPE)
		this->inp->writers = 0;

	if (this->inp->readers <= 0 && this->inp->writers <= 0) {
		TRACE(("disposing of closed fifo"));
/* unlink from list of FIFOs */
		if (rootlist == this)
			rootlist = this->next;
		else {
			for (old = rootlist; old->next != this;
					old = old->next) {
				if (!old) {
					ALERT("fifo not on list???");
					return EINTRN;
				}
			}
			old->next = this->next;
		}
		kfree(this->inp);
		if (this->outp) kfree(this->outp);
		kfree(this);
		pipetime = timestamp;
		pipedate = datestamp;
	}

	return 0;
}

static long ARGS_ON_STACK 
pipe_select(f, proc, mode)
	FILEPTR *f;
	long proc;
	int mode;
{
	struct fifo *this;
	struct pipe *p;
	int j;

	this = (struct fifo *)f->fc.index;

	if (mode == O_RDONLY) {
		p = (f->flags & O_HEAD) ? this->outp : this->inp;
		if (!p) {
			DEBUG(("read select on wrong end of pipe"));
			return 0;
		}

/* NOTE: if p->writers <= 0 then reads won't block (they'll fail) */
		if (p->tail != p->head || p->writers <= 0) {
			return 1;
		}

/* BUG: multiple selects fail, only the first one works */
		if (!p->rsel)
			p->rsel = proc;
		return 0;
	} else if (mode == O_WRONLY) {
		p = (f->flags & O_HEAD) ? this->inp : this->outp;
		if (!p) {
			DEBUG(("write select on wrong end of pipe"));
			return 0;
		}
		j = p->tail+1;
		if (j >= PIPESIZ) j = 0;
		if (j != p->head || p->readers <= 0)
			return 1;	/* data may be written */
		if (!p->wsel)
			p->wsel = proc;
		return 0;
	}
	return 0;
}

static void ARGS_ON_STACK 
pipe_unselect(f, proc, mode)
	FILEPTR *f;
	long proc;
	int mode;
{
	struct fifo *this;
	struct pipe *p;

	this = (struct fifo *)f->fc.index;

	if (mode == O_RDONLY) {
		p = (f->flags & O_HEAD) ? this->outp : this->inp;
		if (!p) {
			return;
		}
		if (p->rsel == proc)
			p->rsel = 0;
	} else if (mode == O_WRONLY) {
		p = (f->flags & O_HEAD) ? this->inp : this->outp;
		if (!p) {
			return;
		}
		if (p->wsel == proc)
			p->wsel = 0;
	}
}
