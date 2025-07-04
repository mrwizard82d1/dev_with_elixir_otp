defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    # Split on the blank line (two newline characters) before the request body.
    [top, params_string] = String.split(request, "\r\n\r\n")

    # Split the "top" into the request line and the header **lines**.
    [request_line | header_lines] = String.split(top, "\r\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines)
    # headers = parse_headers(header_lines, %{})

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn x, acc ->
      [key, value] = String.split(x, ": ")
      Map.put(acc, key, value)
    end)
  end

  @doc """
  Parses the given param string oft he form `key1=value1&key2=value2`
  into a map with corresponding keys and values.

  ## Examples
    iex> params_string = "name=Baloo&type=Brown"
    iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
    %{"name" => "Baloo", "type" => "Brown"}
    iex> Servy.Parser.parse_params("multipart/form_data", params_string)
    %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()
  end

  def parse_params("application/json", params_string) do
    params_string
    |> String.trim()
    |> Poison.Parser.parse!(%{})
  end

  def parse_params(_, _), do: %{}
end
