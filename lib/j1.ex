defmodule J1CPU do
  @moduledoc """
  J1 CPU
  """
  defstruct pc: 0, # 13-bit program counter
            # 32 deep × 16-bit return stack
            r: [],
            # 33 deep × 16-bit data stack
            s: [],
            rp: 0,
            sp: 0,
            mem: %{}

  def new(), do: %J1CPU{}
end

defmodule J1CMD do
  @moduledoc """
  J1 COMMAND makers
  """
  def lit(value),    do: << 1 :: size(1), value :: size(15) >> |> to_int()
  def jmp(address),  do: << 0 :: size(1), 0 :: size(1), 0 :: size(1), address :: size(13) >> |> to_int()
  def jz(address),   do: << 0 :: size(1), 0 :: size(1), 1 :: size(1), address :: size(13) >> |> to_int()
  def call(address), do: << 0 :: size(1), 1 :: size(1), 0 :: size(1), address :: size(13) >> |> to_int()
  
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

    to_int(bin)
  end

  def to_int(<< word :: integer-unsigned-16 >>), do: word
end


defmodule J1 do
  @moduledoc """
  Documentation for J1.
  """
  use Bitwise
  require Logger

  # run
  def run(j1) do
    result = try do
      new_j1 = J1.exec(j1, hardware_read_mem(j1.mem, j1.pc))
    rescue
      _ -> :halt
    end

    case result do
      :halt -> j1
      _else -> run(result)
    end
  end

  # exec command (mem[pc])
  def exec(j1),
    do: J1.exec(j1, j1.mem[j1.pc])

  # number to binary
  def exec(j1, cmd) when is_number(cmd),
    do: exec(j1, << cmd :: integer-unsigned-16 >>)

  # literal
  def exec(j1, << 1 :: size(1), value :: size(15) >> = _cmd),
    do: %{j1 | s: [value] ++ j1.s, sp: j1.sp + 1, pc: j1.pc + 1}

  # jump
  def exec(j1, << 0 :: size(3), address :: size(13) >> = _cmd),
    do: %{j1 | pc: address}

  # conditional jump
  def exec(%{s: [0 | s_tail]} = j1, << 1 :: size(3), address :: size(13) >> = _cmd),
    do: %{j1 | s: s_tail, pc: address}
  def exec(%{s: [_ | s_tail]} = j1, << 1 :: size(3), _address :: size(13) >> = _cmd),
    do: %{j1 | s: s_tail, pc: j1.pc + 1}

  # call
  def exec(j1, << 2 :: size(3), address :: size(13) >> = _cmd),
    do: %{j1 | pc: address, rp: j1.rp + 1, r: [(j1.pc + 1)] ++ j1.r}

  # ALU
  def exec(j1, << 3 :: size(3), _word :: size(13) >> = cmd) do
    # Logger.debug "ALU cmd"
    %{pc: pc, r: r, s: s, rp: rp, sp: sp, mem: mem} = j1
    {s_t, s_n} = case s do
      [] -> {nil, nil}
      [s_t] -> {s_t, nil}
      [s_t, s_n | _] -> {s_t, s_n}
    end
    
    r_r = case r do
      [] -> nil
      r -> hd(r)
    end
    # Logger.debug "T=#{inspect s_t} N=#{inspect s_n} R=#{inspect r_r}"

    << _ :: size(3), rpc :: size(1), code :: size(4), 
       tn :: size(1), tr :: size(1), nt :: size(1),
       _ :: size(1), rstackpm :: size(2), dstackpm :: size(2) >> = cmd

    res = case code do
       0 -> s_t
       1 -> s_n
       2 -> s_t + s_n
       3 -> band(s_t, s_n)
       4 -> bor(s_t, s_n)
       5 -> bxor(s_t, s_n)
       6 -> uint16(bnot(s_t))
       7 -> if (s_n == s_t), do: 1, else: 0
       8 -> if (s_n <  s_t), do: 1, else: 0
       9 -> bsr(s_n, s_t)
      10 -> s_t - 1
      11 -> r_r
      12 -> hardware_read_mem(mem, s_t) # mem[s_t]
      13 -> bsl(s_n, s_t)
      14 -> uint16(sp) # s stack depth (глубина стека данных)
      15 -> if (uint16(s_n) < s_t), do: 1, else: 0
    end

    # Logger.debug "result = #{inspect res}"

    # dstack ±
    {s, sp} = case dstackpm do
      # sp++
      1 -> {[nil] ++ s, sp + 1}
      # sp--
      2 -> {tl(s), sp - 1}
      _else -> {s, sp}
    end
    # rstack ±
    {r, rp} = case rstackpm do
      # rp++
      1 -> {[nil] ++ r, rp + 1}
      # rp--
      2 -> {tl(r), rp - 1}
      _else -> {r, rp}
    end

    new_pc = case rpc == 1 do
      true -> r_r
      false -> pc + 1
    end

    new_s = case tn do
      1 -> # T -> N
        # Logger.debug "tn true s=#{inspect s} s_t=#{inspect s_t}"
        case s do
          [] -> []
          [_] -> [res]
          _else ->
            [_, _ | tail] = s
            [res, s_t] ++ tail
        end
      _else ->
        case s do
          [] -> [] # if s is empty when result not save to S
          _else -> [res] ++ tl(s)
        end
    end

    new_r = case tr do
      1 ->
        # Logger.debug "tr true r=#{inspect r}"
        case r do
          [] -> []
          _else -> [s_t] ++ tl(r)
        end
      _else ->
        r
    end

    new_mem = case nt==1 do
      true -> hardware_write_mem(mem, s_t, s_n)
      false -> mem
    end

    %{j1 | pc: new_pc, mem: new_mem, s: new_s, r: new_r, sp: sp, rp: rp}
  end

  def exec(_j1, cmd) do
    Logger.error "Unknown cmd=#{inspect cmd}"
  end

  def write_mem(j1, address, value),
    do: %{j1 | mem: Map.merge(j1.mem, %{address => value})}

  def read_mem(j1, address),
    do: j1.mem[address]

  def lit(j1, value),
    do: exec(j1, J1CMD.lit(value))

  def jmp(j1, address),
    do: exec(j1, J1CMD.jmp(address))

  def jz(j1, address),
    do: exec(j1, J1CMD.jz(address))

  def call(j1, address),
    do: exec(j1, J1CMD.call(address))

  # hardware memory mapping emulation

  # by default - write to internal memory
  def hardware_write_mem(mem, 10000, value) do
    IO.write "#{[value]}"
    mem
  end

  def hardware_write_mem(mem, 10001, value) do
    Logger.info "J1 halt"
    raise "halt"
    mem
  end

  def hardware_write_mem(mem, address, value),
    do: Map.merge(mem, %{address => value})

  # mem[s_t]
  def hardware_read_mem(mem, address) do
    case mem[address] do
      nil -> << 0 :: integer-unsigned-16 >>
      data -> data
    end
  end

  # utils
  def uint16(x) do
    << result :: size(16) >> = << x :: integer-unsigned-16 >>
    result
  end
end
