#include "./media_capture.h"

#include <libavdevice/avdevice.h>
#include <string.h>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
const char *driver = "v4l2";
#elif __APPLE__
const char *driver = "avfoundation";
#elif __linux__
const char *driver = "dshow";
#endif

UNIFEX_TERM do_open(UnifexEnv *env, char *url, char *framerate) {
  avdevice_register_all();
  State *state = unifex_alloc_state(env);
  UNIFEX_TERM ret;

  AVInputFormat *input_format = av_find_input_format(driver);
  if (input_format == NULL) {
    ret = do_open_result_error(env, "Could open supplied format");
    goto end;
  }

  state->input_ctx = avformat_alloc_context();
  AVDictionary *options = NULL;

  av_dict_set(&options, "framerate", framerate, 0);
  if (avformat_open_input(&state->input_ctx, url, input_format, &options) < 0) {
    ret = do_open_result_error(env, "Could not open supplied url");
    goto end;
  }

  if (avformat_find_stream_info(state->input_ctx, NULL) < 0) {
    ret = do_open_result_error(env, "Couldn't get stream info");
    goto cleanup;
  }

  if (state->input_ctx->nb_streams == 0) {
    ret = do_open_result_error(env,
                               "No streams found - at least one is required");
    goto cleanup;
  }

  ret = do_open_result_ok(env, state);
  goto end;
cleanup:
  avformat_close_input(&state->input_ctx);
end:
  unifex_release_state(env, state);
  return ret;
}

UNIFEX_TERM read_packet(UnifexEnv *env, State *state) {
  AVPacket packet;
  UNIFEX_TERM ret;
  int res;
  while ((res = av_read_frame(state->input_ctx, &packet)) == -35)
    ;

  if (res < 0) {
    ret = read_packet_result_error(env, av_err2str(res));
    goto end;
  }

  UnifexPayload payload;
  unifex_payload_alloc(env, UNIFEX_PAYLOAD_BINARY, packet.size, &payload);
  memcpy(payload.data, packet.data, packet.size);

  ret = read_packet_result_ok(env, &payload);
  unifex_payload_release(&payload);
end:
  av_packet_unref(&packet);
  return ret;
}

void handle_destroy_state(UnifexEnv *_env, State *state) {
  avformat_close_input(&state->input_ctx);
  avformat_free_context(state->input_ctx);
}