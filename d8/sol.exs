defmodule DayEight do
  def solve_entry([patterns, outputs]) do
    patterns = patterns
    |> String.split()
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&MapSet.new/1)

    pattern_map = %{}
    segment_map = %{}
    pattern_map = pattern_map
    |> Map.put(1, patterns
      |> Enum.find(fn p -> MapSet.size(p) == 2 end)
    )
    |> Map.put(4, patterns
      |> Enum.find(fn p -> MapSet.size(p) == 4 end)
    )
    |> Map.put(7, patterns
      |> Enum.find(fn p -> MapSet.size(p) == 3 end)
    )
    |> Map.put(8, patterns
      |> Enum.find(fn p -> MapSet.size(p) == 7 end)
    )

    segment_map = Map.put(segment_map, ?a, MapSet.difference(pattern_map[7], pattern_map[1]) |> MapSet.to_list() |> hd())

    counts_cf = pattern_map[1]
    |> Enum.map(fn c -> {Enum.count(patterns, fn p -> MapSet.member?(p, c) end), c} end)
    |> Map.new()

    segment_map = Map.put(segment_map, ?c, counts_cf[8])
    segment_map = Map.put(segment_map, ?f, counts_cf[9])

    counts_bd = MapSet.difference(pattern_map[4], pattern_map[1])
    |> Enum.map(fn c -> {Enum.count(patterns, fn p -> MapSet.member?(p, c) end), c} end)
    |> Map.new()

    segment_map = Map.put(segment_map, ?b, counts_bd[6])
    segment_map = Map.put(segment_map, ?d, counts_bd[7])

    pattern_map = Map.put(pattern_map, 0, MapSet.difference(pattern_map[8], MapSet.new([segment_map[?d]])))
    pattern_map = Map.put(pattern_map, 6, MapSet.difference(pattern_map[8], MapSet.new([segment_map[?c]])))
    pattern_map = Map.put(pattern_map, 2, MapSet.difference(pattern_map[8], MapSet.new([segment_map[?b], segment_map[?f]])))

    counts_eg = MapSet.difference(pattern_map[2], MapSet.new([segment_map[?a], segment_map[?c], segment_map[?d]]))
    |> Enum.map(fn c -> {Enum.count(patterns, fn p -> MapSet.member?(p, c) end), c} end)
    |> Map.new()

    segment_map = Map.put(segment_map, ?e, counts_eg[4])
    segment_map = Map.put(segment_map, ?g, counts_eg[7])

    pattern_map = Map.put(pattern_map, 3, MapSet.new([segment_map[?a], segment_map[?c], segment_map[?d], segment_map[?f], segment_map[?g]]))
    pattern_map = Map.put(pattern_map, 5, MapSet.new([segment_map[?a], segment_map[?b], segment_map[?d], segment_map[?f], segment_map[?g]]))
    pattern_map = Map.put(pattern_map, 9, MapSet.new([segment_map[?a], segment_map[?b], segment_map[?c], segment_map[?d], segment_map[?f], segment_map[?g]]))

    lookup = pattern_map
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Map.new()

    #    IO.inspect(pattern_map, label: "Patterns")
    #    IO.inspect(segment_map, label: "Segments")


    outputs
    |> String.split()
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&MapSet.new/1)
    |> Enum.map(fn ms -> lookup[ms] end)
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join()
    |> String.to_integer()
  end
end

"./input"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, " | "))
|> Enum.map(&DayEight.solve_entry/1)
|> Enum.sum
|> IO.inspect()
