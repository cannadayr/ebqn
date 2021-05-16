-module(ebqn_mut).

% mutable byte arrays using atomics
-export([new/1,get/2,put/3,flip/2,init/3]).

% create a new mutable byte array
new(0) ->
    nil;
new(Size) ->
    atomics:new(Size,[{signed,false}]).

% 0-based indexing wrappers
get(Ref,Id) ->
    atomics:get(Ref,1+Id).
put(Ref,Id,X) ->
    atomics:put(Ref,1+Id,X).
% flip entire byte array to max unsigned int
% this is to distinguish between index 0 and an unset index
flip(Ref,Size) ->
    flip(Ref,0,Size).
flip(Ref,Id,Size) when Id =/= Size ->
    Max = (1 bsl 64) - 1,
    ok = atomics:put(Ref,1+Id,Max),
    flip(Ref,1+Id,Size);
flip(_Ref,Id,Size) when Id =:= Size ->
    ok.
% sets the heap indices of the initial arguments
init(Ref,Offset,Cnt) ->
    init(Ref,0,Offset,Cnt).
init(Ref,Id,Offset,Cnt) when Cnt =/= 0 ->
    ok = ebqn_mut:put(Ref,Id,Id+Offset),
    init(Ref,1+Id,Offset,Cnt-1);
init(_Ref,_Id,_Size,Cnt) when Cnt =:= 0 ->
    ok.
