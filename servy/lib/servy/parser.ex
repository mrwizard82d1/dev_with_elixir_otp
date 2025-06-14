defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    # Split on the blank line (two newline characters) before the request body.
    [top, params_string] = String.split(request, "\n\n")

    # Split the "top" into the request line and the header **lines**.
    [request_line | _header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")

    params = parse_params(params_string)

    # This implementation works, but it is insufficient. (It does not capture
    # the HTTP headers.)

    %Conv{
      method: method,
      path: path,
      params: params,
    }
  end

  defp parse_params(params_string) do
    params_string
    |> String.trim
    |> URI.decode_query
  end
end
