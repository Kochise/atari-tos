/*
 *  $Id: vdi_userdef.h,v 1.2 2016/01/10 00:44:32 a_bercegeay Exp $
 */

#include "mt_gem.h"

/** private type used by all "udef" specific functions */
typedef struct
{
    short    vdi_control[VDI_CNTRLMAX];  /**< private global data used by all "udef" specific functions */
    short    vdi_intin[VDI_INTINMAX];    /**< private global data used by all "udef" specific functions */
    short    vdi_intout[VDI_INTOUTMAX];  /**< private global data used by all "udef" specific functions */
    short    vdi_ptsin[VDI_PTSINMAX];    /**< private global data used by all "udef" specific functions */
    short    vdi_ptsout[VDI_PTSOUTMAX];  /**< private global data used by all "udef" specific functions */
} VDIPARBLK;


extern VDIPARBLK _VDIParBlk;

