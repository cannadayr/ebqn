-module(ebqn_mut).

% mutable byte arrays using atomics
-export([new/1,set/3]).

% create a new mutable byte array
new(Size) ->
    atomics:new(Size,[{signed,false}]).

% set contiguous indices in byte array
set(Ref,Offset,Limit) ->
    set(Ref,1,Offset,1+Limit).
set(Ref,Id,Offset,Limit) when Id =/= Limit ->
    ok = atomics:put(Ref,Id,Id+Offset),
    set(Ref,1+Id,Offset,Limit);
set(Ref,Id,Offset,Limit) when Id =:= Limit ->
    ok.
