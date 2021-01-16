-module(ebqn).

-export([runtime/1]).

runtime(b) ->
    <<15,1,25>>;
runtime(o) ->
    {0,1,2,32,3,8,infinity,neg_infinity,-1};
runtime(s) ->
    [{0,1,0,0}].
