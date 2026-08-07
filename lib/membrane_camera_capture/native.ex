defmodule Membrane.CameraCapture.Native do
  @moduledoc false
  use Unifex.Loader

  @spec open(binary(), non_neg_integer(), binary(), {pos_integer(), pos_integer()} | nil) ::
          {:ok, reference()} | {:error, reason :: atom()}
  def open(url, framerate, pixel_format, video_size) when is_binary(url) do
    video_size =
      case video_size do
        {width, height} -> "#{width}x#{height}"
        nil -> ""
      end

    do_open(url, inspect(framerate), pixel_format, video_size)
  end
end
