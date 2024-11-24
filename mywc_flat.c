/*--------------------------------------------------------------------*/
/* mywc.c                                                             */
/* Author: Bob Dondero                                                */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void)
{
   
  beginwhile:
   if ((iChar = getchar()) == EOF) goto endwhile1;
   
   lCharCount++;

   if (!isspace(iChar)) goto startelse1;

   if (!iInWord) goto endif1;
   lWordCount++;
   iInWord = FALSE;

   goto endif1;
  startelse1:
      
   if (iInWord) goto endif1;
   iInWord = TRUE;
  endif1:

   if (iChar != '\n') goto endif2;
   lLineCount++;
  endif2:
   
   goto beginwhile;
  endwhile1:

   if (!iInWord) goto endif3;
   lWordCount++;
  endif3:

   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}
