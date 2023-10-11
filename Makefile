all: clean build

build:
	mkdir ./bin
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

clean:
	rm -rf ./bin

boot:
	qemu-system-x86_64 -hda bin/boot.bin	