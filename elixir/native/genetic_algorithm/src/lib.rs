use recess_algorithm::adult::Adult;
use recess_algorithm::recess_config::RecessConfig;

#[rustler::nif(schedule = "DirtyCpu")]
fn call_nif(adults_json: String, dates_json: String, recess_config_json: String) -> String {
    let mut adults: Vec<Adult> = recess_algorithm::serde_json::from_str(&adults_json).unwrap();

    let mut de = recess_algorithm::serde_json::Deserializer::from_str(&dates_json);
    let dates = recess_algorithm::serde_naive_dates::deserialize(&mut de).unwrap();

    let recess_config: RecessConfig =
        recess_algorithm::serde_json::from_str(&recess_config_json).unwrap();

    env_logger::init();

    adults.iter().for_each(|adult| log::trace!("{:?}", adult));
    log::trace!("{:?}\n", dates);
    log::trace!("{:?}\n", recess_config);

    recess_algorithm::recess_algorithm::call(&mut adults, &dates, &recess_config);

    recess_algorithm::serde_json::to_string(&adults).unwrap()
}

rustler::init!("Elixir.Recess.GeneticAlgorithm", [call_nif]);
