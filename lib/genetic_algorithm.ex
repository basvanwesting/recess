defmodule GeneticAlgorithm do
  use Rustler, otp_app: :recess, crate: "genetic_algorithm"

  # When your NIF is loaded, it will override this function.
  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def point(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def parse(_a), do: :erlang.nif_error(:nif_not_loaded)
end
