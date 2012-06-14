BITS 32
ORG 0100000h

start:
	mov ax,0x0000
	mov bx, 0x0f01         ; prints smiley at 4th place on screen,
   	mov eax, 0x0b8008      ; be happy you reached protected world!!
   	mov word [ds:eax], bx
	hlt	
