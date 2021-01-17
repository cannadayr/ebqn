-module(ebqn).

% ebqn:run(ebqn:runtime(b),ebqn:runtime(o),ebqn:runtime(s)).

-import(gb_trees,[insert/3,empty/0]).
-import(array,[new/2,resize/2,foldl/3,set/3,from_list/1,fix/1]).
-import(lists,[map/2]).
-import(queue,[cons/2,len/1,head/1,tail/1]).
-export([runtime/1]).
-export([run/3,concat/2,fixed/1,num/2,dbg/1]).

-record(e,{s,p}). % slots, parent
-record(m1,{f}).
-record(m2,{f}).
-record(v,{r,sh}).

dbg(X) ->
    io:format("~p~n",[X]).
kill() ->
    exit(self(),kill).
kill(A,B) when A =:= B ->
    exit(self(),kill);
kill(_A,_B) ->
    ok.

fixed(X) ->
    fix(resize(length(X),from_list(X))).
concat(X,W) ->
    Xs = array:size(X),
    Z = resize(Xs+array:size(W),X),
    foldl(fun(I,V,A) -> set(Xs+I,V,A) end,Z,W).
tail(L,A,S) when L =:= -1 ->
    {A,S};
tail(L,A,S) ->
    tail(L-1,set(L,head(S),A),tail(S)).

arr(R,Sh) -> #v{r=R,sh=Sh}.
list(A) -> arr(A,[array:size(A)]).
fns() -> array:new(21,fixed).

num(Binary,Ptr) ->
    {Size,Bitstring} = num(Binary,Ptr,0,<<>>),
    <<Value:Size/unsigned-integer>> = Bitstring,
    {Value,Ptr+trunc(Size/7)}.
num(Binary,Ptr,Size,Acc) ->
    <<H:1,Chunk:7/bitstring>> = binary_part(Binary,Ptr,1),
    num(Binary,Ptr,Size,Chunk,Acc,H).
num(_Binary,_Ptr,Size,Chunk,Acc,0) ->
    {Size+7,<<Chunk/bitstring,Acc/bitstring>>};
num(Binary,Ptr,Size,Chunk,Acc,1) ->
    num(Binary,Ptr+1,Size+7,<<Chunk/bitstring,Acc/bitstring>>).
ge(I,E,H) when I =:= 0 ->
    {E,gb_trees:get(E,H)};
ge(I,E,H) ->
    #e{p=P} = gb_trees:get(E,H),
    ge(I-1,P,H).

pe(B,P,4) ->
    num(B,P);
pe(B,P,15) ->
    num(B,P);
pe(B,P,21) ->
    {X,Xp} = num(B,P),
    {Y,Yp} = num(B,Xp),
    {{X,Y},Yp};
pe(B,P,22) ->
    {X,Xp} = num(B,P),
    {Y,Yp} = num(B,Xp),
    {{X,Y},Yp};
pe(_B,P,25) ->
    {undefined,P}.

se(_O,D,H,E0,S,X,4) ->
    {T,Si} = tail(X-1,array:new(X,fixed),S),
    cons(T,Si);
se(_O,D,H,E0,S,X,15) ->
    F = element(1+X,D),
    cons(F(H,E0),S);
se(_O,_D,H,E0,S,{X,Y},21) ->
    {T,#e{s=V}} = ge(X,E0,H),
    false = (undefined =:= array:get(Y,V)),
    cons({T,Y},S);
se(_O,_D,H,E0,S,{X,Y},22) ->
    {T,_} = ge(X,E0,H),
    cons({T,Y},S);
se(_O,_D,_H,_E0,S,_Arg,25) ->
     S.

he(H,_S,4) ->
    H;
he(H,_S,15) ->
    H;
he(H,_S,21) ->
    H;
he(H,_S,22) ->
    H;
he(H,_S,25) ->
    H.

ce(_S,4) ->
    cont;
ce(_S,15) ->
    cont;
ce(_S,21) ->
    cont;
ce(_S,22) ->
    cont;
ce(S,25) ->
    1 = len(S),
    head(S).

vm_switch(B,O,D,P,H,E,S,cont) ->
    ArgStart = P+1,
    {Op,ArgStart} = num(B,P),
        dbg({op,{Op,P}}),
    {Arg,ArgEnd} = pe(B,ArgStart,Op),
        dbg({args,{Arg,ArgEnd}}),
    Sn = se(O,D,H,E,S,Arg,Op),
        dbg({se,Sn}),
    Hn = he(H,S,Op),
        dbg({he,Hn}),
    Ctrln = ce(S,Op),
        dbg({ctrl,Ctrln}),
    vm_switch(B,O,D,ArgEnd,Hn,E,Sn,Ctrln);
vm_switch(_B,_O,_D,_P,_H,_E,_S,Rtn) ->
    Rtn.
vm(H,E,P) ->
    fun(B,O,D) ->
        vm_switch(B,O,D,P,H,E,queue:new(),cont)
    end.

run_env(H0,E0,V,ST) ->
    fun (SV) ->
        E = make_ref(),
        H = insert(E,#e{s=concat(SV,V),p=E0},H0),
        vm(H,E,ST)
    end.
run_block(T,I,ST,L) ->
    fun (H,E) ->
        dbg({block,{T,I,ST,L}}),
        V0 = new(L,fixed),
        C = run_env(H,E,V0,ST),
        F = case T of
            0 -> fun(N) -> N(new(0,fixed)) end;
            1 -> fun(N) -> R = fun R(F  ) -> N(fixed([R,F  ])) end,#m1{f=R} end;
            2 -> fun(N) -> R = fun R(F,G) -> N(fixed([R,F,G])) end,#m2{f=R} end
        end,
        G = case I of
            0 -> fun(V) -> fun R(X,W) -> C(concat(fixed([R,X,W]),fixed([V]))) end end;
            1 -> C
        end,
        F(G)
    end.
run_init(S) ->
    list_to_tuple(map(fun({T,I,ST,L}) -> run_block(T,I,ST,L) end,S)).
run(B,O,S) ->
    E = make_ref(),
    H = insert(E,#e{},empty()),
    D = run_init(S),
    F0 = element(1,D),
    F1 = F0(H,E),
    F2 = F1(B,O,D),
    F3 = F2(fns(),undefined),
    F3(B,O,D).

runtime(b) ->
    <<15,1,25,21,0,1,22,0,3,22,0,4,22,0,5,22,0,6,22,0,7,22,0,8,22,0,9,22,0,10,22,0,11,22,0,12,22,0,13,22,0,14,22,0,15,22,0,16,22,0,17,22,0,18,22,0,19,22,0,20,22,0,21,22,0,22,22,0,23,4,21,11,14,15>>;
runtime(o) ->
    {0,1,2,32,3,8,infinity,neg_infinity,-1};
runtime(s) ->
    [{0,1,0,0},{0,0,3,149}].
