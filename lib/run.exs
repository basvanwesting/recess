adults = [
  %{
    name: "Bas",
    start_date: Date.from_iso8601!("2022-01-01"), #%{year: 2022, month: 1, day: 1},
    end_date: Date.from_iso8601!("2022-12-01"), #%{year: 2022, month: 12, day: 1},
    monday: true,
    tuesday: true,
    thursday: true,
  },
  %{
    name: "Laura",
    start_date: Date.from_iso8601!("2022-01-01"), #%{year: 2022, month: 1, day: 1},
    end_date: Date.from_iso8601!("2022-12-01"), #%{year: 2022, month: 12, day: 1},
    monday: true,
    tuesday: false,
    thursday: true,
  }
]

periods = [
  Date.range(
    Date.from_iso8601!("2022-01-01"), #%{year: 2022, month: 1, day: 1},
    Date.from_iso8601!("2022-03-01") #%{year: 2022, month: 3, day: 1},
  ),
  Date.range(
    Date.from_iso8601!("2022-04-01"), #%{year: 2022, month: 4, day: 1},
    Date.from_iso8601!("2022-06-01") #%{year: 2022, month: 6, day: 1},
  ),
  Date.range(
    Date.from_iso8601!("2022-07-01"), #%{year: 2022, month: 7, day: 1},
    Date.from_iso8601!("2022-09-01") #%{year: 2022, month: 9, day: 1},
  ),
  Date.range(
    Date.from_iso8601!("2022-10-01"), #%{year: 2022, month: 10, day: 1},
    Date.from_iso8601!("2022-12-01") #%{year: 2022, month: 12, day: 1},
  ),
]

exception_dates = [
  Date.from_iso8601!("2022-01-04"), #%{year: 2022, month: 1, day: 4},
  Date.from_iso8601!("2022-02-04"), #%{year: 2022, month: 2, day: 4},
] |> MapSet.new()

dates =
  periods
  |> Enum.flat_map(&(&1))
  |> Enum.reject(fn date -> MapSet.member?(exception_dates, date) end)

GeneticAlgorithm.run(
  Jason.encode!(adults) |> IO.inspect(label: "elixir adults"),
  Jason.encode!(dates) |> IO.inspect(label: "elixir dates")
) |> Jason.decode!() |> IO.inspect()
