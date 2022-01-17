defmodule Example do
  def get_frames(_state, 0) do
    :ok
  end

  def get_frames(state, counter) do
    with {:ok, frame} <- Membrane.MediaCapture.Native.read_packet(state) do
      File.write!("output/frame_#{counter}.raw", frame, [:binary])
      get_frames(state, counter - 1)
    else
      {:error, _reason} = error ->
        IO.puts("#{counter} frames left to go, but failed to get them")
        error
    end
  end
end

File.rm_rf("output")
File.mkdir!("output")
{:ok, ref} = Membrane.MediaCapture.Native.test()
{time, :ok} = :timer.tc(fn -> Example.get_frames(ref, 60) end)

time =
  Membrane.Time.microseconds(time)
  |> Membrane.Time.to_seconds()
  |> then(fn
    %Ratio{} = input -> Ratio.to_string(input)
    id -> id
  end)

IO.puts("Took #{time} seconds to get 60 frames")
