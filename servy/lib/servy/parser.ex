defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    # Split on the blank line (two newline characters) before the request body.
    [top, params_string] = String.split(request, "\n\n")

    # Split the "top" into the request line and the header **lines**.
    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines)

    params = parse_params(params_string)

    IO.inspect header_lines

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers,
    }
  end

  def parse_headers([head | tail]) do
    IO.puts "Head: #{inspect(head)}, Tail #{inspect(tail)}}"

    [key, value] = String.split(head, ": ")

    IO.puts "Key: #{inspect(key)}, Value: #{inspect(value)}"

    headers = Map.put(%{}, key, value)

    IO.inspect(headers)

    parse_headers(tail)
  end

  def parse_headers([]), do: IO.puts("Done!")

  defp parse_params(params_string) do
    params_string
    |> String.trim
    |> URI.decode_query
  end
end
