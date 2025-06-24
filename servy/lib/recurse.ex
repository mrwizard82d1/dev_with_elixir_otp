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

  def my_map([h | t], f) do
    [f.(h) | my_map(t, f)]
  end

  def my_map([], _f), do: []
end

total = Recurse.sum([1, 2, 3, 4, 5], 0)
IO.puts("The sum is #{total}")

IO.puts("")

tripled = Recurse.triple([1, 2, 3, 4, 5])
IO.puts("The tripled list is #{inspect(tripled)}")

double = &(2 * &1)
triple = &(3 * &1)
quadruple = &(4 * &1)

doubled = Recurse.my_map([1, 2, 3, 4, 5], double)
IO.puts("The mapped list using double/1 is #{inspect(doubled)}")
tripled = Recurse.my_map([1, 2, 3, 4, 5], triple)
IO.puts("The mapped list using triple/1 is #{inspect(tripled)}")
quadrupled = Recurse.my_map([1, 2, 3, 4, 5], quadruple)
IO.puts("The mapped list using quadruple/1 is #{inspect(quadrupled)}")
