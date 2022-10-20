use crate::adult::Adult;
use chrono::{Datelike, NaiveDate};
use genetic_algorithm::fitness;
use genetic_algorithm::strategy::hill_climb::prelude::*;
//use itertools::Itertools;
use crate::config::Config;
use std::collections::HashMap;

#[derive(Clone, Debug)]
pub struct Fitness<'a>(pub &'a Vec<Adult>, pub &'a Vec<NaiveDate>, pub &'a Config);
impl<'a> fitness::Fitness for Fitness<'a> {
    type Genotype = UniqueGenotype;
    fn calculate_for_chromosome(
        &mut self,
        chromosome: &Chromosome<Self::Genotype>,
    ) -> Option<fitness::FitnessValue> {
        let adults = self.0;
        let dates = self.1;
        let config = self.2;
        let mut score: isize = 0;

        let mut assigns: HashMap<&Adult, Vec<&NaiveDate>> = HashMap::new();
        chromosome
            .genes
            .iter()
            .enumerate()
            .for_each(|(index, value)| {
                let date = &dates[index];
                let adult = &adults[*value];
                if !adult.allow_weekday(date.weekday()) {
                    score -= config.invalid_date_penalty;
                }
                if adult.start_date > *date || adult.end_date < *date {
                    score -= config.invalid_date_penalty;
                }
                assigns
                    .entry(adult)
                    .and_modify(|dates| dates.push(date))
                    .or_insert(vec![date]);
            });

        //assigns
        //.iter_mut()
        //.for_each(|(_, dates)| dates.sort_unstable());

        let mut min_interval: i64 = 999_999;
        let min_allowed_interval = config.min_allowed_interval as i64;
        adults.iter().for_each(|adult| {
            if let Some(dates) = assigns.get(adult) {
                if dates.len() > 1 {
                    dates.windows(2).for_each(|pair| {
                        let interval = (*pair[1] - *pair[0]).num_days();
                        if interval == 0 {
                            score -= config.invalid_date_penalty;
                        } else if interval < min_allowed_interval {
                            score -= config.invalid_interval_penalty;
                        }
                        if min_interval > interval {
                            min_interval = interval;
                        }
                    });
                }
            }
        });

        score += min_interval as isize;
        Some(score as isize)
    }
}
