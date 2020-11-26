defmodule XMLTV do
  import XmlStream
  alias XMLTV.Channel
  alias XMLTV.Datalist
  alias XMLTV.Programme

  @moduledoc """
  Documentation for XMLTV.
  """

  @spec as_string([any], atom | %{generator_name: any, generator_url: any}) :: {:ok, binary}
  def as_string(channel_stream, datalist_stream, programme_stream, file_name, config \\ %{})
      when is_list(items) do
    rows =
      []
      |> Channel.add(channel_stream, config)
      |> Datalist.add(datalist_stream, config)
      |> Programme.add(programme_stream, config)

    stream!(
      [
        declaration(),
        doctype("tv", system: ["xmltv.dtd"]),
        element(
          "tv",
          %{
            "generator-info-name" => config.generator_name,
            "generator-info-url" => config.generator_url
          },
          rows
        )
      ],
      printer: XmlStream.Printer.Ugly
    )
    |> Stream.into(File.stream!(file_name))
    |> Stream.run()
  end
end
