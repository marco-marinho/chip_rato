defmodule ChipRato.State do
  defstruct pc: 0, register: %{}, memory: %{}, display: %{}, stack: [], index: 0

  def new() do
    %ChipRato.State{
      pc: 0,
      register:
        Enum.reduce(0..15, %{}, fn i, acc ->
          Map.put(acc, i, 0)
        end),
      memory:
        Enum.reduce(0..4096, %{}, fn i, acc ->
          Map.put(acc, i, 0)
        end),
      display: for(x <- 0..63, y <- 0..31, into: %{}, do: {{x, y}, false}),
      stack: [],
      index: 0
    }
  end

  defp pixel_update(curr, new, vf) do
    case {curr, new} do
      {true, true} -> {false, 1}
      {false, true} -> {true, vf}
      {true, false} -> {true, vf}
      {false, false} -> {false, vf}
    end
  end

  def set_pixel(state, x, y, val) do
    if x > 63 or y > 31 do
      state
    end

    {new_pixel, vf} =
      pixel_update(Map.get(state.display, {x, y}), val, Map.get(state.register, 0xF))

    %ChipRato.State{
      state
      | register: Map.put(state.register, 0xF, vf),
        display: Map.put(state.display, {x, y}, new_pixel)
    }
  end

  def push_stack(state, nnn) do
    %ChipRato.State{state | stack: [nnn | state.stack]}
  end

  def pop_stack(state) do
    [nnn | stack] = state.stack
    %ChipRato.State{state | stack: stack , pc: nnn}
  end

  def set_memory(state, address, value) do
    %ChipRato.State{state | memory: Map.put(state.memory, address, value)}
  end

  def get_memory(state, address) do
    <<Map.get(state.memory, address)::8>>
  end

  def increment_pc(state) do
    %ChipRato.State{state | pc: state.pc + 2}
  end

  def set_pc(state, nnn) do
    %ChipRato.State{state | pc: nnn}
  end

  def set_reg(state, x, value) do
    %ChipRato.State{state | register: Map.put(state.register, x, value)}
  end

  def get_reg(state, x) do
    Map.get(state.register, x)
  end

  def set_index(state, nnn) do
    %ChipRato.State{state | index: nnn}
  end

  def clear_display(state) do
    display = for x <- 0..63, y <- 0..31, into: %{}, do: {{x, y}, false}
    %ChipRato.State{state | display: display}
  end
end
