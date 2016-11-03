#ifndef SPL6_NFILERW_H
#define SPL6_NFILERW_H

#include <stdio.h>
#include <stdlib.h>
#include "imagestorage.h"
#include "imagelib.h"

extern char *filepath , *filename;

read_error_code_t read_header(FILE* fin, bmp_header_t *header_info);

read_error_code_t read_body(image_t *image_short_info, FILE* opened_file);

FILE* fileopen(char* str_message, char* mode);

void write_header(FILE* fout, bmp_header_t);

void write_body(FILE* fout, image_t image_short_info);


#endif
