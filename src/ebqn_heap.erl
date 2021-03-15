-module(ebqn_heap).

-export([alloc/3,get/3,set/4]).

alloc(E,Slots,Heap) ->
    lists:foldl(fun(K,A) -> A#{{E,K}=>undefined} end,#{},lists:seq(0,Slots)).

get(E,N,Heap) ->
    #{{E,N}:=Slot} = Heap,
    Slot.

set(E,N,V,Heap) ->
    Heap#{{E,N}=>V}.
