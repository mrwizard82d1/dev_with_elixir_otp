defmodule Recurse do
  def sum([head | tail]) do
    IO.puts "Head: #{head}, Tail: #{inspect(tail)}"
    head + sum(tail)
  end

  def sum([]), do: 0
end

total = Recurse.sum([1, 2, 3, 4, 5])
IO.puts "The total is #{total}"
