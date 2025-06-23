defmodule Servy.Api.BearController do
  def index(conv) do
    json =
      Servy.WildThings.list_bears()
      |> Poison.encode!()

    conv = put_resp_content_type(conv, "application/json")

    %{
      conv
      | status_code: 200,
        resp_body: json
    }
  end

  def create(conv, %{"name" => name, "type" => type}) do
    conv = put_resp_content_type(conv, "text/html")

    %{
      conv
      | status_code: 201,
        resp_body: "Created a #{type} bear named #{name}!"
    }
  end

  def put_resp_content_type(conv, content_type) do
    %{
      conv
      | resp_headers: Map.put(conv.resp_headers, "Content-Type", content_type)
    }
  end
end
