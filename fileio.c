/*	FILEIO.C
 *
 * The routines in this file read and write ASCII files from the disk. All of
 * the knowledge about files are here.
 *
 *	modified by Petri Kutvonen
 */

#include        <stdio.h>
#include        <stdlib.h>
#include        <string.h>
#include	"estruct.h"
#include        "edef.h"

#if	PKCODE
extern int nullflag;
#endif

FILE	*ffp;		/* File pointer, all functions. */
int eofflag;		/* end-of-file flag */

/*
 * Open a file for reading.
 */
ffropen(fn)
char    *fn;
{
        if ((ffp=fopen(fn, "r")) == NULL)
                return (FIOFNF);
	eofflag = FALSE;
        return (FIOSUC);
}

/*
 * Open a file for writing. Return TRUE if all is well, and FALSE on error
 * (cannot create).
 */
ffwopen(fn)
char    *fn;
{
#if     VMS
        register int    fd;

        if ((fd=creat(fn, 0666, "rfm=var", "rat=cr")) < 0
        || (ffp=fdopen(fd, "w")) == NULL) {
#else
        if ((ffp=fopen(fn, "w")) == NULL) {
#endif
                mlwrite("Cannot open file for writing");
                return (FIOERR);
        }
        return (FIOSUC);
}

/*
 * Close a file. Should look at the status in all systems.
 */
ffclose()
{
	/* free this since we do not need it anymore */
	if (fline) {
		free(fline);
		fline = NULL;
	}
	eofflag = FALSE;

#if	MSDOS & CTRLZ
	fputc(26, ffp);		/* add a ^Z at the end of the file */
#endif
	
#if     V7 | USG | BSD | (MSDOS & (MSC | TURBO))
        if (fclose(ffp) != FALSE) {
                mlwrite("Error closing file");
                return(FIOERR);
        }
        return(FIOSUC);
#else
        fclose(ffp);
        return (FIOSUC);
#endif
}

/*
 * Write a line to the already opened file. The "buf" points to the buffer,
 * and the "nbuf" is its length, less the free newline. Return the status.
 * Check only at the newline.
 */
ffputline(buf, nbuf)
char    buf[];
{
        register int    i;
#if	CRYPT
	char c;		/* character to translate */

	if (cryptflag) {
	        for (i = 0; i < nbuf; ++i) {
			c = buf[i] & 0xff;
			crypt(&c, 1);
			fputc(c, ffp);
		}
	} else
	        for (i = 0; i < nbuf; ++i)
        	        fputc(buf[i]&0xFF, ffp);
#else
        for (i = 0; i < nbuf; ++i)
                fputc(buf[i]&0xFF, ffp);
#endif

        fputc('\n', ffp);

        if (ferror(ffp)) {
                mlwrite("Write I/O error");
                return (FIOERR);
        }

        return (FIOSUC);
}

/*
 * Read a line from a file, and store the bytes in the supplied buffer. The
 * "nbuf" is the length of the buffer. Complain about long lines and lines
 * at the end of the file that don't have a newline present. Check for I/O
 * errors too. Return status.
 */
ffgetline()

{
        register int c;		/* current character read */
        register int i;		/* current index into fline */
	register char *tmpline;	/* temp storage for expanding line */

	/* if we are at the end...return it */
	if (eofflag)
		return(FIOEOF);

	/* dump fline if it ended up too big */
	if (flen > NSTRING) {
		free(fline);
		fline = NULL;
	}

	/* if we don't have an fline, allocate one */
	if (fline == NULL)
		if ((fline = malloc(flen = NSTRING)) == NULL)
			return(FIOMEM);

	/* read the line in */
#if	PKCODE
	if (!nullflag) {
	if (fgets(fline, NSTRING, ffp) == (char *)NULL) {	/* EOF ? */
		i = 0;
		c = EOF;
	}
	else {
		i = strlen(fline);
		c = 0;
		if (i > 0) {
			c = fline[i-1];
			i--;
		}
	}
	}
	else {
		i = 0;
		c = fgetc(ffp);
	}
	while (c != EOF && c != '\n') {
#else
        i = 0;
        while ((c = fgetc(ffp)) != EOF && c != '\n') {
#endif
#if	PKCODE
	if (c) {
#endif
                fline[i++] = c;
		/* if it's longer, get more room */
                if (i >= flen) {
                	if ((tmpline = malloc(flen+NSTRING)) == NULL)
                		return(FIOMEM);
                	strncpy(tmpline, fline, flen);
                	flen += NSTRING;
                	free(fline);
                	fline = tmpline;
                }
#if	PKCODE
	}
		c = fgetc(ffp);
#endif
        }

	/* test for any errors that may have occured */
        if (c == EOF) {
                if (ferror(ffp)) {
                        mlwrite("File read error");
                        return(FIOERR);
                }

                if (i != 0)
			eofflag = TRUE;
		else
			return(FIOEOF);
        }

	/* terminate and decrypt the string */
        fline[i] = 0;
#if	CRYPT
	if (cryptflag)
		crypt(fline, strlen(fline));
#endif
        return(FIOSUC);
}

int fexist(fname)	/* does <fname> exist on disk? */

char *fname;		/* file to check for existance */

{
	FILE *fp;

	/* try to open the file for reading */
	fp = fopen(fname, "r");

	/* if it fails, just return false! */
	if (fp == NULL)
		return(FALSE);

	/* otherwise, close it and report true */
	fclose(fp);
	return(TRUE);
}
