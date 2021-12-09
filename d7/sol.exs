defmodule DaySeven do
  def cost(nums, n) do
    nums
    |> Enum.map(&(abs(n - &1)))
    |> Enum.map(&(1..&1))
    |> Enum.map(&Enum.sum/1)
    |> Enum.sum()
  end

  def result(nums) do
    (Enum.min(nums)..Enum.max(nums))
    |> Enum.map(fn n -> {n, cost(nums, n)} end)
    |> Enum.min_by(fn {_n, cost} -> cost end)
    |> then(&(elem(&1, 1)))
  end
end

"./input"
|> File.read!()
|> String.trim()
|> String.split(",")
|> Enum.map(&String.to_integer/1)
|> DaySeven.result()
|> IO.inspect()
