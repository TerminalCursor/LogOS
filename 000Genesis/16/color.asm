clear_screen:
	push bp
	mov bp, sp
	pusha

	mov ah, 0x07
	mov al, 0x00
	mov bh, 0x17
	mov cx, 0x00
	mov dh, 0x18
	mov dl, 0x4f
	int 0x10

	popa
	mov sp, bp
	pop bp
	ret

move_cursor:
	push bp
	mov bp, sp
	pusha

	mov dx, [bp+4]
	mov ah, 0x02
	mov bh, 0x00
	int 0x10

	popa
	mov sp, bp
	pop bp
	ret
