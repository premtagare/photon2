// main.c 
// Kernel initialization.

#include "monitor.h"
#include "gdtidt.h"
#include "timer.h"
#include "paging.h"

int main(struct multiboot *mBootPtr)
{
	// Initialise the screen (by clearing it)
	monitor_clear();
	monitor_write("Initializing Kernel...\n\n");
	gdt_initialize();
	idt_initialize();
	monitor_write("Initialized GDT & IDT.\n");

    initialise_paging();
    monitor_write("Enabled paging\n");

    unsigned *ptr = (unsigned*) 0xA0000000;
    unsigned var = *ptr;
    
    return 0;
}
