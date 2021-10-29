defmodule J1ProgTest do
  use ExUnit.Case
  require Logger
  doctest J1

  # mix test --only prog_test
  @tag prog_test: true

  test "prog" do


    j1 = make_j1_and_program()

    j1 = J1.run(j1)
    # Logger.debug "j1 = #{inspect j1}"
    assert j1.state == :halted

  end

  def make_j1_and_program do
    # program write "0123456789" to console
    J1.CPU.new
    |> J1.write_mem( 0, J1.CMD.lit(48))
    |> J1.write_mem( 1, J1.CMD.lit(10000)) # write to cons
    |> J1.write_mem( 2, J1.CMD.to_addr())
    |> J1.write_mem( 3, J1.CMD.lit(1))
    |> J1.write_mem( 4, J1.CMD.plus())
    |> J1.write_mem( 5, J1.CMD.dup())
    |> J1.write_mem( 6, J1.CMD.lit(58))
    |> J1.write_mem( 7, J1.CMD.alu( 5, false, false, false, -1,  0, false)) # XOR - give 0 when equal
    |> J1.write_mem( 8, J1.CMD.jz(10))
    |> J1.write_mem( 9, J1.CMD.jmp(1))
    |> J1.write_mem(10, J1.CMD.lit(10001)) # halt
    |> J1.write_mem(11, J1.CMD.to_addr())
    # |> J1.write_mem(10, J1.CMD.jmp(0))
  end

end
