defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> route
    |> format_response
  end

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %{method: method, path: path, resp_body: ""}
  end

  def route(conv) do
    %{conv | resp_body: "Bears, Lions, Tigers"}
  end

  def format_response(conv) do
    # A HERE doc describing the expected response.
    #
    # We expect three header lines, a blank line, and a response line.
    #
    # The first header line is the status line consisting of
    #
    # - HTTP version
    # - Status code
    # - Reason phrase
    #
    # The `Content-Type` line specifies the expected format

    # The `Content-Length` line specifies the number of characters in the body.

    # TODO: Use values in the map to create an HTTP response string:
    # Since the following expression is a HERE doc, we can use string
    # interpolation to "splice" in fields.
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

# Utilizes an Elixir "HERE Doc"
# An empty (blank) line separates the header from the body. We have no body,
# but we still need the empty line.
request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)