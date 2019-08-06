defimpl Vex.Blank, for: DateTime do
  def blank?(nil), do: true
  def blank?(""), do: true
  def blank?(_), do: false
end

defmodule XMLTV do
  import XmlBuilder
  alias XMLTV.Programme
  alias XMLTV.Helper.Credits

  @moduledoc """
  Documentation for XMLTV.
  """

  def export(programmes, config) do
    []
    |> add_programme(programmes)
    |> into_tv(config)
    |> document()
    |> generate(encoding: "utf-8")
  end

  # Parse the programme
  defp add_programme(doc, []), do: doc

  defp add_programme(doc, [%Programme{} = programme | programmes]) do
    if Vex.valid?(programme) do
      doc
      |> Enum.concat([
        element(
          :programme,
          %{
            start: format_datetime(programme.start),
            stop: format_datetime(programme.stop),
            channel: programme.channel
          },
          compile_programme(programme)
        )
      ])
      |> add_programme(programmes)
    else
      doc
      |> add_programme(programmes)
    end
  end

  defp add_programme(doc, [_wrong_struct | programmes]), do: add_programme(doc, programmes)

  # Compile the fields inside of the programme
  defp compile_programme(programme) do
    []
    |> add_field(:title, programme.title)
    |> add_field(:subtitle, programme.subtitle)
    |> add_field(:desc, programme.desc)
    |> add_field(:credits, Credits.sort(programme.credits))
    # |> add_field(:date, programme.production_year)
    |> add_field(:category, programme)
    |> add_field(:xmltvns, programme)
  end

  # Add fields
  defp add_field(docs, :title, titles) do
    docs
    |> Enum.concat(
      Enum.map(titles, fn title ->
        element(
          :title,
          remove_nils_from_map(%{"lang" => title.language}),
          title.value
        )
      end)
    )
  end

  defp add_field(docs, :subtitle, subtitles) do
    docs
    |> Enum.concat(
      Enum.map(subtitles, fn subtitle ->
        element(
          "sub-title",
          remove_nils_from_map(%{"lang" => subtitle.language}),
          subtitle.value
        )
      end)
    )
  end

  defp add_field(docs, :desc, descriptions) do
    docs
    |> Enum.concat(
      Enum.map(descriptions, fn desc ->
        element(
          :desc,
          remove_nils_from_map(%{"lang" => desc.language}),
          desc.value
        )
      end)
    )
  end

  defp add_field(docs, :credits, credits) do
    creds = credits |> Enum.map(&add_credit/1) |> Enum.reject(&is_nil/1)

    if length(creds) > 0 do
      docs
      |> Enum.concat([
        element(
          :credits,
          creds
        )
      ])
    else
      docs
    end
  end

  defp add_field(docs, :category, %{program_type: program_type, category: genres}) do
    if is_nil(program_type) do
      docs
    else
      docs
      |> Enum.concat([
        element(
          :category,
          %{"lang" => "en"},
          program_type
        )
      ])
    end
    |> Enum.concat(
      Enum.map(genres, fn genre ->
        element(
          :category,
          %{"lang" => "en"},
          genre
        )
      end)
    )
  end

  defp add_field(docs, :xmltvns, %{season: season, episode: episode}) do
    import ExPrintf

    if lengther(season) or lengther(episode) do
      docs
      |> Enum.concat([
        element(
          "episode-num",
          %{"system" => "xmltv_ns"},
          sprintf("%s.%s.", [
            if(season |> lengther, do: (season - 1) |> to_string, else: ""),
            if(episode |> lengther, do: (episode - 1) |> to_string, else: "")
          ])
        )
      ])
    else
      docs
    end
  end

  defp add_field(docs, _, _), do: docs

  # Parse credits into an element
  defp add_credit(%{type: "director"} = credit) do
    element(
      :director,
      credit.person
    )
  end

  defp add_credit(%{type: "actor"} = credit) do
    element(
      :actor,
      remove_nils_from_map(%{"role" => credit.role}),
      credit.person
    )
  end

  defp add_credit(_), do: nil

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

  # Format datetime into correct xmltv format
  defp format_datetime(nil), do: nil

  defp format_datetime(datetime) do
    datetime
    |> Timex.format!("%Y%m%d%H%M%S %z", :strftime)
  end

  # Remove all nils from a map
  defp remove_nils_from_map(map) do
    map
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end

  defp lengther(nil), do: false
  defp lengther(""), do: false
  defp lengther(0), do: false

  defp lengther(num) do
    if num > 0 do
      true
    else
      false
    end
  end
end
