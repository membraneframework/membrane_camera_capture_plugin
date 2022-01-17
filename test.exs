defmodule Example do
  use Membrane.Pipeline

  @impl true
  def handle_init(_opts) do
    spec = %ParentSpec{
      children: %{
        source: Membrane.MediaCapture,
        encoder: Membrane.H264.FFmpeg.Encoder,
        sink: %Membrane.File.Sink{location: "output.h264"}
      },
      links: [
        link(:source) |> to(:encoder) |> to(:sink)
      ]
    }

    {{:ok, spec: spec}, %{}}
  end
end

{:ok, pid} = Example.start_link()
:ok = Example.play(pid)

monitor_ref = Process.monitor(pid)

receive do
  {:DOWN, ^monitor_ref, :process, _object, _reason} -> :ok
end
