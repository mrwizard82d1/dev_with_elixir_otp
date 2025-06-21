defmodule Servy.Api.BearController do
  def index(conv) do
    json =
      Servy.WildThings.list_bears()
      |> Poison.encode!()

    %{
      conv
      | status_code: 200,
        resp_headers: Map.put(conv.resp_headers, "Content-Type", "application/json"),
        resp_body: json
    }
  end
end
