defmodule DayTwo do
  def result([["forward", n] | tail], hor, dep) do
    result(tail, hor + n, dep)
  end
  def result([["up", n] | tail], hor, dep) do
    result(tail, hor, dep - n)
  end
  def result([["down", n] | tail], hor, dep) do
    result(tail, hor, dep + n)
  end
  def result([], hor, dep) do
    hor * dep
  end

  def result2([["forward", n] | tail], aim, hor, dep) do
    result2(tail, aim, hor + n, dep + (aim * n))
  end
  def result2([["up", n] | tail], aim, hor, dep) do
    result2(tail, aim - n, hor, dep)
  end
  def result2([["down", n] | tail], aim, hor, dep) do
    result2(tail, aim + n, hor, dep)
  end
  def result2([], _aim, hor, dep) do
    hor * dep
  end
end

inputs = File.stream!("./input", [], :line)
|> Stream.map(&String.split/1)
|> Stream.map(fn ([cmd, n]) -> [cmd, String.to_integer(n)] end)


inputs
|> DayTwo.result(0, 0)
|> IO.puts

inputs
|> DayTwo.result2(0, 0, 0)
|> IO.puts
