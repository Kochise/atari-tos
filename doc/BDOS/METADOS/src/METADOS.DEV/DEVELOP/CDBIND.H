/**************************************************************************
*
*							Mike Schmal
*
* cdbind.h	Standard "C" include file for use with cdbind.o to access
*		the Cd-ROM Extended Bios.
*
*		Started:	04/14/88
*		Last Update:	04/04/89
*
*
***************************************************************************/


/*
* CD-ROM trap calling routine.
*/
extern	long	CDROM();

/*
* Currently defined Extended Bios calls:
*/
#define	Meta_init(a)		CDROM(48,a)
#define	open(a,b)		CDROM(49,a,b)
#define	close(a)		CDROM(50,a)
#define	read(a,b,c,d)		CDROM(51,a,b,c,d)
#define	seek(a,b)		CDROM(53,a,b)
#define	status(a,b)		CDROM(54,a,b)
;
#define	start_aud(a,b,c)	CDROM(59,a,b,c)
#define	stop_aud(a)		CDROM(60,a)
#define	set_songtime(a,b,c)	CDROM(61,a,b,c)
#define	get_toc(a,b,c)		CDROM(62,a,b,c)
#define	disc_info(a,b)		CDROM(63,a,b)

