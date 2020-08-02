# $@ = target file
# $< = first dependency
# $^ = all dependencies

.PHONY: backup clean cleanobj run

# First rule is run by default
#os-image.bin: os-image-raw.bin
#	dd if=$< of=$@ bs=100M conv=sync
#

imago-dei.bin: 000Genesis/genesis.bin Eden/eden.bin
	cat $^ > $@

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

run: imago-dei.bin
	qemu-system-x86_64 -fda $<

clean: cleanobj
	rm -rf *.bin
	rm -rf 000Genesis/*.bin
	rm -rf 000Genesis/16/*.bin
	rm -rf 000Genesis/32/*.bin
	rm -rf Eden/*.bin

cleanobj:
	rm -rf *.o
	rm -rf 000Genesis/*.o
	rm -rf 000Genesis/16/*.o
	rm -rf 000Genesis/32/*.o
	rm -rf Eden/*.o

backup:
	cp -r ./ ../backups.d/LogOS
