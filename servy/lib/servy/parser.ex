defmodule Servy.Parser do
  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %Servy.Conv{
      method: method,
      path: path
      # Because the `Server.Conv struct` provides defaults, the following
      # code is no longer needed.
      # resp_body: "",
      # status_code: 500,
    }
  end
end
