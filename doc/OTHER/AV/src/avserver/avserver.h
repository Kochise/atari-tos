#define DATE     "Sep 13 1999"
#define VERSION  "1.3-L"

#ifndef _WORD
#ifdef __PUREC__
#define _WORD int
#define _UWORD int
#else
#define _WORD short
#define _UWORD short
#endif
#define _LONG long
#endif
#ifndef SH_WDRAW
#define SH_WDRAW        72          /* AES 4.0 */
#endif

#ifndef SHW_PARALLEL
#define SHW_PARALLEL 100
#endif

#ifndef FALSE
#define FALSE 0
#define TRUE  1
#endif
#ifndef SuperToUser
#define SuperToUser(sp) Super(sp)
#endif

#ifdef __GNUC__
#  define ASM_NAME(x) __asm__(x)
#else
#  define ASM_NAME(x)
#endif


#define C_AmAN 0x416D414EL     /* 'AmAN' */
#define C_AVSV 0x41565356L     /* 'AVSV' */
#define _longframe *((short *)0x59e)

struct setter {
	char magic[16];
	struct setter *self;
	char display[46];
	short type;
	short av_startprog_upper;
	char eos[2];
};

extern struct setter setter;

int get_cookie(const char *id, void **value);
