-module(ebqn_heap).

-export([alloc/3,get/3,set/4]).

alloc(E,Slots,Heap) ->
    maps:fold(fun(K,V,A) -> A#{{E,K}=>V} end,Heap,Slots).

get(E,N,Heap) ->
    #{{E,N}:=Slot} = Heap,
    Slot.

set(E,N,V,Heap) ->
    Heap#{{E,N}=>V}.
