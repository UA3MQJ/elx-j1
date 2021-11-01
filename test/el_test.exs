defmodule J1AsmTest do
  use ExUnit.Case
  require Logger
  doctest J1

  # mix test --only prog_test
  @tag prog_test: true

  test "prog" do


    time1 = :os.system_time(:millisecond)
    {:ok, _} = :leex.file('./priv/lexer.xrl')
    time2 = :os.system_time(:millisecond)
    {:ok, :lexer} = :c.c('./priv/lexer.erl')
    time3 = :os.system_time(:millisecond)

    # :lexer.string('--')
    # :lexer.string('-')

    {:ok, _} = :leex.file('./priv/lexer.xrl'); {:ok, :lexer} = :c.c('./priv/lexer.erl')
  end

end
