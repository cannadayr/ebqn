-module(ebqn_ast).
-export([main/0]).

main() ->
    ModuleName = foo,
    FunName = main,
    Arity = 0,
    ModuleAst = erl_syntax:attribute(erl_syntax:atom(module),[erl_syntax:atom(ModuleName)]),
    ExportAst = erl_syntax:attribute(
        erl_syntax:atom(export),
        [erl_syntax:list([erl_syntax:arity_qualifier(erl_syntax:atom(FunName),erl_syntax:integer(Arity))])]
    ),
    Fun = [erl_syntax:function(erl_syntax:atom(FunName),[erl_syntax:clause([],none,[erl_syntax:atom(okokok)])])],

    Forms = [erl_syntax:revert(X) || X <- [ModuleAst,ExportAst | Fun]],
    {ok,Module,Bin} = compile:forms(Forms,[]),

    code:purge(Module),
    {module, _} = code:load_binary(Module, atom_to_list(ModuleName) ++ ".erl", Bin),
    erlang:apply(ModuleName,FunName,[]).
