-module(ebqn_core).

-import(lists,[seq/2,flatten/1]).
-import(math,[log/1,exp/1,pow/2]).
-import(ebqn,[list/1,call/4]).

-export([fns/0,fn/1]).
-export([arr/2,r1/1,r2/1,type/3,fill/3,log/3,group_len/3,group_ord/3,
         plus/3,minus/3,times/3,divide/3,power/3,floor/3,equals/3,lesseq/3,shape/3,
         reshape/3,pick/3,window/3,table/4,scan/4,fill_by/5,cases/5,assert_fn/1]).
-include("schema.hrl").

arr(R,Sh) ->
    #a{r=R,sh=Sh}.
fn(F) ->
    #fn{f=F}.
r1(F) ->
    #r1{f=fn(F)}.
r2(F) ->
    #r2{f=fn(F)}.
type(St0,X,_W) when is_record(X,bi) ->
    {St0,3 + X#bi.t};
type(St0,X,_W) when is_record(X,fn);is_record(X,tr);is_record(X,d1);is_record(X,d2) ->
    {St0,3};
type(St0,X,_W) when is_record(X,r1) ->
    {St0,4};
type(St0,X,_W) when is_record(X,r2) ->
    {St0,5};
type(St0,X,_W) when is_record(X,a) ->
    {St0,0};
type(St0,X,_W) when is_number(X);X =:= inf;X =:= ninf ->
    {St0,1};
type(St0,X,_W) when is_record(X,c) ->
    {St0,2}.
fill(St0,X,undefined) ->
    {St0,0};
fill(St0,X,W) ->
    {St0,X}.
log(St0,0,undefined) ->
    {St0,ninf};
log(St0,inf,undefined) ->
    {St0,inf};
log(St0,X,undefined) when is_number(X),X > 0 ->
    {St0,log(X)};
log(St0,0,W) when is_number(W),W>0 ->
    divide(St0,log(W),ninf);
log(St0,inf,W) when is_number(W),W>0 ->
    divide(St0,log(W),inf);
log(St0,X,0) when is_number(X),X>0 ->
    divide(St0,ninf,log(X));
log(St0,X,inf) when is_number(X),X>0 ->
    divide(St0,inf,log(X));
log(St0,X,W) ->
    {St0,log(X) / log(W)}.
group_len(St0,X,undefined) ->
    L = ebqn_array:foldl(fun(_I,V,A) -> max(A,V) end,-1,X#a.r),
    R = ebqn_array:new(L+1,0),
    F = fun (_I,E,A) when E >= 0 -> ebqn_array:set(E,1+ebqn_array:get(E,A),A);
            (_I,_E,A)            -> A
    end,
    {St0,ebqn:list(ebqn_array:foldl(F,R,X#a.r))};
group_len(St0,X,W) ->
    L = ebqn_array:foldl(fun(_I,V,A) -> max(A,V) end,W-1,X#a.r),
    R = ebqn_array:new(L+1,0),
    F = fun (_I,E,A) when E >= 0 -> ebqn_array:set(E,1+ebqn_array:get(E,A),A);
            (_I,_E,A)            -> A
    end,
    {St0,ebqn:list(ebqn_array:foldl(F,R,X#a.r))}.
group_ord(St0,X,W) ->
    {S,L} = ebqn_array:foldl(fun(_I,V,{Si,Li}) -> {ebqn_array:concat(Si,ebqn_array:from_list([Li])),Li+V} end,{#{},0},W#a.r),
    R = ebqn_array:new(L),
    F = fun
        (I,V,{Si,Ri}) when V >= 0 ->
            {ebqn_array:set(V,1+ebqn_array:get(V,Si),Si),
                ebqn_array:set(ebqn_array:get(V,Si),I,Ri)};
        (_I,_V,A) ->
            A
    end,
    {_, O} = ebqn_array:foldl(F,{S,R},X#a.r),
    {St0,list(O)}.
assert_fn(Pre) ->
    fun
        (_St0,X,W) when X =/= 1 ->
            case W =/= undefined of
                true ->
                    throw({assert_fn,ebqn:strings(W)});
                false ->
                    throw({assert_fn,Pre})
            end;
        (St0,X,W) ->
            {St0,X}
    end.
plus(St0,X,undefined) ->
    {St0,X};
plus(_St0,X,W) when is_record(X,c),is_record(W,c) ->
    throw("+: Cannot add two characters");
plus(_St0,X,W) when (is_record(X,tr) or is_record(X,bi) or is_record(X,r1) or is_record(X,r2) or is_function(X))  or
               (is_record(W,tr) or is_record(W,bi) or is_record(W,r1) or is_record(W,r2) or is_function(W)) ->
    throw("+: Cannot add non-data values");
plus(St0,X,W) when is_record(X,c),not is_record(W,c) ->
    {St0,#c{p=X#c.p + W}};
plus(St0,X,W) when is_record(W,c),not is_record(X,c) ->
    {St0,#c{p=W#c.p + X}};
plus(St0,inf,W) when is_number(W) ->
    {St0,inf};
plus(St0,ninf,W) when is_number(W) ->
    {St0,ninf};
plus(St0,X,inf) when is_number(X) ->
    {St0,inf};
plus(St0,X,ninf) when is_number(X) ->
    {St0,ninf};
plus(St0,X,W)  ->
    {St0,W + X}.
minus(St0,inf,undefined) ->
    {St0,ninf};
minus(St0,ninf,undefined) ->
    {St0,inf};
minus(St0,inf,W) ->
    {St0,ninf};
minus(St0,ninf,W) ->
    {St0,inf};
minus(_St0,X,undefined) when not is_number(X) ->
    throw("-: Can only negate numbers");
minus(St0,X,undefined) ->
    {St0,-1*X};
minus(_St0,X,W) when (is_record(X,tr) or is_record(X,bi) or is_record(X,r1) or is_record(X,r2) or is_function(X))  or
                (is_record(W,tr) or is_record(W,bi) or is_record(W,r1) or is_record(W,r2) or is_function(W)) ->
    throw("-: Can only negate numbers");
minus(St0,X,W) when is_record(X,c),is_record(W,c) ->
    {St0,W#c.p - X#c.p};
minus(St0,X,W) when not is_record(X,c),is_record(W,c) ->
    P = W#c.p - X,
    case P < 0 of
        true ->
            throw("Invalid code point");
        false ->
            ok
    end,
    {St0,#c{p=P}};
minus(_St0,X,W) when is_record(X,c),not is_record(W,c) ->
    throw("-: Can only negate numbers");
minus(St0,X,W) when is_number(X),is_number(W) ->
    {St0,W-X}.
times(St0,X,undefined) when X < 0 ->
    {St0,-1};
times(St0,X,undefined) when X =:= 0 ->
    {St0,0};
times(St0,X,undefined) when X > 0 ->
    {St0,1};
times(St0,X,inf) when X > 0 ->
    {St0,inf};
times(St0,X,inf) when X < 0 ->
    {St0,ninf};
times(St0,X,ninf) when X > 0 ->
    {St0,ninf};
times(St0,X,ninf) when X < 0 ->
    {St0,inf};
times(St0,inf,W) when W > 0 ->
    {St0,inf};
times(St0,inf,W) when W < 0 ->
    {St0,ninf};
times(St0,ninf,W) when W > 0 ->
    {St0,ninf};
times(St0,ninf,W) when W < 0 ->
    {St0,inf};
times(_St0,X,W) when is_record(X,c);is_record(W,c) ->
    throw("×: Arguments must be numbers");
times(_St0,X,W) when not is_number(X),is_number(W) ->
    throw("×: Arguments must be numbers");
times(_St0,X,W) when is_number(X),not is_number(W) ->
    throw("×: Arguments must be numbers");
times(St0,X,W) ->
    {St0,X*W}.
divide(St0,0,undefined) ->
    {St0,inf};
divide(St0,inf,undefined) ->
    {St0,0};
divide(_St0,X,W) when is_record(X,bi);is_record(X,tr);is_function(X) ->
    throw("÷: Arguments must be numbers");
divide(_St0,X,W) when is_record(X,c);is_record(W,c) ->
    throw("÷: Arguments must be numbers");
divide(St0,X,undefined) ->
    {St0,1 / X};
divide(St0,0,W) when is_number(W),W > 0->
    {St0,inf};
divide(St0,0,W) when is_number(W),W < 0->
    {St0,ninf};
divide(St0,inf,W) when is_number(W) ->
    {St0,0};
divide(St0,ninf,W) when is_number(W) ->
    {St0,0};
divide(St0,X,ninf) when is_number(X),X >= 0 ->
    {St0,ninf};
divide(St0,X,ninf) when is_number(X),X < 0 ->
    {St0,inf};
divide(St0,X,inf) when is_number(X),X >= 0 ->
    {St0,inf};
divide(St0,X,inf) when is_number(X),X < 0 ->
    {St0,ninf};
divide(St0,X,W) ->
    {St0,W / X}.
power(_St0,X,W) when is_record(X,c);is_record(W,c) ->
    throw("⋆: Arguments must be numbers");
power(St0,X,undefined) ->
    {St0,exp(X)};
power(St0,0,inf) ->
    {St0,1};
power(St0,X,inf) when X > 0 ->
    {St0,inf};
power(St0,X,inf) when X < 0 ->
    {St0,0};
power(St0,X,W) ->
    {St0,pow(W,X)}.
floor(St0,inf,_W) ->
    {St0,inf};
floor(St0,ninf,_W) ->
    {St0,ninf};
floor(_St0,X,_W) when not is_number(X),not is_record(X,c) ->
    throw("⌊: Cannot compare operations");
floor(St0,X,_W) when is_number(X) ->
    {St0,floor(X)}.
equals(St0,X,undefined) when is_record(X,a) ->
    {St0,length(X#a.sh)};
equals(St0,X,W) when is_number(X),is_number(W) ->
    % use '==' for float-to-int comparisons
    case X == W of true -> {St0,1}; false -> {St0,0} end;
equals(St0,X,W) ->
    case X =:= W of true -> {St0,1}; false -> {St0,0} end.
lesseq(St0,X,W) when X =:= W ->
    {St0,1};
lesseq(St0,X,inf) when is_record(X,c) ->
    {St0,1};
lesseq(St0,X,ninf) ->
    {St0,1};
lesseq(St0,X,inf) ->
    {St0,0};
lesseq(_St0,X,W) when is_record(X,bi);is_record(W,bi);is_record(X,tr);is_record(W,tr);is_function(X);is_function(W) ->
    throw("𝕨≤𝕩: Cannot compare operations");
lesseq(St0,X,W) ->
    {St0,T} = type(St0,X,undefined),
    {St0,S} = type(St0,W,undefined),
    R =
        case S =/= T of
            true ->
                S =< T;
            false ->
                case (X =:= ninf) or (W =:= inf) of
                    true ->
                        false;
                    false ->
                        W =< X
                end
        end,
    case R of true -> {St0,1}; false -> {St0,0} end.
shape(St0,X,undefined) ->
    {St0,list(ebqn_array:from_list(X#a.sh))}.
reshape(St0,X,undefined) ->
    {St0,arr(X#a.r,[maps:size(X#a.r)])};
reshape(St0,X,W) when is_record(W,a) ->
    {St0,arr(X#a.r,ebqn_array:to_list(W#a.r))};
reshape(St0,X,W) ->
    {St0,arr(X#a.r,W)}.
pick(St0,X,W) ->
    {St0,ebqn_array:get(trunc(W),X#a.r)}.
window(St0,X,undefined) ->
    {St0,list(ebqn_array:from_list(seq(0,trunc(X)-1)))}.
table_accm(F,I,E,{St0,M}) ->
    {St1,R} = call(St0,F,E,undefined),
    {St1,maps:put(I,R,M)}.
table(St0,F,X,undefined) ->
    {St1,Result} = ebqn_array:foldl(fun(I,E,A) -> table_accm(F,I,E,A) end,{St0,#{}},X#a.r),
    {St1,arr(Result,X#a.sh)};
table(St0,F,X,W) ->
    Xsize = maps:size(X#a.r),
    Rsize =  ebqn_array:new(Xsize*maps:size(W#a.r)),
    {St1,R} =
        maps:fold(fun (J,D,{StAccmO,AO}) -> maps:fold(fun(I,E,{StAccmI,AI}) ->
            {StAccm,Rtn} = call(StAccmI,F,E,D),
            {StAccm,ebqn_array:set(J*Xsize+I,Rtn,AI)} end,
            {StAccmO,AO},X#a.r)
        end,{St0,Rsize},W#a.r),
    {St1,arr(R,flatten(W#a.sh ++ X#a.sh))}.
% monadic scan inner with no modifier
scan_moni(X,I,C,R) when I =:= C ->
    R;
scan_moni(X,I,C,R) when I =/= C ->
    scan_moni(X,I+1,C,ebqn_array:set(I,ebqn_array:get(I,X#a.r),R)).
% monadic scan inner with modifier
scan_moni(St0,F,X,W,I,C,R) when I =:= C ->
    {St0,R};
scan_moni(St0,F,X,W,I,C,R) when I =/= C ->
    {St1,K} = call(St0,F,ebqn_array:get(I,X#a.r),ebqn_array:get(I,W#a.r)),
    scan_moni(St1,F,X,W,I+1,C,ebqn_array:set(I,K,R)).
% scan monadic outer
scan_mono(St0,F,X,I,C,R,L) when I =:= L ->
    {St0,arr(R,X#a.sh)};
scan_mono(St0,F,X,I,C,R,L) when I =/= L ->
    {St1,Rtn} = call(St0,F,ebqn_array:get(I,X#a.r),ebqn_array:get(I-C,R)),
    scan_mono(St1,F,X,I+1,C,ebqn_array:set(I,Rtn,R),L).
% scan dyadic inner
scan_dyi(St0,F,X,undefined,R,L) when L > 0 ->
    C = lists:foldl(fun(E,A) -> A*E end,1,tl(X#a.sh)),
    scan_mono(St0,F,X,C,C,scan_moni(X,0,C,R),L);
scan_dyi(St0,F,X,W,R,L) when L =:= 0 ->
    {St0,arr(R,X#a.sh)};
scan_dyi(St0,F,X,W,R,L) when L > 0 ->
    C = lists:foldl(fun(E,A) -> A*E end,1,tl(X#a.sh)),
    {St1,K} = scan_moni(St0,F,X,W,0,C,R),
    scan_mono(St1,F,X,C,C,K,L).
% scan dyadic outer
scan_dyo(St0,F,X,W) ->
    L = maps:size(X#a.r),
    R = ebqn_array:new(L),
    scan_dyi(St0,F,X,W,R,L).
scan(St0,F,X,undefined) when not is_record(X,a) ->
    throw("`: 𝕩 must have rank at least 1");
scan(St0,F,X,W) when is_record(X,a),length(X#a.sh) =:= 0 ->
    throw("`: 𝕩 must have rank at least 1");
scan(St0,F,X,undefined) when length(X#a.sh) > 0 ->
    scan_dyo(St0,F,X,undefined);
scan(St0,F,X,W) when length(X#a.sh) > 0,is_record(W,a),1 + length(W#a.sh) =/= length(X#a.sh) ->
    throw("`: rank of 𝕨 must be cell rank of 𝕩");
scan(St0,F,X,W) when length(X#a.sh) > 0,not is_record(W,a),1 =/= length(X#a.sh) ->
    throw("`: rank of 𝕨 must be cell rank of 𝕩");
scan(St0,F,X,W) when length(X#a.sh) > 0,is_record(W,a),is_list(W#a.sh) ->
    case not lists:all(fun({L,A}) ->  L =:= lists:nth(1+A,X#a.sh) end,lists:zip(W#a.sh,lists:seq(1,length(W#a.sh)))) of
        true ->
            throw("`: shape of 𝕨 must be cell shape of 𝕩");
        false ->
            ok
    end,
    scan_dyo(St0,F,X,W);
scan(St0,F,X,W) when length(X#a.sh) > 0,not is_record(W,a) ->
    W2 = ebqn:list(ebqn_array:from_list([W])),
    scan_dyo(St0,F,X,W2).
fill_by(St0,F,G,X,W) ->
    call(St0,F,X,W).
cases(St0,F,G,X,undefined) ->
    call(St0,F,X,undefined);
cases(St0,F,G,X,W) ->
    call(St0,G,X,W).
catches(St0,F,G,X,W) ->
    try call(St0,F,X,W) of
        Rtn ->
            Rtn
    catch
        _:_ ->
            call(St0,G,X,W)
    end.
fns() -> [fn(fun type/3),fn(fun fill/3),fn(fun log/3),fn(fun group_len/3),fn(fun group_ord/3),
                     fn(assert_fn("")),fn(fun plus/3),fn(fun minus/3),fn(fun times/3),fn(fun divide/3),
                     fn(fun power/3),fn(fun floor/3),fn(fun equals/3),fn(fun lesseq/3),fn(fun shape/3),
                     fn(fun reshape/3),fn(fun pick/3),fn(fun window/3),
                     r1(fun table/4),r1(fun scan/4),r2(fun fill_by/5),r2(fun cases/5),r2(fun catches/5)].
