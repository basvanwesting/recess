# frozen_string_literal: true

require "ffi"
require "json"

require_relative "recess/version"
require_relative "recess/c_string"
require_relative "recess/algorithm"

module Recess
  class Error < StandardError; end

  def self.run
    adults = [
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Bibian", end_date: "2023-07-31", assigned_dates: [],    allowed_weekdays: [1, 2, 3, 4, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Daan", end_date: "2023-10-31", assigned_dates: [],      allowed_weekdays: [1, 2, 3, 4, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Daphne", end_date: "2023-07-31", assigned_dates: [],    allowed_weekdays: [1, 2, 3, 4, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Deveny", end_date: "2023-10-31", assigned_dates: [],    allowed_weekdays: [1, 2, 3, 4, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Emma", end_date: "2023-10-31", assigned_dates: [],      allowed_weekdays: [1, 2, 3, 4, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Foske", end_date: "2023-10-31", assigned_dates: [],     allowed_weekdays: [2, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Hannah", end_date: "2023-07-31", assigned_dates: [],    allowed_weekdays: [1, 4] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Jip", end_date: "2023-10-31", assigned_dates: [],       allowed_weekdays: [5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Julie", end_date: "2023-07-31", assigned_dates: [],     allowed_weekdays: [5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Madeleine", end_date: "2023-10-31", assigned_dates: [], allowed_weekdays: [1, 4] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Mees", end_date: "2023-10-31", assigned_dates: [],      allowed_weekdays: [1, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Meiske", end_date: "2023-10-31", assigned_dates: [],    allowed_weekdays: [2] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Mia", end_date: "2023-07-31", assigned_dates: [],       allowed_weekdays: [1, 2, 3, 4, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Nina", end_date: "2023-10-31", assigned_dates: [],      allowed_weekdays: [1, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Nora", end_date: "2023-10-31", assigned_dates: [],      allowed_weekdays: [1, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Olivier", end_date: "2023-10-31", assigned_dates: [],   allowed_weekdays: [1, 2, 3, 4, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Ollie", end_date: "2023-10-31", assigned_dates: [],     allowed_weekdays: [1, 2, 3, 4, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Pam", end_date: "2023-07-31", assigned_dates: [],       allowed_weekdays: [1, 2, 3, 4, 5] },
      { start_date: "2022-11-01", number_of_assigns: 2, name: "Philia", end_date: "2023-07-31", assigned_dates: [],    allowed_weekdays: [1, 2, 3, 4, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Pijke", end_date: "2023-10-31", assigned_dates: [],     allowed_weekdays: [1, 2, 3, 4, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Sophie", end_date: "2023-07-31", assigned_dates: [],    allowed_weekdays: [1, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Suzy", end_date: "2023-10-31", assigned_dates: [],      allowed_weekdays: [1, 2] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Tom", end_date: "2023-10-31", assigned_dates: [],       allowed_weekdays: [1, 5] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Tommie", end_date: "2023-10-31", assigned_dates: [],    allowed_weekdays: [1, 2] },
      { start_date: "2022-11-01", number_of_assigns: 3, name: "Yorick", end_date: "2023-07-31", assigned_dates: [],    allowed_weekdays: [2, 5] },
    ]

    dates = [
      "2022-11-01", "2022-11-01", "2022-11-08", "2022-11-08", "2022-11-15", "2022-11-15",
      "2022-11-22", "2022-11-22", "2022-11-29", "2022-11-29", "2022-12-06", "2022-12-06",
      "2022-12-13", "2022-12-13", "2022-12-20", "2022-12-20", "2023-01-12", "2023-01-12",
      "2023-01-19", "2023-01-19", "2023-01-26", "2023-01-26", "2023-02-02", "2023-02-02",
      "2023-02-09", "2023-02-09", "2023-02-16", "2023-02-16", "2023-02-23", "2023-02-23",
      "2023-03-10", "2023-03-10", "2023-03-17", "2023-03-17", "2023-03-24", "2023-03-24",
      "2023-03-31", "2023-03-31", "2023-04-14", "2023-04-14", "2023-04-21", "2023-04-21",
      "2023-05-08", "2023-05-08", "2023-05-15", "2023-05-15", "2023-05-22", "2023-05-22",
      "2023-06-05", "2023-06-05", "2023-06-12", "2023-06-12", "2023-06-19", "2023-06-19",
      "2023-06-26", "2023-06-26", "2023-07-03", "2023-07-03", "2023-08-22", "2023-08-22",
      "2023-08-29", "2023-08-29", "2023-09-05", "2023-09-05", "2023-09-12", "2023-09-12",
      "2023-09-19", "2023-09-19", "2023-09-26", "2023-09-26", "2023-10-03", "2023-10-03",
      "2023-10-10", "2023-10-10"
    ]

    config = { variant: "SteepestAscent", valid_fitness_score: 0, repeats: 1, multithreading: true, min_allowed_interval: 21, max_stale_generations: 100, invalid_interval_penalty: 100_000, invalid_date_penalty: 1_000_000 }

    result = Algorithm.call(
      JSON.generate(adults),
      JSON.generate(dates),
      JSON.generate(config),
    )
    puts result
  end
end
