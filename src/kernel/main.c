// Athena 7736
// main.c : Kernel initialization.

#include "monitor.h"
#include "gdtidt.h"

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
    	return 0;
}
