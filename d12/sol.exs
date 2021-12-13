defmodule DayTwelve do
  def big?(c) do
    c
    |> String.to_charlist()
    |> hd
    |> then(fn c -> c in ?A..?Z end)
  end

  def small?(c) do
    c
    |> String.to_charlist()
    |> hd
    |> then(fn c -> c in ?a..?z end)
  end

  def get_paths(["end" | path], _edges) do
    [Enum.reverse(["end" | path])]
  end
  def get_paths(path, edges) do
    IO.inspect(path, label: "path")
    Map.get(edges, hd(path), MapSet.new())
    |> IO.inspect()
    |> Enum.filter(fn c -> big?(c) || !(c in path) end)
    |> IO.inspect(label: "to")
    |> Enum.reduce([], fn
      c, paths -> get_paths([c | path], edges) ++ paths
    end)
  end

  def add_edge(_path, "start") do
    nil
  end
  def add_edge({caves, true}, cave) do
    if small?(cave) && cave in caves do
      nil
    else
      {[cave | caves], true}
    end
  end
  def add_edge({caves, false}, cave) do
    {[cave | caves], (small?(cave) && (cave in caves))}
  end

  def get_paths2({["end" | path], _}, _edges) do
    [Enum.reverse(["end" | path])]
  end
  def get_paths2(path, edges) do
    Map.get(edges, hd(elem(path, 0)), MapSet.new())
    |> Enum.reduce([], fn c, paths ->
      case add_edge(path, c) do
        nil -> paths
        new_path -> get_paths2(new_path, edges) ++ paths
      end
    end)
  end

  def result(edges) do
    get_paths(["start"], edges)
    |> length()
  end

  def result2(edges) do
    get_paths2({["start"], false}, edges)
    |> length()
  end
end

"./input"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, "-"))
|> Enum.reduce(%{}, fn [a, b], edges ->
  edges
  |> Map.update(a, MapSet.new([b]), fn s -> MapSet.put(s, b) end)
  |> Map.update(b, MapSet.new([a]), fn s -> MapSet.put(s, a) end)
end)
|> IO.inspect()
|> DayTwelve.result2()
|> IO.inspect()
