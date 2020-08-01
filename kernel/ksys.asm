; Shutdown definition
shutdown:
	mov dx, 0x604
	mov ax, 0x2000
	out dx, ax
	ret

; Clear screen definition
clear_screen:
    pusha

    mov edx, VIDEO_MEMORY
    mov al, 0x20
    mov ah, WHITE_ON_BLACK
    mov bx, 0

_screen_clear_loop:
    mov [edx], ax
    add edx, 2
    inc bx
    cmp bx, VIDEO_MEMORY_MAX
    jl _screen_clear_loop

    popa
    ret
