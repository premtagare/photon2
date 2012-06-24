// Athena 7736
// main.c : Kernel initialization.

#include "monitor.h"

int main(struct multiboot *mBootPtr)
{
	// Initialise the screen (by clearing it)
	monitor_clear();
	monitor_write("Initializing Kernel...");
    	return 0;
}
