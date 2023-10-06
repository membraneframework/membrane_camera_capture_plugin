#pragma once

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wall" 
#pragma GCC diagnostic ignored "-Wextra" 
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#pragma GCC diagnostic pop
#include <stdbool.h>
#include <unifex/unifex.h>

typedef struct State {
  AVFormatContext *input_ctx;
} State;

extern const char *driver;

#include "_generated/camera_capture.h"
