EBQN
=====

EBQN is an experimental implementation of a [`BQN`](https://github.com/mlochbaum/BQN) virtual machine in Erlang.
It can interpret BQN bytecode, and compile source expressions to bytecode via the BQN self-hosted compiler.

It is extremely slow! This seems due to BQN heap operations and Erlang mutability constraints.
Using the JIT-enabled OTP 24 release is highly recommended.

There are several mitigations in consideration:

1. Implement some (or all) of the BQN runtime in Erlang.
2. Change from bytecode interpretation to AST generation via [`erl_syntax`](http://erlang.org/doc/man/erl_syntax.html)
3. Implement as a NIF via [`rustler`](https://github.com/rusterlium/rustler)

Each of these strategies have pros and cons, and further investigation will happen.

For more information on the rationale behind this project, see the following blog post by Gordon Guthrie:

[The BEAM needs an APL-y language](https://medium.com/@gordonguthrie/the-beam-needs-an-apl-y-language-6c5c998ba6d)

Installation
------------

It is recommended to use EBQN by generating BQN bytecode with DBQN.

1. Setup [BQN](https://github.com/mlochbaum/BQN)
2. Setup [DBQN](https://github.com/dzaima/BQN)
3. Setup `dbqn` as outlined in DBQN documentation.


Usage
-----

1. Generate BQN bytecode:
```
$ ./misc/cerl /path/to/mlochbaum/bqn '{𝕩×10}'
```
2. From EBQN root directory:
```
$ rebar3 shell
```
3. Load the bytecode (using the bytecode from step 1):
```
1> rr(ebqn).
2> {St0,Rt} = ebqn:runtime().
3> {St1,F} = ebqn:run(St0,[[15,1,25,0,1,0,0,21,0,1,17,25],[ebqn_array:get(2,Rt#a.r),10],[[0,1,0,0],[0,0,3,3]]]).
4> ebqn:call(St1,F,1,undefined).
```
Build
-----

    $ rebar3 compile

Test
----

    1> {St0,Rt} = ebqn:runtime().
    2> ebqn_test:test(St0,Rt).
