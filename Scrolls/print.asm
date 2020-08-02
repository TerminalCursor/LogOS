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
