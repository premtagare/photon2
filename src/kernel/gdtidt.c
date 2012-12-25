// Athena 7736

#include "gdtidt.h"
#define NUM_GDT_DESCR 5

struct gdt_struct gdts[NUM_GDT_DESCR];
struct gdt_base_struct gdt_base;

void create_gdt()
{

  // Null GDT
  gdts[0].limit_low = 0;
  gdts[0].base_low = 0;
  gdts[0].base_mid = 0;
  gdts[0].privilege = 0;
  gdts[0].limit_and_gran = 0;
  gdts[0].base_high = 0;

  // GDT entry for Kernel code
  gdts[1].limit_low = 0xFFFF;
  gdts[1].base_low = 0;
  gdts[1].base_mid = 0;
  gdts[1].privilege = 0x9A;
  gdts[1].limit_and_gran = 0xCF;
  gdts[1].base_high = 0;

  // GDT entry for Kernel data
  gdts[2].limit_low = 0xFFFF;
  gdts[2].base_low = 0;
  gdts[2].base_mid = 0;
  gdts[2].privilege = 0x92;
  gdts[2].limit_and_gran = 0xCF;
  gdts[2].base_high = 0;

    // GDT entry for User code
  gdts[3].limit_low = 0xFFFF;
  gdts[3].base_low = 0;
  gdts[3].base_mid = 0;
  gdts[3].privilege = 0xFA;
  gdts[3].limit_and_gran = 0xCF;
  gdts[3].base_high = 0;

  // GDT entry for User data
  gdts[4].limit_low = 0xFFFF;
  gdts[4].base_low = 0;
  gdts[4].base_mid = 0;
  gdts[4].privilege = 0xF2;
  gdts[4].limit_and_gran = 0xCF;
  gdts[4].base_high = 0;

  gdt_base.limit = (NUM_GDT_DESCR * sizeof(struct gdt_struct)) - 1; 
  gdt_base.base = (unsigned int) &gdts[0];

}

int gdt_initialize()
{
  create_gdt();

  // Load GDT and switch to kernel GDT entry.
  asm volatile ("movl %0,%%eax"::"r"(&gdt_base):"%eax");
  asm volatile ("lgdt (%eax)");
  asm volatile ("movl $0x10,%eax \n");
  asm volatile ("movl %eax,%ds \n");
  asm volatile ("movl %eax,%es \n");
  asm volatile ("movl %eax,%fs \n");
  asm volatile ("movl %eax,%gs \n");
  asm volatile ("movl %eax,%ss \n");
  asm volatile ("ljmp $0x08,$next \n");
  asm volatile ("next:xorl %eax,%eax \n");
   
}

