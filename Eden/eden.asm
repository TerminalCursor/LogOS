; Tell NASM where the kernel expects to be loaded into
[org 0x1000]
; using 32-bit protected mode
[bits 32]
jmp _main
_main:

; Wait
push ebx
mov ebx, 0xFFFFFFFF
call wait_b

; Clear the screen
call clear_screen

; Write text at (0x0, 0x1)
mov eax, 0x1
mov edx, 0x0
call get_offset
mov ebx, MSG_KERNEL_LOADED
call kprint_at

; Write text at (0x0, 0x2)
mov eax, 0x2
mov edx, 0x0
call get_offset
mov ebx, MSG_HELLO
call kprint_at

; Set the cursor to (0x0, 0x3)
mov eax, 0x3
mov edx, 0x0
call get_offset
call set_cursor_offset

; Display 'L' at the cursor offset
mov al, 0x4C
call kprint_ch
; Display 'O' at the cursor offset
mov al, 0x4F
call kprint_ch
; Display 'G' at the cursor offset
mov al, 0x47
call kprint_ch
; Display 'O' at the cursor offset
mov al, 0x4F
call kprint_ch
; Display 'S' at the cursor offset
mov al, 0x53
call kprint_ch

; Wait
push ebx
mov ebx, 0xFFFFFFFF
call wait_b

; Shutdown the machine
call shutdown

; If the shutdown failed, return to bootloader (which goes to inf loop)
ret

; Messages
MSG_KERNEL_LOADED db "Eden Loaded!", 0 ; Zero Terminated String
MSG_HELLO db "In the beginning, God created the heavens and the earth", 0
; this is how constants are defined
VIDEO_MEMORY equ 0xb8000
VIDEO_MEMORY_MAX equ 0x7D0
WHITE_ON_BLACK equ 0x17 ; the color byte for each character

; Kernel modules
%include "Scrolls/print.asm"
%include "Scrolls/cursor.asm"
%include "Scrolls/sys.asm"
%include "Scrolls/mem.asm"
%include "Scrolls/screen.asm"
%include "Spirit/idt.asm"

wait_b:
_wait_loop:
	sub ebx, 1
	jnz _wait_loop

	ret
