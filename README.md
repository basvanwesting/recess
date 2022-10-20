# Recess

Recess planning in Elixir and Ruby using a genetic algorithm implementation in Rust.

## Elixir Implementation

Recess planning in Elixir using a [Rust NIF](https://github.com/rusterlium/rustler).

First `cd elixir` for everything below

The data is hardcoded in `lib/run.exs` for now.
Run with `RUST_LOG=debug mix run lib/run.exs`

## Ruby Implementation

Recess planning in Ruby using [FFI](https://github.com/ffi/ffi).

First `cd ruby` for everything below

The data is hardcoded in `lib/recess.rb` for now.
Run with `RUST_LOG=debug bundle exec exe/recess`

## Rust Implementation

This is shared Rust library using the [genetic algorithm](https://github.com/basvanwesting/genetic-algorithm) crate.

The genetic_algorithm crate supports info/debug/trace log levels.

