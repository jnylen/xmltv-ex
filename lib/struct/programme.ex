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
            country: nil,
            video: %{},
            audio: %{},
            previously_shown: nil,
            url: nil,
            icon: nil

  use Vex.Struct

  # Validators
  validates(:start, presence: true)
  validates(:stop, presence: true)
  validates(:channel, presence: true)
end
