# $@ = target file
# $< = first dependency
# $^ = all dependencies

.PHONY: backup clean cleanobj run

# First rule is run by default
#os-image.bin: os-image-raw.bin
#	dd if=$< of=$@ bs=100M conv=sync
#

os-image-raw.bin: 000boot/boot.bin kernel/kernel.bin
	cat $^ > $@

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

run: os-image-raw.bin
	qemu-system-x86_64 -fda $<

clean: cleanobj
	rm -rf *.bin
	rm -rf 000boot/*.bin
	rm -rf 000boot/16/*.bin
	rm -rf 000boot/32/*.bin
	rm -rf kernel/*.bin

cleanobj:
	rm -rf *.o
	rm -rf 000boot/*.o
	rm -rf 000boot/16/*.o
	rm -rf 000boot/32/*.o
	rm -rf kernel/*.o

backup:
	cp -r ./ ../backups.d/LogOS
