defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    # Split on the blank line (two newline characters) before the request body.
    [top, params_string] = String.split(request, "\n\n")

    # Split the "top" into the request line and the header **lines**.
    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines)
    # headers = parse_headers(header_lines, %{})

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers,
    }
  end

  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{},
      fn x, acc ->
        [key, value] = String.split(x, ": ")
        Map.put(acc, key, value)
    end)
  end

  defp parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim
    |> URI.decode_query
  end

  defp parse_params(_, _), do: %{}
end
