-module(ebqn_gc).

-include("schema.hrl").

% misc stuff from ebqn.erl

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
