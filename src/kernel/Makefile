# Makefile for compiling kernel

SOURCES=boot.o main.o monitor.o common.o gdtidt.o isr.o interrupts.o timer.o memory.o paging.o

CFLAGS=-g -nostdlib -nostdinc -fno-builtin -fno-stack-protector -m32
LDFLAGS=-Tlink.ld -melf_i386
ASFLAGS=-felf

all: $(SOURCES) link

clean:
	-rm *.o kernel.bin

link:
	ld $(LDFLAGS) -o kernel.bin $(SOURCES)

%.o:%.asm
	as -g --32 -o $@ $<

.s.o:
	nasm $(ASFLAGS) $<
