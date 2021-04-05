-module(ebqn_heap).

-export([alloc/3,get/3,set/4,slots/2]).

alloc(E,Slots,Heap) ->
    maps:put(E,Slots,Heap).

get(E,N,Heap) ->
    Slots = maps:get(E,Heap),
    ebqn_array:get(N,Slots).

set(E,N,V,Heap) ->
    #{E:=Slots} = Heap,
    Heap#{E=>ebqn_array:set(N,V,Slots)}.

slots(E,Heap) ->
    maps:get(E,Heap).
