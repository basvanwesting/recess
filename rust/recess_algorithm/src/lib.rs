pub mod adult;
pub mod config;
mod fitness;
pub mod prelude;
pub mod serde_naive_date;
pub mod serde_naive_dates;

use crate::adult::Adult;
use crate::config::Config;
use crate::fitness::Fitness;
use chrono::NaiveDate;
use genetic_algorithm::strategy::hill_climb::prelude::*;
use rand::prelude::*;
use rand::rngs::SmallRng;

pub fn call(adults: &mut Vec<Adult>, dates: &Vec<NaiveDate>, config: &Config) {
    let mut rng = SmallRng::from_entropy();
    let genotype = UniqueGenotype::builder()
        .with_allele_list(
            adults
                .iter()
                .enumerate()
                .flat_map(|(index, adult)| vec![index; adult.number_of_assigns])
                .collect(),
        )
        .build()
        .unwrap();

    log::info!("{}", genotype);

    let hill_climb_builder = HillClimb::builder()
        .with_genotype(genotype)
        .with_variant(config.variant.clone())
        .with_max_stale_generations(config.max_stale_generations)
        .with_valid_fitness_score_option(config.valid_fitness_score)
        .with_multithreading(config.multithreading)
        .with_fitness(Fitness(&adults, &dates, config))
        .with_fitness_ordering(FitnessOrdering::Maximize);

    let now = std::time::Instant::now();
    //let hill_climb = hill_climb_builder.call(&mut rng).unwrap();
    let hill_climb = hill_climb_builder
        .call_repeatedly(config.repeats, &mut rng)
        .unwrap();
    let duration = now.elapsed();

    log::info!("duration: {:?}", duration);

    if let Some(best_chromosome) = hill_climb.best_chromosome() {
        if let Some(fitness_score) = best_chromosome.fitness_score {
            log::info!(
                "fitness_score: {}, best_generation: {}",
                fitness_score,
                hill_climb.best_generation
            );
            log::info!("{:?}", best_chromosome.genes);
            best_chromosome
                .genes
                .iter()
                .enumerate()
                .for_each(|(index, value)| {
                    let date = &dates[index];
                    let adult = &mut adults[*value];

                    adult.assigned_dates.push(*date);
                });
        }
    }
}
