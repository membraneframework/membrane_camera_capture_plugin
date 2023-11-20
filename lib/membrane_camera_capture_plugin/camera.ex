defmodule Membrane.CameraCapture do
  @moduledoc """
  Membrane Source Element for capturing image from a camera through FFmpeg
  """
  use Membrane.Source

  alias __MODULE__.Native
  alias Membrane.Buffer

  def_output_pad :output, accepted_format: _any, flow_control: :push

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
      state = %{native: native, provider: nil, init_time: nil, framerate: options.framerate}
      {[], state}
    else
      {:error, reason} -> raise "Failed to initialize camera, reason: #{reason}"
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
      framerate: {state.framerate, 1}
    }

    element_pid = self()

    {:ok, provider} =
      Membrane.UtilitySupervisor.start_link_child(
        ctx.utility_supervisor,
        {Task, fn -> frame_provider(state.native, element_pid) end}
      )

    state = %{state | provider: provider}
    actions = [stream_format: {:output, stream_format}]
    {actions, state}
  end

  defp frame_provider(native, target) do
    with {:ok, frame} <- Native.read_packet(native) do
      send(target, {:frame, frame})
      frame_provider(native, target)
    else
      {:error, reason} ->
        raise "Error when reading packet from camera: #{inspect(reason)}"
    end
  end

  @impl true
  def handle_info({:frame, frame}, _ctx, state) do
    time = Membrane.Time.monotonic_time()
    init_time = state.init_time || time
    buffer = %Buffer{payload: frame, pts: time - init_time}
    {[buffer: {:output, buffer}], %{state | init_time: init_time}}
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
