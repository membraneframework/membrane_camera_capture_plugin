# Membrane Template Plugin

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_template_plugin.svg)](https://hex.pm/packages/membrane_template_plugin)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/membrane_template_plugin)
[![CircleCI](https://circleci.com/gh/membraneframework/membrane_template_plugin.svg?style=svg)](https://circleci.com/gh/membraneframework/membrane_template_plugin)

This repository contains a template for new elements.

Check out different branches for other flavours of template.

It is part of [Membrane Multimedia Framework](https://membraneframework.org).

## Installation

The package can be installed by adding `membrane_template_plugin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_template_plugin, "~> 0.1.0"}
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
        source: %Membrane.MediaCapture{},
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

Process.exit(pid, :kill)

receive do
  {:DOWN, ^monitor_ref, :process, _object, _reason} -> :ok
end

```

Open generated file using:

```
ffplay output.h264
```

## Testing

To run manual tests, type `mix test --include manual`

## Copyright and License

Copyright 2020, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_template_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_template_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)
