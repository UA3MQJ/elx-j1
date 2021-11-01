Nonterminals 
source source_str command params param
.

Terminals 
integer string t_org t_lit t_label t_alu t_jmp t_jz t_call t_comment t_next_str 
opcode_00 opcode_01 opcode_02 opcode_03 opcode_04 opcode_05 opcode_06 opcode_07 
opcode_08 opcode_09 opcode_10 opcode_11 opcode_12 opcode_13 opcode_14 opcode_15 
flag_12 flag_7 flag_6 flag_5 flag_d_plus flag_d_minus flag_r_plus flag_r_minus
.


Rootsymbol source.

% source -> '$empty' : [].
source -> source_str : '$1'.
source -> source source_str : '$1' ++ '$2'.

source_str -> t_next_str : [].
source_str -> t_comment t_next_str : ['$1'].
source_str -> command t_next_str : ['$1'].
source_str -> command t_comment t_next_str : ['$1', '$2'].

command  -> t_org   integer : {org,     str_of('$1'), int_value_of('$2')}.
command  -> t_lit   integer : {lit,     str_of('$1'), int_value_of('$2')}.
command  -> t_label  string : {label,   str_of('$1'), str_value_of('$2')}.
command  -> t_jmp   integer : {jmp,     str_of('$1'), {addr,  int_value_of('$2')}}.
command  -> t_jz    integer : {jz,      str_of('$1'), {addr,  int_value_of('$2')}}.
command  -> t_call  integer : {call,    str_of('$1'), {addr,  int_value_of('$2')}}.
command  -> t_jmp    string : {jmp,     str_of('$1'), {label, str_value_of('$2')}}.
command  -> t_jz     string : {jz,      str_of('$1'), {label, str_value_of('$2')}}.
command  -> t_call   string : {call,    str_of('$1'), {label, str_value_of('$2')}}.

command -> t_alu    integer : {alu,    str_of('$1'), {word,  int_value_of('$2')}}.
command -> t_alu    params  : {alu,    str_of('$1'), 'Elixir.Utils':alu_list_to_word({params,  '$2'})}.

params -> param : ['$1'].
params -> param params : ['$1'] ++ '$2'.

param -> opcode_00    : '$1'.
param -> opcode_01    : '$1'.
param -> opcode_02    : '$1'.
param -> opcode_03    : '$1'.
param -> opcode_04    : '$1'.
param -> opcode_05    : '$1'.
param -> opcode_06    : '$1'.
param -> opcode_07    : '$1'.
param -> opcode_08    : '$1'.
param -> opcode_09    : '$1'.
param -> opcode_10    : '$1'.
param -> opcode_11    : '$1'.
param -> opcode_12    : '$1'.
param -> opcode_13    : '$1'.
param -> opcode_14    : '$1'.
param -> opcode_15    : '$1'.
param -> flag_12      : '$1'.
param -> flag_7       : '$1'.
param -> flag_6       : '$1'.
param -> flag_5       : '$1'.
param -> flag_d_plus  : '$1'.
param -> flag_d_minus : '$1'.
param -> flag_r_plus  : '$1'.
param -> flag_r_minus : '$1'.

Erlang code.

-define(MType, '__struct__').

% list_tail({_, List}) -> List.
str_of(Obj) when is_tuple(Obj) -> tstr_of(Obj);
str_of(Obj) when is_map(Obj) -> mstr_of(Obj).

int_value_of(Obj) -> 'Elixir.Utils':string_to_int(value_of(Obj)).
str_value_of(Obj) -> 'Elixir.Utils':string_to_string(value_of(Obj)).

value_of(Obj) when is_tuple(Obj) -> tvalue_of(Obj);
value_of(Obj) when is_map(Obj) -> mvalue_of(Obj).

tstr_of(Token) ->
    % io:format('str_of ~w~n', [Token]),
    element(2, Token).

mstr_of(Map) ->
    % io:format('mstr_of ~w~n', [Map]),
    maps:get(str, Map, nil).

tvalue_of(Token) ->
    element(3, Token).

mvalue_of(Map) ->
    % io:format('value_of ~w~n', [Map]),
    maps:get(value, Map, nil).
