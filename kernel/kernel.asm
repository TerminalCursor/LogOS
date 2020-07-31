; Tell NASM where the kernel expects to be loaded into
[org 0x1000]
; using 32-bit protected mode
[bits 32]
_main:
call clear_screen
mov ecx, 0x50
lea ecx, [2 + 2 * ecx]
mov ebx, MSG_KERNEL_LOADED
call print_string_pm
mov ecx, 0x50
lea ecx, [5 + 5 * ecx]
mov ebx, MSG_HELLO
call print_string_pm
call shutdown
ret

MSG_KERNEL_LOADED db "LogOS Kernel Loaded!", 0 ; Zero Terminated String
MSG_HELLO db "Hello, this is Christian Cunningham's LogOS", 0
; this is how constants are defined
VIDEO_MEMORY equ 0xb8000
VIDEO_MEMORY_MAX equ 0x7D0
WHITE_ON_BLACK equ 0x17 ; the color byte for each character

%include "kernel/print.asm"

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

shutdown:
	mov dx, 0x604
	mov ax, 0x2000
	out dx, ax
	ret
