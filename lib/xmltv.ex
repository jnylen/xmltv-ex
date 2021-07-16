defmodule XMLTV do
  import XmlBuilder
  alias XMLTV.Channel
  alias XMLTV.Datalist
  alias XMLTV.Programme

  @moduledoc """
  Documentation for XMLTV.
  """

  @spec as_string([any], atom | %{generator_name: any, generator_url: any}) :: {:ok, binary}
  def as_string(items, config \\ %{}) when is_list(items) do
    []
    |> Channel.add(items, config)
    |> Datalist.add(items, config)
    |> Programme.add(items, config)
    |> into_tv(config)
    |> document()
    |> generate(encoding: "utf-8")
    |> ok_wrap()
  end

  # Put the doxs into <tv></tv>
  defp into_tv(docs, config) do
    [doctype("tv", system: ["xmltv.dtd"])] ++
      [
        element(
          :tv,
          %{
            "generator-info-name" => config.generator_name,
            "generator-info-url" => config.generator_url
          },
          docs
        )
      ]
  end

  defp ok_wrap({:ok, value}), do: {:ok, value}
  defp ok_wrap({:error, reason}), do: {:error, reason}
  defp ok_wrap(other), do: {:ok, other}
end
