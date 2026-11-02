#define MAJ_VERSION	1
#define MIN_VERSION	8

#ifndef MULTITOS
#define BETA
#endif

#ifdef BETA
#define VERS_STRING	"%d.%02d BETA"
#else
#define VERS_STRING	"%d.%02d"
#endif
