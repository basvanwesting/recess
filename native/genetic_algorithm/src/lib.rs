mod adult;
mod recess_algorithm;
mod recess_fitness;
mod serde_naive_date;
mod serde_naive_dates;

use self::adult::Adult;

#[rustler::nif]
fn run(adults_json: String, dates_json: String) -> String {
    let mut adults: Vec<Adult> = serde_json::from_str(&adults_json).unwrap();

    let mut de = serde_json::Deserializer::from_str(&dates_json);
    let dates = serde_naive_dates::deserialize(&mut de).unwrap();

    recess_algorithm::run(&mut adults, &dates);

    let serialized = serde_json::to_string(&adults).unwrap();
    serialized
}

rustler::init!("Elixir.GeneticAlgorithm", [run]);
