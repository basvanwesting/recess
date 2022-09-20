defmodule GeneticAlgorithm do
  use Rustler, otp_app: :recess, crate: "genetic_algorithm"

  # When your NIF is loaded, it will override this function.
  def run(_adults_json, _dates_json, _config_json), do: :erlang.nif_error(:nif_not_loaded)
end
