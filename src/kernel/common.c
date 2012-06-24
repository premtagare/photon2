// Athena 7736

#include "common.h"

// Write a byte out to the specified port.
void outb(unsigned short port, unsigned char value)
{
   asm volatile ("outb %1, %0" : : "dN" (port), "a" (value));
} 

// Read one byte from the specified port.
unsigned char inb(unsigned short port)
{
   unsigned char ret;
   asm volatile("inb %1, %0" : "=a" (ret) : "dN" (port));
   return ret;
}

// Read one word from the specified port.
unsigned short inw(unsigned short port)
{
   unsigned short ret;
   asm volatile ("inw %1, %0" : "=a" (ret) : "dN" (port));
   return ret;
}
