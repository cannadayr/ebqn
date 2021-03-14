-module(ebqn_array).

% test implementation using erlang maps as a mutable array
% https://erlang.org/doc/man/maps.html
% https://en.wikipedia.org/wiki/Hash_array_mapped_trie

-export([new/1]).

% functions that need to be implemented (or have shims for)
new(N) when is_integer(N),N > 0 ->
    new(0,N,#{}).
new(N,L,A) when N =:= L ->
    A;
new(N,L,A) ->
    new(N+1,L,A#{N=>undefined}).
