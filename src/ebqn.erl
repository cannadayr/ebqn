-module(ebqn).

-export([run/1,run/3,call/3,list/1,load_block/1,char/1,str/1,strings/1,fmt/1,perf/1]).
-import(queue,[cons/2,tail/1,head/1,len/1]).

-include("schema.hrl").

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
    #v{r=R,sh=Sh}.
list(A) when is_record(A,v) ->
    A;
list(A) when not is_record(A,v) ->
    arr(A,[maps:size(A)]).
char([C]) ->
    #c{p=C}.
str(S) ->
    list(ebqn_array:from_list(lists:map(fun(P) -> #c{p=P} end,S))).
strings(#v{r=X}) ->
            io_lib:format("~ts~n",[lists:map(fun(E) -> E#c.p end,ebqn_array:to_list(X))]).

call(_F,undefined,_W) ->
    undefined;
call(F,X,W) when is_number(F) ->
    F;
call(F,X,W) when is_function(F) ->
    F(X,W);
call(R,X,W) when is_record(R,r1) ->
    M = R#r1.m,
    F = R#r1.f,
    Fn = M#m1.f,
    D = Fn(F),
    call(D,X,W);
call(R,X,W) when is_record(R,r2) ->
    M = R#r2.m,
    F = R#r2.f,
    G = R#r2.g,
    Fn = M#m2.f,
    D = Fn(F,G),
    call(D,X,W);
call(F,X,W) when is_record(F,bi) ->
    0 = F#bi.t,
    D = F#bi.d,
    Args = F#bi.args,
    L = ebqn_array:concat([ebqn_array:from_list([F,X,W]),Args,ebqn_array:new(D#bl.l)]),
    load_vm(F#bi.b,F#bi.o,F#bi.s,D,make_ref(),F#bi.e,L);
call(T,X,W) when is_record(T,tr), undefined =/= T#tr.f ->
    R = call(T#tr.h,X,W),
    L = call(T#tr.f,X,W),
    call(T#tr.g,R,L);
call(T,X,W) when is_record(T,tr), undefined =:= T#tr.f ->
    R = call(T#tr.h,X,W),
    call(T#tr.g,R,undefined);
call(V,X,W) when is_record(V,v) ->
    V;
call(F,X,W) when not is_function(F) ->
    F.
call_block(M,Args) when is_record(M,bi), 0 =:= M#bi.d#bl.i ->
    M#bi{args=Args,t=0};
call_block(M,Args) when is_record(M,bi), 1 =:= M#bi.d#bl.i ->
    D = M#bi.d,
    L = ebqn_array:concat([Args,ebqn_array:new(D#bl.l - maps:size(Args))]),
    load_vm(M#bi.b,M#bi.o,M#bi.s,D,make_ref(),M#bi.e,L).
call1(M,F) when is_record(M,bi) ->
    true = (1 =:= M#bi.t),
    call_block(M,ebqn_array:from_list([M,F]));
call1(M,F) when is_record(M,m1) ->
    #r1{m=M,f=F}.
call2(M,F,G) when is_record(M,bi) ->
    true = (2 =:= M#bi.t),
    call_block(M,ebqn_array:from_list([M,F,G]));
call2(M,F,G) when is_record(M,m2) ->
    #r2{m=M,f=F,g=G}.
ge(I,E,An) when I =:= 0 ->
    E;
ge(I,E,An) when I =/= 0 ->
    #{E := Parent} = An,
    ge(I-1,Parent,An).
hset(Heap,D,#v{r=Id},#v{r=V}) ->
    maps:fold(fun(J,N,A) -> hset(A,D,N,ebqn_array:get(J,V)) end,Heap,Id);
hset(Heap,D,{E,I},V) ->
    Slot = ebqn_heap:get(E,I,Heap),
    D = (undefined =:= Slot),
    ebqn_heap:set(E,I,V,Heap).
hget(Heap,{T,I}) when is_reference(T) ->
    Z = ebqn_heap:get(T,I,Heap),
    true = (undefined =/= Z),
    Z;
hget(Heap,#v{sh=S,r=R} = I) when is_record(I,v) ->
    arr(maps:map(fun(_J,E) -> hget(Heap,E) end,R),S).
tail(L,A,S) when L =:= -1 ->
    {A,S};
tail(L,A,S) ->
    tail(L-1,ebqn_array:set(L,head(S),A),tail(S)).
popn(N,Q) when N =:= 0 ->
    Q;
popn(N,Q) when N =/= 0 ->
    popn(N-1,tail(Q)).

derive(B,O,S,#bl{t=0,i=1} = Block,E) ->
    load_vm(B,O,S,Block,make_ref(),E,ebqn_array:new(Block#bl.l));
derive(B,O,S,Block,E) ->
    #bi{b=B,o=O,s=S,t=Block#bl.t,d=Block,args=#{},e=E}.

args(B,P,Op) when Op =:= 7; Op =:= 8; Op =:= 9; Op =:= 11; Op =:= 12; Op =:= 13; Op =:= 14; Op =:= 16; Op =:= 17; Op =:= 19; Op =:= 25 ->
    {undefined,P};
args(B,P,Op) when Op =:= 0; Op =:= 3; Op =:= 4; Op =:= 15 ->
    {element(1+P,B),1+P};
args(B,P,Op) when Op =:= 21; Op =:= 22 ->
    X = element(1+P,B),
    Y = element(2+P,B),
    {{X,Y},2+P}.

stack(State,B,O,S,E,Stack,X,0) ->
    {State,cons(element(1+X,O),Stack)};
stack(State,B,O,S,E,Stack,X,Op) when Op =:= 3; Op =:= 4 ->
    {T,Si} = case X of
        0 -> {list(#{}),Stack};
        _ -> tail(X-1,ebqn_array:new(X),Stack)
    end,
    {State,cons(list(T),Si)};
stack(State,B,O,S,E,Stack,undefined,7) ->
    F = head(Stack),
    M = head(tail(Stack)),
    Sn = cons(call1(M,F),tail(tail(Stack))),
    {get(st),Sn};
stack(State,B,O,S,E,Stack,undefined,8) ->
    F = head(Stack),
    M = head(tail(Stack)),
    G = head(tail(tail(Stack))),
    Sn = cons(call2(M,F,G),tail(tail(tail(Stack)))),
    {get(st),Sn};
stack(State,B,O,S,E,Stack,undefined,9) ->
    G = head(Stack),
    J = head(tail(Stack)),
    {State,cons(#tr{f=undefined,g=G,h=J},tail(tail(Stack)))};
stack(State0,B,O,S,E,Stack,X,Op) when Op =:= 11 ->
    I = head(Stack),
    V = head(tail(Stack)),
    NxtHeap = hset(State0#st.heap,true,I,V),
    {State0#st{heap=NxtHeap},tail(Stack)};
stack(State,B,O,S,E,Stack,X,Op) when Op =:= 12 ->
    {State,tail(Stack)};
stack(State,B,O,S,E,Stack,X,13) ->
    {State,tail(tail(Stack))};
stack(State,B,O,S,E,Stack,X,14) ->
    {State,tail(Stack)};
stack(State,B,O,S,E,Stack,X,15) ->
    Block = load_block(element(1+X,S)),
    D = derive(B,O,S,Block,E),
    {get(st),cons(D,Stack)};
stack(State,B,O,S,E,Stack,undefined,16) ->
    F = head(Stack),
    X = head(tail(Stack)),
    Sn = cons(call(F,X,undefined),tail(tail(Stack))),
    {get(st),Sn};
stack(State,B,O,S,E,Stack,undefined,17) ->
    W = head(Stack),
    F = head(tail(Stack)),
    X = head(tail(tail(Stack))),
    Sn = cons(call(F,X,W),tail(tail(tail(Stack)))),
    {get(st),Sn};
stack(State,B,O,S,E,Stack,undefined,19) ->
    F = head(Stack),
    G = head(tail(Stack)),
    H = head(tail(tail(Stack))),
    {State,cons(#tr{f=F,g=G,h=H},tail(tail(tail(Stack))))};
stack(State,B,O,S,E,Stack,{X,Y},21) ->
    T = ge(X,E,State#st.an),
    Z = ebqn_heap:get(T,Y,State#st.heap),
    %true = (undefined =/= Z),
    {State,cons(Z,Stack)};
stack(State,B,O,S,E,Stack,{X,Y},22) ->
    T = ge(X,E,State#st.an),
    {State,cons({T,Y},Stack)};
stack(State,B,O,S,E,Stack,X,25) ->
    1 = len(Stack),
    {State,head(Stack)}.

heap(State,Stack,Op) when Op =:= 0; Op =:= 3; Op =:= 4; Op =:= 7; Op =:= 8; Op =:= 9; Op =:= 14; Op =:= 15; Op =:= 16; Op =:= 17; Op =:= 19; Op =:= 21; Op =:= 22; Op =:= 25; Op =:= 11 ->
    State#st.heap;
heap(State,Stack,Op) when Op =:= 12 ->
    I = head(Stack),
    V = head(tail(Stack)),
    hset(State#st.heap,false,I,V);
heap(State0,Stack,Op) when Op =:= 13 ->
    I = head(Stack),
    F = head(tail(Stack)),
    X = head(tail(tail(Stack))),
    % the following call/3 may mutate the heap
    % set the change on the proc_dict heap, not the Heap passed in via args
    % this _must_ be in separate lines!
    Result = call(F,X,hget(State0#st.heap,I)),
    State1 = get(st),
    hset(State1#st.heap,false,I,Result).

ctrl(Op) when Op =:= 0; Op =:= 3; Op =:= 4; Op =:= 7; Op =:= 8; Op =:= 9; Op =:= 11; Op =:= 12; Op =:= 13; Op =:= 14; Op =:= 15; Op =:= 16; Op =:= 17; Op =:= 19; Op =:= 21; Op =:= 22 ->
    cont;
ctrl(Op) when Op =:= 25 ->
    rtn.

vm(B,O,S,Block,E,P,Stack,rtn) ->
    % get the number of children for each environment
    State = get(st),
    An = State#st.an,
    Children = maps:fold(fun(K,V,A) -> maps:update_with(V,fun(N) -> N+1 end,1,A) end,#{},An),
    % get the number of children for this environment
    Num = maps:get(E,Children,0),
    %fmt("~p~n",[{rtn_pop,Num}]),
    put(st,State#st{rtn=popn(Num,State#st.rtn)}), % pop this number of slots off the rtn stack
    Stack;
vm(B,O,S,Block,E,P,Stack,cont) ->
    Op = element(1+P,B),
    %fmt({vm,Op,P+1,E}),
    {Arg,Pn} = args(B,1+P,Op), % advances the ptr and reads the args
    State = get(st),
    {State1,Sn} = stack(State,B,O,S,E,Stack,Arg,Op), % mutates the stack
    %State1 = get(st),
    NxtHeap = heap(State1,Stack,Op),
    put(st,State1#st{heap=NxtHeap}), % mutates the heap
    Ctrl = ctrl(Op), % set ctrl atom
    % convert stack to a usable data structure for GC
    %Slots =
    %    case Ctrl =:= rtn of
    %        true ->
    %            [Sn];
    %        false ->
    %            queue:to_list(Sn)
    %    end,
    % test for GC
    % currently using hard coded memory total
    % this should be replaced w/ either a platform specific system cmd or memsup
    % ((?MEM*1024)-erlang:memory(total)) < 1024*1024*100
    %case false of
    %    true ->
    %        Refs = mark(get(root),get(heap),get(an),get(rtn),E,Slots), % get stale refs
    %        fmt({memory,process_info(self(),[heap_size,stack_size]),erlang:memory(processes)/(1024*1024),erts_debug:flat_size(get(heap))}),
    %        put(heap,sweep(get(heap),Refs)),
    %        put(an,maps:without(sets:to_list(Refs),get(an)));
    %    false ->
    %        ok
    %end,
    vm(B,O,S,Block,E,Pn,Sn,Ctrl). % call itself with new state

trace_env(E,Root,An,Acc) when E =:= Root ->
    [E] ++ Acc;
trace_env(E,Root,An,Acc) ->
    #{E := Parent} = An,
    trace_env(Parent,Root,An,[E]++Acc).
trace([],Marked,Root,An,Heap) ->
    Marked;
trace(Todo,Marked,Root,An,Heap) when is_number(hd(Todo)); is_atom(hd(Todo)); is_function(hd(Todo)) ->
    trace(tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_tuple(hd(Todo)),is_reference(element(1,hd(Todo))) ->
    {R,_} = hd(Todo),
    trace([R]++tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_record(hd(Todo),v) ->
    V = hd(Todo),
    trace(ebqn_array:to_list(V#v.r)++tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_record(hd(Todo),tr) ->
    Tr = hd(Todo),
    F = Tr#tr.f,
    G = Tr#tr.g,
    H = Tr#tr.h,
    trace([F,G,H]++tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_record(hd(Todo),m1) ->
    D = hd(Todo),
    trace([D#m1.f]++tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_record(hd(Todo),m2) ->
    D = hd(Todo),
    trace([D#m2.f]++tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_record(hd(Todo),r1) ->
    D = hd(Todo),
    M = D#r1.m,
    F = D#r1.f,
    trace([M,F]++tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_record(hd(Todo),r2) ->
    D = hd(Todo),
    M = D#r2.m,
    F = D#r2.f,
    G = D#r2.g,
    trace([M,F,G]++tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_record(hd(Todo),bi) ->
    Bi = hd(Todo),
    trace(ebqn_array:to_list(Bi#bi.args)++[Bi#bi.e]++tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_reference(hd(Todo)) ->
    E = hd(Todo),
    {TodoN,MarkedN} =
        case sets:is_element(E,Marked) of
            true ->
                % already marked
                {tl(Todo),Marked};
            false ->
                % get env lineage
                Lineage = trace_env(E,Root,An,[]),
                % get the slots from the heap
                Slots = ebqn_array:to_list(maps:get(E,Heap)),
                {Lineage++Slots++tl(Todo),sets:add_element(E,Marked)}
        end,
    trace(TodoN,MarkedN,Root,An,Heap).
mark(Root,Heap,An,Rtn,E,Stack) ->
    % initial list of slots & environments to fold over
    Init = queue:to_list(Rtn)++Stack++[Root,E],
    % trace for references
    Marked = trace(Init,sets:new(),Root,An,Heap),
    % return the unmarked environments
    sets:subtract(sets:from_list(maps:keys(Heap)),Marked).
sweep(Heap,Refs) ->
    maps:without(sets:to_list(Refs),Heap).

load_vm(B,O,S,Block,E,Parent,V) ->
    State = get(st),
    Heap = ebqn_heap:alloc(E,V,State#st.heap),
    An0 = State#st.an,
    An = An0#{E => Parent},
    Rtn = queue:cons(E,State#st.rtn),
    put(st,State#st{heap=Heap,an=An,rtn=Rtn}),
    vm(B,O,S,Block,E,Block#bl.st,queue:new(),cont). % run vm w/ empty stack

load_block({T,I,ST,L}) ->
    #bl{t=T,i=I,st=ST,l=L}.

init(Key,T) ->
    case get(Key) of
        undefined ->
            put(Key,T);
        _ ->
            ok
    end.
init_st() ->
    #st{root=make_ref(),heap=#{},an=#{},rtn=queue:new()}.

run([B,O,S]) ->
    ebqn:run(list_to_tuple(B),list_to_tuple(O),list_to_tuple(lists:map(fun list_to_tuple/1,S))).
run(B,O,S) ->
    State = init_st(),
    put(st,State),
    #bl{i=1,l=L} = Block = load_block(element(1,S)),
    load_vm(B,O,S,Block,State#st.root,State#st.root,ebqn_array:new(L)). % set the root environment, and root as its own parent.
