-module(ebqn_rt0).

-include("schema.hrl").
-import(ebqn_core,[fn/1]).
-export([right/3]).
-export([fns/0]).

right(St0,X,_W) ->
    {St0,X}.

fns() -> [undefined,undefined,undefined,undefined,
          undefined,undefined,undefined,fn(fun right/3),
          undefined,undefined,undefined,undefined,
          undefined,undefined,undefined,undefined,
          undefined,undefined,undefined,undefined,
          undefined,undefined,undefined].
