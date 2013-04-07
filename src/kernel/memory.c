// memory.c
// routines to allocate memory

#include "memory.h"
#include "monitor.h"


unsigned mem_limit = 0x40000000;  // setting limit to 1GB

// Kernel end is defined in link.ld
extern unsigned end;
unsigned alloc_ptr = (unsigned) (&end);

void * kmalloc(unsigned size, int page_align)
{
    unsigned assigned_addr;

    if( page_align ==1 && (alloc_ptr & 0x00000FFF) )
    {
        alloc_ptr &= 0xFFFFF000;
        alloc_ptr += 0x1000;
    }

    if(alloc_ptr + size >= mem_limit)
    {
        monitor_write("Allocation Error: Insufficient memory\n");
        return NULL;
    }
    assigned_addr = alloc_ptr;
    alloc_ptr += size;
    return (void *)assigned_addr;
}
