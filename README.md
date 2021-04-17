EBQN
=====

EBQN is an experimental implementation of a `BQN` [0] virtual machine in Erlang.
It can interpret BQN bytecode, and compile source expressions to bytecode via the BQN self-hosted compiler.

It is extremely slow! This seems due to BQN heap operations and Erlang mutability constraints.

There are several mitigations in consideration:

1. Test with the JIT compiler from the upcoming OTP 24 release.
2. Implement some (or all) of the BQN runtime in Erlang.
3. Change from bytecode interpretation to AST generation via `erl_syntax`
4. Implement as a NIF via `rustler` [1]

Each of these strategies have pros and cons, and further investigation will need to happen.

Build
-----

    $ rebar3 compile

Test
----

    1> {St0,Rt} = ebqn:runtime().
    2> ebqn_test:test(St0,Rt).

[0] https://github.com/mlochbaum/BQN

[1] https://github.com/rusterlium/rustler
