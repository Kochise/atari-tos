/*
 *  $Id: a_graf_shrinkbox_grect.c,v 1.2 2004/10/04 18:51:33 a_bercegeay Exp $
 */

#include "gem_aesP.h"

/** see mt_graf_shrinkbox()
 *
 *  @param in  rectangle to shrink to
 *  @param out rectangle to shrink from
 *  @param global_aes global AES array
 *
 *  @return  see mt_graf_shrinkbox()
 *
 *  @since see mt_graf_shrinkbox()
 *
 *
 */

short
mt_graf_shrinkbox_grect( const GRECT *in, const GRECT *out, short *global_aes)
{
	AES_PARAMS(74,8,1,0,0);

	*(GRECT*)(aes_intin  ) = *in;
	*(GRECT*)(aes_intin+4) = *out;

	AES_TRAP(aes_params);

	return aes_intout[0];
}
