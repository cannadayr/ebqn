#[macro_use] extern crate rustler;

use rustler::{Env, Term, NifResult, Encoder};
use rustler::resource::ResourceArc;
use std::collections::HashMap;

struct Block {
    typ: u8,
}
enum Entity {
    Block
}
type Id = i32;
struct E {
    slots: Vec<Entity>,
    parent: Id
}
struct State {
    root: Id,
    heap: Vec<Option<E>>,
    rtn: Vec<Id>,
    id: Id,
}

mod atoms {
    rustler_atoms! {
        atom ok;
    }
}

fn on_load<'a>(env: Env<'a>, _load_info: Term<'a>) -> bool {
    resource_struct_init!(State, env);
    true
}

rustler_export_nifs! {
    "ebqn",
    [("init_st2", 0, init_st)],
    Some(on_load)
}

fn init_st<'a>(env: Env<'a>, _args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let id : Id = 0;
    let e = E {
        slots: Vec::new(),
        parent: id,
    };
    let mut heap = Vec::new();
    heap.insert(0,Some(e));
    let state = State {
        root: id,
        heap: heap,
        rtn: Vec::new(),
        id: id+1,
    };
    Ok((atoms::ok(),ResourceArc::new(state)).encode(env))
}
