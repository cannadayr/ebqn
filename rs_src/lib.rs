#[macro_use] extern crate rustler;

use rustler::{Env, Term, NifResult, Encoder};

mod atoms {
    rustler_atoms! {
        atom an_atom;
    }
}

rustler_export_nifs! {
    "ebqn",
    [("hello", 0, hello)],
    None
}

fn hello<'a>(env: Env<'a>, _args: &[Term<'a>]) -> NifResult<Term<'a>> {
    Ok(atoms::an_atom().encode(env))
}
