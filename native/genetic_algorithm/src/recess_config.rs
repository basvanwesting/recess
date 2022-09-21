use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct RecessConfig {
    pub max_stale_generations: usize,
    pub invalid_assign_penalty: isize,
    pub min_allowed_interval: isize,
}
