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
    pub monday: bool,
    pub tuesday: bool,
    pub thursday: bool,
    #[serde(default)]
    pub weight_to_assign: f64,
    #[serde(default)]
    pub number_of_assigns: usize,
    #[serde(default)]
    pub number_of_assigns_modifier: isize,
    #[serde(with = "serde_naive_dates")]
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
