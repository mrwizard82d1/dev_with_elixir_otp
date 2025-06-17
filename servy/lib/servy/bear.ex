defmodule Servy.Bear do
  defstruct id: nil, name: "", type: "", hibernating: false

  def grizzly?(bear) do
    bear.type == "Grizzly"
  end
end
