/* bigintadd.s
Authors:         VS and AK */


        .equ FALSE, 0
        .equ TRUE, 1

        .section .data

        // ------------------------------------------ //

        .section .bss

        // ------------------------------------------ //

        .section .text

        .global BigInt_add
BigInt_add:
        .equ ADD_STACK_BYTECOUNT, 64 // Why does this make it better?
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
        //str ULCARRY, [sp, ulCarry]
        str ULSUM, [sp, ulSum]
        str LINDEX, [sp, lIndex]
        str LSUMLENGTH, [sp, lSumLength]
        

        mov OADDEND1, x0
        mov OADDEND2, x1
        mov OSUM,     x2

        // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        ldr x0, [OADDEND1]
        ldr x1, [OADDEND2]

        /*In-lining the call to BigInt_larger */
        //if (lLength1 <= lLength2) goto startelse1;
        cmp x0, x1
        ble startelse1inline

        mov LSUMLENGTH, x0 //lLarger = lLength1;
        b endif1inline
        
startelse1inline:
        mov LSUMLENGTH, x1 //lLarger = lLength2;
        
endif1inline: 

        
        mov x0, 0
        mov x1, 1
        cmp x0, x1
        // adcs x0, x0, x1  //reset the carry flag
        
        // if (oSum->lLength <= lSumLength) go to endif
        ldr x0, [OSUM] // loading lLength into
        
        
        cmp x0, LSUMLENGTH

        add OADDEND1, OADDEND1, BigInt_aulDigits_offset
        add OADDEND2, OADDEND2, BigInt_aulDigits_offset
        add OSUM, OSUM, BigInt_aulDigits_offset
        /* OADDEND1, OADDEND2, OSUM now contain pointers to the
        corresponding aulDigits arrays */
        
        ble endif
        

        //memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        // Perhaps we can optimize memset!
        mov x0, OSUM
        mov x1, 0
        mov x2, MAX_DIGITS
        lsl x2, x2, 3 // multiply by 8
        bl memset

endif:

        // lIndex = 0;
        mov LINDEX, 0
        mov ULSUM, 0

        
        /*Using the guarded loop pattern*/
        //if(lIndex >= lSumLength) goto endloop1;
        cmp LINDEX, LSUMLENGTH
        bge endloop1
loop1:
        
        //ulSum += oAddend1->aulDigits[lIndex];
        // add x0, OADDEND1, BigInt_aulDigits_offset // goto aulDigits
        ldr x0, [OADDEND1, LINDEX, lsl 3] // deref lIndex-th entry
        adcs ULSUM, ULSUM, x0
        bcc endif2

        // add x0, OADDEND2, BigInt_aulDigits_offset
        ldr x0, [OADDEND2, LINDEX, lsl 3]
        add ULSUM, ULSUM, x0
        b endif3

endif2: 
        
        //ulSum += oAddend2->aulDigits[lIndex];
        // add x0, OADDEND2, BigInt_aulDigits_offset
        ldr x0, [OADDEND2, LINDEX, lsl 3]
        adcs ULSUM, ULSUM, x0
        
endif3:
        //oSum->aulDigits[lIndex] = ulSum;
        // add x0, OSUM, BigInt_aulDigits_offset
        str ULSUM, [OSUM, LINDEX, lsl 3]
       

        //lIndex++;
        add LINDEX, LINDEX, 1
        cset ULSUM, CS //set ULSUM to be whatever is stored in the carry flag
        //CHECK IF ALLOWED TO DO THIS? It works though!

        //if(lIndex < lSumLength) goto loop1;
        cmp LINDEX, LSUMLENGTH
        blt loop1

endloop1:
        //if (ulCarry != 1) goto endif4;
        mov x0, 1
        cmp ULSUM, x0
        bne endif4 //if (ulCarry != 1) goto endif4;
        
        //if (lSumLength != MAX_DIGITS) goto endif5;
        mov x0, MAX_DIGITS
        cmp LSUMLENGTH, x0
        bne endif5

        // return FALSE;
        mov w0, FALSE
        b epilogue
        /*ldr x30, [sp]
        add sp, sp, ADD_STACK_BYTECOUNT
        ret*/

endif5:

        // oSum->aulDigits[lSumLength] = 1;
        mov x1, 1
        str x1, [OSUM, LSUMLENGTH, lsl 3]

        // lSumLength++;
        add LSUMLENGTH, LSUMLENGTH, 1


endif4:
        // oSum->lLength = lSumLength;
        sub OSUM, OSUM, BigInt_aulDigits_offset
        str LSUMLENGTH, [OSUM] 
        
        // return TRUE;
        mov w0, TRUE
epilogue:
        ldr OADDEND1, [sp, oAddend1]
        ldr OADDEND2, [sp, oAddend2]
        ldr OSUM, [sp, oSum]
        //ldr ULCARRY, [sp, ulCarry]
        ldr ULSUM, [sp, ulSum]
        ldr LINDEX, [sp, lIndex]
        ldr LSUMLENGTH, [sp, lSumLength]
        ldr x30, [sp]
        add sp, sp, ADD_STACK_BYTECOUNT
        ret
        
        .size BigInt_add, (. - BigInt_add)
        

        
        
