#[macro_use] extern crate rustler;

use rustler::{Env, Term, NifResult, Encoder};
use rustler::resource::ResourceArc;

struct Block {
    t:  u8,
    i:  u8,
    st: u8,
    l:  u8,
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
    [("init_st2", 0, init_st),
     ("run2",4,run)],
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

fn load_block(block: &Vec<u8>) -> Block {
    Block {
        t: block[0],
        i: 1,
        st: 1,
        l: 1,
    }
}
fn run<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let state: ResourceArc<State> = args[0].decode()?;
    let b: Vec<i64> = args[1].decode()?;
    let o: Vec<Term> = args[2].decode()?;
    let s: Vec<Vec<u8>> = args[3].decode()?;
    let block =
        match s.get(0) {
            Some(b) => load_block(b),
            None => panic!("no initial block!"),
        };
    Ok((atoms::ok(),block.t).encode(env))
}
