; Shutdown definition
shutdown:
	mov dx, 0x604	; Write to 0x604
	mov ax, 0x2000	; Write 0x2000
	out dx, ax	; Send shutdown
	ret		; Return if shutdown failed

; Clear screen definition
clear_screen:
	pusha

	mov edx, VIDEO_MEMORY	; Get the start address of the video memory buffer
	mov al, 0x20		; Space character
	mov ah, WHITE_ON_BLACK	; Color attribute
	mov bx, 0		; Counter

_screen_clear_loop:
	mov [edx], ax		; Move the character + attribute to video memory
	add edx, 2		; Go to next character
	inc bx			; Increase counter
	cmp bx, VIDEO_MEMORY_MAX	; Check if we have written to entire buffer
	jl _screen_clear_loop	; If not, loop

	popa
	ret

wait_b:
_wait_loop:
	sub ebx, 1
	jnz _wait_loop

	ret
