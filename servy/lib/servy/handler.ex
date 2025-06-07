defmodule Servy.Handler do
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
