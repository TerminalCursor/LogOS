refresh_kbd_status:
	.loop:
	mov dx, 0x0064
	in eax, dx
	test ax, 1
	jz .loop
	ret

get_kbd_keyup:
	mov dx, 0x0060
	in eax, dx
	cmp al, [LAST_KEY]
	je get_kbd_keyup
	mov [LAST_KEY], al
	test al, 0x80
	jz get_kbd_keyup
	ret

key_to_ascii:
	mov cl, 0
	cmp al, 0x8B
	je _zero_key

	cmp al, 0xB9
	je _space_key

	cmp al, 0x9C
	je _enter_key

	cmp al, 0x8E
	je _back_key

	cmp al, 0x81
	jle _key_exit
	cmp al, 0x8A
	jle _zero_row

	cmp al, 0x90
	jl _key_exit
	cmp al, 0x99
	jle _first_row

	cmp al, 0x9E
	jl _key_exit
	cmp al, 0xA6
	jle _second_row

	cmp al, 0xAC
	jl _key_exit
	cmp al, 0xB2
	jle _third_row

	jmp _key_exit
_zero_row:
	sub al, 0x81
	add al, 0x30
	jmp _key_exit
_first_row:
	sub al, 0x90
	and eax, 0xFF
	mov ebx, FIRST_ROW
	add ebx, eax
	mov al, [ebx]
	jmp _key_exit
_second_row:
	sub al, 0x9E
	and eax, 0xFF
	mov ebx, SECOND_ROW
	add ebx, eax
	mov al, [ebx]
	jmp _key_exit
_third_row:
	sub al, 0xAC
	and eax, 0xFF
	mov ebx, THIRD_ROW
	add ebx, eax
	mov al, [ebx]
	jmp _key_exit
_zero_key:
	mov al, 0x30
	jmp _key_exit
_space_key:
	mov al, 0x20
	jmp _key_exit
_back_key:
	push eax
	push edx
	call get_cursor_position
	dec edx
	call get_offset
	call set_cursor_offset
	mov al, 0x20
	call kprint_ch
	call get_cursor_position
	dec edx
	call get_offset
	call set_cursor_offset
	pop eax
	pop edx
	mov cl, 1
	jmp _key_exit
_enter_key:
	push eax
	push edx
	call get_cursor_position
	mov edx, 0
	add eax, 1
	call get_offset
	call set_cursor_offset
	pop eax
	pop edx
	mov cl, 1
	jmp _key_exit
_key_exit:
	ret

FIRST_ROW db "QWERTYUIOP"
SECOND_ROW db "ASDFGHJKL"
THIRD_ROW db "ZXCVBNM", 0
