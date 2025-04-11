defmodule ChipRato.Decoder do
  alias ChipRato.State
  alias ChipRato.Converters

  def fetch_instruction(memory, state) do
    # Fetch the instruction from memory at the program counter (pc)
    <<instruction::16>> = <<Map.get(memory, state.pc)::8, Map.get(memory, state.pc + 1)::8>>
    {instruction, State.increment_pc(state)}
  end

  def decode_instruction(instruction) do
    # Decode the instruction into opcode and operands
    <<opcode::4, x::4, y::4, n::4>> = <<instruction::16>>
    {opcode, x, y, n, <<y::4, n::4>>, <<x::4, y::4, n::4>>}
  end

  def draw_byte(state, x, y, p) do
    sprite = State.get_memory(state, p)
    sprite_bools = Converters.byte_to_bools(sprite)

    {new_state, _} =
      Enum.reduce(sprite_bools, {state, x}, fn bit, {state, coord} ->
        {State.set_pixel(state, coord, y, bit), coord + 1}
      end)

    new_state
  end

  def draw(state, x, y, n) do
    # Draw the sprite at the specified coordinates
    x_coord = rem(State.get_reg(state, x), 64)
    y_coord = rem(State.get_reg(state, y), 32)

    {state, _} =
      Enum.reduce(0..n, {state, y_coord}, fn i, {state, y} ->
        state = draw_byte(state, x_coord, y, i + state.index)
        {state, y + 1}
      end)

    state
  end

  def execute_instruction({opcode, x, y, n, nn, nnn}, state) do
    # Execute the instruction based on the opcode and operands
    case opcode do
      0x0 ->
        cond do
          x == 0x0 && y == 0xE && n == 0x0 ->
            State.clear_display(state)

          true ->
            state
        end

      # Set register
      0x1 ->
        State.set_pc(state, nnn)

      # Jump to address
      0x6 ->
        State.set_reg(state, x, nn)

      # Add to register
      0x7 ->
        State.set_reg(state, x, State.get_reg(state, x) + nn)

      OxA ->
        State.set_index(state, nnn)

      # Draw sprite
      0xD ->
        draw(state, x, y, n)

      # Unknown opcode, no operation
      _ ->
        state
    end
  end

  def decode(memory, state) do
    # Fetch the instruction from memory
    {instruction, state} = fetch_instruction(memory, state.pc)

    # Decode the instruction
    decoded_instruction = decode_instruction(instruction)

    # Update the state based on the opcode and operands
    new_state = execute_instruction(decoded_instruction, state)

    # Return the new state
    new_state
  end
end
