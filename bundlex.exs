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
        os_deps: [
          ffmpeg: [
            {:precompiled,
             Membrane.PrecompiledDependencyProvider.get_dependency_url(:ffmpeg,
               version: "6.0.1"
             ), ["libavformat", "libavutil", "libavdevice"]},
            {:pkg_config, ["libavformat", "libavutil", "libavdevice"]}
          ]
        ],
        preprocessor: Unifex
      ]
    ]
  end
end
