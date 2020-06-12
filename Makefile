# $@ = target file
# $< = first dependency
# $^ = all dependencies
#

# First rule is run by default
os-image-raw.bin: 000boot/boot.bin kernel/kernel.bin
	cat $^ > $@

os-image.bin: os-image-raw.bin
	dd if=$< of=$@ bs=100M conv=sync

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

clean:
	rm -rf *.bin *.o
	rm -rf 000boot/*.bin 000boot/*.o
	rm -rf 000boot/16/*.bin 000boot/16/*.o
	rm -rf 000boot/32/*.bin 000boot/32/*.o
	rm -rf kernel/*.bin kernel/*.o

backup:
	cp -r ./ ../backups.d/LogOS

.PHONY: backup clean
