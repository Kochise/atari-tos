/*
 *  $Id: rc_copy.c,v 1.2 2003/02/28 20:46:41 a_bercegeay Exp $
 */

#include "mt_gem.h"

/** copy a GRECT structure
 *
 *  @param src
 *  @param dst
 *
 *  @return always 1.
 *
 */
 
short
rc_copy (const GRECT * src, GRECT * dst)
{
	*dst = *src;
	return 1;
}
