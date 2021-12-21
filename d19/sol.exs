defmodule Solver do
  def transforms do
    [
    fn [x,y,z] -> [x,y,z] end,
    fn [x,y,z] -> [x,y,-z] end,
    fn [x,y,z] -> [x,-y,z] end,
    fn [x,y,z] -> [x,-y,-z] end,
    fn [x,y,z] -> [x,z,y] end,
    fn [x,y,z] -> [x,z,-y] end,
    fn [x,y,z] -> [x,-z,y] end,
    fn [x,y,z] -> [x,-z,-y] end,

    fn [x,y,z] -> [-x,y,z] end,
    fn [x,y,z] -> [-x,y,-z] end,
    fn [x,y,z] -> [-x,-y,z] end,
    fn [x,y,z] -> [-x,-y,-z] end,
    fn [x,y,z] -> [-x,z,y] end,
    fn [x,y,z] -> [-x,z,-y] end,
    fn [x,y,z] -> [-x,-z,y] end,
    fn [x,y,z] -> [-x,-z,-y] end,

    fn [x,y,z] -> [y,x,z] end,
    fn [x,y,z] -> [y,x,-z] end,
    fn [x,y,z] -> [y,-x,z] end,
    fn [x,y,z] -> [y,-x,-z] end,
    fn [x,y,z] -> [y,z,x] end,
    fn [x,y,z] -> [y,z,-x] end,
    fn [x,y,z] -> [y,-z,x] end,
    fn [x,y,z] -> [y,-z,-x] end,

    fn [x,y,z] -> [-y,x,z] end,
    fn [x,y,z] -> [-y,x,-z] end,
    fn [x,y,z] -> [-y,-x,z] end,
    fn [x,y,z] -> [-y,-x,-z] end,
    fn [x,y,z] -> [-y,z,x] end,
    fn [x,y,z] -> [-y,z,-x] end,
    fn [x,y,z] -> [-y,-z,x] end,
    fn [x,y,z] -> [-y,-z,-x] end,

    fn [x,y,z] -> [z,y,x] end,
    fn [x,y,z] -> [z,y,-x] end,
    fn [x,y,z] -> [z,-y,x] end,
    fn [x,y,z] -> [z,-y,-x] end,
    fn [x,y,z] -> [z,x,y] end,
    fn [x,y,z] -> [z,x,-y] end,
    fn [x,y,z] -> [z,-x,y] end,
    fn [x,y,z] -> [z,-x,-y] end,

    fn [x,y,z] -> [-z,y,x] end,
    fn [x,y,z] -> [-z,y,-x] end,
    fn [x,y,z] -> [-z,-y,x] end,
    fn [x,y,z] -> [-z,-y,-x] end,
    fn [x,y,z] -> [-z,x,y] end,
    fn [x,y,z] -> [-z,x,-y] end,
    fn [x,y,z] -> [-z,-x,y] end,
    fn [x,y,z] -> [-z,-x,-y] end
    ]
  end

  def sub([x1, y1, z1], [x2, y2, z2]) do
    [x1-x2, y1-y2, z1-z2]
  end

  def add([x1, y1, z1], [x2, y2, z2]) do
    [x1+x2, y1+y2, z1+z2]
  end


  def vec_eq?(v1, v2) do
    Enum.find(transforms(), fn t -> v1 == t.(v2) end)
  end

  def all_vectors(beacons) do
    Enum.map(beacons, fn beacon ->
      {
        beacon,
        Enum.map(beacons -- [beacon], fn other_beacon ->
          sub(beacon, other_beacon)
        end)
        |> MapSet.new()
      }
    end)
    |> Map.new()
  end

  def valid_match?(matches) do
    {beacon_a, beacon_b, va, vb} = hd(matches)
    t = vec_eq?(va, vb)
    nt = fn beacon ->
      add(
        sub(beacon_a, t.(beacon_b)),
        t.(beacon)
      )
    end

    Enum.all?(matches, fn {beacon_a, beacon_b, _va, _vb} ->
      nt.(beacon_b) == beacon_a
    end)
  end

  def overlap?(scanner_a, scanner_b) do
    vectors_for_a = all_vectors(scanner_a)
    vectors_for_b = all_vectors(scanner_b)

    vectors_for_a
    |> Enum.find_value(fn {beacon_a, vectors_from_beacon_a} ->
      vectors_for_b
      |> Enum.find_value(fn {beacon_b, vectors_from_beacon_b} ->
        matches = for va <- vectors_from_beacon_a, vb <- vectors_from_beacon_b, vec_eq?(va, vb), do: {beacon_a, beacon_b, va, vb}
        if length(matches) >= 11 && valid_match?(matches) do
          {beacon_a, beacon_b, va, vb} = hd(matches)
          t = vec_eq?(va, vb)
          nt = fn beacon ->
            add(
              sub(beacon_a, t.(beacon_b)),
              t.(beacon)
            )
          end
          nt
        else
          nil
        end
      end)
    end)
  end

  def solve_from(scanner, scanners, mappers) do
    {mappers, to_solve} =
      scanners
      |> Enum.reject(fn scanner -> Map.has_key?(mappers, scanner) end)
      |> Enum.reduce({mappers, _to_solve = MapSet.new()}, fn s, {mappers, to_solve} ->
        case overlap?(scanner, s) do
          nil -> {mappers, to_solve}
          t ->
            nt = fn beacon -> mappers[scanner].(t.(beacon)) end
            {
              Map.put_new(mappers, s, nt),
              MapSet.put(to_solve, s)
            }
        end
    end)

    Enum.reduce(to_solve, mappers, fn scanner, mappers ->
      solve_from(scanner, scanners, mappers)
    end)
  end

  def solve([scanner | scanners]) do
    mappers = solve_from(scanner, scanners, %{scanner => fn beacon -> beacon end})

    Enum.reduce(mappers, MapSet.new(), fn {scanner, t}, beacons ->
      Enum.reduce(scanner, beacons, fn beacon, beacons ->
        MapSet.put(beacons, t.(beacon))
      end)
    end)
  end

  def solve2([scanner | scanners]) do
    mappers = solve_from(scanner, scanners, %{scanner => fn beacon -> beacon end})


    origins = Enum.map(mappers, fn {_, t} -> t.([0,0,0]) end) |> IO.inspect()
    dists = for [x1,y1,z1] <- origins, [x2,y2,z2] <- origins do
      abs(x1-x2)+abs(y1-y2)+abs(z1-z2)
    end
    Enum.max(dists)
  end
end

"./input"
|> File.read!()
|> String.split(~r{\-\-\- scanner \d+ \-\-\-}, trim: true)
|> Enum.map(fn s ->
  s
  |> String.split(["\n", ","], trim: true)
  |> Enum.map(&String.to_integer/1)
  |> Enum.chunk_every(3)
end)
|> Solver.solve2()
|> IO.inspect(limit: :infinity)
