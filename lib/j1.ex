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

defmodule J1 do
  @moduledoc """
  Documentation for J1.
  """
  use Bitwise
  require Logger

  # literal
  def exec(j1, << 1 :: size(1), value :: size(15) >> = _cmd) do
    %{j1 | s: [value] ++ j1.s, sp: j1.sp + 1, pc: j1.pc + 1}
  end

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
      12 -> mem[s_t]
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
      true -> Map.merge(mem, %{s_t => s_n})
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
    do: exec(j1, << 1 :: size(1), value :: size(15) >>)

  def jmp(j1, address),
    do: exec(j1, << 0 :: size(1), 0 :: size(1), 0 :: size(1), address :: size(13) >> )

  def jz(j1, address),
    do: exec(j1, << 0 :: size(1), 0 :: size(1), 1 :: size(1), address :: size(13) >> )

  def call(j1, address),
    do: exec(j1, << 0 :: size(1), 1 :: size(1), 0 :: size(1), address :: size(13) >> )

  def uint16(x) do
    << result :: size(16) >> = << x :: integer-unsigned-16 >>
    result
  end
end
