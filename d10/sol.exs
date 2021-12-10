defmodule DayTen do
  def score(?\)) do
    3
  end
  def score(?\]) do
    57
  end
  def score(?\}) do
    1197
  end
  def score(?>) do
    25137
  end

  def parse([c | rest]) do
    parse(rest, [c])
  end
  def parse([], stack) do
    {true, stack}
  end
  def parse([?\) | rest], [?\( | stack]) do
    parse(rest, stack)
  end
  def parse([?\] | rest], [?\[ | stack]) do
    parse(rest, stack)
  end
  def parse([?\} | rest], [?\{ | stack]) do
    parse(rest, stack)
  end
  def parse([?> | rest], [?< | stack]) do
    parse(rest, stack)
  end
  def parse([?\) | _rest], _) do
    {false, ?\)}
  end
  def parse([?\] | _rest], _) do
    {false, ?\]}
  end
  def parse([?\} | _rest], _) do
    {false, ?\}}
  end
  def parse([?> | _rest], _) do
    {false, ?>}
  end
  def parse([ c | rest], stack) do
    parse(rest, [c | stack])
  end

  def completion_score(l) do
    Enum.reduce(l, 0, fn
      (?\(, s) -> s*5 + 1
      (?\[, s) -> s*5 + 2
      (?\{, s) -> s*5 + 3
      (?\<, s) -> s*5 + 4
     end)
  end

  def result(lines) do
    lines
    |> Enum.map(&parse/1)
    |> Enum.reject(fn {v, _} -> v end)
    |> Enum.map(fn {_, c} -> score(c) end)
    |> Enum.sum()
  end

  def result2(lines) do
    lines
    |> Enum.map(&parse/1)
    |> Enum.filter(fn {v, _} -> v end)
    |> Enum.map(fn {_, s} -> completion_score(s) end)
    |> Enum.sort()
    |> then(fn l -> Enum.fetch(l, round(length(l) / 2 - 1))  end)
  end
end

"./input"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(&String.to_charlist/1)
|> DayTen.result2()
|> IO.inspect()
