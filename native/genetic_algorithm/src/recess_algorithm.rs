use crate::adult::Adult;
use crate::recess_config::RecessConfig;
use crate::recess_fitness::RecessFitness;
use chrono::NaiveDate;
use genetic_algorithm::strategy::hill_climb::prelude::*;
use rand::prelude::*;
use rand::rngs::SmallRng;

pub fn call(adults: &mut Vec<Adult>, dates: &Vec<NaiveDate>, recess_config: &RecessConfig) {
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

    //println!("{}", genotype);

    let hill_climb_builder = HillClimb::builder()
        .with_genotype(genotype)
        .with_variant(recess_config.variant.clone())
        .with_max_stale_generations(recess_config.max_stale_generations)
        .with_multithreading(recess_config.multithreading)
        .with_fitness(RecessFitness(&adults, &dates, recess_config))
        .with_fitness_ordering(FitnessOrdering::Minimize);

    //let now = std::time::Instant::now();
    let hill_climb = hill_climb_builder.call(&mut rng).unwrap();
    //let hill_climb = hill_climb_builder.call_repeatedly(1, &mut rng).unwrap();
    //let duration = now.elapsed();

    //println!("{}", hill_climb);

    if let Some(best_chromosome) = hill_climb.best_chromosome() {
        if let Some(_fitness_score) = best_chromosome.fitness_score {
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