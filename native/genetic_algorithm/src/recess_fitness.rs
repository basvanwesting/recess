use crate::adult::Adult;
use chrono::{Datelike, NaiveDate};
use genetic_algorithm::strategy::hill_climb::prelude::*;
//use itertools::Itertools;
use statrs::statistics::Statistics;
use std::collections::HashMap;

const INVALID_ASSIGN_PENALTY: f64 = 1_000_000.0;
const MIN_ALLOWED_INTERVAL: f64 = 21.0;
//const MEAN_MULTIPLIER: f64 = 100.0;
const STD_DEV_MULTIPLIER: f64 = 1000.0;

#[derive(Clone, Debug)]
pub struct RecessFitness<'a>(pub &'a Vec<Adult>, pub &'a Vec<NaiveDate>);
impl<'a> Fitness for RecessFitness<'a> {
    type Genotype = UniqueGenotype;
    fn calculate_for_chromosome(
        &mut self,
        chromosome: &Chromosome<Self::Genotype>,
    ) -> Option<FitnessValue> {
        let adults = self.0;
        let dates = self.1;
        let mut score = 0.0;

        let mut assigns: HashMap<&Adult, Vec<&NaiveDate>> = HashMap::new();
        chromosome
            .genes
            .iter()
            .enumerate()
            .for_each(|(index, value)| {
                let date = &dates[index];
                let adult = &adults[*value];
                if !adult.allow_weekday(date.weekday()) {
                    score += INVALID_ASSIGN_PENALTY;
                }
                if adult.start_date > *date || adult.end_date < *date {
                    score += INVALID_ASSIGN_PENALTY;
                }
                assigns
                    .entry(adult)
                    .and_modify(|dates| dates.push(date))
                    .or_insert(vec![date]);
            });

        let mut intervals: Vec<f64> = vec![];
        adults.iter().for_each(|adult| {
            if let Some(dates) = assigns.get(adult) {
                dates.windows(2).for_each(|pair| {
                    let interval = (*pair[1] - *pair[0]).num_days() as f64;
                    if interval < MIN_ALLOWED_INTERVAL {
                        score += INVALID_ASSIGN_PENALTY;
                    }
                    intervals.push(interval);
                });
            }
        });

        //let mean = Statistics::mean(&intervals);
        //score -= MEAN_MULTIPLIER * mean; // maximize mean
        let std_dev = Statistics::population_std_dev(&intervals);
        score += STD_DEV_MULTIPLIER * std_dev; // minimize std_dev

        Some(score as isize)
    }
}
