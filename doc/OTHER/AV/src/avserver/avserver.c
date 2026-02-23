#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "vaproto.h"
#include "avserver.h"
#include "a-man.h"

char const sccs_id[] = "@(#)AV-Server " VERSION " (" DATE "), Copyright (c)1996-98 by A. Barton";
static char const progname[] = "AVSERVER\0";
/* WTF. Use Keytbl() instead */
/* BUG: off by 1 when indexed by scancode */
static char const keyboard_table[] = "\x17!\"\xdd$%&/()=?`^\x08\x09QWERTZUIOP\x9a+\x0d\0ASDFGHJKL\x99\x8e\0\0|YXCVBNM;:_\0\0\0 ";


#define MAX_CLIENTS   127
#define MAX_WINDS     127
#define MAX_PROGS     4

/*
 * in assembler code
 */
extern short sp_offset ASM_NAME("sp_offset"); /* FIXME: not used anywhere */
long install_aes_trap(void); ASM_NAME("install_aes_trap");


/*
 * our structures
 */
#define MAX_APPNAME 8

struct client {
	short apid;
	short capabilities;
	char name[MAX_APPNAME + 1];
};

struct window {
	short winid;
	short apid;
};

struct program {
	short apid;
	short msg_extra;
	char name[MAX_APPNAME + 1];
};

struct avserver_info {
	short maxclients;
	short maxwindows;
	short maxprograms;
	struct client *clients;
	struct window *windows;
	struct program *programs;
};

_WORD gl_apid ASM_NAME("gl_apid");
static _WORD magxdesk;
_WORD ap_dragdrop_id ASM_NAME("ap_dragdrop_id");
static _WORD av_protokoll3;
static _WORD av_protokoll4;
static _WORD workout[57]; /* FIXME: only used on font selector */
static char startprog_path[1024];
static char startprog_name[1024];
static void *dd_data;
static struct client clients[MAX_CLIENTS];
static struct window windows[MAX_WINDS];
static struct program programs[MAX_PROGS];
static struct avserver_info avserver_info;


/*
 * forward declarations
 */
static void etv_term(void);
static void check_apps(void);
static void gen_mgcopy_cmdline(char *names);
static int what_izit(_WORD mox, _WORD moy, _WORD *owner);



void error_dragdrop(void);
void error_internal(void);
void error_overflow(void);
void error_copy(void);
void error_no_aman(void);
void error_magx_inf(void);

static int xbra_unlink(int vec);
static void cycle_windows(void);


static void av_protokoll(_WORD *message);
static void av_exit(_WORD *message);
static void av_path_update(_WORD *message);
static void av_drag_on_window(_WORD *message);
static void av_what_izit(_WORD *message);
static void av_accwindopen(_WORD *message);
static void av_accwindclosed(_WORD *message);
static void av_startprog(_WORD *message);
static void va_progstart(_WORD *message);
static void av_sendkey(_WORD *message);
static void av_xwind(_WORD *message);
static void av_openwind(_WORD *message);
static void av_view(_WORD *message);
static void av_status(_WORD *message);
static void av_getstatus(_WORD *message);
static void av_copyfile(_WORD *message);
static void av_delfile(_WORD *message);
static void va_start_(void);

#define AV_SERVER_INFO 0x4798
#define VA_SERVER_INFO 0x4799
static void av_server_info(_WORD *message);

static int ap_dragdrop(int fd, _WORD mox, _WORD moy, _WORD winid, _WORD apid);
static int dd_reply(int fd, char ack);


/*
 * Font protocoll
 */
#define FONT_SELECT   0x7a19
#define FONT_CHANGED  0x7a18
static void font_select(_WORD *message);
static void fontselect_error(int code);

#if defined(__GNUC__)
#include <gemx.h>
#elif defined(__PORTAES_H__)
#include <wdlgfslx.h>
#else
/*
 * fnts_* prototypes, not present in original pcgemlib.lib
 */
typedef struct _fnt_dialog { int dummy; } FNT_DIALOG;
typedef long fix31;

/* Definitions for <font_flags> with fnts_create() */
#define FNTS_BTMP   1                   /* Display bitmap fonts */
#define FNTS_OUTL   2                   /* Display vector fonts */
#define FNTS_MONO   4                   /* Display equidistant fonts */
#define FNTS_PROP   8                   /* Display proportional fonts */
#define FNTS_ALL    15

/* Definitions for <dialog_flags> with fnts_create() */
#define FNTS_3D     1                   /* Use 3D-design */

/* Definitions for <button> with fnts_evnt() */

#define FNTS_CANCEL     1              /* "Cancel was selected */
#define FNTS_OK         2              /* "OK" was pressed */
#define FNTS_SET        3              /* "Set" was selected */
#define FNTS_MARK       4              /* "Mark" was selected */
#define FNTS_OPT        5              /* The application's own button was selected */
#define FNTS_OPTION		FNTS_OPT

/* Definitions for <button_flags> with fnts_open() */
#define FNTS_SNAME      0x01           /* Select checkbox for names */
#define FNTS_SSTYLE     0x02           /* Select checkbox for styles */
#define FNTS_SSIZE      0x04           /* Select checkbox for height */
#define FNTS_SRATIO     0x08           /* Select checkbox for width/height ratio */

FNT_DIALOG *fnts_create(_WORD vdi_handle, _WORD no_fonts, _WORD font_flags, _WORD dialog_flags, const char *sample, const char *opt_button);
_WORD fnts_delete(FNT_DIALOG *fnt_dialog, _WORD vdi_handle);
_WORD fnts_open(FNT_DIALOG *fnt_dialog, _WORD button_flags, _WORD x, _WORD y, long id, fix31 pt, _LONG ratio);
_WORD fnts_close(FNT_DIALOG *fnt_dialog, _WORD *x, _WORD *y);
_WORD fnts_do(FNT_DIALOG *fnt_dialog, _WORD button_flags, _LONG id_in, _LONG pt_in, _LONG ratio_in, _WORD *check_boxes, _LONG *id, _LONG *pt, _LONG *ratio);

/* vst_error return values */
#undef NO_ERROR /* clashes with Win32 */
#define NO_ERROR		0
#define CHAR_NOT_FOUND	1
#define FILE_READERR 	8
#define FILE_OPENERR 	9
#define BAD_FORMAT		10
#define CACHE_FULL		11
#define MISC_ERROR		(-1)

#endif


#define MGCOPY_NAME "MGCOPY.APP"
#define MGCOPY_PATH "C:\\GEMSYS\\GEMDESK\\MGCOPY.APP"


int main(void)
{
	char *server_name;
	int i;
	int done;
	long old_sp;
	_WORD message[8];
	char filename[32];

	server_name = getenv("AVSERVER");
	if (server_name == NULL)
		return 0;
	if (strcmp(server_name, "AVSERVER") != 0)
	{
		if (_app)
			return 0;
		/* not quite right: no appl_init() done yet */
		for (;;)
			evnt_timer(0xff00, 0xff00); /* XXX 101f0 */
	}
	
	gl_apid = appl_init();
	if (gl_apid < 0)
		return -1;
	
	for (i = 0; i < MAX_CLIENTS; i++)
		clients[i].apid = -1;
	for (i = 0; i < MAX_WINDS; i++)
		windows[i].winid = -1;
	for (i = 0; i < MAX_PROGS; i++)
		programs[i].apid = -1;
	
	avserver_info.maxclients = MAX_CLIENTS;
	avserver_info.maxwindows = MAX_WINDS;
	avserver_info.maxprograms = MAX_PROGS;
	avserver_info.clients = clients;
	avserver_info.windows = windows;
	avserver_info.programs = programs;
	av_protokoll3 = VA_PROT_SENDKEY |
		VA_PROT_OPENWIND |
		VA_PROT_STARTPROG |
		VA_PROT_ACCWINDOPEN |
		VA_PROT_ACCWINDCLOSED |
		VA_PROT_STATUS |
		VA_PROT_PATH_UPDATE |
		VA_PROT_WHAT_IZIT |
		VA_PROT_EXIT |
		VA_PROT_XWIND;
	av_protokoll4 = VA_PROT_COPYFILE | VA_PROT_DELFILE | VA_PROT_VIEW;
	done = FALSE;
	dd_data = NULL;
	old_sp = Super(0);
	sp_offset = _longframe ? 8 : 6;
	SuperToUser((void *)old_sp);
	Supexec(install_aes_trap);
	Setexc(0x102, etv_term);
	
	while (!done)
	{
		evnt_mesag(message);
		magxdesk = appl_find("MAGXDESK");

		if (message[0] == AP_TERM)
		{
			int any_active;
			
			any_active = -1;
			for (i = 0; i < MAX_CLIENTS; i++)
			{
				if (clients[i].apid != -1)
					any_active = 1;
			}
			for (i = 0; i < MAX_WINDS; i++)
			{
				if (windows[i].winid != -1)
					any_active = 1;
			}
			if (any_active == -1 ||
				message[5] == AP_TERM ||
				message[5] == AP_RESCHG ||
				form_alert(1, "[3][AV-Server: AV-Clients are|still active. Do you really|want to quit the AV-Server?][Cancel|Quit]") == 2)
				done = TRUE;
		}
		
		if (!done)
			check_apps();
		
		if (message[0] == SH_WDRAW)
			appl_write(magxdesk, 16, message);
		
		/*
		 * The AP_DRAGDROP message will be redirected
		 * here by our aes_trap
		 */
		if (message[0] == AP_DRAGDROP)
		{
			long fd;
			
			strcpy(filename, "U:\\PIPE\\DRAGDROP.AA");
			filename[18] = message[7] & 0xff;
			filename[17] = ((unsigned short)message[7] & 0xff00) >> 8;
			fd = Fopen(filename, FO_RW);
			if (fd >= 0)
			{
				if (ap_dragdrop((int)fd, message[4], message[5], message[3], ap_dragdrop_id) == FALSE)
					appl_write(ap_dragdrop_id, 16, message);
			} else
			{
				error_dragdrop();
			}
		}
		
		if (message[0] == AV_PROTOKOLL)
			av_protokoll(message);
		
		if (message[0] == AV_EXIT)
			av_exit(message);
		
		if (message[0] == AV_DRAG_ON_WINDOW)
			av_drag_on_window(message);
		
		if (message[0] == AV_PATH_UPDATE)
			av_path_update(message);
		
		if (message[0] == AV_WHAT_IZIT)
			av_what_izit(message);
		
		if (message[0] == AV_ACCWINDOPEN)
			av_accwindopen(message);
		
		if (message[0] == AV_ACCWINDCLOSED)
			av_accwindclosed(message);
		
		if (message[0] == AV_STARTPROG)
			av_startprog(message);
		
		if (message[0] == VA_PROGSTART)
			va_progstart(message);
		
		if (message[0] == AV_SENDKEY)
			av_sendkey(message);
		
		if (message[0] == AV_XWIND)
			av_xwind(message);
		
		if (message[0] == AV_OPENWIND)
			av_openwind(message);
		
		if (message[0] == AV_VIEW)
			av_view(message);
		
		if (message[0] == AV_STATUS)
			av_status(message);
		
		if (message[0] == AV_GETSTATUS)
			av_getstatus(message);

		if (message[0] == AV_COPYFILE)
			av_copyfile(message);
		
		if (message[0] == AV_DELFILE)
			av_delfile(message);
		
		if (message[0] == AV_SERVER_INFO)
			av_server_info(message);
		
		if (message[0] == FONT_SELECT)
			font_select(message);
		
		if (message[0] == VA_START)
			va_start_();
	}
	appl_exit();
	
	return 0;
}


static void va_start_(void)
{
	form_alert(1, "[3][AV-Server " VERSION " (" DATE ")|Copyright (c)1996-98 by Alex Barton,|all rights reserved. This program is|freeware. E-mail: <alex@barton.de>][ OK ]");
	/* FIXME: should reply with AV_STARTED */
}


static void etv_term(void)
{
	/* uninstall from AES trap */
	if (xbra_unlink(34) == FALSE)
		error_internal();
}


static void av_protokoll(_WORD *message)
{
	char name[MAX_APPNAME * 2];
	int slot;
	int i;
	_WORD apid;
	const char *clientname;
	const char **pp;
	
	pp = ((const char **)&message[6]);
	clientname = *pp;
	strncpy(name, clientname, MAX_APPNAME);
	name[MAX_APPNAME] = '\0';
	slot = -1;
	for (i = 0; i < MAX_CLIENTS; i++)
	{
		if (strcmp(name, clients[i].name) == 0)
			slot = i;
		if (slot != -1)
			break;
	}
	if (slot == -1)
	{
		for (i = 0; i < MAX_CLIENTS; i++)
			if (clients[i].apid == -1)
				slot = i;
	}
	if (slot != -1)
	{
		clients[slot].apid = message[1];
		clients[slot].capabilities = message[3];
		strcpy(clients[slot].name, name);
		apid = message[1];
		message[0] = VA_PROTOSTATUS;
		message[1] = gl_apid;
		message[2] = 0;
		message[3] = av_protokoll3;
		message[4] = av_protokoll4;
		message[5] = 0;
		/* BUG: will crash with MP */
		message[6] = (_WORD)((long)progname >> 16);
		message[7] = (_WORD)((unsigned int)(unsigned long)progname) & 0xffffu;
		appl_write(apid, 16, message);
	} else
	{
		error_overflow();
	}
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_exit(_WORD *message)
{
	int i;
	int slot;
	
	slot = -1;
	/*
	 * search for apid from protocol
	 */
	for (i = 0; i < MAX_CLIENTS; i++)
	{
		if (clients[i].apid == message[3])
			slot = i;
	}
	if (slot == -1)
	{
		/*
		 * search for apid of sender
		 */
		slot = -1;
		for (i = 0; i < MAX_CLIENTS; i++)
		{
			if (clients[i].apid == message[1])
				slot = i;
		}
	}
	if (slot != -1)
	{
		for (i = 0; i < MAX_WINDS; i++)
		{
			if (windows[i].apid == clients[slot].apid)
			{
				windows[i].winid = -1;
				windows[i].apid = -1;
			}
		}
		clients[slot].apid = -1;
		clients[slot].capabilities = 0;
	}
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_server_info(_WORD *message)
{
	const char *p;
	_WORD apid;
	
	p = (const char *)&avserver_info;
	apid = message[1];
	message[0] = VA_SERVER_INFO;
	message[1] = gl_apid;
	message[2] = 0;
	message[3] = 0;
	message[6] = 0;
	message[7] = 0;
	message[4] = (_WORD)((long)p >> 16);
	message[5] = (_WORD)((unsigned int)(unsigned long)p) & 0xffffu;
	/* XXX: registers loaded in different order */
	appl_write(apid, 16, message);
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_accwindopen(_WORD *message)
{
	int slot;
	int i;
	
	slot = -1;
	for (i = 0; i < MAX_WINDS; i++)
		if (windows[i].winid == message[3])
			slot = 1;
	if (slot == -1)
	{
		slot = -1;
		for (i = 0; i < MAX_WINDS; i++)
		{
			if (windows[i].winid == -1)
				slot = i;
		}
		if (slot != -1)
		{
			windows[slot].apid = message[1];
			windows[slot].winid = message[3];
		} else
		{
			error_overflow();
		}
	}
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_accwindclosed(_WORD *message)
{
	int i;
	
	for (i = 0; i < MAX_WINDS; i++)
	{
		if (windows[i].winid == message[3])
		{
			windows[i].winid = -1;
			windows[i].apid = -1;
		}
	}
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_startprog(_WORD *message)
{
	int slot;
	int i;
	char *name;
	char **pp;
	
	slot = -1;
	for (i = 0; i < MAX_PROGS; i++)
	{
		if (programs[i].apid == -1)
			slot = i;
	}
	if (slot != -1)
	{
		programs[slot].msg_extra = message[7];
		programs[slot].apid = message[1];
		pp = ((char **)&message[3]);
		name = *pp;;
		/*
		 * BUG: will crash with MP if memory is read-only
		 */
		if (setter.av_startprog_upper)
			strupr(name);
		strcpy(startprog_path, name);
		name = strrchr(startprog_path, '\\'); /* FIXME: handle also '/' */
		if (name != NULL)
		{
			name++;
			strcpy(startprog_name, name);
		} else
		{
			strncpy(startprog_name, startprog_path, MAX_APPNAME);
		}
		name = strchr(startprog_name, '.');
		if (name != NULL)
			*name = '\0';
		strcat(startprog_name, "        ");
		startprog_name[MAX_APPNAME] = '\0';
		strcpy(programs[slot].name, startprog_name);
		message[1] = gl_apid;
		message[7] = 0x7d00 + slot;
		appl_write(magxdesk, 16, message);
	} else
	{
		error_overflow();
	}
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void va_progstart(_WORD *message)
{
	int slot;
	
	if (message[7] != 0x3e81) /* if message was not sent from av_view() */
	{
		slot = message[7] - 0x7d00;
		if (slot >= 0 && slot < MAX_PROGS)
		{
			message[1] = gl_apid;
			message[7] = programs[slot].msg_extra;
			if (appl_find(programs[slot].name) < 0)
				message[3] = 0;
			else
				message[3] = 1;
			appl_write(programs[slot].apid, 16, message);
			programs[slot].apid = -1;
		} else if (message[7] != 0x3e80) /* if message was not sent from av_drag_on_window() */
		{
			error_internal();
		}
	}
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_sendkey(_WORD *message)
{
	_WORD scancode;
	
	scancode = message[4] >> 8;
	if (message[3] == K_CTRL && scancode == 0x11) /* BUG: 0x11 is not always scancode for 'W', should look at ascii code */
	{
		cycle_windows();
	} else
	{
		if (magxdesk >= 0 && scancode > 0 && scancode <= 0x39)
		{
			if (message[3] == (K_ALT | K_LSHIFT) ||
				message[3] == (K_ALT | K_RSHIFT) ||
				message[3] == (K_CTRL | K_LSHIFT) ||
				message[3] == (K_CTRL | K_RSHIFT))
			{
				message[0] = AV_XWIND;
				message[2] = 0;
				/* WTF. Keytbl() instead */
				sprintf(startprog_path, "%c:\\", keyboard_table[scancode]);
				message[3] = (_WORD)((long)startprog_path >> 16);
				message[4] = (_WORD)((unsigned int)(unsigned long)startprog_path) & 0xffffu;
				strcpy(startprog_name, "*");
				message[5] = (_WORD)((long)startprog_name >> 16);
				message[6] = (_WORD)((unsigned int)(unsigned long)startprog_name) & 0xffffu;
				message[7] = 0;
				appl_write(magxdesk, 16, message);
			}
		}
	}
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_path_update(_WORD *message)
{
	char **pp;
	char *path;
	
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
	pp = (char **)&message[3];
	if (pp != NULL) /* FIXME: cannot be NULL */
	{
		path = *pp;
		if (path != NULL)
		{
			/* FIXME: check for setter.av_startprog_upper */
			strupr(path);
			message[0] = SH_WDRAW;
			message[1] = gl_apid;
			message[2] = 0;
			/* FIXME: check for absolute path with drive */
			/* FIXME: check for drive > 'Z' */
			message[3] = path[0] - 'A';
			message[4] = 0;
			message[5] = 0;
			message[6] = 0;
			message[7] = 0;
			/* BUG: send to magxdesk */
			appl_write(0, 16, message);
			/* mark message as handled */
			message[0] = 0; /* FIXME: unnecessary */
		}
	}
}


static void av_drag_on_window(_WORD *message)
{
	_WORD apid;
	_WORD mox, moy;
	char *names;
	char **pp;
	_WORD success;
	_WORD owner;
	_WORD wh;
	int type;
	
	apid = message[1];
	mox = message[3];
	moy = message[4];
	names = NULL;
	pp = (char **)&message[6];
	if (pp != NULL) /* FIXME: cannot be NULL */
		names = *pp;
	else
		names = NULL;
	if (names != NULL && strlen(names) > sizeof(startprog_path)) /* BUG: must be >= */
	{
		form_alert(1, "[3][AV-Server: Too many objects!][Cancel]");
		message[0] = VA_DRAG_COMPLETE;
		message[1] = gl_apid;
		message[2] = 0;
		message[3] = 0;
	} else
	{
		gen_mgcopy_cmdline(names);
		success = FALSE;
		type = what_izit(mox, moy, &owner); /* FIXME: type not needed below */
		switch (type)
		{
		case VA_OB_FILE:
			if (names != NULL)
			{
				strcpy(startprog_name, names);
				message[0] = AV_STARTPROG;
				message[1] = gl_apid;
				message[2] = 0;
				message[3] = (_WORD)((long)startprog_path >> 16);
				message[4] = (_WORD)((unsigned int)(unsigned long)startprog_path) & 0xffffu;
				message[5] = (_WORD)((long)(startprog_name) >> 16);
				message[6] = (_WORD)((unsigned int)(unsigned long)(startprog_name)) & 0xffffu;
				message[7] = 0x3e80;
				appl_write(magxdesk, 16, message);
				success = TRUE;
			}
			break;
		
		case VA_OB_SHREDDER:
			if (names != NULL)
			{
				startprog_name[2] = 'D';
				success = TRUE;
				strcpy(startprog_path, MGCOPY_NAME);
				if (shel_find(startprog_path) == 0)
					strcpy(startprog_path, MGCOPY_PATH);
				if (shel_write(100, 1, SHW_PARALLEL, startprog_path, startprog_name) == 0)
					error_copy();
			}
			break;
		
		case VA_OB_WINDOW:
			wh = wind_find(mox, moy);
			if (wh > 0)
			{
				wind_get(wh, WF_OWNER, &owner);
				if (owner >= 0)
				{
					strcpy(startprog_path, names);
					message[0] = VA_DRAGACCWIND;
					message[1] = gl_apid;
					message[2] = 0;
					message[3] = wh;
					message[4] = mox;
					message[5] = moy;
					message[6] = (_WORD)((long)startprog_path >> 16);
					message[7] = (_WORD)((unsigned int)(unsigned long)startprog_path) & 0xffffu;
					appl_write(owner, 16, message);
					success = TRUE;
				}
			}
			break;
		
		case VA_OB_FOLDER:
			wh = wind_find(mox, moy); /* FIXME: no check for valid window handle */
			wind_get(wh, WF_OWNER, &owner);
			if (owner >= 0)
			{
				startprog_name[2] = 'C';
				strcat(startprog_name, " ");
				strcat(startprog_name, startprog_path);
				success = TRUE;
				strcpy(startprog_path, MGCOPY_NAME);
				if (shel_find(startprog_path) == 0)
					strcpy(startprog_path, MGCOPY_PATH);
				if (shel_write(100, 1, SHW_PARALLEL, startprog_path, startprog_name) == 0)
					error_copy();
			}
			break;
		
		case VA_OB_DRIVE:
			if (names != NULL)
			{
				startprog_name[2] = 'C';
				strcat(startprog_name, " ");
				strcat(startprog_name, startprog_path); /* BUG? should be names */
				success = TRUE;
				strcpy(startprog_path, MGCOPY_NAME);
				if (shel_find(startprog_path) == 0)
					strcpy(startprog_path, MGCOPY_PATH);
				if (shel_write(100, 1, SHW_PARALLEL, startprog_path, startprog_name) == 0)
					error_copy();
			}
			break;
		}
		message[0] = VA_DRAG_COMPLETE;
		message[1] = gl_apid;
		message[2] = 0;
		message[3] = success;
	}
	message[4] = 0;
	message[5] = 0;
	message[6] = 0;
	message[7] = 0;
	appl_write(apid, 16, message);
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_what_izit(_WORD *message)
{
	_WORD apid;
	_WORD mox, moy;
	int type;
	_WORD owner;
	
	mox = message[3];
	moy = message[4];
	type = what_izit(mox, moy, &owner);
	apid = message[1];
	message[0] = VA_THAT_IZIT;
	message[1] = gl_apid;
	message[2] = 0;
	message[3] = owner;
	message[4] = type;
	message[5] = 0;
	message[6] = 0;
	message[7] = 0;
	if (startprog_path[0] != '\0' && type != VA_OB_UNKNOWN)
	{
		message[5] = (_WORD)((long)startprog_path >> 16);
		message[6] = (_WORD)((unsigned int)(unsigned long)startprog_path) & 0xffffu;
	}
	appl_write(apid, 16, message);
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_xwind(_WORD *message)
{
	/* just forward */
	appl_write(magxdesk, 16, message);
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_openwind(_WORD *message)
{
	message[7] = 0;
	message[0] = AV_XWIND;
	appl_write(magxdesk, 16, message);
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_view(_WORD *message)
{
	_WORD apid;
	
	apid = message[1];
	message[0] = AV_STARTPROG;
	message[1] = gl_apid;
	message[2] = 0;
	message[5] = 0;
	message[6] = 0;
	message[7] = 0x3e81;
	appl_write(magxdesk, 16 + message[2], message); /* FIXME: message[2] was cleared above */
	/* send reply */
	message[0] = VA_VIEWED;
	message[1] = gl_apid;
	message[2] = 0;
	message[3] = 1;
	message[4] = 0;
	message[5] = 0;
	message[6] = 0;
	message[7] = 0;
	appl_write(apid, 16, message);
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_status(_WORD *message)
{
	int i;
	int slot;
	char *p;
	FILE *fp;
	FILE *out;
	int found;
	char **pp;
	char *str;
	
	slot = -1;
	for (i = 0; i < MAX_CLIENTS; i++)
		if (clients[i].apid == message[1])
			slot = i;
	if (slot == -1)
		return;

	p = getenv("ETCDIR");
	if (p == NULL)
		p = getenv("ETC");
	if (p == NULL)
	{
		strcpy(startprog_name, "\\AVSERVER.INF");
	} else
	{
		strcpy(startprog_name, p);
		if (startprog_name[strlen(startprog_name) - 1] != '\\')
			strcat(startprog_name, "\\");
		strcat(startprog_name, "AVSERVER.INF");
	}
	fp = fopen(startprog_name, "r");
	/* BUG: no NULL check here */
	p = strrchr(startprog_name, '.');
	if (p == NULL)
	{
		fclose(fp);
		return;
	}
	*p = '\0';
	strcat(startprog_name, ".NEW");
	out = fopen(startprog_name, "w");
	/* BUG: no NULL check here */
	found = FALSE;
	while (!feof(fp))
	{
		fgets(startprog_path, 256, fp);
		if (feof(fp))
			break;
		if (startprog_path[strlen(startprog_path) - 1] == '\n')
			startprog_path[strlen(startprog_path) - 1] = '\0';
		p = strchr(startprog_path, '\001');
		if (p != NULL)
		{
			*p = '\0';
			p++;
			if (strcmp(startprog_path, clients[slot].name) == 0)
			{
				pp = (char **)&message[3];
				str = *pp;
				if (!found && str != NULL && str[0] != '\0')
				{
					fprintf(out, "%s\001%s\n", clients[slot].name, str);
				}
				found = TRUE;
			} else
			{
				*--p = '\001';
				fprintf(out, "%s\n", startprog_path);
			}
		} else
		{
			fprintf(out, "%s\n", startprog_path);
		}
	}
	if (!found)
	{
		pp = (char **)&message[3];
		str = *pp;
		/* BUG: str can be NULL */
		fprintf(out, "%s\001%s\n", clients[slot].name, str);
	}
	
	fclose(fp);
	fclose(out);
	strcpy(startprog_path, startprog_name);
	p = strrchr(startprog_path, '.');
	*p = '\0';
	strcat(startprog_path, ".INF");
	unlink(startprog_path);
	rename(startprog_name, startprog_path);
	
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_getstatus(_WORD *message)
{
	_WORD apid;
	int i;
	int slot;
	char *p;
	FILE *fp;
	int found;
	
	apid = message[1];
	slot = -1;
	for (i = 0; i < MAX_CLIENTS; i++)
		if (clients[i].apid == apid)
			slot = i;
	if (slot == -1)
	{
		message[0] = VA_SETSTATUS;
		message[1] = gl_apid;
		message[2] = 0;
		message[3] = 0;
		message[4] = 0;
		message[5] = 0;
		message[6] = 0;
		message[7] = 0;
		appl_write(apid, 16, message);
	} else
	{
		p = getenv("ETCDIR");
		if (p == NULL)
			p = getenv("ETC");
		if (p == NULL)
		{
			strcpy(startprog_name, "\\AVSERVER.INF");
		} else
		{
			strcpy(startprog_name, p);
			if (startprog_name[strlen(startprog_name) - 1] != '\\')
				strcat(startprog_name, "\\");
			strcat(startprog_name, "AVSERVER.INF");
		}
		found = FALSE;
		fp = fopen(startprog_name, "r");
		if (fp != NULL)
		{
			while (!feof(fp))
			{
				fgets(startprog_path, 256, fp);
				if (feof(fp))
					break;
				if (startprog_path[strlen(startprog_path) - 1] == '\n')
					startprog_path[strlen(startprog_path) - 1] = '\0';
				p = strchr(startprog_path, '\001');
				if (p != NULL)
				{
					*p = '\0';
					p++;
					if (strcmp(startprog_path, clients[slot].name) == 0)
					{
						found = TRUE;
						strcpy(startprog_name, p);
					}
				}
				if (found)
					break;
			}
			fclose(fp);
		}

		message[0] = VA_SETSTATUS;
		message[1] = gl_apid;
		message[2] = 0;
		message[3] = 0;
		message[4] = 0;
		if (found)
		{
			message[3] = (_WORD)((long)startprog_name >> 16);
			message[4] = (_WORD)((unsigned int)(unsigned long)startprog_name) & 0xffffu;
		}
		message[5] = 0;
		message[6] = 0;
		message[7] = 0;
		appl_write(apid, 16, message);

		/* mark message as handled */
		message[0] = 0; /* FIXME: unnecessary */
	}
}


static void av_copyfile(_WORD *message)
{
	_WORD apid;
	char **pp;
	char *names;

	apid = message[1];
	pp = (char **)&message[3];
	if (pp != NULL) /* FIXME: cannot be NULL */
		names = *pp;
	else
		names = NULL;
	gen_mgcopy_cmdline(names);
	pp = (char **)&message[5];
	if (pp != NULL) /* FIXME: cannot be NULL */
		names = *pp;
	else
		names = NULL;
	message[0] = VA_FILECOPIED;
	message[1] = gl_apid;
	message[2] = 0;
	message[3] = 0;
	message[4] = 0;
	message[5] = 0;
	message[6] = 0;
	message[7] = 0; /* BUG: will be needed below */
	if (names != NULL)
	{
		strcat(startprog_name, " ");
		strcat(startprog_name, names);
		/* move mode? */
		if (message[7] == 1) /* BUG: test only bit #0 */
			startprog_name[2] = 'M';
		else
			startprog_name[2] = 'C';
		strcpy(startprog_path, MGCOPY_NAME);
		if (shel_find(startprog_path) == 0)
			strcpy(startprog_path, MGCOPY_PATH);
		if (shel_write(100, 1, SHW_PARALLEL, startprog_path, startprog_name) == 0)
			error_copy();
		else
			message[3] = 1;
	}
	appl_write(apid, 16, message);
	
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void av_delfile(_WORD *message)
{
	_WORD apid;
	char **pp;
	char *names;

	apid = message[1];
	pp = (char **)&message[3];
	if (pp != NULL) /* FIXME: cannot be NULL */
		names = *pp;
	else
		names = NULL;
	gen_mgcopy_cmdline(names);
	
	startprog_name[2] = 'D';
	message[0] = VA_FILECOPIED; /* BUG: should be VA_FILEDELETED */
	message[1] = gl_apid;
	message[2] = 0;
	message[3] = 0;
	message[4] = 0;
	message[5] = 0;
	message[6] = 0;
	message[7] = 0;
	
	strcpy(startprog_path, MGCOPY_NAME);
	if (shel_find(startprog_path) == 0)
		strcpy(startprog_path, MGCOPY_PATH);
	if (shel_write(100, 1, SHW_PARALLEL, startprog_path, startprog_name) == 0)
		error_copy();
	else
		message[3] = 1;
	appl_write(apid, 16, message);

	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


/*
 * check all registered clients to be still active.
 * If not, invalidate their entries
 */
static void check_apps(void)
{
	int i;
	int j;
	
	for (i = 0; i < MAX_CLIENTS; i++)
	{
		if (clients[i].apid != -1 && appl_find(clients[i].name) < 0)
		{
			for (j = 0; j < MAX_WINDS; j++)
			{
				if (windows[j].apid == clients[i].apid)
				{
					/* BUG: must use j, not i */
					windows[i].winid = -1;
					windows[i].apid = -1;
				}
			}
			clients[i].apid = -1;
		}
	}
}


/* AP_DRAGDROP return codes */
#define DD_OK        0
#define DD_NAK       1
#define DD_EXT       2
#define DD_LEN       3
#define DD_TRASH     4
#define DD_PRINTER   5
#define DD_CLIPBOARD 6

struct dd_header {
	short hdrlen;
	char type[6];
	long datasize;
	char *obname;
	char *filename;
};

static int dd_getheader(int fd, struct dd_header *header);

/*
 * Perform D&D protocoll.
 * BUG: no signal handler installed to catch SIGPIPE
 */
static int ap_dragdrop(int fd, _WORD mox, _WORD moy, _WORD winid, _WORD apid)
{
	int found;
	int i;
	struct dd_header header;
	_WORD message[8];

	found = FALSE;
	for (i = 0; i < MAX_CLIENTS; i++)
	{
		if (clients[i].apid == apid)
			found = TRUE;
		if (found)
			break;
	}
	if (found)
	{
		found = FALSE;
		for (i = 0; i < MAX_WINDS; i++)
		{
			if (windows[i].winid == winid)
				found = TRUE;
			if (found)
				break;
		}
	}
	if (!found)
	{
		/* BUG: fd not closed */
		return FALSE;
	}

	if (dd_reply(fd, DD_OK))
	{
		if (Fwrite(fd, 32, "ARGS\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0") != 32)
		{
			Fclose(fd);
			error_dragdrop();
		} else
		{
			do
			{
				if (dd_getheader(fd, &header) == FALSE)
				{
					return TRUE;
				}
				if (strncmp("ARGS", header.type, 4) != 0)
				{
					if (dd_reply(fd, DD_EXT))
						continue;
					return TRUE;
				}
				if (dd_data != NULL)
					free(dd_data);
				dd_data = malloc(header.datasize);
				if (dd_data == NULL)
				{
					if (dd_reply(fd, DD_LEN))
						continue;
					return TRUE;
				}
				if (dd_reply(fd, DD_OK) == FALSE)
					return TRUE;
				if (Fread(fd, header.datasize, dd_data) != header.datasize)
				{
					dd_reply(fd, DD_NAK);
					Fclose(fd);
					error_dragdrop();
					break;
				}
				found = TRUE;
			} while (!found);
			Fclose(fd);
			if (found)
			{
				message[0] = VA_DRAGACCWIND;
				message[1] = gl_apid;
				message[2] = 0;
				message[3] = winid;
				message[4] = mox;
				message[5] = moy;
				message[6] = (_WORD)((long)dd_data >> 16);
				message[7] = (_WORD)((unsigned int)(unsigned long)dd_data) & 0xffffu;
				appl_write(apid, 16, message);
			}
		}
	}
	
	return TRUE;
}


static void cycle_windows(void)
{
	_WORD top;
	_WORD message[8];
	int tries;
	int topslot;
	int bottomslot;
	int i;
	
	wind_get(0, WF_TOP, &top);
	if (top == 0)
		return;
	tries = 0;
	do
	{
		topslot = -1;
		bottomslot = -1;
		for (i = 0; i < MAX_WINDS; i++)
			if (windows[i].winid == top)
				topslot = i;
		if (topslot == -1)
			topslot = 0;
		for (i = topslot + 1; i < MAX_WINDS; i++)
			if (windows[i].winid != -1)
			{
				bottomslot = i;
				break;
			}
		if (bottomslot == -1)
		{
			for (i = 0; i < topslot; i++)
				if (windows[i].winid != -1)
				{
					bottomslot = i;
					break;
				}
		}
		if (bottomslot == -1)
			break;
		message[0] = WM_TOPPED;
		message[1] = gl_apid;
		message[2] = 0;
		message[3] = windows[bottomslot].winid;
		message[4] = 0;
		message[5] = 0;
		message[6] = 0;
		message[7] = 0;
		appl_write(windows[bottomslot].apid, 16, message);
		evnt_timer(250, 0);
		wind_get(0, WF_TOP, &top);
		if (top == 0)
			break;
		if (top == windows[bottomslot].winid)
			break;
		check_apps();
		evnt_timer(500, 0);
		wind_get(0, WF_TOP, &top);
		if (top == 0)
			break;
		if (top == windows[bottomslot].winid)
			break;
		top = windows[bottomslot].winid;
		/* BUG: tries never incremented */
	} while (tries < 3);
}


#if !defined(__PORTAES_H__) && !defined(__GNUC__)
/*
 * Replacement for wind_get() in pcgemlib.
 * The version in the original library cannot be used,
 * because it does not know about the new WF_* options,
 * and has a fixed table for the "known" values to determine
 * the number of arguments.
 */
static int wnd_get(_WORD handle, _WORD field, _WORD *out1, _WORD *out2, _WORD *out3, _WORD *out4)
{
	AESPB pb;
	
	pb.contrl = _GemParBlk.contrl;
	pb.global = _GemParBlk.global;
	pb.intin = _GemParBlk.intin;
	pb.intout = _GemParBlk.intout;
	_GemParBlk.contrl[0] = 104;
	_GemParBlk.contrl[1] = 2;
	_GemParBlk.contrl[2] = 5;
	_GemParBlk.contrl[3] = 0;
	_GemParBlk.contrl[4] = 0;
	_GemParBlk.intin[0] = handle;
	_GemParBlk.intin[1] = field;
	_crystal(&pb);
	if (out1 != NULL)
		*out1 = _GemParBlk.intout[1];
	if (out2 != NULL)
		*out2 = _GemParBlk.intout[2];
	if (out3 != NULL)
		*out3 = _GemParBlk.intout[3];
	if (out4 != NULL)
		*out4 = _GemParBlk.intout[4];
	return _GemParBlk.intout[0];
}
#else
#define wnd_get wind_get
#endif


static int xbra_unlink(int vec)
{
	char cont;
	char xbra_ok;
	char slot;
	long *addr;
	long *xbra;
	
	cont = TRUE;
	xbra_ok = TRUE;
	slot = 0;
	addr = (long *)Setexc(vec, (void (*)(void))-1);
#if 0
	xbra = addr - 3;
#else
	xbra = (long *)((long)addr - 12);
#endif
	do
	{
		if (xbra[0] == 0x58425241L) /* 'XBRA' */
		{
			if (xbra[1] == C_AVSV)
			{
				if (slot != 0)
				{
					/*
					 * there was another TSR in the chain, replace
					 * its previous vector
					 */
					*addr = xbra[2];
				} else
				{
					/*
					 * no other TSR, restore system vector
					 */
					Setexc(vec, (void (*)(void))xbra[2]);
				}
				cont = FALSE;
			} else
			{
#if 0
				addr = xbra + 2;
				xbra = (long *)(*addr) - 3;
#else
				addr = (long *)((long)xbra + 8);
				xbra = (long *)(*addr - 12);
#endif
				slot++;
			}
		} else
		{
			xbra_ok = FALSE;
		}
	} while (cont && xbra_ok);
	if (cont)
		return FALSE;
	return TRUE;
}


static int dd_getheader(int fd, struct dd_header *header)
{
	void *data;
	int error = FALSE;
	short hdrlen;
	
	data = malloc(2048);
	if (data == NULL)
	{
		dd_reply(fd, DD_NAK);
		Fclose(fd);
		return FALSE;
	}
	if (Fread(fd, sizeof(header->hdrlen), &header->hdrlen) < (long)sizeof(header->hdrlen))
		error = TRUE;
	if (header->hdrlen < 9)
		error = TRUE;
	if (Fread(fd, 4, header->type) < 4)
	{
		error = TRUE;
		header->type[0] = '\0';
	} else
	{
		header->type[4] = '\0';
	}
	if (Fread(fd, sizeof(header->datasize), &header->datasize) < (long)sizeof(header->datasize))
		error = TRUE;
	header->obname = NULL;
	header->filename = NULL;
	if (!error)
	{
		hdrlen = header->hdrlen - 8;
		while (hdrlen > 0)
		{
			long count = Fread(fd, hdrlen < 2048 ? hdrlen : 2048, data);
			if (count < 1)
				error = TRUE;
			else
				hdrlen -= count;
			if (error)
				break;
		}
	}
	if (error || hdrlen > 0)
	{
		dd_reply(fd, DD_NAK);
		Fclose(fd);
		error_dragdrop();
		return FALSE;
	}
	/*
	 * BUG: obname/filename are not returned to caller,
	 * and data is leaked
	 */
	return TRUE;
}


static int dd_reply(int fd, char ack)
{
	if (Fwrite(fd, 1, &ack) == 1)
		return TRUE;
	Fclose(fd);
	error_dragdrop();
	return FALSE;
}


static int what_izit(_WORD mox, _WORD moy, _WORD *owner)
{
	int type;
	_WORD winid;
	union {
		_WORD kind;
		struct {
			_WORD hi;
			_WORD lo;
		} name;
	} info;
	int i;
	_WORD dummy;
	A_MAN *aman;
	char *name;
	void **pp;
	
	type = VA_OB_UNKNOWN;
	*owner = -1;
	startprog_path[0] = '\0';
	winid = wind_find(mox, moy);
	if (winid > 0)
	{
		for (i = 0; i < MAX_WINDS; i++)
		{
			if (windows[i].winid == winid)
				*owner = windows[i].apid;
		}
		if (*owner == -1)
		{
			wind_get(winid, WF_OWNER, owner);
			if (*owner != magxdesk)
				*owner = -1;
		}
		if (*owner != -1)
		{
			type = VA_OB_WINDOW;
			wnd_get(winid, WF_KIND, &info.kind, NULL, NULL, NULL);
			if (info.kind & NAME)
			{
				if (get_cookie("AmAN", (void **)&aman))
				{
					wnd_get(winid, WF_NAME, &info.name.hi, &info.name.lo, NULL, NULL);
					pp = (void **)&info.name;
					name = *pp;
					if (name != NULL)
					{
						if (*name == ' ')
							name++;
						strcpy(startprog_path, name);
						if (startprog_path[strlen(startprog_path) - 1] == ' ')
							startprog_path[strlen(startprog_path) - 1] = '\0';
					}
				} else
				{
					error_no_aman();
					type = VA_OB_UNKNOWN;
				}
			}
		}
	}
	
	if (winid == 0)
	{
		OBJECT *tree;
		_WORD obj;
		ICONBLK *iconblk;
		
		wind_get(0, WF_NEWDESK, &info.name.hi, &info.name.lo, &dummy);
		pp = (void **)&info.name;
		tree = *pp;
		if (tree != NULL)
		{
			obj = objc_find(tree, ROOT, MAX_DEPTH, mox, moy);
			if (obj > 0)
			{
				if (tree[obj].ob_type == G_ICON || tree[obj].ob_type == G_CICON)
				{
					iconblk = tree[obj].ob_spec.iconblk;
					strcpy(startprog_path, iconblk->ib_ptext);
					i = iconblk->ib_char;
					name = (char *)&i;
					name++;
					*owner = magxdesk;
					if (name != NULL && *name != '\0') /* FIXME: cannot be NULL */
					{
						type = VA_OB_DRIVE;
						sprintf(startprog_path, "%c:\\\0", *name); /* FIXME: \0? */
					} else
					{
						if (strcmp(startprog_path, "PAPIERKORB") == 0) /* FIXME: language dependant */
							type = VA_OB_SHREDDER;
						if (strcmp(startprog_path, "DRUCKER") == 0) /* FIXME: language dependant */
						{
							type = VA_OB_FILE;
							strcpy(startprog_path, "U:\\DEV\\PRN");
						}
						if (type == VA_OB_UNKNOWN)
						{
							FILE *fp;

							strcpy(startprog_name, "MAGX.INF");
							if (shel_find(startprog_name) != 0 && (fp = fopen(startprog_name, "r")) != NULL)
							{
								i = 0;
								while (!feof(fp))
								{
									fgets(startprog_name, 126, fp);
									
									if (strncmp(startprog_name, "#_DIC ", 6) == 0)
										i++;
									/*
									 * for icontypes see https://github.com/th-otto/MagicMac/blob/951522e6c949672cae888ebaa3695ef7ed0e4eaf/apps/magxdesk.5/k.h
									 */
									if ((strncmp(startprog_name, "#_DIC 6 @ ", 10) == 0 ||
										 strncmp(startprog_name, "#_DIC 7 @ ", 10) == 0 ||
										 strncmp(startprog_name, "#_DIC 8 @ ", 10) == 0) &&
										 i == obj)
									{
										name = strrchr(startprog_name, ' ');
										if (name != NULL) /* FIXME: cannot be NULL */
										{
											if (startprog_name[strlen(startprog_name) - 1] == '\n')
												startprog_name[strlen(startprog_name) - 1] = '\0';
											name++;
											strcpy(startprog_path, name);
											type = VA_OB_FILE;
										}
									}
									if (i >= obj)
										break;
								}
								fclose(fp);
							} else
							{
								error_magx_inf();
							}
							if (type == VA_OB_UNKNOWN && shel_find(startprog_path) != 0)
								type = VA_OB_FILE;
						}
					}
				}
			} else
			{
				type = VA_OB_UNKNOWN;
			}
		}
	}
	
	if (type == VA_OB_FILE)
	{
		if (Fattrib(startprog_path, 0, 0) & FA_SUBDIR)
			type = VA_OB_FOLDER;
	} else if (type != VA_OB_UNKNOWN)
	{
		if (startprog_path[1] != ':')
		{
			strcpy(startprog_path, "");
		} else
		{
			name = strrchr(startprog_path, '\\');
			if (name != NULL)
				name[1] = '\0';
			if (*owner == magxdesk)
				type = VA_OB_FOLDER;
		}
	}
	
	if (type == VA_OB_FOLDER)
	{
		if (startprog_path[strlen(startprog_path) - 1] != '\\')
			strcat(startprog_path, "\\");
	}
	
	return type;
}


static void font_select(_WORD *message)
{
	long fontid;
	fix31 fontsize;
	_LONG ratio;
	_WORD workin[11];
	_WORD vdi_handle;
	_WORD error;
	_WORD check_boxes;
	_WORD i;
	FNT_DIALOG *dialog;
	_WORD button;
	_WORD apid;
	
	/*
	 * FIXME: check whether fnts_* functions are available
	 */
	graf_mouse(BUSYBEE, NULL);
	
	fontid = message[4];
	fontsize = (long)message[5] << 16;
	ratio = 1L << 16;
	for (i = 1; i < 10; i++)
		workin[i] = 1;
	workin[0] = Getrez() + 2; /* FIXME: use 1 for current resolution */
	workin[10] = 2;
	vdi_handle = graf_handle(&i, &i, &i, &i);
	v_opnvwk(workin, &vdi_handle, workout);
	error = 0;
	vst_error(vdi_handle, 0, &error);
	if (error != 0)
		fontselect_error(error);
	dialog = fnts_create(vdi_handle, 0, FNTS_ALL, FNTS_3D, "The quick brown fox jumps over the lazy dog.", NULL);
	if (error != 0)
		fontselect_error(error);
	graf_mouse(ARROW, NULL);
	
	button = fnts_do(dialog, FNTS_SNAME | FNTS_SSTYLE | FNTS_SSIZE, fontid, fontsize, ratio, &check_boxes, &fontid, &fontsize, &ratio);
	graf_mouse(BUSYBEE, NULL);
	if (button == FNTS_OK)
	{
		message[4] = (_WORD)fontid;
		message[5] = (_WORD)(fontsize >> 16);
	}
	apid = message[1];
	message[0] = FONT_CHANGED;
	message[1] = gl_apid;
	message[2] = 0;
	appl_write(apid, 16, message);
	if (error != 0)
		fontselect_error(error);
	fnts_delete(dialog, vdi_handle);
	graf_mouse(ARROW, NULL);
	v_clsvwk(vdi_handle);
	
	/* mark message as handled */
	message[0] = 0; /* FIXME: unnecessary */
}


static void gen_mgcopy_cmdline(char *names)
{
	char *end;
	char *start;
	long ret;
	char buf[16];
	
	if (names != NULL)
	{
		strcpy(startprog_path, names);
		strcat(startprog_path, " ");
		start = startprog_path;
		strcpy(startprog_name, "\xff-?cfq");
		end = strchr(startprog_path, ' ');
		while (end != NULL)
		{
			*end = '\0';
			if (start[strlen(start) - 1] != '\\')
			{
				long filesize;

				ret = Fopen(start, FO_READ);
				filesize = ret; /* XXX to get registers right */
				if (ret > 0)
				{
					short fd;

					fd = (unsigned int)ret;
					filesize = Fseek(0, fd, SEEK_END);
					Fclose(fd);
					ltoa(filesize, buf, 10);
				} else
				{
					strcpy(buf, "1");
				}
				strcat(startprog_name, " ");
				strcat(startprog_name, start);
				strcat(startprog_name, " ");
				strcat(startprog_name, buf);
			} else
			{
				strcat(startprog_name, " ");
				strcat(startprog_name, start);
				strcat(startprog_name, " -1");
			}
			start = end + 1;
			end = strchr(start, ' ');
		}
	}
}


static void fontselect_error(int code)
{
	switch (code)
	{
	case CHAR_NOT_FOUND:
		/* BUG: too many arguments for format */
		sprintf(startprog_path, "[3][AV-Server: VDI Scaler Error:|Character not defined!][Ignore]", code);
		break;
	case FILE_READERR:
		/* BUG: too many arguments for format */
		sprintf(startprog_path, "[3][AV-Server: VDI Scaler Error:|Can't read font!][Ignore]", code);
		break;
	case FILE_OPENERR:
		/* BUG: too many arguments for format */
		sprintf(startprog_path, "[3][AV-Server: VDI Scaler Error:|Can't open font!][Ignore]", code);
		break;
	case BAD_FORMAT:
		/* BUG: too many arguments for format */
		sprintf(startprog_path, "[3][AV-Server: VDI Scaler Error:|Invalid file format!][Ignore]", code);
		break;
	case CACHE_FULL:
		/* BUG: too many arguments for format */
		sprintf(startprog_path, "[3][AV-Server: VDI Scaler Error:|No more memory/cache free!][Ignore]", code);
		break;
	default:
		sprintf(startprog_path, "[3][AV-Server: VDI Scaler Error:|Error code %d!][Ignore]", code);
		break;
	}
	form_alert(1, startprog_path);
}


void error_overflow(void)
{
	form_alert(1, "[3][AV-Server: Overflow!][Cancel]");
}


void error_dragdrop(void)
{
	form_alert(1, "[3][AV-Server: Drag&Drop-Error!][Ignore]");
}


void error_internal(void)
{
	form_alert(1, "[3][AV-Server: Internal error!][Ignore]");
}


void error_copy(void)
{
	form_alert(1, "[3][AV-Server: Can't start|MG-Copy!][Cancel]");
}


void error_no_aman(void)
{
	form_alert(1, "[3][AV-Server: A-MAN not installed.|Can't execute this function!][Cancel]");
}


void error_magx_inf(void)
{
	form_alert(1, "[3][AV-Server: Can't|read MAGX.INF!][Cancel]");
}
