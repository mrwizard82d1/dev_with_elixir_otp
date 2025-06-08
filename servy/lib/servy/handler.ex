defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> route
    |> format_response
  end

  def parse(_request) do
    # TODO: Parse the request string into a map:
    _conv = %{method: "GET", path: "/wildthings", resp_body: ""}
  end

  def route(_conv) do
    # TODO: Create a new map that also has the response body:
    _conv = %{method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers"}
  end

  def format_response(_conv) do
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
    3
    # The `Content-Length` line specifies the number of characters in the body.

    # TODO: Use values in the map to create an HTTP response string:
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    Bears, Lions, Tigers
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

# Another HERE doc describing the expected response.
# We expect three header lines, a blank line, and a response line.
# The first header line is the status line consisting of
#
# - HTTP version
# - Status code
# - Reason phrase
# The `Content-Type` line specifies the expected format
# The `Content-Length` line specifies the number of characters in the body.
expected_response = """
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 20

Bears, Lions, Tigers
"""

response = Servy.Handler.handle(request)

IO.puts(response)