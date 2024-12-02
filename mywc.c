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
   while ((iChar = getchar()) != EOF)
   {
      lCharCount++;
      fprintf(stderr, "Reached here 1\n");
      

      if (isspace(iChar))
      {
         if (iInWord)
         {
            lWordCount++;
            iInWord = FALSE;
            fprintf(stderr, "Reached here 2\n");
      
            
         }
      }
      else
      {
         if (! iInWord) {
            iInWord = TRUE;
            fprintf(stderr, "Reached here 3\n");
      
         }
         
      }

      if (iChar == '\n') {
         lLineCount++;
         fprintf(stderr, "Reached here 4\n");
      
      }
   }

   if (iInWord) {
      lWordCount++;
      fprintf(stderr, "Reached here 5\n");
      
   }

   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}
