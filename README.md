# Recess

Recess planning in Elixir using a [Rust NIF](https://github.com/rusterlium/rustler) for a high performance [genetic algorithm](https://github.com/basvanwesting/genetic-algorithm).

## Run Elixir
First `cd elixir` for everything below

The data is hardcoded in `lib/run.exs` for now.
Run with `mix run lib/run.exs`

Debug Rust with RUST_LOG environment variable `RUST_LOG=debug mix run lib/run.exs`
The genetic_algorithm crate supports info/debug/trace log levels.
