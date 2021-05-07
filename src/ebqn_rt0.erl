-module(ebqn_rt0).

-include("schema.hrl").
-import(ebqn_core,[fn/1,r1/1,r2/1]).
-import(ebqn,[call/4]).
-export([right/3,left/3,greater/3,not_eq/3,greater_eq/3,join/3,fold/4]).
-export([fns/0]).

right(St0,X,_W) ->
    {St0,X}.
left(St0,X,undefined) ->
    {St0,X};
left(St0,X,W) ->
    {St0,W}.
greater(St0,X,W) ->
    {St1,Rtn} = ebqn_core:lesseq(St0,X,W),
    {St1,1-Rtn}.
not_eq(St0,X,W) when is_record(X,a),is_list(X#a.sh),length(X#a.sh)>0 ->
    {St0,hd(X#a.sh)};
not_eq(St0,X,W) ->
    {St0,1}.
greater_eq(St0,X,W) ->
    ebqn_core:lesseq(St0,W,X).
join(St0,X,W) when is_record(X,a),is_record(W,a),is_list(X#a.sh),is_list(W#a.sh),is_number(hd(X#a.sh)),is_number(hd(W#a.sh)) ->
    {St0,ebqn_core:arr(ebqn_array:concat(W#a.r,X#a.r),[hd(W#a.sh)+hd(X#a.sh)])}.
constant(St0,F,X,W) ->
    {St0,F}.
swap(St0,F,X,undefined) ->
    call(St0,F,X,X);
swap(St0,F,X,W) ->
    call(St0,F,W,X).
each(St0,F,X,W) ->
    {St3,Rtn1} = ebqn_array:foldl(fun(I,E,{St1,Accm}) -> {St2,Rtn0} = call(St1,F,E,ebqn_array:get(I,W#a.r)),{St2,ebqn_array:set(I,Rtn0,Accm)} end,{St0,#{}},X#a.r),
    {St3,ebqn_core:arr(Rtn1,X#a.sh)}.
atop(St0,F,G,X,W) ->
    {St1,Rtn0} = call(St0,G,X,W),
    call(St1,F,Rtn0,undefined).
fold_fn(I,St0,F,R0,X) when I =:= -1 ->
    {St0,R0};
fold_fn(I,St0,F,R0,X) when I =/= -1 ->
    {St1,R1} = call(St0,F,R0,ebqn_array:get(I,X#a.r)),
    fold_fn(I-1,St1,F,R1,X).
fold(St0,F,X,undefined) ->
    L = hd(X#a.sh),
    R = ebqn_array:get(L-1,X#a.r),
    fold_fn(L-2,St0,F,R,X);
fold(St0,F,X,W) ->
    L = hd(X#a.sh),
    R = W,
    fold_fn(L-1,St0,F,W,X).

fns() -> [undefined,undefined,undefined,undefined,
          undefined,undefined,undefined,fn(fun right/3),
          undefined,undefined,undefined,undefined,
          undefined,undefined,undefined,undefined,
          undefined,undefined,undefined,undefined,
          undefined,undefined,undefined].
