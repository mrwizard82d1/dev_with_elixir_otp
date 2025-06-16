defmodule Recurse do
  def sum([head | tail]) do
    IO.puts "Head: #{head}, Tail: #{inspect(tail)}"
    head + sum(tail)
  end

  def sum([]), do: 0

  def triple([head | tail]) do
    IO.puts "Head: #{head}, Tail: #{inspect(tail)}"
    [3 * head | triple(tail)]
  end

  def triple([]), do: []
end

total = Recurse.sum([1, 2, 3, 4, 5])
IO.puts "The total is #{total}"

IO.puts ""

tripled = Recurse.triple([1, 2, 3, 4, 5])
IO.puts "The tripled list is #{inspect(tripled)}"
