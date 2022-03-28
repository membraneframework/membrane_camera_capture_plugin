defmodule Membrane.CameraCapture.BundlexProject do
  use Bundlex.Project

  def project do
    [
      natives: natives()
    ]
  end

  defp natives() do
    [
      camera_capture: [
        interface: :nif,
        sources: ["camera_capture.c"],
        pkg_configs: ["libavformat", "libavutil", "libavdevice"],
        preprocessor: Unifex
      ]
    ]
  end
end
