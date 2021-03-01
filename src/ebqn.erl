-module(ebqn).

-export([test/0,fixed/1,concat/2,load_block/1]).
-import(array,[fix/1,from_list/1,resize/2,foldl/3,set/3]).
-import(queue,[cons/2,tail/1,liat/1,head/1,len/1]).
-import(dict,[store/3,fetch/2,fetch_keys/1]).
-import(erlang,[fun_info/2]).

-record(bl,{t,i,st,l}).
-record(bi,{b,o,s,t,d,args,e}). % bytecode, objs, sections, type, definition, args, env
-record(tr,{f,g,h}).
-record(v,{sh,r}). % value (shape, ravel)
-record(m1,{f,i}).
-record(m2,{f,i}).
-record(r1,{m,f}). % raw 1-mod

test([B,O,S]) ->
    run(list_to_binary(B),list_to_tuple(O),list_to_tuple(lists:map(fun list_to_tuple/1,S))).
test() ->
    5 = test([[0,0,25],[5],[[0,1,0,0]]]), % 5
    3 = test([[0,0,14,0,1,25],[4,3],[[0,1,0,0]]]), % 4⋄3
    5 = test([[0,0,22,0,0,11,25],[5],[[0,1,0,1]]]), % a←5
    4 = test([[0,0,22,0,0,11,14,0,1,22,0,0,12,25],[5,4],[[0,1,0,1]]]), % a←5⋄a↩4
    2 = test([[0,0,22,0,0,11,14,0,1,22,0,1,11,14,21,0,0,25],[2,3],[[0,1,0,2]]]), % a←2⋄b←3⋄a
    1 = test([[0,0,22,0,0,11,14,0,1,21,0,0,16,25],[1,4],[[0,1,0,1]]]), % a←1⋄A 4
    2 = test([[0,0,22,0,0,11,14,0,2,21,0,0,0,1,17,25],[2,3,4],[[0,1,0,1]]]), % a←2⋄3 A 4
    6 = test([[0,0,15,1,16,25,21,0,1,25],[6],[[0,1,0,0],[0,0,6,3]]]), % {𝕩}6
    3 = test([[15,1,22,0,0,11,14,0,1,21,0,0,0,0,17,25,21,0,2,25],[3,4],[[0,1,0,1],[0,0,16,3]]]), % A←{𝕨}⋄3 A 4
    7 = test([[0,0,0,1,3,2,22,0,0,22,0,1,4,2,11,14,21,0,0,25],[7,2],[[0,1,0,2]]]), % a‿b←7‿2⋄a
    4 = test([[0,1,15,1,0,0,7,16,25,21,0,1,25],[4,6],[[0,1,0,0],[1,1,9,2]]]), % "4{𝔽}6"
    6 = test([[0,1,15,1,0,0,7,16,25,21,0,4,14,21,0,1,25],[4,6],[[0,1,0,0],[1,0,9,5]]]), % "4{𝔽⋄𝕩}6"
    1 = test([[0,1,15,1,15,2,0,0,8,16,25,21,0,1,25,21,0,2,25],[3,1],[[0,1,0,0],[0,0,11,3],[2,1,15,3]]]), % "3{𝔾}{𝕩} 1 "
    2 = test([[0,1,15,1,15,2,0,0,7,9,16,25,21,0,1,25,21,0,1,25],[2,3],[[0,1,0,0],[0,0,12,3],[1,1,16,2]]]), % "(2{𝔽}{𝕩})3 "
    3 = test([[0,1,15,1,15,2,9,0,0,17,25,21,0,2,21,0,1,3,2,25,21,0,1,22,0,3,22,0,4,4,2,11,14,21,0,3,25],[3,4],[[0,1,0,0],[0,0,11,3],[0,0,20,5]]]), % "3({a‿b←𝕩⋄a}{𝕨‿𝕩})4 "
    4 = test([[0,1,15,1,15,2,15,3,19,0,0,17,25,21,0,2,25,21,0,1,25,21,0,2,21,0,1,3,2,25],[4,5],[[0,1,0,0],[0,0,13,3],[0,0,17,3],[0,0,21,3]]]), % "4({𝕨‿𝕩}{𝕩}{𝕨})5"
    2 = test([[0,1,15,1,15,2,0,0,19,16,22,0,0,22,0,1,4,2,11,14,21,0,0,25,21,0,1,25,21,0,2,21,0,1,3,2,25],[2,5],[[0,1,0,2],[0,0,24,3],[0,0,28,3]]]), % "a‿b←(2{𝕨‿𝕩}{𝕩})5⋄a "
    2 = test([[0,2,22,0,0,11,15,1,15,2,15,3,19,16,25,0,1,22,1,0,12,14,21,0,1,25,21,0,1,14,21,1,0,25,0,0,22,1,0,12,14,21,0,1,25],[2,3,4],[[0,1,0,1],[0,0,15,3],[0,0,26,3],[0,0,34,3]]]), % "({a↩2⋄𝕩}{𝕩⋄a}{a↩3⋄𝕩})a←4 "
    8 = test([[0,0,22,0,0,11,14,0,1,15,1,22,0,0,13,14,21,0,0,25,21,0,1,25],[3,8],[[0,1,0,1],[0,0,20,3]]]), % "a←3⋄a{𝕩}↩8⋄a  "
    4 = test([[0,0,0,1,3,2,22,0,0,22,0,1,4,2,11,14,0,2,15,1,22,0,0,22,0,1,4,2,13,14,21,0,0,25,21,0,1,21,0,2,3,2,25],[2,1,4],[[0,1,0,2],[0,0,34,3]]]), % "a‿b←2‿1⋄a‿b{𝕩‿𝕨}↩4⋄a "
    1 = test([[0,0,22,0,0,11,14,15,1,14,21,0,0,25,0,1,22,0,0,11,25],[1,2],[[0,1,0,1],[0,1,14,1]]]), % "a←1⋄{a←2}⋄a"
    2 = test([[0,0,22,0,0,11,14,15,1,14,21,0,0,25,0,1,22,1,0,12,25],[1,2],[[0,1,0,1],[0,1,14,0]]]), % "a←1⋄{a↩2}⋄a"
    6 = test([[15,1,22,0,0,22,0,1,4,2,11,14,0,1,21,0,0,16,14,0,2,21,0,1,16,25,0,0,22,0,0,11,14,15,2,15,3,3,2,25,21,0,1,22,1,0,12,25,21,0,1,14,21,1,0,25],[2,6,0],[[0,1,0,2],[0,1,26,1],[0,0,40,3],[0,0,48,3]]]), % "f‿g←{a←2⋄{a↩𝕩}‿{𝕩⋄a}}⋄F 6⋄G 0"
    5 = test([[15,1,22,0,0,11,14,0,0,21,0,0,16,21,0,0,16,21,0,0,16,15,2,16,25,15,3,21,0,1,7,25,21,0,0,21,0,1,16,25,21,0,4,21,0,1,16,25],[5],[[0,1,0,1],[0,0,25,3],[0,0,32,3],[1,0,40,5]]]), % "L←{𝕩{𝕏𝕗}}⋄{𝕏𝕤}L L L 5"
    3 = test([[15,1,22,0,0,11,14,0,1,21,0,0,0,0,7,16,21,0,0,15,2,7,16,15,3,16,25,21,0,4,15,4,21,0,1,7,9,25,21,0,1,25,21,0,0,21,0,1,16,25,21,0,4,21,0,1,16,25],[3,5],[[0,1,0,1],[1,0,27,5],[0,0,38,3],[0,0,42,3],[1,0,50,5]]]), % "_l←{𝕩{𝕏𝕗} 𝔽}⋄{𝕏𝕤} {𝕩}_l 3 _l 5"
    1 = test([[0,1,15,1,15,2,15,3,8,0,0,17,25,21,0,1,25,21,0,1,21,0,2,15,4,21,0,1,7,19,25,21,0,2,25,21,0,2,21,0,4,21,0,1,17,25],[1,0],[[0,1,0,0],[0,0,13,3],[2,1,17,3],[0,0,31,3],[1,0,35,5]]]), % "1{𝕨}{𝔽{𝕩𝔽𝕨}𝔾𝔽}{𝕩}0 "
    2 = test([[0,0,0,1,0,2,0,3,0,4,15,1,3,2,3,2,3,2,3,2,3,2,15,2,0,0,0,0,15,3,3,2,3,2,7,16,25,21,0,1,25,21,0,1,15,4,16,25,21,0,1,25,21,0,1,22,0,3,22,0,4,4,2,11,14,21,0,0,22,0,5,11,14,0,0,15,5,15,6,7,16,14,15,7,21,0,4,21,0,5,16,7,25,21,0,1,21,1,4,16,25,21,0,0,14,15,8,22,1,5,12,25,21,0,1,22,0,5,22,0,6,4,2,11,14,21,0,6,21,0,4,16,25,21,0,0,14,15,9,25,21,0,1,22,0,3,22,0,4,4,2,11,14,21,0,3,25],[0,1,2,3,4],[[0,1,0,0],[0,0,37,3],[1,1,41,2],[0,0,48,3],[0,0,52,6],[1,1,93,2],[0,0,101,3],[1,0,112,7],[0,0,133,3],[0,0,140,5]]]), % "0‿(0‿{𝕩}){{a‿b←𝕩⋄t←𝕤⋄{𝕤⋄T↩{𝕤⋄{a‿b←𝕩⋄a}}}{B𝕗}0⋄(T b){a‿b←𝕩⋄𝔽b}}𝕗} 0‿(1‿(2‿(3‿(4‿{𝕩}))))"
    true.

arr(R,Sh) ->
    #v{r=R,sh=Sh}.
list(A) ->
    arr(A,[array:size(A)]).
call(_F,undefined,_W) ->
    undefined;
call(F,X,W) when is_number(F) ->
    F;
call(F,X,W) when is_record(F,bi) ->
    0 = F#bi.t,
    D = F#bi.d,
    Args = F#bi.args,
    L = concat([fixed([F,X,W]),Args,array:new(D#bl.l)]),
    load_vm(F#bi.b,F#bi.o,F#bi.s,D,make_ref(),F#bi.e,L);
call(T,X,W) when is_record(T,tr), undefined =/= T#tr.f ->
    R = call(T#tr.h,X,W),
    L = call(T#tr.f,X,W),
    call(T#tr.g,R,L);
call(T,X,W) when is_record(T,tr), undefined =:= T#tr.f ->
    R = call(T#tr.h,X,W),
    call(T#tr.g,R,undefined);
call(V,X,W) when is_record(V,v) ->
    V.
call_block(M,Args) when is_record(M,bi), 0 =:= M#bi.d#bl.i ->
    M#bi{args=Args,t=0};
call_block(M,Args) when is_record(M,bi), 1 =:= M#bi.d#bl.i ->
    D = M#bi.d,
    L = concat([Args,array:new(D#bl.l - asize(Args))]),
    load_vm(M#bi.b,M#bi.o,M#bi.s,D,make_ref(),M#bi.e,L).
call1(M,F) when is_record(M,bi) ->
    1 =:= M#bi.t,
    call_block(M,fixed([M,F]));
call1(M,F) when is_record(M,m1) ->
    #r1{m=M,f=F}.
call2(M,F,G) when is_record(M,bi) ->
    2 =:= M#bi.t,
    call_block(M,fixed([M,F,G])).
tr3o(H,G,undefined) ->
    fun(X,W) ->
        call(G,call(H,X,W),undefined)
    end;
tr3o(H,G,F) ->
    fun(X,W) ->
        call(G,call(H,X,W),call(F,X,W))
    end.
ge(I,E,An) when I =:= 0 ->
    E;
ge(I,E,An) when I =/= 0 ->
    #{E := Parent} = An,
    ge(I-1,Parent,An).
hset(Heap,D,#v{r=Id},#v{r=V}) ->
    foldl(fun(J,N,A) -> hset(A,D,N,array:get(J,V)) end,Heap,Id);
hset(Heap,D,{E,I},V) ->
    A = fetch(E,Heap),
    D = (array:get(I,A) =:= undefined),
    store(E,set(I,V,A),Heap).
hget(Heap,{T,I}) when is_reference(T) ->
    Slots = fetch(T,Heap),
    Z = array:get(I,Slots),
    true = (null =/= Z),
    Z;
hget(Heap,#v{sh=S,r=R} = I) when is_record(I,v) ->
    arr(array:map(fun(_J,E) -> hget(Heap,E) end,R),S).
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
asize(X) when X =:= nil;X =:= [nil] ->
    0;
asize(X) ->
    array:size(X).
fixed(X) when X =:= nil;X =:= [nil] ->
    nil;
fixed(X) when is_list(X) ->
    fix(resize(length(X),from_list(X))).
concat(nil,nil) ->
    nil;
concat(X,nil) when X =/= nil ->
    X;
concat(nil,W) when W =/= nil ->
    W;
concat(X,W) ->
    Xs = array:size(X),
    Z = array:resize(Xs+array:size(W),X),
    array:foldl(fun(I,V,A) -> array:set(Xs+I,V,A) end,Z,W).
concat(L) ->
    lists:foldl(fun(V,A) -> concat(A,V) end,fixed([]),L).
tail(L,A,S) when L =:= -1 ->
    {A,S};
tail(L,A,S) ->
    tail(L-1,set(L,head(S),A),tail(S)).

derive(B,O,S,#bl{t=0,i=1} = Block,E) ->
    load_vm(B,O,S,Block,make_ref(),E,array:new(Block#bl.l));
derive(B,O,S,Block,E) ->
    #bi{b=B,o=O,s=S,t=Block#bl.t,d=Block,args=nil,e=E}.

args(B,P,Op) when Op =:= 7; Op =:= 8; Op =:= 9; Op =:= 11; Op =:= 12; Op =:= 13; Op =:= 14; Op =:= 16; Op =:= 17; Op =:= 19; Op =:= 25 ->
    {undefined,P};
args(B,P,Op) when Op =:= 0; Op =:= 3; Op =:= 4; Op =:= 15 ->
    num(B,P);
args(B,P,Op) when Op =:= 21; Op =:= 22 ->
    {X,Xp} = num(B,P),
    {Y,Yp} = num(B,Xp),
    {{X,Y},Yp}.

stack(B,O,S,Root,Heap,An,E,Stack,X,0) ->
    cons(element(1+X,O),Stack);
stack(B,O,S,Root,Heap,An,E,Stack,X,Op) when Op =:= 3; Op =:= 4 ->
    {T,Si} = case X of
        0 -> {list(fixed([])),Stack};
        _ -> tail(X-1,array:new(X),Stack)
    end,
    cons(list(T),Si);
stack(B,O,S,Root,Heap,An,E,Stack,undefined,7) ->
    F = head(Stack),
    M = head(tail(Stack)),
    cons(call1(M,F),tail(tail(Stack)));
stack(B,O,S,Root,Heap,An,E,Stack,undefined,8) ->
    F = head(Stack),
    M = head(tail(Stack)),
    G = head(tail(tail(Stack))),
    cons(call2(M,F,G),tail(tail(tail(Stack))));
stack(B,O,S,Root,Heap,An,E,Stack,undefined,9) ->
    G = head(Stack),
    J = head(tail(Stack)),
    cons(#tr{f=undefined,g=G,h=J},tail(tail(Stack)));
stack(B,O,S,Root,Heap,An,E,Stack,X,Op) when Op =:= 11; Op =:= 12 ->
    tail(Stack);
stack(B,O,S,Root,Heap,An,E,Stack,X,13) ->
    tail(tail(Stack));
stack(B,O,S,Root,Heap,An,E,Stack,X,14) ->
    liat(Stack);
stack(B,O,S,Root,Heap,An,E,Stack,X,15) ->
    Block = load_block(element(1+X,S)),
    D = derive(B,O,S,Block,E),
    cons(D,Stack);
stack(B,O,S,Root,Heap,An,E,Stack,undefined,16) ->
    F = head(Stack),
    X = head(tail(Stack)),
    cons(call(F,X,undefined),tail(tail(Stack)));
stack(B,O,S,Root,Heap,An,E,Stack,undefined,17) ->
    W = head(Stack),
    F = head(tail(Stack)),
    X = head(tail(tail(Stack))),
    cons(call(F,X,W),tail(tail(tail(Stack))));
stack(B,O,S,Root,Heap,An,E,Stack,undefined,19) ->
    F = head(Stack),
    G = head(tail(Stack)),
    H = head(tail(tail(Stack))),
    cons(#tr{f=F,g=G,h=H},tail(tail(tail(Stack))));
stack(B,O,S,Root,Heap,An,E,Stack,{X,Y},21) ->
    T = ge(X,E,An),
    Slots = fetch(T,Heap),
    Z = array:get(Y,Slots),
    true = (null =/= Z),
    cons(Z,Stack);
stack(B,O,S,Root,Heap,An,E,Stack,{X,Y},22) ->
    T = ge(X,E,An),
    cons({T,Y},Stack);
stack(B,O,S,Root,Heap,An,E,Stack,X,25) ->
    1 = len(Stack),
    head(Stack).

heap(Root,Heap,Stack,Op) when Op =:= 0; Op =:= 3; Op =:= 4; Op =:= 7; Op =:= 8; Op =:= 9; Op =:= 14; Op =:= 15; Op =:= 16; Op =:= 17; Op =:= 19; Op =:= 21; Op =:= 22; Op =:= 25 ->
    Heap;
heap(Root,Heap,Stack,Op) when Op =:= 11 ->
    I = head(Stack),
    V = head(tail(Stack)),
    hset(Heap,true,I,V);
heap(Root,Heap,Stack,Op) when Op =:= 12 ->
    I = head(Stack),
    V = head(tail(Stack)),
    hset(Heap,false,I,V);
heap(Root,Heap,Stack,Op) when Op =:= 13 ->
    I = head(Stack),
    F = head(tail(Stack)),
    X = head(tail(tail(Stack))),
    hset(Heap,false,I,call(F,X,hget(Heap,I))).

ctrl(Op) when Op =:= 0; Op =:= 3; Op =:= 4; Op =:= 7; Op =:= 8; Op =:= 9; Op =:= 11; Op =:= 12; Op =:= 13; Op =:= 14; Op =:= 15; Op =:= 16; Op =:= 17; Op =:= 19; Op =:= 21; Op =:= 22 ->
    cont;
ctrl(Op) when Op =:= 25 ->
    rtn.

vm(B,O,S,Block,E,P,Stack,rtn) ->
    Stack;
vm(B,O,S,Block,E,P,Stack,cont) ->
    Pi = P+1,
    {Op,Pi} = num(B,P),
    {Arg,Pn} = args(B,Pi,Op), % advances the ptr and reads the args
    Sn = stack(B,O,S,get(root),get(heap),get(an),E,Stack,Arg,Op), % mutates the stack
    put(heap,heap(get(root),get(heap),Stack,Op)), % mutates the heap
    Ctrl = ctrl(Op), % set ctrl atom
    vm(B,O,S,Block,E,Pn,Sn,Ctrl). % call itself with new state

load_vm(B,O,S,Block,E,Parent,V) ->
    put(heap,store(E,V,get(heap))), % alloc slots
    An = get(an),
    put(an,An#{E => Parent}), % alloc relationship
    vm(B,O,S,Block,E,Block#bl.st,queue:new(),cont). % run vm w/ empty stack

load_block({T,I,ST,L}) ->
    #bl{t=T,i=I,st=ST,l=L}.

run(B,O,S) ->
    Root = make_ref(),
    Heap = dict:new(),
    An = #{}, % ancestors
    put(heap,Heap), % init the proc_dict
    put(root,Root),
    put(an,An),
    #bl{i=1,l=L} = Block = load_block(element(1,S)),
    load_vm(B,O,S,Block,Root,Root,array:new(L)). % set the root environment, and root as its own parent.
