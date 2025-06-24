defmodule Servy.BearController do
  alias Servy.Bear
  alias Servy.View
  alias Servy.WildThings

  def index(conv) do
    bears =
      WildThings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    View.render(conv, "index.eex", bears: bears)
  end

  def faq(conv) do
    faq =
      WildThings.read_faq()

    View.render(conv, "faq.eex", faq: faq)
  end

  def show(conv, %{"id" => id}) do
    bear = WildThings.get_bear(id)

    View.render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{
      conv
      | status_code: 201,
        resp_body: "Created a #{type} bear named #{name}!"
    }
  end

  def delete(conv, _id) do
    %{
      conv
      | resp_body: "Deleting a bear is forbidden!",
        status_code: 403
    }
  end
end
