; Prints message[ebx] at [ecx]
kprint_at:
	call set_cursor_offset
; Prints message at cursor offset
kprint:
	push ebx
_kprint_loop:
	mov al, BYTE [ebx]
	cmp al, 0
	je _kprint_done
	call kprint_ch
	inc ebx
	jmp _kprint_loop
_kprint_done:
	pop ebx
	ret

; Print char al at [ecx]
kprint_ch:
	cmp al, 0x0A
	jne _kprint_ch_norm
_kprint_ch_nl:
	call get_cursor_position
	mov edx, 0
	inc eax
	call get_offset
	call set_cursor_offset
	jmp _kprint_ch_done
_kprint_ch_norm:
	xor ecx, ecx
	push ax
	call get_cursor_offset
	pop ax
	add ecx, VIDEO_MEMORY
	mov BYTE [ecx], al
	inc ecx
	mov BYTE [ecx], WHITE_ON_BLACK
	call advance_cursor_offset
_kprint_ch_done:
	ret
