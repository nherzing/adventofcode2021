defmodule Solution do
  def step(template, rules) do
    (0..String.length(template)-2)
    |> Enum.map(fn i ->
      pair = String.slice(template, i, 2)
      String.first(pair) <> rules[pair]
    end)
    |> Enum.join("")
    |> then(&(&1 <> String.last(template)))
  end

  def pair_to_i(pair) do
    pair
    |> String.to_charlist()
  end

  def step2(template, rules) do
    Enum.reduce(template, %{}, fn {k, v}, template ->
      [a, b] = rules[k]
      template
      |> Map.update(a, v, fn x -> x + v end)
      |> Map.update(b, v, fn x -> x + v end)
    end)
  end

  def result2(template, rules) do
    counts = %{}
    |> Map.put(template |> String.to_charlist() |> hd(), 1)
    |> Map.put(template |> String.to_charlist() |> List.last(), 1)
    rules = rules
    |> Enum.map(fn {k, v} ->
      {
        pair_to_i(k),
        [pair_to_i(String.first(k) <> v), pair_to_i(v <> String.last(k))]
      }
    end)
    |> Map.new()

    template = (0..String.length(template)-2)
    |> Enum.map(fn i ->
      pair_to_i(String.slice(template, i, 2))
    end)
    |> Enum.frequencies()

    Enum.reduce(1..40, template, fn _, t -> step2(t, rules) end)
    |> Enum.reduce(counts, fn {[a, b], c}, counts ->
      counts
      |> Map.update(a, c, fn x -> x + c end)
      |> Map.update(b, c, fn x -> x + c end)
    end)
    |> Map.values()
    |> Enum.map(fn x -> x/2 end)
    |> then(fn v -> Enum.max(v) - Enum.min(v) end)
    |> round()
  end

  def result(template, rules) do
    Enum.reduce(1..10, template, fn _, t -> step(t, rules) end)
    |> String.to_charlist()
    |> Enum.group_by(&Function.identity/1)
    |> Map.values()
    |> Enum.map(&length/1)
    |> then(fn v -> Enum.max(v) - Enum.min(v) end)
  end
end

"./input"
|> File.read!()
|> String.split("\n\n", trim: true)
|> then(fn [template, rules] ->
  Solution.result2(
    template,
    rules
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " -> "))
    |> Enum.map(&List.to_tuple/1)
    |> Map.new()
    )
end)
|> IO.inspect()
