/*
 *	Display VDI properties
 *
 *	Patrice Mandin
 */

/*--- Includes ---*/

#include <stdio.h>
#include <string.h>

#include <gem.h>
#include <gemx.h>
#include <mint/osbind.h>
#include <sys/cookie.h>

/*--- Defines ---*/

/* Bug in mintlib-0.57, \r is not automatically added */
#define CRLF "\n\r"
/*#define CRLF "\n"*/

/* CLUT types */
enum {
	CLUT_NONE=0,
	CLUT_HARDWARE,
	CLUT_SOFTWARE
};

/*--- Variables ---*/

int myargc;		/* Command line parameters */
char **myargv;

int output_to_file;

/*--- Functions prototypes ---*/

int ParmPresent(char *param);

void vdi_read_infos(void);
void display_vdi_properties(short vdi_handle, short *work_out);
void display_extended_properties(short vdi_handle, short *work_out);
void display_screeninfo(short vdi_handle, short *work_out);

unsigned long get_EdDI_version(void *function_pointer);

/*--- Functions ---*/

int main(int argc, char **argv)
{
	int old_stdout;
	int file_h;

	myargc = argc;
	myargv = argv;

	output_to_file=ParmPresent("-file");
	if (output_to_file) {
		old_stdout=Fdup(1);
		file_h=Fcreate("stdout.txt", 0);
		Fforce(1,file_h);
	}

	vdi_read_infos();

	if (output_to_file) {
		Fforce(1,old_stdout);
		Fclose(file_h);		
	} else {
		/* Wait a key */
		printf("Press a key to exit" CRLF);
		while (!Cconis());
	}

	return 0;
}

int ParmPresent(char *param)
{
	int	i;

	for (i=1; i<myargc; i++)
		if ( !strcasecmp(param, myargv[i]) )
			return i;

	return 0;
}

void vdi_read_infos(void)
{
	short	ap_id, vdi_handle, dummy;
	short	work_in[12], work_out[272];
	int		i;

	/* Setup VDI workstation */
	work_in[0]=Getrez()+2;
	for(i = 1; i < 10; i++)
		work_in[i] = 1;
	work_in[10] = 2;

	/* Open AES */
	ap_id = appl_init();

	if (ap_id == -1) {
		printf("AES not available" CRLF);

		/* Open physical workstation */
		v_opnwk(work_in, &vdi_handle, work_out);

		if (vdi_handle) {
			printf("Physical workstation %d opened" CRLF, vdi_handle);

			display_vdi_properties(vdi_handle, work_out);
			display_extended_properties(vdi_handle, work_out);
			display_screeninfo(vdi_handle, work_out);

			/* Close physical workstation */
			v_clswk(vdi_handle);
		}

	} else {
		printf("AES available" CRLF);

		vdi_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);

		/* Close AES */
		appl_exit();

		/* Open virtual workstation */
		v_opnvwk(work_in, &vdi_handle, work_out);

		if (vdi_handle) {
			printf("Virtual workstation %d opened" CRLF, vdi_handle);

			display_vdi_properties(vdi_handle, work_out);
			display_extended_properties(vdi_handle, work_out);
			display_screeninfo(vdi_handle, work_out);

			/* Close virtual workstation */
			v_clsvwk(vdi_handle);
		}
	}

	fflush(stdout);
}

void display_vdi_properties(short vdi_handle, short *work_out)
{
	/* Display workstation properties */
	printf("Workstation properties:" CRLF);	
	printf(" Screen size: %dx%d" CRLF,work_out[0]+1, work_out[1]+1);
	printf(" Pens: %d" CRLF,work_out[13]);
	switch(work_out[39]) {
		case 0:
			printf(" True colour device" CRLF);
			break;		
		case 2:
			printf(" Monochrome device" CRLF);
			break;		
		default:
			printf(" %d colour paletted device" CRLF,work_out[39]);
			break;		
	}
}

void display_extended_properties(short vdi_handle, short *work_out)
{
	vq_extnd(vdi_handle, 1, work_out);
	printf(CRLF "Workstation extended properties:" CRLF);	
	printf(" %d bits per plane" CRLF,work_out[4]);
	if (work_out[5]) {
		printf(" Lookup table for colours" CRLF);
	} else {
		printf(" No lookup table for colours" CRLF);
	}
}

void display_screeninfo(short vdi_handle, short *work_out)
{
#define EDDI_10	(0x0100)
#define EDDI_11 (0x0110)

	unsigned long EdDI_version;
	unsigned long cookie_EdDI;

	unsigned long num_colours;
	int clut_type, num_bits;

	unsigned long amask,rmask,gmask,bmask;

	/* Display screen info if available */
	if  (Getcookie(C_EdDI, &cookie_EdDI) == C_NOTFOUND) {
		return;
	}

	EdDI_version=get_EdDI_version( (void *)cookie_EdDI);

	/* Now read informations */
	vq_scrninfo(vdi_handle, work_out);
	printf(CRLF "Screen informations:" CRLF);	
	switch(work_out[0]) {
		case 0:
			printf(" Interleaved bitplanes" CRLF);
			break;
		case 1:
			printf(" VDI independent format" CRLF);
			break;
		case 2:
			printf(" Packed pixels" CRLF);
			break;
		default:
			printf(" Unknown bitplane organization" CRLF);
			break;
	}
	clut_type = work_out[1];
	switch(clut_type) {
		case CLUT_NONE:
			printf(" No CLUT (monochrome)" CRLF);
			break;
		case CLUT_HARDWARE:
			printf(" Hardware CLUT (paletted mode)" CRLF);
			break;
		case CLUT_SOFTWARE:
			printf(" Software CLUT (true colour mode)" CRLF);
			break;
		default:
			printf(" Unknown CLUT format" CRLF);
			break;
	}

	num_bits = work_out[2];
	printf(" %d bitplanes" CRLF, num_bits);
	num_colours = *((unsigned long *) &work_out[3]);
	printf(" %ld colours" CRLF, num_colours);

	if (EdDI_version >= EDDI_11) {
		printf(" Horizontal line length=%d" CRLF, work_out[5]);
		printf(" Screen address=0x%08x" CRLF, *((unsigned long *) &work_out[6]));
	}

	printf(" %d bits for red" CRLF, work_out[8]);
	printf(" %d bits for green" CRLF, work_out[9]);
	printf(" %d bits for blue" CRLF, work_out[10]);
	printf(" %d bits for alpha" CRLF, work_out[11]);
	printf(" %d bits for overlay" CRLF, work_out[12]);
	printf(" %d bits unused" CRLF, work_out[13]);

	amask = rmask = gmask = bmask = 0;
	if (EdDI_version >= EDDI_11) {
		printf(" Screen format: 0x%04x" CRLF, work_out[14]);
		if (work_out[14] & (1<<7)) {
				printf("  Little Endian" CRLF);
		} else {
				printf("  Big Endian" CRLF);
		}

		switch(num_colours) {
			case 32768UL:
				if (work_out[14] & (1<<7)) {
					/* Little endian */
					if (work_out[14] & (1<<1)) {
						/* Falcon */
						printf("  A1R5G5B5: GGABBBBB RRRRRGGG" CRLF);
						amask = 1 << 13;
						rmask = 31 << 3;
						gmask = (3 << 14) | 7;
						bmask = 31 << 8;
					} else {
						/* Others */
						printf("  A1R5G5B5: GGGBBBBB ARRRRRGG" CRLF);
						amask = 1 << 7;
						rmask = 31 << 2;
						gmask = (7 << 13) | 3;
						bmask = 31 << 8;
					}
				} else {
					/* Big endian */
					if (work_out[14] & (1<<1)) {
						/* Falcon */
						printf("  A1R5G5B5: RRRRRGGG GGABBBBB" CRLF);
						amask = 1 << 5;
						rmask = 31 << 11;
						gmask = 31 << 6;
						bmask = 31;
					} else {
						/* Others */
						printf("  A1R5G5B5: ARRRRRGG GGGBBBBB" CRLF);
						amask = 1 << 15;
						rmask = 31 << 10;
						gmask = 31 << 5;
						bmask = 31;
					}
				}
				break;
			case 65536UL:
				if (work_out[14] & (1<<7)) {
					/* Little endian */
					printf("  A0R5G6B5: GGGBBBBB RRRRRGGG" CRLF);
					amask = 0;
					rmask = 31 << 3;
					gmask = (7 << 13) | 7;
					bmask = 31 << 8;
				} else {
					/* Big endian */
					printf("  A0R5G6B5: RRRRRGGG GGGBBBBB" CRLF);
					amask = 0;
					rmask = 31 << 11;
					gmask = 63 << 5;
					bmask = 31;
				}
				break;
			case 16777216UL:
				if (work_out[14] & (1<<7)) {
					/* Little endian */
					switch(num_bits) {
						case 24:
							printf("  A0R8G8B8: BBBBBBBB GGGGGGGG RRRRRRRR" CRLF);
							amask = 0;
							rmask = 255;
							gmask = 255 << 8;
							bmask = 255 << 16;
							break;
						case 32:
							printf("  A8R8G8B8: BBBBBBBB GGGGGGGG RRRRRRRR AAAAAAAA" CRLF);
							amask = 255;
							rmask = 255 << 8;
							gmask = 255 << 16;
							bmask = 255 << 24;
							break;
					}
				} else {
					/* Big endian */
					switch(num_bits) {
						case 24:
							printf("  A0R8G8B8: RRRRRRRR GGGGGGGG BBBBBBBB" CRLF);
							amask = 0;
							rmask = 255 << 16;
							gmask = 255 << 8;
							bmask = 255;
							break;
						case 32:
							printf("  A8R8G8B8: AAAAAAAA RRRRRRRR GGGGGGGG BBBBBBBB" CRLF);
							amask = 255 << 24;
							rmask = 255 << 16;
							gmask = 255 << 8;
							bmask = 255;
							break;
					}
				}
				break;
		}
	}

	switch(clut_type) {
		case CLUT_HARDWARE:
			{
				int x,y;
				unsigned short *tmp_p;

				printf(" Hardware palette -> VDI palette mapping" CRLF); 

				tmp_p = (unsigned short *)&work_out[16];
				for (y=0;y<16;y++) {
					printf("  ");
					for (x=0;x<16;x++) {
						printf("0x%2x ",*tmp_p++);
					}
					printf(CRLF);
				}
			}
			break;
		case CLUT_SOFTWARE:
			{
				int component; /* red, green, blue, alpha, overlay */
				int num_bit;
				unsigned short *tmp_p;
				unsigned char *component_name[5]={"red","green","blue","alpha","overlay"};

				printf(" True Colour mapping" CRLF); 

				tmp_p = (unsigned short *) &work_out[16];
				for (component=0;component<5;component++) {
					for (num_bit=0;num_bit<16;num_bit++) {
						unsigned short valeur;

						valeur = *tmp_p++;

						if (valeur == 0xffff) {
							continue;
						}

						printf("  Bit %d of %s is at position %d" CRLF,num_bit,component_name[component],valeur);

						if (EdDI_version < EDDI_11) {
							switch(component) {
								case 0:
									rmask |= 1<< valeur;
									break;
								case 1:
									gmask |= 1<< valeur;
									break;
								case 2:
									bmask |= 1<< valeur;
									break;
								case 3:
									amask |= 1<< valeur;
									break;
							}
						}
					}					
				}
			}
			break;
	}

	printf(" Colour masks:" CRLF); 
	printf("  R mask: 0x%08x" CRLF, rmask); 
	printf("  G mask: 0x%08x" CRLF, gmask); 
	printf("  B mask: 0x%08x" CRLF, bmask); 
	printf("  A mask: 0x%08x" CRLF, amask); 
}
