; Prints message[ebx] at [ecx]
kprint_at:
	call set_cursor_offset	; Set the cursor to the offset in ecx
; Prints message (zero terminated) at cursor offset
kprint:
	push ebx		; Save the memory address
_kprint_loop:
	mov al, BYTE [ebx]	; Get the character to print
	cmp al, 0		; Ensure it is not zero
	je _kprint_done		; If it is, finish printing
	call kprint_ch		; Otherwise, print the character
	inc ebx			; Get the next character
	jmp _kprint_loop	; Start over
_kprint_done:
	pop ebx			; Restore the message memory address

	ret

; Print char al at [ecx]
kprint_ch:
	call _check_bounds	; Make sure that we are in the video memory
	cmp al, 0x0A		; Check to see if we need to make a new line
	jne _kprint_ch_norm
_kprint_ch_nl:
	call get_cursor_position; Get the cursor position
	mov edx, 0		; Start at the first character
	inc eax			; Of the next line
	call get_offset		; Get the offset from those coordinates
	call set_cursor_offset	; Move to that offset
	jmp _kprint_ch_done
_kprint_ch_norm:
	xor ecx, ecx		; Clear ecx - just in case higher 16 has data
	push ax			; preserve character
	call get_cursor_offset	; Get the cursor location
	pop ax			; preserve character
	add ecx, VIDEO_MEMORY	; Align to video memory
	mov BYTE [ecx], al	; Write the character
	inc ecx			; Move forward to set attribute
	mov BYTE [ecx], WHITE_ON_BLACK	; Set color attribute
	call advance_cursor_offset	; Advance the cursor
_kprint_ch_done:
	ret

_check_bounds:
	push eax
	push ebx
	push ecx
	push edx

_check_loop:
	call get_cursor_position; Get the cursor location
	cmp eax, 25		; Check to see if it is out of the video memory
	jl _check_done		; If it isn't - finish without doing anything
	
	dec eax			; Otherwise, go back a row
	call get_offset		; Get the new offset
	call set_cursor_offset	; Set the new cursor position
	call scroll_up		; Scroll up one line
	jmp _check_loop		; Check to see if we are back in video memory

_check_done:
	pop edx
	pop ecx
	pop ebx
	pop eax

	ret

	;;  Data is in ax
dump_stack_16:
	push ax

	pop ax
	sub esp, 2
	and ax, 0xF000
	shr ax, 0xC
	call c_to_i
	call kprint_ch
	pop ax
	sub esp, 2
	and ax, 0xF00
	shr ax, 0x8
	call c_to_i
	call kprint_ch
	pop ax
	sub esp, 2
	and al, 0xF0
	shr al, 0x4
	call c_to_i
	call kprint_ch
	pop ax
	sub esp, 2
	and al, 0xF
	call c_to_i
	call kprint_ch

	pop ax
	ret

	;;  Data is in eax
dump_stack_32:
	push eax
	shr eax, 0x10
	call dump_stack_16
	pop eax
	call dump_stack_16
	ret

c_to_i:
	cmp al, 0x0A
	jl _chr
	add al, 0x07
_chr:	add al, 0x30
	ret

	;; Cursor position in (eax, edx)
	;; Data in cx
output_stack_16:
	push cx
	push eax
	push edx
	call get_offset
	push ebx
	mov ebx, BASE_HEX
	call kprint_at
	pop ebx
	; Move to (0x2, 0x7)
	mov eax, 0xA
	mov edx, 0x2
	pop edx
	add edx, 6
	pop eax
	call get_offset
	call set_cursor_offset
	;; Print top of stack
	;; mov eax, [esp]
	pop ax
	call dump_stack_16
	ret

	;; Cursor position in (eax, edx)
	;; Data in ecx
output_stack_32:
	push ecx
	push eax
	push edx
	call get_offset
	push ebx
	mov ebx, BASE_HEX
	call kprint_at
	pop ebx
	; Move to (0x2, 0x7)
	mov eax, 0xA
	mov edx, 0x2
	pop edx
	add edx, 2
	pop eax
	call get_offset
	call set_cursor_offset
	;; Print top of stack
	;; mov eax, [esp]
	pop eax
	call dump_stack_32
	ret
