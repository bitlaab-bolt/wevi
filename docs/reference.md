# API References

Make sure to checkout code comments for additional details.

## libspng

[libspng](https://github.com/randy408/libspng/) (simple png) is a C library for reading and writing Portable Network Graphics (PNG) format files with a focus on security and ease of use.

**Limes exposes underlying `libspng` APIs to `lime.Api.spng`.**

### New Context

`spng.ctxNew()` maps to `spng_ctx_new()` in libspng.

### Free Context

`spng.ctxFree()` maps to `spng_ctx_free()` in libspng.

### Error Message

`spng.strError()` maps to `spng_strerror()` in libspng.

### Open File

`spng.open()` maps to `fopen()`.

### Close File

`spng.close()` maps to `fclose()`.

### Set Png File

`spng.setPngFile()` maps to `spng_set_png_file()` in libspng.

### Get Header Info

`spng.getIhdr()` maps to `spng_get_ihdr()` in libspng.

### Decode Image Size

`spng.decodeImageSize()` maps to `spng_decoded_image_size()` in libspng.

### Decode Image

`spng.decodeImage()` maps to `spng_decode_image()` in libspng.
