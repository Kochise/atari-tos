/*
 *  $Id: vst_scratch.c,v 1.7 2015/12/08 22:34:40 landemarre Exp $
 */

#include "gem_vdiP.h"

/** 
 *
 *  @param handle Device handle
 *  @param mode 
 *
 *  @return 
 *
 *  @since 
 *
 *  @sa
 *
 *
 *
 */

void
vst_scratch (short handle, short mode)
{
	short vdi_control[VDI_CNTRLMAX]; 

	VDI_PARAMS(vdi_control, &mode, 0L, vdi_dummy, vdi_dummy );
	
	VDI_TRAP (vdi_params, handle, 244, 0,1);
}
