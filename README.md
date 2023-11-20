# Membrane Camera Capture Plugin

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_camera_capture_plugin.svg)](https://hex.pm/packages/membrane_camera_capture_plugin)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/membrane_camera_capture_plugin)
[![CircleCI](https://circleci.com/gh/membraneframework/membrane_camera_capture_plugin.svg?style=svg)](https://circleci.com/gh/membraneframework/membrane_camera_capture_plugin)

This plugin can be used to capture video stream from an input device.

It is part of [Membrane Multimedia Framework](https://membraneframework.org).

## Installation

Add the following line to your `deps` in `mix.exs`. Run `mix deps.get`.

```elixir
	{:membrane_camera_capture_plugin, "~> 0.7.0"}
```

This package depends on the [ffmpeg](https://www.ffmpeg.org) libraries. The precompiled builds will be pulled and linked automatically. However, should there be any problems, consider installing it manually.

### Manual instalation of dependencies
#### Ubuntu

```bash
sudo apt-get install ffmpeg
```

#### Arch/Manjaro

```bash
pacman -S ffmpeg
```

#### MacOS

```bash
brew install ffmpeg
```

## Sample Usage

Dependencies:

```elixir
def deps do
  [
	{:membrane_camera_capture_plugin, "~> 0.7.0"}
    {:membrane_h264_ffmpeg_plugin, "~> 0.21"},
    {:membrane_file_plugin, "~> 0.10"},
    {:membrane_ffmpeg_swscale_plugin, "~> 0.10"}
  ]
end
```

```elixir
defmodule Example do
  use Membrane.Pipeline

  @impl true
  def handle_init(_ctx, _options) do
    structure =
      child(:source, Membrane.CameraCapture)
      |> child(:converter, %Membrane.FFmpeg.SWScale.PixelFormatConverter{format: :I420})
      |> child(:encoder, Membrane.H264.FFmpeg.Encoder)
      |> child(:sink, %Membrane.File.Sink{location: "output.h264"})

    {[spec: structure], %{}}
  end
end
```

## Testing

To run manual tests, you need to install dependencies:

```shell
$ mix deps.get
```

And run manual (you observe the result and decide whether it works) tests:

```shell
$ mix test --include manual
```

If it runs successfully, you should be able to see video from your camera.

_You might be asked to grant access to your camera, as some operating systems require that_

_In case of the absence of a physical camera, it is necessary to use a virtual camera (e.g. OBS, [see how to set up the virtual camera in OBS](https://obsproject.com/kb/virtual-camera-guide))_

## Copyright and License

Copyright 2022, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_camera_capture_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_camera_capture_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)
