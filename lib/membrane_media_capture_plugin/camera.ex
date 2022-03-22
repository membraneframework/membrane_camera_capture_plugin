defmodule Membrane.MediaCapture do
  @moduledoc """
  Membrane Source Element for capturing image from a camera through FFmpeg
  """
  use Membrane.Source

  alias __MODULE__.Native
  alias Membrane.Buffer

  def_output_pad :output,
    caps: :any,
    availability: :always,
    mode: :pull

  def_options device: [
                spec: String.t(),
                default: "default"
              ],
              framerate: [
                spec: non_neg_integer(),
                default: 30
              ]

  @impl true
  def handle_init(%__MODULE__{} = options) do
    with {:ok, native} <- Native.open(options.device, options.framerate) do
      {:ok, %{native: native, provider: nil}}
    end
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    caps = %Membrane.RawVideo{
      width: 1280,
      height: 720,
      pixel_format: :NV12,
      aligned: true,
      framerate: {30, 1}
    }

    my_pid = self()
    pid = spawn_link(fn -> frame_provider(state.native, my_pid) end)
    {{:ok, caps: {:output, caps}}, %{state | provider: pid}}
  end

  defp frame_provider(native, target) do
    receive do
      :get_frame ->
        with {:ok, frame} <- Native.read_packet(native) do
          buffer = %Buffer{payload: frame}
          send(target, {:frame_provider, buffer})
          frame_provider(native, target)
        else
          {:error, _reason} = error -> {error, native}
        end

      :terminate ->
        :ok
    end
  end

  @impl true
  def handle_other({:frame_provider, buffer}, %{playback_state: :playing} = _ctx, state) do
    {{:ok, buffer: {:output, buffer}, redemand: :output}, state}
  end

  @impl true
  def handle_other({:frame_provider, _buffer}, _ctx, state) do
    {:ok, state}
  end

  @impl true
  def handle_demand(:output, _size, :buffers, _ctx, state) do
    send(state.provider, :get_frame)
    {:ok, state}
  end
end
