defmodule J1.CPU do
  @moduledoc """
  J1 CPU state
  """
  defstruct pc: 0, # 13-bit program counter
            r: [], # 32 deep × 16-bit return stack
            s: [], # 33 deep × 16-bit data stack
            rp: 0,
            sp: 0,
            mem: %{},
            memory_mapper_module: J1.MEMORYMAP,
            state: nil

  def new(), do: %J1.CPU{}
  def set_memory_mapper(j1, memory_mapper_module), do: %J1.CPU{j1 | memory_mapper_module: memory_mapper_module}
end
