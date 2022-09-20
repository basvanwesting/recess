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
  %{name: "Y"},
  %{name: "Z"},
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
  |> Enum.reject(fn date -> Date.day_of_week(date) in [6,7] end) #sat/sun
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
    weight_to_assign = min(remaining_dates_to_assign, floor(adult.weight_to_assign))
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
    weight_to_assign = min(remaining_dates_to_assign, 1)
    {
      %{adult |
        number_of_assigns: adult.number_of_assigns + weight_to_assign,
        weight_to_assign: adult.weight_to_assign - weight_to_assign,
      },
      remaining_dates_to_assign - weight_to_assign
    }
  end)

adults = Enum.map(adults, &(Map.drop(&1, [:weight_to_assign, :number_of_assigns_modifier])))

GeneticAlgorithm.run(
  Jason.encode!(adults) |> IO.inspect(label: "elixir adults"),
  Jason.encode!(dates) |> IO.inspect(label: "elixir dates")
) |> Jason.decode!() |> IO.inspect()
