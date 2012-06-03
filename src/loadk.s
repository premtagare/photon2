BITS 16
;ORG 10000
;ORG 07D0h

first_process:
	mov ax, 1000h		; first process is located at 10000h 
	mov ds, ax
	mov ax, 1500h		 
	mov ss, ax		; setting stack segment
	mov sp, 3000h

	mov ah,0Eh		; print FS
	mov al,70
	int 10h
	mov al,83
	int 10h
	
.fstprmsgprint:	
	
	mov si, fstpr_text_string	; Put string position into SI
	call fstpr_print_string		; Call our string-printing routine
        
	cli

	mov cx,005Eh			; delay for few micro seconds
	mov dx,8480h
	mov ah,86h
	int 15h

	sti

	jmp .fstprmsgprint		; print message infinitely


	fstpr_text_string db 'This is first process ', 0

fstpr_print_string:			; Routine: output string in SI to screen
	mov ah, 0Eh			; int 10h 'print char' function

.fstprrepeat:
	lodsb				; Get character from string
	cmp al, 0
	je .fstprdone			; If char is zero, end of string
	int 10h				; Otherwise, print it
	jmp .fstprrepeat

.fstprdone:
	ret
