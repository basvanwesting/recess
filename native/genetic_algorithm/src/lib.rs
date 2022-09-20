mod adult;
mod recess_algorithm;
mod recess_config;
mod recess_fitness;
mod serde_naive_date;
mod serde_naive_dates;

use self::adult::Adult;
use self::recess_config::RecessConfig;

#[rustler::nif]
fn run(adults_json: String, dates_json: String, recess_config_json: String) -> String {
    //println!("");
    //println!("=== entering rust ===");
    let mut adults: Vec<Adult> = serde_json::from_str(&adults_json).unwrap();

    let mut de = serde_json::Deserializer::from_str(&dates_json);
    let dates = serde_naive_dates::deserialize(&mut de).unwrap();

    let recess_config: RecessConfig = serde_json::from_str(&recess_config_json).unwrap();
    //println!("recess_config: {:?}", recess_config);

    recess_algorithm::run(&mut adults, &dates, &recess_config);

    let serialized = serde_json::to_string(&adults).unwrap();
    //println!("=== leaving rust ===");
    serialized
}

rustler::init!("Elixir.GeneticAlgorithm", [run]);
