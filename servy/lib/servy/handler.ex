defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests."

  alias Servy.BearController
  alias Servy.Conv
  alias Servy.Fetcher

  @pages_path Path.expand("../../pages", __DIR__)

  # Remember that the number value in the list is the **arity** of
  # the function.
  # import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Plugins, only: [rewrite_path: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc "Transforms a request into the appropriate response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    # |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/snapshots"} = conv) do
    # spawn(fn -> send(parent, {:result, Servy.VideoCam.get_snapshot(camera_name)}) end)
    Fetcher.async(fn -> Servy.VideoCam.get_snapshot("cam-1") end)
    Fetcher.async(fn -> Servy.VideoCam.get_snapshot("cam-2") end)
    Fetcher.async(fn -> Servy.VideoCam.get_snapshot("cam-3") end)

    snapshot1 = Fetcher.get_result()
    snapshot2 = Fetcher.get_result()
    snapshot3 = Fetcher.get_result()

    snapshots = [snapshot1, snapshot2, snapshot3]

    %{conv | status_code: 200, resp_body: inspect(snapshots)}
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()

    %{conv | status_code: 200, resp_body: "Awake!"}
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{
      conv
      | resp_body: "Bears, Lions, Tigers",
        status_code: 200
    }
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
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
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    BearController.delete(conv, id)
  end

  # Creating a new bear.
  #
  # For example, the content of the POST request is
  # "name=Baloo&type=Brown"
  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> name} = conv) do
    @pages_path
    |> Path.join("#{name}.md")
    |> IO.inspect(label: "URL")
    |> File.read()
    |> handle_file(conv)
    |> markdown_to_html
  end

  # Define a "catch-all" route in the right place.
  def route(%Conv{method: _method, path: path} = conv) do
    # Because we **did not** find the requested resource, we
    # return a 404 status code
    %{
      conv
      | resp_body: "No #{path} here!",
        status_code: 404
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
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  def format_response_headers(conv) do
    conv.resp_headers
    |> Enum.map(fn {key, value} -> "#{key}: #{value}\r" end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  def put_content_length(conv) do
    %{
      conv
      | resp_headers: Map.put(conv.resp_headers, "Content-Length", byte_size(conv.resp_body))
    }
  end

  def markdown_to_html(%Conv{status_code: 200} = conv) do
    %{conv | resp_body: Earmark.as_html!(conv.resp_body)}
  end

  def markdown_to_html(%Conv{} = conv), do: conv
end
