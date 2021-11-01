% https://regex101.com/

Definitions.

% COMMENT    = ;(.*[ \t]*.*)*[\n]+
COMMENT    = ;(.*[\\s\\t]*.*)*

NEXT_STR   = [\r\n]
DELIM      = [\s\t]
WS         = {DELIM}+

ORG        = ORG|org
LIT        = LIT|lit
JMP        = JMP|jmp
JZ         = JZ|jz
CALL       = CALL|call
ALU        = ALU|alu
LABEL      = LABEL|label

% T
OPCODE_00  = T
% N
OPCODE_01  = N
% T+N
OPCODE_02  = T\+N
% T&N 
OPCODE_03  = T&N|TandN
% T|N
OPCODE_04  = T\|N|TorN
% T^N 
OPCODE_05  = T\^N|TxorN
% ~T
OPCODE_06  = ~T
% N==T
OPCODE_07  = N==T
% N<T
OPCODE_08  = N<T
% N>>T
OPCODE_09  = N>>T
% T-1
OPCODE_10  = T-1
% rT
OPCODE_11  = R
% [T]
OPCODE_12  = \[T\]
% N<<T
OPCODE_13  = N<<T
% dsp
OPCODE_14  = dsp
% Nu<T
OPCODE_15  = Nu<T

% BIT 12 RETURN FLAG R -> PC 
FLAG_12    = R->PC
% % BIT 7 T->N
FLAG_7     = T->N
% % BIT 6 T->R
FLAG_6     = T->R
% % BIT 5 N->[T]
FLAG_5     = N->\[T\]

% stacks flags
% d+1
FLAG_D_PLUS  = d\+1
% d-1
FLAG_D_MINUS = d-1
% r+1
FLAG_R_PLUS  = r\+1
% r-1
FLAG_R_MINUS = r-1

SEMICOLON  = ;

LETTER     = [A-Za-z]
DIGIT      = [0-9]
% _ not in EBNF!
IDENT      = ({LETTER}|_)({LETTER}|{DIGIT}|_)*
INTHEXWR   = ([0-9A-F])
INTHEX     = ([0-9A-F]+(H|h))
INTDEC     = {DIGIT}+
INT        = {INTHEX}|{INTDEC}
INT2       = {INTHEXWR}+
STRING1    = "([^"|^\n|^\r])*"
STRING2    = '([^'|^\n|^\r])*'
STRING     = {STRING1}|{STRING2}



Rules.
{COMMENT}    : {token, {t_comment, TokenLine, str_validate(TokenChars, TokenLine)}}.

{NEXT_STR}  : {token, {t_next_str, TokenLine, TokenChars}}.
{WS}        : skip_token.
{ORG}       : {token, {t_org, TokenLine, TokenChars}}.
{LIT}       : {token, {t_lit, TokenLine, TokenChars}}.
{LABEL}     : {token, {t_label, TokenLine, TokenChars}}.
{JMP}       : {token, {t_jmp, TokenLine, TokenChars}}.
{JZ}        : {token, {t_jz, TokenLine, TokenChars}}.
{CALL}      : {token, {t_call, TokenLine, TokenChars}}.
{ALU}       : {token, {t_alu, TokenLine, TokenChars}}.

{OPCODE_00} : {token, {opcode_00, TokenLine, TokenChars}}.
{OPCODE_01} : {token, {opcode_01, TokenLine, TokenChars}}.
{OPCODE_02} : {token, {opcode_02, TokenLine, TokenChars}}.
{OPCODE_03} : {token, {opcode_03, TokenLine, TokenChars}}.
{OPCODE_04} : {token, {opcode_04, TokenLine, TokenChars}}.
{OPCODE_05} : {token, {opcode_05, TokenLine, TokenChars}}.
{OPCODE_06} : {token, {opcode_06, TokenLine, TokenChars}}.
{OPCODE_07} : {token, {opcode_07, TokenLine, TokenChars}}.
{OPCODE_08} : {token, {opcode_08, TokenLine, TokenChars}}.
{OPCODE_09} : {token, {opcode_09, TokenLine, TokenChars}}.
{OPCODE_10} : {token, {opcode_10, TokenLine, TokenChars}}.
{OPCODE_11} : {token, {opcode_11, TokenLine, TokenChars}}.
{OPCODE_12} : {token, {opcode_12, TokenLine, TokenChars}}.
{OPCODE_13} : {token, {opcode_13, TokenLine, TokenChars}}.
{OPCODE_14} : {token, {opcode_14, TokenLine, TokenChars}}.
{OPCODE_15} : {token, {opcode_15, TokenLine, TokenChars}}.

{FLAG_12} : {token, {flag_12, TokenLine, TokenChars}}.
{FLAG_7}  : {token, {flag_7,  TokenLine, TokenChars}}.
{FLAG_6}  : {token, {flag_6,  TokenLine, TokenChars}}.
{FLAG_5}  : {token, {flag_5,  TokenLine, TokenChars}}.

{FLAG_D_PLUS}  : {token, {flag_d_plus,  TokenLine, TokenChars}}.
{FLAG_D_MINUS} : {token, {flag_d_minus, TokenLine, TokenChars}}.
{FLAG_R_PLUS}  : {token, {flag_r_plus,  TokenLine, TokenChars}}.
{FLAG_R_MINUS} : {token, {flag_r_minus, TokenLine, TokenChars}}.

% {SEMICOLON} : {token, {t_semicolon, TokenLine, TokenChars}}.

{IDENT}     : {token, {ident,  TokenLine, id_validate(TokenChars, TokenLine)}}.
{INT}       : {token, {integer, TokenLine, int_validate(TokenChars, TokenLine)}}.
{INT2}      : {token, {integer, TokenLine, intwr_validate(TokenChars, TokenLine)}}.
{STRING}    : {token, {string, TokenLine, str_validate(TokenChars, TokenLine)}}.


Erlang code.

id_validate(Chars, Line) ->
  case length(Chars) > 40 of
    true ->
      io:format("WARNING: Identifier too long. ~w: ~s -> ~s~n", [Line, Chars, lists:sublist(Chars, 40)]),
      lists:sublist(Chars, 40);
    _Else ->
      Chars
  end.

int_validate(Chars, _Line) -> int_validate_del_zero(Chars).
int_validate_del_zero([$0] = Chars) -> Chars;
int_validate_del_zero([$0|Chars]) -> int_validate_del_zero(Chars);
int_validate_del_zero(Chars) -> Chars.

intwr_validate(Chars, Line) ->
  io:format("WARNING: A hexadecimal literal hasn't a trailing H. ~w: ~s -> ~s~n", [Line, Chars, Chars ++ "H"]),
  int_validate(Chars ++ "H", Line).

str_validate(Chars, _Line) -> Chars.
