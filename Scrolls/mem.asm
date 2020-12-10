; Copy eax length of memory at addess edx to address ecx
mem_cpy:
_mem_cpy_loop:
	push eax		; Save eax - length of remaining memory to copy
	mov al, BYTE [edx]	; Get the source byte
	mov BYTE [ecx], al	; Copy to destination
	pop eax			; Restore length of remaining memory to copy
	inc edx			; Get next address
	inc ecx			; Get next address
	dec eax			; One less byte to copy
	jnz _mem_cpy_loop	; Loop until no more bytes to copy

	ret
