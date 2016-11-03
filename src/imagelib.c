#include <stdio.h>
#include <stdlib.h>
#include "math.h"
#include "imagestorage.h"
#include "imagelib.h"

#define PI 3.14159265



static long new_image_initialize(image_t* result_img, image_t source_img){
    result_img->biHeight = source_img.biWidth;
    result_img->biWidth = source_img.biHeight;
    return sizeof(pixel_t)*result_img->biWidth;
}

image_t rotate_right(image_t input_image){
    int i, j;
    pixel_t *save_position;
    image_t result_image;
    long array_length = new_image_initialize(&result_image, input_image);
    save_position = result_image.colorArray = malloc(array_length*result_image.biHeight);
    for(i = 0; i < result_image.biHeight; i++){
        for(j = 0; j < result_image.biWidth; j++){
            *(result_image.colorArray++) = *(input_image.colorArray+(j*input_image.biWidth + i));
        }
    }
    result_image.colorArray = save_position;
    return result_image;
}



image_t rotate_left(image_t input_image){
    int i, j;
    pixel_t *save_position;
    image_t result_image;
    long array_length = new_image_initialize(&result_image, input_image);
    save_position = result_image.colorArray = malloc(array_length*result_image.biHeight);
    for(i = 0; i < result_image.biHeight; i++){
        for(j = 0; j < result_image.biWidth; j++){
            *(result_image.colorArray++) = *(input_image.colorArray+((input_image.biHeight - j)*input_image.biWidth + i));
        }
    }
    result_image.colorArray = save_position;
    return result_image;
}

image_t (*functions_list[])(image_t) = {rotate_right, rotate_left};
int options_count = sizeof(functions_list)/8;

char *options[] = {"rotate 90 degrees right", "rotate 90 degrees left"};

