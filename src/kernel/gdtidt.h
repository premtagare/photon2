// Athena 7736

#include "common.h"

#ifndef GDTIDT_H
#define GDTIDT_H

// format for each GDT entry
struct gdt_struct
{
  unsigned short limit_low;
  unsigned short base_low;
  unsigned char base_mid;
  unsigned char privilege; 
  unsigned char limit_and_gran;
  unsigned char base_high;
} __attribute__((packed));


struct gdt_base_struct
{
  unsigned short limit;
  unsigned int base;
} __attribute__((packed));


int gdt_initialize();

#endif
