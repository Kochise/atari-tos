/*
 *  $Id: v_gtext16n.c,v 1.4 2003/08/07 06:59:17 a_bercegeay Exp $
 */

#include "gem_vdiP.h"

/** same as v_gtext()
 *
 *  @param handle Device handle
 *  @param pos 
 *  @param wstr string, with 16 bits per character.
 *  @param num len of the string
 *
 *  @since all VDI versions
 *
 */

void
v_gtext16n (short handle, PXY pos, const short *wstr, short num)
{
	short vdi_control[VDI_CNTRLMAX]; 

	VDI_PARAMS(vdi_control, wstr, (short*)&pos, vdi_dummy, vdi_dummy );
	
	VDI_TRAP (vdi_params, handle, 8, 1,num);
}

