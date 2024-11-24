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
#include <stdlib.h>

enum {MAX_STRING_LENGTH = 50000, MAX_LINE_COUNT = 1000};

int main(void)
{
   size_t count = 0;
   { /* Boundary tests */
      char* tests[] = {
         "",
         "a",
         "\n\n",
         "  ",
         " a\n ",
         "abcde"
      };
      char fileName[MAX_STRING_LENGTH];
      FILE * file;
      size_t i = 0;

      while(i < sizeof(tests)/sizeof(size_t)) {
         sprintf(fileName, "mywc%d.txt", (int) count);
         file = fopen(fileName,"w");
         fprintf(file, tests[i]);

         i += 1;
         count++;
      }
      fprintf(stderr, "LAST INDEX FOR BOUNDARY TESTS : {%d}\n", (int)i);
   }

   

   { /* Statement test */
      
      char* tests[] = {
         " word word2\n",
         "aa\t\nfinishword"
      };
      char fileName[50];
      FILE * file;
      size_t i = 0;

      while(i < sizeof(tests)/sizeof(size_t)) {
         sprintf(fileName, "mywc%d.txt", (int) count);
         file = fopen(fileName,"w");
         fprintf(file, tests[i]);

         i += 1;
         count++;
      }

      fclose(file);
   }

   {/* Stress test */
      int charType, character, seed;
      char fileName[50];
      int newLineCount = 0;
      int inputStringLength = 0;
      FILE * file;

      
      
      sprintf(fileName, "mywc%d.txt", (int) count);
      count++;
      file = fopen(fileName, "w");

      while(inputStringLength < MAX_STRING_LENGTH) {
         charType = rand()%3;

         if(charType == 0) {
            /* add random character */
            character = rand()%127;
         
            if(character == 0x09  || (character >= 0x21 && character <= 0x7E)) {          
               fputc(character, file);
               inputStringLength++;
            }
         }
         
         else if(charType == 1) {
            /* add space */
            fputc(0x20, file);
            inputStringLength++;
         }
         /*Ignore new line if already reached MAX_LINE_COUNT */
         else if (charType == 2 && newLineCount < MAX_LINE_COUNT) {
            /*add new line*/
            fputc(0x0A, file);
            inputStringLength++;
            newLineCount++;
         }
         
      }
      
      fclose(file);
      
      

   }


   return 0;
   
}
