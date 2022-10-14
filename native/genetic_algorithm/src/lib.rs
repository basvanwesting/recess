mod adult;
mod recess_algorithm;
mod recess_config;
mod recess_fitness;
mod serde_naive_date;
mod serde_naive_dates;

use self::adult::Adult;
use self::recess_config::RecessConfig;

#[rustler::nif(schedule = "DirtyCpu")]
fn call_nif(adults_json: String, dates_json: String, recess_config_json: String) -> String {
    let mut adults: Vec<Adult> = serde_json::from_str(&adults_json).unwrap();

    let mut de = serde_json::Deserializer::from_str(&dates_json);
    let dates = serde_naive_dates::deserialize(&mut de).unwrap();

    let recess_config: RecessConfig = serde_json::from_str(&recess_config_json).unwrap();

    env_logger::init();

    adults.iter().for_each(|adult| log::debug!("{:?}", adult));
    log::debug!("{:?}\n", dates);
    log::debug!("{:?}\n", recess_config);

    recess_algorithm::call(&mut adults, &dates, &recess_config);

    serde_json::to_string(&adults).unwrap()
}

rustler::init!("Elixir.Recess.GeneticAlgorithm", [call_nif]);
