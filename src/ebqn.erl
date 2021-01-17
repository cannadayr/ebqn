-module(ebqn).

% ebqn:run(ebqn:runtime(b),ebqn:runtime(o),ebqn:runtime(s)).

-import(gb_trees,[insert/3,empty/0]).
-import(array,[new/2,resize/2,foldl/3,set/3,from_list/1,fix/1]).
-import(lists,[map/2]).
-export([runtime/1]).
-export([run/3,concat/2,fixed/1]).

-record(e,{s,p}). % slots, parent
-record(m1,{f}).
-record(m2,{f}).

fixed(X) ->
    fix(resize(length(X),from_list(X))).
concat(X,W) ->
    Xs = array:size(X),
    Z = resize(Xs+array:size(W),X),
    foldl(fun(I,V,A) -> set(Xs+I,V,A) end,Z,W).

vm_switch(B,O,D,P,H,E,S,cont) ->
    {B,O,D,P,H,E,S,cont}.
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
        V0 = new(L,fixed),
        C = run_env(H,E,V0,ST),
        apply(case T of
            0 -> fun(N) -> N(new(0,fixed)) end;
            1 -> fun(N) -> R = fun R(F  ) -> N(fixed([R,F  ])) end,#m1{f=R} end;
            2 -> fun(N) -> R = fun R(F,G) -> N(fixed([R,F,G])) end,#m2{f=R} end
        end,[case I of
            0 -> fun(V) -> fun R(X,W) -> C(concat(fixed([R,X,W]),fixed([V]))) end end;
            1 -> C
        end])
    end.
run_init(S) ->
    map(fun({T,I,ST,L}) -> run_block(T,I,ST,L) end,S).
run(B,O,S) ->
    E = make_ref(),
    H = insert(E,#e{},empty()),
    [F|_] = D = run_init(S),
    G = F(H,E),
    G(B,O,D).

runtime(b) ->
    <<15,1,25>>;
runtime(o) ->
    {0,1,2,32,3,8,infinity,neg_infinity,-1};
runtime(s) ->
    [{0,1,0,0}].
