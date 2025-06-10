defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  defp track(%{status_code: 404, path: path} = conv) do
    IO.puts "Warning: #{path} is on the loose!"
    conv
  end

  # Default implementation returns `conv` **unchanged**
  defp track(conv), do: conv

  # The pattern, `%{path: "/wildlife"} = conv` accomplishes two
  # distinct goals. First, the expression, `%{path: "/wildlife"}`,
  # tries to match the expression with the function arguments.
  # Second, the `= conv` expression binds the entire map that
  # matches the pattern, `%{path: "/wildlife"}`.
  #
  # If the match occurs, the returned value changes the path,
  # "/wildlife", to the path, "/wildthings".
  defp rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  # "Do nothing" clause
  defp rewrite_path(conv), do: conv

  # Because `IO.inspect/1` returns its argument, we can simplify this code
  # to a "one-liner."
  def log(conv), do: IO.inspect conv

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %{
      method: method,
      path: path,
      resp_body: "",
      status_code: 500,
      reason_phrase: status_code_to_reason_phrase(500)
    }
  end

  def route(conv) do
    route(conv, conv.method, conv.path)
  end

  # The following two "functions" are actually **function clauses**. Each
  # clause of `route/3` handles an HTTP method **and** path. Elixir
  # itself uses **pattern matching** to decide which of these two clauses
  # it will execute at run-time.
  #
  # The choice of the route to fulfill the request actually depends on
  # **two** elements of the request: the path **and the method**. Let's
  # add a parameter for the request method (although currently,
  # effectively unused.)
  def route(conv, "GET", "/wildthings") do
    %{
      conv |
      resp_body: "Bears, Lions, Tigers",
      status_code: 200,
      reason_phrase: status_code_to_reason_phrase(200)
    }
  end

  def route(conv, "GET", "/bears") do
    %{
      conv |
      resp_body: "Teddy, Smokey, Paddington",
      status_code: 200,
      reason_phrase: status_code_to_reason_phrase(200)
    }
  end

  # The function definition will attempt to match `id` to a value that,
  # when concatenated to the path, "/bears/", will math the path of the
  # HTTP request.
  def route(conv, "GET", "/bears/" <> id) do
    %{
      conv |
      resp_body: "Bear #{id}",
      status_code: 200,
      reason_phrase: status_code_to_reason_phrase(200)
    }
  end

  def route(conv, "DELETE", "/bears/" <> _id) do
    %{
      conv |
      resp_body: "Deleting a bear is forbidden!",
      status_code: 403,
      reason_phrase: status_code_to_reason_phrase(403)
    }
  end

  # Define a "catch-all" route in the right place.
  def route(conv, _method, path) do
    # Because we **did not** find the requested resource, we
    # return a 404 status code
    %{
      conv |
      resp_body: "No #{path} here",
      status_code: 404,
      reason_phrase: status_code_to_reason_phrase(404)
    }
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

    # Since the following expression is a HERE doc, we can use string
    # interpolation to "splice" in fields.
    #
    """
    HTTP/1.1 #{conv.status_code} #{conv.reason_phrase}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_code_to_reason_phrase(status_code) do
    %{
    200 => "OK",
    201 => "Created",
    401 => "Unauthorized",
    403 => "Forbidden",
    404 => "Not found",
    500 => "Internal Server Error",
    }[status_code]
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

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

# Request a specific bear by its ID
request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

# Delete a specific bear by its ID
request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)
