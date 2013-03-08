// main.c 
// Kernel initialization.

#include "monitor.h"
#include "gdtidt.h"
#include "timer.h"

int main(struct multiboot *mBootPtr)
{
	// Initialise the screen (by clearing it)
	monitor_clear();
	monitor_write("Initializing Kernel...\n");
	gdt_initialize();
	monitor_write("Initialized GDT.\n");
	idt_initialize();
	monitor_write("Initialized Interrupts.\n");
	asm volatile ("int $0x0");
	asm volatile ("int $8");
	asm volatile ("int $0x1F");

	asm volatile ("sti");
	init_timer(50);

    	return 0;
}
