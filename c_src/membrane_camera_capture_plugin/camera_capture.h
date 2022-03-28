#pragma once

#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <stdbool.h>
#include <unifex/unifex.h>

typedef struct State {
    AVFormatContext *input_ctx;

} State;

extern const char* driver;


#include "_generated/camera_capture.h"