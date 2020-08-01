scroll_up:
	push eax
	push ebx
	push ecx
	push edx

	mov eax, 0xA0
	mov ecx, VIDEO_MEMORY
	mov edx, VIDEO_MEMORY
	mov ebx, 24

_scroll_loop:
	add edx, 0xA0
	call mem_cpy
	add ecx, 0xA0
	dec ebx
	cmp ebx, 0
	jnz _scroll_loop

	mov ebx, 0xA0
_new_line_loop:
	mov BYTE [edx], 0x20
	inc edx
	mov BYTE [edx], WHITE_ON_BLACK
	inc edx
	dec ebx
	jnz _new_line_loop

	pop edx
	pop ecx
	pop ebx
	pop eax
	ret
