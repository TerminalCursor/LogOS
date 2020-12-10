refresh_kbd_status:
	.loop:
	mov dx, 0x0064
	in al, dx
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
