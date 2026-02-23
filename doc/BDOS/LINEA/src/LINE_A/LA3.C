



#include <syntax.h>
#include <osbind.h>
#include <line_a.c>
#include "B:SINCOS.C"

main()
{
   WORD a,x,z,i;


   la_init();

   la_draw(0,200,639,200);
   la_draw(320,0,320,399);

  for (a = 1 ; a < 200 ; a += 5 )

  {
         x = i = 0;

         for (x = 0   ; x < 640 ; x ++)


     {
         i++;
         if (i == 360)
            i = 0;

         z = (icos(i)/32767.) * a;
         la_put( x  , z + 200,1 );
         la_put( x  , -z + 200,1 );


     }
  }

   Cconin();

}

