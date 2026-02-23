#include "cdbind.h"
#include <osbind.h>
#include <bios.h>

/* 
   CDAR location routine

   Attempts to initialize MetaDOS(tm), then searches the drive map for
   existing drives, attempts to open each drive.  Upon success, checks
   for "CDAR" in the device header to ensure a CDROM.

   Failures of any kind, Meta_init, or failure to locate a drive, cause
   a return of 0.
   Success causes the FIRST drive's physical id to be returned (a letter 
   from A -> Z).
 */

main()
{
	long initdata[4] = {0,0,0,0};	/* Drive map, *version, *phy dev */
	long opendata[4] = {0,0,0,0};	/* Device header, id string */
	long drives;			/* Drive bits */
	long error;			/* Open error code */
	int found;			/* If we found a cdrom */
	char *devh;			/* device header string */
	int i;				/* Loop */
	char found_it[20] = "CDAR on  \r\n";

	Meta_init(initdata);		/* Initialize, get version */
	if (initdata[1] != 0L) {
		Cconws("\r\n");		/* Force carriage return */
		Cconws((char *)initdata[1]);
		Cconws("\r\n");		/* Force carriage return */
		}
	else return 0;			/* Illegal */

	drives = initdata[0];		/* Take drive map */
	found = 0;			/* Not yet found */


	for (i = 'A'; (i <= 'Z') && (!found); ++i, drives >>= 1) {

		/* Check each drive bit, to a max of 26 drives */
		/* or until ONE CDAR device is found */

		if (drives & 0x1l) {		/* Check for CDAR504 */
			error = open(i, opendata);
			if (error == 0L) {
				devh = (char *)opendata[0];

				if ((devh[0] == 'C') &&
				    (devh[1] == 'D') &&
				    (devh[2] == 'A') &&
				    (devh[3] == 'R')) {
					/* Show drive later */
					close(i);	/* Clean up */
					found = 0xFF;	/* Found it */
					}
				}
			else {
				Cconws("Error opening DMA device\r\n");
				}
			}
		
		}

	if (found) {		/* We've found a CDAR! */
		/* Since the 'for' loop added one to i, subtract */
		--i;
		found_it[8] = i;/* Show drive */
		Cconws(found_it);
		}
	else {			/* Nope, didn't find it */
		Cconws("CDAR not installed...\r\n");
		}

	Cconws("\r\nAny key to Continue\r\n");
	Bconin(BC_CON);

	/* return (i & found), the drive letter or 0 if not found */
	return (i & found);
}
