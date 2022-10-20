use chrono::NaiveDate;
use serde::{Deserialize, Deserializer, Serialize, Serializer};

pub fn serialize<S: Serializer>(naive_date: &NaiveDate, serializer: S) -> Result<S::Ok, S::Error> {
    naive_date
        .format("%Y-%m-%d")
        .to_string()
        .serialize(serializer)
}
pub fn deserialize<'de, D: Deserializer<'de>>(deserializer: D) -> Result<NaiveDate, D::Error> {
    let string: String = Deserialize::deserialize(deserializer)?;
    NaiveDate::parse_from_str(&string, "%Y-%m-%d").map_err(serde::de::Error::custom)
}
