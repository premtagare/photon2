// Athena 7736
//
// isr.c -- High level interrupt service routines and interrupt request handlers.
//

#include "common.h"
#include "isr.h"
#include "monitor.h"

// This gets called from our ASM interrupt handler.
void isr_handler(registers_t regs)
{
    monitor_write("recieved interrupt: ");
    print_num(regs.int_no);
    print_char('\n');
}
