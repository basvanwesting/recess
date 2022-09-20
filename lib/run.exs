default_adult = %{
  start_date: Date.from_iso8601!("2022-01-01"),
  end_date:   Date.from_iso8601!("2022-12-31"),
  monday:     true,
  tuesday:    true,
  thursday:   true,
  weight_to_assign: 0.0,
  number_of_assigns: 0,
  number_of_assigns_modifier: 0,
}

adults = [
  %{name: "A", start_date: Date.from_iso8601!("2022-06-01"), number_of_assigns_modifier: 2},
  %{name: "B", start_date: Date.from_iso8601!("2022-06-01"), number_of_assigns_modifier: -1},
  %{name: "C", start_date: Date.from_iso8601!("2022-06-01")},
  %{name: "D", start_date: Date.from_iso8601!("2022-06-01")},
  %{name: "E", start_date: Date.from_iso8601!("2022-06-01")},
  %{name: "F", start_date: Date.from_iso8601!("2022-06-01")},
  %{name: "G", start_date: Date.from_iso8601!("2022-06-01")},
  %{name: "H", start_date: Date.from_iso8601!("2022-06-01")},
  %{name: "I", start_date: Date.from_iso8601!("2022-06-01")},
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
  Date.range(
    Date.from_iso8601!("2022-01-01"),
    Date.from_iso8601!("2022-03-01")
  ),
  Date.range(
    Date.from_iso8601!("2022-04-01"),
    Date.from_iso8601!("2022-06-01")
  ),
  Date.range(
    Date.from_iso8601!("2022-07-01"),
    Date.from_iso8601!("2022-09-01")
  ),
  Date.range(
    Date.from_iso8601!("2022-10-01"),
    Date.from_iso8601!("2022-12-01")
  ),
]

exception_dates = [
  Date.from_iso8601!("2022-01-04"), #%{year: 2022, month: 1, day: 4},
  Date.from_iso8601!("2022-02-04"), #%{year: 2022, month: 2, day: 4},
] |> MapSet.new()

dates =
  periods
  |> Enum.flat_map(&(&1))
  |> Enum.filter(fn date -> Date.day_of_week(date) in [1,2,4] end) #mon/tue/thu
  |> Enum.reject(fn date -> MapSet.member?(exception_dates, date) end)

adults =
  adults
  |> Enum.map(fn adult ->
    number_of_dates =
      dates
      |> Enum.reject(fn date -> Date.compare(date, adult.start_date) == :lt end)
      |> Enum.reject(fn date -> Date.compare(date, adult.end_date) == :gt end)
      |> Enum.count()
    %{adult | weight_to_assign: number_of_dates}
  end)

number_of_dates_to_assign = length(dates)
total_weight_to_assign = Enum.reduce(adults, 0.0, fn adult, acc -> acc + adult.weight_to_assign end)

adults =
  adults
  |> Enum.map(fn adult ->
    weight_to_assign =
      adult.weight_to_assign
      |> Kernel./(total_weight_to_assign) # normalize weight_to_assign
      |> Kernel.*(number_of_dates_to_assign) # weight_to_assign in terms of fractional dates
      |> Kernel.+(adult.number_of_assigns_modifier)

    %{ adult | weight_to_assign: weight_to_assign}
  end)

# assign modulo of fractional dates
{adults, number_of_dates_to_assign} =
  adults
  |> Enum.map_reduce(number_of_dates_to_assign, fn adult, remaining_dates_to_assign ->
    weight_to_assign = min(remaining_dates_to_assign, floor(adult.weight_to_assign)) |> max(0)
    {
      %{adult |
        number_of_assigns: adult.number_of_assigns + weight_to_assign,
        weight_to_assign: adult.weight_to_assign - weight_to_assign,
      },
      remaining_dates_to_assign - weight_to_assign
    }
  end)

# assign remainder of fractional dates
{adults, _number_of_dates_to_assign} =
  adults
  |> Enum.sort_by(&(&1.weight_to_assign), :desc)
  |> Enum.map_reduce(number_of_dates_to_assign, fn adult, remaining_dates_to_assign ->
    weight_to_assign = min(remaining_dates_to_assign, 1) |> max(0)
    {
      %{adult |
        number_of_assigns: adult.number_of_assigns + weight_to_assign,
        weight_to_assign: adult.weight_to_assign - weight_to_assign,
      },
      remaining_dates_to_assign - weight_to_assign
    }
  end)

adults =
  adults
  |> Enum.map(&(Map.drop(&1, [:weight_to_assign, :number_of_assigns_modifier])))
  |> Enum.sort_by(&(&1.name))

config = %{
  max_stale_generations: 10_000,
  variant: "Stochastic",
  multithreading: false,
  #max_stale_generations: 1_000,
  #variant: "SteepestAscent",
  invalid_assign_penalty: 1_000_000,
  min_allowed_interval: 21,
  std_dev_precision: 1.0e-3,
}

results = GeneticAlgorithm.run(
  Jason.encode!(adults),
  Jason.encode!(dates),
  Jason.encode!(config)
) |> Jason.decode!() |> IO.inspect(label: "results")

#errors =
  #adults
  #|> Enum.reduce([], fn adult, errors ->
    #adult.assigned_dates
    #|> Enum.reduce(errors, fn assigned_date, errors ->
      #if Date.compare(assigned_date, adult.start_date) == :lt do
        #errors = ["adult #{adult.name}, assigned_date (#{assigned_date}) before start_date (#{adult.start_date})" | errors]
      #end
      #if Date.compare(assigned_date, adult.end_date) == :gt do
        #errors = ["adult #{adult.name}, assigned_date (#{assigned_date}) after end_date (#{adult.end_date})" | errors]
      #end
      #if Date.day_of_week(assigned_date) == 1 && !adult.monday do
        #errors = ["adult #{adult.name}, assigned_date (#{assigned_date}) is monday but not allowed" | errors]
      #end
      #if Date.day_of_week(assigned_date) == 2 && !adult.tuesday do
        #errors = ["adult #{adult.name}, assigned_date (#{assigned_date}) is monday but not allowed" | errors]
      #end
      #if Date.day_of_week(assigned_date) == 4 && !adult.thursday do
        #errors = ["adult #{adult.name}, assigned_date (#{assigned_date}) is monday but not allowed" | errors]
      #end
      #errors
    #end)
  #end)
  #|> IO.inspect()


