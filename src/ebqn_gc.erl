-module(ebqn_gc).

-include("schema.hrl").

-export([gc/3,mark/6,sweep/2]).

gc(St0,E,Slots) ->
    Refs = ebqn_gc:mark(St0#st.root,St0#st.heap,St0#st.an,St0#st.rtn,E,Slots),
    St0#st{heap=ebqn_gc:sweep(St0#st.heap,Refs),an=maps:without(sets:to_list(Refs),St0#st.an)}.

trace_env(E,Root,An,Acc) when E =:= Root ->
    [E] ++ Acc;
trace_env(E,Root,An,Acc) ->
    #{E := Parent} = An,
    trace_env(Parent,Root,An,[E]++Acc).
trace([],Marked,Root,An,Heap) ->
    Marked;
trace(Todo,Marked,Root,An,Heap) when is_number(hd(Todo)); is_atom(hd(Todo)); is_function(hd(Todo)); is_record(hd(Todo),c); is_record(hd(Todo),fn) ->
    trace(tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_tuple(hd(Todo)),is_reference(element(1,hd(Todo))) ->
    {R,_} = hd(Todo),
    trace([R]++tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_record(hd(Todo),a) ->
    V = hd(Todo),
    trace(ebqn_array:to_list(V#a.r)++tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_record(hd(Todo),tr) ->
    Tr = hd(Todo),
    F = Tr#tr.f,
    G = Tr#tr.g,
    H = Tr#tr.h,
    trace([F,G,H]++tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_record(hd(Todo),d1) ->
    D = hd(Todo),
    trace([D#d1.f]++tl(Todo),Marked,Root,An,Heap);
trace(Todo,Marked,Root,An,Heap) when is_record(hd(Todo),d2) ->
    D = hd(Todo),
    trace([D#d2.f]++tl(Todo),Marked,Root,An,Heap);
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
                Slots = maps:values(ebqn_heap:slots(E,Heap)),
                {Lineage++Slots++tl(Todo),sets:add_element(E,Marked)}
        end,
    trace(TodoN,MarkedN,Root,An,Heap).
mark(Root,Heap,An,Rtn,E,Stack) ->
    % initial list of slots & environments to fold over
    Init = Rtn++Stack++[Root,E],
    % trace for references
    Marked = trace(Init,sets:new(),Root,An,Heap),
    % return the unmarked environments
    sets:subtract(sets:from_list(maps:keys(Heap)),Marked).
sweep(Heap,Refs) ->
    maps:without(sets:to_list(Refs),Heap).
