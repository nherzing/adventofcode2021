defmodule DayThree do
  def most_common(list) do
    if Enum.count(list, &(&1 == "1")) >= Enum.count(list, &(&1 == "0")), do: "1", else: "0"
  end

  def least_common(list) do
    if Enum.count(list, &(&1 == "1")) >= Enum.count(list, &(&1 == "0")), do: "0", else: "1"
  end

  def invert([]) do
    []
  end
  def invert(["1" | rest]) do
    ["0" | invert(rest)]
  end
  def invert(["0" | rest]) do
    ["1" | invert(rest)]
  end

  def gamma(binaries) do
    binaries
    |> Enum.map(&String.graphemes/1)
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&most_common/1)
  end

  def metric([value], _bit_position, _eval_fn) do
    value
  end
  def metric(binaries, bit_position, eval_fn) do
    mc = binaries
    |> Enum.map(&(String.at(&1, bit_position)))
    |> eval_fn.()
    o2genrating(Enum.filter(binaries, &(mc == String.at(&1, bit_position))), bit_position + 1, eval_fn)
  end

  def btoi(b) do
    b
    |> Enum.join("")
    |> String.to_integer(2)
  end

  def result(binaries) do
    g = gamma(binaries)
    e = invert(g)
    btoi(g) * btoi(e)
  end

  def result2(binaries) do
    o2gr = metric(binaries, 0, &most_common/1)
    co2s = metric(binaries, 0, &least_common/1)
    String.to_integer(o2gr, 2) * String.to_integer(co2s, 2)
  end
end

binaries = File.stream!("./input", [], :line) |> Stream.map(&String.trim/1)

binaries
|> DayThree.result2()
|> IO.puts
