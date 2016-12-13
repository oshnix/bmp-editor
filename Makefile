CC=gcc
NASMC=nasm
NASMFLAGS = -g -f elf64
IDIR=./include
CFLAGS= -std=c89 -pedantic -Wall -I$(IDIR)
BDIR=./build
LIBS= -lm
LDK = -o
CDK= -c -g
TARGET=main
CSRC=$(wildcard src/*.c)
ASMSRC=$(wildcard src/*.asm)
CFILES=$(patsubst src/%.c, build/%.o , $(CSRC))
ASMFILES=$(patsubst src/%.asm, build/%.o, $(ASMSRC))
FILES = main.c

mainmake: makedir $(CFILES) $(ASMFILES)
	$(CC) $(LDK) $(TARGET) $(CFILES) $(ASMFILES) $(CFLAGS)

build/%.o: src/%.c 
	$(CC) $(CDK) $(LDK) $@ $< $(CFLAGS)

build/%.o: src/%.asm
	$(NASMC) $(NASMFLAGS) $(LDK) $@ $<
makedir:
	mkdir -p build

clean:
	rm $(BDIR)/* $(TARGET)

