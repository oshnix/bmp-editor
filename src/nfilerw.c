#include <stdio.h>
#include <stdlib.h>
#include "imagestorage.h"
#include "nfilerw.h"



read_error_code_t read_header(FILE* fin, bmp_header_t *header_info){
    read_error_code_t result;
    result = fread(header_info, sizeof(bmp_header_t), 1, fin) == 1 ? READ_OK : READ_INVALID_HEADER;
    return result;
}

read_error_code_t read_body(image_t *image_short_info, FILE* opened_file){
    int i, string_trash, trash_len;
    long array_length = sizeof(pixel_t)*image_short_info->biWidth;
    trash_len = (4-(array_length % 4))%4;
    image_short_info->colorArray = malloc(array_length*image_short_info->biHeight);
    for(i = 0; i < image_short_info->biHeight; i++){
        if(fread(image_short_info->colorArray+(image_short_info->biWidth * i), array_length, 1, opened_file) != 1) return READ_INVALID_SIGNATURE;
        fread(&string_trash, trash_len, 1, opened_file);
    }
    return READ_OK;
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

void write_header(FILE* fout, bmp_header_t header_info){
    fwrite(&header_info, sizeof(bmp_header_t),1,fout);
}

void write_body(FILE* fout, image_t image_short_info){
    int i, trash_len, string_trash = 0;
    long array_length = sizeof(pixel_t)*image_short_info.biWidth;
    trash_len = (4-(array_length % 4))%4;
    for(i = 0; i < image_short_info.biHeight; i++){
        fwrite(image_short_info.colorArray+(image_short_info.biWidth * i), array_length, 1, fout);
        fwrite(&string_trash, trash_len, 1, fout);
    }
}
