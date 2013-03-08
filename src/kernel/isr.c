// isr.c
// High level interrupt service routines and interrupt request handlers.

#include "common.h"
#include "isr.h"
#include "monitor.h"

isr_t interrupt_handlers[256];

void register_interrupt_handler(unsigned char n, isr_t handler)
{
    interrupt_handlers[n] = handler;
}

// This gets called from our ASM interrupt handler.
void isr_handler(registers_t regs)
{
    monitor_write("recieved interrupt: ");
    print_num(regs.int_no);
    print_char('\n');

    if (interrupt_handlers[regs.int_no] != 0)
    {
        isr_t handler = interrupt_handlers[regs.int_no];
        handler(regs);
    }
}

// This gets called from our ASM interrupt handler channel.
void irq_handler(registers_t regs)
{
    // Send an EOI (end of interrupt) signal to the PICs.
    // If this interrupt involved the slave.
    if (regs.int_no >= 40)
    {
        // Send reset signal to slave.
        outb(0xA0, 0x20);
    }
    // Send reset signal to master. (As well as slave, if necessary).
    outb(0x20, 0x20);

    if (interrupt_handlers[regs.int_no] != 0)
    {
        isr_t handler = interrupt_handlers[regs.int_no];
        handler(regs);
    }

}
