defmodule J1.CMD do
  @moduledoc """
  J1 COMMAND makers
  """

  def lit(value),    do: << 1 :: size(1), value :: size(15) >> |> bin_to_uint()
  def jmp(address),  do: << 0 :: size(1), 0 :: size(1), 0 :: size(1), address :: size(13) >> |> bin_to_uint()
  def jz(address),   do: << 0 :: size(1), 0 :: size(1), 1 :: size(1), address :: size(13) >> |> bin_to_uint()
  def call(address), do: << 0 :: size(1), 1 :: size(1), 0 :: size(1), address :: size(13) >> |> bin_to_uint()

  # http://excamera.com/files/j1.pdf
  # Table iii -  Encoding of some Forth words.
  # ============================================================================
  # ALU                                   op,    tn,    rpc,    tr,   ds, rs, nti
  # dup                                   T       v                   +1   0
  def dup(),       do: alu(J1.ALU.opcode("T"),    true, false, false, +1,  0, false) # dup
  # over                                  N       v                   +1   0
  def over(),      do: alu(J1.ALU.opcode("N"),    true, false, false, +1,  0, false) # over
  # invert                                ~T                           0   0
  def invert(),    do: alu(J1.ALU.opcode("~T"),  false, false, false,  0,  0, false) # invert
  # +                                     T+N                         -1   0
  def plus(),      do: alu(J1.ALU.opcode("T+N"), false, false, false, -1,  0, false) # +
  # swap                                  N       v                    0   0
  def swap(),      do: alu(J1.ALU.opcode("N"),    true, false, false,  0,  0, false) # swap
  # nip                                   T                           -1   0
  def nip(),       do: alu(J1.ALU.opcode("T"),   false, false, false, -1,  0, false) # nip
  # drop                                  N                           -1   0
  def drop(),      do: alu(J1.ALU.opcode("N"),   false, false, false, -1,  0, false) # drop
  # >r                                    N                     v     -1  +1
  def to_r(),      do: alu(J1.ALU.opcode("N"),   false, false,  true, -1, +1, false) # >r to_r
  # r>                                    R       v                   +1  -1    !!! tr no need!!! may be error in pdf. see http://excamera.com/files/j1demo/docforth/basewords.fs.html
  def from_r(),    do: alu(J1.ALU.opcode("R"),    true, false, false, +1, -1, false) # r> from_r
  # r@                                    R       v                   +1   0    !!! tr no need!!! may be error in pdf. see http://excamera.com/files/j1demo/docforth/basewords.fs.html
  def copy_r(),    do: alu(J1.ALU.opcode("R"),    true, false, false, +1,  0, false) # R@ copy_r
  # @                                     [T]                          0   0
  def from_addr(), do: alu(J1.ALU.opcode("[T]"), false, false, false,  0,  0, false) # @ from_addr
  # !                                     N                           -1   0
  def to_addr(),   do: alu(J1.ALU.opcode("N"),   false, false, false, -1,  0,  true) # ! to_addr
  # ;                                     T              v             0  -1
  def finish(),    do: alu(J1.ALU.opcode("T"),   false,  true, false,  0, -1, false) # ; Finishes the compilation of a colon definition

  # alu command_encode
  def alu(op, tn, rpc, tr, ds, rs, nti) do
    tn  = if (tn),  do: 1, else: 0
    tr  = if (tr),  do: 1, else: 0
    rpc = if (rpc), do: 1, else: 0
    nti = if (nti), do: 1, else: 0
    ds  = if (ds == -1), do: 3, else: ds
    rs  = if (rs == -1), do: 3, else: rs

    bin = << 3 :: size(3),
       rpc :: size(1), op :: size(4),
       tn :: size(1), tr :: size(1), nti :: size(1),
       0 :: size(1), rs :: size(2), ds :: size(2) >>

    bin_to_uint(bin)
  end

  def bin_to_uint(<< word :: integer-unsigned-16 >>), do: word
end
