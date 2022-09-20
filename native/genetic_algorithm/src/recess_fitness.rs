use crate::adult::Adult;
use chrono::{Datelike, NaiveDate};
use genetic_algorithm::strategy::hill_climb::prelude::*;
//use itertools::Itertools;
use crate::recess_config::RecessConfig;
use statrs::statistics::Data;
use statrs::statistics::OrderStatistics;
use std::collections::HashMap;

#[derive(Clone, Debug)]
pub struct RecessFitness<'a>(
    pub &'a Vec<Adult>,
    pub &'a Vec<NaiveDate>,
    pub &'a RecessConfig,
);
impl<'a> Fitness for RecessFitness<'a> {
    type Genotype = UniqueGenotype;
    fn calculate_for_chromosome(
        &mut self,
        chromosome: &Chromosome<Self::Genotype>,
    ) -> Option<FitnessValue> {
        let adults = self.0;
        let dates = self.1;
        let recess_config = self.2;
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
                    score -= recess_config.invalid_assign_penalty;
                }
                if adult.start_date > *date || adult.end_date < *date {
                    score -= recess_config.invalid_assign_penalty;
                }
                assigns
                    .entry(adult)
                    .and_modify(|dates| dates.push(date))
                    .or_insert(vec![date]);
            });

        let mut min_intervals: Vec<f64> = vec![];
        adults.iter().for_each(|adult| {
            if let Some(dates) = assigns.get(adult) {
                if dates.len() > 1 {
                    let mut adult_intervals: Vec<i64> = vec![];
                    dates.windows(2).for_each(|pair| {
                        let interval = (*pair[1] - *pair[0]).num_days();
                        if interval < recess_config.min_allowed_interval {
                            score -= recess_config.invalid_assign_penalty;
                        }
                        adult_intervals.push(interval);
                    });
                    min_intervals.push(Iterator::min(adult_intervals.into_iter()).unwrap() as f64);
                }
            }
        });

        let mut x = Data::new(min_intervals);
        score += x.percentile(0) / recess_config.std_dev_precision;

        Some(score as isize)
    }
}
