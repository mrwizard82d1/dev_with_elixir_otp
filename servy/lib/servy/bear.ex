defmodule Servy.Bear do
  defstruct id: nil, name: "", type: "", hibernating: false

  def grizzly?(bear) do
    bear.type == "Grizzly"
  end

  def order_asc_by_name(left, right) do
    left.name <= right.name
  end
end
