FILES = ./build/kernel.asm.o

all: clean ./bin/boot.bin ./bin/kernel.bin
	rm -rf ./bin/pituxa.bin
	dd if=./bin/boot.bin >> ./bin/pituxa.bin
	dd if=./bin/kernel.bin >> ./bin/pituxa.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/pituxa.bin

./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o
	i686-elf-gcc -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o

./bin/boot.bin: ./src/boot/boot.asm
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

./build/kernel.asm.o: ./src/kernel/kernel.asm
	nasm -f elf -g ./src/kernel/kernel.asm -o ./build/kernel.asm.o

clean:
	rm -rf ./bin
	rm -rf ./build
	mkdir ./bin
	mkdir ./build