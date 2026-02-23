#include <aes.h>
#include <tos.h>
#include "a-man.h"

#define C_AmAN 0x416D414EL     /* 'AmAN' */
#define _longframe *((short *)0x59e)

#ifndef SuperToUser
#define SuperToUser(sp) Super(sp)
#endif

typedef struct {
	long id;
	long value;
} COOKIE;

COOKIE *install_jar(long size);
#define JARSIZE 10

static long old_sp;
long sp_offset;

extern A_MAN aman;
extern void xbios_trap(void);
extern void *old_xbios_trap;

int main(void)
{
	int slot;
	int exit_code;
	int cont;
	int apid;
	int msgbuf[32];
	COOKIE *jar;
	COOKIE *p;
	
	slot = 0;
	exit_code = 0;
	cont = 0;
	if (_app)
	{
		_GemParBlk.global[0] = 0;
		apid = appl_init();
		if (_GemParBlk.global[0] != 0)
			form_alert(1, "[3][A-MAN kann nur aus dem|AUTO-Ordner gestartet|werden!][ OK ]");
		else
			cont = 1;
	} else
	{
		apid = appl_init();
		if (apid >= 0)
		{
			if ((unsigned int)menu_register(apid, "  A-MAN") != 0xffff)
			{
				for (;;)
				{
					do
					{
						evnt_mesag(msgbuf);
					} while (msgbuf[0] != AC_OPEN);
					form_alert(1, "[3][Bitte A-MAN nur aus dem|AUTO-Ordner starten!][ OK ]");
				}
			}
			appl_exit();
		}
	}
	
	if (cont & 1)
	{
		Cconws("\033p" "A-MAN V1.4 16.04.1995" "\033q" "\n\r");
		Cconws("By Sven Kopacz\n\r");
		old_sp = Super(0);
		jar = *((COOKIE **)0x5a0);
		p = jar;
		sp_offset = _longframe ? 8 : 6;
		SuperToUser((void *)old_sp);
		if (p == 0)
		{
			p = install_jar(JARSIZE);
			slot = 0;
		} else
		{
			while (p->id != 0 && p->id != C_AmAN)
			{
				p++;
				slot++;
			}
		}
		if (p->id == 0)
		{
			long save;
			
			/*
			 * FIXME: no need to install new jar if there is an empty slot
			 */
			if (p->value - slot < JARSIZE)
			{
				/* BUG: will be negative if slot > JARSIZE */
				p = install_jar((p->value + JARSIZE) - (p->value - slot));
				while (jar->id != 0)
				{
					*p++ = *jar++;
				}
				p->id = 0;
				p->value = (jar->value + JARSIZE) - (jar->value - slot);
			}
			save = p->value;
			p->id = C_AmAN;
			p->value = (long)&aman;
			p++;
			p->id = 0;
			p->value = save;
			old_xbios_trap = Setexc(45, xbios_trap);
			Cconws("Installiert");
			Ptermres(_PgmSize, 0);
			return exit_code;
		} else
		{
			Cconws("Fehler: Bereits installiert");
		}
	}
	exit_code = 1;

	return exit_code;
}


COOKIE *install_jar(long size)
{
	COOKIE *jar;
	
	jar = Malloc(size * sizeof(*jar));
	Super(0);
	*((COOKIE **)0x5a0) = jar;
	SuperToUser((void *)old_sp); /* BUG: not saved above */
	/* BUG: no malloc check */
	jar->id = 0;
	jar->value = size;
	return jar;
}
