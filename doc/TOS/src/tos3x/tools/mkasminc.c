#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>

#ifndef O_BINARY
#  ifdef _O_BINARY
#    define O_BINARY _O_BINARY
#  else
#    define O_BINARY 0
#  endif
#endif 

#ifndef __ALCYON__
 #  define lmalloc(size) malloc(size)
 #  define lrealloc(ptr, size) realloc(ptr, size)
 #  define lfree(ptr) free(ptr)
#endif

#ifndef PROTO
#ifdef __ALCYON__
#define VOID int					/* Void function return	   */
#define VOIDPTR char *
#define NOTHING                     /* no parameters */
#define PROTO(p) ()
#define P(t)
#define PP(v) v
#define volatile
#define const
#define signed
#else
#define NOTHING void                /* no parameters */
#define PROTO(p) p
#define P(t) t
#define PP(v)
#endif
#endif

#define _(x) x

#undef MIN
#define MIN(a, b) ((a)<=(b) ? (a) : (b))
#define BUFFER_SIZE (16*1024)


#define	 TRUE	1
#define	 FALSE  0


/* Read a stream into memory */
static int read_file(P(int) infile, P(const char *) infilename, P(char *) buffer, P(long) count)
PP(int infile;)
PP(const char *infilename;)
PP(char *buffer;)
PP(long count;)
{
	size_t toread; /* Number of bytes to read this time */
	size_t towrite; /* Number of bytes to write this time */
	
	for (;;)
	{
		toread = MIN(BUFFER_SIZE, count);
		if (toread == 0)
			break;

		towrite = read(infile, buffer, toread);
		if (towrite != toread)
		{
			fprintf(stderr, "%s: %s\n", infilename, strerror(errno));
			return FALSE;
		}
		count -= towrite;
		buffer += towrite;
	}

	return TRUE;
}


int main(P(int) argc, P(char **) argv)
PP(int argc;)
PP(char **argv;)
{
	const char *infile;
	const char *outfile;
	const char *symname;
	int handle;
	long filesize, i, j, count;
	long memsize;
	char *buffer;
	FILE *fp;
	char *p;
	int ret;
	
#ifdef __ALCYON__
	/* symbols etoa and ftoa are unresolved */
	asm("xdef _etoa");
	asm("_etoa equ 0");
	asm("xdef _ftoa");
	asm("_ftoa equ 0");
#endif

	if (argc < 2)
	{
		fprintf(stderr, _("usage: mkasminc <infile> [<symname> [<outfile>]]\n"));
		return EXIT_FAILURE;
	}
	infile = argv[1];
	if (argc > 2)
		symname = argv[2];
	else
		symname = "-";
	if (argc > 3)
		outfile = argv[3];
	else
		outfile = "-";
	
	handle = open(infile, O_RDONLY | O_BINARY);	/* open source file */
	if (handle < 0)
	{
		fprintf(stderr, _("%s not found\n"), infile);
		return EXIT_FAILURE;
	}
	filesize = lseek(handle, 0L, SEEK_END);
	lseek(handle, 0L, SEEK_SET);
	
	memsize = (filesize + 15) & -16;
	buffer = lmalloc(memsize);
	if (!buffer)
	{
		fprintf(stderr, _("No memory !\n"));
		return EXIT_FAILURE;
	}
	ret = read_file(handle, infile, buffer, filesize);
	close(handle);
	if (ret == FALSE)
		return EXIT_FAILURE;
	if (memsize > filesize)
		memset(buffer + filesize, 0, (int)(memsize - filesize));
	if (strcmp(outfile, "-") == 0)
	{
		fp = stdout;
	} else
	{
		fp = fopen(outfile, "wb");
		if (fp == NULL)
		{
			fprintf(stderr, _("can't create %s: %s\n"), outfile, strerror(errno));
			return EXIT_FAILURE;
		}
	}
	
	fprintf(fp, "/*\n");
	fprintf(fp, " * automatically generated from %s - DO NOT EDIT\n", infile);
	fprintf(fp, " */\n");
	fprintf(fp, "\n\n");

	if (symname && strcmp(symname, "-") != 0)
		fprintf(fp, "%s:\n", symname);

	p = buffer;

	for (i = 0; i < filesize; )
	{
		uint32_t val;
		
		count = filesize - i;
		if (count > 16)
			count = 16;
		i += count;
		
		fprintf(fp, "\tdc.l ");
		for (j = 0; j < count; )
		{
			val = ((uint32_t)(p[j+0] & 0xff) << 24) | ((uint32_t)(p[j+1] & 0xff) << 16) | ((uint32_t)(p[j+2] & 0xff) << 8) | ((uint32_t)(p[j+3] & 0xff));
			fprintf(fp, "$%08lx", (long)val);
			j += 4;
			if (j < count)
				putc(',', fp);
		}
		fprintf(fp, "\n");
		
		p += count;
	}
	fflush(fp);
	if (fp != stdout)
		fclose(fp);

	return EXIT_SUCCESS;
}
