defmodule J1AsmTest do
  use ExUnit.Case
  require Logger
  doctest J1

  # mix test --only prog_test
  @tag prog_test: true

  test "prog" do


    # # j1_2 = J1.CPU.new()
    # # |> J1.CPU.set_memory_mapper(J1.MEMORYMAP2)

    # # {:ok, data} =  File.read("./toolchain/source.asm")
    # # lines = String.split(data, "\n")

    # # Logger.debug ">>>> lines=#{inspect lines}"

    # # state = %{addr: 0, mem: %{},}

    # # result = parse(lines, state)
    # # Logger.debug ">>>> result=#{inspect result}"

    time1 = :os.system_time(:millisecond)
    {:ok, _} = :leex.file('./priv/asm_lexer.xrl')
    time2 = :os.system_time(:millisecond)
    {:ok, :asm_lexer} = :c.c('./priv/asm_lexer.erl')
    time3 = :os.system_time(:millisecond)

    Logger.debug "Leex - generate erl time = #{time2 - time1} ms"
    Logger.debug "Compile erl time = #{time3 - time2} ms"

    time1 = :os.system_time(:millisecond)
    {:ok, _} = :yecc.file('./priv/asm_parser.yrl', [verbose: true])
    time2 = :os.system_time(:millisecond)
    {:ok, :asm_parser} = :c.c('./priv/asm_parser.erl')
    time3 = :os.system_time(:millisecond)

    Logger.debug "Yecc - generate erl time = #{time2 - time1} ms"
    Logger.debug "Compile erl time = #{time3 - time2} ms"

    # {:ok, tokens, _} = :asm_lexer.string('  org   100 ; 123 org jmp "123" LIT jz call alu comment  \n')
    # Logger.debug ">>>>>>>> tokens = #{inspect tokens}"
    # {:ok, res} = :asm_parser.parse(tokens)
    # Logger.debug ">>>>>>>>>> res=#{inspect res}"

    # src = """
    # label '":'
    # label "label:"
    # label "label1:"
    # label "label_1:"
    # label "label-1:"
    # label "_label1:"
    # label "+:"
    # label ";:"
    # label ">r:"
    # label "r>:"
    # label "r@:"
    # label "!:"
    # label "#:"
    # label "S:"
    # label "#>:"
    # label "[:"
    # label "}:"
    # label "{:"
    # label "':"
    # label "/:"
    # label "\\:"
    # label "*/:"
    # label "0<:"
    # label "0=:"
    # label "1+:"
    # label "1-:"
    # label "::"
    # label ";:"
    # label ">:"
    # label "<:"
    # label "=:"
    # label "?:"
    # label ".:"
    # label ",:"
    # label "':"
    # label "[]:"
    # """
    # IO.puts(src)
    # {:ok, tokens, _} = :asm_lexer.string(String.to_charlist(src))
    # Logger.debug ">>>>>>>>>> tokens=#{inspect tokens}"
    # assert [:string, :t_label, :t_next_str] = tokens
    # |> Enum.map(fn({t,_,_}) -> t end)
    # |> Enum.group_by(&(&1))
    # |> Map.keys()


    # src = """
    #       label "321"
    #             lit 123
    #             org 100 ; start addr

    #             org 200    ; 123 org jmp "123" LIT jz call alu comment
    #             org 300
    #             org 10h

    #             lit 120
    #             jmp 10h
    #             jz     20h
    #             call 111
    #             jmp "321"
    #             jz     "321"
    #             call "321"
    # """

    # {:ok, tokens, _} = :asm_lexer.string(String.to_charlist(src))
    # Logger.debug ">>>>>>>>>> tokens=#{inspect tokens}"
    # {:ok, res} = :asm_parser.parse(tokens)
    # Logger.debug ">>>>>>>>>> res=#{inspect res}"

    # src = """
    #             org 200    ; 123 org jmp "123" LIT jz call alu comment
    #       label "winth ; inside" ; 123 org jmp "123" LIT jz call
    #       label "321"
    #             lit 123
    #             org 100 ; start addr

    #             org 200    ; 123 org jmp "123" LIT jz call alu comment
    #             org 300
    #             org 10h

    #             lit 120
    #             jmp 10h
    #             jz     20h
    #             call 111
    #             jmp "321"
    #             jz     "321"
    #             call "321"
    # """

    # {:ok, tokens, _} = :asm_lexer.string(String.to_charlist(src))
    # Logger.debug ">>>>>>>>>> tokens=#{inspect tokens}"
    # {:ok, res} = :asm_parser.parse(tokens)
    # Logger.debug ">>>>>>>>>> res=#{inspect res}"

    # src = """
    #     alu 100
    #     alu 100h


    #     alu x
    #     alu x y
    #     alu x y z

    #     alu T        ; h# 0000 ;
    #     alu N        ; h# 0100 ;
    #     alu T+N      ; h# 0200 ;
    #     alu T&N      ; h# 0300 ;
    #     alu T|N      ; h# 0400 ;
    #     alu T^N      ; h# 0500 ;
    #     alu ~T       ; h# 0600 ;
    #     alu N==T     ; h# 0700 ;
    #     alu N<T      ; h# 0800 ;
    #     alu N>>T     ; h# 0900 ;
    #     alu T-1      ; h# 0a00 ;
    #     alu rT       ; h# 0b00 ;
    #     alu [T]      ; h# 0c00 ;
    #     alu N<<T     ; h# 0d00 ;
    #     alu dsp      ; h# 0e00 ;
    #     alu Nu<T     ; h# 0f00 ;

    # """

    # # alu opcodes flags test
    # src ="""
    #   alu TorN TandN TxorN d+1 d-1 r+1 r-1 N->[T] T->R T->N R->PC Nu<T N<<T [T] T-1 N>>T N<T N==T ~T T^N T|N T&N T+N T N rT dsp
    # """
    # {:ok, tokens, _} = :asm_lexer.string(String.to_charlist(src))
    # Logger.debug ">>>>>>>>>> tokens=#{inspect tokens}"
    # {:ok, res} = :asm_parser.parse(tokens)
    # Logger.debug ">>>>>>>>>> res=#{inspect res}"

    # # alu opcodes flags test
    src ="""
          org 100
          lit 48               ; lit 48
          label "write to console"
          lit 10000            ; lit 10000
          alu N N->[T] d-1     ; ! to_addr do: alu(J1.ALU.opcode("N"),   false, false, false, -1,  0,  true) # ! to_addr
          lit 1                ; lit 1
          alu T+N d-1          ; +
          alu T T->N d+1       ; dup
          lit 58               ; lit 58
          alu TxorN d-1        ; XOR - give 0 when equal
          jz  "halt"
          jmp "write to console"
          label "halt"
          lit 10001            ; halt
          alu N N->[T] d-1     ; ! to_addr
          label "alu ops"
          alu T T->N d+1       ; dup
          alu N T->N d+1       ; over
          alu ~T               ; invert
          alu T+N d-1          ; +
          alu N T->N           ; swap
          alu T d-1            ; nip
          alu N d-1            ; drop
          alu T R->PC r-1      ; ;
          alu N T->R d-1 r+1      ; >r
          alu R T->N T->R d+1 r-1 ; r>
          alu R T->N T->R d+1     ; r@
          alu [T]                 ; @
          alu N d-1 N->[T]        ; !
          """

    {:ok, tokens, _} = :asm_lexer.string(String.to_charlist(src))
    # Logger.debug ">>>>>>>>>> tokens=#{inspect(tokens, limit: :infinity)}"
    {:ok, res} = :asm_parser.parse(tokens)
    # Logger.debug ">>>>>>>>>> res=#{inspect res, limit: :infinity}"

    cstate = %{address_pointer: 0, labels: %{}, mem: %{}}

    # pass 1 - get commands, get labels
    result = res
    |> Enum.reduce(cstate, fn token, acc ->
      %{address_pointer: address_pointer, labels: labels, mem: mem} = acc
      new_address_pointer = cond do
        is_command(token) -> address_pointer + 1
        is_org(token) -> get_org_addr(token)
        true -> address_pointer
      end

      new_labels = cond do
        is_label(token) -> Map.merge(labels, %{get_label_name(token) => address_pointer})
        true -> labels
      end

      new_mem = cond do
        is_command(token) -> Map.merge(mem, %{address_pointer => token})
        true -> mem
      end

      %{acc | address_pointer: new_address_pointer, labels: new_labels, mem: new_mem}
    end)

    # pass 2
    mem = result.mem
    _addresses = mem
    |> Map.keys()
    |> Enum.sort()

    _new_mem = Enum.reduce(mem, mem, fn({addr, token}, acc) ->
      dump(addr, token, result)
      case is_command_has_label(token) do
        true ->
          # Logger.debug ">>> addr=#{inspect addr} token=#{inspect token}"
          label_addr = result.labels[get_command_label(token)]
          Map.merge(acc, %{addr => cmd_set_addr(token, label_addr)})
        _false ->
          # Logger.debug ">>> addr=#{inspect addr} token=#{inspect token}"
          acc
      end
    end)


    # Logger.debug ">>>>>>>>>> new_mem = #{inspect new_mem}"
    # Enum.map(addresses, fn(addr) ->
    #   Logger.debug ">>>>>>>>>> #{addr} - #{inspect new_mem[addr]}"
    # end)

  end

  def is_command({:lit, _, _}),  do: true
  def is_command({:jz, _, _}),   do: true
  def is_command({:jmp, _, _}),  do: true
  def is_command({:call, _, _}), do: true
  def is_command({:alu, _, _}),  do: true
  def is_command(_else),         do: false

  def is_command_has_label({_, _, {:label, _}}), do: true
  def is_command_has_label(_else), do: false
  def get_command_label({_, _, {:label, label_name}}), do: label_name
  def get_command_label(_), do: nil

  def is_label({:label, _, _}), do: true
  def is_label(_else),          do: false
  def get_label_name({:label, _, label_name}), do: label_name
  def get_label_name(_), do: nil

  def is_org({:org, _, _}), do: true
  def is_org(_else),        do: false
  def get_org_addr({:org, _, addr}), do: addr
  def get_org_addr(_), do: nil

  def cmd_set_addr({cmd, str, {:label, _}}, addr), do: {cmd, str, {:addr, addr}}
  def cmd_set_addr(cmd, _), do: cmd


  def dump(addr, {:lit, _, value} = _token, result) do
    # label_addr = result.labels[get_command_label(token)]
    str = "LIT  #{to_hex(value)}; #{value}"
    Logger.debug ">>> #{addr_to_hex(result, addr)} #{str}"
  end
  def dump(addr, {:jz, _, {:label, _label_name}} = token, result) do
    label_addr = result.labels[get_command_label(token)]
    # str = "JZ   #{to_hex(label_addr)}"
    str = case addr_to_label(result.labels, label_addr) do
      nil ->
        "JZ  ? ; ERROR LABEL!"
      label ->
        "JZ   #{inspect label}; addr = #{to_hex(label_addr)}"
    end
    Logger.debug ">>> #{addr_to_hex(result, addr)} #{str}"
  end
  def dump(addr, {:jmp, _, {:label, _label_name}} = token, result) do
    label_addr = result.labels[get_command_label(token)]
    str = case addr_to_label(result.labels, label_addr) do
      nil ->
        "JMP ? ; ERROR LABEL!"
      label ->
        "JMP  #{inspect label}; addr = #{to_hex(label_addr)}"
    end
    Logger.debug ">>> #{addr_to_hex(result, addr)} #{str}"
  end
  def dump(addr, {:alu, _, {:word, word}} = _token, result) do
    str = inspect_alu(word)
    # String.pad_trailing("abc", 30, " ")
    Logger.debug ">>> #{addr_to_hex(result, addr)} #{str}"
  end
  def dump(addr, token, result) do
    str = "token=#{inspect token}"
    # String.pad_trailing("abc", 30, " ")
    Logger.debug ">>> #{addr_to_hex(result, addr)} #{str}"
  end

  def label_to_addr(labels, label),
    do: labels |> Map.get(label)

  # def addr_to_label(labels, addr),
  #   do: Logger.debug ">>> #{inspect labels} #{inspect addr}"

  def addr_to_label(labels, addr),
    do: labels |> Enum.map(fn({k,v}) -> {v, k} end)|> Enum.into(%{}) |> Map.get(addr)

  def addr_to_hex(result, addr) do
    str = to_hex(addr)
    str = case addr_to_label(result.labels, addr) do
      nil ->
        # str = String.pad_trailing(str, 30, " ")
        str
      label ->
        # str = String.pad_trailing(str, 30, " ")
        str <> " #{inspect label} "
    end
    String.pad_trailing(str, 30, " ")
  end

  def to_hex(addr) do
    String.pad_leading(Integer.to_string(addr, 16), 4, "0") <> "h"
  end

  # TODO over invert swap nip drop ; >r r> r@ @ !
  def inspect_alu(word) do
    << _ :: size(3), rpc :: size(1), op :: size(4),
    tn :: size(1), tr :: size(1), nti :: size(1),
    0 :: size(1), rs :: size(2), ds :: size(2) >> = << word :: integer-unsigned-16 >>

    # Logger.debug word
    inspect_alu_word({op, rpc, tn, tr, nti, rs, ds})
  end

  #                     op  rpc tn tr nti rs ds         // rs/ds +1 = 1  -1 = 3 0 = 0
  def inspect_alu_word({ 0,   0, 1, 0,  0, 0, 1} = alu_word),
    do: "DUP ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word({ 1,   0, 1, 0,  0, 0, 1} = alu_word),
    do: "OVER ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word({ 6,   0, 0, 0,  0, 0, 0} = alu_word),
    do: "INVERT ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word({ 2,   0, 0, 0,  0, 0, 3} = alu_word),
    do: "+ ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word({ 1,   0, 1, 0,  0, 0, 0} = alu_word),
    do: "SWAP ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word({ 0,   0, 0, 0,  0, 0, 3} = alu_word),
    do: "NIP ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word({ 1,   0, 0, 0,  0, 0, 3} = alu_word),
    do: "DROP ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word({ 0,   1, 0, 0,  0, 3, 0} = alu_word),
    do: "';' ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word({ 1,   0, 0, 1,  0, 1, 3} = alu_word),
    do: ">r ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word({11,   0, 1, 1,  0, 3, 1} = alu_word),
    do: "r> ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word({11,   0, 1, 1,  0, 0, 1} = alu_word),
    do: "r@ ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word({12,   0, 0, 0,  0, 0, 0} = alu_word),
    do: "@ ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word({ 1,   0, 0, 0,  1, 0, 3} = alu_word),
    do: "! ; " <> inspect_alu_word_detailed(alu_word)
  def inspect_alu_word(alu_word),
    do: inspect_alu_word_detailed(alu_word)

  def inspect_alu_word_detailed({op, rpc, tn, tr, nti, rs, ds}),
    do: "ALU   #{inspect_opcode(op)} #{inspect_rpc(rpc)} #{inspect_tn(tn)} #{inspect_tr(tr)} #{inspect_nti(nti)} #{inspect_rs(rs)} #{inspect_ds(ds)}"


  def inspect_opcode(op), do: "op=#{inspect J1.ALU.opcode(op)}"

  def inspect_rpc(1), do: "R->PC"
  def inspect_rpc(_), do: ""

  def inspect_tn(1), do: "T->N"
  def inspect_tn(_), do: ""

  def inspect_tr(1), do: "T->R"
  def inspect_tr(_), do: ""

  def inspect_nti(1), do: "N->[T]"
  def inspect_nti(_), do: ""

  def inspect_ds(3), do: "ds=-1 (ds=3)"
  def inspect_ds(2), do: "ds=-1 (ds=2)"
  def inspect_ds(1), do: "ds=+1 (ds=1)"
  def inspect_ds(0), do: "      (ds=0)"

  def inspect_rs(3), do: "rs=-1 (rs=3)"
  def inspect_rs(2), do: "rs=-1 (rs=2)"
  def inspect_rs(1), do: "rs=+1 (rs=1)"
  def inspect_rs(0), do: "      (rs=0)"
end
