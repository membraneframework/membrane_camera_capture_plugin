module Membrane.MediaCapture.Native

state_type "State"

spec open(
  type :: atom,
) :: {:ok :: label, state} | {:error :: label, reason :: atom}

spec read_packet(state) :: {:ok :: label, payload} | {:error :: label, reason :: atom}

dirty :cpu, read_packet: 1
