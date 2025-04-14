defmodule ChipRato do
  use GenServer
  alias ChipRato.State
  alias ChipRato.Decoder

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
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
    Process.send_after(self(), :continue_loop, 10)
    {:ok, state}
  end

  def loop(state) do
    {instruction, state} = Decoder.fetch_instruction(state.memory, state)
    {opcode, x, y, n, nn, nnn} = Decoder.decode_instruction(instruction)
    state = Decoder.execute_instruction({opcode, x, y, n, nn, nnn}, state)
    GenServer.cast(:screen, {:update_pixels, state.display |> Map.to_list()})
      # Continue the loop after 10 milliseconds
    Process.send_after(self(), :continue_loop, 1)

    state
  end

  def handle_info(:continue_loop, state) do
    state = loop(state)
    {:noreply, state}
  end

end
