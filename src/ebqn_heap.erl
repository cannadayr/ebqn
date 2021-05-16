-module(ebqn_heap).

-export([alloc/4,get/3,set/4,slots/2]).

alloc(E,L,Slots,Heap) ->
    Offset = maps:size(Heap),
    Size = maps:size(Slots),
    ok = ebqn_mut:flip(E,L),
    ok = ebqn_mut:init(E,Offset,Size),
    ebqn_array:concat(Heap,Slots).

get(E,I,Heap) ->
    Id = ebqn_mut:get(E,I),
    Max = (1 bsl 64) - 1,
    case Id of
        Max -> undefined;
        _ -> ebqn_array:get(Id,Heap)
    end.

set(E,I,V,Heap) ->
    ebqn_mut:put(E,I,maps:size(Heap)),
    ebqn_array:concat(Heap,#{ 0 => V }).

slots(E,Heap) ->
    maps:get(E,Heap).
