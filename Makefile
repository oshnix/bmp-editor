CC=gcc
IDIR=./include
CFLAGS= -ansi -pedantic -Wall -I$(IDIR)
BDIR=./build
LIBS= -lm
LDK = -o
CDK= -c
TARGET=main
SRC=$(wildcard src/*.c)
OBJ=$(patsubst src/%.c, build/%.o , $(SRC))
FILES = main.c

mainmake: $(OBJ)
	$(CC) $(LDK) $(TARGET) $(OBJ)

build/%.o: src/%.c 
	$(CC) $(CDK) $(LDK) $@ $< $(CFLAGS)


#clean:
#	rm -rf $(TARGET)

