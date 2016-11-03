#include "imagestorage.h"



#ifndef SPL6_IMAGELIB_H
#define SPL6_IMAGELIB_H

extern int options_count;

image_t rotate_right(image_t);

extern image_t (*functions_list[])(image_t);

extern char *options[];

typedef enum {
    READ_OK = 0,
    READ_INVALID_SIGNATURE,
    READ_INVALID_BITS,
    READ_INVALID_HEADER
} read_error_code_t;

#endif
