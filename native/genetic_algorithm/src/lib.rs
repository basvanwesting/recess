use chrono::{Datelike, NaiveDate, Weekday};
use serde::{Deserialize, Serialize};
use std::hash::{Hash, Hasher};

#[derive(Serialize, Deserialize)]
#[serde(remote = "NaiveDate")]
struct NaiveDateDef {
    #[serde(getter = "NaiveDate::year")]
    year: i32,
    #[serde(getter = "NaiveDate::month")]
    month: u32,
    #[serde(getter = "NaiveDate::day")]
    day: u32,
}
impl From<NaiveDateDef> for NaiveDate {
    fn from(def: NaiveDateDef) -> NaiveDate {
        NaiveDate::from_ymd(def.year, def.month, def.day)
    }
}

#[derive(Debug, Serialize, Deserialize)]
struct Adult {
    pub name: String,
    #[serde(with = "NaiveDateDef")]
    pub start_date: NaiveDate,
    #[serde(with = "NaiveDateDef")]
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
    #[serde(with = "NaiveDateDef")]
    pub start_date: NaiveDate,
    #[serde(with = "NaiveDateDef")]
    pub end_date: NaiveDate,
}

#[derive(Debug, Serialize, Deserialize)]
struct ExceptionDate(#[serde(with = "NaiveDateDef")] pub NaiveDate);

#[rustler::nif]
fn run(adults_json: String, periods_json: String, exception_dates_json: String) -> String {
    let adults: Vec<Adult> = serde_json::from_str(&adults_json).unwrap();
    println!("adults: {:?}", adults);

    let periods: Vec<Period> = serde_json::from_str(&periods_json).unwrap();
    println!("periods: {:?}", periods);

    let exception_dates: Vec<ExceptionDate> = serde_json::from_str(&exception_dates_json).unwrap();
    println!("exception_dates: {:?}", exception_dates);

    let serialized = serde_json::to_string(&adults).unwrap();
    serialized
}

rustler::init!("Elixir.GeneticAlgorithm", [run]);
