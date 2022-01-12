defmodule Membrane.MediaCapture.BundlexProject do
  use Bundlex.Project

  def project do
    [
      natives: natives()
    ]
  end

  defp natives() do
    [
      media_capture: [
        interface: :nif,
        sources: ["media_capture.c"],
        pkg_configs: ["libavutil", "libavcodec"],
        preprocessor: Unifex
      ]
    ]
  end
end
