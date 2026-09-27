`ifndef VIDEO_TYPES_SVH
`define VIDEO_TYPES_SVH

typedef struct packed {
    bit [5:0] r;
    bit [5:0] g;
    bit [5:0] b;
} rgb666_s;

typedef struct packed {
    bit [7:0] r;
    bit [7:0] g;
    bit [7:0] b;
} rgb888_s;

typedef struct packed {
    bit t;
    bit [4:0] r;
    bit [4:0] g;
    bit [4:0] b;
} rgb555_s;

typedef struct packed {
    bit [7:0] y;
    bit [7:0] u;
    bit [7:0] v;
} yuv_s;

typedef enum bit [1:0] {
    kBitmap = 2'd0,
    kRunLength = 2'd2,
    kMosaic = 2'd3
} file_type_e;

typedef enum bit [1:0] {
    kMosaicFactor2,
    kMosaicFactor4,
    kMosaicFactor8,
    kMosaicFactor16
} mosaic_factor_e;

typedef struct {
    bit cm;
    mosaic_factor_e mf;
    file_type_e ft;

    bit strobe;  // used to force an overwrite
} display_parameters_s;

`endif
