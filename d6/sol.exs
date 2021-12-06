defmodule DaySix do
  def step([a, b, c, d, e, f, g, h, i]) do
    [b, c, d, e, f, g, h + a, i, a]
  end

  def result(state) do
    (0..255)
    |> Enum.reduce(state, fn(_i, state) -> step(state) end)
    |> Enum.sum()
  end
end

"./input"
|> File.read!()
|> String.trim()
|> String.split(",", trim: true)
|> Enum.map(&String.to_integer/1)
|> Enum.group_by(&Function.identity/1)
|> then(fn(nums) -> Enum.map((0..8), fn(i) -> nums |> Map.get(i, []) |> length() end) end)
|> DaySix.result()
|> IO.inspect()
