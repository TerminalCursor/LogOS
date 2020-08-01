; Tell NASM where the kernel expects to be loaded into
[org 0x1000]
; using 32-bit protected mode
[bits 32]
jmp _main
_main:
; Clear the screen
call clear_screen

; Write text on the third line starting at the second character of the line
mov eax, 0x3
mov edx, 0x2
call get_offset
mov ebx, MSG_KERNEL_LOADED
call kprint_at

; Set the cursor to (0x5, 0x7)
mov eax, 0x7
mov edx, 0x5
call get_offset
call set_cursor_offset

; Display 'C' at the cursor offset
mov al, 0x43
call kprint_ch

; Write text at (0x8, 23)
mov eax, 23
mov edx, 0x8
call get_offset
mov ebx, MSG_HELLO
call kprint_at

; Newline
mov al, 0x0A
call kprint_ch

; Move over by 1
call advance_cursor_offset

; Scroll screen up 1 line
;call scroll_up

; Rudimentary wait to exit ~ 7 seconds
; TODO: Make a better wait function
mov eax, 0xFFFFFFFF
wait_loop:
sub eax, 1
jnz wait_loop

; Shutdown the machine
call shutdown

; If the shutdown failed, return to bootloader (which goes to inf loop)
ret

; Messages
MSG_KERNEL_LOADED db "LogOS Kernel Loaded!", 0 ; Zero Terminated String
MSG_HELLO db "LogOS successfully started!", 0x0A, "Hello!", 0
; this is how constants are defined
VIDEO_MEMORY equ 0xb8000
VIDEO_MEMORY_MAX equ 0x7D0
WHITE_ON_BLACK equ 0x17 ; the color byte for each character

; Kernel modules
%include "kernel/kprint.asm"
%include "kernel/kcursor.asm"
%include "kernel/ksys.asm"
%include "kernel/kmem.asm"
%include "kernel/kscreen.asm"
