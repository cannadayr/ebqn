#[macro_use] extern crate rustler;
//#[macro_use] extern crate lazy_static;

use std::collections::HashMap;
use std::sync::Mutex;
use rustler::{Env, Term, NifResult, Encoder, Binary};
use rustler::resource::ResourceArc;

pub struct StateResource(Mutex<State>);

#[derive(Debug)]
enum HeapEntity {
    E(u8) // m1,m2,r1,r2,bi,bl,fn, etc maybe a box type (ptr to heap)
}

#[derive(Debug)]
pub struct State {
    heap: HashMap<Vec<u8>, Vec<HeapEntity>>
}

#[derive(Debug, PartialEq)]
pub enum StateResult {
    Ok
}

mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
        atom lock_fail;
    }
}

rustler_export_nifs! {
    "ebqn_heap",
    [("init_st",0,init_st),
     ("init_id",0,init_id),
     ("alloc",2,alloc)],
    Some(on_load)
}

fn on_load(env: Env, _info: Term) -> bool {
    resource_struct_init!(StateResource, env);
    true
}

impl State {
    pub fn empty() -> State {
        let heap: HashMap<Vec<u8>,Vec<HeapEntity>> = HashMap::new();

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

fn init_id<'a>(env: Env<'a>, _args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let id = xid::new().as_bytes().to_vec();

    Ok((atoms::ok(),id).encode(env))
}

fn alloc<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let resource: ResourceArc<StateResource> = args[0].decode()?;

    let mut state = match resource.0.try_lock() {
        Err(_) => return Ok((atoms::error(), atoms::lock_fail()).encode(env)),
        Ok(guard) => guard,
    };

    Ok((atoms::ok()).encode(env))
}
