#include <png.h>
#include <cstdio>
#include <cstdint>
#include <vector>

int WriteBmp(const char *path, int width, int height, uint8_t *pixels) {
    FILE *fh = fopen(path, "wb");
    if (!fh) {
        return 0;
    }

    int padded_width = (width * 3 + 3) & (~3);
    int padding = padded_width - (width * 3);
    int data_size = padded_width * height;
    int file_size = 54 + data_size;

    fwrite("BM", 1, 2, fh);
    fwrite(&file_size, 1, 4, fh);
    fwrite("\x00\x00\x00\x00\x36\x00\x00\x00\x28\x00\x00\x00", 1, 12, fh);
    fwrite(&width, 1, 4, fh);
    fwrite(&height, 1, 4, fh);
    fwrite("\x01\x00\x18\x00\x00\x00\x00\x00", 1, 8, fh); // planes, bpp, compression
    fwrite(&data_size, 1, 4, fh);
    fwrite("\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", 1, 16, fh);

    for (int y = height - 1; y >= 0; y--) {
        fwrite(pixels + y * width * 3, 3, width, fh);
        fwrite("\x00\x00\x00\x00", 1, padding, fh);
    }
    fclose(fh);
    return file_size;
}

// Writes the simulator's RGB framebuffer as a vertically scaled BGR BMP.
int WriteRgbBmp(const char *path, int width, int height, int vertical_scale, const uint8_t *pixels) {
    FILE *fh = fopen(path, "wb");
    if (!fh)
        return 0;

    const int output_height = height * vertical_scale;
    const int padded_width = (width * 3 + 3) & (~3);
    const int data_size = padded_width * output_height;
    const int file_size = 54 + data_size;

    fwrite("BM", 1, 2, fh);
    fwrite(&file_size, 1, 4, fh);
    fwrite("\x00\x00\x00\x00\x36\x00\x00\x00\x28\x00\x00\x00", 1, 12, fh);
    fwrite(&width, 1, 4, fh);
    fwrite(&output_height, 1, 4, fh);
    fwrite("\x01\x00\x18\x00\x00\x00\x00\x00", 1, 8, fh);
    fwrite(&data_size, 1, 4, fh);
    fwrite("\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", 1, 16, fh);

    std::vector<uint8_t> bgr_row(padded_width, 0);
    for (int y = height - 1; y >= 0; y--) {
        const uint8_t *row = pixels + y * width * 3;
        for (int x = 0; x < width; x++) {
            const uint8_t *pixel = row + x * 3;
            uint8_t *bgr_pixel = &bgr_row[x * 3];
            bgr_pixel[0] = pixel[2];
            bgr_pixel[1] = pixel[1];
            bgr_pixel[2] = pixel[0];
        }
        for (int repeat = 0; repeat < vertical_scale; repeat++) {
            if (fwrite(bgr_row.data(), 1, padded_width, fh) != static_cast<size_t>(padded_width)) {
                fclose(fh);
                return 0;
            }
        }
    }
    fclose(fh);
    return file_size;
}

// Writes the simulator's RGB framebuffer as a vertically scaled PNG.
int WriteRgbPng(const char *path, int width, int height, int vertical_scale, const uint8_t *pixels) {
    FILE *file = fopen(path, "wb");
    if (!file)
        return 0;

    png_structp png = png_create_write_struct(PNG_LIBPNG_VER_STRING, nullptr, nullptr, nullptr);
    png_infop info = png ? png_create_info_struct(png) : nullptr;
    if (!png || !info || setjmp(png_jmpbuf(png))) {
        if (png)
            png_destroy_write_struct(&png, info ? &info : nullptr);
        fclose(file);
        return 0;
    }

    const int output_height = height * vertical_scale;
    png_init_io(png, file);
    png_set_IHDR(png, info, width, output_height, 8, PNG_COLOR_TYPE_RGB, PNG_INTERLACE_NONE,
                 PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
    png_write_info(png, info);

    std::vector<png_bytep> rows(output_height);
    for (int row = 0; row < output_height; row++)
        rows[row] = const_cast<png_bytep>(pixels + (row / vertical_scale) * width * 3);
    png_write_image(png, rows.data());
    png_write_end(png, nullptr);
    png_destroy_write_struct(&png, &info);
    fclose(file);
    return 1;
}