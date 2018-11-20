defmodule J1a do
  @moduledoc """
  Documentation for J1a.
  
  ALU
  1 1 1 1|1 1    |       | 
  5 4 3 2|1 0 9 8|7 6 5 4|3 2 1 0
  -------+-------+-------+-------
  0 1 1  |C O D E| Flags |R S D S

                              DS= 
                              1 1  - d-1
                              0 1  - d+1
                          RS=
                          1 1      - r-1
                          1 0      - r-2
                          0 1      - r+1

                        1          - T->N
                      1 0          - T->R
                      1 1          - N->[T]
                    1 0 0          - N->io[T]
                    1 0 1          - _IORD_
                  1 0 0 0          - RET

            CODE                      Operation
              0                    -        T
              1                    -        N
              2                    -      T + N
              3                    -      TandN
              4                    -       TorN
              5                    -      TxorN
              6                    -       ~T
              7                    -       N==T
              8                    -       N <T
              9                    -       T2/   !
             10                    -       T2*   !
             11                    -       rT    !
             12                    -      N - T  !
             13                    -      io[T]  !
             14                    -      status !
             15                    -      Nu<T
  
  ------------------------------------------------------
  0 0 0                            - ubranch (jump)
  0 0 1                            - 0branch (conditional jump)
  0 1 0                            - scall   (call)
  0 1 1                            - alu     (see --^)
  1                                - imm     (lit value)


  0 1 1 x x x x x x x x x x x x x  - is_alu

  x x x x x x x x 0 0 0 1 x x x x  - func_T_N   (see T->N)
  x x x x x x x x 0 0 1 0 x x x x  - func_T_R   (see T->R)
  x x x x x x x x 0 0 1 1 x x x x  - func_write (see N->[T])
  x x x x x x x x 0 1 0 0 x x x x  - func_iow   (see N->io[T])
  x x x x x x x x 0 1 0 1 x x x x  - func_ior   (see _IORD_)
  
  mem_wr = is_alu & func_write
  io_wr  = is_alu & func_iow;
  io_rd  = is_alu & func_ior;

  """
  use Bitwise
  require Logger

  
end
