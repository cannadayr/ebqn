-module(ebqn_array).

% test implementation using erlang maps as a mutable array
% https://erlang.org/doc/man/maps.html
% https://en.wikipedia.org/wiki/Hash_array_mapped_trie

-export([new/1,new/2,get/2,set/3,to_list/1,concat/1,concat/2,from_list/1,foldl/3]).

new(N) when N =:= 0 ->
    #{};
new(N) when is_integer(N),N > 0 ->
    new(0,N,#{},undefined).
new(N,Default) when N =:= 0 ->
    #{};
new(N,Default) when is_integer(N),N > 0 ->
    new(0,N,#{},Default).
new(N,L,A,Default) when N =:= L ->
    A;
new(N,L,A,Default) ->
    new(N+1,L,A#{N=>Default},Default).

get(N,M) ->
    maps:get(N,M).

set(N,V,M) ->
    M#{N=>V}.

% recursive fn calls to ensure in-order transformation
to_list(M) ->
    S = maps:size(M),
    to_list(0,S,[],M).
to_list(I,L,A,M) when I =/= L ->
    #{I := K} = M,
    to_list(I+1,L,[K]++A,M);
to_list(I,L,A,M) when I =:= L ->
    lists:reverse(A).

from_list(L) ->
    {_,R} = lists:foldl(fun(V,{N,A}) -> {N+1,A#{N=>V}} end,{0,#{}},L),
    R.

concat(X,W) ->
    S = maps:size(X),
    maps:fold(fun(K,V,A) -> A#{K+S=>V} end,X,W).
concat(L) ->
    lists:foldl(fun(M,A) -> concat(A,M) end,hd(L),tl(L)).

foldl(F,A,M) ->
    foldl(0,F,A,maps:size(M),M).
foldl(I,F,A,S,M) when I =/= S ->
    foldl(I+1,F,F(I,maps:get(I,M),A),S,M);
foldl(I,F,A,S,M) when I =:= S ->
    A.
