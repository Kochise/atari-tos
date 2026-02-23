/*
 *  $Id: u_vrq_string.c,v 1.5 2016/01/10 00:44:31 a_bercegeay Exp $
 */

#include "gem_vdiP.h"
#include "vdi_userdef.h"


/** UDEF version of vrq_string(). See \ref overviewUDEF for details about UDEF feature
 */

void
udef_vrq_string (short handle, short len, short echo, short echoxy[], char *str)
{

	VDI_PARAMS(_VDIParBlk.vdi_control, _VDIParBlk.vdi_intin, echoxy, _VDIParBlk.vdi_intout, vdi_dummy );
	
	_VDIParBlk.vdi_intin[0]      = len;
	_VDIParBlk.vdi_intin[1]      = echo;
	
	VDI_TRAP (vdi_params, handle, 31, 1,2);
	
	vdi_array2str (_VDIParBlk.vdi_intout, str, _VDIParBlk.vdi_control[4]);
}
