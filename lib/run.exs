adults = [
  %{
    name: "Bas",
    start_date: %{year: 2022, month: 1, day: 1},
    end_date: %{year: 2022, month: 12, day: 1},
    monday: true,
    tuesday: true,
    thursday: true,
  },
  %{
    name: "Laura",
    start_date: %{year: 2022, month: 1, day: 1},
    end_date: %{year: 2022, month: 12, day: 1},
    monday: true,
    tuesday: false,
    thursday: true,
  }
]

periods = [
  %{
    start_date: %{year: 2022, month: 1, day: 1},
    end_date: %{year: 2022, month: 3, day: 1},
  },
  %{
    start_date: %{year: 2022, month: 4, day: 1},
    end_date: %{year: 2022, month: 6, day: 1},
  },
  %{
    start_date: %{year: 2022, month: 7, day: 1},
    end_date: %{year: 2022, month: 9, day: 1},
  },
  %{
    start_date: %{year: 2022, month: 10, day: 1},
    end_date: %{year: 2022, month: 12, day: 1},
  },
]

GeneticAlgorithm.run(
  Jason.encode!(adults),
  Jason.encode!(periods)
) |> Jason.decode!() |> IO.inspect()
