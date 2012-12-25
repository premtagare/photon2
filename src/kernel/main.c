// Athena 7736
// main.c : Kernel initialization.

#include "monitor.h"
#include "gdtidt.h"

int main(struct multiboot *mBootPtr)
{
	// Initialise the screen (by clearing it)
	monitor_clear();
	monitor_write("Initializing Kernel...");
	gdt_initialize();
	monitor_write("Initialized GDT...");
    	return 0;
}
