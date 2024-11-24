/*--------------------------------------------------------------------*/
/* mywc.s                                                             */
/* Author: Venkat Subramanian and Alexei Korolev                      */
/*--------------------------------------------------------------------*/
        
        .equ FALSE, 0
        .equ TRUE, 1

        .section .rodata
printfstring:
        .string "%7ld %7ld %7ld\n"
        

        .section .data

lLineCount:
        .skip 8
lWordCount:
        .skip 8
lCharCount:
        .skip 8
iChar:
        .skip 4
iInWord:
        .skip 4


        .section .text


        .equ   MAIN_STACK_BYTECOUNT, 16

        .global main

main:
        //Prolog
        sub sp,sp, MAIN_STACK_BYTECOUNT
        str x30, [sp]

        

        
beginwhile:

        // if ((iChar = getchar()) == EOF) goto endwhile1;
        bl getchar
        adr x1, iChar
        strb w0, [x1]
        cmp w0, -1
        beq endwhile1

        // lCharCount++;
        adr x2, lCharCount
        ldr x3, [x2]
        add x3, x3, 1
        str x3, [x2]


        //if (!isspace(iChar)) goto startelse1;
        adr x1, iChar
        ldrb w0, [x1]
        bl isspace
        cmp w0, 0
        beq startelse1

        //if (!iInWord) goto endif1;
        adr x1, iInWord
        ldr w0, [x1]
        cmp w0, 0
        beq endif1

        //  lWordCount++;
        adr x2, lWordCount
        ldr x3, [x2]
        add x3, x3, 1
        str x3, [x2]

        //  iInWord = FALSE;
        mov x3, FALSE
        adr x2, iInWord
        str x3, [x2]
        

        b endif1

startelse1:     
        //if (iInWord) goto endif1;
        adr x1, iInWord
        ldr w0, [x1]
        cmp w0, 0
        bne endif1

        //iInWord = TRUE;
        mov x3, TRUE
        adr x2, iInWord
        str x3, [x2]

endif1:
        //if (iChar != '\n') goto endif2;
        adr x1, iChar
        ldr w0, [x1]
        // CHECK IF WE CAN HARDCODE ASCII
        mov w3, 10
        cmp w0, w3
        bne endif2

        adr x2, lLineCount
        ldr x3, [x2]
        add x3, x3, 1
        str x3, [x2]

endif2:
        b beginwhile
endwhile1:

        //  if (!iInWord) goto endif3;
        adr x1, iInWord
        ldr w0, [x1]
        cmp w0, 0
        beq endif3

        // lWordCount++;
        adr x2, lWordCount
        ldr x3, [x2]
        add x3, x3, 1
        str x3, [x2]

endif3:

        /* printf("%7ld %7ld %7ld\n", lLineCount, lWordCount,
                        lCharCount); */
        adr x0, printfstring
        adr x29, lLineCount
        ldr x1, [x29]
        adr x29, lWordCount
        ldr x2, [x29]
        adr x29, lCharCount
        ldr x3, [x29]
        bl printf

        // Epilogue
        mov w0, 0
        ldr x30, [sp]
        add sp,sp, MAIN_STACK_BYTECOUNT
        
        ret

        .size main, (. - main)
        
        
        
        

        
        
        
        

        
   


        
        