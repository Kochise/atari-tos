#include "avserver.h"
#include <tos.h>
#include <stddef.h>
#include <string.h>

struct cookie {
	union {
		char magic[4];
		long end;
	} id;
	void *value;
};

int get_cookie(const char *id, void **value)
{
	long old_sp;
	struct cookie *jar;
	
	old_sp = Super(0);
	jar = *((struct cookie **)0x5a0);
	SuperToUser((void *)old_sp);
	
	if (jar != NULL)
	{
		do
		{
			if (strncmp(jar->id.magic, id, 4) == 0)
			{
				if (value != NULL)
				{
					*value = jar->value;
					return TRUE;
				}
				/* BUG: will loop forever */
			} else
			{
				jar++;
			}
		} while (jar->id.end != 0);
	}
	return FALSE;
}
