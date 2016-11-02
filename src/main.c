#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "imagestorage.h"
#include "imagelib.h"
#include "strings.h"

static char respath[]="../res/";
static char *open_modes[] = {"r+b", "w+b"};
static char *filepath , *filename;


void options_list(){
    /*
     * Каждая функция из списка берёт структуру image_t - описание картинки
     * выполняет над ней какие-то действия и возвращает структуру
     *  того же типа - полученную в результате применения функции к исходной.
     */
}

void new_file_path(char* resource_string){
    filepath = malloc(256);
    filename = strCopyMove(resource_string,filepath);
}

FILE* fileopen(char* str_message, char* mode){
    FILE* bmpimage = NULL;
    while(!bmpimage){
        printf("input name of the file %s: ", str_message);
        scanf("%s",filename);
        bmpimage = fopen(filepath,mode);
    }
    return bmpimage;
}


int main(){
    int i, a;
    long array_length;
    bmp_header_t current_header, new_header;
    FILE* current_bmp_image = fileopen("to open", open_modes[0]);
    FILE* new_bmp_image = fileopen("to save", open_modes[1]);
    image_t current_image, new_image;
    new_file_path(respath);
    fread(&current_header, sizeof(bmp_header_t), 1, current_bmp_image);
    current_image.colorArray = malloc(sizeof(void*)*current_header.biHeight);
    current_image.biHeight = current_header.biHeight;
    current_image.biWidth = current_header.biWidth;
    array_length = sizeof(pixel_t)*current_image.biWidth;
    current_image.stringTrash = (4-(array_length % 4))%4;
    for(i = 0; i < current_header.biHeight; i++){
        current_image.colorArray[i] = malloc(array_length);
        fread(current_image.colorArray[i], array_length, 1, current_bmp_image);
        fseek(current_bmp_image,current_image.stringTrash, SEEK_CUR);
    }
    new_image = rotate(current_image);
    new_header = current_header;
    new_header.biHeight = new_image.biHeight;
    new_header.biWidth = new_image.biWidth;
    array_length = sizeof(pixel_t)*new_image.biWidth;
    fwrite(&new_header, sizeof(bmp_header_t),1,new_bmp_image);
    for(i=new_header.biHeight - 1; i > 0; i--){
        fwrite(new_image.colorArray[i], array_length, 1, new_bmp_image);
        fwrite(&a, new_image.stringTrash, 1, new_bmp_image);
    }
    fclose(new_bmp_image);
    return 0;
}