-module(ebqn_rt).

-include("schema.hrl").

-export([fold/4]).

fold(St0,F,X,undefined) ->
    Size = maps:size(X#a.r),
    R0 = ebqn_array:get(Size-1,X#a.r),
    R1 = ebqn_array:get(Size-2,X#a.r),
    RTail = ebqn_array:drop(2,X#a.r),
    Init = ebqn:call(St0,F,R0,R1),
    ebqn_array:foldr(fun(I,E,{StAccm,A}) -> ebqn:call(StAccm,F,A,E) end,Init,RTail).
