*
* These functions are referenced by VDI,
* but are defined elsewhere
*
*
* This file is only used when linking a single module,
* to get the same addresses as when linking the whole ROM
*
#include "../common/config.h"
#include "vdidefs.h"
#include "../common/ctrycode.h"
#include "../common/sections.inc"

		xdef _zeromem
_zeromem equ BIOSTBASE+$1680
