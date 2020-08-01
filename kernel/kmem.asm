; Copy eax length of memory at addess edx to address ecx
mem_cpy:
	push eax
	push edx
	push ecx

_mem_cpy_loop:
	push eax
	mov al, BYTE [edx]
	mov BYTE [ecx], al
	pop eax
	inc edx
	inc ecx
	dec eax
	jnz _mem_cpy_loop

	pop ecx
	pop edx
	pop eax
	ret
