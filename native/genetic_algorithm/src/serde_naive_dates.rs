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
pub fn deserialize<'de, D: Deserializer<'de>>(deserializer: D) -> Result<Vec<NaiveDate>, D::Error> {
    let strings: Vec<String> = Deserialize::deserialize(deserializer)?;
    strings
        .iter()
        .map(|string| {
            NaiveDate::parse_from_str(string, "%Y-%m-%d").map_err(serde::de::Error::custom)
        })
        .collect()
}
