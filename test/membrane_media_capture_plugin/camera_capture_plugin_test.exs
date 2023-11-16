defmodule Membrane.CameraCaptureTest do
  use ExUnit.Case

  import Membrane.ChildrenSpec

  alias Membrane.Testing

  @tag :manual
  @tag :tmp_dir
  test "integration test" do
    spec =
      child(Membrane.CameraCapture)
      |> child(%Membrane.FFmpeg.SWScale.PixelFormatConverter{format: :I420})
      |> child(Membrane.SDL.Player)

    pipeline = Testing.Pipeline.start_link_supervised!(spec: spec)

    Process.sleep(10_000)

    # Check if pipeline is alive
    assert Process.alive?(pipeline)

    Membrane.Pipeline.terminate(pipeline)
  end
end
