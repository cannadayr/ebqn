-module(ebqn_core).

-import(lists,[seq/2,flatten/1]).
-import(math,[log/1,exp/1,pow/2]).
-import(ebqn,[list/1,call/4,fmt/1]).

-export([fns/0,fn/1]).
-export([arr/2,d1/1,d2/1,type/3,fill/3,log/3,group_len/3,group_ord/3,
         plus/3,minus/3,times/3,divide/3,power/3,floor/3,equals/3,lesseq/3,shape/3,
         reshape/3,pick/3,window/3,table/1,scan/1,fill_by/2,cases/2,assert_fn/1]).
-include("schema.hrl").

arr(R,Sh) ->
    #a{r=R,sh=Sh}.
fn(F) ->
    #fn{f=F}.
d1(F) ->
    #d1{f=F}.
d2(F) ->
    #d2{f=F}.
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
type(St0,X,_W) when is_number(X);X =:= inf; X =:= ninf ->
    {St0,1};
type(St0,X,_W) when is_record(X,c) ->
    {St0,2}.
fill(St0,X,undefined) ->
    {St0,0};
fill(St0,X,W) ->
    {St0,X}.
log(St0,X,undefined) ->
    {St0,log(X)};
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
plus(_St0,X,W) when (is_record(X,tr) or is_record(X,bi) or is_record(X,d1) or is_record(X,d2) or is_function(X))  or
               (is_record(W,tr) or is_record(W,bi) or is_record(W,d1) or is_record(W,d2) or is_function(W)) ->
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
minus(_St0,X,undefined) when not is_number(X) ->
    throw("-: Can only negate numbers");
minus(St0,X,undefined) ->
    {St0,-1*X};
minus(_St0,X,W) when (is_record(X,tr) or is_record(X,bi) or is_record(X,d1) or is_record(X,d2) or is_function(X))  or
                (is_record(W,tr) or is_record(W,bi) or is_record(W,d1) or is_record(W,d2) or is_function(W)) ->
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
divide(St0,X,W) ->
    {St0,W / X}.
power(_St0,X,W) when is_record(X,c);is_record(W,c) ->
    throw("⋆: Arguments must be numbers");
power(St0,X,undefined) ->
    {St0,exp(X)};
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
    %fmt({pick,X,W}),
    {St0,ebqn_array:get(trunc(W),X#a.r)}.
window(St0,X,undefined) ->
    {St0,list(ebqn_array:from_list(seq(0,trunc(X)-1)))}.
table(F) ->
    fn(fun
        (St0,X,undefined) ->
            Table = fun (I,E,{StAcc,M}) ->
                {St1,R} = call(StAcc,F,E,undefined),
                {St1,maps:put(I,R,M)}
            end,
            {St3,Result} = ebqn_array:foldl(Table,{St0,#{}},X#a.r),
            {St3,arr(Result,X#a.sh)};
        (St0,#a{r=Xr,sh=Xsh},#a{r=Wr,sh=Wsh}) ->
            InitSize =  ebqn_array:new(maps:size(Xr)*maps:size(Wr)),
            Xs = maps:size(Xr),
            {RtnSt,Rtn} = maps:fold(
                fun
                    (J,D,{StAcc1,A1}) -> maps:fold(
                        fun
                            (I,E,{StAcc2,A2}) ->
                                {StAcc3,Rtn2} = call(StAcc2,F,E,D),
                                {StAcc3,ebqn_array:set(J*Xs+I,Rtn2,A2)} end,
                        {StAcc1,A1}, Xr) end,
                        {St0,InitSize}, Wr),
                        {RtnSt,arr(Rtn,flatten(Wsh ++ Xsh))}
    end).
scan(F) ->
    fn(fun
        (St0,X,undefined) when not is_record(X,a) ->
            throw("`: 𝕩 must have rank at least 1");
        (St0,X,undefined) when is_record(X,a),length(X#a.sh) =:= 0 ->
            throw("`: 𝕩 must have rank at least 1");
        (St0,#a{r=X,sh=S},undefined) when length(S) > 0 ->
            L = maps:size(X),
            R = ebqn_array:new(L),
            H = fun
                (St1,Ri,Li) when Li > 0 ->
                    C = lists:foldl(fun(E,A) -> A*E end,1,tl(S)),
                    G = fun
                        G(I,Ci,Rn) when I =/= Ci ->
                            G(I+1,Ci,ebqn_array:set(I,ebqn_array:get(I,X),Rn));
                        G(I,Ci,Rn) when I =:= Ci ->
                            Rn
                    end,
                    J = fun
                        J(I,Ci,Rn,Ln,St2) when I =/= Ln ->
                            {St3,Rtn} = call(St2,F,ebqn_array:get(I,X),ebqn_array:get(I-C,Rn)),
                            J(I+1,Ci,ebqn_array:set(I,Rtn,Rn),Ln,St3);
                        J(I,_Ci,Rn,Ln,St2) when I =:= Ln ->
                            {St2,Rn}
                    end,
                    J(C,C,G(0,C,Ri),L,St1);
                (St1,Ri,_Li) ->
                    {St1,Ri}
            end,
            {St4,Rtn2} = H(St0,R,L),
            {St4,arr(Rtn2,S)};
        (St0,#a{r=X,sh=S},W) when length(S) > 0,is_record(W,a),is_list(W#a.sh) ->
            R1 = W#a.sh,
            Wr = length(R1),
            case 1+Wr =/= length(S) of
                true ->
                    throw("`: rank of 𝕨 must be cell rank of 𝕩");
                false ->
                    ok
            end,
            case not lists:all(fun({L,A}) ->  L =:= lists:nth(1+A,S) end,lists:zip(R1,lists:seq(1,length(R1)))) of
                true ->
                    throw("`: shape of 𝕨 must be cell shape of 𝕩");
                false ->
                    ok
            end,
            L = maps:size(X),
            R = ebqn_array:new(L),
            H = fun
                (St1,Ri,Li) when Li > 0 ->
                    C = lists:foldl(fun(E,A) -> A*E end,1,tl(S)),
                    G = fun
                        G(St6,I,Ci,Rn) when I =/= Ci ->
                            {St7,K1} = call(St6,F,ebqn_array:get(I,X),ebqn_array:get(I,W#a.r)),
                            G(St7,I+1,Ci,ebqn_array:set(I,K1,Rn));
                        G(St6,I,Ci,Rn) when I =:= Ci ->
                            {St6,Rn}
                    end,
                    J = fun
                        J(I,Ci,Rn,Ln,St2) when I =/= Ln ->
                            {St3,Rtn} = call(St2,F,ebqn_array:get(I,X),ebqn_array:get(I-C,Rn)),
                            J(I+1,Ci,ebqn_array:set(I,Rtn,Rn),Ln,St3);
                        J(I,_Ci,Rn,Ln,St2) when I =:= Ln ->
                            {St2,Rn}
                    end,
                    {St5,K} = G(St1,0,C,Ri),
                    J(C,C,K,L,St5);
                (St1,Ri,_Li) ->
                    {St1,Ri}
            end,
            {St4,Rtn2} = H(St0,R,L),
            {St4,arr(Rtn2,S)};
        (St0,#a{r=X,sh=S},W) when length(S) > 0,not is_record(W,a) ->
            Wr = 0,
            W2 = ebqn_array:from_list([W]),
            case 1+Wr =/= length(S) of
                true ->
                    throw("`: rank of 𝕨 must be cell rank of 𝕩");
                false ->
                    ok
            end,
            L = maps:size(X),
            R = ebqn_array:new(L),
            H = fun
                (St1,Ri,Li) when Li > 0 ->
                    C = lists:foldl(fun(E,A) -> A*E end,1,tl(S)),
                    G = fun
                        G(St6,I,Ci,Rn) when I =/= Ci ->
                            {St7,K1} = call(St6,F,ebqn_array:get(I,X),ebqn_array:get(I,W2)),
                            G(St7,I+1,Ci,ebqn_array:set(I,K1,Rn));
                        G(St6,I,Ci,Rn) when I =:= Ci ->
                            {St6,Rn}
                    end,
                    J = fun
                        J(I,Ci,Rn,Ln,St2) when I =/= Ln ->
                            {St3,Rtn} = call(St2,F,ebqn_array:get(I,X),ebqn_array:get(I-C,Rn)),
                            J(I+1,Ci,ebqn_array:set(I,Rtn,Rn),Ln,St3);
                        J(I,_Ci,Rn,Ln,St2) when I =:= Ln ->
                            {St2,Rn}
                    end,
                    {St5,K} = G(St1,0,C,Ri),
                    J(C,C,K,L,St5);
                (St1,Ri,_Li) ->
                    {St1,Ri}
            end,
            {St4,Rtn2} = H(St0,R,L),
            {St4,arr(Rtn2,S)}
    end).
fill_by(F,G) ->
    fn(fun(St0,X,W) ->
        call(St0,F,X,W)
    end).
cases(F,G) ->
    fn(fun
        (St0,X,undefined) ->
            call(St0,F,X,undefined);
        (St0,X,W) ->
            call(St0,G,X,W)
    end).
fns() -> [fn(fun type/3),fn(fun fill/3),fn(fun log/3),fn(fun group_len/3),fn(fun group_ord/3),
                     fn(assert_fn("")),fn(fun plus/3),fn(fun minus/3),fn(fun times/3),fn(fun divide/3),
                     fn(fun power/3),fn(fun floor/3),fn(fun equals/3),fn(fun lesseq/3),fn(fun shape/3),
                     fn(fun reshape/3),fn(fun pick/3),fn(fun window/3),
                     d1(fun table/1),d1(fun scan/1),d2(fun fill_by/2),d2(fun cases/2)].
