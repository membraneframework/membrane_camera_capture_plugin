defmodule Membrane.MediaCapture.Native do
  use Unifex.Loader

  def test, do: open("avfoundation", "default")
end
