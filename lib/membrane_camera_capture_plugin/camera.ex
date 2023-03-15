defmodule Membrane.CameraCapture do
  @moduledoc """
  Membrane Source Element for capturing image from a camera through FFmpeg
  """
  use Membrane.Source

  alias __MODULE__.Native
  alias Membrane.Buffer

  @supported_pixel_formats [
    :I420,
    :I422,
    :I444,
    :RGB,
    :RGBA,
    :YUY2,
    :NV12
  ]

  def_output_pad :output,
    accepted_format:
      %Membrane.RawVideo{pixel_format: pixel_format} when pixel_format in @supported_pixel_formats,
    availability: :always,
    mode: :push

  def_options device: [
                spec: String.t() | nil,
                default: nil,
                description: "Name of the device used to capture video"
              ],
              preffered_framerate: [
                spec: non_neg_integer(),
                default: 15,
                description: """
                Framerate value passed to Ffmpeg's device initialization.

                Final framerate depends on device's capabilities and may be override by the driver without warning.
                """
              ],
              preffered_width: [
                spec: non_neg_integer(),
                default: 640,
                description: """
                Width passed to Ffmpeg's device initialization.

                Final width depends on device's capabilities and may be override by the driver without warning.
                """
              ],
              preffered_height: [
                spec: non_neg_integer(),
                default: 480,
                description: """
                Height passed to FFmpeg's decive initialization.

                Final height depends on device's capabilities and may be override by the driver without warning.
                """
              ]

  @impl true
  def handle_init(_ctx, %__MODULE__{} = options) do
    with {:ok, native} <-
           Native.open(
             options.device || find_default_device(),
             options.preffered_framerate,
             options.preffered_width,
             options.preffered_height
           ) do
      state = %{native: native, provider: nil}
      {[], state}
    end
  end

  @impl true
  def handle_playing(ctx, state) do
    {:ok, width, height, pixel_format, framerate_nom, framerate_den} =
      Native.stream_props(state.native)

    stream_format = %Membrane.RawVideo{
      width: width,
      height: height,
      pixel_format: pixel_format_to_atom(pixel_format),
      aligned: true,
      framerate: {framerate_nom, framerate_den}
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
  defp pixel_format_to_atom(pixel_format), do: raise("Unsupported pixel format #{pixel_format}")

  defp find_default_device() do
    case :os.type() do
      {:unix, :darwin} ->
        # macos
        "default"

      {:unix, _subtype} ->
        # some sort of linux
        "/dev/video0"

      {:win32, _subtype} ->
        raise "Default device discovery is not available on Windows. Please provide the URL"
    end
  end
end
