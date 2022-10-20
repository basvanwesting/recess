default_adult = %Recess.Adult{
  weight_to_assign: 0.0,
  number_of_assigns: 0,
  number_of_assigns_modifier: 0,
  assigned_dates: [],
}

adults = [
  %{ name: "Sophie",    allowed_weekdays: [1,5],       start_date: ~D[2022-11-01], end_date: ~D[2023-07-31]},
  %{ name: "Hannah",    allowed_weekdays: [1,4],       start_date: ~D[2022-11-01], end_date: ~D[2023-07-31]},
  #%{ name: "Hannah",    allowed_weekdays: [1,4,5],     start_date: ~D[2022-11-01], end_date: ~D[2023-07-31]},
  %{ name: "Yorick",    allowed_weekdays: [2,5],       start_date: ~D[2022-11-01], end_date: ~D[2023-07-31]},
  %{ name: "Julie",     allowed_weekdays: [5],         start_date: ~D[2022-11-01], end_date: ~D[2023-07-31]},
  %{ name: "Bibian",    allowed_weekdays: [1,2,3,4,5], start_date: ~D[2022-11-01], end_date: ~D[2023-07-31]},
  %{ name: "Daphne",    allowed_weekdays: [1,2,3,4,5], start_date: ~D[2022-11-01], end_date: ~D[2023-07-31]},
  %{ name: "Mia",       allowed_weekdays: [1,2,3,4,5], start_date: ~D[2022-11-01], end_date: ~D[2023-07-31]},
  %{ name: "Pam",       allowed_weekdays: [1,2,3,4,5], start_date: ~D[2022-11-01], end_date: ~D[2023-07-31]},
  %{ name: "Philia",    allowed_weekdays: [1,2,3,4,5], start_date: ~D[2022-11-01], end_date: ~D[2023-07-31]},
  %{ name: "Nina",      allowed_weekdays: [1,5],       start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  %{ name: "Meiske",    allowed_weekdays: [2],         start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  #%{ name: "Meiske",    allowed_weekdays: [2,5],       start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  %{ name: "Nora",      allowed_weekdays: [1,5],       start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  %{ name: "Madeleine", allowed_weekdays: [1,4],       start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  %{ name: "Tommie",    allowed_weekdays: [1,2],       start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  %{ name: "Jip",       allowed_weekdays: [5],         start_date: ~D[2022-11-01], end_date: ~D[2023-10-31], number_of_assigns_modifier: 0},
  %{ name: "Tom",       allowed_weekdays: [1,5],       start_date: ~D[2022-11-01], end_date: ~D[2023-10-31], number_of_assigns_modifier: 0},
  %{ name: "Mees",      allowed_weekdays: [1,5],       start_date: ~D[2022-11-01], end_date: ~D[2023-10-31], number_of_assigns_modifier: 0},
  %{ name: "Suzy",      allowed_weekdays: [1,2],       start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  %{ name: "Daan",      allowed_weekdays: [1,2,3,4,5], start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  %{ name: "Deveny",    allowed_weekdays: [1,2,3,4,5], start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  %{ name: "Emma",      allowed_weekdays: [1,2,3,4,5], start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  %{ name: "Ollie",     allowed_weekdays: [1,2,3,4,5], start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  %{ name: "Olivier",   allowed_weekdays: [1,2,3,4,5], start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  %{ name: "Pijke",     allowed_weekdays: [1,2,3,4,5], start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
  %{ name: "Foske",     allowed_weekdays: [2,5],       start_date: ~D[2022-11-01], end_date: ~D[2023-10-31]},
] |> Enum.map(fn attr -> Map.merge(default_adult, attr) end)

periods = [
  %Recess.Period{start_date: ~D[2022-11-01], end_date: ~D[2022-12-20], weekdays: [2]},
  %Recess.Period{start_date: ~D[2023-01-12], end_date: ~D[2023-02-23], weekdays: [4]},
  %Recess.Period{start_date: ~D[2023-03-10], end_date: ~D[2023-04-21], weekdays: [5]},
  %Recess.Period{start_date: ~D[2023-05-08], end_date: ~D[2023-07-03], weekdays: [1]},
  %Recess.Period{start_date: ~D[2023-08-22], end_date: ~D[2023-10-10], weekdays: [2]}, #lower group only
]

exception_dates = [
  ~D[2023-04-07],
  ~D[2023-05-29],
]

dates = Recess.Period.dates_from_periods_and_exceptions(periods, exception_dates)
adults = Recess.Adult.calculate_number_of_assigns(adults, dates)

#dates  |> IO.inspect()
#adults |> Enum.sort_by(fn a -> a.weight_to_assign end) |> Enum.each(&Recess.Adult.inspect/1)

config = %{
  #max_stale_generations: 10,
  #variant: "Stochastic",
  max_stale_generations: 100,
  variant: "SteepestAscent",
  valid_fitness_score: 0,
  multithreading: true,
  repeats: 1,
  invalid_date_penalty: 1_000_000,
  invalid_interval_penalty: 100_000,
  min_allowed_interval: 21,
}

adults = Recess.Algorithm.call(adults, dates, config)

Recess.Adult.report(adults, dates)
