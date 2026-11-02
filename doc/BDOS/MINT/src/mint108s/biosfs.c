/*
Copyright 1991,1992 Eric R. Smith.
Copyright 1993 Atari Corporation.
All rights reserved.
 */

/* simple biosfs.c */

#include "mint.h"

extern struct kerinfo kernelinfo;	/* see main.c */

static long	ARGS_ON_STACK bios_root	P_((int drv, fcookie *fc));
static long	ARGS_ON_STACK bios_lookup	P_((fcookie *dir, const char *name, fcookie *fc));
static long	ARGS_ON_STACK bios_getxattr	P_((fcookie *fc, XATTR *xattr));
static long	ARGS_ON_STACK bios_chattr	P_((fcookie *fc, int attrib));
static long	ARGS_ON_STACK bios_chown	P_((fcookie *fc, int uid, int gid));
static long	ARGS_ON_STACK bios_chmode	P_((fcookie *fc, unsigned mode));
static long	ARGS_ON_STACK bios_rmdir	P_((fcookie *dir, const char *name));
static long	ARGS_ON_STACK bios_remove	P_((fcookie *dir, const char *name));
static long	ARGS_ON_STACK bios_getname	P_((fcookie *root, fcookie *dir, char *pathname, int size));
static long	ARGS_ON_STACK bios_rename	P_((fcookie *olddir, char *oldname,
				    fcookie *newdir, const char *newname));
static long	ARGS_ON_STACK bios_opendir	P_((DIR *dirh, int flags));
static long	ARGS_ON_STACK bios_readdir	P_((DIR *dirh, char *nm, int nmlen, fcookie *fc));
static long	ARGS_ON_STACK bios_rewinddir	P_((DIR *dirh));
static long	ARGS_ON_STACK bios_closedir	P_((DIR *dirh));
static long	ARGS_ON_STACK bios_pathconf	P_((fcookie *dir, int which));
static long	ARGS_ON_STACK bios_dfree	P_((fcookie *dir, long *buf));
static DEVDRV *	ARGS_ON_STACK bios_getdev	P_((fcookie *fc, long *devspecial));
static long	ARGS_ON_STACK bios_fscntl	P_((fcookie *, const char *, int, long));
static long	ARGS_ON_STACK bios_symlink	P_((fcookie *, const char *, const char *));
static long	ARGS_ON_STACK bios_readlink	P_((fcookie *, char *, int));

static long	ARGS_ON_STACK bios_topen	P_((FILEPTR *f));
static long	ARGS_ON_STACK bios_twrite	P_((FILEPTR *f, const char *buf, long bytes));
static long	ARGS_ON_STACK bios_tread	P_((FILEPTR *f, char *buf, long bytes));
static long	ARGS_ON_STACK bios_nwrite	P_((FILEPTR *f, const char *buf, long bytes));
static long	ARGS_ON_STACK bios_nread	P_((FILEPTR *f, char *buf, long bytes));
static long	ARGS_ON_STACK bios_ioctl	P_((FILEPTR *f, int mode, void *buf));
static long	ARGS_ON_STACK bios_select	P_((FILEPTR *f, long p, int mode));
static void	ARGS_ON_STACK bios_unselect	P_((FILEPTR *f, long p, int mode));
static long	ARGS_ON_STACK bios_tseek	P_((FILEPTR *f, long where, int whence));

long	ARGS_ON_STACK null_open	P_((FILEPTR *f));
long	ARGS_ON_STACK null_write	P_((FILEPTR *f, const char *buf, long bytes));
long	ARGS_ON_STACK null_read	P_((FILEPTR *f, char *buf, long bytes));
long	ARGS_ON_STACK null_lseek	P_((FILEPTR *f, long where, int whence));
long	ARGS_ON_STACK null_ioctl	P_((FILEPTR *f, int mode, void *buf));
long	ARGS_ON_STACK null_datime	P_((FILEPTR *f, short *time, int rwflag));
long	ARGS_ON_STACK null_close	P_((FILEPTR *f, int pid));
long	ARGS_ON_STACK null_select	P_((FILEPTR *f, long p, int mode));
void	ARGS_ON_STACK null_unselect	P_((FILEPTR *f, long p, int mode));

static long ARGS_ON_STACK mouse_open	P_((FILEPTR *f));
static long ARGS_ON_STACK mouse_read	P_((FILEPTR *f, char *buf, long nbytes));
static long ARGS_ON_STACK mouse_ioctl P_((FILEPTR *f, int mode, void *buf));
static long ARGS_ON_STACK mouse_close P_((FILEPTR *f, int pid));
static long ARGS_ON_STACK mouse_select P_((FILEPTR *f, long p, int mode));
static void ARGS_ON_STACK mouse_unselect P_((FILEPTR *f, long p, int mode));

/* device driver for BIOS terminals */

DEVDRV bios_tdevice = {
	bios_topen, bios_twrite, bios_tread, bios_tseek, bios_ioctl,
	null_datime, null_close, bios_select, bios_unselect
};

/* device driver for BIOS devices that are not terminals */

DEVDRV bios_ndevice = {
	null_open, bios_nwrite, bios_nread, null_lseek, bios_ioctl,
	null_datime, null_close, bios_select, bios_unselect
};

DEVDRV null_device = {
	null_open, null_write, null_read, null_lseek, null_ioctl,
	null_datime, null_close, null_select, null_unselect
};

DEVDRV mouse_device = {
	mouse_open, null_write, mouse_read, null_lseek, mouse_ioctl,
	null_datime, mouse_close, mouse_select, mouse_unselect
};

/* this special driver is checked for in dosfile.c, and indicates that
 * a dup operation is actually wanted rather than an open
 */
DEVDRV fakedev;

#ifdef FASTTEXT
extern DEVDRV screen_device;	/* see fasttext.c */
#endif

FILESYS bios_filesys = {
	(FILESYS *)0,
	FS_LONGPATH,
	bios_root,
	bios_lookup, nocreat, bios_getdev, bios_getxattr,
	bios_chattr, bios_chown, bios_chmode,
	nomkdir, bios_rmdir, bios_remove, bios_getname, bios_rename,
	bios_opendir, bios_readdir, bios_rewinddir, bios_closedir,
	bios_pathconf, bios_dfree, nowritelabel, noreadlabel,
	bios_symlink, bios_readlink, nohardlink, bios_fscntl, nodskchng
};


struct tty con_tty, aux_tty, midi_tty;
struct tty sccb_tty, scca_tty, ttmfp_tty;

#define BNAME_MAX	13

struct bios_file {
	char 	name[BNAME_MAX+1];	/* device name */
	DEVDRV *device;			/* device driver for device */
	short	private;		/* extra info for device driver */
	ushort	flags;			/* flags for device open */
	struct tty *tty;		/* tty structure (if appropriate) */
	struct bios_file *next;
};

struct bios_file BDEV[] = {

/* "real" bios devices present on all machines */
	{"centr", &bios_ndevice, 0, 0, 0, 0},
	{"console", &bios_tdevice, 2, O_TTY, &con_tty, 0},
	{"midi", &bios_tdevice, 3, O_TTY, &midi_tty, 0},
	{"kbd", &bios_ndevice, 4, 0, 0, 0},
/* devices that duplicate handles */
	{"prn", &fakedev, -3, 0, 0, 0}, /* handle -3 (printer) */
	{"aux", &fakedev, -2, 0, 0, 0}, /* handle -2 (aux. terminal) */
	{"con", &fakedev, -1, 0, 0, 0}, /* handle -1 (control terminal) */
	{"tty", &fakedev, -1, 0, 0, 0}, /* the Unix name for it */
	{"stdin", &fakedev, 0, 0, 0, 0},  /* handle 0 (stdin) */
	{"stdout", &fakedev, 1, 0, 0, 0}, /* handle 1 (stdout) */
	{"stderr", &fakedev, 2, 0, 0, 0}, /* handle 2 (stderr) */

/* other miscellaneous devices */
	{"mouse", &mouse_device, 0, 0, 0, 0},
	{"null", &null_device, 0, 0, 0, 0},

#ifdef FASTTEXT
/* alternate console driver */
	{"fasttext", &screen_device, 2, O_TTY, &con_tty, 0},
#endif

/* serial port things *must* come last, because not all of these
 * are present on all machines (except for modem1, which does however
 * have a different device number on TTs and STs)
 */
	{"modem1", &bios_tdevice, 6, O_TTY, &aux_tty, 0},
	{"modem2", &bios_tdevice, 7, O_TTY, &sccb_tty, 0},
	{"serial1", &bios_tdevice, 8, O_TTY, &ttmfp_tty, 0},
	{"serial2", &bios_tdevice, 9, O_TTY, &scca_tty, 0},
	{"", 0, 0, 0, 0, 0}
};

struct bios_file *broot, *bdevlast;

/* a file pointer for BIOS device 1, provided only for insurance
 * in case a Bconmap happens and we can't allocate a new FILEPTR;
 * in most cases, we'll want to build a FILEPTR in the usual
 * way.
 */

FILEPTR *defaultaux;

void
biosfs_init()
{
	struct bios_file *b;

	broot = BDEV;

	for (b = broot; b->name[0]; b++) {
		b->next = b+1;

	/* if not a TT or Mega STE, adjust the MODEM1 device to be BIOS
	 * device 1
	 * and ignore the remaining devices, since they're not present
	 */
		if (!has_bconmap && b->private == 6) {
			b->private = 1;
			b->next = 0;
			break;
		}
	/* SERIAL2 is not present on the Mega STe */
		if (mch == MEGASTE && b->private == 8) {
			b->next = 0;
			break;
		}
			
	}
	bdevlast = b;
	if (b->name[0] == 0) {
		--b;
		b->next = 0;
	}
	defaultaux = new_fileptr();
	defaultaux->links = 1;		/* so it never gets freed */
	defaultaux->flags = O_RDWR;
	defaultaux->pos = 0;
	defaultaux->devinfo = 0;
	defaultaux->fc.fs = &bios_filesys;
	defaultaux->fc.index = 0;
	defaultaux->fc.aux = 1;
	defaultaux->fc.dev = BIOSDRV;
	defaultaux->dev = &bios_ndevice;
}

static long ARGS_ON_STACK 
bios_root(drv, fc)
	int drv;
	fcookie *fc;
{
	if (drv == BIOSDRV) {
		fc->fs = &bios_filesys;
		fc->dev = drv;
		fc->index = 0L;
		return 0;
	}
	fc->fs = 0;
	return EINTRN;
}

static long ARGS_ON_STACK 
bios_lookup(dir, name, fc)
	fcookie *dir;
	const char *name;
	fcookie *fc;
{
	struct bios_file *b;

	if (dir->index != 0) {
		DEBUG(("bios_lookup: bad directory"));
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

	for (b = broot; b; b = b->next) {
		if (!stricmp(b->name, name)) {
			fc->fs = &bios_filesys;
			fc->index = (long)b;
			fc->aux = b->private;
			fc->dev = dir->dev;
			return 0;
		}
	}
	DEBUG(("bios_lookup: name(%s) not found", name));
	return EFILNF;
}

static long ARGS_ON_STACK 
bios_getxattr(fc, xattr)
	fcookie *fc;
	XATTR *xattr;
{
	FILEPTR *f;
	struct bios_file *b = (struct bios_file *)fc->index;

	xattr->index = fc->index;
	xattr->dev = fc->dev;
	xattr->nlink = 1;
	xattr->uid = xattr->gid = 0;
	xattr->size = xattr->nblocks = 0;
	xattr->blksize = 1;
	xattr->mtime = xattr->atime = xattr->ctime = timestamp;
	xattr->mdate = xattr->adate = xattr->cdate = datestamp;
	if (fc->index == 0) {		/* root directory? */
		xattr->mode = S_IFDIR | DEFAULT_DIRMODE;
		xattr->attr = FA_DIR;
	} else if (b->device == 0) {	/* symbolic link? */
		xattr->mode = S_IFLNK | DEFAULT_DIRMODE;
	} else if (b->device == &fakedev &&
		(f = curproc->handle[b->private]) != 0)
	{
	    /* u:\dev\stdin, u:\dev\stdout, etc. */
	    (*f->fc.fs->getxattr) (&f->fc, xattr);
	    xattr->index = fc->index;
	    xattr->dev = fc->dev;
	} else {
		xattr->mode = S_IFCHR | DEFAULT_MODE;
		xattr->attr = 0;
	}
	return 0;
}

static long ARGS_ON_STACK 
bios_chattr(fc, attrib)
	fcookie *fc;
	int attrib;
{
	UNUSED(fc); UNUSED(attrib);
	return EACCDN;
}

static long ARGS_ON_STACK 
bios_chown(fc, uid, gid)
	fcookie *fc;
	int uid, gid;
{
	UNUSED(fc); UNUSED(uid);
	UNUSED(gid);
	return EINVFN;
}

static long ARGS_ON_STACK 
bios_chmode(fc, mode)
	fcookie *fc;
	unsigned mode;
{
	UNUSED(fc); UNUSED(mode);
	return EINVFN;
}

long ARGS_ON_STACK 
nomkdir(dir, name, mode)
	fcookie *dir;
	const char *name;
	unsigned mode;
{
	UNUSED(dir); UNUSED(name);
	UNUSED(mode);
	return EACCDN;
}

static long ARGS_ON_STACK 
bios_rmdir(dir, name)
	fcookie *dir;
	const char *name;
{
	return bios_remove(dir, name);
}

/*
 * MAJOR BUG: we don't check here for removal of devices for which there
 * are still open files
 */

static long ARGS_ON_STACK 
bios_remove(dir, name)
	fcookie *dir;
	const char *name;
{
	struct bios_file *b, **lastb;

	UNUSED(dir);
	lastb = &broot;
	for (b = broot; b; b = *(lastb = &b->next)) {
		if (!stricmp(b->name, name)) break;
	}
	if (!b) return EFILNF;

/* don't allow removal of the basic system devices */
	if (b >= BDEV && b <= bdevlast) {
		return EACCDN;
	}
	*lastb = b->next;

	if (b->device == 0 || b->device == &bios_tdevice)
		kfree(b->tty);

	kfree(b);
	return 0;
}

static long ARGS_ON_STACK 
bios_getname(root, dir, pathname, size)
	fcookie *root, *dir; char *pathname;
	int size;
{
	char *foo = ((struct bios_file *)dir->index)->name;

	UNUSED(root);
	if (dir->index == 0 && size > 0)
		*pathname = 0;
	else if (strlen(foo) < size)
		strcpy(pathname, foo);
	else
		return ERANGE;
	return 0;
}

static long ARGS_ON_STACK 
bios_rename(olddir, oldname, newdir, newname)
	fcookie *olddir;
	char *oldname;
	fcookie *newdir;
	const char *newname;
{
	struct bios_file *b;

	UNUSED(olddir); UNUSED(newdir);

/* BUG: we should check to see if "newname" already exists */

	for (b = broot; b; b = b->next) {
		if (!stricmp(b->name, oldname)) {
			strncpy(b->name, newname, BNAME_MAX);
			return 0;
		}
	}
	return EFILNF;
}

static long ARGS_ON_STACK 
bios_opendir(dirh, flags)
	DIR *dirh;
	int flags;
{
	UNUSED(flags);

	if (dirh->fc.index != 0) {
		DEBUG(("bios_opendir: bad directory"));
		return EPTHNF;
	}
	return 0;
}

static long ARGS_ON_STACK 
bios_readdir(dirh, name, namelen, fc)
	DIR *dirh;
	char *name;
	int namelen;
	fcookie *fc;
{
	struct bios_file *b;
	int giveindex = dirh->flags == 0;
	int i;

	b = broot;
	i = dirh->index++;
	while(i-- > 0) {
		if (!b) break;
		b = b->next;
	}
	if (!b) {
		return ENMFIL;
	}
	fc->fs = &bios_filesys;
	fc->index = (long)b;
	fc->aux = b->private;
	fc->dev = dirh->fc.dev;
	if (giveindex) {
		namelen -= (int)sizeof(long);
		if (namelen <= 0)
			return ERANGE;
		*((long *)name) = (long) b;
		name += sizeof(long);
	}
	strncpy(name, b->name, namelen-1);
	if (strlen(b->name) >= namelen)
		return ENAMETOOLONG;
	return 0;
}

static long ARGS_ON_STACK 
bios_rewinddir(dirh)
	DIR *dirh;
{
	dirh->index = 0;
	return 0;
}

static long ARGS_ON_STACK 
bios_closedir(dirh)
	DIR *dirh;
{
	UNUSED(dirh);
	return 0;
}

static long ARGS_ON_STACK 
bios_pathconf(dir, which)
	fcookie *dir;
	int which;
{
	UNUSED(dir);

	switch(which) {
	case -1:
		return DP_MAXREQ;
	case DP_IOPEN:
		return UNLIMITED;	/* no limit on BIOS file descriptors */
	case DP_MAXLINKS:
		return 1;		/* no hard links available */
	case DP_PATHMAX:
		return PATH_MAX;
	case DP_NAMEMAX:
		return BNAME_MAX;
	case DP_ATOMIC:
		return 1;		/* no atomic writes */
	case DP_TRUNC:
		return DP_AUTOTRUNC;	/* names are truncated */
	case DP_CASE:
		return DP_CASEINSENS;	/* not case sensitive */
	default:
		return EINVFN;
	}
}

static long ARGS_ON_STACK 
bios_dfree(dir, buf)
	fcookie *dir;
	long *buf;
{
	UNUSED(dir);

	buf[0] = 0;	/* number of free clusters */
	buf[1] = 0;	/* total number of clusters */
	buf[2] = 1;	/* sector size (bytes) */
	buf[3] = 1;	/* cluster size (sectors) */
	return 0;
}

/*
 * BIOS Dcntl() calls:
 * Dcntl(0xde02, "U:\DEV\FOO", &foo_descr): install a new device called
 *     "FOO", which is described by the dev_descr structure "foo_descr".
 *     this structure has the following fields:
 *         DEVDRV *driver		the device driver itself
 *	   short  dinfo			info for the device driver
 *	   short  flags			flags for the file (e.g. O_TTY)
 *	   struct tty *tty		tty structure, if appropriate
 *
 * Dcntl(0xde00, "U:\DEV\BAR", n): install a new BIOS terminal device, with
 *     BIOS device number "n".
 * Dcntl(0xde01, "U:\DEV\BAR", n): install a new non-tty BIOS device, with
 *     BIOS device number "n".
 */

static long ARGS_ON_STACK 
bios_fscntl(dir, name, cmd, arg)
	fcookie *dir;
	const char *name;
	int cmd;
	long arg;
{
	struct bios_file *b;

	UNUSED(dir);
	if ((unsigned)cmd == DEV_INSTALL) {
		struct dev_descr *d = (struct dev_descr *)arg;

		b = kmalloc(SIZEOF(struct bios_file));
		if (!b) return 0;
		strncpy(b->name, name, BNAME_MAX);
		b->name[BNAME_MAX] = 0;
		b->device = d->driver;
		b->private = d->dinfo;
		b->flags = d->flags;
		b->tty = d->tty;
		b->next = broot;
		broot = b;
		return (long)&kernelinfo;
	}
	if ((unsigned)cmd == DEV_NEWTTY) {
		b = kmalloc(SIZEOF(struct bios_file));
		if (!b) return ENSMEM;
		b->tty = kmalloc(SIZEOF(struct tty));
		if (!b->tty) {
			kfree(b);
			return ENSMEM;
		}
		strncpy(b->name, name, BNAME_MAX);
		b->name[BNAME_MAX] = 0;
		b->device = &bios_tdevice;
		b->private = arg;
		b->flags = O_TTY;
		*b->tty = default_tty;
		b->next = broot;
		broot = b;
		return 0;
	}
	if ((unsigned)cmd == DEV_NEWBIOS) {
		b = kmalloc(SIZEOF(struct bios_file));
		if (!b) return ENSMEM;
		strncpy(b->name, name, BNAME_MAX);
		b->name[BNAME_MAX] = 0;
		b->tty = 0;
		b->device = &bios_ndevice;
		b->private = arg;
		b->flags = 0;
		b->next = broot;
		return 0;
	}
	return EINVFN;
}

static long ARGS_ON_STACK 
bios_symlink(dir, name, to)
	fcookie *dir;
	const char *name, *to;
{
	struct bios_file *b;
	long r;
	fcookie fc;

	r = bios_lookup(dir, name, &fc);
	if (r == 0) return EACCDN;	/* file already exists */
	if (r != EFILNF) return r;	/* some other error */

	b = kmalloc(SIZEOF(struct bios_file));
	if (!b) return EACCDN;

	strncpy(b->name, name, BNAME_MAX);
	b->name[BNAME_MAX] = 0;
	b->device = 0;
	b->private = EINVFN;
	b->flags = 0;
	b->tty = kmalloc((long)strlen(to)+1);
	if (!b->tty) {
		kfree(b);
		return EACCDN;
	}
	strcpy((char *)b->tty, to);
	b->next = broot;
	broot = b;
	return 0;
}

static long ARGS_ON_STACK 
bios_readlink(fc, buf, buflen)
	fcookie *fc;
	char *buf;
	int buflen;
{
	struct bios_file *b = (struct bios_file *)fc->index;

	if (!b) return EINVFN;
	if (b->device) return EINVFN;

	strncpy(buf, (char *)b->tty, buflen);
	if (strlen((char *)b->tty) >= buflen)
		return ENAMETOOLONG;
	return 0;
}


/*
 * routines for file systems that don't support volume labels
 */

long ARGS_ON_STACK 
nowritelabel(dir, name)
	fcookie *dir;
	const char *name;
{
	UNUSED(dir);
	UNUSED(name);
	return EACCDN;
}

long ARGS_ON_STACK 
noreadlabel(dir, name, namelen)
	fcookie *dir;
	char *name;
	int namelen;
{
	UNUSED(dir);
	UNUSED(name);
	UNUSED(namelen);
	return EFILNF;
}

/*
 * routines for file systems that don't support links
 */

long ARGS_ON_STACK 
nosymlink(dir, name, to)
	fcookie *dir;
	const char *name, *to;
{
	UNUSED(dir); UNUSED(name);
	UNUSED(to);
	return EINVFN;
}

long ARGS_ON_STACK 
noreadlink(dir, buf, buflen)
	fcookie *dir;
	char *buf;
	int buflen;
{
	UNUSED(dir); UNUSED(buf);
	UNUSED(buflen);
	return EINVFN;
}

long ARGS_ON_STACK 
nohardlink(fromdir, fromname, todir, toname)
	fcookie *fromdir, *todir;
	const char *fromname, *toname;
{
	UNUSED(fromdir); UNUSED(todir);
	UNUSED(fromname); UNUSED(toname);
	return EINVFN;
}

/* dummy routine for file systems with no Fscntl commands */

long ARGS_ON_STACK 
nofscntl(dir, name, cmd, arg)
	fcookie *dir;
	const char *name;
	int cmd;
	long arg;
{
	UNUSED(dir); UNUSED(name);
	UNUSED(cmd); UNUSED(arg);
	return EINVFN;
}

/*
 * Did the disk change? Not on this drive!
 * However, we have to do Getbpb anyways, because someone has decided
 * to force a media change on our (non-existent) drive.
 */
long ARGS_ON_STACK 
nodskchng(drv)
	int drv;
{
	(void)getbpb(drv);
	return 0;
}

long ARGS_ON_STACK 
nocreat(dir, name, mode, attrib, fc)
	fcookie *dir, *fc;
	const char *name;
	unsigned mode;
	int attrib;
{
	UNUSED(dir); UNUSED(fc);
	UNUSED(name); UNUSED(mode);
	UNUSED(attrib);
	return EACCDN;
}

static DEVDRV * ARGS_ON_STACK 
bios_getdev(fc, devsp)
	fcookie *fc;
	long *devsp;
{
	struct bios_file *b;

	b = (struct bios_file *)fc->index;

	if (b->device && b->device != &fakedev)
		*devsp = (long)b->tty;
	else
		*devsp = b->private;

	return b->device;	/* return the device driver */
}

/*
 * NULL device driver
 */

long ARGS_ON_STACK 
null_open(f)
	FILEPTR *f;
{
	UNUSED(f);
	return 0;
}

long ARGS_ON_STACK 
null_write(f, buf, bytes)
	FILEPTR *f; const char *buf; long bytes;
{
	UNUSED(f); UNUSED(buf);
	return bytes;
}

long ARGS_ON_STACK 
null_read(f, buf, bytes)
	FILEPTR *f; char *buf; long bytes;
{
	UNUSED(f); UNUSED(buf);
	UNUSED(bytes);
	return 0;
}

long ARGS_ON_STACK 
null_lseek(f, where, whence)
	FILEPTR *f; long where; int whence;
{
	UNUSED(f); UNUSED(whence);
	return (where == 0) ? 0 : ERANGE;
}

long ARGS_ON_STACK 
null_ioctl(f, mode, buf)
	FILEPTR *f; int mode; void *buf;
{
	UNUSED(f);
	if (mode == FIONREAD) {
		*((long *)buf) = 0;
	}
	else if (mode == FIONWRITE)
		*((long *)buf) = 1;
	else
		return EINVFN;
	return 0;
}

long ARGS_ON_STACK 
null_datime(f, timeptr, rwflag)
	FILEPTR *f;
	short *timeptr;
	int rwflag;
{
	UNUSED(f);
	if (rwflag)
		return EACCDN;
	*timeptr++ = timestamp;
	*timeptr = datestamp;
	return 0;
}

long ARGS_ON_STACK 
null_close(f, pid)
	FILEPTR *f;
	int pid;
{
	UNUSED(f);
	UNUSED(pid);
	return 0;
}

long ARGS_ON_STACK 
null_select(f, p, mode)
	FILEPTR *f; long p;
	int mode;
{
	UNUSED(f); UNUSED(p);
	UNUSED(mode);
	return 1;	/* we're always ready to read/write */
}

void ARGS_ON_STACK 
null_unselect(f, p, mode)
	FILEPTR *f;
	long p;
	int mode;
{
	UNUSED(f); UNUSED(p);
	UNUSED(mode);
	/* nothing to do */
}

/*
 * BIOS terminal device driver
 */

static long ARGS_ON_STACK 
bios_topen(f)
	FILEPTR *f;
{
	f->flags |= O_TTY;
	return 0;
}

/*
 * Note: when a BIOS device is a terminal (i.e. has the O_TTY flag
 * set), bios_read and bios_write will only ever be called indirectly, via
 * tty_read and tty_write. That's why we can afford to play a bit fast and
 * loose with the pointers ("buf" is really going to point to a long) and
 * why we know that "bytes" is divisible by 4.
 */

static long ARGS_ON_STACK 
bios_twrite(f, buf, bytes)
	FILEPTR *f; const char *buf; long bytes;
{
	long *r;
	long ret = 0;
	int bdev = f->fc.aux;

	r = (long *)buf;

/* Check for control characters on any newline output.
 * Note that newlines are always output through tty_putchar,
 * so they'll always be the first thing in the buffer (at least,
 * for cooked TTY output they will, which is the only sort that
 * control characters affect anyways).
 */
	if (bytes > 0 && (*r & 0x000000ffL) == '\n')
		(void) checkkeys();

	if (f->flags & O_NDELAY) {
		while (bytes > 0) {
		    if (!bcostat(bdev)) break;
		    if (bconout(bdev, (int)*r) == 0)
			break;
		    r++; bytes -= 4; ret+= 4;
		}
	} else {
		while (bytes > 0) {
		    if (bconout(bdev, (int)*r) == 0)
			break;
		    r++; bytes -= 4; ret+= 4;
		}
	}
#if 0
	(void)checkkeys();
#endif
	return ret;
}

static long ARGS_ON_STACK 
bios_tread(f, buf, bytes)
	FILEPTR *f; char *buf; long bytes;
{
	long *r, ret = 0;
	int bdev = f->fc.aux;

	r = (long *)buf;

	if ((f->flags & O_NDELAY)) {
		while (bytes > 0) {
		    if ( !bconstat(bdev) )
			break;
		    *r++ = bconin(bdev) & 0x7fffffffL;
		    bytes -= 4; ret += 4;
		}
	} else {
		while (bytes > 0) {
		    *r++ = bconin(bdev) & 0x7fffffffL;
		    bytes -= 4; ret += 4;
		}
	}
	return ret;
}

/*
 * read/write routines for BIOS devices that aren't terminals (like the
 * printer & IKBD devices)
 */

static long ARGS_ON_STACK 
bios_nwrite(f, buf, bytes)
	FILEPTR *f; const char *buf; long bytes;
{
	long ret = 0;
	int bdev = f->fc.aux;
	int c;

	while (bytes > 0) {
		if ( (f->flags & O_NDELAY) && !bcostat(bdev) )
			break;

		c = *buf++ & 0x00ff;

		if (bconout(bdev, c) == 0)
			break;

		bytes--; ret++;
	}
	return ret;
}

static long ARGS_ON_STACK 
bios_nread(f, buf, bytes)
	FILEPTR *f; char *buf; long bytes;
{
	long ret = 0;
	int bdev = f->fc.aux;

	while (bytes > 0) {
		if ( (f->flags & O_NDELAY) && !bconstat(bdev) )
			break;
		*buf++ = bconin(bdev) & 0xff;
		bytes--; ret++;
	}
	return ret;
}

/*
 * BIOS terminal seek code -- this has to match the documented
 * way to do isatty()
 */

static long ARGS_ON_STACK 
bios_tseek(f, where, whence)
	FILEPTR *f;
	long where;
	int whence;
{
	UNUSED(f); UNUSED(where);
	UNUSED(whence);
/* terminals always are at position 0 */
	return 0;
}

#define MAXBAUD 16

/* keep these sorted in descending order */
static long baudmap[MAXBAUD] = {
19200L, 9600L, 4800L, 3600L, 2400L, 2000L, 1800L, 1200L,
600L, 300L, 200L, 150L, 134L, 110L, 75L, 50L
};

static long ARGS_ON_STACK 
bios_ioctl(f, mode, buf)
	FILEPTR *f; int mode; void *buf;
{
	long *r = (long *)buf;
	struct winsize *ws;
	char *aline;
	short dev;
	int i;

	if (mode == FIONREAD) {
		if (bconstat(f->fc.aux))
			*r = 1;
		else
			*r = 0;
	}
	else if (mode == FIONWRITE) {
		if (bcostat(f->fc.aux))
			*r = 1;
		else
			*r = 0;
	}
	else if (mode == TIOCFLUSH) {
/* BUG: this should flush the input/output buffers */
		return 0;
	}
	else if (mode == TIOCGWINSZ && f->fc.aux == 2) {
		aline = lineA0();
		ws = (struct winsize *)buf;
		ws->ws_row = *((short *)(aline - 42)) + 1;
		ws->ws_col = *((short *)(aline - 44)) + 1;
	} else if (mode == TIOCIBAUD || mode == TIOCOBAUD) {
		long oldbaud, newbaud;
		int oldmap;

		dev = f->fc.aux;

		newbaud = *r;
		if (dev == 1 || dev >= 6) {
/* trick rsconf into setting the correct port (it uses curproc->bconmap) */
			oldmap = curproc->bconmap;
			if (has_bconmap)
				curproc->bconmap = 
					(dev == 1) ? curproc->bconmap : dev;
			i = (int)rsconf(-2, -1, -1, -1, -1, -1);

			if (i < 0 || i >= MAXBAUD)
				oldbaud = -1L;
			else
				oldbaud = baudmap[i];
			*r = oldbaud;
			if (newbaud > 0 && newbaud != oldbaud) {
	/* BUG: assert DTR works only on modem1 */
				if (dev == 1 || dev == 6) {
					Offgibit(0xef);
				}
				for (i = 0; i < MAXBAUD; i++) {
					if (baudmap[i] == newbaud) {
						rsconf(i, -1, -1, -1, -1, -1);
						curproc->bconmap = oldmap;
						return 0;
					} else if (baudmap[i] < newbaud) {
						*r = baudmap[i];
						curproc->bconmap = oldmap;
						break;
					}
				}
				curproc->bconmap = oldmap;
				return ERANGE;
			} else if (newbaud == 0L) {
	/* BUG: drop DTR: works only on modem1 */
				if (dev == 1 || dev == 6) {
					Ongibit(0x10);
				}
			}
			curproc->bconmap = oldmap;
			return 0;
		} else if (dev == 2 || dev == 5) {
			/* screen: assume 9600 baud */
			oldbaud = 9600L;
		} else if (dev == 3) {
			/* midi */
			oldbaud = 31250L;
		} else {
			oldbaud = -1L;	/* unknown speed */
		}
		*r = oldbaud;
		if (newbaud > 0 && newbaud != oldbaud)
			return ERANGE;
		return 0;
	} else if (mode == TIOCCBRK || mode == TIOCSBRK) {
		unsigned long bits;

		dev = f->fc.aux;
		if (dev == 1 || dev >= 6) {
			if (has_bconmap)
				mapin((dev == 1) ? curproc->bconmap : dev);
		} else {
			return EINVFN;
		}
		bits = rsconf(-1, -1, -1, -1, -1, -1);	/* get settings */
		bits = (bits >> 8) & 0x0ff;		/* isolate TSR byte */
		if (mode == TIOCCBRK)
			bits &= ~8;
		else
			bits |= 8;
		(void)rsconf(-1, -1, -1, -1, (int)bits, -1);
	} else if (mode == TIOCGFLAGS || mode == TIOCSFLAGS) {
		unsigned short oflags, flags;
		unsigned long bits;
		unsigned char ucr;
		short flow;

		dev = f->fc.aux;
		if (dev == 1 || dev >= 6) {
			oflags = ((struct tty *)f->devinfo)->sg.sg_flags;
			oflags &= (T_TANDEM|T_RTSCTS);
			if (has_bconmap)
				mapin((dev == 1) ? curproc->bconmap : dev);
			bits = rsconf(-1, -1, -1, -1, -1, -1);	/* get settings */
			ucr = (bits >> 24L) & 0x0ff;		/* isolate UCR byte */
			oflags |= (ucr >> 3) & (TF_STOPBITS|TF_CHARBITS);
			if (ucr & 0x4) {			/* parity on? */
				oflags |= (ucr & 0x2) ? T_EVENP : T_ODDP;
			}
			if (mode == TIOCSFLAGS) {
				flags = (*(unsigned short *)buf);
				if (flags & T_EVENP) {
					ucr |= 0x6;
				} else if (flags & T_ODDP) {
					ucr &= ~2;
					ucr |= 0x4;
				} else {
					ucr &= ~6;
				}
				if (flags & TF_STOPBITS) {
					ucr &= ~(0x18);
					ucr |= (flags & TF_STOPBITS) << 3;
				}
				ucr &= ~(0x60);
				ucr |= (flags & TF_CHARBITS) << 3;
				flow = (flags & (T_RTSCTS|T_TANDEM)) >> 12L;
				rsconf(-1, flow, ucr, -1, -1, -1);
			} else {
				*((unsigned short *)buf) = oflags;
			}
		} else {
			return EINVFN;
		}
	} else if ((mode >= TCURSOFF && mode <= TCURSSTEADY) && (f->fc.aux == 2)) {
		return Cursconf(mode - TCURSOFF, 0);
	} else if ((mode >= TCURSSRATE && mode <= TCURSGRATE) && (f->fc.aux == 2)) {
		long r;

		r = Cursconf(mode - TCURSOFF, *((short *)buf));
		if (r >= 0) {
			*(short *)buf = r;
			r = 0;
		}
		return r;
	} else {
	/* Fcntl will automatically call tty_ioctl to handle
	 * terminal calls that we didn't deal with
	 */
		return EINVFN;
	}
	return 0;
}

static long ARGS_ON_STACK 
bios_select(f, p, mode)
	FILEPTR *f; long p; int mode;
{
	struct tty *tty = (struct tty *)f->devinfo;
	int dev = f->fc.aux;

	if (mode == O_RDONLY) {
		if (bconstat(dev)) {
			TRACE(("bios_select: data present for device %d", dev));
			return 1;
		}
		if (tty) {
		/* avoid collisions with other processes */
			if (!tty->rsel)
				tty->rsel = p;
		}
		return 0;
	} else if (mode == O_WRONLY) {
		if (bcostat(dev)) {
			TRACE(("bios_select: ready to output on %d", dev));
			return 1;
		}
		if (tty) {
			if (!tty->wsel)
				tty->wsel = p;
		}
		return 0;
	}
	/* default -- we don't know this mode, return 0 */
	return 0;
}

static void ARGS_ON_STACK 
bios_unselect(f, p, mode)
	FILEPTR *f;
	long p;
	int mode;
{
	struct tty *tty = (struct tty *)f->devinfo;

	if (tty) {
		if (mode == O_RDONLY && tty->rsel == p)
			tty->rsel = 0;
		else if (mode == O_WRONLY && tty->wsel == p)
			tty->wsel = 0;
	}
}

/*
 * mouse device driver
 */

#define MOUSESIZ 128*3
static unsigned char mousebuf[MOUSESIZ];
static int mousehead, mousetail;

long mousersel;	/* is someone calling select() on the mouse? */

char mshift;		/* shift key status; set by checkkeys() in bios.c */
short *gcurx = 0,
      *gcury = 0;	/* mouse pos. variables; used by big screen emulators */

void ARGS_ON_STACK 
mouse_handler(buf)
	const char *buf;	/* must be a *signed* character */
{
	unsigned char *mbuf, buttons;
	int newmtail;
	short dx, dy;

/* the Sun mouse driver has 0=down, 1=up, while the atari hardware gives
   us the reverse. also, we have the "middle" button and the "left"
   button reversed; so we use this table to convert (and also to add the
   0x80 to indicate a mouse packet)
 */
	static int _cnvrt[8] = {
		0x87, 0x86, 0x83, 0x82, 0x85, 0x84, 0x81, 0x80
	};

	mbuf = &mousebuf[mousetail];
	newmtail = mousetail + 3;
	if (newmtail >= MOUSESIZ)
		newmtail = 0;
	if (newmtail == mousehead)
		return;			/* buffer full */

	buttons = *buf++ & 0x7;		/* convert to SUN format */
	if (mshift & 0x3) {		/* a shift key held down? */
	/* if so, convert shift+button to a "middle" button */
		if (buttons == 0x1 || buttons == 0x2)
			buttons = 0x4;
		else if (buttons == 0x3)
			buttons = 0x7;
	}
	*mbuf++ = _cnvrt[buttons];	/* convert to Sun format */
	dx = *buf++;
	*mbuf++ = dx;			/* copy X delta */
	dy = *buf;
	*mbuf = -dy;			/* invert Y delta for Sun format */
	mousetail = newmtail;
	*gcurx += dx;			/* update line A variables */
	*gcury += dy;
/*
 * if someone has called select() waiting for mouse input, wake them
 * up
 */
	if (mousersel) {
		wakeselect(mousersel);
	}
}

extern void newmvec(), newjvec();	/* in intr.s */
static long oldvec = 0;
long oldjvec = 0;

static long ARGS_ON_STACK 
mouse_open(f)
	FILEPTR *f;
{
	char *aline;

	static char parameters[] = {
		0, 		/* Y=0 in lower corner */
		0,		/* normal button handling */
		1, 1		/* X, Y scaling factors */
	};

	UNUSED(f);

	if (oldvec)		/* mouse in use */
		return EACCDN;

/* initialize pointers to line A variables */
	if (!gcurx) {
		aline = lineA0();
		if (aline == 0)	{	/* should never happen */
			ALERT("unable to read line A variables");
			return -1;
		}
		gcurx = (short *)(aline - 0x25a);
		gcury = (short *)(aline - 0x258);
		*gcurx = *gcury = 32;	/* magic number -- what MGR uses */
	}

	oldvec = syskey->mousevec;
	oldjvec = syskey->joyvec;	/* jr: save old joystick vector */
	Initmous(1, parameters, newmvec);
	syskey->joyvec = (long)newjvec;	/* jr: set up new joystick handler */
	mousehead = mousetail = 0;
	return 0;
}

static long ARGS_ON_STACK 
mouse_close(f, pid)
	FILEPTR *f;
	int pid;
{
	static char parameters[] = {
		0, 		/* Y=0 in lower corner */
		0,		/* normal button handling */
		1, 1		/* X, Y scaling factors */
	};

	UNUSED(pid);
	if (!f) return EIHNDL;
	if (f->links <= 0) {
		if (!oldvec) {
			DEBUG(("Mouse not open!!"));
			return -1;
		}
		Initmous(1, parameters, (void *)oldvec);	/* gratuitous (void *) for Lattice */
		syskey->joyvec = oldjvec;	/* jr: restore old joystick handler */
		oldvec = 0;
	}
	return 0;
}

static long ARGS_ON_STACK 
mouse_read(f, buf, nbytes)
	FILEPTR *f;
	char *buf;
	long nbytes;
{
	long count = 0;
	int mhead;
	unsigned char *foo;

	mhead = mousehead;
	foo = &mousebuf[mhead];

	if (mhead == mousetail) {
		if (f->flags & O_NDELAY)
			return 0;
		do {
			yield();
		} while (mhead == mousetail);
	}

	while ( (mhead != mousetail) && (nbytes > 0)) {
		*buf++ = *foo++;
		mhead++;
		if (mhead >= MOUSESIZ) {
			mhead = 0;
			foo = mousebuf;
		}
		count++;
		--nbytes;
	}
	mousehead = mhead;
	return count;
}

static long ARGS_ON_STACK 
mouse_ioctl(f, mode, buf)
	FILEPTR *f;
	int mode;
	void *buf;
{
	long r;

	UNUSED(f);
	if (mode == FIONREAD) {
		r = mousetail - mousehead;
		if (r < 0) r += MOUSESIZ;
		*((long *)buf) = r;
	}
	else
		return EINVFN;
	return 0;
}

static long ARGS_ON_STACK 
mouse_select(f, p, mode)
	FILEPTR *f;
	long p;
	int mode;
{
	UNUSED(f);

	if (mode != O_RDONLY)
		return 1;	/* we can always take output :-) */

	if (mousetail - mousehead)
		return 1;	/* input waiting already */

	if (!mousersel)
		mousersel = p;
	return 0;
}

static void ARGS_ON_STACK 
mouse_unselect(f, p, mode)
	FILEPTR *f;
	long p;
	int mode;
{
	UNUSED(f);

	if (mode == O_RDONLY && mousersel == p)
		mousersel = 0;
}


/*
 * UTILITY ROUTINE called by Bconmap() in xbios.c:
 * this sets handle -1 of process p to a file handle
 * that has BIOS device "dev". Returns 0 on failure,
 * non-zero on success.
 */

int
set_auxhandle(p, dev)
	PROC *p;
	int dev;
{
	FILEPTR *f;
	struct bios_file *b;

	f = new_fileptr();
	if (f) {
		f->links = 1;
		f->flags = O_RDWR;
		f->pos = 0;
		f->devinfo = 0;
		f->fc.fs = &bios_filesys;
		f->fc.aux = dev;
		f->fc.dev = BIOSDRV;
		for (b = broot; b; b = b->next) {
			if (b->private == dev &&
			    (b->device == &bios_tdevice ||
			     b->device == &bios_ndevice)) {
				f->fc.index = (long)b;
				f->dev = b->device;
				if (b->device != &fakedev)
					f->devinfo = (long)b->tty;
				goto found_device;
			}
		}
		f->fc.index = 0;
		f->dev = &bios_ndevice;
found_device:
		if ((*f->dev->open)(f) < 0) {
			f->links = 0;
			dispose_fileptr(f);
			return 0;
		}
	} else {
/* no memory! use the fake FILEPTR we
 * set up in biosfs_init
 */
		f = defaultaux;
		f->links++;
	}

	(void)do_pclose(p, p->aux);
	p->aux = f;

	return 1;
}
