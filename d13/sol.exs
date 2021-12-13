defmodule DayThirteen do
  def fold(pts, {:x, x}) do
    pts
    |> Enum.reject(fn {x1, _y1} -> x1 == x end)
    |> Enum.map(fn
      {x1, y1} when x1 < x -> {x1, y1}
      {x1, y1} ->
        {x1 - 2*(x1-x), y1}
      end)
    |> MapSet.new()
  end
  def fold(pts, {:y, y}) do
    pts
    |> Enum.reject(fn {_x1, y1} -> y1 == y end)
    |> Enum.map(fn
      {x1, y1} when y1 < y -> {x1, y1}
      {x1, y1} ->
        {x1, y1 - 2*(y1-y)}
    end)
    |> MapSet.new()
  end

  def result(pts, folds) do
    folds
    |> Enum.reduce(pts, fn f, pts -> fold(pts, f) end)
    |> draw()
  end

  def draw(pts) do
    max_x = Enum.max_by(pts, &elem(&1, 0)) |> elem(0)
    max_y = Enum.max_by(pts, &elem(&1, 1)) |> elem(1)
    for y <- 0..max_y do
      for x <- 0..max_x do
        if MapSet.member?(pts, {x, y}) do
          IO.write("#")
        else
          IO.write(".")
        end
      end
      IO.puts("")
    end
  end
end

"./input"
|> File.read!()
|> String.split("\n\n", trim: true)
|> then(fn [pts, folds] ->
  {
    pts
    |> String.split("\n", trim: true)
    |> Enum.map(fn pt ->
      pt |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end),
    folds
    |> String.split("\n", trim: true)
    |> Enum.map(fn
      "fold along y=" <> y -> {:y, String.to_integer(y)}
      "fold along x=" <> x -> {:x, String.to_integer(x)}
     end)
  }
end)
|> then(fn {pts, folds} -> DayThirteen.result(MapSet.new(pts), folds) end)
|> IO.inspect()
