module Membrane.CameraCapture.Native

state_type "State"

spec do_open(url :: string, framerate :: string) ::
       {:ok :: label, state} | {:error :: label, reason :: atom}

spec read_packet(state) :: {:ok :: label, payload} | {:error :: label, reason :: atom}
spec stream_props(state) :: {:ok :: label, width :: int, height :: int, pixel_format :: string}

dirty :cpu, read_packet: 1
