defmodule J1ProgTest do
  use ExUnit.Case
  require Logger
  doctest J1

  # mix test --only prog_test
  @tag prog_test: true

  test "prog" do

    # program write "0123456789" to console
    j1 = J1CPU.new
    |> J1.write_mem( 0, J1CMD.lit(48))
    |> J1.write_mem( 1, J1CMD.lit(10000)) # write to cons
    |> J1.write_mem( 2, J1CMD.to_addr())
    |> J1.write_mem( 3, J1CMD.lit(1))
    |> J1.write_mem( 4, J1CMD.plus())
    |> J1.write_mem( 5, J1CMD.dup())
    |> J1.write_mem( 6, J1CMD.lit(58))
    |> J1.write_mem( 7, J1CMD.alu( 5, false, false, false, -1,  0, false)) # XOR - give 0 when equal
    |> J1.write_mem( 8, J1CMD.jz(10))
    |> J1.write_mem( 9, J1CMD.jmp(1))
    |> J1.write_mem(10, J1CMD.lit(10001)) # halt
    |> J1.write_mem(11, J1CMD.to_addr())
    # |> J1.write_mem(10, J1CMD.jmp(0))

    j1 = J1.run(j1)
    Logger.debug "j1 = #{inspect j1}"

  end

end
