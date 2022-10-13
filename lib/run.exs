default_adult = %Recess.Adult{
  start_date: ~D[2022-01-01],
  end_date:   ~D[2022-12-31],
  allowed_weekdays: [1,2,4],
  weight_to_assign: 0.0,
  number_of_assigns: 0,
  number_of_assigns_modifier: 0,
  assigned_dates: [],
}

adults = [
  %{name: "A", start_date: ~D[2022-06-01], allowed_weekdays: [1,4,5], number_of_assigns_modifier: 2},
  %{name: "B", start_date: ~D[2022-06-01], allowed_weekdays: [1,4,5], number_of_assigns_modifier: -1},
  %{name: "C", start_date: ~D[2022-06-01], allowed_weekdays: [1,4,5]},
  %{name: "D", start_date: ~D[2022-06-01], allowed_weekdays: [1,4,5]},
  %{name: "E", start_date: ~D[2022-06-01]},
  %{name: "F", start_date: ~D[2022-06-01]},
  %{name: "G", start_date: ~D[2022-06-01]},
  %{name: "H", start_date: ~D[2022-06-01]},
  %{name: "I", start_date: ~D[2022-06-01]},
  %{name: "J"},
  %{name: "K"},
  %{name: "L"},
  %{name: "M"},
  %{name: "N"},
  %{name: "O"},
  %{name: "P"},
  %{name: "Q"},
  %{name: "R"},
  %{name: "S"},
  %{name: "T"},
  %{name: "U"},
  %{name: "V"},
  %{name: "W"},
  %{name: "X"},
] |> Enum.map(fn attr -> Map.merge(default_adult, attr) end)

periods = [
  %Recess.Period{start_date: ~D[2022-01-01], end_date: ~D[2022-03-01], weekdays: [1,2]},
  %Recess.Period{start_date: ~D[2022-04-01], end_date: ~D[2022-06-01], weekdays: [1,4]},
  %Recess.Period{start_date: ~D[2022-07-01], end_date: ~D[2022-09-01], weekdays: [1,2,4,5]},
  %Recess.Period{start_date: ~D[2022-10-01], end_date: ~D[2022-12-01], weekdays: [1,2,4]},
]

exception_dates = [
  ~D[2022-01-04],
  ~D[2022-02-04],
]

dates = Recess.Period.dates_from_periods_and_exceptions(periods, exception_dates)
adults = Recess.Adult.calculate_number_of_assigns(adults, dates)

config = %{
  max_stale_generations: 100_000,
  variant: "Stochastic",
  #max_stale_generations: 1000,
  #variant: "SteepestAscent",
  multithreading: true,
  repeats: 1,
  invalid_assign_penalty: 1_000_000,
  min_allowed_interval: 21,
}

adults = Recess.GeneticAlgorithm.call(adults, dates, config)

Recess.Adult.report(adults, dates)
