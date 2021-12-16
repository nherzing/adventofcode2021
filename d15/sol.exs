defmodule Solver do
  def iterate(grid, costs) do
    {dx, dy} = Enum.max(Map.keys(grid))

    Enum.reduce(0..dx, costs, fn x, costs ->
      Enum.reduce(0..dy, costs, fn y, costs ->
        left_cost = Map.get(costs, {x-1, y}, 99999999999)
        up_cost = Map.get(costs, {x, y-1}, 99999999999)
        right_cost = Map.get(costs, {x+1, y}, 99999999999)
        down_cost = Map.get(costs, {x, y+1}, 99999999999)
        mc = Enum.min([left_cost, up_cost, right_cost, down_cost]) + grid[{x, y}]
        Map.update(costs, {x, y}, mc, fn v -> Enum.min([v, mc]) end)
      end)
    end)
  end

  def result(grid) do
    {dx, dy} = Enum.max(Map.keys(grid))


    costs = Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(%{{0, 0} => 0}, fn i, costs ->
      new_costs = iterate(grid, costs)
      if costs == new_costs do
        {:halt, costs}
      else
        {:cont, new_costs}
      end
    end)


    costs[{dx, dy}]
  end

  def result2(grid) do
    {mx, my} = Enum.max(Map.keys(grid))
    dx = mx + 1
    dy = my + 1

    expanded_grid = Enum.reduce(0..dy*5-1, grid, fn y, grid ->
      grid = if y >= dy do
          Enum.reduce(0..dx-1, grid, fn x, grid ->
            rl = grid[{x, y-dy}] + 1
            rl = if rl == 10, do: 1, else: rl
            Map.put_new(grid, {x, y}, rl)
          end)
        else
          grid
        end

      Enum.reduce(dx..dx*5-1, grid, fn x, grid ->
        rl = grid[{x-dx, y}] + 1
        rl = if rl == 10, do: 1, else: rl
        Map.put_new(grid, {x, y}, rl)
      end)
    end)

    result(expanded_grid)
  end
end

"./input"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(&String.to_charlist/1)
|> Enum.map(&List.to_tuple/1)
|> List.to_tuple()
|> then(fn lines ->
  dim = tuple_size(lines)
  Map.new(for x <- 0..dim-1, y <- 0..dim-1, do: {{x, y}, lines |> elem(y) |> elem(x) |> then(&(&1 - ?0)) })
end)
|> Solver.result2()
|> IO.inspect()
