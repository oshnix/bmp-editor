#include "imagestorage.h"
#include "sepia_c.h"

static void sepia_one(pixel_t* const pixel );

void sepia_c_inplace(image_t* img ) {
    uint32_t x,y;
    for( y = 0; y < img->biHeight; y++ )
        for( x = 0; x < img->biWidth; x++ )
            sepia_one(&(img->colorArray[y*img->biWidth+x]));
}

static unsigned char sat( uint64_t x) {
    if (x < 256) return x; return 255;
}

static void sepia_one(pixel_t* const pixel ) {
    static const float c[3][3] = {
            {.393f, .769f, .189f},
            {.349f, .686f, .168f},
            {.272f, .543f, .131f}};
    pixel_t const old = *pixel;
    pixel->red = sat(
            old.red * c[0][0] + old.green * c[0][1] + old.blue * c[0][2]
    );
    pixel->green = sat(
            old.red * c[1][0] + old.green * c[1][1] + old.blue * c[1][2]
    );
    pixel->blue = sat(
            old.red * c[2][0] + old.green * c[2][1] + old.blue * c[2][2]
    );
}
