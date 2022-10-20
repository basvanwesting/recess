use recess_algorithm::prelude::*;

#[rustler::nif(schedule = "DirtyCpu")]
fn call_nif(adults_json: String, dates_json: String, config_json: String) -> String {
    let mut adults: Vec<Adult> = serde_json::from_str(&adults_json).unwrap();

    let mut de = serde_json::Deserializer::from_str(&dates_json);
    let dates = serde_naive_dates::deserialize(&mut de).unwrap();

    let config: Config = serde_json::from_str(&config_json).unwrap();

    env_logger::init();

    adults.iter().for_each(|adult| log::trace!("{:?}", adult));
    log::trace!("{:?}\n", dates);
    log::trace!("{:?}\n", config);

    recess_algorithm::call(&mut adults, &dates, &config);

    serde_json::to_string(&adults).unwrap()
}

rustler::init!("Elixir.Recess.Algorithm", [call_nif]);
