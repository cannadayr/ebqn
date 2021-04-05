-module(ebqn_heap).

-include("crates.hrl").

-export([alloc/3,get/3,set/4,slots/2]).
-export([init_st/0,init_id/0,alloc/2]).

-on_load(init/0).

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

init() ->
    ?load_nif_from_crate(ebqn, ?crate_ebqn_heap, 0).

init_st() ->
    exit(nif_library_not_loaded).

init_id() ->
    exit(nif_library_not_loaded).

alloc(St,_E) ->
    exit(nif_library_not_loaded).
