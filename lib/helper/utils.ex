defmodule XMLTV.Helper.Utils do
  # Format datetime into correct xmltv format
  def format_datetime(nil), do: nil

  def format_datetime(datetime) do
    datetime
    |> Timex.format!("%Y%m%d%H%M%S %z", :strftime)
  end

  # Remove all nils from a map
  def remove_nils_from_map(map) do
    map
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end

  def lengther(nil), do: false
  def lengther(""), do: false
  def lengther(0), do: false

  def lengther(num) do
    if num > 0 do
      true
    else
      false
    end
  end
end
