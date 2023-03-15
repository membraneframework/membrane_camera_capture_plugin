defmodule Membrane.CameraCapture.Native do
  @moduledoc false
  use Unifex.Loader

  @spec open(binary, non_neg_integer(), non_neg_integer(), non_neg_integer()) ::
          {:ok, reference()} | {:error, reason :: atom()}
  def open(url, framerate, width, height) when is_binary(url) do
    do_open(url, inspect(framerate), "#{width}x#{height}")
  end
end
