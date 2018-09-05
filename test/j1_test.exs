defmodule J1Test do
  use ExUnit.Case
  require Logger
  doctest J1

  test "literal" do
    j1 = J1CPU.new

    j1 = J1.lit(j1, 5)
    assert %{s: [5], sp: 1, pc: 1} = j1

    j1 = J1.lit(j1, 6)
    assert %{s: [6, 5], sp: 2, pc: 2} = j1
  end

  test "jump" do
    j1 = J1CPU.new
    |> J1.jmp(5)
    assert %{pc: 5} = j1
  end

  test "conditional jump" do
    j1 = J1CPU.new
    |> J1.lit(0)
    |> J1.lit(1)

    assert %{s: [1, 0], sp: 2, pc: 2} = j1

    # no jump
    j1 = J1.jz(j1, 6)
    assert %{pc: 3} = j1

    # jump
    j1 = J1.jz(j1, 6)
    assert %{pc: 6} = j1
  end

  test "call" do
    j1 = J1CPU.new
    |> J1.call(7)
    assert %{pc: 7, r: [1]} = j1
  end

  # http://excamera.com/files/j1.pdf
  # Table iii -  Encoding of some Forth words.
  # word      op,  tn, rpc, tr, ds, rs, nti
  # dup        T    v           +1   0
  # over       N    v           +1   0
  # invert    ~T                -1   0
  # +         T+N               -1   0
  # swap       N    v            0   0
  # nip        T                -1   0
  # drop       N                -1   0
  # ;          T        v        0  -1
  # >r         N             v  -1  +1
  # r>         R    v           +1  -1    !!! tr no need!!! may be error in pdf. see http://excamera.com/files/j1demo/docforth/basewords.fs.html
  # r@         R    v           +1   0    !!! tr no need!!! may be error in pdf. see http://excamera.com/files/j1demo/docforth/basewords.fs.html
  # @         [T]                0   0
  # !          N                -1   0

  # dup and test of d+1 logic
  # ( x -- x x )
  # Duplicate x
  test "dup" do
    #            op,    tn,   rpc,    tr, ds, rs,   nti
    dup_cmd = op( 0,  true, false, false, +1,  0, false)

    j1 = J1CPU.new
    |> J1.lit(1)
    |> J1.exec(dup_cmd)

    # Logger.debug "dup j1=#{inspect j1}"
    assert %{s: res, pc: 2} = j1
    assert res == [1, 1]
  end

  # over
  # ( x1 x2 -- x1 x2 x1 )
  # Place a copy of x1 on top of the stack.
  test "over" do
    #             op,    tn,   rpc,    tr, ds, rs,   nti
    over_cmd = op( 1,  true, false, false, +1,  0, false)

    j1 = J1CPU.new
    |> J1.lit(1)
    |> J1.lit(2)
    |> J1.exec(over_cmd)

    # Logger.debug "over j1=#{inspect j1}"
    assert %{s: [1, 2, 1], sp: 3, pc: 3} = j1
  end

  # invert
  # ( x1 -- x2 )
  # Invert all bits of x1, giving its logical inverse x2.
  test "invert" do
    #               op,    tn,   rpc,    tr, ds, rs,   nti
    invert_cmd = op( 6, false, false, false,  0,  0, false)

    j1 = J1CPU.new
    |> J1.lit(0)
    |> J1.exec(invert_cmd)

    # Logger.debug "invert j1=#{inspect j1}"
    assert %{s: [65535], sp: 1, pc: 2} = j1
  end

  # + and test of d-1 logic
  test "plus" do
    #             op,    tn,   rpc,    tr, ds, rs,   nti
    plus_cmd = op( 2, false, false, false, -1,  0, false)

    j1 = J1CPU.new
    |> J1.lit(1)
    |> J1.lit(2)
    |> J1.exec(plus_cmd)

    # Logger.debug "plus j1=#{inspect j1}"
    assert %{s: [res], pc: 3} = j1
    assert res == 3
  end

  # swap ( x1 x2 -- x2 x1 )
  # Exchange the top two stack items.
  test "swap" do
    #             op,    tn,   rpc,    tr, ds, rs,   nti
    swap_cmd = op( 1,  true, false, false,  0,  0, false)

    j1 = J1CPU.new
    |> J1.lit(1)
    |> J1.lit(2)
    |> J1.exec(swap_cmd)

    # Logger.debug "swap j1=#{inspect j1}"
    assert %{s: s, sp: 2, pc: 3} = j1
    assert s == [1, 2]
  end

  # nip ( x1 x2 -- x2 )
  # Drop the first item below the top of stack.
  test "nip" do
    #            op,    tn,   rpc,    tr, ds, rs,   nti
    nip_cmd = op( 0, false, false, false, -1,  0, false)

    j1 = J1CPU.new
    |> J1.lit(1)
    |> J1.lit(2)
    |> J1.exec(nip_cmd)

    # Logger.debug "nip j1=#{inspect j1}"
    assert %{s: [2], sp: 1, pc: 3} = j1
  end

  # drop
  # ( x -- )
  # Remove x from the stack.
  test "drop" do
    #             op,    tn,   rpc,    tr, ds, rs,   nti
    drop_cmd = op( 1, false, false, false, -1,  0, false)

    j1 = J1CPU.new
    |> J1.lit(1)
    |> J1.lit(2)
    |> J1.exec(drop_cmd)

    # Logger.debug "drop j1=#{inspect j1}"
    assert %{s: [1], sp: 1, pc: 3} = j1
  end

  # >r and r+1 test
  # ( x -- ) ( R: -- x )
  # Move x to the return stack.
  test "to r" do
    #             op,    tn,   rpc,    tr, ds, rs,   nti
    tor_cmd = op( 1, false, false,  true, -1, +1, false)

    j1 = J1CPU.new
    |> J1.lit(1)
    |> J1.exec(tor_cmd)

    # Logger.debug ">r j1=#{inspect j1}"
    assert %{s: [], sp: 0, r: [1], rp: 1, pc: 2} = j1
  end

  # r> and r-1 test
  # ( -- x ) ( R: x -- )
  # Move x from the return stack to the data stack.
  test "from r" do
    #             op,    tn,   rpc,    tr, ds, rs,   nti
    tor_cmd = op( 1, false, false,  true, -1, +1, false)

    #              op,    tn,   rpc,    tr, ds, rs,   nti
    fromr_cmd = op(11, true, false, false, +1, -1, false)

    j1 = J1CPU.new
    |> J1.lit(1)
    |> J1.exec(tor_cmd)
    |> J1.exec(fromr_cmd)

    # Logger.debug "r> j1=#{inspect j1}"
    assert %{s: [1], sp: 1, r: [], rp: 0, pc: 3} = j1
  end

  # R@
  # ( -- x ) ( R: x -- x )
  # Copy x from the return stack to the data stack.
  test "copy r" do
    #             op,    tn,   rpc,    tr, ds, rs,   nti
    tor_cmd = op( 1, false, false,  true, -1, +1, false)

    #              op,    tn,   rpc,    tr, ds, rs,   nti
    copyr_cmd = op(11,  true, false, false, +1,  0, false)

    j1 = J1CPU.new
    |> J1.lit(1)
    |> J1.exec(tor_cmd)
    |> J1.exec(copyr_cmd)

    # Logger.debug "R@ j1=#{inspect j1}"
    assert %{s: [1], sp: 1, r: [1], rp: 1, pc: 3} = j1
  end

  # @
  # ( a-addr -- x )
  # x is the value stored at a-addr.
  test "get a-addr" do
    #             op,    tn,   rpc,    tr, ds, rs,   nti
    addr_cmd = op(12, false, false, false,  0,  0, false)

    j1 = J1CPU.new
    |> J1.write_mem(1, 22)
    |> J1.lit(1)
    |> J1.exec(addr_cmd)

    # Logger.debug "@ j1=#{inspect j1}"
    assert %{s: [22], sp: 1, r: [], rp: 0, pc: 2} = j1
  end

  # !
  # ( x a-addr -- )
  # Store x at a-addr.
  test "set a-addr" do
    #             op,    tn,   rpc,    tr, ds, rs,   nti
    addr_cmd = op( 1, false, false, false, -1,  0,  true)

    j1 = J1CPU.new
    |> J1.lit(1)
    |> J1.lit(2)
    |> J1.exec(addr_cmd)

    # Logger.debug "! j1=#{inspect j1}"
    assert %{mem: %{2 => 1}, s: [1], sp: 1, r: [], rp: 0, pc: 3} = j1
    assert J1.read_mem(j1, 2) == 1
  end

  def op(op, tn, rpc, tr, ds, rs, nti) do
    tn  = if (tn),  do: 1, else: 0
    tr  = if (tr),  do: 1, else: 0
    rpc = if (rpc), do: 1, else: 0
    nti = if (nti), do: 1, else: 0
    ds  = if (ds == -1), do: 2, else: ds
    rs  = if (rs == -1), do: 2, else: rs

    << 3 :: size(3), 
       rpc :: size(1), op :: size(4), 
       tn :: size(1), tr :: size(1), nti :: size(1),
       0 :: size(1), rs :: size(2), ds :: size(2) >>
  end
end
