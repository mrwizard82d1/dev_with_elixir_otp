defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests."

  alias Servy.Conv

  @pages_path Path.expand("../../pages", __DIR__)

  # Remember that the number value in the list is the **arity** of
  # the function.
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc "Transforms a request into the appropriate response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
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
  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{
      conv |
      resp_body: "Bears, Lions, Tigers",
      status_code: 200,
    }
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    %{
      conv |
      resp_body: "Teddy, Smokey, Paddington",
      status_code: 200,
    }
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
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

  # The function definition will attempt to match `id` to a value that,
  # when concatenated to the path, "/bears/", will math the path of the
  # HTTP request.
  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    %{
      conv |
      resp_body: "Bear #{id}",
      status_code: 200,
    }
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{
      conv |
      resp_body: "Deleting a bear is forbidden!",
      status_code: 403,
    }
  end

  # Creating a new bear.
  #
  # For example, the content of the POST request is
  # "name=Baloo&type=Brown"
  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    %{
      conv |
      status_code: 201,
      resp_body: "Created a #{conv.params["type"]} bear named #{conv.params["name"]}!",
    }#
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
      Path.expand("../../pages", __DIR__)
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv)
  end

  # Define a "catch-all" route in the right place.
  def route(%Conv{method: _method, path: path} = conv) do
    # Because we **did not** find the requested resource, we
    # return a 404 status code
    %{
      conv |
      resp_body: "No #{path} here",
      status_code: 404,
    }
  end

  def format_response(%Conv{} = conv) do
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
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

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
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /big_foot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

# Request a specific bear by its ID
request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

# Delete a specific bear by its ID
request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

# Exercises 08: Rewriting
request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

#request = """
#GET /bears/new HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept: */*
#
#"""
#
#response = Servy.Handler.handle(request)
#
#IO.puts(response)

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request)

IO.puts(response)
