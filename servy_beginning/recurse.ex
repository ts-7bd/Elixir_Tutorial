defmodule Recurse do

  def loopy([head | tail]) do
    IO.puts "Head: #{head} Tail: #{inspect(tail)}"
    loopy(tail)
  end
  def loopy([]), do: IO.puts "Done!"

  # Summing up a list of elements
  def summy([head | tail], total) do
    total = total + head
    summy(tail, total)
  end
  def summy([], total), do: total

  # 1. Möglichkeit - Triple
  def triple1([head|tail]) do
    [head*3 | triple(tail)]
  end
  def triple1([]), do: []

  # 2. Möglichkeit
  def triple(list) do
    triple(list, [])
  end

  defp triple([head|tail], current_list) do
    triple(tail, [head*3 | current_list])
  end

  defp triple([], current_list) do
    current_list |> Enum.reverse()
  end

  # mathematic operation like with enum.map
  def my_map(liste, funct) do
    my_map(liste, funct, [])
  end
  def my_map([head|tail], funct, new) do
    new = new ++ [funct.(head)]
    my_map(tail, funct, new)
  end
  def my_map([], funct, new), do: new

  def my_map2([head|tail], fun) do
    [fun.(head) | my_map(tail, fun)]
  end
  def my_map2([], _fun), do: []

end


list = [1,2,3,4,5,6,7,8,9]

Recurse.loopy(list)

IO.inspect(list, label: "Input ")
IO.inspect(Recurse.summy(list, 0), label: "Summe ")

IO.inspect(list, label: "Input ")
IO.inspect(Recurse.triple1(list), label: "Triple")
IO.inspect(Recurse.triple(list), label: "Triple")

IO.inspect(Enum.map(list, &:math.pow(&1, 3)), label: "Enum.map")
IO.inspect(Recurse.my_map(list, &(&1 * 5)), label: "my_map  ")
IO.inspect(Recurse.my_map2(list, &(&1 * 5)), label: "my_map2 ")

IO.inspect(Enum.reduce(list, 0, fn(x, total_so_far) -> x + total_so_far end))
