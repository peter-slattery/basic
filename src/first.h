#include <stdio.h>
#include <stdint.h>

// Sokol
#define SOKOL_IMPL
#define SOKOL_GLCORE33
#include "../lib/sokol/sokol_app.h"
#include "../lib/sokol/sokol_gfx.h"

// STB Libraries
#define STB_IMAGE_IMPLEMENTATION 1
#include "../lib/stb/stb_image.h"

#define STB_SPRINTF_IMPLEMENTATION 1
#include "../lib/stb/stb_sprintf.h"

// Handmade Math
#include "../lib/HandmadeMath/HandmadeMath.h"