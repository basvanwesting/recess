defmodule Recess.GeneticAlgorithm do
  alias Recess.Adult
  use Rustler, otp_app: :recess, crate: "genetic_algorithm"

  # When your NIF is loaded, it will override this function.
  def call_nif(_adults_json, _dates_json, _config_json), do: :erlang.nif_error(:nif_not_loaded)

  def call([%Adult{} | _] = adults, [%Date{} | _] = dates, config) do
    results = call_nif(
      Poison.encode!(adults),
      Poison.encode!(dates),
      Poison.encode!(config)
    ) |> Poison.decode!(as: [%Adult{}])

    adults
    |> Enum.map(fn adult ->
      result = Enum.find(results, fn result -> result.name == adult.name end)
      %{adult | assigned_dates: Enum.map(result.assigned_dates, &(Date.from_iso8601!(&1)))}
    end)
  end
end
