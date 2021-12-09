defmodule DayNine do
  def get({x, y}, grid) do
    grid |> elem(y) |> elem(x)
  end

  def neighbors({x, y}, grid) do
    [{x, y-1}, {x, y+1}, {x-1, y}, {x+1, y}]
    |> Enum.reject(fn {x, y} ->
      y < 0 || y >= tuple_size(grid) || x < 0 || x >= tuple_size(elem(grid, 0))
    end)
  end

  def low_point?(x, y, grid) do
    v = get({x, y}, grid)

    Enum.all?(neighbors({x, y}, grid) |> Enum.map(fn pt -> get(pt, grid) end), fn n -> n > v end)
  end

  def basin(pt, grid, existing) do
    if MapSet.member?(existing, pt) || get(pt, grid) == 9 do
      existing
    else
      neighbors(pt, grid)
      |> Enum.reduce(MapSet.put(existing, pt), fn neighbor_pt, extended ->
        basin(neighbor_pt, grid, extended)
      end)
    end
  end

  def result(grid) do
    low_points = for y <- 0..tuple_size(grid)-1,
      x <- 0..tuple_size(elem(grid, 0))-1,
low_point?(x,y,grid), do: grid |> elem(y) |> elem(x)

    low_points
    |> Enum.map(fn x -> x + 1 end)
    |> Enum.sum()
  end

  def result2(grid) do
    basins = for y <- 0..tuple_size(grid)-1,
      x <- 0..tuple_size(elem(grid, 0))-1,
      low_point?(x,y,grid), do: basin({x, y}, grid, MapSet.new())

    basins
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(3)
    |> Enum.product()
  end
end

"./input"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(&String.to_charlist/1)
|> Enum.map(fn line ->
  Enum.map(line, fn c -> c - ?0 end)
  |> List.to_tuple()
end)
|> List.to_tuple()
|> DayNine.result2()
|> IO.inspect()
