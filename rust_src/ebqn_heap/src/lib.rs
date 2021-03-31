#[macro_use] extern crate rustler;
#[macro_use] extern crate lazy_static;

use std::collections::HashMap;
use std::sync::Mutex;
use rustler::{Env, Term, NifResult, Encoder};
use rustler::resource::ResourceArc;

pub struct StateResource(Mutex<State>);

#[derive(Debug)]
pub struct State {
    heap: HashMap<String, Vec<String>>
}

mod atoms {
    rustler_atoms! {
        atom ok;
    }
}

rustler_export_nifs! {
    "ebqn_heap",
    [("static_atom", 0, static_atom),
     ("native_add", 2, native_add),
     ("tuple_add", 1, tuple_add),
     ("init_st",0,init_st),
     ("alloc",1,alloc)],
    Some(on_load)
}

fn on_load(env: Env, _info: Term) -> bool {
    resource_struct_init!(StateResource, env);
    true
}

fn static_atom<'a>(env: Env<'a>, _args: &[Term<'a>]) -> NifResult<Term<'a>> {
    Ok(atoms::ok().encode(env))
}

/// Add two integers. `native_add(A,B) -> A+B.`
fn native_add<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let num1: i64 = args[0].decode()?;
    let num2: i64 = args[1].decode()?;

    Ok((num1 + num2).encode(env))
}

#[derive(NifTuple)]
struct AddTuple {
    e1: i32,
    e2: i32,
}

/// Add integers provided in a 2-tuple. `tuple_add({A,B}) -> A+B.`
fn tuple_add<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let tuple: AddTuple = args[0].decode()?;

    Ok((tuple.e1 + tuple.e2).encode(env))
}

impl State {
    pub fn empty() -> State {
        let heap: HashMap<String, Vec<String>> = HashMap::new();

        State {
            heap: heap
        }
    }

    pub fn new() -> State {
        let state = State::empty();
        state
    }
}

fn init_st<'a>(env: Env<'a>, _args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let resource = ResourceArc::new(StateResource(Mutex::new(State::new())));
    Ok((atoms::ok(),resource).encode(env))
}

fn alloc<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let e: Term = args[0].decode()?;
    Ok((atoms::ok(),e).encode(env))
}
