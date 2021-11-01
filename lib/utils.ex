defmodule Utils do
  require Logger

  def string_to_int(str) when is_list(str) do
    string_to_int(to_string(str))
  end
  def string_to_int(str) when is_bitstring(str) do
    type = case String.slice(str, -1..-1) do
      "B" -> 2
      "b" -> 2
      "H" -> 16
      "h" -> 16
      _else -> 10
    end
    string_to_int(str, type)
  end
  def string_to_int(str, base) do
    {int_value, _} = Integer.parse(str, base)
    int_value
  end

  def string_to_string(str) when is_list(str) do
    string_to_string(to_string(str))
  end
  def string_to_string(str) when is_bitstring(str) do
    String.slice(str, 1..-2)
  end

  def alu_list_to_word({:params, params}) do
    use Bitwise
    Logger.debug ">>> inspect params=#{inspect params}"
    word = Enum.reduce(params, 0, fn({flag, _, _}, acc) ->
      bor(acc, alu_list_to_word_param_parse(flag))
    end
    )

    {:word, word}
  end


  def alu_list_to_word_param_parse(:opcode_00), do:  0 * 256 # : T         h# 0000 ;
  def alu_list_to_word_param_parse(:opcode_01), do:  1 * 256 # : N         h# 0100 ;
  def alu_list_to_word_param_parse(:opcode_02), do:  2 * 256 # : T+N       h# 0200 ;
  def alu_list_to_word_param_parse(:opcode_03), do:  3 * 256 # : T&N       h# 0300 ;
  def alu_list_to_word_param_parse(:opcode_04), do:  4 * 256 # : T|N       h# 0400 ;
  def alu_list_to_word_param_parse(:opcode_05), do:  5 * 256 # : T^N       h# 0500 ;
  def alu_list_to_word_param_parse(:opcode_06), do:  6 * 256 # : ~T        h# 0600 ;
  def alu_list_to_word_param_parse(:opcode_07), do:  7 * 256 # : N==T      h# 0700 ;
  def alu_list_to_word_param_parse(:opcode_08), do:  8 * 256 # : N<T       h# 0800 ;
  def alu_list_to_word_param_parse(:opcode_09), do:  9 * 256 # : N>>T      h# 0900 ;
  def alu_list_to_word_param_parse(:opcode_10), do: 10 * 256 # : T-1       h# 0a00 ;
  def alu_list_to_word_param_parse(:opcode_11), do: 11 * 256 # : rT        h# 0b00 ;
  def alu_list_to_word_param_parse(:opcode_12), do: 12 * 256 # : [T]       h# 0c00 ;
  def alu_list_to_word_param_parse(:opcode_13), do: 13 * 256 # : N<<T      h# 0d00 ;
  def alu_list_to_word_param_parse(:opcode_14), do: 14 * 256 # : dsp       h# 0e00 ;
  def alu_list_to_word_param_parse(:opcode_15), do: 15 * 256 # : Nu<T      h# 0f00 ;

  def alu_list_to_word_param_parse(:flag_12),   do: 4096  # : R->PC     h# 1000 or ;
  def alu_list_to_word_param_parse(:flag_7),    do:  128  # : T->N      h# 0080 or ;
  def alu_list_to_word_param_parse(:flag_6),    do:   64  # : T->R      h# 0040 or ;
  def alu_list_to_word_param_parse(:flag_5),    do:   32  # : N->[T]    h# 0020 or ;
  def alu_list_to_word_param_parse(:flag_d_minus), do:    3 # : d-1       h# 0003 or ;    11
  def alu_list_to_word_param_parse(:flag_d_plus),  do:    1 # : d+1       h# 0001 or ;    01
  def alu_list_to_word_param_parse(:flag_r_minus), do:   12 # : r-1       h# 000c or ;  1100
  def alu_list_to_word_param_parse(:flag_r_plus),  do:    4 # : r+1       h# 0004 or ;  0100
  def alu_list_to_word_param_parse(_), do: 0
end
