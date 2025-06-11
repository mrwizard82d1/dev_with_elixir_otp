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
