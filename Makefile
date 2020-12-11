# $@ = target file
# $< = first dependency
# $^ = all dependencies

.PHONY: backup clean cleanobj run

# First rule is run by default
#LogOS.aligned.bin: LogOS.bin
#	dd if=$< of=$@ bs=100M conv=sync
#

LogOS.bin: 000Genesis/genesis.bin Eden/eden.bin
	cat $^ > $@

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

run: LogOS.bin
	qemu-img create los.bin 2048
	qemu-system-x86_64 -fda $< -hda los.bin

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
	mkdir -p ../DeadSeaScrolls.d/LogOS/
	cp -r ./ ../DeadSeaScrolls.d/LogOS/
