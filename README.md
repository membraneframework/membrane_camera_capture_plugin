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
    {:membrane_camera_capture_plugin, "~> 0.1.0"}
  ]
end
```

## Testing (and usage example)

Running this manual test, you should be able to record a 5-sec long video stream from your webcam and then play it using ffplay (you need to have ffmpeg installed).

Moreover, you can check how this plugin can be used [in this test](test/membrane_media_capture_plugin/camera_capture_plugin_test.exs).

To run manual tests, you need to install dependencies:

```shell
$ mix deps.get
```

And run manual (you observe the result and decide whether it works) tests:

```shell
$ mix test --include manual
```

If run successfully, you should be able to see yourself in the video.

## Copyright and License

Copyright 2022, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_camera_capture_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_camera_capture_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)
