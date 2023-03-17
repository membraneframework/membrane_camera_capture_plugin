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
    {:membrane_camera_capture_plugin, "~> 0.4.0"}
  ]
end
```

## Examples

To run the example, execute the following in your terminal in the root folder of this repository
```shell
$ elixir exapmles/camera_example.exs
```
It is expected that the example will self terminate after 60 seconds, leaving an `output.h264` file containing the recording captured from your webcam.

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
