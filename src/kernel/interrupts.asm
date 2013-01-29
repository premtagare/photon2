// Athena 7736
// interrupts.asm: common Channel for interrupts.

//Macro for Interrupt without error code
.macro ISR_NOERRCODE IntrNum
    .globl isr\IntrNum
    isr\IntrNum:
        cli             
        push $0
        push $\IntrNum
        jmp isr_channel
        .endm

//Macro for Interrupt with error code
.macro ISR_ERRCODE IntrNum
    .globl isr\IntrNum
    isr\IntrNum:
        cli
	push $0
        push $\IntrNum
        jmp isr_channel
.endm

ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_ERRCODE   8
ISR_NOERRCODE 9
ISR_ERRCODE   10
ISR_ERRCODE   11
ISR_ERRCODE   12
ISR_ERRCODE   13
ISR_ERRCODE   14
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_NOERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31

// After saving processor state calls Interrupt handler in isr.c
isr_channel:
    pusha
    movl %ds,%eax
    pushl %eax

    movl $0x10,%eax
    movl %eax,%ds
    movl %eax,%es
    movl %eax,%fs
    movl %eax,%gs

    call isr_handler

    popl %ebx
    movl %ebx,%ds
    movl %ebx,%es
    movl %ebx,%fs
    movl %ebx,%gs

    popa
    // Clean up pushed error code and isr number
    add $8,%esp
    sti
    iret
