#pragma once

int WriteRgbPng(const char *path, int width, int height, int vertical_scale, const uint8_t *pixels);
int WriteRgbBmp(const char *path, int width, int height, int vertical_scale, const uint8_t *pixels);
int WriteBmp(const char *path, int width, int height, uint8_t *pixels);
