Mix.install([
  {:membrane_core, "~> 0.11.0"},
  {:membrane_file_plugin, "~> 0.13.0"},
  {:membrane_ffmpeg_swscale_plugin, "~> 0.11.1"},
  {:membrane_h264_ffmpeg_plugin, "~> 0.26.0"},
  {:membrane_camera_capture_plugin, path: Path.expand("../", __DIR__)}
])

defmodule Example do
  use Membrane.Pipeline

  require Membrane.Logger

  @impl true
  def handle_init(_ctx, _options) do
    structure = 
      child(:source, %Membrane.CameraCapture{
        preffered_width: 1280,
        preffered_height: 720
      }) 
      |> child(:converter, %Membrane.FFmpeg.SWScale.PixelFormatConverter{format: :I420}) 
      |> child(:encoder, Membrane.H264.FFmpeg.Encoder) 
      |> child(:sink, %Membrane.File.Sink{location: "output.h264"}) 

    Membrane.Logger.info("""
    Example is starting.
    It will automatically terminate after 60 seconds
    """)
    Process.send_after(self(), :stop, 60_000)

    {[spec: structure, playback: :playing], %{}}
  end

  @impl true
  def handle_info(:stop, _context, state) do
    {[terminate: :normal], state}
  end
end

{:ok, _supervisor, pipeline} = Example.start_link()
monitor = Process.monitor(pipeline)

receive do
  {:DOWN, ^monitor, :process, _pid, _reason} -> :ok
end

