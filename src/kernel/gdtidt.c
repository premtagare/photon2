// Athena 7736

#include "gdtidt.h"
#define NUM_GDT_DESCR 5
#define NUM_IDT_DESCR 256

struct gdt_struct gdts[NUM_GDT_DESCR];
struct gdt_base_struct gdt_base;

struct idt_struct idts[NUM_IDT_DESCR];
struct idt_base_struct idt_base;

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

void set_idt(int num,int handler,unsigned short descr, unsigned char flags)
{
  idts[num].addr_low  = handler & 0xFFFF;
  idts[num].addr_high = (handler >> 16 ) & 0xFFFF;
  idts[num].zero_bits = 0;
  idts[num].descr_sel = descr;
  idts[num].flags     = flags;
}

int idt_initialize()
{
  memset_int(&idts,0,sizeof(struct idt_struct)*NUM_IDT_DESCR);

  idt_base.limit = (NUM_IDT_DESCR*sizeof(struct idt_struct))-1;
  idt_base.base  = (unsigned int)&idts;

  set_idt(0, (unsigned int) isr0, 0x08, 0x8E);
  set_idt(1, (unsigned int) isr1, 0x08, 0x8E);
  set_idt(2, (unsigned int) isr2, 0x08, 0x8E);
  set_idt(3, (unsigned int) isr3, 0x08, 0x8E);
  set_idt(4, (unsigned int) isr4, 0x08, 0x8E);
  set_idt(5, (unsigned int) isr5, 0x08, 0x8E);
  set_idt(6, (unsigned int) isr6, 0x08, 0x8E);
  set_idt(7, (unsigned int) isr7, 0x08, 0x8E);
  set_idt(8, (unsigned int) isr8, 0x08, 0x8E);
  set_idt(9, (unsigned int) isr9, 0x08, 0x8E);
  set_idt(10, (unsigned int) isr10, 0x08, 0x8E);
  set_idt(11, (unsigned int) isr11, 0x08, 0x8E);
  set_idt(12, (unsigned int) isr12, 0x08, 0x8E);
  set_idt(13, (unsigned int) isr13, 0x08, 0x8E);
  set_idt(14, (unsigned int) isr14, 0x08, 0x8E);
  set_idt(15, (unsigned int) isr15, 0x08, 0x8E);
  set_idt(16, (unsigned int) isr16, 0x08, 0x8E);
  set_idt(17, (unsigned int) isr17, 0x08, 0x8E);
  set_idt(18, (unsigned int) isr18, 0x08, 0x8E);
  set_idt(19, (unsigned int) isr19, 0x08, 0x8E);
  set_idt(20, (unsigned int) isr20, 0x08, 0x8E);
  set_idt(21, (unsigned int) isr21, 0x08, 0x8E);
  set_idt(22, (unsigned int) isr22, 0x08, 0x8E);
  set_idt(23, (unsigned int) isr23, 0x08, 0x8E);
  set_idt(24, (unsigned int) isr24, 0x08, 0x8E);
  set_idt(25, (unsigned int) isr25, 0x08, 0x8E);
  set_idt(26, (unsigned int) isr26, 0x08, 0x8E);
  set_idt(27, (unsigned int) isr27, 0x08, 0x8E);
  set_idt(28, (unsigned int) isr28, 0x08, 0x8E);
  set_idt(29, (unsigned int) isr29, 0x08, 0x8E);
  set_idt(30, (unsigned int) isr30, 0x08, 0x8E);
  set_idt(31, (unsigned int) isr31, 0x08, 0x8E);

  // Load IDT
  asm volatile ("movl %0,%%eax"::"r"(&idt_base):"%eax");
  asm volatile ("lidt (%eax)");
}

