defmodule Servy.BearController do

  alias Servy.Bear
  alias Servy.WildThings

  @templates_path Path.expand("../../templates", __DIR__)

  def render(conv, template_file_name, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template_file_name)
      |> EEx.eval_file(bindings)

    %{
      conv |
      resp_body: content,
      status_code: 200,
    }
  end

  def index(conv) do
    bears =
      WildThings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = WildThings.get_bear(id)

    render(conv, "show.eex", bear: bear)
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
