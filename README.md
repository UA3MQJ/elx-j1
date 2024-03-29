# J1

Elixir J1 Forth CPU emulator

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `j1` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:j1, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/j1](https://hexdocs.pm/j1).

# opcodes

: T         h# 0000 ;
: N         h# 0100 ;
: T+N       h# 0200 ;
: T&N       h# 0300 ;
: T|N       h# 0400 ;
: T^N       h# 0500 ;
: ~T        h# 0600 ;
: N==T      h# 0700 ;
: N<T       h# 0800 ;
: N>>T      h# 0900 ;
: T-1       h# 0a00 ;
: rT        h# 0b00 ;
: [T]       h# 0c00 ;
: N<<T      h# 0d00 ;
: dsp       h# 0e00 ;
: Nu<T      h# 0f00 ;

: T->N      h# 0080 or ;
: T->R      h# 0040 or ;
: N->[T]    h# 0020 or ;
: d-1       h# 0003 or ;    11
: d+1       h# 0001 or ;    01
: r-1       h# 000c or ;  1100
: r-2       h# 0008 or ;  1000
: r+1       h# 0004 or ;  0100

: alu       h# 6000 or t, ;

: return    T  h# 1000 or r-1 alu ;        return (alu command)
: ubranch   2/ h# 0000 or t, ;             jmp
: 0branch   2/ h# 2000 or t, ;             jz
: scall     2/ h# 4000 or t, ;             call

# Links

 http://excamera.com/sphinx/fpga-j1.html

 http://excamera.com/files/j1.pdf

 http://excamera.com/files/j1demo/docforth/

 http://excamera.com/files/j1demo/docforth/basewords.fs.html

 https://github.com/jamesbowman/swapforth See j1a, j1b


 https://nanode0000.wordpress.com/2017/04/08/exploring-the-j1-instruction-set-and-architecture/

 https://www.fpgarelated.com/showarticle/790.php

https://github.com/gerryjackson/forth2012-test-suite/tree/master ANS Forth standards requires a set of test programs

https://www.veripool.org/projects/verilator/wiki/Manual-verilator for Verilog j1 emulation

https://www.gnu.org/software/gforth/

 https://zserge.wordpress.com/2012/04/23/%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80-j1-%D0%BA%D1%83%D0%B4%D0%B0-%D1%83%D0%B6-%D0%BF%D1%80%D0%BE%D1%89%D0%B5/

 https://www.fpgarelated.com/showarticle/790.php

 http://lars.nocrew.org/forth2012/rationale.html

 https://habr.com/post/133338/
 
 https://habr.com/post/133380/


 https://github.com/jamesbowman/j1
 
 https://github.com/samawati/j1eforth
 
 https://github.com/ddb/j1tools

 https://github.com/jamesbowman/swapforth

 other

 https://github.com/jamesbowman/j1 other impl on verilog

 http://www.bradrodriguez.com/papers/piscedu2.htm A Minimal TTL Processor for Architecture Exploration

 http://iosifk.narod.ru/hdl_coding/verilog.htm Статья "Микропроцессор своими руками" часть 1

 http://astro.pas.rochester.edu/Forth/forth-words.html

 http://lars.nocrew.org/forth2012/core.html

 http://lars.nocrew.org/forth2012/usage.html

 http://lars.nocrew.org/forth2012/port.html