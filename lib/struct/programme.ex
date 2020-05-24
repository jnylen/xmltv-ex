defmodule XMLTV.Programme do
  # According to XMLTV.dtd
  # Might not have all properties
  defstruct start: nil,
            stop: nil,
            channel: nil,
            title: [],
            subtitle: [],
            desc: [],
            credits: [],
            date: nil,
            category: [],
            season: nil,
            episode: nil,
            of_episodes: nil,
            country: [],
            video: %{},
            audio: %{},
            previously_shown: nil,
            new: nil,
            url: nil,
            icon: nil

  use Vex.Struct
  import XmlBuilder
  alias XMLTV.Helper.Credits
  alias XMLTV.Helper.Utils

  # Validators
  validates(:start, presence: true)
  validates(:stop, presence: true)
  validates(:channel, presence: true)
  validates(:title, presence: true)

  @doc """
  Add a programme based on a struct to a XML document
  """
  def add(doc, [], _config), do: doc

  def add(doc, [%XMLTV.Programme{} = programme | programmes], config) do
    if Vex.valid?(programme) do
      [
        element(
          :programme,
          %{
            start: Utils.format_datetime(programme.start),
            stop: Utils.format_datetime(programme.stop),
            channel: programme.channel
          },
          compile_programme(programme)
        )
        | doc
      ]
      |> add(programmes, config)
    else
      doc
      |> add(programmes, config)
    end
  end

  def add(doc, [_wrong_struct | programmes], config), do: add(doc, programmes, config)

  # Compile the fields inside of the programme
  defp compile_programme(programme) do
    []
    |> add_field(:title, programme.title)
    |> add_field(:subtitle, programme.subtitle)
    |> add_field(:desc, programme.desc)
    |> add_field(:credits, Credits.sort(programme.credits))
    |> add_field(:date, programme)
    |> add_field(:category, programme)
    |> add_field(:icon, programme)
    |> add_field(:country, programme)
    |> add_field(:xmltvns, programme)
    |> add_field(:previously_shown, programme)
    |> add_field(:new, programme)
  end

  # Add fields

  defp add_field(docs, :title, titles) do
    docs ++
      Enum.map(titles, fn title ->
        element(
          :title,
          Utils.remove_nils_from_map(%{"lang" => title.language}),
          title.value
        )
      end)
  end

  defp add_field(docs, :subtitle, subtitles) do
    docs ++
      Enum.map(subtitles, fn subtitle ->
        element(
          "sub-title",
          Utils.remove_nils_from_map(%{"lang" => subtitle.language}),
          subtitle.value
        )
      end)
  end

  defp add_field(docs, :desc, descriptions) do
    docs ++
      Enum.map(descriptions, fn desc ->
        element(
          :desc,
          Utils.remove_nils_from_map(%{"lang" => desc.language}),
          desc.value
        )
      end)
  end

  defp add_field(docs, :credits, credits) do
    creds = credits |> Enum.map(&add_credit/1) |> Enum.reject(&is_nil/1)

    if length(creds) > 0 do
      [
        element(
          :credits,
          creds
        )
        | docs
      ]
    else
      docs
    end
  end

  defp add_field(docs, :category, %{category: category}) do
    docs ++
      Enum.map(category, fn val ->
        element(
          :category,
          %{"lang" => "en"},
          val
        )
      end)
  end

  defp add_field(docs, :country, %{country: country}) do
    docs ++
      Enum.map(country, fn val ->
        element(
          :country,
          val
        )
      end)
  end

  defp add_field(docs, :date, %{date: %Date{} = date}) do
    [
      element(
        :date,
        date
        |> Date.to_iso8601()
      )
      | docs
    ]
  end

  defp add_field(docs, :xmltvns, %{season: season, episode: episode}) do
    import ExPrintf

    if Utils.lengther(season) or Utils.lengther(episode) do
      [
        element(
          "episode-num",
          %{"system" => "xmltv_ns"},
          sprintf("%s.%s.", [
            if(season |> Utils.lengther(), do: (season - 1) |> to_string, else: ""),
            if(episode |> Utils.lengther(), do: (episode - 1) |> to_string, else: "")
          ])
        )
        | docs
      ]
    else
      docs
    end
  end

  defp add_field(docs, :previously_shown, %{previously_shown: true}) do
    [element(:previously_shown) | docs]
  end

  defp add_field(docs, :previously_shown, %{previously_shown: val}) when is_bitstring(val) do
    [element(:previously_shown, val) | docs]
  end

  defp add_field(docs, :icon, %{icon: val}) when is_bitstring(val) do
    [element(:icon, %{"src" => val}) | docs]
  end

  defp add_field(docs, :new, %{new: true}) do
    [element(:new) | docs]
  end

  defp add_field(docs, :new, %{new: val}) when is_bitstring(val) do
    [element(:new, val) | docs]
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
      Utils.remove_nils_from_map(%{"role" => credit.role}),
      credit.person
    )
  end

  defp add_credit(_), do: nil
end
