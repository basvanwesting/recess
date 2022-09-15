
GeneticAlgorithm.run(
  Jason.encode!(
    [
      %{
        name: "Bas",
        start_date: %{year: 2022, month: 1, day: 1},
        end_date: %{year: 2022, month: 12, day: 1}
      },
      %{
        name: "Laura",
        start_date: %{year: 2022, month: 1, day: 1},
        end_date: %{year: 2022, month: 12, day: 1}
      }
    ]
  )
) |> Jason.decode!() |> IO.inspect()
