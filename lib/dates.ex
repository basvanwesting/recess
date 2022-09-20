defmodule Recess.Dates do
  def from_periods_and_exceptions([%Date.Range{} | _] = periods, [%Date{} | _] = exception_dates) do
    exception_set = MapSet.new(exception_dates)
    periods
    |> Enum.flat_map(&(&1))
    |> Enum.filter(fn date -> Date.day_of_week(date) in [1,2,4] end) #mon/tue/thu
    |> Enum.reject(fn date -> MapSet.member?(exception_set, date) end)
  end
end
