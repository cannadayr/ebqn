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
struct State {
    root: Id,
    heap: Vec<Option<Vec<Entity>>>,
    an: HashMap<Id,Id>,
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
    let state = State {
        root: 0,
        heap: Vec::new(),
        an: HashMap::new(),
        rtn: Vec::new(),
        id: 1,
    };

    Ok((atoms::ok(),ResourceArc::new(state)).encode(env))
}
