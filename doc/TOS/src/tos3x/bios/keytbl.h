#if !MULTILANG_SUPPORT

/*
 * labels are only referenced from assembler code,
 * so must include "_" prefix
 */

#if (OS_COUNTRY == CTRY_US)
#define _keytblnorm  _keytblnorm_us
#define _keytblshift _keytblshift_us
#define _keytblcaps  _keytblcaps_us
#endif

#if (OS_COUNTRY == CTRY_UK)
#define _keytblnorm  _keytblnorm_uk
#define _keytblshift _keytblshift_uk
#define _keytblcaps  _keytblcaps_uk
#endif

#if (OS_COUNTRY == CTRY_DE)
#define _keytblnorm  _keytblnorm_de
#define _keytblshift _keytblshift_de
#define _keytblcaps  _keytblcaps_de
#endif

#if (OS_COUNTRY == CTRY_ES)
#define _keytblnorm  _keytblnorm_es
#define _keytblshift _keytblshift_es
#define _keytblcaps  _keytblcaps_es
#endif

#if (OS_COUNTRY == CTRY_FR)
#define _keytblnorm  _keytblnorm_fr
#define _keytblshift _keytblshift_fr
#define _keytblcaps  _keytblcaps_fr
#endif

#if (OS_COUNTRY == CTRY_SE) | (OS_COUNTRY == CTRY_FI) | (OS_COUNTRY == CTRY_NO)
#define _keytblnorm  _keytblnorm_se
#define _keytblshift _keytblshift_se
#define _keytblcaps  _keytblcaps_se
#endif

#if (OS_COUNTRY == CTRY_IT)
#define _keytblnorm  _keytblnorm_it
#define _keytblshift _keytblshift_it
#define _keytblcaps  _keytblcaps_it
#endif

#if (OS_COUNTRY == CTRY_SG)
#define _keytblnorm  _keytblnorm_sg
#define _keytblshift _keytblshift_sg
#define _keytblcaps  _keytblcaps_sg
#endif

#if (OS_COUNTRY == CTRY_SF)
#define _keytblnorm  _keytblnorm_sf
#define _keytblshift _keytblshift_sf
#define _keytblcaps  _keytblcaps_sf
#endif

#if !BINEXACT

#if (OS_COUNTRY == CTRY_PL)
#define _keytblnorm  _keytblnorm_pl
#define _keytblshift _keytblshift_pl
#define _keytblcaps  _keytblcaps_pl
#endif

#if (OS_COUNTRY == CTRY_CZ)
#define _keytblnorm  _keytblnorm_cz
#define _keytblshift _keytblshift_cz
#define _keytblcaps  _keytblcaps_cz
#endif

#if (OS_COUNTRY == CTRY_NL)
#define _keytblnorm  _keytblnorm_nl
#define _keytblshift _keytblshift_nl
#define _keytblcaps  _keytblcaps_nl
#endif

#if (OS_COUNTRY == CTRY_DK)
#define _keytblnorm  _keytblnorm_dk
#define _keytblshift _keytblshift_dk
#define _keytblcaps  _keytblcaps_dk
#endif

#if (OS_COUNTRY == CTRY_TR)
#define _keytblnorm  _keytblnorm_tr
#define _keytblshift _keytblshift_tr
#define _keytblcaps  _keytblcaps_tr
#endif

#endif


#endif /* MULTILANG_SUPPORT */
