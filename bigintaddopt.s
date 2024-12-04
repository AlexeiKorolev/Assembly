/* bigintaddopt.s
Authors:         Venkat Subramanian and Alexei Korolev */


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
        OADDEND1 .req x19
        OADDEND2 .req x20
        OSUM .req x21
        ULCARRY .req x22
        ULSUM .req x23
        LINDEX .req x24
        LSUMLENGTH .req x25
        .equ oAddend1, 8
        .equ oAddend2, 16
        .equ oSum, 24
        .equ ulCarry, 32
        .equ ulSum, 40
        .equ lIndex, 48
        .equ lSumLength, 56
        .equ MAX_DIGITS, 32768
        .equ SIZE_OF_UNSIGNED_LONG, 8
        .equ BigInt_aulDigits_offset, 8
        

        
        sub sp, sp, ADD_STACK_BYTECOUNT
        str x30, [sp]
        str OADDEND1, [sp, oAddend1]
        str OADDEND2, [sp, oAddend2]
        str OSUM, [sp, oSum]
        str ULCARRY, [sp, ulCarry]
        str ULSUM, [sp, ulSum]
        str LINDEX, [sp, lIndex]
        str LSUMLENGTH, [sp, lSumLength]
        

        mov OADDEND1, x0
        mov OADDEND2, x1
        mov OSUM,     x2
        


        // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        ldr x0, [OADDEND1]
        ldr x1, [OADDEND2]
        
        bl BigInt_larger

        mov LSUMLENGTH, x0


        // if (oSum->lLength <= lSumLength) go to endif
        ldr x0, [OSUM] // loading lLength into 
        cmp x0, LSUMLENGTH
        ble endif
        



        //memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        add x0, OSUM, BigInt_aulDigits_offset
        mov x1, 0
        mov x2, MAX_DIGITS
        lsl x2, x2, 3 // multiply by 8
        bl memset



endif:
        // ulCarry = 0;
        mov ULCARRY, 0


        // lIndex = 0;
        mov LINDEX, 0


loop1:
        //if(lIndex >= lSumLength) goto endloop1;
        cmp LINDEX, LSUMLENGTH
        bge endloop1

        //ulSum = ulCarry;
        mov ULSUM, ULCARRY
        
        
        //ulCarry = 0;
        mov ULCARRY, 0

        
        //ulSum += oAddend1->aulDigits[lIndex];
        add x0, OADDEND1, BigInt_aulDigits_offset // goto aulDigits
        ldr x0, [x0, LINDEX, lsl 3] // deref lIndex-th entry
        add ULSUM, ULSUM, x0
        

        //if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2;
        cmp ULSUM, x0 // Ensure x0 contains oAddend1->aulDigits[lIndex]
        bhs endif2

        //ulCarry = 1;
        mov ULCARRY, 1


endif2: 
        
        //ulSum += oAddend2->aulDigits[lIndex];
        add x0, OADDEND2, BigInt_aulDigits_offset
        ldr x0, [x0, LINDEX, lsl 3]
        add ULSUM, ULSUM, x0
        

        //if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif2;
        cmp ULSUM, x0
        bhs endif3


        //ulCarry = 1;
        mov ULCARRY, 1


endif3:
        //oSum->aulDigits[lIndex] = ulSum;
        add x0, OSUM, BigInt_aulDigits_offset
        str ULSUM, [x0, LINDEX, lsl 3]


        //lIndex++;
        add LINDEX, LINDEX, 1


        b loop1

endloop1:
        //if (ulCarry != 1) goto endif4;
        mov x0, 1
        cmp ULCARRY, x0
        bne endif4


        
        //if (lSumLength != MAX_DIGITS) goto endif5;
        mov x0, MAX_DIGITS
        cmp LSUMLENGTH, x0
        bne endif5

        // return FALSE;
        mov w0, FALSE
        b epilogue

endif5:
        // oSum->aulDigits[lSumLength] = 1;
        add x0, OSUM, BigInt_aulDigits_offset
        mov x1, 1
        str x1, [x0, LSUMLENGTH, lsl 3]

        // lSumLength++;
        add LSUMLENGTH, LSUMLENGTH, 1
endif4:
        
        // oSum->lLength = lSumLength;
        str LSUMLENGTH, [OSUM] 
       
        // return TRUE;
        mov w0, TRUE
epilogue:
        ldr OADDEND1, [sp, oAddend1]
        ldr OADDEND2, [sp, oAddend2]
        ldr OSUM, [sp, oSum]
        ldr ULCARRY, [sp, ulCarry]
        ldr ULSUM, [sp, ulSum]
        ldr LINDEX, [sp, lIndex]
        ldr LSUMLENGTH, [sp, lSumLength]
        ldr x30, [sp]
        add sp, sp, ADD_STACK_BYTECOUNT
        ret
        
        .size BigInt_add, (. - BigInt_add)
        

        
        
