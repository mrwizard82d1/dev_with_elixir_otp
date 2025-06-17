defmodule Servy.BearController do

  alias Servy.WildThings

  def index(conv) do
    bears = WildThings.list_bears()

    # TODO: Transform the list of bears to an HTML list

    %{
      conv |
      resp_body: "Teddy, Smokey, Paddington" ,
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
