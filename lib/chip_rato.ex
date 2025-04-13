defmodule ChipRato do
  alias ChipRato.State

  def start(_, _) do
    {:ok, binary} = File.read("roms/ibm_logo.ch8")
    byte_list = :binary.bin_to_list(binary)

    state =
      Enum.reduce(Enum.with_index(byte_list), State.new(), fn {byte, index}, state ->
        State.set_memory(state, index + 512, byte)
      end)

    # Main loop to fetch, decode, and execute instructions
    main_viewport_config = Application.get_env(:chip_rato, :viewport)

    # start the application with the viewport
    children = [
      {Scenic, [main_viewport_config]},
      ChipRato.PubSub.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
