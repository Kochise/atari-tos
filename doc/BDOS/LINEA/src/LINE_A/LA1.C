#include <syntax.h>
#include <osbind.h>
#include <line_a.c>
#include "B:SINCOS.C"

main()
{
	WORD i;

	la_init();
	for(i = 0; i < 640; i += 5)
		la_draw(0, 200, i, 200 + isin(i) / 164);
	Cconin();
}
