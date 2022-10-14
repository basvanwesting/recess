use genetic_algorithm::strategy::hill_climb::HillClimbVariant;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct RecessConfig {
    pub max_stale_generations: usize,
    pub valid_fitness_score: Option<isize>,
    #[serde(with = "HillClimbVariantDef")]
    pub variant: HillClimbVariant,
    pub multithreading: bool,
    pub repeats: usize,
    pub seed_genes: Vec<usize>,
    pub invalid_date_penalty: isize,
    pub invalid_interval_penalty: isize,
    pub min_allowed_interval: isize,
}

#[derive(Serialize, Deserialize)]
#[serde(remote = "HillClimbVariant")]
enum HillClimbVariantDef {
    Stochastic,
    SteepestAscent,
}
