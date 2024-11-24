        .equ FALSE, 0
        .equ TRUE, 1

        .section .data

        // ------------------------------------------ //

        .section .bss

        // ------------------------------------------ //

        .section .text

        .equ STACK_OFFSET_BYTECOUNT, 16
BigInt_larger:
        sub sp, sp, STACK_OFFSET_BYTECOUNT
        str x30, [sp] // push x30
        
        sub sp, sp, STACK_OFFSET_BYTECOUNT
        str x0, [sp] // push lLength1

        /* HOW MANY BITS TO PUSH TO??? */
        sub sp, sp, STACK_OFFSET_BYTECOUNT
        str x1, [sp] // push lLength2
        
        // mov x2, x0 // lLength1 in x2 now.

        // if (lLength1 <= lLength2) goto startelse1;
        cmp x0, x1
        ble  startelse1

        // lLarger = lLength1;
        // goto endif;
        add sp, sp, STACK_OFFSET_BYTECOUNT
        ldr x1, [sp] 
        sub sp, sp, STACK_OFFSET_BYTECOUNT * 2
        str x1, [sp]
        b endif

startelse1:
        // lLarger = lLength2;
        ldr x0, [sp] 
        sub sp, sp, STACK_OFFSET_BYTECOUNT
        str x0, [sp]
        b endif

endif:  
        ldr x0, [sp]
        add sp, sp, STACK_OFFSET_BYTECOUNT * 3
        ldr x30 [sp]
        add sp, sp, STACK_OFFSET_BYTECOUNT
        
        ret

BigInt_add:
        sub sp, sp, STACK_OFFSET_BYTECOUNT
        str x30, [sp]
         
        sub sp, sp, STACK_OFFSET_BYTECOUNT
        str x0, [sp] // push oAddend1

        sub sp, sp, STACK_OFFSET_BYTECOUNT
        str x1, [sp] // push oAddend2

        sub sp, sp, STACK_OFFSET_BYTECOUNT
        str x2, [sp] // push oSum

        
        bl BigInt_larger
        

        
        
