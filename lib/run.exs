adults = [
  %{
    name: "Bas",
    start_date: "2022-01-01", #%{year: 2022, month: 1, day: 1},
    end_date: "2022-12-01", #%{year: 2022, month: 12, day: 1},
    monday: true,
    tuesday: true,
    thursday: true,
  },
  %{
    name: "Laura",
    start_date: "2022-01-01", #%{year: 2022, month: 1, day: 1},
    end_date: "2022-12-01", #%{year: 2022, month: 12, day: 1},
    monday: true,
    tuesday: false,
    thursday: true,
  }
]

periods = [
  %{
    start_date: "2022-01-01", #%{year: 2022, month: 1, day: 1},
    end_date: "2022-03-01", #%{year: 2022, month: 3, day: 1},
  },
  %{
    start_date: "2022-04-01", #%{year: 2022, month: 4, day: 1},
    end_date: "2022-06-01", #%{year: 2022, month: 6, day: 1},
  },
  %{
    start_date: "2022-07-01", #%{year: 2022, month: 7, day: 1},
    end_date: "2022-09-01", #%{year: 2022, month: 9, day: 1},
  },
  %{
    start_date: "2022-10-01", #%{year: 2022, month: 10, day: 1},
    end_date: "2022-12-01", #%{year: 2022, month: 12, day: 1},
  },
]

exception_dates = [
  "2022-01-04", #%{year: 2022, month: 1, day: 4},
  "2022-02-04", #%{year: 2022, month: 2, day: 4},
]

GeneticAlgorithm.run(
  Jason.encode!(adults),
  Jason.encode!(periods),
  Jason.encode!(exception_dates)
) |> Jason.decode!() |> IO.inspect()
