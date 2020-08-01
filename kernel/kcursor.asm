; Sets cursor offset from the cursor offset in cx
set_cursor_offset:
	xor ax, ax	; Clear out register

	shr cx, 1

	mov eax, 14
	mov dx, 0x3d4
	out dx, al

	mov al, ch
	mov dx, 0x3d5
	out dx, al

	mov eax, 15
	mov dx, 0x3d4
	out dx, al

	mov al, cl
	mov dx, 0x3d5
	out dx, al

	ret

; Stores cursor offset in cx
get_cursor_offset:
	xor ecx, ecx	; Place to store cursor offset
	xor ax, ax	; Clear out register

	; Request high byte of cursor offset - stored in 0x3d5
	mov eax, 14
	mov dx, 0x3d4
	out dx, al

	; Store high byte of cursor offset into ch
	mov dx, 0x3d5
	in al, dx

	mov ch, al

	; Request low byte of cursor offset
	mov eax, 15
	mov dx, 0x3d4
	out dx, al

	; Add high byte of cursor offset
	mov dx, 0x3d5
	in al, dx

	add cl, al
	shl cx, 1

	ret

; Returns with row[eax] and col[edx]
get_cursor_position:
	; Get cursor position
	call get_cursor_offset
	shr ecx, 1
	mov eax, ecx

	; MAX_COLS = 0x50
	mov edx, 0
	mov ecx, 0x50
	div ecx
	; EAX contains quotient (row)
	; EDX contains remainder (column)

	ret

; With row[eax] and col[edx] returns computed offset in[ecx]
get_offset:
	mov ecx, edx
	xor edx, edx
	mov edx, 0x50
	mul edx	; Multiply eax(row) by 0x50(MAX_COL)
	add ecx, eax
	shl ecx, 1
	ret

advance_cursor_offset:
	push eax
	push ecx
	push edx

	call get_cursor_offset
	add ecx, 2
	call set_cursor_offset

	pop edx
	pop ecx
	pop eax
	ret
