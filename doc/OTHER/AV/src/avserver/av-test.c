#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <aes.h>
#include "vaproto.h"
#include "avserver.h"
#include "av-test.h"

char const sccs_id[] = "@(#)AV-Test 1.1 (Jun 24 1996), Copyright (c)1996 by A. Barton";
static char const progname[] = "AV-TEST \0";

static OBJECT *maintree;
static _WORD gl_apid;
static _WORD server_id;

/*
 * forward declarations
 */
static char *rs_str(_WORD idx);
static void set_ptext(OBJECT *tree, _WORD idx, const char *str);


#define YES "JA"
#define NO  "NEIN"


int main(void)
{
	_WORD message[8];
	_WORD dummy;
	_WORD x;
	_WORD y;
	_WORD w;
	_WORD h;
	_WORD mask;
	char **pp;
	char *avserver;
	char servername[32];
	int found;
	int done;
	
	gl_apid = appl_init();
	
	if (rsrc_load("AV-TEST.RSC"))
	{
		rsrc_gaddr(R_TREE, MAIN_DIALOG, &maintree);
		server_id = -1;
		avserver = getenv("AVSERVER");
		if (avserver != NULL)
		{
			strcpy(servername, avserver);
			strcat(servername, "          ");
			servername[8] = '\0';
			server_id = appl_find(servername);
		}
		if (server_id < 0)
			server_id = appl_find("AVSERVER");
		if (server_id < 0)
			server_id = 0;
			
		message[0] = AV_PROTOKOLL;
		message[1] = gl_apid;
		message[2] = 0;
		message[3] = 0;
		message[4] = 0;
		message[5] = 0;
		/* BUG: will crash with MP */
		message[6] = (_WORD)((long)progname >> 16);
		message[7] = (_WORD)((unsigned int)(unsigned long)progname) & 0xffffu;
		appl_write(server_id, 16, message);

		server_id = -1;
		found = FALSE;
		/* BUG: done not initialized */
		do
		{
			_WORD events;
			
			events = evnt_multi(MU_MESAG | MU_TIMER,
				0, 0, 0,
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				message,
				3000, 0,
				&dummy, &dummy, &dummy, &dummy, &mask, &dummy);
			if (events == MU_TIMER)
				done = TRUE;
			if ((events & MU_MESAG) && message[0] == VA_PROTOSTATUS)
			{
				server_id = message[1];
				found = TRUE;
				done = TRUE;
			}
		} while (!done);
		
		if (found && server_id >= 0)
		{
			pp = (char **)&message[6];
			avserver = *pp;
			sprintf(servername, "%s (ID: %d)", avserver, server_id);
			set_ptext(maintree, SERVER_ID, servername);
			mask = 1;
			y = HAS_AV_SENDKEY;
			for (dummy = 1; dummy <= 16; dummy++)
			{
				if (dummy != 15) /* VA_PROT_QUOTING handled below */
				{
					if (message[3] & mask)
						set_ptext(maintree, y, YES);
					else
						set_ptext(maintree, y, NO);
					y++;
				}
				mask += mask;
			}
			mask = 1;
			for (dummy = 0; dummy < 5; dummy++)
			{
				if (message[4] & mask)
					set_ptext(maintree, y, YES);
				else
					set_ptext(maintree, y, NO);
				y++;
				mask += mask;
			}
			if (message[3] & VA_PROT_QUOTING)
				set_ptext(maintree, HAS_AV_QUOTING, YES);
			else
				set_ptext(maintree, HAS_AV_QUOTING, NO);
				
			wind_update(BEG_UPDATE);
			form_center(maintree, &x, &y, &w, &h);
			form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
			form_dial(FMD_GROW, x + w / 2, y + w / 2, 1, 1, x, y, w, h); /* BUG: should be h / 2 */
			objc_draw(maintree, ROOT, MAX_DEPTH, x, y, w, h);
			form_do(maintree, ROOT);
			form_dial(FMD_SHRINK, x + w / 2, y + w / 2, 1, 1, x, y, w, h);
			form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);
			wind_update(END_UPDATE);
			
			message[0] = AV_EXIT;
			message[1] = gl_apid;
			message[2] = 0;
			message[3] = gl_apid;
			message[4] = 0;
			message[5] = 0;
			message[6] = 0;
			message[7] = 0;
			appl_write(server_id, 16, message);
		} else
		{
			form_alert(1, rs_str(AL_NO_AVSERVER));
		}
		rsrc_free();
	} else
	{
		form_alert(1, "[1][AV-Test: Resource|not found!][Cancel]");
	}
	
	appl_exit();
	
	return 0;
}


static char *rs_str(_WORD idx)
{
	char *str;
	
	rsrc_gaddr(R_STRING, idx, &str);
	return str;
}


static void set_ptext(OBJECT *tree, _WORD idx, const char *str)
{
	TEDINFO *ted = tree[idx].ob_spec.tedinfo;
	
	strncpy(ted->te_ptext, str, ted->te_txtlen - 1);
	ted->te_ptext[ted->te_txtlen - 1] = '\0';
}
