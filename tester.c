/* TESTS TO ADD:
 * empty file
 * 1 character no spaces
 * 2 /n
 * 2 space characters
 * \s a \n \s 
 * 5 characters no whitespace
 */



#include <stdio.h>
#include <ctype.h>

enum {MAX_STRING_LENGTH = 50001};

int main(void)
{
   { /* Boundary tests */
      char* tests[] = {
         "",
         "a",
         "\n\n",
         "  ",
         " a\n ",
         "abcde"
      };
      char inputString[MAX_STRING_LENGTH];
      FILE * file;
      size_t i = 0;

      while(i < sizeof(tests)/8) {
         sprintf(inputString, "mywc%d", (int) i);
         file = fopen(inputString,"w");
         fprintf(file, tests[i]);

         i += 1;
      }
      fprintf(stderr, "LAST INDEX FOR BOUNDARY TESTS : {%d}", (int)i);
   }

   { /* Statement test */
      
      char* tests[] = {
         " word word2\n",
         "aa\t\nfinishword"
      };
      char inputString[MAX_STRING_LENGTH];
      FILE * file;
      size_t i = 0;

      while(i < sizeof(tests)/8) {
         sprintf(inputString, "mywc%d", (int) i);
         file = fopen(inputString,"w");
         fprintf(file, tests[i]);

         i += 1;
      }

      fclose(file);
   }
   


   

   

   
   

   return 0;
   
}
