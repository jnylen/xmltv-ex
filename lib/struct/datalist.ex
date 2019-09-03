defmodule XMLTV.Datalist do
  # Datalist isn't a XMLTV-standardized structure,
  # but it follows the common structure
  defstruct channel_id: nil,
            channel_names: [],
            base_url: [],
            data_for: []

  use Vex.Struct
  import XmlBuilder
  alias XMLTV.Helper.Utils

  # Validators
  validates(:channel_id, presence: true)
  validates(:channel_names, presence: true)

  @doc """
  Add a channel XML element based on struct to a document
  """
  def add(doc, [], _), do: doc

  def add(doc, [%XMLTV.Datalist{} = datalist | datalists], config) do
    if Vex.valid?(datalist) do
      doc
      |> Enum.concat([
        element(
          :channel,
          %{
            id: datalist.channel_id
          },
          compile_channel(datalist, config)
        )
      ])
      |> add(datalists, config)
    else
      doc
      |> add(datalists, config)
    end
  end

  def add(doc, [_wrong_struct | datalists], config),
    do: add(doc, datalists, config)

  # Compile the fields inside of the programme
  defp compile_channel(datalist, config) do
    []
    |> add_field(:name, datalist.channel_names)
    |> add_field(:baseurl, datalist.base_url)
    |> add_field(:datafor, datalist.data_for)
  end

  # Add fields
  defp add_field(docs, :name, names) do
    docs
    |> Enum.concat(
      Enum.map(names, fn name ->
        element(
          "display-name",
          Utils.remove_nils_from_map(%{"lang" => name.language}),
          name.value
        )
      end)
    )
  end

  defp add_field(docs, :baseurl, baseurl) do
    docs
    |> Enum.concat(
      Enum.map(baseurl, fn url ->
        element(
          "base-url",
          url
        )
      end)
    )
  end

  defp add_field(docs, :datafor, datafors) do
    docs
    |> Enum.concat(
      Enum.map(datafors, fn datafor ->
        element(
          "datafor",
          %{"lastmodified" => Utils.format_datetime(datafor.last_modified)},
          datafor.date
        )
      end)
    )
  end

  defp add_field(docs, _, _), do: docs
end
