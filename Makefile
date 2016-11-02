CC=gcc
IDIR=./include
CFLAGS= -ansi -pedantic -Wall -Werror -I$(IDIR)
BDIR=./build
LIBS= -lm
LDK = -o
CDK= -c
TARGET=main
SRC=$(wildcard src/*.c)
OBJ=$(patsubst src/%.c, build/%.o , $(SRC))
FILES = main.c

mainmake: $(OBJ)
	@echo $(CC) $(LIBS) $(LDK) $(TARGET) $(OBJ)

$(OBJ) : $(SRC)
	@echo $(CC) $(CDK) $(LDK) $@ $< $(CFLAGS)


#clean:
#	rm -rf $(TARGET)

