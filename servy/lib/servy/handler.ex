defmodule Servy.Plugins do

  @doc "Logs 404 requests"
  def track(%{status_code: 404, path: path} = conv) do
    IO.puts "Warning: #{path} is on the loose!"
    conv
  end

  # Default implementation returns `conv` **unchanged**
  def track(conv), do: conv

  # The pattern, `%{path: "/wildlife"} = conv` accomplishes two
  # distinct goals. First, the expression, `%{path: "/wildlife"}`,
  # tries to match the expression with the function arguments.
  # Second, the `= conv` expression binds the entire map that
  # matches the pattern, `%{path: "/wildlife"}`.
  #
  # If the match occurs, the returned value changes the path,
  # "/wildlife", to the path, "/wildthings".
  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  # Rewrite paths like
  # - "/bears?id=1" to "bears/1"
  # - "/bears?id=2" to "bears/2"
  def rewrite_path(%{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/#{id}"}
  end

  # "Do nothing" clause
  def rewrite_path(conv), do: conv

  # Because `IO.inspect/1` returns its argument, we can simplify this code
  # to a "one-liner."
  def log(conv), do: IO.inspect conv

end

defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests."

  @pages_path Path.expand("../../pages", __DIR__)

  @doc "Transforms a request into the appropriate response"
  def handle(request) do
    request
    |> parse
    |> Servy.Plugins.rewrite_path
    |> Servy.Plugins.log
    |> route
    |> Servy.Plugins.track
    |> format_response
  end

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
    }
  end

#  def route(conv) do
#    route(conv, conv.method, conv.path)
#  end

  # The following two "functions" are actually **function clauses**. Each
  # clause of `route/3` handles an HTTP method **and** path. Elixir
  # itself uses **pattern matching** to decide which of these two clauses
  # it will execute at run-time.
  #
  # The choice of the route to fulfill the request actually depends on
  # **two** elements of the request: the path **and the method**. Let's
  # add a parameter for the request method (although currently,
  # effectively unused.)
  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{
      conv |
      resp_body: "Bears, Lions, Tigers",
      status_code: 200,
    }
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{
      conv |
      resp_body: "Teddy, Smokey, Paddington",
      status_code: 200,
    }
  end

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    file_path =
      @pages_path
      |> Path.join("form.html")

    case File.read(file_path) do
      {:ok, content} ->
        %{conv | status_code: 200, resp_body: content}
      {:error, :enoent} ->
        %{conv | status_code: 404, resp_body: "File not found"}
      {:error, reason} ->
        %{conv | status_code: 500, resp_body: "File error #{reason}"}
    end
  end

#  def route(%{method: "GET", path: "/bears/new"} = conv) do
#    file_path =
#      Path.expand("../../pages", __DIR__)
#      |> Path.join("form.html")
#      |> File.read
#      |> handle_file(conv)
#  end
#
#  defp handle_new({:ok, content}, conv) do
#    %{conv | status_code: 200, resp_body: content}
#  end
#
#  defp handle_new({:error, :enoent}, conv) do
#    %{conv | status_code: 404, resp_body: "File not found!"}
#  end
#
#  defp handle_new({:error, reason}, conv) do
#    %{conv | status_code: 500, resp_body: "File error: #{reason}"}
#  end


  # The function definition will attempt to match `id` to a value that,
  # when concatenated to the path, "/bears/", will math the path of the
  # HTTP request.
  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{
      conv |
      resp_body: "Bear #{id}",
      status_code: 200,
    }
  end

  def route(%{method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{
      conv |
      resp_body: "Deleting a bear is forbidden!",
      status_code: 403,
    }
  end

  def route(%{method: "GET", path: "/about"} = conv) do
      Path.expand("../../pages", __DIR__)
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv)
  end

#  def route(%{method: "GET", path: "/about"} = conv) do
#    file_path =
#      Path.expand("../../pages", __DIR__)
#      |> Path.join("about.html")
#
#    case File.read(file_path) do
#      {:ok, content} ->
#        %{conv | status_code: 200, resp_body: content}
#      {:error, :enoent} ->
#        %{conv | status_code: 404, resp_body: "File not found"}
#      {:error, reason} ->
#        %{conv | status_code: 500, resp_body: "File error #{reason}"}
#    end
#  end

  # Define a "catch-all" route in the right place.
  def route(%{method: _method, path: path} = conv) do
    # Because we **did not** find the requested resource, we
    # return a 404 status code
    %{
      conv |
      resp_body: "No #{path} here",
      status_code: 404,
    }
  end

  defp handle_file({:ok, content}, conv) do
    %{conv | status_code: 200, resp_body: content}
  end

  defp handle_file({:error, :enoent}, conv) do
    %{conv | status_code: 404, resp_body: "File not found!"}
  end

  defp handle_file({:error, reason}, conv) do
    %{conv | status_code: 500, resp_body: "File error: #{reason}"}
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
    HTTP/1.1 #{conv.status_code} #{status_code_to_reason_phrase(conv.status_code)}
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
GET /big_foot HTTP/1.1
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

# Exercises 08: Rewriting
request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

#request = """
#GET /bears/new HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept */*
#
#"""
#
#response = Servy.Handler.handle(request)
#
#IO.puts(response)
