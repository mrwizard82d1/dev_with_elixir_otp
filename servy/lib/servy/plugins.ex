defmodule Servy.Plugins do
  alias Servy.Conv

  @doc "Logs 404 requests"
  def track(%Conv{status_code: 404, path: path} = conv) do
    if Mix.env() != :test do
      IO.puts("Warning: #{path} is on the loose!")
      Servy.FourOhFourCounter.bump_count(path)
    end

    conv
  end

  # Default implementation returns `conv` **unchanged**
  # By matching, `%Conv{} = conv`, we ensure that the
  # right-hand side is a `Servy.Conv struct`.
  def track(%Conv{} = conv), do: conv

  # The pattern, `%{path: "/wildlife"} = conv` accomplishes two
  # distinct goals. First, the expression, `%{path: "/wildlife"}`,
  # tries to match the expression with the function arguments.
  # Second, the `= conv` expression binds the entire map that
  # matches the pattern, `%{path: "/wildlife"}`.
  #
  # If the match occurs, the returned value changes the path,
  # "/wildlife", to the path, "/wildthings".
  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  # Rewrite paths like
  # - "/bears?id=1" to "bears/1"
  # - "/bears?id=2" to "bears/2"
  def rewrite_path(%Conv{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/#{id}"}
  end

  # "Do nothing" clause
  def rewrite_path(%Conv{} = conv), do: conv

  # Because `IO.inspect/1` returns its argument, we can simplify this code
  # to a "one-liner."
  # def log(%Conv{} = conv), do: IO.inspect conv
  def log(%Conv{} = conv) do
    if Mix.env() == :dev do
      IO.inspect(conv)
    end

    conv
  end
end
