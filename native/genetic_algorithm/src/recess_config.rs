use genetic_algorithm::strategy::hill_climb::HillClimbVariant;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct RecessConfig {
    pub max_stale_generations: usize,
    #[serde(with = "HillClimbVariantDef")]
    pub variant: HillClimbVariant,
    pub multithreading: bool,
    pub invalid_assign_penalty: f64,
    pub min_allowed_interval: f64,
    pub std_dev_precision: f64,
}

#[derive(Serialize, Deserialize)]
#[serde(remote = "HillClimbVariant")]
enum HillClimbVariantDef {
    Stochastic,
    SteepestAscent,
}
