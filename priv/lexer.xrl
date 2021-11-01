Definitions.

D = [0-9]
L = [^\x20]
 
Rules.
 
[-] : { token, { '-', TokenLine }}.
[=] : { token, { '=', TokenLine }}.

(\s)+ : skip_token.
 
(\-)?{D}+ :
  { token,{integer,TokenLine,list_to_integer(TokenChars)}}.
 
(\-)?{D}+\.{D}+((E|e)(\+|\-)?{D}+)? :
  { token,{float,TokenLine,list_to_float(TokenChars)}}.
 
'([^'])*' : { token, { str1, TokenLine, list_to_binary(lists:sublist(TokenChars,2, length(TokenChars)-2)) }}.
 
Erlang code.
 
% rc_cli_lexer:string("--").
 
%
 