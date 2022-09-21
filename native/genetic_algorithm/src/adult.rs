use crate::serde_naive_date;
use crate::serde_naive_dates;
use chrono::{NaiveDate, Weekday};
use serde::{Deserialize, Serialize};
use std::hash::{Hash, Hasher};

#[derive(Debug, Serialize, Deserialize)]
pub struct Adult {
    pub name: String,
    #[serde(with = "serde_naive_date")]
    pub start_date: NaiveDate,
    #[serde(with = "serde_naive_date")]
    pub end_date: NaiveDate,
    pub allowed_weekdays: Vec<usize>,
    #[serde(default)]
    pub number_of_assigns: usize,
    #[serde(with = "serde_naive_dates")]
    #[serde(default)]
    pub assigned_dates: Vec<NaiveDate>,
}

impl Adult {
    pub fn allow_weekday(&self, weekday: Weekday) -> bool {
        match weekday {
            Weekday::Mon => self.allowed_weekdays.contains(&1),
            Weekday::Tue => self.allowed_weekdays.contains(&2),
            Weekday::Wed => self.allowed_weekdays.contains(&3),
            Weekday::Thu => self.allowed_weekdays.contains(&4),
            Weekday::Fri => self.allowed_weekdays.contains(&5),
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
