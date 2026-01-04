defmodule Membrane.CameraCapture.Native do
  @moduledoc false
  use Unifex.Loader

  @spec open(binary, non_neg_integer(), binary,  binary) :: {:ok, reference()} | {:error, reason :: atom()}
  def open(url, framerate, pixel_format, video_size) when is_binary(url) do
    do_open(url, inspect(framerate), pixel_format, video_size)
  end
end
