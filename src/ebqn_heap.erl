-module(ebqn_heap).

-include("crates.hrl").

-export([alloc/3,get/3,set/4,slots/2]).
-export([static_atom/0,native_add/2,tuple_add/1,init_st/0]).

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

static_atom() ->
    exit(nif_library_not_loaded).

native_add(_X, _Y) ->
    exit(nif_library_not_loaded).

tuple_add(_X) ->
    exit(nif_library_not_loaded).

init_st() ->
    exit(nif_library_not_loaded).
