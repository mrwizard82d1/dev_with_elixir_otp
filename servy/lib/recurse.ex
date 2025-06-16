defmodule Recurse do
  def sum([head | tail], total) do
    sum(tail, head + total)
  end

  def sum([], total), do: total

  def triple(l), do: triple(l, [])

  defp triple([head | tail], result) do
    triple(tail, [3 * head | result])
  end

  defp triple([], result) do
    Enum.reverse(result)
  end
end

total = Recurse.sum([1, 2, 3, 4, 5], 0)
IO.puts "The sum is #{total}"

IO.puts ""

tripled = Recurse.triple([1, 2, 3, 4, 5])
IO.puts "The tripled list is #{inspect(tripled)}"
