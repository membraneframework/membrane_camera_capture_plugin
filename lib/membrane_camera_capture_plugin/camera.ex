defmodule Membrane.CameraCapture do
  @moduledoc """
  Membrane Source Element for capturing image from a camera through FFmpeg
  """
  use Membrane.Source

  alias __MODULE__.Native
  alias Membrane.Buffer

  def_output_pad :output,
    caps: :any,
    availability: :always,
    mode: :push

  def_options device: [
                spec: String.t(),
                default: "default",
                description: "Name of the device used to capture video"
              ],
              framerate: [
                spec: non_neg_integer(),
                default: 30,
                description: "Framerate of device's output video stream"
              ]

  @impl true
  def handle_init(%__MODULE__{} = options) do
    with {:ok, native} <- Native.open(options.device, options.framerate) do
      {:ok, %{native: native, provider: nil}}
    end
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    caps = %Membrane.RawVideo{
      width: 1280,
      height: 720,
      pixel_format: :NV12,
      aligned: true,
      framerate: {30, 1}
    }

    my_pid = self()
    pid = spawn_link(fn -> frame_provider(state.native, my_pid) end)
    {{:ok, caps: {:output, caps}}, %{state | provider: pid}}
  end

  defp frame_provider(native, target) do
    with {:ok, frame} <- Native.read_packet(native) do
      buffer = %Buffer{payload: frame}
      send(target, {:frame_provider, buffer})
      frame_provider(native, target)
    else
      {:error, reason} ->
        raise "Error when reading packet from camera: #{inspect(reason)}"
    end
  end

  @impl true
  def handle_other({:frame_provider, buffer}, %{playback_state: :playing} = _ctx, state) do
    {{:ok, buffer: {:output, buffer}}, state}
  end

  @impl true
  def handle_other({:frame_provider, _buffer}, _ctx, state) do
    {:ok, state}
  end
end
