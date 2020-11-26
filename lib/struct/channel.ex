defmodule XMLTV.Channel do
  # According to XMLTV.dtd
  # Might not have all properties
  defstruct id: nil,
            name: [],
            url: nil,
            icon: nil

  import XmlStream
  alias XMLTV.Helper.Utils

  # Validators
  validates(:id, presence: true)
  validates(:name, presence: true)

  @doc """
  Add a channel XML element based on struct to a document
  """

  def add(initial_stream, channel_stream, config) do
    initial_stream
    |> Stream.concat(
      Stream.map(channel_stream, fn channel ->
        element("channel", %{id: channel.id}, compile_channel(channel, config))
      end)
    )
  end

  # Compile the fields inside of the programme
  defp compile_channel(channel, config) do
    []
    |> add_field(:name, channel.name)
    |> add_field(:baseurl, Map.get(config, :base_url))
    |> add_field(:icon, channel.icon)
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
    if Utils.lengther(baseurl) do
      docs
      |> Enum.concat([
        element(
          "base-url",
          baseurl
        )
      ])
    else
      docs
    end
  end

  defp add_field(docs, _, _), do: docs
end
