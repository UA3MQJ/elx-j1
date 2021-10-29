defmodule J1 do
  @moduledoc """
  Documentation for J1.
  """
  use Bitwise
  require Logger

  # run
  def run(j1) do
    result = try do
      pc_hex = Integer.to_string(j1.pc, 16)
      Logger.debug ">>> j1.pc=0x#{pc_hex}"
      :timer.sleep(1000)
      J1.exec(j1)
    rescue
      _ -> :halt
    end

    case result do
      :halt -> %{j1 | state: :halted}
      _else -> run(result)
    end
  end

  def dump(_, _, 0), do: :ok
  def dump(j1, start, size) do
    address = start
    address_hex = address
      |> Integer.to_string(16)
      |> String.pad_leading(4, "0000")
    data = hardware_read_mem(j1, start)

    data_hex = data
    |> Integer.to_string(16)
    |> String.pad_leading(4, "0000")

    data_bin = data
    |> Integer.to_string(2)
    |> String.pad_leading(16, "0000000000000000")

    opcode = decode(<< data :: integer-unsigned-16 >>)

    Logger.debug ">>>> #{address_hex}:#{data_hex} (#{data_bin}) - #{opcode}"
    dump(j1, start+1, size-1)
  end

  def decode(data) when is_number(data),
    do: decode(<< data :: integer-unsigned-16 >>)

  def decode(<< 1 :: size(1), value :: size(15) >> = _cmd) do
    value_hex = value
    |> Integer.to_string(16)
    |> String.pad_leading(4, "0000")
    "literal #{value} (#{value_hex}h)"
  end

  def decode(<< 0 :: size(3), address :: size(13) >> = _cmd) do
    address_hex = address
    |> Integer.to_string(16)
    |> String.pad_leading(4, "0000")
    "jump #{address} (#{address_hex}h)"
  end

  def decode(<< 1 :: size(3), address :: size(13) >> = _cmd) do
    address_hex = address
    |> Integer.to_string(16)
    |> String.pad_leading(4, "0000")
    "conditional jump #{address} (#{address_hex}h)"
  end

  def decode(<< 2 :: size(3), address :: size(13) >> = _cmd) do
    address_hex = address
    |> Integer.to_string(16)
    |> String.pad_leading(4, "0000")
    "call #{address} (#{address_hex}h)"
  end

  def decode(<< 3 :: size(3), _word :: size(13) >> = cmd) do

    << _ :: size(3), rpc :: size(1), code :: size(4),
       tn :: size(1), tr :: size(1), nt :: size(1),
       _ :: size(1), rstackpm :: size(2), dstackpm :: size(2) >> = cmd

    # dstackpm==3 = -1
    # dstackpm==1 = +1
    cond do
      code==0 and tn==1 and dstackpm==1 ->
        "alu DUP"
      code==1 and tn==1 and dstackpm==1 ->
        "alu OVER"
      code==6 ->
        "alu INVERT"
      code==2 and dstackpm==3 ->
        "alu +"
      code==1 and tn==1 ->
        "alu SWAP"
      code==0 and dstackpm==3 ->
        "alu NIP"
      code==1 and dstackpm==3 ->
        "alu DROP"
      code==0 and rpc==1 and rstackpm==3 ->
        "alu ;"
      code==1 and tr==1 and dstackpm==3 and dstackpm==1 ->
        "alu >R"
      code==11 and tr==1 and tn==1 and dstackpm==1 and rstackpm==3 ->
        "alu R>"
      code==11 and tr==1 and tn==1 and dstackpm==1 ->
        "alu R@"
      code==12 ->
        "alu @"
      code==1 and dstackpm==3 and nt==1 ->
        "alu !"

      true ->
        # Logger.debug ">>> code=#{code} dstackpm=#{dstackpm}"
        case code do
          0 -> "alu T"
          1 -> "alu N"
          2 -> "alu T + N"
          3 -> "alu T and N"
          4 -> "alu T or N"
          5 -> "alu T xor N"
          6 -> "alu ~T"
          7 -> "alu N = T"
          8 -> "alu N < T"
          9 -> "alu N rshift T"
         10 -> "alu T - 1"
         11 -> "alu R"
         12 -> "alu [T]"
         13 -> "alu NlshiftT"
         14 -> "alu depth"
         15 -> "alu Nu<T"
        end
    end
  end


  def decode(_),
    do: "?"


  # exec command (mem[pc])
  def exec(j1),
    do: J1.exec(j1, hardware_read_mem(j1, j1.pc))

  # number to binary
  def exec(j1, cmd) when is_number(cmd),
    do: exec(j1, << cmd :: integer-unsigned-16 >>)

  # literal
  # def exec(j1, << 1 :: size(1), value :: size(15) >> = _cmd),
  #   do: %{j1 | s: [value] ++ j1.s, sp: j1.sp + 1, pc: j1.pc + 1}
  def exec(j1, << 1 :: size(1), value :: size(15) >> = _cmd) do
    Logger.debug ">>>>>> literal #{value}"
    %{j1 | s: [value] ++ j1.s, sp: j1.sp + 1, pc: j1.pc + 1}
  end

  # jump
  # def exec(j1, << 0 :: size(3), address :: size(13) >> = _cmd),
  #   do: %{j1 | pc: address}
  def exec(j1, << 0 :: size(3), address :: size(13) >> = _cmd) do
    address_hex = Integer.to_string(address, 16)
    Logger.debug ">>>>>> jump #{address_hex}"
    %{j1 | pc: address}
  end

  # conditional jump
  # def exec(%{s: [0 | s_tail]} = j1, << 1 :: size(3), address :: size(13) >> = _cmd),
  #   do: %{j1 | s: s_tail, pc: address}
  # def exec(%{s: [_ | s_tail]} = j1, << 1 :: size(3), _address :: size(13) >> = _cmd),
  #   do: %{j1 | s: s_tail, pc: j1.pc + 1}
  def exec(%{s: [0 | s_tail]} = j1, << 1 :: size(3), address :: size(13) >> = _cmd) do
    address_hex = Integer.to_string(address, 16)
    Logger.debug ">>>>>> conditional jump #{address_hex} // true"
    %{j1 | s: s_tail, pc: address}
  end
  def exec(%{s: [_ | s_tail]} = j1, << 1 :: size(3), _address :: size(13) >> = _cmd) do
    address_hex = Integer.to_string(j1.pc + 1, 16)
    Logger.debug ">>>>>> conditional jump #{address_hex} // false"
    %{j1 | s: s_tail, pc: j1.pc + 1}
  end

  # call
  # def exec(j1, << 2 :: size(3), address :: size(13) >> = _cmd),
  #   do: %{j1 | pc: address, rp: j1.rp + 1, r: [(j1.pc + 1)] ++ j1.r}
  def exec(j1, << 2 :: size(3), address :: size(13) >> = _cmd) do
    address_hex = Integer.to_string(address, 16)
    Logger.debug ">>>>>> call #{address_hex}"
    %{j1 | pc: address, rp: j1.rp + 1, r: [(j1.pc + 1)] ++ j1.r}
  end

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
      12 -> hardware_read_mem(j1, s_t) # mem[s_t]
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
      3 -> {tl(s), sp - 1}
      _else -> {s, sp}
    end
    # rstack ±
    {r, rp} = case rstackpm do
      # rp++
      1 -> {[nil] ++ r, rp + 1}
      # rp--
      3 -> {tl(r), rp - 1}
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
      true -> hardware_write_mem(j1, s_t, s_n)
      false -> mem
    end

    # dstackpm==3 = -1
    # dstackpm==1 = +1
    cond do
      code==0 and tn==1 and dstackpm==1 ->
        Logger.debug ">>>>>> alu DUP"
      code==1 and tn==1 and dstackpm==1 ->
        Logger.debug ">>>>>> alu OVER"
      code==6 ->
        Logger.debug ">>>>>> alu INVERT"
      code==2 and dstackpm==3 ->
        Logger.debug ">>>>>> alu +"
      code==1 and tn==1 ->
        Logger.debug ">>>>>> alu SWAP"
      code==0 and dstackpm==3 ->
        Logger.debug ">>>>>> alu NIP"
      code==1 and dstackpm==3 and nt==0 ->
        Logger.debug ">>>>>> alu DROP"
      code==0 and rpc==1 and rstackpm==3 ->
        Logger.debug ">>>>>> alu ;"
      code==1 and tr==1 and dstackpm==3 and rstackpm==1 ->
        Logger.debug ">>>>>> alu >R"
      code==11 and tr==1 and tn==1 and dstackpm==1 and rstackpm==3 ->
        Logger.debug ">>>>>> alu R>"
      code==11 and tr==1 and tn==1 and dstackpm==1 ->
        Logger.debug ">>>>>> alu R@"
      code==12 ->
        Logger.debug ">>>>>> alu @"
      code==1 and dstackpm==3 and nt==1 ->
        Logger.debug ">>>>>> alu !"

      true ->
        case code do
          0 -> Logger.debug ">>>>>> alu T"
          1 -> Logger.debug ">>>>>> alu N"
          2 -> Logger.debug ">>>>>> alu T + N"
          3 -> Logger.debug ">>>>>> alu T and N"
          4 -> Logger.debug ">>>>>> alu T or N"
          5 -> Logger.debug ">>>>>> alu T xor N"
          6 -> Logger.debug ">>>>>> alu ~T"
          7 -> Logger.debug ">>>>>> alu N = T"
          8 -> Logger.debug ">>>>>> alu N < T"
          9 -> Logger.debug ">>>>>> alu N rshift T"
         10 -> Logger.debug ">>>>>> alu T - 1"
         11 -> Logger.debug ">>>>>> alu R"
         12 -> Logger.debug ">>>>>> alu [T]"
         13 -> Logger.debug ">>>>>> alu NlshiftT"
         14 -> Logger.debug ">>>>>> alu depth"
         15 -> Logger.debug ">>>>>> alu Nu<T"
        end
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
    do: exec(j1, J1.CMD.lit(value))

  def jmp(j1, address),
    do: exec(j1, J1.CMD.jmp(address))

  def jz(j1, address),
    do: exec(j1, J1.CMD.jz(address))

  def call(j1, address),
    do: exec(j1, J1.CMD.call(address))

  # hardware memory mapping emulation
  def hardware_write_mem(j1, address, value),
    do: j1.memory_mapper_module.hardware_write_mem(j1, address, value)
  def hardware_read_mem(j1, address),
    do: j1.memory_mapper_module.hardware_read_mem(j1, address)

  # utils
  def uint16(x) do
    << result :: size(16) >> = << x :: integer-unsigned-16 >>
    result
  end
end
