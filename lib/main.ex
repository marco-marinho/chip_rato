defmodule ChipRato.MainLoop do

  alias ChipRato.Decoder
  alias ChipRato.State

  def run(rom_path) do
    {:ok, binary} = File.read(rom_path)
    byte_list = :binary.bin_to_list(binary)
    state = Enum.reduce(Enum.with_index(byte_list), State.new(), fn {byte, index}, state ->
      Map.put(state.memory, index + 512, byte)
    end)
    # Main loop to fetch, decode, and execute instructions
    loop(state)
  end

  defp loop(state) do
    {instruction, state} = Decoder.fetch_instruction(state.memory, state)
    {opcode, x, y, n, nn, nnn} = Decoder.decode_instruction(instruction)
    state = Decoder.execute_instruction({opcode, x, y, n, nn, nnn}, state)

    # Continue the loop with the updated state
    loop(state)
  end

end
