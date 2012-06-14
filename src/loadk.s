BITS 16
ORG 10000h

bl_stage2:
	mov ax, 1000h		; Second stage bootloader is located at 10000h 
	mov ds, ax
	mov ax, 1500h		 
	mov ss, ax		; setting stack segment
	mov sp, 3000h

	mov si,BLStage2
	call print_string
	
	;Load FAT12 information from floppy
	mov ax,0x07C0
	mov es,ax
	mov di,0Bh
	mov ax,[es:di]
	mov [BytesPerSector],ax
	add di,2
	mov al,[es:di]
	mov [SectorsPerCluster],al
	add di,1
	mov di,0Eh
	mov ax,[es:di]
	mov [ReservedSectors],ax
	add di,2
	mov al,[es:di]
	mov [NumberOfFATs],al
	add di,1
	mov ax,[es:di]
	mov [RootDirEntries],ax
	add di,2	
	mov ax,[es:di]
	mov [TotalSectors],ax
	add di,2
	mov al,[es:di]
	mov [MediaDescriptor],al
	add di,1
        mov ax,[es:di]
	mov [SectorsPerFAT],ax
	add di,2
	mov ax,[es:di]
	mov [SectorsPerTrack],ax
	add di,2
	mov ax,[es:di]
	mov [NumberOfHeads],ax

	;Parse root directory entries to find kernel.bin and load it at address 0x20000 in RAM
	mov ax,0x1C00
	mov es,ax
	mov ax,1			; Count of directory entries read
	push ax
	mov di,0x20			; First Entry's filename location
	push di
.NextDirEntry:
	mov si,kernel
	mov cx,11
	cld
	repe cmpsb
	je .Loadkernel
	pop di
	add di,0x40			; Each directory Entry is 64 bytes long
	pop ax
	inc ax
	push ax
	push di
	cmp ax,112			; [RootDirEntries]/2 since each directory entry is taking 64 bytes instead of 32
	jle .NextDirEntry
	mov si,Error
	call print_string
	jmp $
.Loadkernel:
	pop di
	pop ax
	
	;calculate the number of sectors to be loaded
	add di,0x1C			; location of file size in directory entry
	mov ax,[es:di]			; size of file lower word
	add di,2
	mov dx,[es:di]			; size of the file higher word
	mov bx,512
	div bx
	cmp dx,0h
	je .aftsectadj
	inc ax
.aftsectadj:
	mov word [kernelsize],ax
	mov word [kernelsizetoload],0
	cmp ax,896
	jle .proceedtoload
	sub ax,896
	mov [kernelsizetoload],ax
	mov ax,896
.proceedtoload:
	mov [kernelcurblocksize],ax
	push ax
	mov bx,0
	sub di,4
	mov cx,[es:di]
	push cx
	mov dx,0x2000
	mov [st2kernelbaseadd],dx
	mov [st2curkernelseg],dx
.nextSect:
	mov ax,1
	add cx,32			; 33 sectores are used for reserved, FAT and root directory entries
	mov dx,[st2curkernelseg]
	call read_from_floppy
	pop di
	pop ax
	dec ax
	cmp ax,0
	je .done
	push ax
	mov bx,ax
	mov ax,[kernelcurblocksize]
	sub ax,bx
	mov bx,512
	xor dx,dx
	mul bx
	shl dx,12
	add dx,[st2kernelbaseadd]
	mov [st2curkernelseg],dx
	mov bx,ax
	mov ax,0x1900
	mov es,ax
	xor dx,dx
	mov ax,di
	mov cx,2
	div cx
	add di,ax
	mov cx,[es:di]
	cmp dx,0h
	je .even
	shr cx,4
	push cx
	jmp .nextSect
.even:
	and cx,0x0FFF
	push cx
	jmp .nextSect
.done:
	;store di, required for next kernel sector in floppy
	mov [nextkersecfloppy],di
	;copy kernel from 0x20000 to 0x100000
	cli			; make sure to clear interrupts first!
	push ds

	lgdt [descrip]		; load GDT into GDTR
	mov  eax, cr0		; set bit 0 in cr0--enter pmode
	or   eax, 1
	mov  cr0, eax
	mov  bx,0x10		; descriptor for data segment
	mov  ds,bx
	mov  eax,cr0		; switch back to real mode
	and  eax,0xFFFFFFFE
	mov  cr0,eax
	
	in al,0x92		; enable A20 line, unreal mode!!
	or al,2
	out 0x92,al
	
	pop ds
	sti

	mov cx,[kernelcurblocksize]
	and ecx,0x0000FFFF
	push ds
	
	xor dx,dx
	mov ax,cx
	mov ecx,0x00000000
	mov bx,512
	mul bx
.addseg:
	cmp dx,0
	je .lessthanseg
	dec dx
	add ecx,0x00010000
	jmp .addseg
	
.lessthanseg:
	and eax,0x0000FFFF
	add ecx,eax
	mov dx,[count]
	add dx,1
	mov [count],dx
	sub dx,1
	mov edi,0x00000000
	mov edi,0x00100000
.nextblock:
	cmp dx,0
	je .afterblockcomp
	sub dx,1
	add edi,0x00070000
	jmp .nextblock
.afterblockcomp:
	mov ax,0x0000
	mov ds,ax   
	mov esi,0x020000
.nextdata:
	mov word bx,[ds:esi]
	mov word [ds:edi],bx
	add esi,2
	add edi,2
	sub ecx,2
	cmp ecx,0
	jg .nextdata

	mov bx,0xFFFF			; what is this code doing here..
	mov ax,50			; nothing. Sometimes assembler gets angry if I remove this.

	pop ds
	mov ax,[kernelsizetoload]
	cmp ax,0
	je .donekerloading
	mov word [kernelsizetoload],0
	cmp ax,896
	jle .proceedtoload2
	sub ax,896
	mov [kernelsizetoload],ax
	mov ax,896

.proceedtoload2:
	mov [kernelcurblocksize],ax
	push ax
	mov bx,0
	mov dx,0x2000
	mov di,[nextkersecfloppy]
        mov ax,0x1900
        mov es,ax
        xor dx,dx
        mov ax,di
        mov cx,2
        div cx
        add di,ax
        mov cx,[es:di]
        cmp dx,0h
        je .even2
        shr cx,4
        push cx
        jmp .nextSect
.even2:
        and cx,0x0FFF
        push cx
        jmp .nextSect		

.donekerloading:
	mov ax,0xABCD
	call print_word
	mov ax,0x0000
	mov ds,ax
	mov bx, 0x0f01         ; attrib/char of smiley
   	mov eax, 0x0b8000      ; note 32 bit offset
   	mov word [ds:eax], bx
	;jump to protected mode
	mov ax, 1000h		; Second stage bootloader is located at 10000h 
	mov ds, ax
	mov ax, 1500h		 
	mov ss, ax		; setting stack segment
	cli
        lgdt [descrip]          ; load GDT into GDTR
        mov  eax, cr0           ; set bit 0 in cr0--enter pmode
        or   eax, 1
        mov  cr0, eax
	mov eax,0x00000000
	mov ax,0x10
	mov ds,ax
	mov ss,ax
	mov es,ax
	mov esp,0x50000
	jmp dword 0x8:0x00100000	; jump to kernel
	nop
	nop
	jmp $
	hlt
	
	;data part
	BLStage2 db 'BL Stage2',13,10,0	
	kernel db 'KERNEL  BIN',0
	Error db 'Error',0
	kernelsize dw 0
	kernelsizetoload dw 0
	kernelcurblocksize dw 0
	st2kernelbaseadd dw 0
	st2curkernelseg dw 0
	nextkersecfloppy dw 0
	count dw 0	

	;FAT12 information
	BytesPerSector dw 0
	SectorsPerCluster db 0
	ReservedSectors dw 0
	NumberOfFATs db 0
	RootDirEntries dw 0
	TotalSectors dw 0
	MediaDescriptor db 0
	SectorsPerFAT dw 0
	SectorsPerTrack dw 0
	NumberOfHeads dw 0
	FileSystemID db 'FAT12   ' 	;This can be used to check if the filesystem is FAT12
	RootDirStartSector dw 0
	TotalSectInRootDir dw 0

; Offset 0 in GDT: Descriptor code=0
 
gdt_data: 
	dd 0 				; null descriptor
	dd 0 
 
; Offset 0x8 bytes from start of GDT: Descriptor code therfore is 8
 
; gdt code:				; code descriptor
	dw 0FFFFh 			; limit low
	dw 0 				; base low
	db 0 				; base middle
	db 10011010b 			; access
	db 11001111b 			; granularity
	db 0 				; base high
 
; Offset 16 bytes (0x10) from start of GDT. Descriptor code therfore is 0x10.
 
; gdt data:				; data descriptor
	dw 0FFFFh 			; limit low (Same as code)
	dw 0 				; base low
	db 0 				; base middle
	db 10010010b 			; access
	db 11001111b 			; granularity
	db 0				; base high
 
;...Other descriptors begin at offset 0x18. Remember that each descriptor is 8 bytes in size.
 
end_of_gdt:
descrip: 
	dw end_of_gdt - gdt_data - 1 	; limit (Size of GDT)
	dd gdt_data 			; base of GDT


read_from_floppy:
	push bx				; offset address for loading
	push dx				; segment address for loading
	push ax				; number of sectors to loaded
	push cx				; sector

.Reset:
        mov	ah, 0                   ; reset floppy disk function
        mov	dl, 0                   ; drive 0 is floppy drive
        int	13h                     ; call BIOS
        jc	.Reset                  ; If Carry Flag (CF) is set, there was an error. Try resetting again

.Read:
	pop 	ax			; sector
	sub	ax,1			; to make division simple
	mov	bx,[SectorsPerTrack]
	add	bx,bx			; since there are two heads
	div	bl
	mov	ch,al			; track
	mov	bx,[SectorsPerTrack]
	mov	al,ah
	mov	ah,00h
	div	bl
	mov	dh,al			; head
	mov	cl,ah			; sector
	add	cl,1			; correction for simplification
	pop	ax			; number of sectors to be loaded
        mov	ah, 02h                 ; function 2
        mov	dl, 0                   ; drive number. Remember Drive 0 is floppy drive.
        
	pop	bx			; segment address for loading data
        mov	es, bx
        pop	bx
        int	13h                     ; call BIOS - Read the sector
        jc	.Read                   ; Error, so try again
	ret

print_word:
	push ax
	mov al,ah
	call print_byte
	pop ax
	call print_byte
	ret

print_byte:
	mov bl,al
	shr al,4
	cmp al,9
	jg .charval
	add al,30h
	jmp .printval
.charval:
	add al,55
.printval:
	mov ah,0Eh
	int 10h
	mov al,bl
	and al,0Fh
	cmp al,9
	jg .charval2
	add al,30h
	jmp .printval2
.charval2:
	add al,55
.printval2:
	mov ah,0Eh
	int 10h
	ret
	
print_string:				; Routine: output string in SI to screen
	mov ah, 0Eh			; int 10h 'print char' function

.repeat:
	lodsb				; Get character from string
	cmp al, 0
	je .done			; If char is zero, end of string
	int 10h				; Otherwise, print it
	jmp .repeat

.done:
	ret

