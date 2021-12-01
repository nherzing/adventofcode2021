depths = File.stream!("./input", [], :line) |> Enum.map(&Integer.parse/1) |> Enum.map(&(elem(&1, 0)))

IO.puts(length(Enum.filter(Enum.zip(depths, Enum.drop(depths, 1)), fn {a, b} -> b > a end)))


windows = Enum.map(Enum.zip([depths, Enum.drop(depths, 1), Enum.drop(depths, 2)]), fn {a, b, c} -> a + b + c end)
IO.puts(
  length(
    Enum.filter(
      Enum.zip(windows, Enum.drop(windows, 1)), fn {a, b} -> b > a end)))
