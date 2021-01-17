-module(ebqn).

% ebqn:run(ebqn:runtime(b),ebqn:runtime(o),ebqn:runtime(s)).

-import(gb_trees,[insert/3,empty/0]).
-import(array,[new/1,new/2,resize/2,foldl/3,set/3,from_list/1,fix/1]).
-import(lists,[map/2]).
-import(queue,[cons/2,len/1,head/1,tail/1,liat/1]).
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

fixed([nil]) ->
    nil;
fixed(X) ->
    fix(resize(length(X),from_list(X))).
concat(nil,nil) ->
    nil;
concat(X,nil) when X =/= nil ->
    X;
concat(nil,W) when W =/= nil ->
    W;
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
fns() -> list(new(21,{default,nullfn})).

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
hset(H,1,#v{r=IdR,sh=IdSh} = Id,{T,Z}) when is_record(Id,v) ->
    #e{s=Vd} = gb_trees:get(T,H),
    #v{r=VdR,sh=VdSh} = array:get(Z,Vd),
    true = (IdSh =:= VdSh),
    foldl(fun(J,N,A) -> hset(A,1,N,array:get(J,VdR)) end,H,IdR);
hset(H,1,{E,I},V) ->
    #e{s=A} = gb_trees:get(E,H),
    true = (array:get(I,A) =:= null),
    gb_trees:update(E,#e{s=array:set(I,V,A)},H).

pe(B,P,4) ->
    num(B,P);
pe(_B,P,11) ->
    {undefined,P};
pe(B,P,14) ->
    {undefined,P};
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

se(_O,_D,_H,_E0,S,X,4) ->
    {T,Si} = tail(X-1,new(X),S),
    cons(list(T),Si);
se(_O,_D,_H,_E0,S,undefined,11) ->
    tail(S);
se(_O,_D,_H,_E0,S,undefined,14) ->
    liat(S);
se(_O,D,H,E0,S,X,15) ->
    F = element(1+X,D),
    cons(F(H,E0),S);
se(_O,_D,H,E0,S,{X,Y},21) ->
    {T,#e{s=V}} = ge(X,E0,H),
    false = (null =:= array:get(Y,V)),
    cons({T,Y},S);
se(_O,_D,H,E0,S,{X,Y},22) ->
    {T,_} = ge(X,E0,H),
    cons({T,Y},S);
se(_O,_D,_H,_E0,S,undefined,25) ->
     S.

he(H,_S,4) ->
    H;
he(H,S,11) ->
    I = head(S),
    V = head(tail(S)),
    hset(H,1,I,V);
he(H,_S,14) ->
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
ce(_S,11) ->
    cont;
ce(_S,14) ->
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
        V0 = case L of
            0 -> nil;
            _ -> new(L,{default,null})
        end,
        C = run_env(H,E,V0,ST),
        F = case T of
            0 -> fun(N) -> N(nil) end;
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
    <<15,1,25,21,0,1,22,0,3,22,0,4,22,0,5,22,0,6,22,0,7,22,0,8,22,0,9,22,0,10,22,0,11,22,0,12,22,0,13,22,0,14,22,0,15,22,0,16,22,0,17,22,0,18,22,0,19,22,0,20,22,0,21,22,0,22,22,0,23,4,21,11,14,15,2,22,0,24,11,14,15,3,22,0,25,11,14,15,4,21,0,23,15,5,8,22,0,26,11,14,15,6,22,0,27,11,14,15,7,22,0,28,11,14,15,8,22,0,29,11,14,15,9,22,0,30,11,14,15,10,22,0,31,11,14,15,11,22,0,32,11,14,21,0,15,21,0,30,21,0,14,8,0,0,3,2,21,0,24,21,0,3,8,22,0,33,11,14,21,0,15,21,0,30,21,0,14,8,21,0,11,21,0,16,21,0,30,0,0,8,19,0,0,3,2,21,0,24,21,0,3,8,22,0,34,11,14,21,0,27,21,0,16,7,21,0,10,0,1,19,21,0,23,15,12,8,22,0,35,11,14,21,0,16,21,0,10,0,1,19,22,0,36,11,14,15,13,21,0,19,21,0,36,19,21,0,23,21,0,14,8,22,0,37,11,14,15,14,21,0,19,21,0,35,19,21,0,23,21,0,10,21,0,28,21,0,37,21,0,28,21,0,10,8,8,8,22,0,38,11,14,0,1,21,0,17,21,0,19,0,0,19,3,2,21,0,24,21,0,15,21,0,35,0,0,19,8,22,0,39,11,14,15,15,22,0,40,11,14,21,0,40,22,0,41,11,14,21,0,3,21,0,10,0,1,19,21,0,32,21,0,35,8,22,0,42,11,14,21,0,17,21,0,31,15,16,8,22,0,43,11,14,15,17,22,0,44,11,14,15,18,22,0,45,11,14,15,19,22,0,46,11,14,21,0,16,21,0,10,21,0,27,21,0,16,7,19,22,0,47,11,14,0,1,21,0,18,21,0,19,0,0,19,21,0,31,21,0,16,21,0,11,0,2,19,21,0,10,0,1,19,15,20,3,2,21,0,24,21,0,25,21,0,28,21,0,3,8,8,8,3,2,21,0,24,21,0,25,21,0,28,21,0,17,8,21,0,41,21,0,11,7,0,1,19,21,0,35,0,0,19,8,22,0,48,11,14,21,0,47,21,0,48,21,0,27,21,0,48,7,21,0,10,9,3,2,21,0,24,21,0,26,21,0,28,21,0,3,8,8,15,21,3,3,21,0,24,21,0,3,21,0,29,21,0,9,8,8,22,0,49,11,14,15,22,22,0,50,11,14,15,23,22,0,51,11,14,21,0,15,21,0,35,0,0,19,21,0,32,15,24,8,22,0,52,11,14,15,25,22,0,53,11,14,15,26,22,0,54,11,14,15,27,22,0,55,11,14,15,28,22,0,56,11,14,15,29,22,0,57,11,14,21,0,3,21,0,29,21,0,15,8,0,0,3,2,21,0,25,21,0,28,21,0,3,8,21,0,15,3,2,21,0,15,21,0,29,21,0,15,8,0,0,3,2,21,0,17,21,0,29,21,0,57,21,0,15,7,8,21,0,41,21,0,11,7,0,1,19,0,0,3,2,15,30,3,5,21,0,41,15,31,7,16,22,0,58,11,14,0,0,15,32,3,2,21,0,24,21,0,3,8,22,0,59,11,14,21,0,58,21,0,23,21,0,59,8,22,0,60,11,14,21,0,58,21,0,10,0,1,19,21,0,23,3,0,21,0,17,3,2,21,0,24,21,0,3,8,8,22,0,61,11,14,21,0,3,21,0,32,21,0,18,21,0,28,21,0,39,8,21,0,35,0,0,19,21,0,32,15,33,8,8,22,0,62,11,14,21,0,46,21,0,12,7,22,0,63,11,14,21,0,46,21,0,13,7,22,0,64,11,14,21,0,27,21,0,63,21,0,31,21,0,64,8,7,21,0,23,0,2,21,0,63,16,21,0,31,21,0,64,8,8,22,0,65,11,14,21,0,46,15,34,21,0,23,21,0,10,21,0,25,3,2,21,0,24,21,0,16,21,0,30,0,0,8,8,8,7,22,0,66,11,14,21,0,46,15,35,21,0,23,21,0,37,8,7,22,0,67,11,14,21,0,46,15,36,21,0,23,21,0,10,21,0,28,21,0,67,21,0,28,21,0,10,8,8,8,7,22,0,68,11,14,21,0,46,21,0,11,7,22,0,69,11,14,21,0,46,21,0,11,21,0,10,21,0,9,19,7,22,0,70,11,14,21,0,46,21,0,11,21,0,23,21,0,36,21,0,10,21,0,35,19,21,0,30,0,0,8,8,7,22,0,71,11,14,21,0,46,21,0,27,21,0,16,7,21,0,10,0,1,19,7,21,0,23,15,37,8,22,0,72,11,14,21,0,46,21,0,16,21,0,10,0,1,19,7,21,0,23,21,0,62,8,22,0,73,11,14,21,0,46,21,0,15,21,0,10,0,1,19,7,21,0,23,21,0,39,8,22,0,74,11,14,21,0,46,21,0,15,7,21,0,23,21,0,15,8,22,0,75,11,14,21,0,46,21,0,27,21,0,16,7,7,21,0,23,0,0,21,0,28,21,0,8,8,8,22,0,76,11,14,21,0,46,21,0,16,7,21,0,23,0,0,21,0,28,21,0,8,8,8,22,0,77,11,14,21,0,46,21,0,9,7,22,0,78,11,14,21,0,46,21,0,10,7,22,0,79,11,14,21,0,79,21,0,78,0,1,19,22,0,80,11,14,21,0,78,0,0,3,2,21,0,79,0,0,3,2,21,0,71,0,1,3,2,21,0,63,0,1,3,2,21,0,64,0,1,3,2,21,0,65,0,1,3,2,21,0,69,0,1,3,2,21,0,70,0,0,3,2,21,0,66,0,0,3,2,21,0,67,0,6,3,2,21,0,68,0,7,3,2,21,0,72,0,0,3,2,21,0,77,0,1,3,2,21,0,75,0,1,3,2,21,0,76,0,1,3,2,21,0,73,0,0,3,2,21,0,74,0,0,3,2,3,17,21,0,41,15,38,7,0,0,21,0,28,21,0,8,8,3,1,21,0,19,0,0,17,17,22,0,81,11,14,15,39,21,0,18,3,2,21,0,24,21,0,3,8,22,0,82,11,14,21,0,42,21,0,31,15,40,8,22,0,83,11,14,21,0,18,21,0,23,21,0,82,8,22,0,84,11,14,15,41,22,0,85,11,14,15,42,21,0,23,15,43,8,22,0,86,11,14,21,0,86,21,0,28,21,0,73,8,22,0,87,11,14,15,44,22,0,88,11,14,15,45,22,0,89,11,14,21,0,89,22,0,90,11,14,15,46,22,0,91,11,14,21,0,91,22,0,92,11,14,15,47,22,0,93,11,14,15,48,22,0,94,11,14,21,0,94,22,0,95,11,14,15,49,22,0,96,11,14,0,1,21,0,96,21,0,53,8,21,0,30,21,0,42,8,22,0,97,11,14,21,0,97,21,0,23,21,0,97,21,0,30,0,0,8,8,22,0,98,11,14,21,0,84,21,0,29,21,0,44,8,15,50,3,2,21,0,24,21,0,75,21,0,72,0,1,19,21,0,29,21,0,70,8,8,22,0,99,11,14,15,51,22,0,100,11,14,15,52,22,0,101,11,14,21,0,100,21,0,23,21,0,101,8,22,0,102,11,14,15,53,22,0,103,11,14,15,54,22,0,104,11,14,21,0,103,21,0,23,21,0,104,8,22,0,105,11,14,15,55,22,0,106,11,14,21,0,98,21,0,30,21,0,51,8,22,0,107,11,14,21,0,74,21,0,75,0,0,19,21,0,79,0,1,19,21,0,96,15,56,15,57,3,2,21,0,24,15,58,8,8,22,0,108,11,14,21,0,106,21,0,23,21,0,85,8,22,0,109,11,14,0,0,21,0,96,21,0,55,8,21,0,23,21,0,54,8,22,0,110,11,14,21,0,108,21,0,23,21,0,51,8,22,0,111,11,14,21,0,84,21,0,28,21,0,74,8,21,0,72,0,0,19,21,0,32,15,59,15,60,3,2,21,0,24,21,0,21,21,0,75,7,21,0,74,0,1,19,21,0,41,21,0,70,7,9,0,1,3,2,21,0,24,21,0,75,21,0,74,0,1,19,8,8,8,22,0,112,11,14,15,61,22,0,113,11,14,15,62,22,0,114,11,14,15,63,22,0,115,11,14,21,0,99,21,0,23,21,0,112,8,22,0,116,11,14,21,0,115,21,0,23,21,0,114,8,22,0,117,11,14,15,64,22,0,118,11,14,21,0,118,15,65,3,2,21,0,24,21,0,26,21,0,28,21,0,84,21,0,28,21,0,21,21,0,3,7,8,8,21,0,41,21,0,70,7,9,8,22,0,119,11,14,21,0,119,21,0,30,21,0,84,21,0,25,3,2,21,0,24,21,0,3,8,8,22,0,120,11,14,15,66,22,0,121,11,14,15,67,22,0,122,11,14,15,68,22,0,123,11,14,15,69,22,0,124,11,14,21,0,124,21,0,49,7,21,0,23,0,0,21,0,50,21,0,49,8,8,22,0,125,11,14,21,0,124,21,0,27,21,0,49,7,7,21,0,23,0,1,21,0,50,21,0,27,21,0,49,7,8,8,22,0,126,11,14,15,70,22,0,127,11,14,15,71,22,0,128,1,11,14,15,72,22,0,129,1,11,14,21,0,127,0,1,7,21,0,23,0,0,21,0,28,21,0,8,8,8,22,0,130,1,11,14,21,0,27,21,0,127,0,0,7,7,21,0,23,21,0,128,1,8,22,0,131,1,11,14,21,0,129,1,21,0,23,21,0,111,21,0,30,21,0,131,1,8,8,22,0,132,1,11,14,15,73,22,0,133,1,11,14,21,0,133,1,21,0,23,21,0,52,8,22,0,134,1,11,14,21,0,125,21,0,28,21,0,125,8,21,0,98,21,0,79,21,0,25,19,21,0,27,21,0,130,1,7,19,22,0,135,1,11,14,15,74,22,0,136,1,11,14,21,0,136,1,21,0,23,21,0,135,1,8,22,0,137,1,11,14,21,0,120,21,0,23,21,0,84,21,0,19,0,0,19,8,22,0,138,1,11,14,15,75,22,0,139,1,11,14,21,0,78,21,0,27,21,0,79,7,21,0,23,21,0,78,8,21,0,79,21,0,79,21,0,71,21,0,27,21,0,63,7,21,0,23,21,0,25,8,21,0,63,21,0,63,21,0,64,21,0,46,21,0,5,7,21,0,65,21,0,27,21,0,64,7,21,0,23,0,2,21,0,31,21,0,64,8,8,21,0,69,21,0,27,21,0,63,7,21,0,23,21,0,25,8,21,0,70,21,0,25,21,0,79,0,1,19,21,0,63,21,0,27,21,0,79,7,19,21,0,23,21,0,25,8,21,0,72,0,0,21,0,28,21,0,8,8,21,0,23,15,76,8,21,0,111,0,0,21,0,28,21,0,8,8,21,0,23,15,77,8,3,20,21,0,84,21,0,30,21,0,74,21,0,27,21,0,63,7,0,2,19,21,0,27,21,0,116,7,0,2,19,8,16,21,0,134,1,16,15,78,16,22,0,140,1,11,14,15,79,22,0,141,1,11,14,15,80,22,0,142,1,11,14,21,0,142,1,22,0,143,1,11,14,21,0,83,21,0,23,21,0,82,8,22,0,144,1,11,14,15,81,22,0,145,1,11,14,21,0,69,21,0,23,21,0,98,21,0,30,21,0,125,8,8,22,0,146,1,11,14,21,0,70,21,0,23,21,0,98,21,0,30,21,0,126,8,8,22,0,147,1,11,14,21,0,56,22,0,148,1,11,14,21,0,78,21,0,79,21,0,71,21,0,63,21,0,64,21,0,65,21,0,67,21,0,68,21,0,66,21,0,80,21,0,146,1,21,0,147,1,21,0,72,21,0,73,21,0,74,21,0,75,21,0,77,21,0,76,21,0,60,21,0,61,21,0,26,21,0,25,21,0,144,1,21,0,116,21,0,87,21,0,102,21,0,105,21,0,109,21,0,110,21,0,134,1,21,0,111,21,0,125,21,0,126,21,0,98,21,0,138,1,21,0,130,1,21,0,137,1,21,0,131,1,21,0,132,1,21,0,117,21,0,8,21,0,27,21,0,93,21,0,57,21,0,145,1,21,0,141,1,21,0,41,21,0,95,21,0,22,21,0,28,21,0,29,21,0,30,21,0,31,21,0,148,1,21,0,23,21,0,139,1,21,0,92,21,0,90,21,0,143,1,3,59,25,21,0,1,15,82,21,0,5,21,1,19,21,0,1,21,0,4,21,0,2,17,17,7,21,0,2,17,25,21,0,1,25,21,0,2,25,21,0,1,25,21,0,1,21,1,26,21,0,2,17,21,0,4,21,0,1,17,25,21,0,1,21,0,5,21,0,2,17,21,0,4,16,25,21,0,1,21,0,5,16,21,0,4,21,0,2,21,0,5,16,17,25,21,0,1,21,0,5,21,0,1,21,1,26,21,0,2,17,21,0,4,16,17,25,21,0,1,21,0,5,16,21,0,4,21,0,1,21,1,26,21,0,2,17,17,25,21,0,1,15,83,21,1,25,21,0,4,3,2,21,1,19,21,0,1,21,0,5,21,0,2,17,17,7,21,0,2,17,25,21,0,1,3,1,21,1,18,3,0,17,25,21,0,2,21,0,1,3,2,25,21,0,2,21,0,1,3,2,25,21,0,1,21,1,15,16,21,1,15,0,1,17,21,1,8,16,14,21,0,1,22,0,5,11,21,1,39,16,22,0,6,11,14,21,0,4,22,0,7,11,14,21,0,1,21,1,26,21,1,23,15,84,15,85,3,2,21,1,24,21,0,6,21,1,35,0,0,17,8,8,21,0,2,17,22,0,8,11,14,21,0,6,21,1,20,16,21,1,21,21,1,10,21,1,30,0,1,21,1,10,21,0,6,17,8,7,16,21,1,21,15,86,7,16,14,21,0,8,25,21,0,2,21,1,10,21,0,1,21,1,39,16,17,21,1,20,16,21,1,21,21,1,27,21,0,1,7,21,1,19,21,1,9,21,1,30,21,0,2,8,19,7,16,25,21,0,2,21,1,39,16,22,0,3,11,14,21,0,1,21,1,39,16,21,1,9,21,0,3,17,21,1,20,16,21,1,21,21,0,2,21,1,31,21,1,19,8,21,1,27,21,0,1,7,21,1,19,21,0,3,21,1,31,21,1,10,8,19,3,2,21,1,24,21,1,16,21,1,30,21,0,3,8,8,7,16,25,15,87,22,0,2,11,14,15,88,22,0,3,11,14,21,0,3,21,0,1,7,21,1,27,21,0,3,21,1,27,21,0,1,7,7,7,3,2,21,1,24,21,1,15,21,1,29,21,1,36,8,8,21,0,2,21,0,1,7,3,2,21,1,24,21,1,15,21,1,29,21,1,15,8,8,25,15,89,21,0,1,7,22,0,2,11,14,21,0,1,15,90,15,91,3,2,21,1,24,21,1,3,21,1,29,21,1,36,8,8,21,1,23,21,1,21,21,0,2,7,8,21,1,45,21,0,2,7,3,3,21,1,24,21,1,3,21,1,29,21,1,9,8,8,25,21,0,1,21,1,48,21,0,2,17,25,21,0,1,21,1,17,21,1,29,21,1,121,8,21,0,2,17,22,0,3,11,14,21,0,3,21,1,41,21,1,122,21,0,1,21,1,18,16,21,1,31,21,1,19,8,21,1,31,21,1,49,21,1,30,21,0,2,21,1,18,16,21,1,31,21,1,19,8,8,8,7,7,16,22,0,4,11,14,0,0,21,1,27,21,0,4,7,16,25,21,0,1,21,1,15,16,21,1,16,0,1,17,21,1,8,16,14,21,0,1,21,1,39,16,22,0,6,11,14,21,0,1,21,1,43,0,1,17,21,1,41,21,1,11,7,0,1,17,22,0,7,11,14,21,0,1,21,1,18,16,22,0,8,11,14,0,0,22,0,9,11,22,0,10,11,14,21,0,8,0,0,21,1,21,21,1,33,7,21,1,41,21,1,11,7,0,1,19,3,2,21,1,24,21,0,6,21,1,35,0,3,17,21,1,11,0,1,21,1,15,21,0,7,17,17,8,16,21,1,25,21,1,32,21,0,1,21,1,31,15,92,8,8,16,21,1,10,0,1,17,22,0,11,11,14,21,0,1,21,1,21,21,0,10,21,1,31,21,1,10,8,21,1,10,21,1,30,21,0,9,8,3,2,21,1,19,21,0,5,17,7,21,1,7,21,1,30,21,1,6,8,9,15,93,21,0,4,7,3,2,21,1,24,21,0,11,8,16,25,21,0,1,21,1,15,16,21,1,15,0,1,17,21,1,8,16,14,21,0,1,21,1,39,16,22,0,3,11,14,21,0,1,21,0,3,21,1,35,0,0,17,21,1,32,15,94,8,16,25,21,0,1,21,1,39,16,22,0,3,11,14,21,0,1,21,1,43,0,1,17,22,0,4,11,21,1,41,21,1,11,7,0,1,17,22,0,5,11,14,21,0,3,21,1,20,16,21,1,21,21,1,27,21,0,1,21,1,18,16,7,21,1,19,21,1,11,21,1,30,21,0,5,8,21,1,31,21,1,9,8,19,7,21,0,5,21,1,20,16,21,1,18,21,0,4,17,17,25,21,0,2,21,1,3,16,21,1,8,16,14,21,0,2,21,1,21,21,1,33,7,16,21,1,18,16,21,1,41,21,1,11,7,0,1,17,21,1,8,16,14,21,0,1,21,1,39,16,22,0,3,11,14,21,0,2,21,1,21,21,1,36,21,1,30,21,0,3,8,21,1,11,21,1,16,21,1,30,21,0,3,21,1,10,16,8,19,7,16,21,1,18,16,21,1,41,21,1,11,7,0,1,17,21,1,8,16,14,21,0,1,15,95,15,96,3,2,21,1,24,21,0,1,21,1,15,16,21,1,15,0,1,17,8,21,0,2,21,1,21,21,1,25,21,1,36,0,0,19,21,1,11,21,0,3,19,21,1,9,21,1,25,19,7,16,17,25,21,0,1,21,1,15,16,21,1,16,0,1,17,21,1,8,16,14,21,0,1,21,1,39,16,22,0,3,11,14,21,0,1,21,1,97,21,0,3,21,1,20,16,21,1,21,21,1,10,21,1,30,0,1,21,1,10,21,0,3,17,8,7,16,17,25,21,0,2,21,1,33,16,21,1,8,16,14,21,0,1,21,1,39,16,22,0,3,11,14,21,0,3,21,1,12,21,0,2,17,21,1,37,16,21,1,11,21,0,3,17,21,1,10,22,0,2,13,14,21,0,1,21,1,97,21,0,3,21,1,20,16,21,1,21,21,1,25,21,1,16,21,0,2,21,1,10,21,0,3,17,19,21,1,11,21,0,3,19,21,1,10,21,1,25,19,21,1,9,21,0,2,19,7,16,17,25,21,0,1,21,1,17,16,22,0,6,11,21,1,41,21,1,11,7,0,1,17,22,0,7,11,21,1,20,16,22,0,8,11,14,21,0,1,21,0,5,21,1,29,21,0,4,8,21,0,2,17,21,1,18,16,22,0,9,11,14,21,0,8,21,1,18,21,0,6,17,21,0,5,16,21,1,18,16,22,0,10,11,0,0,21,1,50,21,1,47,8,16,22,0,11,11,14,21,1,27,21,0,10,7,21,1,19,21,0,11,21,1,31,21,1,19,8,19,21,0,7,3,2,21,1,24,21,1,16,21,1,30,21,0,11,21,1,39,16,8,8,22,0,12,11,14,0,0,22,0,13,11,21,0,12,16,22,0,14,11,14,21,0,8,21,1,21,21,0,1,21,1,18,16,21,1,31,21,1,19,8,15,97,3,2,21,1,24,15,98,8,7,16,21,1,18,21,0,6,17,25,21,1,42,21,1,29,21,1,45,21,0,1,7,21,1,23,21,1,21,21,0,1,7,8,8,25,21,0,1,21,1,57,21,1,58,7,21,0,2,17,21,1,18,16,21,1,41,21,1,11,7,0,1,17,25,21,0,2,21,1,19,0,1,17,21,0,1,3,2,21,1,24,21,0,2,21,1,19,0,0,17,8,25,21,0,1,21,1,18,16,21,1,21,21,1,59,7,16,21,1,41,21,1,10,21,1,11,21,1,16,19,21,1,10,21,1,26,19,7,0,0,17,21,1,9,0,1,17,25,21,0,1,21,1,18,16,21,1,19,0,0,17,21,1,61,16,22,0,3,11,14,21,0,1,21,1,18,16,21,1,21,21,1,61,21,1,60,21,0,3,19,7,16,21,1,41,21,1,11,7,0,1,17,21,1,8,16,14,21,0,3,21,1,41,21,1,11,7,0,1,17,21,1,20,16,21,1,18,21,0,3,17,21,1,21,21,1,27,21,1,82,21,1,31,21,1,19,8,7,7,21,0,1,17,25,21,0,2,21,1,63,21,0,1,17,21,1,37,16,21,1,11,21,0,2,17,21,1,10,21,0,1,17,25,21,0,2,21,0,1,3,2,21,1,19,21,0,1,21,1,36,21,0,2,17,17,25,21,0,2,21,0,1,3,2,21,1,19,21,0,1,21,1,35,21,0,2,17,17,25,21,0,1,3,1,21,1,18,3,0,17,25,21,0,1,21,0,2,21,1,19,0,1,17,3,2,21,1,24,15,99,21,0,2,21,1,19,0,0,17,7,8,25,21,0,1,3,1,25,21,0,2,21,1,75,16,21,1,76,0,1,17,21,1,8,16,14,21,0,2,21,1,82,16,22,0,2,12,14,21,0,2,21,1,21,21,1,34,7,16,21,1,41,21,1,69,7,16,21,1,8,16,14,21,0,2,21,1,41,21,1,71,7,16,22,0,3,11,14,21,0,1,21,1,61,16,21,1,41,21,1,71,7,16,22,0,4,11,14,21,0,1,21,0,4,21,1,74,21,0,3,17,21,1,32,15,100,8,16,21,1,18,21,0,2,17,25,15,101,22,0,3,11,14,15,102,22,0,4,11,14,21,0,1,21,0,3,21,0,4,3,2,21,1,24,21,1,3,8,16,25,21,0,2,21,0,1,3,2,25,21,0,1,3,1,25,21,0,1,21,1,28,21,1,84,8,21,1,25,21,1,28,21,1,72,8,21,1,57,21,1,19,7,21,1,74,21,1,31,21,1,27,21,1,66,21,1,78,0,1,19,21,1,79,21,1,26,19,7,8,19,0,1,0,0,3,2,21,1,23,0,2,3,1,8,19,25,21,0,1,21,1,88,21,0,5,7,21,0,2,17,22,0,6,11,21,1,73,0,0,17,22,0,7,11,14,21,0,4,22,0,8,11,14,15,103,22,0,9,11,14,21,0,1,21,0,9,21,0,6,7,21,0,2,17,25,21,0,1,21,1,88,21,0,5,7,21,1,57,21,1,79,21,1,31,21,1,67,8,21,1,79,21,1,68,0,0,19,3,2,21,1,24,21,1,25,21,1,77,0,0,19,8,7,21,1,75,21,1,29,21,1,86,8,19,21,0,2,17,22,0,6,11,14,15,104,22,0,7,11,14,21,1,25,21,1,72,9,21,0,7,21,1,25,21,1,21,21,1,72,7,9,3,3,21,1,24,21,1,75,21,1,31,21,1,76,8,21,1,78,0,0,21,1,31,21,1,73,8,19,8,22,0,7,12,14,21,0,1,21,0,7,21,0,6,21,1,19,21,1,30,21,1,74,21,1,27,21,1,79,7,0,1,19,8,16,17,21,1,57,21,0,4,7,21,0,2,21,0,7,21,0,6,21,1,19,0,0,17,17,17,21,1,73,16,25,0,8,21,1,92,21,0,1,8,25,21,0,1,21,1,75,16,21,1,77,0,1,17,21,1,8,16,14,21,0,1,21,1,93,21,1,72,7,16,21,1,41,21,0,4,7,21,0,2,17,25,21,0,1,22,0,3,11,14,15,105,15,106,3,2,21,1,24,21,1,26,21,1,28,21,1,60,21,1,72,21,0,2,19,8,8,25,21,0,1,21,1,61,21,1,29,21,1,86,8,21,0,2,17,22,0,3,11,14,21,0,3,21,1,21,21,1,74,7,16,22,0,4,11,21,1,41,21,1,68,7,0,1,17,22,0,5,11,14,21,0,4,21,1,79,21,0,5,17,21,1,76,0,1,17,21,1,41,21,1,69,7,16,21,1,8,16,14,21,0,3,21,1,57,21,1,98,21,1,30,0,1,21,1,79,21,0,5,17,21,1,20,16,21,1,31,21,1,78,8,8,7,21,0,5,21,1,80,21,0,4,17,17,22,0,6,11,14,21,0,6,21,1,41,21,1,60,7,16,21,1,8,16,14,21,0,3,21,1,57,0,1,21,1,25,21,1,19,0,0,19,3,2,21,1,24,21,1,26,8,7,21,0,4,21,1,75,21,0,5,17,17,21,1,41,21,1,78,7,16,22,0,7,11,14,21,0,1,21,1,84,21,1,29,21,1,44,8,21,0,2,17,21,1,84,21,0,6,21,1,19,0,0,17,21,1,44,21,0,7,3,1,17,17,25,15,107,22,0,3,11,14,21,0,1,21,1,84,21,1,84,21,1,61,21,1,28,21,1,44,21,1,30,21,1,25,21,1,74,21,1,29,21,1,79,8,21,0,2,19,21,1,68,0,0,19,21,1,20,21,1,28,21,1,21,0,1,7,8,9,8,8,19,16,0,0,21,1,96,21,0,3,8,21,0,2,17,25,21,0,1,21,1,75,16,21,1,77,0,1,17,21,1,8,16,14,21,0,1,21,1,74,16,21,1,78,0,1,17,21,1,20,16,21,1,21,21,0,1,21,1,31,21,1,100,8,7,16,25,21,0,1,21,1,61,16,21,1,74,21,1,31,21,1,79,8,21,1,68,0,0,19,21,1,20,21,1,28,21,1,21,0,1,7,8,9,21,1,27,21,1,44,7,21,1,25,19,21,1,102,21,1,26,19,21,0,2,21,1,74,16,17,22,0,3,11,14,21,0,1,21,1,102,21,0,2,21,1,67,21,0,3,17,21,1,68,21,0,3,21,1,79,16,17,21,1,78,0,0,21,1,73,21,0,2,17,21,1,64,0,8,17,21,1,71,21,0,3,17,17,17,25,21,0,1,21,1,75,16,21,1,77,0,1,17,21,1,8,16,14,21,0,1,21,1,74,16,21,1,78,0,1,17,21,1,20,16,21,1,21,21,0,1,21,1,31,21,1,103,8,7,16,25,21,0,1,21,1,3,16,21,1,8,16,14,21,0,2,21,1,75,16,21,1,76,0,1,17,21,1,8,16,14,21,0,1,21,1,61,16,21,1,74,21,1,29,21,1,77,8,21,0,2,17,21,1,8,16,14,21,0,2,21,1,84,16,21,1,21,21,1,34,7,16,21,1,41,21,1,69,7,16,21,1,8,16,14,21,0,1,21,1,61,16,21,1,102,21,0,2,21,1,74,16,17,22,0,3,11,14,21,0,3,21,1,78,0,1,17,21,1,77,21,0,2,17,21,1,41,21,1,69,7,16,21,1,8,16,14,21,0,1,21,0,2,21,1,74,16,21,1,72,0,0,17,21,1,32,15,108,8,21,0,2,17,25,21,0,1,21,1,107,21,1,30,21,1,21,21,0,2,7,8,16,25,21,0,1,21,1,74,21,1,29,21,1,75,8,21,0,2,17,21,1,8,16,14,21,0,1,21,1,107,21,0,2,17,25,21,0,2,21,1,75,16,21,1,72,0,0,17,25,0,8,22,0,3,11,22,0,4,11,14,3,0,22,0,5,11,14,21,0,1,22,0,6,11,14,21,0,1,21,1,21,21,1,74,7,16,21,1,111,16,21,1,21,15,109,7,16,25,21,1,25,21,1,41,21,1,21,21,1,44,21,1,30,21,1,84,8,7,7,3,0,21,1,72,16,19,22,0,3,11,14,21,0,1,21,1,3,16,21,1,8,16,14,21,0,1,21,1,21,21,1,61,7,16,22,0,4,11,14,21,0,4,21,1,84,16,21,1,19,0,0,17,21,1,74,16,22,0,5,11,14,21,0,4,21,1,21,21,1,74,7,16,21,1,75,21,0,5,17,21,1,84,16,21,1,41,21,1,69,7,16,21,1,8,16,14,21,0,1,21,1,75,16,21,1,76,21,0,5,17,21,1,8,16,14,21,0,1,22,0,6,11,21,1,75,16,22,0,7,11,21,1,109,16,22,0,8,11,21,1,57,15,110,7,21,0,1,21,1,61,16,17,22,0,9,11,14,21,0,9,21,0,3,16,21,1,60,21,0,4,21,1,21,21,1,102,21,1,30,21,0,7,8,7,16,17,21,1,8,16,14,21,0,9,21,1,21,15,111,7,16,21,0,3,16,22,0,10,11,14,21,0,1,21,1,111,21,0,9,17,21,1,57,21,1,98,21,1,30,21,1,21,21,1,72,7,8,7,21,0,10,17,21,1,73,16,25,21,0,1,21,1,75,16,21,1,75,0,1,17,21,1,8,16,14,21,0,1,21,1,21,21,1,33,7,16,21,1,41,21,1,69,7,16,21,1,8,16,14,21,0,1,21,1,77,0,8,17,21,1,41,21,1,69,7,16,21,1,8,16,14,21,0,1,21,1,7,21,0,1,21,1,6,16,22,0,5,11,17,22,0,6,11,14,0,0,22,0,7,11,14,21,0,5,21,1,21,21,1,109,21,1,28,21,1,21,15,112,7,8,21,0,4,9,7,16,25,21,0,1,21,1,3,16,21,1,8,16,14,21,1,113,21,1,25,7,22,0,3,11,14,21,0,1,21,0,3,21,1,21,21,0,3,7,21,1,41,21,1,21,21,1,21,21,1,44,21,1,30,21,1,84,8,7,7,7,3,0,21,1,72,16,21,1,72,16,19,3,2,21,1,24,21,1,60,21,1,72,0,1,19,8,16,25,21,0,1,21,1,3,16,21,1,8,16,14,21,0,2,21,1,60,16,21,1,72,0,1,17,22,0,3,11,14,21,0,2,21,1,74,15,113,3,2,21,1,24,21,0,3,8,16,22,0,4,11,14,21,0,1,21,1,61,16,21,1,74,21,1,29,21,1,77,8,21,0,4,17,21,1,8,16,14,21,0,1,21,1,61,16,21,1,102,21,1,30,21,1,74,8,21,0,4,17,21,1,75,21,0,4,17,21,1,41,21,1,69,7,16,21,1,8,16,14,21,0,1,21,1,26,21,1,113,21,0,1,21,1,31,21,1,98,8,7,9,15,114,3,2,21,1,24,21,0,3,8,21,0,2,17,25,21,0,2,21,1,75,16,21,1,75,0,1,17,21,1,8,16,14,21,0,1,21,1,61,16,22,0,3,11,21,1,74,21,1,29,21,1,75,8,21,0,2,17,21,1,8,16,14,21,0,2,21,1,21,21,1,33,7,16,21,1,41,21,1,69,7,16,21,1,8,16,14,21,0,3,21,1,72,21,1,69,21,1,79,21,1,31,21,1,76,8,19,21,0,2,17,21,1,41,21,1,69,7,16,21,1,8,16,14,0,0,21,1,72,21,0,2,17,21,1,71,21,0,3,17,21,1,78,21,0,2,17,22,0,2,12,14,21,0,2,21,1,74,16,21,1,80,21,1,30,21,1,109,8,16,21,1,79,16,21,1,41,21,1,25,21,1,71,21,0,3,21,1,31,21,1,19,8,19,21,1,78,21,0,2,21,1,31,21,1,19,8,19,7,0,0,17,21,1,27,21,1,19,7,21,0,1,21,1,84,16,17,25,21,0,2,21,1,21,21,0,1,21,1,31,21,1,119,8,7,16,25,21,0,1,21,1,75,21,1,30,0,0,8,21,1,41,21,1,70,7,9,21,1,29,21,1,27,21,1,79,7,8,21,0,2,17,22,0,3,11,14,21,0,1,0,0,21,0,3,3,2,15,115,3,2,21,1,24,0,0,21,1,75,21,0,3,17,8,21,0,2,17,25,21,0,4,22,0,5,11,14,21,0,2,22,0,6,11,14,21,0,1,22,0,7,11,14,15,116,22,0,8,11,14,21,0,4,21,1,75,21,1,30,0,0,8,21,1,32,21,0,1,8,9,21,0,8,3,2,21,1,19,21,0,6,21,1,74,0,1,17,17,25,21,0,1,22,0,2,11,14,21,1,72,21,1,30,0,0,8,21,1,32,15,117,8,25,21,0,2,21,1,75,16,21,1,27,21,1,79,7,0,1,17,22,0,5,11,14,21,0,5,21,1,77,0,0,17,21,1,8,16,14,21,0,1,21,1,75,16,21,1,77,21,0,5,17,21,1,8,16,14,21,0,2,21,1,43,0,1,17,22,0,6,11,21,1,41,21,1,71,7,16,22,0,7,11,14,0,0,21,1,122,21,0,2,21,1,84,16,21,1,31,21,1,19,8,21,1,29,21,0,4,8,7,21,0,7,17,22,0,8,11,14,21,0,2,21,1,74,16,0,1,0,1,21,1,31,21,1,79,21,1,28,21,1,109,8,8,21,1,71,21,0,7,19,21,1,21,21,1,78,21,1,30,21,0,7,8,21,1,31,21,0,8,8,7,9,21,1,27,21,1,77,7,0,0,19,21,1,41,21,1,69,7,9,3,2,21,1,24,21,1,72,21,1,30,0,0,8,8,16,21,1,8,16,14,21,0,1,21,1,75,16,21,1,27,21,1,79,7,21,0,5,17,22,0,9,11,14,21,0,1,21,1,43,21,0,9,17,22,0,10,11,14,21,0,10,21,1,121,21,0,6,17,22,0,11,11,14,21,0,11,21,1,41,21,1,122,21,0,1,21,1,84,16,21,1,31,21,1,19,8,21,1,31,21,0,4,21,1,30,21,0,2,21,1,84,16,21,1,31,21,1,19,8,8,8,7,7,16,22,0,12,11,14,21,1,27,0,0,7,21,1,77,21,0,12,21,1,30,21,1,71,21,1,30,21,0,6,21,1,41,21,1,71,7,16,8,8,19,22,0,13,11,14,21,0,9,21,1,109,16,21,1,21,21,0,1,21,1,61,16,21,1,31,21,1,19,8,7,16,21,1,41,21,1,71,7,21,1,109,9,21,1,31,21,1,84,8,16,21,1,71,21,0,10,21,1,41,21,1,71,7,16,17,21,1,21,15,118,21,1,30,21,0,2,21,1,74,16,8,7,16,25,21,0,1,22,0,2,11,14,21,1,95,21,1,69,7,21,1,80,9,21,1,22,21,1,69,7,21,1,95,21,1,78,7,9,3,2,21,1,19,21,0,1,17,22,0,3,11,14,15,119,25,21,0,1,21,1,75,16,21,1,77,0,1,17,21,1,8,16,14,21,0,1,21,1,125,16,22,0,3,11,14,21,0,1,21,1,74,16,21,1,109,16,21,1,21,0,1,21,1,25,21,0,1,21,1,75,21,1,72,0,1,19,21,1,32,21,1,93,21,1,72,7,8,16,21,1,98,21,0,3,17,21,1,31,21,1,19,8,21,1,29,21,1,61,8,0,1,21,1,31,21,1,79,8,19,3,2,21,1,24,21,1,72,21,1,30,0,0,8,8,7,16,21,1,98,21,0,3,21,1,7,21,1,30,21,1,57,0,1,7,8,16,17,25,21,0,2,21,1,75,16,22,0,3,11,14,21,0,1,21,1,75,16,21,1,77,21,0,3,17,21,1,8,16,14,21,0,1,21,0,3,21,1,92,21,1,109,8,21,0,2,21,1,61,16,17,21,0,3,21,1,92,21,1,60,8,21,0,2,17,25,21,0,1,21,1,60,21,1,75,0,0,19,21,1,32,21,1,72,8,16,22,0,1,12,14,21,0,2,21,1,75,16,21,1,76,0,1,17,21,1,8,16,14,21,0,2,21,1,84,16,22,0,2,12,14,21,0,1,21,1,61,16,21,1,74,21,1,29,21,1,77,8,21,0,2,17,21,1,8,16,14,21,0,2,21,1,84,16,21,1,21,21,1,34,7,16,21,1,41,21,1,69,7,16,21,1,8,16,14,21,0,2,21,1,131,1,16,21,1,80,16,21,1,41,21,1,78,7,16,21,1,79,21,0,1,21,1,75,16,17,22,0,3,11,14,21,0,3,21,1,72,21,0,2,17,21,1,41,21,1,69,7,16,21,1,8,16,14,21,0,3,21,1,109,16,21,1,25,21,1,111,21,1,27,21,1,131,1,21,1,28,21,1,80,8,7,19,21,0,2,17,21,1,116,21,0,2,17,22,0,2,12,14,21,0,1,21,1,61,16,21,1,117,21,0,2,17,21,1,21,21,1,41,21,1,67,7,7,16,21,1,109,16,21,1,21,21,1,27,21,0,1,7,21,1,120,21,1,98,21,1,30,21,0,2,8,19,7,16,25,21,0,1,21,1,130,1,21,1,30,21,0,2,8,21,1,135,1,21,1,31,21,1,93,21,1,87,7,8,9,21,1,29,21,1,130,1,8,21,0,2,17,25,21,0,1,15,120,21,0,5,21,1,138,1,21,0,1,21,0,4,21,0,2,17,17,7,21,0,2,17,25,21,0,1,21,1,3,16,21,1,8,16,14,21,0,1,21,1,75,16,21,1,75,0,0,17,21,1,8,16,14,21,0,1,21,1,138,1,16,25,21,0,1,21,1,75,16,21,1,75,0,1,17,21,1,8,16,14,21,0,1,21,1,21,21,1,34,7,16,21,1,41,21,1,69,7,16,21,1,8,16,14,21,0,1,21,1,105,21,1,30,0,1,8,21,1,77,21,1,105,21,1,30,0,8,8,19,21,1,41,21,1,69,7,9,16,21,1,8,16,14,21,0,1,21,1,6,16,25,21,1,27,0,0,21,1,28,21,1,8,8,3,1,21,1,116,21,0,1,21,1,98,0,1,17,17,7,21,1,138,1,21,1,72,21,1,130,1,21,0,1,21,1,98,0,0,17,19,21,1,138,1,9,19,25,21,0,1,21,1,140,1,16,25,21,0,1,21,0,5,21,0,2,17,22,0,6,11,14,0,0,22,0,7,11,22,0,8,11,14,21,0,6,0,0,21,1,90,15,121,8,16,14,21,0,1,22,0,9,11,14,15,122,22,0,10,11,14,21,0,7,21,0,10,21,1,25,21,0,4,21,0,2,19,7,16,22,0,11,11,14,21,0,8,21,1,79,16,21,0,10,21,1,25,21,1,141,1,21,0,4,7,21,0,2,19,7,16,22,0,12,11,14,21,0,6,0,0,21,1,90,21,1,27,21,0,11,21,0,12,3,2,7,21,1,138,1,0,0,21,1,31,21,1,72,8,19,21,1,138,1,21,1,66,19,8,16,25,21,1,42,21,1,29,21,1,21,21,0,1,7,8,25,21,0,1,25,21,0,1,25,21,0,1,14,21,1,7,21,2,81,16,25,0,1,21,2,10,21,1,6,17,22,1,6,12,14,21,0,1,21,2,19,21,1,6,17,25,21,1,8,21,1,7,21,1,5,21,2,19,21,0,1,17,17,22,1,8,12,25,21,0,2,21,2,17,16,22,0,5,11,14,21,0,2,21,2,15,16,21,2,20,16,21,2,41,21,2,11,21,2,30,21,0,1,21,2,17,16,21,2,31,21,2,19,8,21,2,15,21,0,5,21,2,31,21,2,19,8,19,8,7,0,1,17,21,2,8,16,14,21,0,5,21,2,41,21,2,11,7,0,1,17,21,2,20,16,21,2,21,21,0,1,21,2,18,16,21,2,31,21,2,19,8,21,0,4,21,0,2,21,2,18,16,21,2,31,21,2,19,8,19,7,16,21,2,18,21,0,5,17,25,21,0,2,21,2,17,16,22,0,5,11,14,21,0,2,21,2,15,16,22,0,6,11,14,21,0,1,21,2,17,16,22,0,7,11,14,21,0,6,21,2,20,16,21,2,41,21,2,11,21,2,30,21,0,7,21,2,31,21,2,19,8,21,2,15,21,0,5,21,2,31,21,2,19,8,19,8,7,0,1,17,21,2,8,16,14,21,0,6,21,2,10,21,0,1,21,2,15,16,17,21,2,20,16,21,2,41,21,2,11,21,2,30,21,2,9,21,2,30,21,0,6,8,21,2,27,21,2,19,7,21,0,7,19,8,7,0,1,17,22,0,8,11,14,21,0,2,21,2,18,16,22,0,9,11,14,21,0,1,21,2,18,16,22,0,10,11,14,21,0,8,21,2,20,21,2,29,21,2,21,21,2,27,21,0,10,7,21,2,19,21,2,9,21,2,30,21,2,11,21,2,30,21,0,8,8,8,19,21,0,4,21,0,9,21,2,31,21,2,19,8,19,7,8,21,0,9,21,2,39,16,17,21,2,18,16,21,2,18,21,0,7,17,25,21,0,1,21,2,46,21,0,4,7,21,0,2,17,25,21,0,1,21,2,21,15,123,21,0,2,7,7,16,25,21,0,2,21,2,21,15,124,21,0,1,7,7,16,25,21,1,6,21,2,11,0,2,17,21,2,16,21,0,1,21,2,41,21,2,37,7,16,22,1,10,12,21,2,10,21,0,1,21,2,41,21,2,38,7,16,22,1,9,12,17,17,25,21,0,1,14,21,2,27,0,0,7,21,2,36,0,0,21,2,122,21,1,8,21,2,31,21,2,19,8,21,2,29,21,0,4,8,7,21,1,7,17,19,22,0,5,11,14,21,2,25,21,1,6,3,2,21,2,24,21,2,16,21,2,30,21,1,6,8,8,22,0,6,11,14,0,0,21,2,15,21,1,6,17,21,2,9,21,1,6,17,21,2,5,0,2,17,21,2,38,16,22,0,7,11,21,2,20,16,21,2,21,21,2,25,21,2,9,0,1,19,21,2,10,21,0,7,19,21,2,13,0,2,19,7,16,21,2,41,15,125,7,21,1,6,21,2,20,16,17,25,21,0,1,21,2,21,21,2,34,7,16,21,2,41,21,2,11,7,0,1,17,21,2,8,16,14,0,1,21,2,10,21,1,3,17,22,0,3,11,14,21,2,25,21,2,10,21,0,3,19,21,2,27,21,2,19,7,21,1,3,21,2,20,16,21,2,21,21,2,10,21,2,30,21,0,3,8,7,16,21,2,22,21,2,25,21,2,27,21,2,19,7,21,0,1,19,21,2,15,0,0,19,21,2,11,21,2,10,19,21,2,9,21,2,25,19,7,16,19,22,0,4,11,14,21,0,1,21,2,22,21,2,9,7,16,21,2,31,21,2,19,8,22,0,5,11,14,0,0,21,0,4,16,22,0,6,11,21,0,5,16,22,0,7,11,14,21,0,3,21,0,5,16,21,2,20,16,21,2,21,15,126,7,16,25,21,0,1,21,2,43,0,1,17,22,0,3,11,21,2,41,21,2,11,7,0,1,17,22,0,4,11,14,21,0,4,21,2,20,16,21,2,18,21,0,3,17,21,2,21,21,2,9,21,2,30,21,2,11,21,2,30,21,0,4,8,8,21,2,27,21,2,19,7,21,0,1,21,2,18,16,19,7,21,0,2,17,25,21,0,2,21,2,21,21,0,1,21,2,31,21,2,19,8,7,16,25,21,0,1,14,21,1,9,21,2,19,21,1,11,21,2,19,21,1,13,17,17,22,0,3,11,14,21,1,13,21,2,9,0,1,17,22,1,13,12,21,1,12,16,22,1,14,12,14,21,0,3,25,21,0,1,21,2,15,21,1,14,17,25,21,0,1,21,2,75,21,0,4,17,25,21,1,3,21,2,20,16,21,2,21,21,2,26,7,21,2,30,21,2,4,8,15,127,21,2,30,21,2,18,8,3,2,21,2,24,21,1,4,21,2,72,0,0,17,8,21,0,1,17,25,21,0,1,21,2,34,16,21,2,8,16,14,21,0,1,21,2,20,16,25,21,0,1,21,2,75,16,21,2,75,0,1,17,21,2,8,16,14,21,0,1,21,2,21,21,1,3,7,16,21,2,41,21,2,21,21,2,44,21,2,30,21,2,84,8,7,7,3,0,21,2,72,16,17,25,21,1,9,21,1,7,21,2,78,21,0,4,17,7,22,0,5,11,14,21,0,1,21,2,57,21,0,5,7,21,2,26,21,2,28,21,2,21,21,0,1,21,2,31,21,0,5,8,7,8,21,2,25,21,2,28,21,2,21,21,2,25,21,0,5,21,0,2,19,7,8,21,1,8,3,4,21,2,24,21,2,60,21,2,29,21,2,86,8,21,2,76,21,0,4,21,2,68,0,0,17,19,21,2,70,0,0,21,2,76,21,0,4,17,21,2,69,21,1,7,17,19,21,2,83,0,2,19,21,2,41,21,2,78,21,2,30,0,2,21,2,31,21,2,71,8,8,7,9,8,21,0,2,17,25,21,0,2,21,2,20,16,21,2,21,21,0,1,21,2,61,16,21,2,31,21,2,19,8,7,16,22,0,3,11,14,21,0,1,21,2,43,21,0,2,17,22,0,4,11,21,2,41,21,2,71,7,16,22,0,5,11,14,21,0,3,21,2,41,21,2,71,7,16,21,2,20,16,21,2,21,21,2,25,21,2,71,21,0,5,19,21,2,78,21,0,5,21,2,20,16,21,2,84,21,0,4,17,19,21,2,28,21,2,21,21,0,1,21,2,84,16,21,2,31,21,2,19,8,7,8,7,16,21,2,84,21,0,3,17,25,21,0,1,21,2,75,16,21,2,77,0,1,17,21,2,8,16,14,21,0,1,21,1,3,21,0,2,17,25,21,0,2,21,2,75,16,21,2,76,0,1,17,21,2,8,16,14,21,0,1,21,2,61,16,21,2,74,21,2,29,21,2,77,8,21,0,2,17,21,2,8,16,14,21,0,2,21,2,74,16,22,0,3,11,14,21,0,2,21,2,84,16,21,2,31,21,2,19,8,22,0,4,11,14,21,0,1,21,0,3,21,2,72,0,0,17,21,2,32,15,128,1,8,0,0,17,25,21,0,2,21,2,33,16,21,2,8,16,14,21,0,1,21,2,74,16,22,0,3,11,14,0,0,21,2,72,21,0,2,17,22,0,4,11,14,21,0,2,21,2,66,16,22,0,5,11,21,2,67,21,0,3,17,22,0,6,11,14,21,0,5,3,1,22,0,7,11,14,0,1,22,0,8,11,14,21,0,6,21,2,20,16,21,0,4,21,2,32,21,2,78,8,21,0,6,21,2,79,21,0,3,17,17,21,0,1,21,2,75,16,21,2,74,0,1,17,21,2,32,15,129,1,8,21,0,1,17,22,0,9,11,14,21,0,9,21,2,21,21,0,1,21,2,84,16,21,2,31,21,2,19,8,7,16,21,0,5,21,2,72,21,0,3,17,21,2,32,15,130,1,21,0,1,7,8,16,21,2,84,21,0,7,17,25,21,0,2,21,2,84,16,21,2,25,21,2,85,21,2,29,21,2,21,21,2,78,7,8,21,2,80,19,21,1,3,17,21,2,57,21,0,1,21,2,31,21,2,98,21,2,30,21,2,21,21,2,72,7,8,8,7,16,21,2,73,21,2,84,21,2,61,21,2,28,21,0,1,21,2,61,16,21,2,105,21,2,30,21,2,74,8,21,0,2,17,21,2,31,21,2,44,8,8,19,16,25,21,0,1,21,2,74,21,2,30,21,1,4,8,21,2,32,15,131,1,8,16,14,21,1,5,21,2,19,0,1,21,2,78,21,1,3,17,22,1,3,12,17,25,21,0,2,21,2,109,16,21,2,21,21,2,71,21,2,30,21,0,1,21,2,75,21,1,8,17,8,21,2,27,21,2,118,7,21,1,6,19,21,2,61,21,2,31,21,2,19,8,21,0,1,19,7,16,25,21,0,1,21,2,102,16,21,2,21,21,2,41,21,2,78,7,7,16,22,0,3,11,14,21,0,3,21,2,105,0,8,17,21,2,111,21,0,1,17,21,2,79,21,0,3,21,2,110,16,21,2,19,0,0,17,21,2,109,16,17,25,21,0,1,14,21,1,6,21,2,19,21,1,7,17,21,2,25,0,1,21,2,78,21,1,7,17,22,1,7,12,17,25,21,0,1,21,2,75,16,21,2,75,0,1,17,21,2,8,16,14,21,0,1,21,2,21,21,2,74,7,16,25,21,0,2,21,2,21,21,2,113,21,2,25,7,7,16,21,2,71,21,1,4,21,2,105,0,1,17,21,2,110,16,21,2,44,0,1,3,1,17,21,2,22,21,2,71,7,16,21,2,110,16,17,21,2,41,21,2,21,21,2,21,21,2,78,7,7,7,16,21,2,21,21,0,1,21,2,43,21,1,4,21,2,74,16,17,21,2,44,21,1,4,21,2,41,21,2,71,7,16,3,1,17,21,2,27,21,2,84,7,21,0,1,17,21,2,31,21,2,98,8,7,16,25,21,0,1,21,2,74,21,2,29,21,2,79,8,21,0,2,17,21,2,71,16,22,0,3,11,14,21,0,1,21,2,74,21,2,29,21,2,67,8,21,0,2,17,22,0,4,11,14,21,0,1,15,132,1,21,2,30,21,2,74,21,2,78,21,0,4,21,2,109,16,21,2,78,0,1,17,21,2,79,16,19,8,21,2,29,15,133,1,8,21,0,2,17,22,0,5,11,14,21,0,5,21,0,3,3,2,25,21,0,2,22,0,3,11,14,21,0,1,22,0,4,11,14,15,134,1,21,1,7,3,2,21,2,24,21,2,75,21,2,30,21,1,6,8,8,22,0,5,11,14,0,0,21,0,5,16,25,15,135,1,22,0,3,11,14,0,8,21,0,3,0,1,21,2,78,21,0,1,17,17,21,2,78,0,1,17,25,21,0,2,21,2,123,21,0,1,21,2,31,21,1,13,8,7,16,25,21,0,2,21,2,75,16,21,2,27,21,2,79,7,0,1,17,22,0,3,11,14,21,0,3,21,2,77,0,0,17,21,2,8,16,14,21,0,1,21,2,42,16,21,2,25,21,2,28,21,0,3,21,2,92,0,0,8,8,21,2,25,21,0,3,21,2,92,21,2,72,8,3,2,21,2,24,21,0,3,21,2,72,0,0,17,8,21,2,29,21,2,21,21,2,61,7,8,21,1,3,9,3,2,21,2,24,21,0,2,21,2,74,16,21,2,72,0,0,17,8,15,136,1,3,2,21,2,24,21,2,84,21,2,28,21,2,74,8,21,2,72,0,5,19,21,2,29,21,2,69,8,8,21,0,2,17,25,21,0,1,25,21,0,1,21,2,33,16,21,2,8,16,14,21,0,1,21,2,67,21,1,8,17,22,1,8,12,14,21,0,1,21,2,68,21,1,7,17,22,1,7,12,25,21,0,1,21,2,78,0,0,17,21,2,109,16,21,2,116,21,1,9,3,1,17,21,2,22,21,2,26,21,2,28,21,0,4,8,7,16,25,21,0,1,21,2,2,21,0,4,17,25,21,0,4,21,2,2,21,0,1,17,25,21,0,2,22,0,3,11,21,3,10,16,22,0,4,11,14,0,0,22,0,5,11,22,0,6,11,22,0,7,11,14,0,4,22,0,8,11,14,21,0,1,0,1,21,3,15,21,2,7,17,21,3,10,0,1,17,21,3,32,21,3,21,21,3,11,21,3,30,21,2,7,8,7,8,16,21,3,31,21,3,19,8,21,3,29,21,1,5,8,22,0,9,11,14,21,0,9,0,0,0,1,0,2,3,4,22,0,10,11,14,21,3,9,15,137,1,3,2,21,3,19,21,0,3,21,3,16,0,5,17,17,22,0,11,11,14,15,138,1,22,0,12,11,14,15,139,1,15,140,1,21,0,12,3,3,21,3,24,15,141,1,8,22,0,13,11,14,21,0,1,21,3,21,21,0,1,21,3,31,15,142,1,8,7,16,25,21,1,6,21,1,7,21,3,15,21,0,1,17,21,3,32,15,143,1,8,16,25,21,0,1,21,3,66,21,2,4,17,21,3,21,21,0,2,21,3,31,21,3,19,8,7,16,25,21,0,1,0,1,21,3,79,21,1,3,17,21,3,72,21,0,2,17,21,3,32,21,3,93,21,0,0,21,3,30,21,0,2,21,3,78,0,1,17,8,7,8,16,21,2,3,21,0,2,21,1,4,16,17,25,21,0,2,21,3,43,0,1,17,22,0,3,11,21,3,44,22,1,7,13,14,21,0,3,21,3,41,21,3,71,7,16,22,1,8,12,21,3,25,21,3,28,21,3,20,8,21,3,21,21,3,78,7,21,3,71,19,21,0,1,17,25,21,1,6,21,3,79,21,1,5,17,21,3,71,21,1,8,17,21,3,20,16,21,3,21,21,0,4,21,3,4,16,21,3,84,16,21,3,19,0,0,17,7,16,21,3,44,21,3,27,21,3,44,7,3,2,21,3,24,21,1,4,8,21,0,1,21,3,84,16,17,25,21,0,1,22,2,4,12,21,3,27,21,3,19,7,21,2,6,17,22,2,5,12,14,0,8,22,2,3,12,25,21,0,2,21,3,21,21,0,1,21,3,31,21,3,19,8,7,16,25,21,0,1,21,3,75,21,0,2,17,21,3,22,21,3,69,7,16,21,3,41,21,3,78,7,16,22,0,3,11,14,21,0,3,21,3,109,16,21,3,21,21,0,2,21,3,31,21,3,19,8,7,16,21,3,41,21,3,71,7,16,22,0,4,11,14,21,0,3,21,3,73,21,3,30,21,1,4,8,21,3,32,21,0,2,21,0,1,3,2,21,3,31,21,3,57,21,3,19,7,8,21,3,28,15,144,1,8,8,16,14,21,0,4,25,21,1,4,21,3,78,21,3,30,21,0,1,8,21,3,29,21,2,5,8,21,1,3,17,21,3,75,21,3,30,0,0,8,21,3,32,21,0,1,21,3,78,0,1,17,21,3,28,21,1,5,8,8,16,25,21,0,1,0,1,21,3,31,21,3,73,8,21,3,32,15,145,1,8,21,0,2,17,25,21,0,2,21,3,126,16,21,3,110,16,22,0,3,11,14,21,0,1,21,3,125,21,0,2,21,3,98,21,0,3,17,17,21,3,27,21,3,79,7,0,1,17,21,3,68,0,0,17,21,3,27,21,3,98,7,21,0,3,17,22,0,4,11,14,21,0,1,21,1,3,21,3,92,21,3,60,8,21,0,2,21,3,98,21,0,4,17,17,21,2,2,21,3,32,21,3,71,21,3,30,21,3,79,21,3,30,21,0,4,8,8,21,3,78,21,3,26,19,8,21,0,2,21,3,74,16,17,25,21,0,1,21,1,8,21,4,10,0,1,17,21,4,32,21,1,9,21,4,10,0,1,19,21,4,32,15,146,1,8,8,0,1,21,4,10,21,0,1,17,17,25,21,0,2,21,4,9,21,1,3,17,22,1,4,12,14,21,0,1,21,4,9,21,1,3,17,22,1,7,12,21,2,6,16,22,1,6,12,21,4,9,21,1,3,17,21,2,6,16,22,1,5,12,14,21,1,7,21,4,16,21,3,6,17,22,1,8,12,14,21,1,6,21,1,11,16,14,21,1,7,21,1,13,21,1,4,17,25,21,0,2,21,4,9,0,1,17,22,1,4,12,21,4,15,21,1,6,17,21,4,11,0,2,17,21,4,9,22,1,8,13,14,21,0,2,25,21,0,1,21,4,9,0,1,17,22,1,7,12,21,4,15,21,1,5,17,21,4,9,22,1,8,13,14,21,0,1,25,21,0,1,21,1,10,21,4,24,21,1,8,8,21,0,2,17,25,21,0,1,21,4,19,21,1,7,21,1,13,21,1,4,17,17,25,0,1,21,4,9,21,0,1,17,21,2,4,16,22,2,6,12,21,2,5,16,22,2,7,12,14,21,2,6,25,21,0,1,21,4,41,21,4,79,7,16,21,4,71,16,22,2,3,12,14,21,0,1,21,4,41,21,4,67,7,16,21,4,71,21,1,4,17,22,1,4,12,25,0,2,21,4,63,21,0,2,17,21,4,67,16,22,0,3,11,21,4,78,21,0,1,17,22,0,4,11,21,3,2,16,22,0,5,11,14,21,0,1,21,0,4,3,2,21,4,19,21,0,5,17,21,2,3,21,0,2,21,4,66,0,2,17,21,4,71,21,0,5,17,21,4,78,21,0,3,17,17,25,21,0,1,14,0,2,22,2,8,12,14,21,2,4,22,2,7,12,14,21,0,1,22,2,4,12,25>>;
runtime(o) ->
    {0,1,2,32,3,8,infinity,neg_infinity,-1};
runtime(s) ->
    [{0,1,0,0},{0,0,3,149},{2,0,2773,6},{0,0,2801,3},{0,0,2805,3},{0,0,2809,3},{1,0,2813,5},{2,0,2831,6},{2,0,2846,6},{2,0,2865,6},{2,0,2887,6},{2,0,2909,6},{0,0,2942,3},{0,0,2954,3},{0,0,2963,3},{1,0,2972,9},{0,0,3092,3},{0,0,3137,4},{1,1,3220,4},{1,1,3296,3},{0,0,3365,3},{0,0,3376,5},{2,0,3465,12},{0,0,3685,4},{0,0,3735,6},{0,0,3834,4},{0,0,4002,4},{0,0,4068,4},{2,0,4179,15},{1,1,4380,2},{0,0,4406,3},{0,0,4435,3},{0,0,4463,3},{0,0,4509,4},{0,0,4615,3},{0,0,4644,3},{0,0,4667,3},{0,0,4690,3},{0,0,4702,3},{0,0,4733,3},{0,0,4739,5},{0,0,4857,5},{0,0,4891,3},{0,0,4900,3},{1,1,4906,2},{2,0,4977,10},{2,0,5036,8},{1,1,5226,2},{1,0,5236,5},{2,1,5277,4},{0,0,5313,8},{0,0,5551,4},{0,0,5634,3},{0,0,5685,4},{0,0,5808,3},{0,0,5859,4},{0,0,6022,3},{0,0,6041,3},{0,0,6074,3},{0,0,6088,7},{0,0,6137,11},{1,0,6406,8},{0,0,6526,4},{0,0,6613,5},{0,0,6770,4},{0,0,6983,3},{0,0,7002,4},{1,0,7074,9},{1,1,7144,3},{1,0,7168,14},{1,1,7606,4},{0,0,7657,4},{0,0,7800,4},{0,0,7867,4},{0,0,8137,3},{2,0,8180,6},{0,0,8209,3},{0,0,8248,3},{0,0,8337,3},{1,1,8393,2},{2,0,8402,13},{1,1,8556,2},{1,1,8571,2},{1,1,8575,2},{0,0,8579,3},{0,0,8591,3},{0,0,8616,3},{1,0,8638,6},{1,0,8770,11},{1,0,9014,5},{0,0,9029,3},{0,0,9044,3},{0,0,9059,3},{1,0,9107,8},{0,0,9256,8},{0,0,9441,5},{0,0,9524,3},{0,0,9543,4},{0,0,9595,3},{1,0,9606,5},{0,0,9617,3},{0,0,9667,3},{0,0,9687,3},{1,0,9742,6},{0,0,9897,6},{0,0,10033,3},{0,0,10062,5},{0,0,10160,10},{0,0,10347,3},{0,0,10449,3},{0,0,10492,3},{0,0,10547,4},{0,0,10609,3},{0,0,10641,3},{0,0,10671,3},{0,0,10794,6},{0,0,10901,6},{0,0,10951,4},{0,0,10981,3},{0,0,11000,4},{1,1,11158,2},{0,0,11162,3},{1,0,11204,5},{1,0,11242,5},{1,0,11253,5},{0,0,11264,14},{0,0,11450,3},{0,0,11472,3},{0,0,11498,3},{0,0,11554,4},{1,0,11616,5},{0,0,11687,3},{0,0,11717,3},{0,0,11736,5},{0,0,11851,3},{0,0,11906,3},{0,0,11930,5},{0,0,12059,3},{0,0,12102,3},{0,0,12189,3},{0,0,12227,3},{0,0,12259,3},{0,0,12277,3},{0,0,12295,3},{0,0,12325,3},{0,0,12368,6},{0,0,12448,3}].
