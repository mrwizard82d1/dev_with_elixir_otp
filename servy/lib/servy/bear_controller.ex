defmodule Servy.BearController do
  def index(conv) do
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
