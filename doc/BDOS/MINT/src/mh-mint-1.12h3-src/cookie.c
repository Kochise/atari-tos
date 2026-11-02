/*
 * This file belongs to MH-MiNT.  It's not in the original MiNT 1.12
 * distribution.  See the file Changes.MH for a detailed log of changes.
 */

/***************************************************************************
 *** File : "cookie.c"                                                   ***
 ***************************************************************************/

#include "mint.h"
#include "cookie.h"

static long search_jar (long tag, COOKIE ** jar);
static long delete_cookie (COOKIE * choc_chip);
static long insert_cookie (COOKIE * Yummy, COOKIE * choc_chip);

extern MEMREGION *newjar_region;

/**************************************************************************
 ***  ================================================================  ***
 ***  ===   LONG Scookie (WORD Action, COOKIE * Yummy);            ===  ***
 ***  ================================================================  ***
 ***                                                                    ***
 ***  New OS call for getting into the cookie jar <grin>.               ***
 ***   = GEMDOS 0x014a =                                                ***
 ***                                                                    ***
 ***  Action Values :                                                   ***
 ***                                                                    ***
 ***    C_BAKE (0x01) - Yummy is a pointer to a cookie you want to      ***
 ***                    install into the cookie jar.  Only root can     ***
 ***                    bake a cookie (or you get EACCDN), and you      ***
 ***                    cannot overwrite an existing cookie (ELOCKED)   ***
 ***                    Returns 0 for success, or a negative error code ***
 ***    C_GRAB (0x02) - Yummy is a pointer to a cookie you want to      ***
 ***                    grab from the cookie jar.  You must supply a    ***
 ***                    Cookie with a tag name to look for.  If you     ***
 ***                    use a -1 (LONG) value for the cookie tag, then  ***
 ***                    the first cookie will be returned to you.  If   ***
 ***                    the cookie is found, it will be copied into the ***
 ***                    cookie pointed to by Yummy.  Returns 0 for      ***
 ***                    success or EFILNF.  If you need direct access   ***
 ***                    to the jar, pass a -1L as your Yummy pointer.   ***
 ***                    This will return a pointer to the jar.          ***
 ***    C_MORE (0x04) - Like C_GRAB but find the NEXT cookie after the  ***
 ***                    one with a tag like Yummy's.  This is so that   ***
 ***                    you can find the entire jar with C_GRAB and     ***
 ***                    C_MORE.  The found cookie is copied into Yummy  ***
 ***                    The NULL cookie is copied into Yummy if Yummy   ***
 ***                    was the last cookie, or returns EFILNF if not   ***
 ***                    found.  Returns 0 for success (or last cookie)  ***
 ***    C_READ (0x08) - Yummy should be a LONG tag value to find, NOT a ***
 ***                    pointer!  The returned value is the value of    ***
 ***                    the cookie indicated, or EFILNF if not found.   ***
 ***                    Use this when you know the cookie exists, such  ***
 ***                    as "_MCH" since this is faster and easier.      ***
 ***    C_SIZE (0x10) - Returns the number of cookies that are actually ***
 ***                    in the jar.  Use C_READ,0 to find out how many  ***
 ***                    cookies can be put in the jar without resizing  ***
 ***    C_EAT  (0x20) - Yummy is the cookie to delete (only need tag    ***
 ***                    value).  Only root can eat cookies (or you get  ***
 ***                    EACCDN).  Returns EFILNF if cookie is not found ***
 ***                    or zero for success.                            ***
 ***                                                                    ***
 **************************************************************************/

long ARGS_ON_STACK s_cookie (short Action, COOKIE * Yummy)
{
  COOKIE * choc_chip;     /* choc_chip cookies are temporary @ my house! */
  register int r;

  switch (Action) {

    case C_BAKE:

      /* "Bakes" a new cookie.  Yummy is a pointer to the cookie to make.
         Only mom can bake cookies (EACCDN) and the cookie must not
         already exist (ELOCKED).  Can't bake the "special" tag.   */

      /* Sanity check - BUG : should make sure block is in process' mem map */
      if ((long) Yummy < (long) CJAR)
        return EIMBA;

      else if ((curproc -> euid) || (Yummy->tag == C_FIRST))
        return EACCDN;
      else if (!(r = search_jar (Yummy->tag, &choc_chip)))
        return ELOCKED;
      else return (insert_cookie (Yummy, choc_chip));


    case C_GRAB:  case C_MORE:

      /* Search for a cookie.  Yummy is a pointer to a cookie to search
         for (search is by tag field, if not found EFILNF).  If C_MORE
         instead of C_READ we copy the NEXT cookie into the user's cookie
         instead of the one we found.                                  */

      if (((long) Yummy == -1L) && (curproc->euid == 0)) {
	r = search_jar (-1L, &choc_chip);
        return (long)choc_chip;
      }  /* Pass -1L, instead of pointer to get direct access to jar */

      else if ((long) Yummy < (long) CJAR)
        return EIMBA;     /* Sanity Check! - see comment above */

      else if ((r = search_jar (Yummy->tag, &choc_chip)))
        return r;
      else {
        if ((Action == C_MORE) && (choc_chip->tag != 0))
          choc_chip++;
        *Yummy = *choc_chip;
        return 0;
      }


    case C_READ:

      /* Special: C_READ passes and returns value, not cookies!     */
      /* The system 200Hz tick is provided by reading cookie "*200" 
         for now.                                                   */

      if ((long)Yummy == COOKIE_V200)
        return ((long)*((long *)0x04ba));
      else if ((r = search_jar ((long)Yummy, &choc_chip))) 
        if ((long)Yummy)
          return r; 
      return (choc_chip->value); 


    case C_SIZE:

       /* Returns the number of cookies actually in the jar.  To find
          how many cookie slots exist, C_READ the NULL cookie.      */

       r = 1;
       search_jar (C_FIRST, &choc_chip);
       while (choc_chip->tag) {
         choc_chip++;
         r++;
       }
       return r;


    case C_EAT:

       /* We don't just let anyone eat our cookies (EACCDN) and the
          cookie may not exist anyways (EFILNF)                     */

       if ((long) Yummy < (long) CJAR)
         return EIMBA;                  /* Sanity Check - see above */
       else if ((curproc->euid) || (Yummy->tag == 0))
         return EACCDN;
       else if ((r = search_jar (Yummy->tag, &choc_chip)))
         return r;
       else return delete_cookie (choc_chip); 


    default:

       return EINVFN;
  }
}


static long search_jar (long tag, COOKIE ** jar)
{
  /* Search the cookie jar for a cookie with a specific tag.  C_FIRST 
     returns the first cookie, and NULL (0) is the last cookie.       */

  (*jar) = *CJAR;
  if (tag == C_FIRST)
    return 0;
  while ((*jar)->tag)
    if (tag == (*jar)->tag)
      return 0;
    else (*jar)++;
  return EFILNF;
}


static long delete_cookie (COOKIE * choc_chip)
{
  int i;
  for (i = 0; (choc_chip[i].tag); i++)      /* Copy everything down */
    choc_chip[i] = choc_chip[i+1];
  return 0;
}


static long insert_cookie (COOKIE * Yummy, COOKIE * choc_chip)
{
  COOKIE * Jar = * CJAR; 
  MEMREGION *temp;

  /* Shall we install a whole new cookie jar? */

  if ((( (long) choc_chip - (long) Jar) >> 3) >= ((choc_chip->value) - 1)) {

    COOKIE * NewJar;
    long jarsize = ROUND(((choc_chip->value) + 8) << 3);

    TRACE(("Allocating new Jar of %ld bytes", jarsize));

    temp = get_region (core, jarsize, PROT_G);
    choc_chip = NewJar = attach_region (rootproc, temp);

    if (!(virtaddr)choc_chip) {
      temp->links = 0;
      free_region (temp);
      return ENSMEM;
    }

    do 
      *choc_chip++ = *Jar++;
    while (choc_chip -> tag);         /* Copy old cookies */

    *choc_chip++ = *Yummy;            /* Insert Cookie! */
    choc_chip->tag = 0;
    choc_chip->value = jarsize/sizeof(COOKIE);
    TRACE(("Free'ing old jar"));
    newjar_region->links = 0;
    free_region (newjar_region);    /* Free old jar */
    *CJAR = NewJar;                 /* Set the new jar */
    newjar_region = temp;
    return 0;                       /* We're Done! */

  } else {

    long value = choc_chip->value;    /* How many? */

    *choc_chip++ = *Yummy;            /* Insert Cookie */
    choc_chip->tag = 0;
    choc_chip->value = value;         /* jar hasn't changed */ 
    return 0;
  } 
}


