; Tell NASM where the kernel expects to be loaded into
[org 0x1000]
; using 32-bit protected mode
[bits 32]
	jmp _main
_main:

	; Clear the screen
	call clear_screen

	; Write loaded message at (0x0, 0x0)
	mov eax, 0x0
	mov edx, 0x0
	call get_offset
	mov ebx, MSG_KERNEL_LOADED
	call kprint_at

	; Write inital message at (0x0, 0x1)
	mov eax, 0x1
	mov edx, 0x0
	call get_offset
	mov ebx, MSG_HELLO
	call kprint_at

	; Write OS Name at (0x0, 0x2)
	mov eax, 0x2
	mov edx, 0x0
	call get_offset
	mov ebx, OS_NAME
	call kprint_at

	;; Check keyboard register polling status
	call refresh_kbd_status
	call _disks
	jmp _output

_user_input_loop:
	;; Get the last key up
	call get_kbd_keyup
	cmp al, 0x90
	je _exit
	cmp al, 0xAE
	je _user_input_clear
	cmp al, 0x94
	je _user_input_text
	cmp al, 0x97
	jne _output
	mov eax, [PORT]
	add eax, 4
	test eax, 4
	jnz _user_input_exit_f
	add eax, 8
_user_input_exit_f:
	mov [PORT], eax
	jmp _output

_user_input_clear:
	call clear_screen
	jmp _output

_user_input_text:
_user_input_text_loop:
	call get_kbd_keyup
	cmp al, 0x81
	je _output
	call key_to_ascii
	test cl, 1
	jnz _user_input_text_loop
	call kprint_ch
	jmp _user_input_text_loop

_output:
	;; output last keyup at (0x46, 0x9)
	mov ecx, eax
	mov eax, 0x9
	mov edx, 0x46
	call output_stack_32
	;; output port to (0x46, 0x9)
	mov dx, [PORT]
	in eax, dx
	mov ecx, eax
	mov eax, 0xA
	mov edx, 0x46
	call output_stack_32
	;; Output register contents (a,b,c,d,si,di,bp,sp)
	;;  at right edge at top of screen
	mov ecx, ecx
	mov eax, 0x2
	mov edx, 0x46
	call output_stack_32
	mov ecx, ebx
	mov eax, 0x1
	mov edx, 0x46
	call output_stack_32
	mov ecx, eax
	mov eax, 0x0
	mov edx, 0x46
	call output_stack_32
	mov ecx, edx
	mov eax, 0x3
	mov edx, 0x46
	call output_stack_32
	mov ecx, esi
	mov eax, 0x4
	mov edx, 0x46
	call output_stack_32
	mov ecx, edi
	mov eax, 0x5
	mov edx, 0x46
	call output_stack_32
	mov ecx, esp
	mov eax, 0x6
	mov edx, 0x46
	call output_stack_32
	mov ecx, ebp
	mov eax, 0x7
	mov edx, 0x46
	call output_stack_32

	;; Wait
	mov ebx, 0x03FFFFFF
	call wait_b
	jmp _user_input_loop

_exit:
	;; Shutdown the machine
	call shutdown

	;; If the shutdown failed, return to bootloader (which goes to inf loop)
	ret

; Messages
MSG_KERNEL_LOADED db "Eden Loaded!", 0 ; Zero Terminated String
MSG_HELLO db "In the beginning, God created the heavens and the earth", 0
BASE_HEX db "0x00000000", 0 ; Zero Terminated
OS_NAME db "LogOS", 0		; Zero Terminated
LAST_KEY db 0
PORT dw 0x0000
; this is how constants are defined
VIDEO_MEMORY equ 0xb8000
VIDEO_MEMORY_MAX equ 0x7D0
WHITE_ON_BLACK equ 0x17 ; the color byte for each character

; Kernel modules
%include "Scrolls/print.asm"
%include "Scrolls/cursor.asm"
%include "Scrolls/keyboard.asm"
%include "Scrolls/sys.asm"
%include "Scrolls/mem.asm"
%include "Scrolls/screen.asm"
%include "Spirit/idt.asm"

_disks:
	xor ax,ax
	mov es,ax
WriteToMbr:
	mov     dx,1f6h         ;Drive and head port
	mov     al,0a0h         ;Drive 0, head 0
	out     dx,al

	mov     dx,1f2h         ;Sector count port
	mov     al,1            ;Write one sector
	out     dx,al

	mov     dx,1f3h         ;Sector number port
	mov     al,1           ;Wrote to sector one
	out     dx,al

	mov     dx,1f4h         ;Cylinder low port
	mov     al,0            ;Cylinder 0
	out     dx,al

	mov     dx,1f5h         ;Cylinder high port
	mov     al,0            ;The rest of the cylinder 0
	out     dx,al

	mov     dx,1f7h         ;Command port
	mov     al,30h          ;Write with retry.
	out     dx,al
_disk_waiting:
	in      al,dx
	test    al,8            ;Wait for sector buffer ready.
	jz      _disk_waiting

	mov     cx,512/2        ;One sector /2
	mov     si, 0x1000
	mov     dx,1f0h         ;Data port - data comes in and out of here.
	rep     outsw
	ret
