; Tell NASM where the kernel expects to be loaded into
[org 0x1000]
; using 32-bit protected mode
[bits 32]
_main:
; Clear the screen
call clear_screen

; Write text on the third line starting at the second character of the line
mov ecx, 0x50
lea ecx, [1 + 2 * ecx]
mov ebx, MSG_KERNEL_LOADED
call print_string_pm

; Write text on the sixth line starting at the sixth character of the line
mov ecx, 0x50
lea ecx, [5 + 5 * ecx]
mov ebx, MSG_HELLO
call print_string_pm

; Shutdown the machine
call shutdown

; If the shutdown failed, return to bootloader (which goes to inf loop)
ret

; Messages
MSG_KERNEL_LOADED db "LogOS Kernel Loaded!", 0 ; Zero Terminated String
MSG_HELLO db "Hello, this is LogOS", 0
; this is how constants are defined
VIDEO_MEMORY equ 0xb8000
VIDEO_MEMORY_MAX equ 0x7D0
WHITE_ON_BLACK equ 0x17 ; the color byte for each character

; Kernel print location
%include "kernel/print.asm"

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

; Shutdown definition
shutdown:
	mov dx, 0x604
	mov ax, 0x2000
	out dx, ax
	ret
