scroll_up:
	push ebx

	mov eax, 0xA0		; 2 * 0x50 since there is both text and attribute data
	mov ecx, VIDEO_MEMORY	; Start at beginning of video memory
	mov edx, VIDEO_MEMORY	; Start at beginning of video memory
	mov ebx, 24		; Stop one line short from top

_scroll_loop:
	add edx, 0xA0		; Get the next line to copy from
	call mem_cpy		; Copy next line to previous line
	add ecx, 0xA0		; Get the next line to copy to
	dec ebx			; Decrease counter of number of lines remaining to copy
	;cmp ebx, 0		; Check
	jnz _scroll_loop	; If we have more lines, go back to top of loop

	mov ebx, 0x50		; Get size of line
_new_line_loop:
	mov BYTE [edx], 0x20	; Write space
	inc edx			; Next byte is attribute
	mov BYTE [edx], WHITE_ON_BLACK	; Set blue/grey attribute
	inc edx			; Get next text byte
	dec ebx			; Finished one text character
	jnz _new_line_loop	; If we have more text to write, loop it again

	pop ebx

	ret
