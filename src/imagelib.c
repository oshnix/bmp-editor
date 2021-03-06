#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "math.h"
#include "sepia_asm.h"
#include "sepia_c.h"
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

image_t sepia(image_t input_image){
    double begin, end, time_spent;
    image_t result_image;
    result_image.biHeight = input_image.biHeight;
    result_image.biWidth = input_image.biWidth;
    int size = result_image.biWidth*result_image.biHeight;
    result_image.colorArray = malloc(size * sizeof(pixel_t));
    begin = clock();
    sepia_asm(input_image.colorArray, size, result_image.colorArray);
    end = clock();
    time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
    printf("SSE sepia time: %f\n", time_spent);
    begin = clock();
    sepia_c_inplace(&input_image);
    end = clock();
    time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
    printf("Pure C time: %f\n", time_spent);
    return result_image;
}

image_t (*functions_list[])(image_t) = {rotate_right, rotate_left, sepia};
int options_count = sizeof(functions_list)/8;

char *options[] = {"rotate 90 degrees right", "rotate 90 degrees left", "Sepia"};

