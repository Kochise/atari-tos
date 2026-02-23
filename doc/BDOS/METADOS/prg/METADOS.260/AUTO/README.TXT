MetaDOS 2.60
	These are the essential elements to get any SCSI CD ROM drive going on 
	an Atari TT or to use an `Atari CDAR 504' CD ROM on an Atari with 
	ACSI port. It does NOT support SCSI drives connected to an ACSI 
	port. It does NOT support the Atari Falcon030 at all (in these 
	cases, you'll need third-party drivers). You may use it 'as is', don't 
	expect any updates.

	This release fixes only some small problems present in previous 
	versions.

FILES
	\AUTO\CDARGEN.BOS
		Generalized version of physical device driver. This driver only 
		supports SCSI CD ROMs connected to the SCSI port of the Atari TT 
		(or the Atari 'CDAR 504' connected to the ACSI port of any Atari 
		computer with ACSI port).

	\AUTO\HSMAY86.DOS
		Version 2.60 driver for CD-ROMs in High Sierra format (usually not 
		needed).

	\AUTO\ISO9660F.DOS
		Version 2.60 driver for CD-ROMs in ISO 9660 format (the ISO format 
		is the 'real' final version of the original High Sierra 
		specification).

	\AUTO\METADOS.PRG
		Version 2.60 of MetaDOS.

	\AUTO\CONFIG.SYS
		Configuration file. You will have to edit this file to assign 
		drive numbers and/or drive letters. In addition, you can edit the 
		path names for all driver files (if \AUTO\BOOT\ isn't ok for you).

INSTALLATION
	Copy METADOS.PRG, CONFIG.SYS, CDARGEN.BOS, ISO9660F.DOS and 
	HSMAY86.DOS into the AUTO folder, edit the ASCII file CONFIG.SYS for 
	your specific settings. Reboot.

KNOWN PROBLEMS
	METADOS.PRG
		Some programs won't access drive letters beyond P: (MetaDOS can 
		install drive letters up to Z:).

		Technical problems: It's not possible to redirect GEMDOS standard 
		input/output to MetaDOS files (only applies to people using 
		command line shells).

	ISO9660F.DOS and HSMAY86.DOS
		Sometimes, media change doesn't work properly. If this happens to 
		you, eject the disk, insert it again and wait a few seconds before 
		the next try.

	CDARGEN.BOS
		The old audio commands (documented in the developer's 
		documentation) are only supported for backwards compatibility 
		only; some flags do not work at all.

		Technical problems: the MetaDOS XBIOS calls that cause I/O with an 
		ACSI device require that buffers are allocated in ST compatible 
		RAM (see Mxalloc documentation).

		Some CD ROM drives need special initializations to be able to 
		access disks in XA format (Photo CD). CDARGEN.BOS has no special 
		support for those drives.

