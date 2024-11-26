/* bigintadd.s
Authors:         VS and AK */


        .equ FALSE, 0
        .equ TRUE, 1

        .section .data

        // ------------------------------------------ //

        .section .bss

        // ------------------------------------------ //

        .section .text
        
BigInt_larger:
        .equ LARGER_STACK_BYTECOUNT, 32
        .equ lLength1, 8
        .equ lLength2, 16
        .equ lLarger, 24
        
        sub sp, sp, LARGER_STACK_BYTECOUNT
        str x30, [sp] // push x30
        
        str x0, [sp, lLength1] // push lLength1
        str x1, [sp, lLength2] // push lLength2
        
        ldr x0, [sp, lLength1]
        ldr x1, [sp, lLength2]
        // mov x2, x0 // lLength1 in x2 now.
        
        // if (lLength1 <= lLength2) goto startelse1;
        cmp x0, x1
        ble  startelse1

        // lLarger = lLength1;
        // goto endif;
        ldr x0, [sp, lLength1] 
        str x0, [sp, lLarger]
        b endif1

startelse1:
        // lLarger = lLength2;
        ldr x0, [sp, lLength2] 
        str x0, [sp, lLarger]

endif1:  
        ldr x0, [sp, lLarger]
        ldr x30, [sp]
        add sp, sp, LARGER_STACK_BYTECOUNT
        
        ret

        .size BigInt_larger, (. - BigInt_larger)

        .global BigInt_add
BigInt_add:
        .equ ADD_STACK_BYTECOUNT, 64
        .equ oAddend1, 8
        .equ oAddend2, 16
        .equ oSum, 24
        .equ ulCarry, 32
        .equ ulSum, 40
        .equ lIndex, 48
        .equ lSumLength, 56
        /*Are we allowed to declare MAX_DIGITS as an equ here, or something else?*/
        .equ MAX_DIGITS, 32768
        .equ SIZE_OF_UNSIGNED_LONG, 8
        

        
        sub sp, sp, ADD_STACK_BYTECOUNT
        str x30, [sp]
         
        str x0, [sp, oAddend1] // push oAddend1
        str x1, [sp, oAddend2] // push oAddend2

        ldr x10, [x1, 8]
        
        str x2, [sp, oSum] // push oSum


        // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        ldr x0, [sp, oAddend1]
        ldr x0, [x0]
        ldr x1, [sp, oAddend2]
        ldr x1, [x1]

        ldr x14, [sp, oAddend2]
        mov x12, 0
        add x14, x14, 8
        ldr x13, [x14, x12, lsl 3]
        
        bl BigInt_larger

        str x0, [sp, lSumLength]


        // if (oSum->lLength <= lSumLength) go to endif
        ldr x0, [sp, oSum]
        ldr x0, [x0]

        ldr x1, [sp, lSumLength]

        cmp x0, x1
        ble endif


        //memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        ldr x0, [sp, oSum]
        add x0, x0, 8

        ldr x1, 0

        mov x2, MAX_DIGITS
        mov x15, SIZE_OF_UNSIGNED_LONG
        mul x2, x2, x15

        bl memset


endif:
        // ulCarry = 0;
        ldr x0, [sp, ulCarry]
        mov x0, 0
        str x0, [sp, ulCarry]

        // lIndex = 0;
        ldr x1, [sp, lIndex]
        mov x1, 0
        str x0, [sp, lIndex]

loop1:
        //if(lIndex >= lSumLength) goto endloop1;
        ldr x0, [sp, lIndex]
        ldr x1, [sp, lSumLength]

        cmp x0, x1
        bge endloop1

        //ulSum = ulCarry;
        ldr x0, [sp, ulCarry]
        str x0, [sp, ulSum]

        
        //ulCarry = 0;
        mov x0, 0
        str x0, [sp, ulCarry]

        
        //ulSum += oAddend1->aulDigits[lIndex];
        ldr x0, [sp, ulSum]
        ldr x1, [sp, lIndex]
        add x1, x1, 1 // To skip over lLength
        ldr x2, [sp, oAddend1]
        ldr x3, [x2, x1, lsl #3] // load into x3, whatever the value stored at x2 + (x1 * 8) is

        add x0, x0, x3

        str x0, [sp, ulSum]

        //if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2;
        cmp x0, x3
        bhs endif2

        //ulCarry = 1;
        mov x0, 1
        str x0, [sp, ulCarry]

endif2:
        // check if lIndex >= oAddend2->lLength
        mov x3, 0
        ldr x5, [sp, lIndex]
        ldr x1, [sp, oAddend2]
        ldr x1, [x1]
        
        

        
        //ulSum += oAddend2->aulDigits[lIndex];
        
        ldr x0, [sp, ulSum]
        cmp x5, x1
        bge dontSetValue
        ldr x1, [sp, lIndex]
        add x1, x1, 1 // To skip over lLength
        ldr x2, [sp, oAddend2]
        ldr x3, [x2, x1, lsl #3] // load into x3, whatever the value stored at x2 + (x1 * 8) is

dontSetValue:   
        add x0, x0, x3

        str x0, [sp, ulSum]

        //if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif2;
        cmp x0, x3
        bhs endif3

        //ulCarry = 1;
        mov x0, 1
        str x0, [sp, ulCarry]

endif3:
        //oSum->aulDigits[lIndex] = ulSum;
        ldr x0, [sp, ulSum]
        ldr x1, [sp, oSum]
        ldr x2, [sp, lIndex] 
        add x2, x2, 1 // To skip over lLength
        str x0, [x1, x2, lsl #3]


        //lIndex++;
        ldr x0, [sp, lIndex]
        add x0, x0, 1
        str x0, [sp, lIndex]

        b loop1


endloop1:

        //if (ulCarry != 1) goto endif4;
        ldr x0, [sp, ulCarry]
        mov x1, 1
        cmp x0, x1
        bne endif4

        
        //if (lSumLength != MAX_DIGITS) goto endif5;
        ldr x0, [sp, lSumLength]
        mov x1, MAX_DIGITS
        cmp x0, x1
        bne endif5

        mov w0, FALSE
        ldr x30, [sp]
        add sp, sp, ADD_STACK_BYTECOUNT
        ret

endif5:
        /*
        mov x0, 1
        ldr x1, [sp, oSum]
        ldr x2, [sp, lSumLength]
        add x2, x2, 1
        str x0, [x1, x2, lsl #3]*/

        mov x0, 1
        ldr x1, [sp, oSum]
        ldr x2, [sp, lSumLength]
        add x1, x1, 8
        str x0, [x1, x2, lsl 3]

        ldr x2, [sp, lSumLength]
        add x2, x2, 1
        str x2, [sp, lSumLength]

endif4:
        ldr x0, [sp, oSum]
        ldr x1, [sp, lSumLength]
        str x1, [x0]

        mov w0, TRUE
        ldr x30, [sp]
        add sp, sp, ADD_STACK_BYTECOUNT
        ret
        
        .size BigInt_add, (. - BigInt_add)
        

        
        
