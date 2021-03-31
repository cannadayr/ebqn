-module(ebqn_core).

-import(lists,[seq/2,flatten/1]).
-import(math,[log/1,exp/1,pow/2]).
-import(ebqn,[list/1,call/4,fmt/1]).

-export([fns/0]).
-export([arr/2,m1/1,m2/1,type/2,decompose/2,glyph/2,fill/2,log/2,group_len/2,group_ord/2,
         plus/2,minus/2,times/2,divide/2,power/2,floor/2,equals/2,lesseq/2,shape/2,
         reshape/2,pick/2,window/2,table/1,scan/1,fill_by/2,cases/2]).
-include("schema.hrl").

arr(R,Sh) ->
    #a{r=R,sh=Sh}.
m(F) ->
    #m{f=F}.
m1(F) ->
    #m1{f=F}.
m2(F) ->
    #m2{f=F}.
is_array(X,_W) when is_record(X,a) ->
    1;
is_array(_X,_W) ->
    0.
type(X,_W) when is_function(X);is_record(X,bi) ->
    3;
type(X,_W) when is_record(X,m1);is_record(X,r1) ->
    4;
type(X,_W) when is_record(X,m2);is_record(X,r2) ->
    5;
type(X,_W) when is_record(X,a) ->
    0;
type(X,_W) when is_number(X);X =:= inf; X =:= ninf ->
    1;
type(X,_W) ->
    2.
decompose(X,W) ->
    list(ebqn_array:from_list([0,X])).
glyph(X,W) ->
    throw("glyph not implemented").
fill(X,undefined) ->
    0;
fill(X,W) ->
    X.
log(X,undefined) ->
    log(X);
log(X,W) ->
    log(X) / log(W).
group_len(X,_W) ->
    L = ebqn_array:foldl(fun(_I,V,A) -> max(A,V) end,-1,X#a.r),
    R = ebqn_array:new(L+1,0),
    F = fun (_I,E,A) when E >= 0 -> ebqn_array:set(E,1+ebqn_array:get(E,A),A);
            (_I,_E,A)            -> A
    end,
    ebqn:list(ebqn_array:foldl(F,R,X#a.r)).
group_ord(X,W) ->
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
    list(O).
assert_fn(Pre) ->
    fun
        (X,W) when X =/= 1 ->
            case W =/= undefined of
                true ->
                    throw({assert_fn,ebqn:strings(W)});
                false ->
                    throw({assert_fn,Pre})
            end;
        (X,W) ->
            X
    end.
plus(X,undefined) ->
    X;
plus(X,W) when is_record(X,c),is_record(W,c) ->
    throw("+: Cannot add two characters");
plus(X,W) when (is_record(X,tr) or is_record(X,bi) or is_record(X,m1) or is_record(X,m2) or is_function(X))  or
               (is_record(W,tr) or is_record(W,bi) or is_record(W,m1) or is_record(W,m2) or is_function(W)) ->
    throw("+: Cannot add non-data values");
plus(X,W) when is_record(X,c),not is_record(W,c) ->
    #c{p=X#c.p + W};
plus(X,W) when is_record(W,c),not is_record(X,c) ->
    #c{p=W#c.p + X};
plus(inf,W) when is_number(W) ->
    inf;
plus(X,W)  ->
    W + X.
minus(inf,undefined) ->
    ninf;
minus(ninf,undefined) ->
    inf;
minus(inf,W) ->
    ninf;
minus(X,undefined) when not is_number(X) ->
    throw("-: Can only negate numbers");
minus(X,undefined) ->
    -1*X;
minus(X,W) when (is_record(X,tr) or is_record(X,bi) or is_record(X,m1) or is_record(X,m2) or is_function(X))  or
                (is_record(W,tr) or is_record(W,bi) or is_record(W,m1) or is_record(W,m2) or is_function(W)) ->
    throw("-: Can only negate numbers");
minus(X,W) when is_record(X,c),is_record(W,c) ->
    W#c.p - X#c.p;
minus(X,W) when not is_record(X,c),is_record(W,c) ->
    P = W#c.p - X,
    case P < 0 of
        true ->
            throw("Invalid code point");
        false ->
            ok
    end,
    #c{p=P};
minus(X,W) when is_record(X,c),not is_record(W,c) ->
    throw("-: Can only negate numbers");
minus(X,W) when is_number(X),is_number(W) ->
    W-X.
times(X,undefined) when X < 0 ->
    -1;
times(X,undefined) when X =:= 0 ->
    0;
times(X,undefined) when X > 0 ->
    1;
times(inf,W) when W > 0 ->
    inf;
times(X,W) when is_record(X,c);is_record(W,c) ->
    throw("×: Arguments must be numbers");
times(X,W) when not is_number(X),is_number(W) ->
    throw("×: Arguments must be numbers");
times(X,W) when is_number(X),not is_number(W) ->
    throw("×: Arguments must be numbers");
times(X,W) ->
    X*W.
divide(0,undefined) ->
    inf;
divide(inf,undefined) ->
    0;
divide(X,W) when is_record(X,bi);is_record(X,tr);is_function(X) ->
    throw("÷: Arguments must be numbers");
divide(X,W) when is_record(X,c);is_record(W,c) ->
    throw("÷: Arguments must be numbers");
divide(X,undefined) ->
    1 / X;
divide(X,W) ->
    W / X.
power(X,W) when is_record(X,c);is_record(W,c) ->
    throw("⋆: Arguments must be numbers");
power(X,undefined) ->
    exp(X);
power(X,W) ->
    pow(W,X).
floor(inf,_W) ->
    inf;
floor(ninf,_W) ->
    ninf;
floor(X,_W) when not is_number(X),not is_record(X,c) ->
    throw("⌊: Cannot compare operations");
floor(X,_W) when is_number(X) ->
    floor(X).
equals(X,undefined) when is_record(X,a) ->
    length(X#a.sh);
equals(X,W) when is_number(X),is_number(W) ->
    % use '==' for float-to-int comparisons
    case X == W of true -> 1; false -> 0 end;
equals(X,W) ->
    case X =:= W of true -> 1; false -> 0 end.
lesseq(X,W) when X =:= W ->
    1;
lesseq(X,inf) when is_record(X,c) ->
    1;
lesseq(X,ninf) ->
    1;
lesseq(X,inf) ->
    0;
lesseq(X,W) when is_record(X,bi);is_record(W,bi);is_record(X,tr);is_record(W,tr);is_function(X);is_function(W) ->
    throw("𝕨≤𝕩: Cannot compare operations");
lesseq(X,W) ->
    T = type(X,undefined),
    S = type(W,undefined),
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
    case R of true -> 1; false -> 0 end.
shape(X,undefined) ->
    list(ebqn_array:from_list(X#a.sh)).
reshape(X,undefined) ->
    arr(X#a.r,[maps:size(X#a.r)]);
reshape(X,W) when is_record(W,a) ->
    arr(X#a.r,ebqn_array:to_list(W#a.r));
reshape(X,W) ->
    arr(X#a.r,W).
pick(X,W) ->
    ebqn_array:get(trunc(W),X#a.r).
window(X,undefined) ->
    list(ebqn_array:from_list(seq(0,trunc(X)-1))).
table(F) ->
    m(fun
        (St0,X,undefined) ->
            Table = fun (I,E,{StAcc,M}) ->
                {St1,R} = call(StAcc,F,E,undefined),
                {St1,maps:put(I,R,M)}
            end,
            {St2,Result} = maps:fold(Table,{St0,#{}},X#a.r),
            {St2,arr(Result,X#a.sh)};
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
    m(fun
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
            {St4,arr(Rtn2,S)}
    end).
fill_by(F,G) ->
    m(fun(St0,X,W) ->
        call(St0,F,X,W)
    end).
cases(F,G) ->
    m(fun
        (St0,X,undefined) ->
            call(St0,F,X,undefined);
        (St0,X,W) ->
            call(St0,G,X,W)
    end).
fns() -> [fun type/2,fun fill/2,fun log/2,fun group_len/2,fun group_ord/2,
                     assert_fn(""),fun plus/2,fun minus/2,fun times/2,fun divide/2,
                     fun power/2,fun floor/2,fun equals/2,fun lesseq/2,fun shape/2,
                     fun reshape/2,fun pick/2,fun window/2,
                     m1(fun table/1),m1(fun scan/1),m2(fun fill_by/2),m2(fun cases/2)].
