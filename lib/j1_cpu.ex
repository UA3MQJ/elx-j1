defmodule J1.CPU do
  @moduledoc """
  J1 CPU state
  """
  defstruct pc: 0, # 13-bit program counter
            # 32 deep × 16-bit return stack
            r: [],
            # 33 deep × 16-bit data stack
            s: [],
            rp: 0,
            sp: 0,
            mem: %{},
            memory_mapper_module: J1.MEMORYMAP,
            state: nil

  def new(), do: %J1.CPU{}
end
