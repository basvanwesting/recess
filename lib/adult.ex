defmodule Recess.Adult do
  @derive {Poison.Encoder, except: [:weight_to_assign, :number_of_assigns_modifier]}
  defstruct [:name, :start_date, :end_date, :allowed_weekdays, :assigned_dates, :number_of_assigns, :number_of_assigns_modifier, :weight_to_assign,]

  def calculate_number_of_assigns([%__MODULE__{} | _] = adults, [%Date{} | _] = dates) do
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

    adults |> Enum.sort_by(&(&1.name))
  end

  def errors([%__MODULE__{} | _] = adults) do
    adults
    |> Enum.reduce([], fn adult, errors ->
      adult.assigned_dates
      |> Enum.reduce(errors, fn assigned_date, errors ->
        errors = if Date.compare(assigned_date, adult.start_date) == :lt do
          ["adult #{adult.name}, assigned_date (#{assigned_date}) before start_date (#{adult.start_date})" | errors]
        else
          errors
        end
        errors = if Date.compare(assigned_date, adult.end_date) == :gt do
          ["adult #{adult.name}, assigned_date (#{assigned_date}) after end_date (#{adult.end_date})" | errors]
        else
          errors
        end
        _errors = if Date.day_of_week(assigned_date) not in adult.allowed_weekdays do
          ["adult #{adult.name}, assigned_date (#{assigned_date}) is weekday #{Date.day_of_week(assigned_date)} but not allowed" | errors]
        else
          errors
        end
      end)
    end)
    |> Enum.reverse()
  end

  def report([%__MODULE__{} | _] = adults, [%Date{} | _] = dates) do
    IO.puts("DATES: #{length(dates)}")

    IO.puts("")
    IO.puts("ASSIGNS:")
    Enum.each(adults, fn adult ->
      case adult.assigned_dates do
        [] -> IO.puts("Adult #{adult.name}, no assigned_dates")
        [date] -> IO.puts("Adult #{adult.name}, #{date} (#{Date.day_of_week(date)})")
        dates ->
          stats =
            dates
            |> Enum.chunk_every(2, 1, :discard)
            |> Enum.map(fn [a, b] -> Date.diff(b, a) end)
            |> Statistex.statistics()

          formatted_dates =
            dates
            |> Enum.map(fn date -> "#{date} (#{Date.day_of_week(date)})" end)
            |> Enum.join(", ")

          IO.puts("Adult #{adult.name}, #{formatted_dates} (minimum interval: #{stats.minimum} days)")
      end
    end)

    IO.puts("")
    IO.puts("ERRORS:")
    Enum.each(errors(adults), &(IO.puts(&1)))

    IO.puts("")
    IO.puts("STATS (of minimum interval per adult):")
    stats =
      adults
      |> Enum.map(fn adult ->
        adult.assigned_dates
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(fn [a, b] -> Date.diff(b, a) end)
        |> Enum.min(fn -> 0 end)
      end)
      |> Enum.filter(fn i -> i > 0 end)
      |> Statistex.statistics()
    IO.puts("average: #{Float.round(stats.average, 1)}")
    IO.puts("minimum: #{stats.minimum}")
    IO.puts("maximum: #{stats.maximum}")
    IO.puts("standard_deviation: #{Float.round(stats.standard_deviation, 1)}")

    IO.puts("")
    IO.puts("STATS (of all intervals):")
    stats =
      adults
      |> Enum.flat_map(fn adult ->
        adult.assigned_dates
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(fn [a, b] -> Date.diff(b, a) end)
      end)
      |> Statistex.statistics()
    IO.puts("average: #{Float.round(stats.average, 1)}")
    IO.puts("minimum: #{stats.minimum}")
    IO.puts("maximum: #{stats.maximum}")
    IO.puts("standard_deviation: #{Float.round(stats.standard_deviation, 1)}")
  end
end
