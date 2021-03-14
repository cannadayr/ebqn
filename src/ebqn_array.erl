-module(ebqn_array).

% test implementation using erlang maps as a mutable array
% https://erlang.org/doc/man/maps.html
% https://en.wikipedia.org/wiki/Hash_array_mapped_trie

-export([new/1,get/2,set/3,to_list/1,concat/2]).

% functions that need to be implemented (or have shims for)
new(N) when is_integer(N),N > 0 ->
    new(0,N,#{}).
new(N,L,A) when N =:= L ->
    A;
new(N,L,A) ->
    new(N+1,L,A#{N=>undefined}).

get(N,M) ->
    #{N := V}  = M,
    V.

set(N,V,M) ->
    M#{N=>V}.

to_list(M) ->
    maps:fold(fun(_,V,A) -> [V]++A end,[],M).

concat(X,W) ->
    S = maps:size(X),
    maps:fold(fun(K,V,A) -> A#{K+S=>V} end,X,W).
