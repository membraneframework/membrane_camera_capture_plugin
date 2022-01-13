#pragma once

#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <stdbool.h>
#include <unifex/unifex.h>

typedef struct State {
    AVFormatContext *input_ctx;

} State;

#include "_generated/media_capture.h"