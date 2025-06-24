defmodule Servy.WildThings do
  alias Servy.Bear

  def list_bears do
    Path.expand("./db", __DIR__)
    |> Path.join("bears.json")
    |> read_json
    |> Poison.decode!(as: %{"bears" => [%Bear{}]})
    |> Map.get("bears")
  end

  def read_json(source) do
    case File.read(source) do
      {:ok, contents} ->
        contents
      {:error, reason} ->
        IO.inspect "Error reading #{source}: #{reason}"
        []
    end
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

  def read_faq() do
    IO.puts("Servy.WildThings.read_faq() called")


    IO.puts("Servy.WildThings.read_faq() returns")
  end
end
