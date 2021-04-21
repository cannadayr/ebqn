-module(ebqn).

-import(ebqn_core,[fn/1]).
-export([run/2,run/4,call/4,list/1,load_block/1,char/1,str/1,strings/1,fmt/1,perf/1,init_st/0,set_prim/2,decompose/3,prim_ind/3]).
-export([runtime/0,compiler/2]).
-export([hello/0]).

-include("schema.hrl").
-include("crates.hrl").

-on_load(init/0).

init() ->
    ?load_nif_from_crate(ebqn, ?crate_ebqn, 0).

hello() ->
    exit(nif_not_loaded).

fmt(X) ->
    io:format("~p~n",[X]).
dbg() ->
    halt(erlang:pid_to_list(self())).
% ebqn:perf(fun() -> ebqn:run(ebqn_bc:runtime()) end).
perf(F) ->
    B = erlang:timestamp(),
    V = F(),
    A = erlang:timestamp(),
    timer:now_diff(A,B)/1000.

arr(R,Sh) ->
    #a{r=R,sh=Sh}.
list(A) when is_record(A,a) ->
    A;
list(A) when not is_record(A,a) ->
    arr(A,[maps:size(A)]).
char([C]) ->
    #c{p=C}.
str(S) ->
    list(ebqn_array:from_list(lists:map(fun(P) -> #c{p=P} end,S))).
strings(#a{r=X}) ->
            lists:map(fun(E) -> E#c.p end,ebqn_array:to_list(X)).

call(St0,_F,undefined,_W) ->
    {St0,undefined};
call(St0,F,X,W) when is_number(F) ->
    {St0,F};
call(St0,F,X,W) when is_record(F,fn) ->
    Fn = F#fn.f,
    Fn(St0,X,W);
call(St0,R,X,W) when is_record(R,d1) ->
    M = R#d1.m#r1.f#fn.f,
    F = R#d1.f,
    M(St0,F,X,W);
call(St0,R,X,W) when is_record(R,d2) ->
    M = R#d2.m#r2.f#fn.f,
    F = R#d2.f,
    G = R#d2.g,
    M(St0,F,G,X,W);
call(St0,F,X,W) when is_record(F,bi) ->
    0 = F#bi.t,
    D = F#bi.d,
    Args = F#bi.args,
    L = ebqn_array:concat([ebqn_array:from_list([F,X,W]),Args,ebqn_array:new(D#bl.l)]),
    Prog = F#bi.prog,
    #prog{b=B,o=O,s=S} = maps:get(Prog,St0#st.objs),
    load_vm(St0,B,O,S,D,make_ref(),F#bi.e,L);
call(St0,T,X,W) when is_record(T,tr), undefined =/= T#tr.f ->
    {St1,R} = call(St0,T#tr.h,X,W),
    {St2,L} = call(St1,T#tr.f,X,W),
    call(St2,T#tr.g,R,L);
call(St0,T,X,W) when is_record(T,tr), undefined =:= T#tr.f ->
    {St1,R} = call(St0,T#tr.h,X,W),
    call(St1,T#tr.g,R,undefined);
call(St0,A,X,W) when is_record(A,a) ->
    {St0,A};
call(St0,F,X,W) when not is_record(F,fn) ->
    {St0,F}.
call_block(St0,M,Args) when is_record(M,bi), 0 =:= M#bi.d#bl.i ->
    {St0,M#bi{args=Args,t=0,prim=undefined}};
call_block(St0,M,Args) when is_record(M,bi), 1 =:= M#bi.d#bl.i ->
    D = M#bi.d,
    L = ebqn_array:concat([Args,ebqn_array:new(D#bl.l - maps:size(Args))]),
    Prog = M#bi.prog,
    #{Prog := #prog{b=B,o=O,s=S} } = St0#st.objs,
    load_vm(St0,B,O,S,D,make_ref(),M#bi.e,L).
call1(St0,M,F) when is_record(M,bi) ->
    true = (1 =:= M#bi.t),
    call_block(St0,M,ebqn_array:from_list([M,F]));
call1(St0,M,F) when is_record(M,r1) ->
    {St0,#d1{m=M,f=F}}.
call2(St0,M,F,G) when is_record(M,bi) ->
    true = (2 =:= M#bi.t),
    call_block(St0,M,ebqn_array:from_list([M,F,G]));
call2(St0,M,F,G) when is_record(M,r2) ->
    {St0,#d2{m=M,f=F,g=G}}.

ge(I,E,An) when I =:= 0 ->
    E;
ge(I,E,An) when I =/= 0 ->
    #{E := Parent} = An,
    ge(I-1,Parent,An).
hset(Heap,D,#a{r=Id},#a{r=V}) ->
    maps:fold(fun(J,N,A) -> hset(A,D,N,ebqn_array:get(J,V)) end,Heap,Id);
hset(Heap,D,{E,I},V) ->
    Slot = ebqn_heap:get(E,I,Heap),
    D = (undefined =:= Slot),
    ebqn_heap:set(E,I,V,Heap).
hget(Heap,{T,I}) when is_reference(T) ->
    Z = ebqn_heap:get(T,I,Heap),
    true = (undefined =/= Z),
    Z;
hget(Heap,#a{sh=S,r=R} = I) when is_record(I,a) ->
    arr(maps:map(fun(_J,E) -> hget(Heap,E) end,R),S).
llst(0,Stack) ->
    [list(#{})|Stack];
llst(X,Stack) ->
    tail(X-1,ebqn_array:new(X),Stack).
tail(L,A,S) when L =:= -1 ->
    [list(A)|S];
tail(L,A,S) ->
    tail(L-1,ebqn_array:set(L,hd(S),A),tl(S)).
popn(N,Q) when N =:= 0 ->
    Q;
popn(N,Q) when N =/= 0 ->
    popn(N-1,tl(Q)).

persist_prog(St0,Hash,Prog,Block,E,Exists) when Exists =:= true ->
    Ref = maps:get(Hash,St0#st.keys),
    {St0,#bi{prog=Ref,t=Block#bl.t,d=Block,args=#{},e=E}};
persist_prog(St0,Hash,Prog,Block,E,Exists) when Exists =/= true ->
    Ref = make_ref(),
    {St0#st{keys=maps:put(Hash,Ref,St0#st.keys),objs=maps:put(Ref,Prog,St0#st.objs)},#bi{prog=Ref,t=Block#bl.t,d=Block,args=#{},e=E}}.
derive(St0,B,O,S,#bl{t=0,i=1} = Block,E) ->
    load_vm(St0,B,O,S,Block,make_ref(),E,ebqn_array:new(Block#bl.l));
derive(St0,B,O,S,Block,E) ->
    % hash the program so we don't store duplicate copies
    % store a reference to the program so we don't store the full hash in every block instance
    Prog = #prog{b=B,o=O,s=S},
    Hash = erlang:phash2(Prog),
    persist_prog(St0,Hash,Prog,Block,E,maps:is_key(Hash,St0#st.keys)).

args(B,P,Op) when Op =:= 7; Op =:= 8; Op =:= 9; Op =:= 11; Op =:= 12; Op =:= 13; Op =:= 14; Op =:= 16; Op =:= 17; Op =:= 19; Op =:= 25 ->
    {undefined,P};
args(B,P,Op) when Op =:= 0; Op =:= 3; Op =:= 4; Op =:= 15 ->
    {element(1+P,B),1+P};
args(B,P,Op) when Op =:= 21; Op =:= 22; Op =:= 31 ->
    X = element(1+P,B),
    Y = element(2+P,B),
    {{X,Y},2+P}.

% put guard Op matches before atom matches
stack(St0,B,O,S,E,Stack,X,Op) when Op =:= 3; Op =:= 4 ->
    {St0,llst(X,Stack)};
stack(St0,B,O,S,E,Stack,{X,Y},Op) when Op =:= 21; Op =:= 31 ->
    T = ge(X,E,St0#st.an),
    Z = ebqn_heap:get(T,Y,St0#st.heap),
    %true = (undefined =/= Z),
    {St0,[Z|Stack]};
stack(St0,B,O,S,E,Stack,X,0) ->
    {St0,[element(1+X,O)|Stack]};
stack(St0,B,O,S,E,Stack,undefined,7) ->
    F = hd(Stack),
    M = hd(tl(Stack)),
    {St1,Result} = call1(St0,M,F),
    {St1,[Result|tl(tl(Stack))]};
stack(St0,B,O,S,E,Stack,undefined,8) ->
    F = hd(Stack),
    M = hd(tl(Stack)),
    G = hd(tl(tl(Stack))),
    {St1,Result} = call2(St0,M,F,G),
    {St1,[Result|tl(tl(tl(Stack)))]};
stack(St0,B,O,S,E,Stack,undefined,9) ->
    G = hd(Stack),
    J = hd(tl(Stack)),
    {St0,[#tr{f=undefined,g=G,h=J}|tl(tl(Stack))]};
stack(St0,B,O,S,E,Stack,X,11) ->
    I = hd(Stack),
    V = hd(tl(Stack)),
    Heap = hset(St0#st.heap,true,I,V),
    {St0#st{heap=Heap},tl(Stack)};
stack(St0,B,O,S,E,Stack,X,12) ->
    I = hd(Stack),
    V = hd(tl(Stack)),
    Heap = hset(St0#st.heap,false,I,V),
    {St0#st{heap=Heap},tl(Stack)};
stack(St0,B,O,S,E,Stack,X,13) ->
    I = hd(Stack),
    F = hd(tl(Stack)),
    G = hd(tl(tl(Stack))),
    {St1,Result} = call(St0,F,G,hget(St0#st.heap,I)),
    Heap = hset(St1#st.heap,false,I,Result),
    {St1#st{heap=Heap},tl(tl(Stack))};
stack(St0,B,O,S,E,Stack,X,14) ->
    {St0,tl(Stack)};
stack(St0,B,O,S,E,Stack,X,15) ->
    Block = load_block(element(1+X,S)),
    {St1,D} = derive(St0,B,O,S,Block,E),
    {St1,[D|Stack]};
stack(St0,B,O,S,E,Stack,undefined,16) ->
    F = hd(Stack),
    X = hd(tl(Stack)),
    {St1,Result} = call(St0,F,X,undefined),
    {St1,[Result|tl(tl(Stack))]};
stack(St0,B,O,S,E,Stack,undefined,17) ->
    W = hd(Stack),
    F = hd(tl(Stack)),
    X = hd(tl(tl(Stack))),
    {St1,Result} = call(St0,F,X,W),
    {St1,[Result|tl(tl(tl(Stack)))]};
stack(St0,B,O,S,E,Stack,undefined,19) ->
    F = hd(Stack),
    G = hd(tl(Stack)),
    H = hd(tl(tl(Stack))),
    {St0,[#tr{f=F,g=G,h=H}|tl(tl(tl(Stack)))]};
stack(St0,B,O,S,E,Stack,{X,Y},22) ->
    T = ge(X,E,St0#st.an),
    {St0,[{T,Y}|Stack]};
stack(St0,B,O,S,E,Stack,X,25) ->
    1 = length(Stack),
    {St0,[hd(Stack)]}.

ctrl(Op) when Op =:= 0; Op =:= 3; Op =:= 4; Op =:= 7; Op =:= 8; Op =:= 9; Op =:= 11; Op =:= 12; Op =:= 13; Op =:= 14; Op =:= 15; Op =:= 16; Op =:= 17; Op =:= 19; Op =:= 21; Op =:= 22; Op =:= 31 ->
    cont;
ctrl(Op) when Op =:= 25 ->
    rtn.

vm(St0,B,O,S,Block,E,P,[Rtn],rtn) ->
    An0 = St0#st.an,
    % get the number of children for this environment
    Num = maps:size(maps:filter(fun(K,V) -> V =:= E end,An0)),
    %fmt({rtn_pop,Num}),
    St1 = St0#st{rtn=popn(Num,St0#st.rtn)}, % pop this number of slots off the rtn stack
    {St1,Rtn};
vm(St0,B,O,S,Block,E,P,Stack,cont) ->
    Op = element(1+P,B),
    %fmt({vm,Op,P+1}),
    %fmt({stack,Stack}),
    {Arg,Pn} = args(B,1+P,Op), % advances the ptr and reads the args
    {St1,Sn} = stack(St0,B,O,S,E,Stack,Arg,Op), % mutates the stack
    Ctrl = ctrl(Op), % set ctrl atom
    vm(St1,B,O,S,Block,E,Pn,Sn,Ctrl). % call itself with new state

load_vm(St0,B,O,S,Block,E,Parent,V) ->
    Heap = ebqn_heap:alloc(E,V,St0#st.heap),
    An0 = St0#st.an,
    An1 = An0#{E => Parent},
    Rtn = [E|St0#st.rtn],
    St1 = St0#st{heap=Heap,an=An1,rtn=Rtn},
    vm(St1,B,O,S,Block,E,Block#bl.st,[],cont). % run vm w/ empty stack

load_block({T,I,ST,L}) ->
    #bl{t=T,i=I,st=ST,l=L}.

init_st() ->
    Root = make_ref(),
    #st{root=Root,heap=#{ Root => #{} },keys=#{},objs=#{},an=#{Root => Root},rtn=[]}.

run(St0,[B,O,S]) ->
    %fmt({run,B}),
    ebqn:run(St0,list_to_tuple(B),list_to_tuple(O),list_to_tuple(lists:map(fun list_to_tuple/1,S))).
run(St0,B,O,S) ->
    #bl{i=1,l=L} = Block = load_block(element(1,S)),
    {St1,Result} = load_vm(St0,B,O,S,Block,make_ref(),St0#st.root,ebqn_array:new(L)), % set the root environment, and root as its own parent.
    {ebqn_gc:gc(St1,St0#st.root,[Result]),Result}.

prim_ind(St0,R,undefined) when is_record(R,fn) and is_number(R#fn.prim) ->
    {St0,R#fn.prim};
prim_ind(St0,R,undefined) when is_record(R,bi) and is_number(R#bi.prim) ->
    {St0,R#bi.prim};
prim_ind(St0,R,undefined) when is_record(R,r1) and is_number(R#r1.prim) ->
    {St0,R#r1.prim};
prim_ind(St0,R,undefined) when is_record(R,r2) and is_number(R#r2.prim) ->
    {St0,R#r2.prim};
prim_ind(St0,R,undefined) when is_record(R,d1) and is_number(R#d1.prim) ->
    {St0,R#d1.prim};
prim_ind(St0,R,undefined) when is_record(R,d2) and is_number(R#d2.prim) ->
    {St0,R#d2.prim};
prim_ind(St0,R,undefined) when is_record(R,tr) and is_number(R#tr.prim) ->
    {St0,R#tr.prim};
prim_ind(St0,R,undefined) ->
    {St0,62}.
set_prim(I,R) when is_record(R,fn) ->
    R#fn{prim=I};
set_prim(I,R) when is_record(R,bi) ->
    R#bi{prim=I};
set_prim(I,R) when is_record(R,r1) ->
    R#r1{prim=I};
set_prim(I,R) when is_record(R,r2) ->
    R#r2{prim=I};
set_prim(I,R) when is_record(R,d1) ->
    R#d1{prim=I};
set_prim(I,R) when is_record(R,d2) ->
    R#d2{prim=I};
set_prim(I,R) when is_record(R,tr) ->
    R#tr{prim=I}.
decompose(St0,X,undefined) when is_record(X,a);is_record(X,c);is_number(X);is_atom(X) ->
    {St0,list(ebqn_array:from_list([-1,X]))};
decompose(St0,X,undefined) when is_record(X,bi),X#bi.prim =:= undefined,X#bi.t =/= X#bi.d#bl.t ->
    T = 3 + X#bi.d#bl.t,
    A =
        case T of
            4 ->
                ebqn_array:from_list(lists:reverse(ebqn_array:to_list(X#bi.args)));
            5 ->
                [F,G,H] = ebqn_array:to_list(X#bi.args),
                ebqn_array:from_list([G,F,H])
        end,
    {St0,list(ebqn_array:concat([ebqn_array:from_list([T]),A]))};
decompose(St0,X,undefined) when
        (is_record(X,fn) and is_number(X#fn.prim));
        (is_record(X,tr) and is_number(X#tr.prim));
        (is_record(X,r1) and is_number(X#r1.prim));
        (is_record(X,r2) and is_number(X#r2.prim));
        (is_record(X,d1) and is_number(X#d1.prim));
        (is_record(X,d2) and is_number(X#d2.prim));
        (is_record(X,bi) and is_number(X#bi.prim))
    ->
    {St0,list(ebqn_array:from_list([0,X]))};
decompose(St0,X,undefined) when is_record(X,tr),X#tr.f =:= undefined ->
    {St0,list(ebqn_array:from_list([2,X#tr.g,X#tr.h]))};
decompose(St0,X,undefined) when is_record(X,tr),X#tr.f =/= undefined ->
    {St0,list(ebqn_array:from_list([3,X#tr.f,X#tr.g,X#tr.h]))};
decompose(St0,X,undefined) when is_record(X,d1) ->
    {St0,list(ebqn_array:from_list([4,X#d1.f,X#d1.m]))};
decompose(St0,X,undefined) when is_record(X,d2) ->
    {St0,list(ebqn_array:from_list([5,X#d2.f,X#d2.m,X#d2.g]))};
decompose(St0,X,undefined) ->
    {St0,list(ebqn_array:from_list([1,X]))}.

runtime() ->
    {St0,X} = ebqn:run(ebqn:init_st(),ebqn_bc:runtime()),
    Rt = ebqn_array:get(0,X#a.r),
    Sp0 = ebqn_array:get(1,X#a.r),
    Ri = Rt#a{r=maps:map(fun ebqn:set_prim/2,Rt#a.r)},
    {St1,_} = call(St0,Sp0,list(ebqn_array:from_list([fn(fun ebqn:decompose/3),fn(fun ebqn:prim_ind/3)])),undefined),
    {ebqn_gc:gc(St1,St1#st.root,[Ri]),Ri}.
compiler(St0,Rt) ->
    {St1,C} = run(St0,ebqn_bc:compiler(Rt)).
