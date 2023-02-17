defmodule Membrane.CameraCapture do
  @moduledoc """
  Membrane Source Element for capturing image from a camera through FFmpeg
  """
  use Membrane.Source

  alias __MODULE__.Native
  alias Membrane.Buffer

  def_output_pad :output,
    accepted_format: _any,
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
  def handle_init(_ctx, %__MODULE__{} = options) do
    with {:ok, native} <- Native.open(options.device, options.framerate) do
      state = %{native: native, provider: nil}
      {[], state}
    end
  end

  @impl true
  def handle_playing(ctx, state) do
    {:ok, width, height, pixel_format} = Native.stream_props(state.native)

    stream_format = %Membrane.RawVideo{
      width: width,
      height: height,
      pixel_format: pixel_format_to_atom(pixel_format),
      aligned: true,
      framerate: {30, 1}
    }

    my_pid = self()
    pid = spawn_link(fn -> frame_provider(state.native, my_pid) end)

    Membrane.ResourceGuard.register(
      ctx.resource_guard,
      fn -> send(pid, :stop) end
    )

    state = %{state | provider: pid}
    actions = [stream_format: {:output, stream_format}]
    {actions, state}
  end

  defp frame_provider(native, target) do
    receive do
      :stop -> :ok
    after
      0 ->
        with {:ok, frame} <- Native.read_packet(native) do
          buffer = %Buffer{payload: frame}
          send(target, {:frame_provider, buffer})
          frame_provider(native, target)
        else
          {:error, reason} ->
            raise "Error when reading packet from camera: #{inspect(reason)}"
        end
    end
  end

  @impl true
  def handle_info({:frame_provider, buffer}, %{playback: :playing} = _ctx, state) do
    {[buffer: {:output, buffer}], state}
  end

  # This callback is called only when
  # element is not in state playing and frame provider is not
  # terminated yet (and sending a frame to us, so we ignore it)
  @impl true
  def handle_info({:frame_provider, _buffer}, _ctx, state) do
    {[], state}
  end

  defp pixel_format_to_atom("yuv420p"), do: :I420
  defp pixel_format_to_atom("yuv422p"), do: :I422
  defp pixel_format_to_atom("yuv444p"), do: :I444
  defp pixel_format_to_atom("rgb24"), do: :RGB
  defp pixel_format_to_atom("rgba"), do: :RGBA
  defp pixel_format_to_atom("yuyv422"), do: :YUY2
  defp pixel_format_to_atom("nv12"), do: :NV12
  defp pixel_format_to_atom("nv21"), do: :NV21
  defp pixel_format_to_atom(pixel_format), do: raise("unsupported pixel format #{pixel_format}")
end
