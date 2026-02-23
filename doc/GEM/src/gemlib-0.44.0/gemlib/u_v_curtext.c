/*
 *  $Id: u_v_curtext.c,v 1.5 2016/01/10 00:44:30 a_bercegeay Exp $
 */

#include "gem_vdiP.h"
#include "vdi_userdef.h"


/** UDEF version of v_curtext(). See \ref overviewUDEF for details about UDEF feature
 */

void
udef_v_curtext (short handle, const char *str)
{
	short n = vdi_str2array_n (str, _VDIParBlk.vdi_intin, VDI_INTINMAX);

	VDI_PARAMS(_VDIParBlk.vdi_control, _VDIParBlk.vdi_intin, 0L, vdi_dummy, vdi_dummy );
	
	VDI_TRAP_ESC (vdi_params, handle, 5,12, 0,n);
}
