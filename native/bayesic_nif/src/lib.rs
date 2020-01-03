use rustler::{Encoder, Env, NifResult, SchedulerFlags, Term};
use rustler::resource::ResourceArc;
use std::sync::Mutex;
use bayesic::Bayesic;

mod atoms {
    rustler::rustler_atoms! {
        atom bad_reference;
        atom error;
        atom lock_fail;
        atom ok;
        //atom __true__ = "true";
        //atom __false__ = "false";
    }
}

pub struct BayesicResource(Mutex<Bayesic>);

rustler::rustler_export_nifs! {
    "Elixir.Bayesic.Nif",
    [
        ("init", 0, init),
        ("train", 3, train),
        ("classify", 2, classify, SchedulerFlags::DirtyCpu),
        ("prune", 2, prune),
    ],
    Some(load)
}

fn load(env: Env, _info: Term) -> bool {
  rustler::resource_struct_init!(BayesicResource, env);
  true
}

fn init<'a>(env: Env<'a>, _args: &[Term<'a>]) -> NifResult<Term<'a>> {
  let resource = ResourceArc::new(BayesicResource(Mutex::new(Bayesic::new())));
  Ok((atoms::ok(), resource).encode(env))
}

fn train<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
  let resource: ResourceArc<BayesicResource> = match args[0].decode() {
    Err(_) => return Ok((atoms::error(), atoms::bad_reference()).encode(env)),
    Ok(r) => r,
  };
  let class: String = args[1].decode()?;
  let tokens: Vec<String> = args[2].decode()?;

  let mut bayesic = match resource.0.try_lock() {
    Err(_) => return Ok((atoms::error(), atoms::lock_fail()).encode(env)),
    Ok(guard) => guard,
  };

  bayesic.train(class, tokens);

  Ok(atoms::ok().encode(env))
}

fn classify<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
  let resource: ResourceArc<BayesicResource> = match args[0].decode() {
    Err(_) => return Ok((atoms::error(), atoms::bad_reference()).encode(env)),
    Ok(r) => r,
  };
  let tokens: Vec<String> = args[1].decode()?;

  let mut bayesic = match resource.0.try_lock() {
    Err(_) => return Ok((atoms::error(), atoms::lock_fail()).encode(env)),
    Ok(guard) => guard,
  };

  let classification = bayesic.classify(tokens);
  let mut result: Vec<(String, f64)> = vec!();
  for (key, value) in classification {
    result.push((key, value));
  }

  Ok((atoms::ok(), result).encode(env))
}

fn prune<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
  let resource: ResourceArc<BayesicResource> = match args[0].decode() {
    Err(_) => return Ok((atoms::error(), atoms::bad_reference()).encode(env)),
    Ok(r) => r,
  };
  let uniqueness_threshold: f64 = args[1].decode()?;

  let mut bayesic = match resource.0.try_lock() {
    Err(_) => return Ok((atoms::error(), atoms::lock_fail()).encode(env)),
    Ok(guard) => guard,
  };

  bayesic.prune(uniqueness_threshold);

  Ok(atoms::ok().encode(env))
}
