defmodule Servy.WildThings do
  alias Servy.Bear

  def list_bears do
    "lib/servy/db/bears.json"
      |> File.read!
      |> Poison.decode!(as: %{"bears" => [%Bear{}]})
      |> Map.get("bears")
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn(candidate) -> candidate.id == id end)
  end

  # Remember that a string in Elixir (and Erlang) is a **binary**.
  def get_bear(id) when is_binary(id) do
    id
    |> String.to_integer
    |> get_bear
  end
end
