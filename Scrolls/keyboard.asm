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
