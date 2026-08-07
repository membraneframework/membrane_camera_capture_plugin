defmodule Membrane.CameraCapture do
  @moduledoc """
  Membrane Source Element for capturing image from a camera through FFmpeg
  """
  use Membrane.Source

  alias __MODULE__.Native
  alias Membrane.Buffer

  def_output_pad :output, accepted_format: _any, flow_control: :push

  @pixel_formats %{
    "yuv420p" => :I420,
    "yuv422p" => :I422,
    "yuv444p" => :I444,
    "rgb24" => :RGB,
    "rgba" => :RGBA,
    "yuyv422" => :YUY2,
    "nv12" => :NV12,
    "nv21" => :NV21
  }

  def_options device: [
                spec: String.t(),
                default: "default",
                description: "Name of the device used to capture video"
              ],
              framerate: [
                spec: non_neg_integer(),
                default: 30,
                description: "Framerate of device's output video stream"
              ],
              pixel_format: [
                spec: String.t(),
                default: "nv12",
                description: """
                Pixel format requested from the device.
                Must be one of: #{@pixel_formats |> Map.keys() |> Enum.join(", ")}.
                """
              ],
              video_size: [
                spec: {pos_integer(), pos_integer()} | nil,
                default: nil,
                description: """
                Size of a video stream requested from the device, e.g. `{1920, 1080}`.
                If set to `nil`, the device's default size is used.
                """
              ]

  @impl true
  def handle_init(_ctx, %__MODULE__{} = options) do
    if not Map.has_key?(@pixel_formats, options.pixel_format) do
      raise "Unsupported pixel format #{inspect(options.pixel_format)}"
    end

    with {:ok, native} <-
           Native.open(
             options.device,
             options.framerate,
             options.pixel_format,
             options.video_size
           ) do
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
        # The call to Supervisor.child_spec can be removed after
        # https://github.com/membraneframework/membrane_core/pull/681 is merged and released.
        Supervisor.child_spec({Task, fn -> frame_provider(state.native, element_pid) end}, [])
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

  defp pixel_format_to_atom(pixel_format) do
    Map.get(@pixel_formats, pixel_format) ||
      raise "unsupported pixel format #{pixel_format}"
  end
end
