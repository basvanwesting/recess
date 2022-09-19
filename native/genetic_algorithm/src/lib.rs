use chrono::{Datelike, NaiveDate, Weekday};
use serde::{Deserialize, Serialize};
use std::hash::{Hash, Hasher};

mod naive_date_serde {
    use chrono::NaiveDate;
    use serde::{Deserialize, Deserializer, Serialize, Serializer};

    pub fn serialize<S: Serializer>(
        naive_date: &NaiveDate,
        serializer: S,
    ) -> Result<S::Ok, S::Error> {
        naive_date
            .format("%Y-%m-%d")
            .to_string()
            .serialize(serializer)
    }
    pub fn deserialize<'de, D: Deserializer<'de>>(deserializer: D) -> Result<NaiveDate, D::Error> {
        let string: String = Deserialize::deserialize(deserializer)?;
        NaiveDate::parse_from_str(&string, "%Y-%m-%d").map_err(serde::de::Error::custom)
    }
}
mod naive_dates_serde {
    use chrono::NaiveDate;
    use serde::{Deserialize, Deserializer, Serialize, Serializer};

    pub fn serialize<S: Serializer>(
        naive_dates: &Vec<NaiveDate>,
        serializer: S,
    ) -> Result<S::Ok, S::Error> {
        naive_dates
            .iter()
            .map(|v| v.format("%Y-%m-%d").to_string())
            .collect::<Vec<String>>()
            .serialize(serializer)
    }
    pub fn deserialize<'de, D: Deserializer<'de>>(
        deserializer: D,
    ) -> Result<Vec<NaiveDate>, D::Error> {
        let strings: Vec<String> = Deserialize::deserialize(deserializer)?;
        strings
            .iter()
            .map(|string| {
                NaiveDate::parse_from_str(string, "%Y-%m-%d").map_err(serde::de::Error::custom)
            })
            .collect()
    }
}

#[derive(Debug, Serialize, Deserialize)]
struct Adult {
    pub name: String,
    #[serde(with = "naive_date_serde")]
    pub start_date: NaiveDate,
    #[serde(with = "naive_date_serde")]
    pub end_date: NaiveDate,
    pub monday: bool,
    pub tuesday: bool,
    pub thursday: bool,
    #[serde(default)]
    pub weight_to_assign: f64,
    #[serde(default)]
    pub number_of_assigns: usize,
    #[serde(default)]
    pub number_of_assigns_modifier: isize,
    #[serde(with = "naive_dates_serde")]
    #[serde(default)]
    pub assigned_dates: Vec<NaiveDate>,
}

impl Adult {
    pub fn allow_weekday(&self, weekday: Weekday) -> bool {
        match weekday {
            Weekday::Mon => self.monday,
            Weekday::Tue => self.tuesday,
            Weekday::Thu => self.thursday,
            _ => false,
        }
    }
}
impl PartialEq for Adult {
    fn eq(&self, other: &Self) -> bool {
        self.name == other.name
    }
}
impl Eq for Adult {}
impl Hash for Adult {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.name.hash(state);
    }
}

#[derive(Debug, Serialize, Deserialize)]
struct Period {
    #[serde(with = "naive_date_serde")]
    pub start_date: NaiveDate,
    #[serde(with = "naive_date_serde")]
    pub end_date: NaiveDate,
}

#[derive(Debug, Serialize, Deserialize)]
struct NaiveDatesWrapper {
    #[serde(with = "naive_dates_serde")]
    #[serde(default)]
    pub naive_dates: Vec<NaiveDate>,
}

#[rustler::nif]
fn run(adults_json: String, periods_json: String, exception_dates_json: String) -> String {
    let adults: Vec<Adult> = serde_json::from_str(&adults_json).unwrap();
    println!("adults: {:?}", adults);

    let periods: Vec<Period> = serde_json::from_str(&periods_json).unwrap();
    println!("periods: {:?}", periods);

    let mut de = serde_json::Deserializer::from_str(&exception_dates_json);
    let exception_dates = NaiveDatesWrapper::deserialize(&mut de).unwrap();
    println!("exception_dates: {:?}", exception_dates);

    let serialized = serde_json::to_string(&adults).unwrap();
    serialized
}

rustler::init!("Elixir.GeneticAlgorithm", [run]);
