defmodule J1CPU do
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
            state: nil

  def new(), do: %J1CPU{}
end
