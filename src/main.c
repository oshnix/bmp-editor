#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "imagestorage.h"
#include "sepia_asm.h"
#include "nfilerw.h"
#include "imagelib.h"
#include "strings.h"

static char respath[]="./res/";
static char *open_modes[] = {"r+b", "w+b"};
char *filepath , *filename;

void error_check(read_error_code_t work_result){
    if(work_result != READ_OK) exit(1);
}

int options_list(){
    int i;
    unsigned int inp;
    printf("exit: 0\n");
    for(i = 1; i <= options_count; i++){
        printf("%s : %d\n",options[i - 1], i);
    }
    printf("Input option number: ");
    while(!scanf("%ud",&inp) && (!(inp <= options_count) || inp)){
        printf("Wrong input\nTry again: ");
    }
    return inp;
    /*
     * Каждая функция из списка берёт структуру image_t - описание картинки
     * выполняет над ней какие-то действия и возвращает структуру
     *  того же типа - полученную в результате применения функции к исходной.
     */
}


void update_header(bmp_header_t *header_info, image_t image_short_info){
    header_info->biHeight = image_short_info.biHeight;
    header_info->biWidth = image_short_info.biWidth;
}

image_t get_header_info(bmp_header_t file_info){
    image_t short_file_info;
    short_file_info.colorArray = malloc(sizeof(void*)*file_info.biHeight);
    short_file_info.biHeight = file_info.biHeight;
    short_file_info.biWidth = file_info.biWidth;
    return short_file_info;
}

void new_file_path(char* resource_string){
    filepath = malloc(256);
    filename = strCopyMove(resource_string,filepath);
}

void file_write(FILE* output_file, image_t image_short_info, bmp_header_t header_info){
    write_header(output_file, header_info);
    write_body(output_file, image_short_info);
    fclose(output_file);
}


int main(){
    int input;
    FILE* current_bmp_image;
    bmp_header_t current_header;
    image_t current_image;
    read_error_code_t result;
    new_file_path(respath);
    current_bmp_image = fileopen("to open", open_modes[0]);
    error_check(read_header(current_bmp_image, &current_header) != 0);
    current_image = get_header_info(current_header);
    error_check((result = read_body(&current_image, current_bmp_image)) != 0);
    fclose(current_bmp_image);
    while(input = options_list()){
        current_image = functions_list[--input](current_image);
        current_bmp_image = fileopen("to save", open_modes[1]);
        update_header(&current_header,current_image);

        file_write(current_bmp_image, current_image, current_header);

    }
    return 0;
}