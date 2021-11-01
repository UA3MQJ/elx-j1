defmodule J1SystemTest do
  use ExUnit.Case
  require Logger
  doctest J1

  # mix test --only prog_test
  @tag prog_test: true

  test "prog" do


    # j1 = make_j1_and_program()

    # j1 = J1.run(j1)
    # # Logger.debug "j1 = #{inspect j1}"
    # assert j1.state == :halted



    j1_2 = J1.CPU.new()
    |> J1.CPU.set_memory_mapper(J1.MEMORYMAP2)

    {:ok, data} =  File.read("./toolchain/build/firmware/nuc.hex16")
    mem_words = String.split(data, "\n")

    {_, j1_3} = Enum.reduce(mem_words, {0, j1_2}, fn(x, {addr, j1}) ->
      case Integer.parse(x, 16) do
        {int_value, ""} ->
          next_j1 = J1.write_mem(j1, addr, int_value)
          {addr+1, next_j1}
        _else ->
          {addr+1, j1}
      end
    end)

    # {start_addr, ""} = Integer.parse("07EA", 16)
    # j1_3 = %J1.CPU{j1_3 | pc: start_addr}

    # Logger.debug "j1_3 = #{inspect j1_3}"


    J1.dump(j1_3, 00, 1200)

    # j1_3 = J1.run(j1_3)
    # Logger.debug "j1_3 = #{inspect j1_3}"
  end

  def make_j1_and_program do
    # program write "0123456789" to console
    J1.CPU.new()
    |> J1.CPU.set_memory_mapper(J1.MEMORYMAP2)
    |> J1.write_mem( 0, J1.CMD.lit(48))
    |> J1.write_mem( 1, J1.CMD.lit(0)) # write to cons = 0000
    |> J1.write_mem( 2, J1.CMD.to_addr())
    |> J1.write_mem( 3, J1.CMD.lit(1))
    |> J1.write_mem( 4, J1.CMD.plus())  # TODO проверить переполнение
    |> J1.write_mem( 5, J1.CMD.dup())
    |> J1.write_mem( 6, J1.CMD.lit(58))
    |> J1.write_mem( 7, J1.CMD.alu( 5, false, false, false, -1,  0, false)) # XOR - give 0 when equal
    |> J1.write_mem( 8, J1.CMD.jz(10))
    |> J1.write_mem( 9, J1.CMD.jmp(1))
    |> J1.write_mem(10, J1.CMD.lit(0)) # halt
    |> J1.write_mem(11, J1.CMD.invert()) # make 65535 on top
    |> J1.write_mem(12, J1.CMD.to_addr())
    |> J1.write_mem(13, J1.CMD.jmp(0))
  end

end

# defmodule J1.MEMORYMAP2 do
#   @moduledoc """
#   J1 CPU memory mapper module
#   """
#   require Logger

#   def hardware_write_mem(j1, 0, value) do
#     IO.write "#{[value]}"
#     j1.mem
#   end

#   def hardware_write_mem(j1, 65535, _value) do
#     Logger.info "J1 halt"
#     raise "halt"
#     j1.mem
#   end

#   def hardware_write_mem(j1, address, value) do
#     Map.merge(j1.mem, %{address => value})
#   end

#   def hardware_read_mem(j1, address) do
#     case j1.mem[address] do
#       nil -> << 0 :: integer-unsigned-16 >>
#       data -> data
#     end
#   end

# end
