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
    {opcode, x, y, n, :binary.decode_unsigned(<<y::4, n::4>>), :binary.decode_unsigned(<<0::4, x::4, y::4, n::4>>)}
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
      Enum.reduce(0..n-1, {state, y_coord}, fn i, {state, y} ->
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
          nnn == 224 ->
            State.clear_display(state)

          nnn == 238 ->
            # Return from subroutine
            State.pop_stack(state)

          true ->
            state
        end

      # Set register
      0x1 ->
        State.set_pc(state, nnn)

      # Jump to subroutine
      0x2 ->
        State.push_stack(state, state.pc)
        State.set_pc(state, nnn)

      # Skip conditionally block
      0x3 ->
        if State.get_reg(state, x) == nn do
          State.increment_pc(state)
        else
          state
        end

      0x4 ->
        if State.get_reg(state, x) != nn do
          State.increment_pc(state)
        else
          state
        end

      0x5 ->
        if State.get_reg(state, x) == State.get_reg(state, y) do
          State.increment_pc(state)
        else
          state
        end

      # Jump to address
      0x6 ->
        State.set_reg(state, x, nn)

      # Add to register
      0x7 ->
        State.set_reg(state, x, rem(State.get_reg(state, x) + nn, 256))

      0x8 ->

        case n do
          0 ->
            State.set_reg(state, x, State.get_reg(state, y))
          1 ->
            State.set_reg(state, x, Bitwise.bor(State.get_reg(state, x), State.get_reg(state, y)))
          2 ->
            State.set_reg(state, x, Bitwise.band(State.get_reg(state, x), State.get_reg(state, y)))
          3 ->
            State.set_reg(state, x, Bitwise.bxor(State.get_reg(state, x), State.get_reg(state, y)))
          4 ->
            result = State.get_reg(state, x) + State.get_reg(state, y)
            carry = if result > 255, do: 1, else: 0
            State.set_reg(state, x, rem(result, 256)) |> State.set_reg(15, carry)
          5 ->
            result = State.get_reg(state, x) - State.get_reg(state, y)
            borrow = if State.get_reg(state, x) < State.get_reg(state, y), do: 0, else: 1
            State.set_reg(state, x, rem(result, 256)) |> State.set_reg(15, borrow)

        end

      # Skip conditionally
      0x9 ->
        if State.get_reg(state, x) != State.get_reg(state, y) do
          State.increment_pc(state)
        else
          state
        end

      0xA ->
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
