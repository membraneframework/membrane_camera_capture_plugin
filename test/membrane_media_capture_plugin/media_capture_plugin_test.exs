defmodule Membrane.MediaCaptureTest do
  use ExUnit.Case

  alias Membrane.Testing
  import Membrane.ParentSpec

  @tag :manual
  test "integration test" do
    options = %Testing.Pipeline.Options{
      elements: [
        source: Membrane.MediaCapture,
        converter: %Membrane.FFmpeg.SWScale.PixelFormatConverter{format: :I420},
        encoder: Membrane.H264.FFmpeg.Encoder,
        sink: %Membrane.File.Sink{location: "output.h264"}
      ],
      links: [
        link(:source) |>
         |> to(:encoder) |> to(:sink)
      ]
    }

    {:ok, pid} = Testing.Pipeline.start_link(options)
    :ok = Testing.Pipeline.play(pid)

    Process.sleep(1000)

    :ok = Membrane.Pipeline.stop_and_terminate(pid, blocking?: true)

    System.cmd("ffplay", ["output.h264"])
  end
end
