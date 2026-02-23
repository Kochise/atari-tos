/*
 *  $Id: u_vqt_extent.c,v 1.5 2016/01/10 00:44:31 a_bercegeay Exp $
 */

#include "gem_vdiP.h"
#include "vdi_userdef.h"


/** UDEF version of vqt_extent(). See \ref overviewUDEF for details about UDEF feature
 */

void
udef_vqt_extent (short handle, const char *str, short extent[])
{
	short n = vdi_str2array_n (str, _VDIParBlk.vdi_intin, VDI_INTINMAX);
	
	VDI_PARAMS(_VDIParBlk.vdi_control, _VDIParBlk.vdi_intin, 0L, vdi_dummy, extent );

	VDI_TRAP (vdi_params, handle, 116, 0,n);
}
