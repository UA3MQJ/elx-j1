defmodule J1CMD do
  @moduledoc """
  J1 COMMAND makers
  """
  
  def lit(value),    do: << 1 :: size(1), value :: size(15) >> |> bin_to_uint()
  def jmp(address),  do: << 0 :: size(1), 0 :: size(1), 0 :: size(1), address :: size(13) >> |> bin_to_uint()
  def jz(address),   do: << 0 :: size(1), 0 :: size(1), 1 :: size(1), address :: size(13) >> |> bin_to_uint()
  def call(address), do: << 0 :: size(1), 1 :: size(1), 0 :: size(1), address :: size(13) >> |> bin_to_uint()
  
  # ALU                    op,    tn,   rpc,    tr, ds, rs,   nti
  def dup(),       do: alu( 0,  true, false, false, +1,  0, false) # dup
  def over(),      do: alu( 1,  true, false, false, +1,  0, false) # over
  def invert(),    do: alu( 6, false, false, false,  0,  0, false) # invert
  def plus(),      do: alu( 2, false, false, false, -1,  0, false) # +
  def swap(),      do: alu( 1,  true, false, false,  0,  0, false) # swap
  def nip(),       do: alu( 0, false, false, false, -1,  0, false) # nip
  def drop(),      do: alu( 1, false, false, false, -1,  0, false) # drop
  def to_r(),      do: alu( 1, false, false,  true, -1, +1, false) # >r to_r
  def from_r(),    do: alu(11,  true, false, false, +1, -1, false) # r> from_r
  def copy_r(),    do: alu(11,  true, false, false, +1,  0, false) # R@ copy_r
  def from_addr(), do: alu(12, false, false, false,  0,  0, false) # @ from_addr
  def to_addr(),   do: alu( 1, false, false, false, -1,  0,  true) # ! to_addr

  # alu command_encode
  def alu(op, tn, rpc, tr, ds, rs, nti) do
    tn  = if (tn),  do: 1, else: 0
    tr  = if (tr),  do: 1, else: 0
    rpc = if (rpc), do: 1, else: 0
    nti = if (nti), do: 1, else: 0
    ds  = if (ds == -1), do: 2, else: ds
    rs  = if (rs == -1), do: 2, else: rs

    bin = << 3 :: size(3), 
       rpc :: size(1), op :: size(4), 
       tn :: size(1), tr :: size(1), nti :: size(1),
       0 :: size(1), rs :: size(2), ds :: size(2) >>

    bin_to_uint(bin)
  end

  def bin_to_uint(<< word :: integer-unsigned-16 >>), do: word
end
