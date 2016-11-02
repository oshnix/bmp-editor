#include <stdio.h>

char* strCopyMove(char* src, char* target){
    while(*target++ = *src++);
    return --target;
}
