/*	VDIBIND.C	2/15/85			John Grant		*/

#include "portab.h"
#include "obdefs.h"

EXTERN WORD contrl[], intin[], ptsin[], intout[], ptsout[];

    WORD
v_opnvwk( work_in, handle, work_out )
WORD work_in[], *handle, work_out[];
{
   i_intin( work_in );
   i_intout( work_out );
   i_ptsout( work_out + 45 );

   contrl[0] = 100;
   contrl[1] = 0;
   contrl[3] = 11;
   contrl[6] = *handle;
   vdi();

   *handle = contrl[6];    
   i_intin( intin );
   i_intout( intout );
   i_ptsout( ptsout );
}

    WORD
v_clsvwk( handle )
WORD handle;
{
    contrl[0] = 101;
    contrl[1] = contrl[3] = 0;
    contrl[6] = handle;
    vdi();
}

    WORD
vs_clip( handle, clip_flag, xy )
WORD handle, clip_flag, xy[];
{
    i_ptsin( xy );
    intin[0] = clip_flag;

    contrl[0] = 129;
    contrl[1] = 2;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();

    i_ptsin( ptsin );
}


    WORD
vst_height( handle, height, char_width, char_height, cell_width, cell_height )
WORD handle, height, *char_width, *char_height, *cell_width, *cell_height;
{
    ptsin[0] = 0;
    ptsin[1] = height;

    contrl[0] = 12;
    contrl[1] = 1;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    *char_width = ptsout[0];
    *char_height = ptsout[1];
    *cell_width = ptsout[2];
    *cell_height = ptsout[3];
}


    WORD
vsf_interior( handle, style )
WORD handle, style;
{
    intin[0] = style;

    contrl[0] = 23;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}

    WORD
vsf_style( handle, index )
WORD handle, index;
{
    intin[0] = index;

    contrl[0] = 24;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}

    WORD
vsf_color( handle, index )
WORD handle, index;
{
    intin[0] = index;

    contrl[0] = 25;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}


vsl_type( handle, style )
WORD handle, style;
{
    intin[0] = style;

    contrl[0] = 15;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}

    WORD
vsl_color( handle, index )
WORD handle, index;
{
    intin[0] = index;

    contrl[0] = 17;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}


    WORD
vr_recfl( handle, xy )
WORD handle, *xy;
{
    i_ptsin( xy );

    contrl[0] = 114;
    contrl[1] = 2;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    i_ptsin( &ptsin[0] );
}


    WORD
vswr_mode( handle, mode )
WORD handle, mode;
{
    intin[0] = mode;

    contrl[0] = 32;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}


    WORD
v_gtext( handle, x, y, string)
WORD handle, x, y;
BYTE *string;
{
    WORD i;

    ptsin[0] = x;
    ptsin[1] = y;
    i = 0;
    while (intin[i++] = *string++)
        ;

    contrl[0] = 8;
    contrl[1] = 1;
    contrl[3] = --i;
    contrl[6] = handle;
    vdi();
}

