#include "./media_capture.h"
#include <libavdevice/avdevice.h>

UNIFEX_TERM open(UnifexEnv* env, char *format, char* url) {
    avdevice_register_all();
    State * state = unifex_alloc_state(env);
    UNIFEX_TERM ret;

    AVInputFormat* av_format = av_find_input_format(format);
    if(av_format == NULL) {
        ret = open_result_error(env, "Could open supplied format");
        goto end;
    }
    
    printf("Allocing input\n");
    state->input_ctx = avformat_alloc_context();
    AVDictionary* options = NULL;
    av_dict_set(&options, "framerate", "30", 0);
    if(avformat_open_input(&state->input_ctx, url, av_format, &options) < 0) {
        ret = open_result_error(env, "Could not open supplied url");
        goto end;
    }
    
    printf("Gettting stream info\n");
    if (avformat_find_stream_info(state->input_ctx, NULL) < 0) {
        ret = open_result_error(env, "Couldn't get stream info");
        goto cleanup;
    }
    
    if(state->input_ctx->nb_streams == 0) {
        ret = open_result_error(env, "No streams found - at least one is required");
        goto cleanup;
    }

    printf("Streams found: %d\n", state->input_ctx->nb_streams);

    ret = open_result_ok(env, state);
cleanup:
    avformat_close_input(&state->input_ctx);
end:
    unifex_release_state(env, state);
    return ret;
}

void handle_destroy_state(UnifexEnv* _env, State *state) {
    avformat_close_input(&state->input_ctx);
    avformat_free_context(state->input_ctx);
}