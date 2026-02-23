#include <syntax.h>
#include <osbind.h>
#include <line_a.c>
#include "B:SINCOS.C"

main()
{
	WORD i, x1, y1, x2, y2;

	la_init();
	for(i = 0; i < 200; ++i) {
		x2 = 320 + i * (icos(i * 30) / 32767.);
		y2 = 200 + i * (isin(i * 30) / 32767.);
		la_draw(320, 200, x2, y2);
		if(i) la_draw(x1, y1, x2, y2);
		x1 = x2;
		y1 = y2;
	}
	Cconin();
}
