/*
 * resource set indices for av_test
 *
 * created by ORCS 2.18
 */

/*
 * Number of Strings:        141
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       46
 * Number of Free Strings:   1
 * Number of Free Images:    0
 * Number of Objects:        53
 * Number of Trees:          1
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          3524
 */

#ifdef RSC_NAME
#undef RSC_NAME
#endif
#ifndef __ALCYON__
#define RSC_NAME "av_test"
#endif
#ifdef RSC_ID
#undef RSC_ID
#endif
#ifdef av_test
#define RSC_ID av_test
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 141
#define NUM_FRSTR 1
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 46
#define NUM_OBS 53
#define NUM_TREE 1
#endif



#define MAIN_DIALOG                        0 /* form/dialog */
#define SERVER_ID                          7 /* TEXT in tree MAIN_DIALOG */ /* max len 21 */
#define HAS_AV_SENDKEY                    31 /* TEXT in tree MAIN_DIALOG */ /* max len 7 */
#define HAS_AV_QUOTING                    50 /* TEXT in tree MAIN_DIALOG */ /* max len 7 */
#define MAIN_OK                           52 /* BUTTON in tree MAIN_DIALOG */

#define AL_NO_AVSERVER                     0 /* Alert string */
/* [1][AV-Test: Kein AV-Server|im System gefunden!][Abbruch] */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD av_test_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD av_test_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD av_test_rsc_free(void);
#endif
