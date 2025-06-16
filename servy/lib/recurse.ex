defmodule Recurse do
  def sum([head | tail], total) do
    sum(tail, head + total)
  end

  def sum([], total), do: total

  def triple([head | tail]) do
    IO.puts "Head: #{head}, Tail: #{inspect(tail)}"
    [3 * head | triple(tail)]
  end

  def triple([]), do: []
end

total = Recurse.sum([1, 2, 3, 4, 5], 0)
IO.puts "The sum is #{total}"

IO.puts ""

tripled = Recurse.triple([1, 2, 3, 4, 5])
IO.puts "The tripled list is #{inspect(tripled)}"
