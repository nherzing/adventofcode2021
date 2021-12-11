defmodule DayEleven do
  def neighbors({x, y}) do
    [{x-1, y-1}, {x, y-1}, {x+1, y-1}, {x-1, y}, {x+1, y}, {x-1, y+1}, {x, y+1}, {x+1, y+1}]
    |> Enum.reject(fn {x,y} ->
      x < 0 || y < 0 || x >= 10 || y >= 10
    end)
  end

  def flash(grid) do
    to_flash = grid
    |> Map.filter(fn {_k, v} -> v > 9 end)
    |> Map.keys()

    grid = Enum.reduce(to_flash, grid, fn (pt, grid) -> Map.put(grid, pt, 0) end)

    case to_flash do
      [] -> {grid, Enum.count(grid, fn {_k, v} -> v == 0 end)}
      to_flash ->
        to_flash
        |> Enum.reduce(grid, fn (pt, grid) ->
          neighbors(pt)
          |> Enum.reduce(grid, fn (pt, grid) ->
            Map.update!(grid, pt, fn
              0 -> 0
              v -> v + 1
            end)
          end)
        end)
        |> flash()
    end
  end

  def step(grid) do
    grid
    |> Map.map(fn {_key, val} -> val + 1 end)
    |> then(fn grid -> flash(grid) end)
  end

  def result(grid) do
    Enum.reduce((0..99), {grid, 0}, fn (_i, {grid, flash_count}) ->
      {new_grid, new_flash_count} = step(grid)
      {new_grid, flash_count + new_flash_count}
    end)
    |> elem(1)
  end

  def result2(grid) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(grid, fn i, grid ->
      case step(grid) do
        {_grid, 100} -> {:halt, i}
        {grid, _flash_count} -> {:cont, grid}
      end
    end)
  end
end

"./input"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(fn line ->
  line
  |> String.to_charlist()
  |> Enum.map(&(&1 - ?0))
  |> List.to_tuple()
end)
|> List.to_tuple()
|> then(fn grid ->
  for y <- 0..9, x <- 0..9,
  into: %{}, do: {{x, y}, grid |> elem(y) |> elem(x)}
end)
|> DayEleven.result2()
|> IO.inspect()
