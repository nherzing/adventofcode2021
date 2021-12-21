defmodule Solver do
  def to_int(pixels) do
    Enum.map(pixels, fn
      ?. -> ?0
      ?\# -> ?1
    end)
    |> List.to_integer(2)
  end

  def apply_algorithm({x, y}, image, algorithm, unknown) do
    [{x-1, y-1}, {x, y-1}, {x+1, y-1}, {x-1, y}, {x, y}, {x+1, y}, {x-1, y+1}, {x, y+1}, {x+1, y+1}]
    |> Enum.map(fn pt -> Map.get(image, pt, unknown) end)
    |> to_int()
    |> then(fn i -> Enum.at(algorithm, i) end)
  end

  def step(algorithm, image, unknown) do
    {{x_min, y_min}, {x_max, y_max}} = Enum.min_max(Map.keys(image))

    for x <- x_min-1..x_max+1, y <- y_min-1..y_max+1, reduce: %{} do
                                                    new_image ->
                                                      Map.put(new_image, {x, y}, apply_algorithm({x, y}, image, algorithm, unknown))
    end
  end

  def next_unknown(unknown, algorithm) do
    unknown
    |> List.duplicate(9)
    |> to_int()
    |> then(fn i -> Enum.at(algorithm, i) end)
  end

  def expand_border(image, unknown) do
    {{x_min, y_min}, {x_max, y_max}} = Enum.min_max(Map.keys(image))
    for x <- x_min-1..x_max+1, y <- y_min-1..y_max+1, reduce: %{} do
                                                    new_image -> Map.put(new_image, {x, y}, Map.get(image, {x, y}, unknown))
    end
  end

  def solve(algorithm, image) do
    (1..50)
    |> Enum.reduce({expand_border(image, ?.), ?.}, fn _, {image, unknown} ->
      {
        step(algorithm, image, unknown),
        next_unknown(unknown, algorithm)
      }
    end)
    |> then(fn {image, _unknown} ->
      Map.values(image)
      |> Enum.count(fn x -> x == ?\# end)
    end)
  end
end

"./input"
|> File.read!()
|> String.split("\n", trim: true)
|> then(fn [algorithm | image] ->
  Solver.solve(
    String.to_charlist(algorithm),
    image
    |> Enum.with_index
    |> Enum.reduce(%{}, fn {line, y}, map ->
      line
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {c, x}, map ->
        Map.put(map, {x, y}, c)
      end)
    end)
  )
end)
|> IO.inspect()
