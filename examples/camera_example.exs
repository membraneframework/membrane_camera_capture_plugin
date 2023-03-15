Mix.install([
  {:membrane_core, "~> 0.11.0"},
  {:membrane_file_plugin, "~> 0.13.0"},
  {:membrane_ffmpeg_swscale_plugin, github: "membraneframework/membrane_ffmpeg_swscale_plugin", branch: "support-yuy2"},
  {:membrane_h264_ffmpeg_plugin, github: "membraneframework/membrane_h264_ffmpeg_plugin", branch: "update_caps"},
  {:membrane_camera_capture_plugin, path: Path.expand("../", __DIR__)}
])

defmodule Example do
  use Membrane.Pipeline

  require Membrane.Logger

  @impl true
  def handle_init(_ctx, _options) do
    structure = 
      child(:source, %Membrane.CameraCapture{
        width: 1280,
        height: 720
      }) 
      |> child(:converter, %Membrane.FFmpeg.SWScale.PixelFormatConverter{format: :I420}) 
      |> child(:encoder, Membrane.H264.FFmpeg.Encoder) 
      |> child(:sink, %Membrane.File.Sink{location: "output.h264"}) 

    Membrane.Logger.info("""
    Example is starting.
    It will automatically terminate after 20 seconds
    """)
    Process.send_after(self(), :stop, 20_000)

    {[spec: structure, playback: :playing], %{}}
  end

  @impl true
  def handle_info(:stop, _context, state) do
    Membrane.Pipeline.terminate(self())
    {[], state}
  end
end

{:ok, _supervisor, pipeline} = Example.start_link(%{})
monitor = Process.monitor(pipeline)

receive do
  {:DOWN, ^monitor, :pid, _process, _reason} -> :ok
end

