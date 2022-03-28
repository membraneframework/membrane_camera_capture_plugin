defmodule Membrane.CameraCaptureTest do
  use ExUnit.Case

  alias Membrane.Testing

  @tag :manual
  @tag :tmp_dir
  test "integration test", %{tmp_dir: tmp_dir} do
    output_path = Path.join(tmp_dir, "output.h264")

    options = %Testing.Pipeline.Options{
      elements: [
        source: Membrane.CameraCapture,
        converter: %Membrane.FFmpeg.SWScale.PixelFormatConverter{format: :I420},
        encoder: Membrane.H264.FFmpeg.Encoder,
        sink: %Membrane.File.Sink{location: output_path}
      ]
    }

    {:ok, pid} = Testing.Pipeline.start_link(options)
    assert Testing.Pipeline.play(pid) == :ok

    Process.sleep(5000)

    # Check if pipeline is alive
    assert Process.alive?(pid)

    :ok = Membrane.Pipeline.stop_and_terminate(pid, blocking?: true)

    System.cmd("ffplay", [output_path])
  end
end
