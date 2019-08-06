defmodule XMLTV.Helper.Credits do
  @moduledoc """
  Sort the credits by where it should actually be in an xmltv dtd.
  """

  def sort(list) when is_list(list) do
    list
    |> Enum.sort(&(type_score(&1.type) < type_score(&2.type)))
  end

  defp type_score("director"), do: 1
  defp type_score("actor"), do: 2
  defp type_score("writer"), do: 3
  defp type_score("adapter"), do: 4
  defp type_score("producer"), do: 5
  defp type_score("composer"), do: 6
  defp type_score("editor"), do: 7
  defp type_score("presenter"), do: 8
  defp type_score("commentator"), do: 9
  defp type_score("guest"), do: 10
  defp type_score(_), do: 1000
end
