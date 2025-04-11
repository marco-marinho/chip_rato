defmodule ChipRato.Converters do
  def int_to_bools(int, bit_size \\ 8) do
    for <<(bit::1 <- <<int::unsigned-integer-size(bit_size)>>)>> do
      bit == 1
    end
  end

  def byte_to_bools(<<byte::8>>) do
    for <<(bit::1 <- <<byte>>)>> do
      bit == 1
    end
  end
end
