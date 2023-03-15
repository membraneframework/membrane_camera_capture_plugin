#include "./camera_capture.h"

#include <libavdevice/avdevice.h>
#include <libavutil/pixdesc.h>
#include <string.h>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
const char *driver = "dshow";
#elif __APPLE__
const char *driver = "avfoundation";
#elif __linux__
const char *driver = "v4l2";
#endif

UNIFEX_TERM do_open(UnifexEnv *env, char *url, char *framerate, char *resolution) {
  avdevice_register_all();
  State *state = unifex_alloc_state(env);
  state->input_ctx = NULL;
  UNIFEX_TERM ret;

  AVInputFormat *input_format = av_find_input_format(driver);
  if (input_format == NULL) {
    ret = do_open_result_error(env, "Could not open input");
    goto end;
  }

  AVDictionary *options = NULL;

  if(strcmp(framerate, "0") != 0) {
    av_dict_set(&options, "framerate", framerate, 0);
  }

  av_dict_set(&options, "pixel_format", "nv12", 0);
  av_dict_set(&options, "video_size", resolution, 0);
  if (avformat_open_input(&state->input_ctx, url, input_format, &options) < 0) {
    ret = do_open_result_error(env, "Could not open supplied url");
    goto end;
  }

  if (avformat_find_stream_info(state->input_ctx, NULL) < 0) {
    ret = do_open_result_error(env, "Couldn't get stream info");
    goto cleanup;
  }

  if (state->input_ctx->nb_streams == 0) {
    ret = do_open_result_error(env, "No streams found - at least one is required");
    goto cleanup;
  }

  printf("Nb streams: %d\n", state->input_ctx->nb_streams);

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
  while ((res = av_read_frame(state->input_ctx, &packet)) == AVERROR(EAGAIN));

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

UNIFEX_TERM stream_props(UnifexEnv *env, State *state) {
  AVStream *stream = state->input_ctx->streams[0];
  AVCodecParameters *codec_params = stream->codecpar;
  AVRational frame_rate = stream->avg_frame_rate;
  return stream_props_result_ok(env, codec_params->width, codec_params->height, av_get_pix_fmt_name(codec_params->format), frame_rate.num, frame_rate.den);
}

void handle_destroy_state(UnifexEnv *_env, State *state) {
  UNIFEX_UNUSED(_env);
  avformat_close_input(&state->input_ctx);
}
