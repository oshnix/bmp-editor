#include <stdint.h>

#ifndef SPL6_IMAGESTORAGE_H
#define SPL6_IMAGESTORAGE_H


#pragma pack(push, 2)
typedef struct{
    uint16_t bftype;
    uint32_t bfilesize;
    uint32_t bfReserved;
    uint32_t bOffBits;
    uint32_t biSize;
    uint32_t biWidth;
    uint32_t biHeight;
    uint16_t biPlanes;
    uint16_t biBitCount;
    uint32_t biCompresion;
    uint32_t biSizeImage;
    uint32_t biXPelsPerMeter;
    uint32_t biYPelsPerMeter;
    uint32_t biClrUsed;
    uint32_t biClrImportant;
} bmp_header_t;
#pragma pack(pop)

typedef struct {
    char read, green, blue;
} pixel_t;

typedef struct{
    uint32_t biHeight;
    uint32_t biWidth;
    pixel_t *colorArray;
}image_t;


#endif
