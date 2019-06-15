defmodule J1.MEMORYMAP do
  @moduledoc """
  J1 CPU memory mapper module
  """
  require Logger

  def hardware_write_mem(j1, 10000, value) do
    IO.write "#{[value]}"
    j1.mem
  end

  def hardware_write_mem(j1, 10001, _value) do
    Logger.info "J1 halt"
    raise "halt"
    j1.mem
  end

  def hardware_write_mem(j1, address, value) do
    Map.merge(j1.mem, %{address => value})
  end

  def hardware_read_mem(j1, address) do
    case j1.mem[address] do
      nil -> << 0 :: integer-unsigned-16 >>
      data -> data
    end
  end

end
