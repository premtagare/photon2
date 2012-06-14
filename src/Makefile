

all:loadb.bin loadk.bin kernel.bin

clean:
	rm *.bin
%.bin:%.s
	nasm -f bin -o $@ $<

#loadb:
#	nasm -f bin -o loadb.bin loadb.s
