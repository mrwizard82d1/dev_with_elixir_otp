defmodule Servy.BearController do

  alias Servy.WildThings

  def index(conv) do
    items =
      WildThings.list_bears()
      |> Enum.map(fn b -> "<li>#{b.name} - #{b.type}</li>" end)
      |> Enum.join

    %{
      conv |
      resp_body: "<ul>#{items}</ul>" ,
      status_code: 200,
    }
  end

  def show(conv, %{"id" => id}) do
    %{
      conv |
      resp_body: "Bear #{id}",
      status_code: 200,
    }
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{
      conv |
      status_code: 201,
      resp_body: "Created a #{type} bear named #{name}!",
    }
  end
end
