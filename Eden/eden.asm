; Tell NASM where the kernel expects to be loaded into
[org 0x1000]
; using 32-bit protected mode
[bits 32]
jmp _main
_main:

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
mov al, 0x6F
call kprint_ch
; Display 'G' at the cursor offset
mov al, 0x67
call kprint_ch
; Display 'O' at the cursor offset
mov al, 0x4F
call kprint_ch
; Display 'S' at the cursor offset
mov al, 0x53
call kprint_ch

	mov eax, 0x6
	mov edx, 0x0
	mov ecx, [esp]
	call output_stack_32

	mov eax, 0x7
	mov edx, 0x0
	mov ecx, esp
	call output_stack_32

	mov eax, 0x8
	mov edx, 0x0
	mov cx, 0xB3EF
	call output_stack_16

	mov eax, 0x9
	mov edx, 0x0
	mov ecx, 0xD3ADB3EF
	call output_stack_32

	call refresh_kbd_status

	mov ecx, eax
	mov eax, 0xA
	mov edx, 0x0
	call output_stack_32

_lp1:
	call get_kbd_keyup

	cmp al, 0x90
	je _exit

_output:
	mov ecx, eax
	mov eax, 0xA
	mov edx, 0x0
	call output_stack_32

	mov ecx, [esp]
	mov eax, 0xB
	mov edx, 0x0
	call output_stack_32

	mov ecx, esp
	mov eax, 0xC
	mov edx, 0x0
	call output_stack_32

	mov ecx, ebx
	mov eax, 0x0
	mov edx, 0x10
	call output_stack_32
	mov ecx, esi
	mov eax, 0x1
	mov edx, 0x10
	call output_stack_32
	mov ecx, edi
	mov eax, 0x2
	mov edx, 0x10
	call output_stack_32
	mov edx, esp
	mov eax, 0x3
	mov edx, 0x10
	call output_stack_32
	mov edx, ebp
	mov eax, 0x4
	mov edx, 0x10
	call output_stack_32

; Wait
push ebx
mov ebx, 0x03FFFFFF
call wait_b
pop ebx
jmp _lp1

_exit:
; Shutdown the machine
call shutdown

; If the shutdown failed, return to bootloader (which goes to inf loop)
ret

; Messages
MSG_KERNEL_LOADED db "Eden Loaded!", 0 ; Zero Terminated String
MSG_HELLO db "In the beginning, God created the heavens and the earth", 0
BASE_HEX db "0x00000000", 0 ; Zero Terminated
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
	mov ebx, BASE_HEX
	call kprint_at
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
	mov ebx, BASE_HEX
	call kprint_at
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

refresh_kbd_status:
	;; mov cx, 0
	.loop:
	;; inc cx
	mov dx, 0x0064
	in al, dx
	;; cmp cx, 5
	test ax, 1
	jz .loop
	ret

get_kbd_keyup:
	.loop:
	mov dx, 0x0060
	in al, dx
	test eax, 0x80
	jz .loop
	ret
