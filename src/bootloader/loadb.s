BITS 16
ORG 03Eh  ; this program is present in MBR after FAT12 filesystem information

start:
	mov ax, 07c0h		; Place in RAM where MBR gets loaded by BIOS
	mov ds, ax
	add ax, 20h		; setting stack
	mov ss, ax
	mov sp, 4096

	mov si,BLStage1
	call print_string
	
	;Load FAT12 information from floppy
;	mov di,0Bh
;	mov ax,[ds:di]
;	mov [BytesPerSector],ax
;	add di,2
;	mov al,[ds:di]
;	mov [SectorsPerCluster],al
;	add di,1
	mov di,0Eh
	mov ax,[ds:di]
	mov [ReservedSectors],ax
	add di,2
	mov al,[ds:di]
	mov [NumberOfFATs],al
	add di,1
	mov ax,[ds:di]
	mov [RootDirEntries],ax
	add di,2	
;	mov ax,[ds:di]
;	mov [TotalSectors],ax
	add di,2
;	mov al,[ds:di]
;	mov [MediaDescriptor],al
	add di,1
        mov ax,[ds:di]
	mov [SectorsPerFAT],ax
	add di,2
	mov ax,[ds:di]
	mov [SectorsPerTrack],ax
	add di,2
;	mov ax,[ds:di]
;	mov [NumberOfHeads],ax

	;Load Root Directory from floppy
	mov bx,[ReservedSectors]
	xor ax,ax
	mov al,[NumberOfFATs]
	mov cx,[SectorsPerFAT]
	mul cx
	add ax,bx
	add ax,1  			; next sector is starting sector
	mov [RootDirStartSector],ax

	mov ax,[RootDirEntries]
	mov bl,32
	mul bl
	xor dx,dx
	mov bx,512
	div bx
	mov [TotalSectInRootDir],ax

	mov ax,[TotalSectInRootDir]
	mov bx,0000h
	mov cx,[RootDirStartSector]
	mov dx,0x1C00
	call read_from_floppy

	;Load FATs
	xor ax,ax
	mov al,[SectorsPerFAT]
	mov bl,[NumberOfFATs]
	mul bl
	mov bx,0000h
	mov cx,[ReservedSectors]
	add cx,1
	mov dx,0x1900
	call read_from_floppy

	;Parse root directory entries to find loadk.bin and load it at address 0x10000 in RAM
	mov ax,0x1C00
	mov es,ax
	mov ax,1			; Count of directory entries read
	push ax
	mov di,0x20			; First Entries filename location
	push di
.NextDirEntry:
	mov si,BLStage2
	mov cx,11
	cld
	repe cmpsb
	je .LoadStage2BL
	pop di
	add di,0x40			; Each directory Entry is 64 bytes long
	pop ax
	inc ax
	push ax
	push di
	cmp ax,112			; [RootDirEntries]/2 since each directory entry is taking 64 bytes instead of 32
	jle .NextDirEntry
;	mov si,Error
;	call print_string
	jmp $
.LoadStage2BL:
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
	cmp ax,40
	jle .proceedtoload
;	mov si,Error
;	call print_string
	jmp $
.proceedtoload:
	mov [LoadBSize],ax
	push ax
	mov bx,0
	sub di,4
	mov cx,[es:di]
	push cx
.nextSect:
	mov ax,1
	add cx,32			; 33 sectores are used for reserved, FAT and root directory entries
	mov dx,0x1000
	call read_from_floppy
	pop di
	pop ax
	dec ax
	cmp ax,0
	je .done
	push ax
	mov bx,ax
	mov ax,[LoadBSize]
	sub ax,bx
	mov bx,512
	mul bx
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
	jmp 0x1000:0x0			; jump to Stage 2 Bootloader
;	jmp $				; In case something is wrong.

	BLStage1 db 'BL Stage1',13,10,0	
	BLStage2 db 'LOADK   BIN',0
	LoadBSize dw 0
;	Error db 'Error',0

	;FAT12 information
;	BytesPerSector dw 0
;	SectorsPerCluster db 0
	ReservedSectors dw 0
	NumberOfFATs db 0
	RootDirEntries dw 0
;	TotalSectors dw 0
;	MediaDescriptor db 0
	SectorsPerFAT dw 0
	SectorsPerTrack dw 0
;	NumberOfHeads dw 0
;	FileSystemID db 'FAT12   ' 	;This can be used to check if the filesystem is FAT12
	RootDirStartSector dw 0
	TotalSectInRootDir dw 0


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

; Following debug code is commented to make the code fit into 450 bytes
;print_word:
;	push ax
;	mov al,ah
;	call print_byte
;	pop ax
;	call print_byte
;	ret
;
;print_byte:
;	mov bl,al
;	shr al,4
;	cmp al,9
;	jg .charval
;	add al,30h
;	jmp .printval
;.charval:
;	add al,55
;.printval:
;	mov ah,0Eh
;	int 10h

;	mov al,bl
;	and al,0Fh
;	cmp al,9
;	jg .charval2
;	add al,30h
;	jmp .printval2
;.charval2:
;	add al,55
;.printval2:
;	mov ah,0Eh
;	int 10h
;	ret
;	
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

	times 510-($-$$)-3Eh db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55			; The standard PC boot signature
