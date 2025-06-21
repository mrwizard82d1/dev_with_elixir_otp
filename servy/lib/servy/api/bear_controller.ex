defmodule Servy.Api.BearController do
  def index(conv) do
    json =
      Servy.WildThings.list_bears()
      |> Poison.encode!()

    %{conv | status_code: 200, resp_content_type: "application/json", resp_body: json}
  end
end
