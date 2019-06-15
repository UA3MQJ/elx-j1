defmodule J1.ALU do
  @moduledoc """
  J1 ALU Opcodes

  # http://excamera.com/files/j1.pdf

  TABLE II: ALU operation codes

  Code  Operation
    0       T
    1       N
    2      T+N
    3     TandN
    4     TorN
    5     TxorN
    6      ~T
    7      N=T
    8      N<T
    9    NrshiftT
   10      T-1
   11       R
   12      [T]
   13    NlshiftT
   14     depth
   15     Nu<T
  """

  def opcode("T"), do: 0
  def opcode("N"), do: 1
  def opcode("T+N"), do: 2
  def opcode("TandN"), do: 3
  def opcode("TorN"), do: 4
  def opcode("TxorN"), do: 5
  def opcode("~T"), do: 6
  def opcode("N=T"), do: 7
  def opcode("N<T"), do: 8
  def opcode("NrshiftT"), do: 9
  def opcode("T-1"), do: 10
  def opcode("R"), do: 11
  def opcode("[T]"), do: 12
  def opcode("NlshiftT"), do: 13
  def opcode("depth"), do: 14
  def opcode("Nu<T"), do: 15

end
