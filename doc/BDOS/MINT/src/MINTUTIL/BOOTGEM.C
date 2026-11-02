#include <osbind.h>
#include <minimal.h>
#include <basepage.h>

typedef void (*VOIDFUNC)();

VOIDFUNC gemaddr;
long _stksize = 4*1024L;

void
getgem()
{
	long ssp;

	ssp = Super(0L);
	gemaddr = *( (VOIDFUNC *) 0x4fe );
	Super(ssp);
}

main()
{
/* get the GEM entry point... */
	getgem();

/* and jump to it; we'd better not ever return! */
	(*gemaddr)(_base);
}
