defmodule Membrane.CameraCaptureTest do
  use ExUnit.Case

  import Membrane.ParentSpec
  alias Membrane.Testing

  @tag :manual
  @tag :tmp_dir
  test "integration test", %{tmp_dir: tmp_dir} do
    options = %Testing.Pipeline.Options{
      elements: [
        source: Membrane.CameraCapture,
        converter: %Membrane.FFmpeg.SWScale.PixelFormatConverter{format: :I420},
        encoder: Membrane.H264.FFmpeg.Encoder,
        sink: %Membrane.File.Sink{location: Path.join(tmp_dir, "output.h264")}
      ],
      links: [
        link(:source) |> to(:converter) |> to(:encoder) |> to(:sink)
      ]
    }

    {:ok, pid} = Testing.Pipeline.start_link(options)
    :ok = Testing.Pipeline.play(pid)

    Process.sleep(5000)

    :ok = Membrane.Pipeline.stop_and_terminate(pid, blocking?: true)

    System.cmd("ffplay", [Path.join(tmp_dir, "output.h264")])
  end
end
