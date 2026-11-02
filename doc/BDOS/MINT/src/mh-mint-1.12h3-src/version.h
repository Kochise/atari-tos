/*
 * This file has been modified as part of the MH-MiNT project. See
 * the file Changes.MH for details and dates.
 */

#define MAJ_VERSION	1
#define MIN_VERSION	12

#define THIRD_PARTY	"MH-MiNT"
#define PATCH_LEVEL	"h3"
#define BETA		"-BETA"

#ifndef BETA
#define BETA ""
#endif
#ifndef PATCH_LEVEL
#define PATCH_LEVEL ""
#endif

#define VERS_STRING	"%d.%02d" PATCH_LEVEL BETA
