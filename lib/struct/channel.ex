defmodule XMLTV.Channel do
  # According to XMLTV.dtd
  # Might not have all properties
  defstruct id: nil,
            name: [],
            url: nil,
            icon: nil

  use Vex.Struct

  # Validators
  validates(:id, presence: true)
  validates(:name, presence: true)
end
