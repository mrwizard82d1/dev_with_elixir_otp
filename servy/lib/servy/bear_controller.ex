defmodule Servy.BearController do

  alias Servy.Bear
  alias Servy.WildThings

  @templates_path Path.expand("../../templates", __DIR__)

  def index(conv) do
    bears =
      WildThings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    content =
      @templates_path
      |> Path.join("index.eex")
      |> EEx.eval_file(bears: bears)

    %{
      conv |
      resp_body: content ,
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

  def delete(conv, _id) do
    %{
      conv |
      resp_body: "Deleting a bear is forbidden!",
      status_code: 403,
    }
  end
end
