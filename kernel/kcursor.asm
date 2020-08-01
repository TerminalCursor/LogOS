; Sets cursor offset from the cursor offset in cx
set_cursor_offset:
	xor ax, ax	; Clear out a register to get/set I/O bus data

	shr cx, 1	; Video buffer has text and attribute data, so multiply offset by 2

	mov eax, 14	; 14 - High byte of cursor offset
	mov dx, 0x3d4	; Register Screen Control Address
	out dx, al	; Query high byte of cursor offset

	mov al, ch	; High byte of new cursor offset
	mov dx, 0x3d5	; Register Screen Data Address
	out dx, al	; Write high byte of new cursor offset

	mov eax, 15	; 15 - Low byte of cursor offset
	mov dx, 0x3d4	; Register Screen Control Address
	out dx, al	; Query low byte of cursor offset

	mov al, cl	; Low byte of new cursor offset
	mov dx, 0x3d5	; Register Screen Data Address
	out dx, al	; Write low byte of new cursor offset

	ret

; Stores cursor offset in cx
get_cursor_offset:
	xor ecx, ecx	; Place to store cursor offset
	xor ax, ax	; Clear out a register to get/set I/O bus data

	mov eax, 14	; 14 - High byte of cursor position
	mov dx, 0x3d4	; Register Screen Control Address
	out dx, al	; Query high byte of cursor offset

	mov dx, 0x3d5	; Register Screen Data Address
	in al, dx	; Get high byte of cursor offset

	mov ch, al	; Store high byte

	mov eax, 15	; 15 - Low byte of cursor position
	mov dx, 0x3d4	; Register Screen Control Address
	out dx, al	; Query low byte of cursor offset

	mov dx, 0x3d5	; Register Screen Data Address
	in al, dx	; Get low byte of cursor offset

	add cl, al	; Add low byte to c register
	shl cx, 1	; Double the offset to get the VIDEO_BUFFER offset

	ret

; Returns with row[eax] and col[edx]
get_cursor_position:
	call get_cursor_offset	; Get cursor offset
	shr ecx, 1		; Divide by 2 to get text offset
	mov eax, ecx		; Move the text offset to eax - to be multiplied

	mov edx, 0		; Clear d register to hold remainder
	mov ecx, 0x50		; Divide eax by MAX_COLS(0x50)
	div ecx			; eax/ecx => eax:edx (eax=quotient, edx=remainder)

	ret

; With row[eax] and col[edx] returns computed offset in[ecx]
get_offset:
	mov ecx, edx	; Store column
	xor edx, edx	; Clear edx for multiplication
	mov edx, 0x50	; Multiply by MAX_COL
	mul edx		; eax*edx => edx:eax - converts row to offset
	add ecx, eax	; Add row offset
	shl ecx, 1	; Double result since VIDEO_BUFFEER includes attributes

	ret

advance_cursor_offset:
	push eax
	push ecx
	push edx

	call get_cursor_offset	; Get the offset
	add ecx, 2		; Move to the next character
	call set_cursor_offset	; Move to the next character
	call _check_bounds	; Ensure we haven't gone past the VIDEO_BUFFER

	pop edx
	pop ecx
	pop eax
	ret
