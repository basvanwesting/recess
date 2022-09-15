#[rustler::nif]
fn add(a: i64, b: i64) -> i64 {
    a + b
}

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
struct Point {
    x: i64,
    y: i64,
}

#[rustler::nif]
fn point(a: i64, b: i64) -> () {
    let point = Point { x: a, y: b };

    // Convert the Point to a JSON string.
    let serialized = serde_json::to_string(&point).unwrap();

    // Prints serialized = {"x":1,"y":2}
    println!("serialized = {}", serialized);

    // Convert the JSON string back to a Point.
    let deserialized: Point = serde_json::from_str(&serialized).unwrap();

    // Prints deserialized = Point { x: 1, y: 2 }
    println!("deserialized = {:?}", deserialized);
}

#[rustler::nif]
fn parse(input: String) -> String {
    // Convert the JSON string back to a Point.
    let mut deserialized: Point = serde_json::from_str(&input).unwrap();

    // Prints deserialized = Point { x: 1, y: 2 }
    println!("deserialized = {:?}", deserialized);

    deserialized.y = 10;

    // Convert the Point to a JSON string.
    let serialized = serde_json::to_string(&deserialized).unwrap();
    serialized
}

rustler::init!("Elixir.GeneticAlgorithm", [add, point, parse]);
