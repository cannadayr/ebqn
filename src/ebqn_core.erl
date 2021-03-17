-module(ebqn_core).

-import(lists,[seq/2,flatten/1]).
-import(math,[log/1,exp/1,pow/2]).
-import(ebqn,[list/1,call/3,fmt/1]).

-export([fns/0]).
-export([arr/2,m1/1,m2/1,type/2,decompose/2,glyph/2,fill/2,log/2,plus/2,minus/2,times/2,divide/2,power/2,floor/2,equals/2,lesseq/2,shape/2,reshape/2,pick/2,window/2,table/1,scan/1,cases/2]).
-include("schema.hrl").

arr(R,Sh) ->
    #v{r=R,sh=Sh}.
m1(F) ->
    #m1{f=F}.
m2(F) ->
    #m2{f=F}.
is_array(X,_W) when is_record(X,v) ->
    1;
is_array(_X,_W) ->
    0.
type(X,_W) when is_function(X);is_record(X,bi) ->
    3;
type(X,_W) when is_record(X,m1) ->
    4;
type(X,_W) when is_record(X,m2) ->
    5;
type(X,_W) when is_record(X,v) ->
    0;
type(X,_W) when is_number(X) ->
    1;
type(X,_W) ->
    2.
decompose(X,W) ->
    case not is_function(X) of
        true ->
            list(ebqn_array:from_list([-1,X]));
        false ->
            % glyph & repr cases not implemented
            list(ebqn_array:from_list([1,X]))
    end.
glyph(X,W) ->
    throw("glyph not implemented").
% fill not yet implemented
fill(X,W) ->
    X.
log(X,undefined) ->
    log(X);
log(X,W) ->
    log(X) / log(W).
group_len(#v{r=X},_W) ->
    L = maps:fold(fun(_I,V,A) -> max(A,V) end,-1,X),
    R = ebqn_array:new(L+1,{default,0}),
    F = fun (_I,E,A) when E >= 0 -> ebqn_array:set(E,1+ebqn_array:get(E,A),A);
            (_I,_E,A)            -> A
    end,
    ebqn:list(maps:fold(F,R,X)).
group_ord(#v{r=X},#v{r=W}) ->
    {S,L} = maps:fold(fun(_I,V,{Si,Li}) -> {ebqn_array:concat(Si,ebqn_array:from_list([Li])),Li+V} end,{nil,0},W),
    R = ebqn_array:new(L),
    F = fun
        (I,V,{Si,Ri}) when V >= 0 ->
            {ebqn_array:set(V,1+ebqn_array:get(V,Si),Si),
                ebqn_array:set(ebqn_array:get(V,Si),I,Ri)};
        (_I,_V,A) ->
            A
    end,
    {_, O} = maps:fold(F,{S,R},X),
    list(O).
assert_fn(Pre) ->
    fun
        (X,W) when X =/= 1 ->
            throw({assert_fn,X,W});
        (X,W) ->
            X
    end.
plus(X,undefined) ->
    X;
plus(X,W) when is_list(X),is_list(W) ->
    throw("DomainError: +: cannot add char to char");
plus(X,W) when not is_number(X),not is_list(X) ->
    throw("DomainError: calling a number only function on a function and number");
plus(X,W) when not is_number(W),not is_list(W) ->
    throw("DomainError: calling a number only function on a function and number");
plus(X,W) when is_list(X),not is_list(W) ->
    [hd(X) + W];
plus(X,W) when is_list(W),not is_list(X) ->
    [hd(W) + X];
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
minus(X,undefined) when is_list(X) ->
    throw("DomainError: Expected number, got character");
minus(X,undefined) when not is_number(X) ->
    throw("DomainError: Expected number, got function");
minus(X,undefined) ->
    -1*X;
minus(X,W) when is_list(X),is_list(W) ->
    hd(W) - hd(X);
minus(X,W) when not is_list(X),is_list(W) ->
    [hd(W) - X];
minus(X,W) when is_list(X),not is_list(W) ->
    throw("DomainError: -: cannot operate on a number and character");
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
times(X,W) when is_list(X);is_list(W) ->
    throw("DomainError: calling a number only function on a number and character");
times(X,W) when not is_number(X),is_number(W) ->
    throw("DomainError: calling a number only function on a number and function");
times(X,W) when is_number(X),not is_number(W) ->
    throw("DomainError: calling a number only function on a number and function");
times(X,W) ->
    X*W.
divide(0,undefined) ->
    inf;
divide(inf,undefined) ->
    0;
divide(X,undefined) when is_list(X) ->
    throw("DomainError: Expected number, got character");
divide(X,undefined) ->
    1 / X;
divide(X,W) ->
    W / X.
power(X,undefined) when is_list(X) ->
    throw("DomainError: Expected number, got character");
power(X,undefined) ->
    exp(X);
power(X,W) when is_list(X),is_list(W) ->
    throw("DomainError: calling a number only function on a character and character");
power(X,W) when is_list(W) ->
    throw("DomainError: Expected number, got character");
power(X,W) ->
    pow(W,X).
floor(inf,_W) ->
    inf;
floor(ninf,_W) ->
    ninf;
floor(X,_W) when not is_number(X),not is_list(X) ->
    throw("DomainError: ⌊: argument contained a function");
floor(X,_W) when is_number(X) ->
    floor(X).
equals(#v{sh=S} = X,undefined) when is_record(X,v),is_list(S) ->
    length(S);
equals(X,W) ->
    % use '==' for float-to-int comparisons
    case X == W of true -> 1; false -> 0 end.
lesseq(X,W) when X =:= W ->
    1;
lesseq(X,inf) when is_list(X),hd(X) =:= 0 ->
    1;
lesseq(X,ninf) ->
    1;
lesseq(X,inf) ->
    0;
lesseq(X,W) when is_record(X,bi);is_record(W,bi);is_function(X);is_function(W) ->
    throw("DomainError: lesseq: Cannot compare functions");
lesseq(X,W) ->
    T = type(X,undefined),
    S = type(W,undefined),
    R =
        case S =/= T of
            true ->
                S =< T;
            false ->
                W =< X
        end,
    case R of true -> 1; false -> 0 end.
shape(#v{sh=Sh},undefined) ->
    list(ebqn_array:from_list(Sh)).
reshape(#v{r=X},undefined) ->
    arr(X,[maps:size(X)]);
reshape(#v{r=X},#v{r=W}) ->
    arr(X,ebqn_array:to_list(W));
reshape(#v{r=X},W) ->
    arr(X,W).
pick(#v{r=X} = Y,W) ->
    ebqn_array:get(trunc(W),X).
window(X,undefined) ->
    list(ebqn_array:from_list(seq(0,trunc(X)-1))).
table(F) ->
    fun
        (#v{r=R,sh=Sh},undefined) ->
            arr(maps:map(fun(_I,E) -> call(F,E,undefined) end,R),Sh);
        (#v{r=Xr,sh=Xsh},#v{r=Wr,sh=Wsh}) ->
            InitSize =  ebqn_array:new(maps:size(Xr)*maps:size(Wr)),
            Xs = maps:size(Xr),
            arr(maps:fold(fun(J,D,A1) -> maps:fold(fun(I,E,A2) -> ebqn_array:set(J*Xs+I,call(F,E,D),A2) end, A1, Xr) end,InitSize, Wr),flatten(Wsh ++ Xsh))
    end.
scan(F) ->
    fun
        (#v{r=X,sh=S},undefined) when length(S) > 0 ->
            L = maps:size(X),
            R = ebqn_array:new(L),
            H = fun
                (Ri,Li) when Li > 0 ->
                    C = lists:foldl(fun(E,A) -> A*E end,1,tl(S)),
                    G = fun
                        G(I,Ci,Rn) when I =/= Ci ->
                            G(I+1,Ci,ebqn_array:set(I,ebqn_array:get(I,X),Rn));
                        G(I,Ci,Rn) when I =:= Ci ->
                            Rn
                    end,
                    J = fun
                        J(I,Ci,Rn,Ln) when I =/= Ln ->
                            J(I+1,Ci,ebqn_array:set(I,call(F,ebqn_array:get(I,X),ebqn_array:get(I-C,Rn)),Rn),Ln);
                        J(I,_Ci,Rn,Ln) when I =:= Ln ->
                            Rn
                    end,
                    J(C,C,G(0,C,Ri),L);
                (Ri,_Li) ->
                    Ri
            end,
            arr(H(R,L),S)
    end.
% fill_by not yet implemented
fill_by(F,G) ->
    F.
% TODO add `setrepr`
cases(F,G) ->
    fun
        (X,undefined) ->
            call(F,X,undefined);
        (X,W) ->
            call(G,X,W)
    end.
fns() -> [fun type/2,fun decompose/2,fun glyph/2,fun fill/2,fun log/2,fun group_len/2,fun group_ord/2,
                     assert_fn(""),fun plus/2,fun minus/2,fun times/2,fun divide/2,
                     fun power/2,fun floor/2,fun equals/2,fun lesseq/2,fun shape/2,
                     fun reshape/2,fun pick/2,fun window/2,m1(fun table/1),m1(fun scan/1),m2(fun fill_by/2),m2(fun cases/2)].
