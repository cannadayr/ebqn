-module(ebqn_core).

-import(lists,[seq/2,flatten/1,duplicate/2,merge/1]).
-import(array,[new/1,new/2,resize/2,map/2,foldl/3,set/3,from_list/1,to_list/1,fix/1]).
-import(math,[log/1,exp/1,pow/2]).
-import(ebqn,[list/1,concat/2,fixed/1,call/3,fmt/1]).

-export([fns/0]).
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
type(_X,_W) ->
    0.
log(X,undefined) ->
    log(X);
log(X,W) ->
    log(X) / log(W).
group_len(#v{r=X},_W) ->
    L = foldl(fun(_I,V,A) -> max(A,V) end,-1,X),
    R = new(L+1,{default,0}),
    F = fun (_I,E,A) when E >= 0 -> set(E,1+array:get(E,A),A);
            (_I,_E,A)            -> A
    end,
    list(foldl(F,R,X)).
group_ord(#v{r=X},#v{r=W}) ->
    {S,L} = foldl(fun(_I,V,{Si,Li}) -> {concat(Si,fixed([Li])),Li+V} end,{nil,0},W),
    R = new(L),
    F = fun
        (I,V,{Si,Ri}) when V >= 0 ->
            {set(V,1+array:get(V,Si),Si),
                set(array:get(V,Si),I,Ri)};
        (_I,_V,A) ->
            A
    end,
    {_, O} = foldl(F,{S,R},X),
    list(O).
assert(X,undefined) ->
    case X=:=1 of true -> 1; false -> 0 end.
add(X,undefined) ->
    X;
add(X,W) when is_list(X),is_list(W) ->
    throw("DomainError: +: cannot add char to char");
add(X,W) when not is_number(X),not is_list(X) ->
    throw("DomainError: calling a number only function on a function and number");
add(X,W) when not is_number(W),not is_list(W) ->
    throw("DomainError: calling a number only function on a function and number");
add(X,W) when is_list(X),not is_list(W) ->
    [lists:nth(1,X) + W];
add(X,W) when is_list(W),not is_list(X) ->
    [lists:nth(1,W) + X];
add(inf,W) when is_number(W) ->
    inf;
add(X,W)  ->
    W + X.
subtract(inf,undefined) ->
    ninf;
subtract(ninf,undefined) ->
    inf;
subtract(inf,W) ->
    ninf;
subtract(X,undefined) ->
    -1*X;
subtract(X,W) when is_list(X),is_list(W) ->
    lists:nth(1,W) - lists:nth(1,X);
subtract(X,W) when not is_list(X),is_list(W) ->
    [lists:nth(1,W) - X];
subtract(X,W) when is_list(X),not is_list(W) ->
    throw("DomainError: -: cannot operate on a number and character");
subtract(X,W) when is_number(X),is_number(W) ->
    W-X.
multiply(X,undefined) when X < 0 ->
    -1;
multiply(X,undefined) when X =:= 0 ->
    0;
multiply(X,undefined) when X > 0 ->
    1;
multiply(inf,W) when W > 0 ->
    inf;
multiply(X,W) ->
    X*W.
divide(X,undefined)  ->
    1 / X;
divide(X,W) ->
    W / X.
power(X,undefined) ->
    exp(X);
power(X,W) when 0 > W  ->
    inf;
power(X,W)  ->
    pow(X,W).
minimum(X,_W) when is_number(X) ->
    floor(X).
equals(#v{sh=S} = X,undefined) when is_record(X,v),is_list(S) ->
    length(S);
equals(X,W) ->
    case X =:= W of true -> 1; false -> 0 end.
lesseq(X,W) when X =:= W ->
    1;
lesseq(X,W) ->
    case {is_record(X,v),is_record(W,v)} of
        {true,false}  -> 1;
        {false,true}  -> 0;
        {true,true}   ->
            #v{sh=Xs} = X,#v{sh=Ws} = W,
            case length(Xs) >= length(Ws) of
                true -> 1;
                false -> 0
            end;
        {false,false} ->
            case X >= W of
                true -> 1;
                false -> 0
            end
    end.
shape(#v{sh=Sh},undefined) ->
    list(fixed(Sh)).
reshape(#v{r=X},undefined) ->
    arr(X,[array:size(X)]);
reshape(#v{r=X},#v{r=W}) ->
    arr(X,to_list(W));
reshape(#v{r=X},W) ->
    arr(X,W).
pick(#v{r=X},W) ->
    array:get(W,X).
window(X,undefined) ->
    list(fixed(seq(0,trunc(X)-1))).
table(F) ->
    fun
        (#v{r=R,sh=Sh},undefined) ->
            arr(map(fun(_I,E) -> call(F,E,undefined) end,R),Sh);
        (#v{r=Xr,sh=Xsh},#v{r=Wr,sh=Wsh}) ->
            InitSize =  array:new(array:size(Xr)*array:size(Wr)),
            Xs = array:size(Xr),
            arr(foldl(fun(J,D,A1) -> foldl(fun(I,E,A2) -> array:set(J*Xs+I,call(F,E,D),A2) end, A1, Xr) end,InitSize, Wr),flatten(Wsh ++ Xsh))
    end.
scan(F) ->
    fun
        (#v{r=X,sh=S},undefined) when length(S) > 0 ->
            L = array:size(X),
            R = new(L),
            H = fun
                (Ri,Li) when Li > 0 ->
                    C = lists:foldl(fun(E,A) -> A*E end,1,lists:nthtail(1,S)),
                    G = fun
                        G(I,Ci,Rn) when I =/= Ci ->
                            G(I+1,Ci,set(I,array:get(I,X),Rn));
                        G(I,Ci,Rn) when I =:= Ci ->
                            Rn
                    end,
                    J = fun
                        J(I,Ci,Rn,Ln) when I =/= Ln ->
                            J(I+1,Ci,set(I,call(F,array:get(I,X),array:get(I-C,Rn)),Rn),Ln);
                        J(I,_Ci,Rn,Ln) when I =:= Ln ->
                            Rn
                    end,
                    J(C,C,G(0,C,Ri),L);
                (Ri,_Li) ->
                    Ri
            end,
            arr(H(R,L),S)
    end.
reorder(F,G) ->
    fun
        (X,undefined) ->
            call(F,X,undefined);
        (X,W) ->
            call(G,X,W)
    end.
fns() -> list(fixed([fun is_array/2,fun type/2,fun log/2,fun group_len/2,fun group_ord/2,
                     fun assert/2,fun add/2,fun subtract/2,fun multiply/2,fun divide/2,
                     fun power/2,fun minimum/2,fun equals/2,fun lesseq/2,fun shape/2,
                     fun reshape/2,fun pick/2,fun window/2,m1(fun table/1),m1(fun scan/1),m2(fun reorder/2)])).

