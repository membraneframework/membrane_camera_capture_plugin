# Membrane Camera Capture Plugin

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_camera_capture_plugin.svg)](https://hex.pm/packages/membrane_camera_capture_plugin)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/membrane_camera_capture_plugin)
[![CircleCI](https://circleci.com/gh/membraneframework/membrane_camera_capture_plugin.svg?style=svg)](https://circleci.com/gh/membraneframework/membrane_camera_capture_plugin)

This plugin can be used to capture video stream from an input device.

It is part of [Membrane Multimedia Framework](https://membraneframework.org).

## Installation

The package can be installed by adding `membrane_camera_capture_plugin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_camera_capture_plugin, "~> 0.3.0"}
  ]
end
```

## Sample Usage

Dependencies:

```elixir
def deps do
  [
    {:membrane_camera_capture_plugin, "~> 0.3.0"},
    {:membrane_h264_ffmpeg_plugin, "~> 0.18.0"},
    {:membrane_file_plugin, "~> 0.9.0"},
    {:membrane_ffmpeg_swscale_plugin, "~> 0.8.0"}
  ]
end
```

```elixir
defmodule Example do
  use Membrane.Pipeline

  @impl true
  def handle_init(_) do
    children = [
      source: Membrane.CameraCapture,
      converter: %Membrane.FFmpeg.SWScale.PixelFormatConverter{format: :I420},
      encoder: Membrane.H264.FFmpeg.Encoder,
      sink: %Membrane.File.Sink{location: "output.h264"}
    ]

    links = [
      link(:source)
      |> to(:converter)
      |> to(:encoder)
      |> to(:sink)
    ]

    {{:ok, spec: %ParentSpec{children: children, links: links}}, %{}}
  end
end
```

## Testing

Running this manual test, you should be able to record a 5-sec long video stream from your webcam and then play it using ffplay (you need to have ffmpeg installed).

To run manual tests, you need to install dependencies:

```shell
$ mix deps.get
```

And run manual (you observe the result and decide whether it works) tests:

```shell
$ mix test --include manual
```

If run successfully, you should be able to see video recorded by your camera.

## Copyright and License

Copyright 2022, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_camera_capture_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_camera_capture_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)
