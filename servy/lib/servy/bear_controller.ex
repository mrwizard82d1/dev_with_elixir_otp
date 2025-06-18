defmodule Servy.BearController do

  alias Servy.Bear
  alias Servy.WildThings

  defp bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end

  def index(conv) do
    items =
      WildThings.list_bears()
      |> Enum.filter(&Bear.grizzly?/1)
      |> Enum.sort(&Bear.order_asc_by_name/2)
      |> Enum.map(&bear_item/1)
      |> Enum.join

    %{
      conv |
      resp_body: "<ul>#{items}</ul>" ,
      status_code: 200,
    }
  end

  def show(conv, %{"id" => id}) do
    bear = WildThings.get_bear(id)

    %{
      conv |
      resp_body: "Bear #{bear.id} - <h1>#{bear.name}</h1>",
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
