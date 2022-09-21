defmodule Recess.Period do
  defstruct [:start_date, :end_date, :weekdays]

  def dates_from_periods_and_exceptions([%__MODULE__{} | _] = periods, [%Date{} | _] = exception_dates) do
    exception_set = MapSet.new(exception_dates)
    periods
    |> Enum.flat_map(fn period ->
      Date.range(period.start_date, period.end_date)
      |> Enum.filter(fn date -> Date.day_of_week(date) in period.weekdays end)
    end)
    |> Enum.reject(fn date -> MapSet.member?(exception_set, date) end)
  end
end
