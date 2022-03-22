# Membrane Camera Capture Plugin

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_camera_capture_plugin.svg)](https://hex.pm/packages/membrane_camera_capture_plugin)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/membrane_camera_capture_plugin)
[![CircleCI](https://circleci.com/gh/membraneframework/membrane_camera_capture_plugin.svg?style=svg)](https://circleci.com/gh/membraneframework/membrane_camera_capture_plugin)

This Plugin can be used to capture Camera video from a device.

It is part of [Membrane Multimedia Framework](https://membraneframework.org).

## Installation

The package can be installed by adding `membrane_camera_capture_plugin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_camera_capture_plugin, "~> 0.2.0"}
  ]
end
```

## Usage example

```elixir
defmodule Example do
  use Membrane.Pipeline

  @impl true
  def handle_init(_opts) do
    spec = %ParentSpec{
      children: %{
        source: %Membrane.CameraCapture{},
        converter: %Membrane.FFmpeg.SWScale.PixelFormatConverter{format: :I420},
        encoder: Membrane.H264.FFmpeg.Encoder,
        sink: %Membrane.File.Sink{location: "output.h264"}
      },
      links: [
        link(:source) |> to(:converter) |> to(:encoder) |> to(:sink)
      ]
    }

    {{:ok, spec: spec}, %{}}
  end
end

{:ok, pid} = Example.start_link()
:ok = Example.play(pid)

monitor_ref = Process.monitor(pid)

Process.sleep(5000)

:ok = Membrane.Pipeline.stop_and_terminate(pid, blocking?: true)

receive do
  {:DOWN, ^monitor_ref, :process, _object, _reason} -> :ok
end

```

Open generated file using:

```
ffplay output.h264
```

## Testing

To run manual tests, type

```shell
mix test --include manual
```

## Copyright and License

Copyright 2020, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_camera_capture_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_camera_capture_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)
