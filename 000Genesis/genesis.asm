[org 0x7c00] ; bootloader offset
KERNEL_OFFSET equ 0x1000	;; The same we use when linking the kernel

	mov [BOOT_DRIVE], dl
	mov bp, 0x9000 ; set the stack
	mov sp, bp

	call clear_screen	;; Clear the screen

	push 0x0000
	call move_cursor	;; Move the cursor to the top left

	mov bx, MSG_REAL_MODE
	call print ; This will be written after the BIOS messages

	push 0x0100
	call move_cursor	;; Move the cursor to the top left

	call load_kernel

	mov ah, 0x00	;; Get character input
	int 0x16

	call switch_to_pm
	jmp $ ; this will actually never be executed

%include "000Genesis/16/color.asm"
%include "000Genesis/16/print.asm"
%include "000Genesis/16/print_hex.asm"
%include "000Genesis/16/disk.asm"
%include "000Genesis/32/gdt.asm"
%include "000Genesis/32/print.asm"
%include "000Genesis/32/third_day.asm"

[bits 16]
load_kernel:
	mov bx, MSG_LOAD_KERNEL
	call print
	call print_nl

	mov bx, KERNEL_OFFSET
	mov dh, 16		;; Number of sectors to read
	mov dl, [BOOT_DRIVE]
	call disk_load
	ret

[bits 32]
BEGIN_PM: ; after the switch we will get here
	mov ebx, MSG_PROT_MODE
	call print_string_pm ; Note that this will be written at the top left corner
	call KERNEL_OFFSET	;; Switch control to kernel
	jmp $	;; Halt if kernel switches execution back to bootloader

BOOT_DRIVE db 0
MSG_REAL_MODE db "LogOS: Firmament loaded", 0
MSG_LOAD_KERNEL db "LogOS: Separating seas...", 0
MSG_PROT_MODE db "LogOS: Seas successfully separated by land!", 0

; bootsector marker
times 510-($-$$) db 0
dw 0xaa55
