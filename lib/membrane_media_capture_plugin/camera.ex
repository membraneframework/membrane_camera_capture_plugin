defmodule Membrane.MediaCapture do
  @moduledoc """
  Membrane Source Element for capturing image from a camera through FFmpeg
  """
  use Membrane.Source

  alias __MODULE__.Native
  alias Membrane.Buffer

  def_output_pad :output,
    caps: :any,
    availability: :always,
    mode: :pull

  def_options device: [
                spec: String.t(),
                default: "default"
              ],
              framerate: [
                spec: non_neg_integer(),
                default: 30
              ]

  @impl true
  def handle_init(%__MODULE__{} = options) do
    with {:ok, native} <- Native.open(options.device, options.framerate) do
      {:ok, %{native: native}}
    end
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    caps = %Membrane.Caps.Video.Raw{
      width: 1280,
      height: 720,
      format: :nv12,
      aligned: true,
      framerate: {30, 1}
    }

    {{:ok, caps: {:output, caps}}, state}
  end

  @impl true
  def handle_demand(:output, _size, :buffers, _ctx, state) do
    with {:ok, frame} <- Native.read_packet(state.native) do
      buffer = %Buffer{payload: frame}
      {{:ok, buffer: {:output, buffer}, redemand: :output}, state}
    else
      {:error, _reason} = error -> {error, state}
    end
  end
end
